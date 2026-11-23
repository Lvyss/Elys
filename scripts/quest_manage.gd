extends Node
## Autoload: QuestManager

signal quest_changed
signal quest_completed(index: int)
signal rune_puzzle_solved

var placed: Array[bool] = [false, false, false]    # pecahan sudah dipasang
var answered: Array[bool] = [false, false, false]  # pertanyaannya sudah dijawab
var solved := false
const FOG_WARN_COOLDOWN := 8.0
var _last_fog_warn := -999.0

const QUESTS := [
	{"title": "Jalan Berkabut", "desc": "Goblin hijau berkeliaran di depan gubuk. Hati-hati saat mendekat, mereka akan mengejarmu.",
	 "tier": 1, "need": 5, "target": "Goblin Prajurit", "coins": 30, "xp": 20},
	{"title": "Sarang Goblin", "desc": "Goblin Elit berjaga di dekat area peti. Mereka licik, menyerang dengan dash lalu kabur (Hit & Run).",
	 "tier": 2, "need": 3, "target": "Goblin Elit", "coins": 60, "xp": 40},
	{"title": "Fajar di Gubuk Tua", "desc": "Sang Raja menjaga daerah altar. Waspadai ancang-ancang getarnya! Hindari serangan hebatnya!",
	 "tier": 3, "need": 1, "target": "Goblin Raja", "coins": 100, "xp": 80},
]

const CREAM := Color("#cdc8a0")
const BROWN_DARK := Color("#2b2523")
const BROWN_MID := Color("#5c4a3a")
const GOLD := Color("#d4af37")
const TEXT_LIGHT := Color("#e8dcc0")
const TEXT_DARK := Color("#3b2a1e")

const TOAST_WIDTH := 380.0
const TRACKER_WIDTH := 270.0
const WARN_COOLDOWN := 20.0

var current := 0
var progress := 0
var all_done := false
var started := false

# --- STATE FINISHING ---
var collecting_runes := false
var runes_solved := false
var chest_opened := false

var _ui: Control
var _tracker: PanelContainer
var _tr_title: Label
var _tr_desc: Label
var _tr_obj: Label
var _tr_count: Label
var _tr_bar: ProgressBar

var _toast: PanelContainer
var _to_head: Label
var _to_title: Label
var _to_body: Label
var _queue: Array = []
var _busy := false
var _last_warn := -999.0


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)

	_ui = Control.new()
	_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.visible = false
	layer.add_child(_ui)

	_build_tracker()
	_build_toast()
	_refresh()

	# Hubungkan sinyal dari altar (saat 3 rune selesai dijawab)
	rune_puzzle_solved.connect(_on_rune_solved)


func _process(_delta: float) -> void:
	_ui.visible = not GameState.ui_open
	_tracker.visible = started


# ---------------- API ----------------
func begin() -> void:
	started = true
	_refresh()
	if all_done or chest_opened:
		return
	var q: Dictionary = QUESTS[current]
	_show_toast("QUEST BARU" if progress == 0 else "QUEST", q["title"], q["desc"])


func report_kill(tier: int) -> void:
	if all_done or chest_opened:
		return
	var q: Dictionary = QUESTS[current]
	if tier != q["tier"]:
		return
	progress += 1
	if progress >= int(q["need"]):
		_complete()
	else:
		_refresh()


func warn_danger(tier: int) -> void:
	if all_done or not started or chest_opened:
		return
	var q: Dictionary = QUESTS[current]
	if tier <= int(q["tier"]):
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_warn < WARN_COOLDOWN:
		return
	_last_warn = now
	_show_toast("PERINGATAN", "Terlalu Berbahaya",
		"Goblin ini jauh lebih kuat darimu. Selesaikan quest \"%s\" dulu." % q["title"])

func warn_fog() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_fog_warn < FOG_WARN_COOLDOWN:
		return
	_last_fog_warn = now
	_show_toast("PERINGATAN", "Kabut Maut",
		"Kabut di luar area menelan siapa pun yang masuk. Berbalik sekarang atau kau akan gugur!")
		
