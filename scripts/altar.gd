extends Node3D
## Pasang di node Altar. Stone1, Stone2, Stone3 harus anak langsung.

const SHARDS: Array[StringName] = [&"pecahan_rune_1", &"pecahan_rune_2", &"pecahan_rune_3"]
const RUNE_NAMES := ["I", "II", "III"]
const INTERACT_RANGE := 3.5
const WRONG_DAMAGE := 100
const DIM_GLOW := 0.9      # terpasang, belum dijawab
const FULL_GLOW := 1.7     # sudah dijawab

# Warna tiap batu: cyan, emas, ungu
const GLOW_COLORS: Array[Color] = [
	Color(0.25, 0.95, 1.0),
	Color(1.0, 0.75, 0.2),
	Color(0.75, 0.4, 1.0),
]

const GLOW_SHADER := """
shader_type spatial;
render_mode blend_add, unshaded, depth_draw_never, cull_back;
uniform vec4 glow_color : source_color = vec4(0.25, 0.95, 1.0, 1.0);
uniform float intensity = 0.0;
void fragment() {
	float f = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.0);
	float pulse = 0.85 + 0.15 * sin(TIME * 2.5);
	ALBEDO = glow_color.rgb * (0.2 + f * 1.2) * intensity * pulse;
	ALPHA = 1.0;
}
"""

# opsi[0] = jawaban benar. Urutan tampil diacak.
const QUESTIONS := [
	{
		"latar": "Di Menara Ukiran, sang Penempa menetapkan sebuah Cetak Biru Senjata: setiap senjata WAJIB memiliki kemampuan Menyerang, namun Cetak Biru itu tak pernah menjelaskan bagaimana cara menyerang.",
		"isi": "Pedang menebas, busur melepaskan panah, tongkat memancarkan petir. Tetapi Cetak Biru itu sendiri tak pernah bisa ditempa menjadi senjata nyata.",
		"tanya": "Dalam bahasa para penyihir kode, apakah nama Cetak Biru yang tak dapat diwujudkan langsung itu?",
		"opsi": ["Kelas abstrak", "Objek konkret", "Variabel global", "Konstruktor"],
	},
	{
		"latar": "Penjaga gerbang meneriakkan satu mantra yang sama: \"SERANG!\"",
		"isi": "Prajurit mengayunkan gada sekali. Elit mengayun dua kali beruntun. Raja menghantam tanah hingga bergetar. Mantra tetap satu, namun wujud tindakan berbeda sesuai penerimanya.",
		"tanya": "Apakah nama prinsip ketika satu perintah menghasilkan perilaku berbeda pada wujud yang berbeda?",
		"opsi": ["Polimorfisme", "Enkapsulasi", "Pewarisan saja", "Abstraksi"],
	},
	{
		"latar": "Pecahan pertama berbunyi: \"Setiap goblin WAJIB bisa bergerak dan menyerang.\" Pecahan kedua berbunyi: \"Prajurit, Elit, dan Raja menentukan sendiri cara mereka menyerang.\"",
		"isi": "Pecahan pertama hanya menetapkan kewajiban tanpa menjelaskan caranya. Pecahan kedua mengisi caranya, berbeda-beda untuk tiap goblin.",
		"tanya": "Apa nama untuk pecahan pertama dan pecahan kedua secara berurutan?",
		"opsi": ["Abstraksi, lalu Polimorfisme (override method)", "Polimorfisme, lalu Abstraksi", "Enkapsulasi, lalu Pewarisan", "Konstruktor, lalu Destruktor"],
	},
]

var _stones: Array[Node3D] = []
var _mats: Array = [null, null, null]
var _lights: Array[OmniLight3D] = []
var _center := Vector3.ZERO
var _prompt: Label3D
var _hero: Node3D
var _near := false
var _busy := false
var _locked := false

var _cur := -1
var _orders: Array = [[], [], []]
var _wrongs: Array = [[], [], []]

var _layer: CanvasLayer
var _panel: PanelContainer
var _hdr: Label
var _lbl_latar: Label
var _lbl_isi: Label
var _lbl_tanya: Label
var _lbl_warn: Label
var _warn_panel: PanelContainer
var _btns: Array[Button] = []
var _btn_hint: Button
var _shader: Shader