# ---------------- LOGIKA ----------------
func _complete() -> void:
	var q: Dictionary = QUESTS[current]
	GameState.add_coins(int(q["coins"]))
	GameState.add_xp(int(q["xp"]))
	quest_completed.emit(current)
	_show_toast("QUEST SELESAI", q["title"], "+%d Koin     +%d XP" % [q["coins"], q["xp"]])

	current += 1
	progress = 0
	if current >= QUESTS.size():
		all_done = true
		collecting_runes = true
		_show_toast("TUGAS PENJAGA SELESAI", "Hutan Aman",
			"Kumpulkan 3 pecahan rune, lalu bawa ke altar kuno.")
	else:
		var n: Dictionary = QUESTS[current]
		_show_toast("QUEST BARU", n["title"], n["desc"])
	_refresh()


# Dipanggil dari Altar saat ketiga teka-teki rune berhasil dijawab
func _on_rune_solved() -> void:
	collecting_runes = false
	runes_solved = true
	_refresh()


# Dipanggil dari Peti saat peti berhasil dibuka
func open_chest() -> void:
	chest_opened = true
	_refresh()


func _refresh() -> void:
	if _tr_title == null:
		return
	
	# PRIORITAS 1: Game Tamat / Peti Kebuka
	if chest_opened:
		_tr_title.text = "Petualangan Selesai"
		_tr_desc.text = "Kau telah mengalahkan Sang Raja Goblin, memecahkan teka-teki Rune Kuno, dan membuka Peti Harta Karun. Hutan kini aman."
		_tr_obj.text = "Kemenangan!"
		_tr_count.text = "✔"
		_tr_bar.max_value = 1
		_tr_bar.value = 1
	
	# PRIORITAS 2: Rune udah beres, tinggal buka peti
	elif runes_solved:
		_tr_title.text = "Harta Karun Terkunci"
		_tr_desc.text = "Cahaya dari altar telah membuka jalan. Bawa Kunci Rune dan buka Peti Kuno!"
		_tr_obj.text = "Buka Peti"
		_tr_count.text = "0 / 1"
		_tr_bar.max_value = 1
		_tr_bar.value = 0
	
	# PRIORITAS 3: Lagi ngumpulin / jawab teka-teki rune
	elif collecting_runes:
		_tr_title.text = "Teka-Teki Rune"
		_tr_desc.text = "Cahaya altar memanggil. Susun pecahan rune dan jawab teka-tekinya."
		_tr_obj.text = "Kumpulkan Pecahan Rune"
		var total_runes = 0
		for p in placed:
			if p: total_runes += 1
		_tr_count.text = "%d / 3" % total_runes
		_tr_bar.max_value = 3
		_tr_bar.value = total_runes
	
	# PRIORITAS 4: Misi tembak-tembakan goblin
	else:
		var q: Dictionary = QUESTS[current]
		_tr_title.text = "%d. %s" % [current + 1, q["title"]]
		_tr_desc.text = q["desc"]
		_tr_obj.text = "Kalahkan " + q["target"]
		_tr_count.text = "%d / %d" % [progress, q["need"]]
		_tr_bar.max_value = q["need"]
		_tr_bar.value = progress
		
	quest_changed.emit()


# ---------------- UI: PEMBANGUN ----------------
func _box(bg: Color, border: Color, bw := 2, radius := 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	return s


func _label(size: int, color: Color, wrap := false) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _make_panel(width: float, vpad := 10, sep := 6) -> Dictionary:
	var root := PanelContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.custom_minimum_size.x = width
	var st := _box(BROWN_DARK, BROWN_MID, 2, 5)
	st.shadow_color = Color(0, 0, 0, 0.5)
	st.shadow_size = 6
	root.add_theme_stylebox_override("panel", st)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	root.add_child(vb)

	var head := PanelContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hs := _box(CREAM, GOLD, 0, 2)
	hs.border_width_bottom = 2
	hs.content_margin_top = 4
	hs.content_margin_bottom = 4
	head.add_theme_stylebox_override("panel", hs)
	var header := _label(13, TEXT_DARK)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(header)
	vb.add_child(head)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, vpad)
	vb.add_child(margin)

	var body := VBoxContainer.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_constant_override("separation", sep)
	margin.add_child(body)

	return {"root": root, "header": header, "body": body}