func _ready() -> void:
	_shader = Shader.new()
	_shader.code = GLOW_SHADER

	for i in 3:
		var s := get_node_or_null("Stone%d" % (i + 1)) as Node3D
		if s == null:
			push_error("Altar: Stone%d tidak ditemukan" % (i + 1))
			return
		_stones.append(s)
		_center += s.global_position

		# lampu dibuat mati (energi 0), jadi altar polos tanpa efek
		var l := OmniLight3D.new()
		l.light_color = GLOW_COLORS[i]
		l.omni_range = 3.5
		l.light_energy = 0.0
		l.shadow_enabled = false
		add_child(l)
		l.global_position = s.global_position + Vector3(0, 0.9, 0.5)
		_lights.append(l)

	_center /= 3.0

	_prompt = Label3D.new()
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.no_depth_test = true
	_prompt.pixel_size = 0.006
	_prompt.outline_size = 12
	_prompt.visible = false
	add_child(_prompt)
	_prompt.global_position = _center + Vector3(0, 2.4, 0)

	# pulihkan keadaan kalau scene dimuat ulang
	for i in 3:
		if QuestManager.placed[i]:
			_set_glow(FULL_GLOW if QuestManager.answered[i] else DIM_GLOW, i)


func _process(_delta: float) -> void:
	if _stones.is_empty():
		return
	if _hero == null or not is_instance_valid(_hero):
		_hero = get_tree().get_first_node_in_group("player") as Node3D
	_near = false
	if _hero:
		var d := _hero.global_position - _center
		d.y = 0.0
		_near = d.length() < INTERACT_RANGE

	_prompt.visible = _near and not GameState.ui_open and not QuestManager.solved and not _busy
	if _prompt.visible:
		_prompt.text = _prompt_text()


func _prompt_text() -> String:
	var p := _pending()
	if p >= 0:
		return "E: Baca teka-teki Rune %s" % RUNE_NAMES[p]
	if _carry_count() > 0:
		return "E: Letakkan pecahan rune"
	return "Rune terpasang %d/3" % _placed_count()


# ---------------- STATUS ----------------
func _pending() -> int:
	for i in 3:
		if QuestManager.placed[i] and not QuestManager.answered[i]:
			return i
	return -1


func _placed_count() -> int:
	var n := 0
	for p in QuestManager.placed:
		if p:
			n += 1
	return n


func _carry_count() -> int:
	var n := 0
	for i in 3:
		if not QuestManager.placed[i] and GameState.get_count(SHARDS[i]) > 0:
			n += 1
	return n


# ---------------- INPUT ----------------
func _input(event: InputEvent) -> void:
	if _layer and _layer.visible and event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()

	# --- TOMBOL RAHASIA BUAT TES ---
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			print("CHEAT: Dapet Kunci!")
			GameState.add_item(&"kunci_peti", 1)
		elif event.keycode == KEY_F2:
			print("CHEAT: Paksa Peti Kebuka!")
			# Ganti "Peti" dengan nama node petimu di scene (misal "Sketchfab_Scene")
			var peti = get_tree().current_scene.get_node_or_null("Peti") 
			if peti and peti.has_method("_try_open"):
				peti._try_open()
	# --------------------------------


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if not _near or GameState.ui_open or QuestManager.solved or _busy:
		return
	var p := _pending()
	if p >= 0:
		get_viewport().set_input_as_handled()
		_open_puzzle(p)
	elif _carry_count() > 0:
		get_viewport().set_input_as_handled()
		_place_next()


# ---------------- PASANG PECAHAN ----------------
func _place_next() -> void:
	for i in 3:
		if not QuestManager.placed[i] and GameState.get_count(SHARDS[i]) > 0:
			_busy = true
			GameState.remove_item(SHARDS[i])
			QuestManager.placed[i] = true
			_light_up(i, 3.2, DIM_GLOW)
			await get_tree().create_timer(1.0).timeout
			_busy = false
			_open_puzzle(i)
			return


# ---------------- GLOW ----------------
func _ensure_mat(i: int) -> ShaderMaterial:
	if _mats[i] == null:
		var m := ShaderMaterial.new()
		m.shader = _shader
		m.set_shader_parameter("glow_color", GLOW_COLORS[i])
		m.set_shader_parameter("intensity", 0.0)
		_mats[i] = m
		for mesh in _stones[i].find_children("*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).material_overlay = m
	return _mats[i]


func _set_glow(v: float, i: int) -> void:
	_ensure_mat(i).set_shader_parameter("intensity", v)
	_lights[i].light_energy = v * 1.6


func _light_up(i: int, peak: float, rest: float) -> void:
	var tw := create_tween()
	tw.tween_method(_set_glow.bind(i), 0.0, peak, 0.35)
	tw.tween_method(_set_glow.bind(i), peak, rest, 0.7)


# ---------------- POPUP ----------------
func _open_puzzle(i: int) -> void:
	_cur = i
	if _layer == null:
		_build_ui()
	if _orders[i].is_empty():
		_orders[i] = [0, 1, 2, 3]
		_orders[i].shuffle()
	_fill_ui()
	_layer.visible = true
	GameState.ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().process_frame
	_panel.pivot_offset = _panel.size * 0.5


func _close() -> void:
	if _layer:
		_layer.visible = false
	GameState.ui_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 25
	_layer.visible = false
	add_child(_layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(center)

	var p: Dictionary = QuestManager._make_panel(580.0, 14, 10)
	_panel = p["root"]
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(_panel)
	_hdr = p["header"]
	var body: VBoxContainer = p["body"]

	_lbl_latar = QuestManager._label(13, QuestManager.TEXT_LIGHT, true)
	_lbl_isi = QuestManager._label(13, QuestManager.TEXT_LIGHT, true)
	body.add_child(_lbl_latar)
	body.add_child(_lbl_isi)

	var line := ColorRect.new()
	line.custom_minimum_size.y = 2
	line.color = QuestManager.BROWN_MID
	body.add_child(line)

	_lbl_tanya = QuestManager._label(16, QuestManager.GOLD, true)
	body.add_child(_lbl_tanya)

	# ---- kotak info damage (senada tema, ada aksen merah lembut) ----
	_warn_panel = PanelContainer.new()
	var ws := StyleBoxFlat.new()
	ws.bg_color = Color(0.5, 0.12, 0.10, 0.22)
	ws.border_color = Color(0.9, 0.42, 0.35, 0.65)
	ws.border_width_left = 3
	ws.set_corner_radius_all(4)
	ws.content_margin_left = 12
	ws.content_margin_right = 10
	ws.content_margin_top = 6
	ws.content_margin_bottom = 6
	_warn_panel.add_theme_stylebox_override("panel", ws)
	_lbl_warn = QuestManager._label(13, Color("#ffb3a7"))
	_warn_panel.add_child(_lbl_warn)
	body.add_child(_warn_panel)

	for k in 4:
		var b := Button.new()
		b.custom_minimum_size.y = 42
		_style_btn(b)
		b.pressed.connect(_answer.bind(k))
		body.add_child(b)
		_btns.append(b)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_btn_hint = Button.new()
	_btn_hint.custom_minimum_size.y = 34
	_style_btn(_btn_hint, true)
	_btn_hint.pressed.connect(_use_hint)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "Tutup  (Esc)"
	close.custom_minimum_size.y = 34
	_style_btn(close, true)
	close.pressed.connect(_close)
	row.add_child(_btn_hint)
	row.add_child(spacer)
	row.add_child(close)
	body.add_child(row)


func _style_btn(b: Button, compact := false) -> void:
	var q := QuestManager
	var r := 5
	b.add_theme_stylebox_override("normal", _mk_btn_box(Color("#352b26"), q.BROWN_MID, 2, r, compact))
	b.add_theme_stylebox_override("hover", _mk_btn_box(Color("#40342c"), q.GOLD, 2, r, compact))
	b.add_theme_stylebox_override("pressed", _mk_btn_box(Color(0.83, 0.69, 0.22, 0.25), q.GOLD, 2, r, compact))
	b.add_theme_stylebox_override("disabled", _mk_btn_box(Color("#1a1614"), Color("#332a25"), 1, r, compact))
	b.add_theme_color_override("font_color", q.TEXT_LIGHT)
	b.add_theme_color_override("font_hover_color", q.GOLD)
	b.add_theme_color_override("font_pressed_color", q.GOLD)
	b.add_theme_color_override("font_disabled_color", Color("#5a5048"))
	b.add_theme_font_size_override("font_size", 15 if not compact else 13)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.focus_mode = Control.FOCUS_NONE


func _mk_btn_box(bg: Color, border: Color, bw: int, radius: int, compact: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 16 if not compact else 12
	s.content_margin_right = 16 if not compact else 12
	s.content_margin_top = 10 if not compact else 6
	s.content_margin_bottom = 10 if not compact else 6
	return s


func _fill_ui() -> void:
	var q: Dictionary = QUESTIONS[_cur]
	_hdr.text = "TEKA-TEKI RUNE %s" % RUNE_NAMES[_cur]
	_lbl_latar.text = q["latar"]
	_lbl_isi.text = q["isi"]
	_lbl_tanya.text = q["tanya"]

	var done: bool = QuestManager.answered[_cur]

	_lbl_warn.text = "Jawaban salah: −%d nyawa" % WRONG_DAMAGE
	_warn_panel.visible = not done

	for k in 4:
		_btns[k].text = "%s.    %s" % ["ABCD"[k], q["opsi"][_orders[_cur][k]]]
		_btns[k].disabled = _wrongs[_cur].has(k) or done

	var gulungan := GameState.get_count(&"gulungan_petunjuk")
	_btn_hint.text = "Gulungan Petunjuk (%d)" % gulungan
	_btn_hint.disabled = gulungan <= 0 or _hint_candidates().is_empty() or done


func _hint_candidates() -> Array:
	var c := []
	for k in 4:
		if _orders[_cur][k] != 0 and not _wrongs[_cur].has(k):
			c.append(k)
	if c.size() <= 1:      # sisakan minimal satu pilihan salah
		return []
	return c


func _use_hint() -> void:
	var c := _hint_candidates()
	if c.is_empty() or GameState.get_count(&"gulungan_petunjuk") <= 0:
		return
	GameState.remove_item(&"gulungan_petunjuk")
	_wrongs[_cur].append(c.pick_random())
	_fill_ui()


# ---------------- JAWAB ----------------
func _answer(k: int) -> void:
	if _locked or QuestManager.answered[_cur]:
		return
	if _orders[_cur][k] == 0:
		_correct()
		return

	_wrongs[_cur].append(k)
	_fill_ui()
	_shake_panel()
	var i := _cur
	var tw := create_tween()
	tw.tween_method(_set_glow.bind(i), DIM_GLOW, 0.1, 0.1)
	tw.tween_method(_set_glow.bind(i), 0.1, DIM_GLOW, 0.4)
	if _hero and _hero.has_method("take_damage"):
		_hero.take_damage(WRONG_DAMAGE)
	if _hero and _hero.get("is_dead") == true:
		_close()


func _shake_panel() -> void:
	var tw := create_tween()
	for a in [2.0, -2.0, 1.5, -1.5, 0.0]:
		tw.tween_property(_panel, "rotation_degrees", a, 0.05)


func _correct() -> void:
	_locked = true
	var i := _cur
	QuestManager.answered[i] = true
	_fill_ui()
	_light_up(i, 4.0, FULL_GLOW)
	await get_tree().create_timer(1.1).timeout
	_close()
	_locked = false

	var count := 0
	for a in QuestManager.answered:
		if a:
			count += 1

	if count >= 3:
		QuestManager.solved = true
		QuestManager._show_toast("SEMUA RUNE MENYALA", "Rune Menempa",
			"Cahaya mengalir dari altar. Sesuatu sedang ditempa...")
		for k in 3:
			_light_up(k, 4.5, FULL_GLOW)

		# Spawn kunci yang muncul dramatis di tengah altar
		_spawn_rune_key()

		QuestManager.rune_puzzle_solved.emit()
	else:
		QuestManager._show_toast("RUNE %s MENYALA" % RUNE_NAMES[i], "Jawaban Benar",
			"Letakkan pecahan berikutnya di altar.")


func _spawn_rune_key() -> void:
	# Cegah dobel spawn kalau scene reload setelah solved
	if GameState.get_flag(&"rune_key_taken"):
		return
	if has_node("RuneKeyReward"):
		return

	var k := preload("res://scripts/RuneKeyReward.gd").new()
	k.name = "RuneKeyReward"
	add_child(k)
	k.global_position = _center + Vector3(0, 0.0, 0)  # pusat altar