func _build_tracker() -> void:
	var p := _make_panel(TRACKER_WIDTH)
	_tracker = p["root"]
	_ui.add_child(_tracker)
	_tracker.anchor_left = 1.0
	_tracker.anchor_right = 1.0
	_tracker.offset_left = -(TRACKER_WIDTH + 16.0)
	_tracker.offset_right = -16.0
	_tracker.offset_top = 16.0

	(p["header"] as Label).text = "QUEST"
	var body: VBoxContainer = p["body"]

	_tr_title = _label(16, GOLD)
	_tr_desc = _label(12, TEXT_LIGHT, true)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tr_obj = _label(12, TEXT_LIGHT)
	_tr_obj.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tr_count = _label(12, GOLD)
	row.add_child(_tr_obj)
	row.add_child(_tr_count)

	_tr_bar = ProgressBar.new()
	_tr_bar.show_percentage = false
	_tr_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tr_bar.custom_minimum_size.y = 10
	_tr_bar.add_theme_stylebox_override("background", _box(Color("#1a1512"), BROWN_MID, 1, 2))
	_tr_bar.add_theme_stylebox_override("fill", _box(GOLD, GOLD, 0, 2))

	body.add_child(_tr_title)
	body.add_child(_tr_desc)
	body.add_child(row)
	body.add_child(_tr_bar)


func _build_toast() -> void:
	var p := _make_panel(TOAST_WIDTH, 3, 2)
	_toast = p["root"]
	_toast.size_flags_vertical = Control.SIZE_SHRINK_BEGIN 
	_toast.visible = false
	_ui.add_child(_toast)

	_to_head = p["header"]
	var body: VBoxContainer = p["body"]
	_to_title = _label(20, GOLD)
	_to_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_to_body = _label(13, TEXT_LIGHT, true)
	_to_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(_to_title)
	body.add_child(_to_body)


# ---------------- UI: POPUP ----------------
func _show_toast(header: String, title: String, text: String) -> void:
	_queue.append([header, title, text])
	if not _busy:
		_run_queue()


func _run_queue() -> void:
	_busy = true
	while not _queue.is_empty():
		var t: Array = _queue.pop_front()
		_to_head.text = t[0]
		_to_title.text = t[1]
		_to_body.text = t[2]
		_toast.reset_size()
		await get_tree().process_frame

		_toast.reset_size()
		await get_tree().process_frame
		var vw := get_viewport().get_visible_rect().size.x
		_toast.position.x = (vw - _toast.size.x) * 0.5
		_toast.offset_top = -_toast.size.y - 10.0
		_toast.offset_bottom = -10.0
		_toast.modulate.a = 0.0
		_toast.visible = true

		var tin := create_tween().set_parallel(true)
		tin.tween_property(_toast, "offset_top", 24.0, 0.4)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tin.tween_property(_toast, "modulate:a", 1.0, 0.3)
		await tin.finished

		await get_tree().create_timer(3.2).timeout

		var tout := create_tween().set_parallel(true)
		tout.tween_property(_toast, "offset_top", -_toast.size.y - 10.0, 0.3)
		tout.tween_property(_toast, "modulate:a", 0.0, 0.3)
		await tout.finished
		_toast.visible = false
	_busy = false


# ---------------- UI: TOMBOL STYLE ----------------
func _style_btn(b: Button) -> void:
	b.add_theme_stylebox_override("normal", _box(Color("#352b26"), BROWN_MID, 2, 5))
	b.add_theme_stylebox_override("hover", _box(Color("#40342c"), GOLD, 2, 5))
	b.add_theme_stylebox_override("pressed", _box(Color(0.83, 0.69, 0.22, 0.25), GOLD, 2, 5))
	b.add_theme_stylebox_override("disabled", _box(Color("#1a1614"), Color("#332a25"), 1, 5))
	b.add_theme_color_override("font_color", TEXT_LIGHT)
	b.add_theme_color_override("font_hover_color", GOLD)
	b.add_theme_color_override("font_pressed_color", GOLD)
	b.add_theme_color_override("font_disabled_color", Color("#5a5048"))
	b.add_theme_font_size_override("font_size", 15)
	b.focus_mode = Control.FOCUS_NONE
