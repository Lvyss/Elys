
extends Node3D
## Pasang di node Peti (Sketchfab_Scene).

@export var chest_id: StringName = &"peti_kuno_altar"
@export var reward_items: Array[StringName] = [&"kristal_kabut", &"ramuan_hijau"]
@export var reward_coins: int = 100
@export var reward_xp: int = 50
@export var interact_range: float = 3.5
@export var required_key: StringName = &"kunci_peti"

var _opened := false
var _prompt: Label3D
var _hero: Node3D
var _near := false

var _anim: AnimationPlayer
var _particles: GPUParticles3D
var _light_burst: OmniLight3D

# SOUND EFFECTS 3D
@onready var chest_open_sfx: AudioStreamPlayer3D = $ChestOpenSFX
@onready var victory_sfx: AudioStreamPlayer3D = $VictorySFX


func _ready() -> void:
	_anim = _find_anim()

	# Tempatkan sumber suara di posisi peti.
	chest_open_sfx.position = Vector3.ZERO
	victory_sfx.position = Vector3.ZERO

	# --- SETUP UI & EFEK ---
	_prompt = Label3D.new()
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.no_depth_test = true
	_prompt.pixel_size = 0.006
	_prompt.outline_size = 12
	_prompt.visible = false
	add_child(_prompt)
	_prompt.global_position = global_position + Vector3(0, 1.5, 0)

	_light_burst = OmniLight3D.new()
	_light_burst.light_color = Color(1.0, 0.8, 0.4)
	_light_burst.omni_range = 0.0
	_light_burst.light_energy = 0.0
	_light_burst.shadow_enabled = false
	add_child(_light_burst)
	_light_burst.global_position = global_position + Vector3(0, 1.0, 0)

	_setup_particles()

	# --- POSISI AWAL PETI ---
	_opened = GameState.get_flag(chest_id)
	_pose_chest(_opened)


# ---------------- ANIMASI ----------------
func _find_anim() -> AnimationPlayer:
	var a := find_child("AnimationPlayer", true, false) as AnimationPlayer

	if a == null and get_parent():
		a = get_parent().find_child("AnimationPlayer", true, false) as AnimationPlayer

	if a == null:
		push_warning("Peti: AnimationPlayer tidak ketemu")
	else:
		print("Peti anim: ", a.get_animation_list())

	return a


func _open_anim_name() -> String:
	if _anim and _anim.has_animation("Armature|A_Open"):
		return "Armature|A_Open"
	return ""


func _close_anim_name() -> String:
	if _anim and _anim.has_animation("Armature|A_Close"):
		return "Armature|A_Close"
	return ""


func _pose_chest(open: bool) -> void:
	if _anim == null:
		return

	_anim.autoplay = ""
	_anim.stop()

	# Kalau sudah dibuka: tahan di akhir A_Open.
	# Kalau belum: tahan di akhir A_Close.
	var anim_name := _open_anim_name() if open else _close_anim_name()

	if anim_name == "":
		return

	await get_tree().process_frame

	_anim.play(anim_name, -1, 0.0)
	_anim.seek(_anim.get_animation(anim_name).length, true)
	_anim.pause()


# ---------------- PARTIKEL ----------------
func _setup_particles() -> void:
	_particles = GPUParticles3D.new()
	_particles.emitting = false
	_particles.amount = 30
	_particles.lifetime = 1.5
	_particles.one_shot = false

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 1.0
	mat.initial_velocity_max = 3.0
	mat.gravity = Vector3(0, 1, 0)
	mat.scale_min = 0.5
	mat.scale_max = 1.5
	mat.color = Color(1.0, 0.9, 0.5)

	_particles.process_material = mat

	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.05, 0.05, 0.05)
	_particles.draw_pass_1 = mesh

	add_child(_particles)
	_particles.position = Vector3(0, 0.5, 0)


# ---------------- INTERAKSI ----------------
func _process(_delta: float) -> void:
	if _hero == null or not is_instance_valid(_hero):
		_hero = get_tree().get_first_node_in_group("player") as Node3D

	_near = false

	if _hero and not _opened:
		var d := _hero.global_position - global_position
		d.y = 0.0
		_near = d.length() < interact_range

	_prompt.visible = _near and not GameState.ui_open and not _opened

	if _prompt.visible:
		_prompt.text = "E: Buka Peti" if GameState.get_count(required_key) > 0 else "Peti Terkunci"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	if not _near or GameState.ui_open or _opened:
		return

	get_viewport().set_input_as_handled()
	_try_open()


func _try_open() -> void:
	if GameState.get_count(required_key) <= 0:
		QuestManager._show_toast(
			"PETI TERKUNCI",
			"Butuh Kunci",
			"Selesaikan teka-teki Rune di altar."
		)
		return

	GameState.remove_item(required_key)
	_opened = true
	GameState.set_flag(chest_id, true)
	_prompt.visible = false

	_play_open_effect()


# ---------------- EFEK PETI TERBUKA ----------------
func _play_open_effect() -> void:
	# 1. SOUND 3D: suara peti terbuka.
	if chest_open_sfx.stream != null:
		chest_open_sfx.play()

	# 2. Animasi buka.
	if _anim:
		var anim_name := _open_anim_name()

		if anim_name != "":
			_anim.play(anim_name, -1, 1.0)

	# 3. Efek sinar terang.
	var tw_light := create_tween()
	tw_light.tween_property(_light_burst, "light_energy", 8.0, 0.3)
	tw_light.parallel().tween_property(_light_burst, "omni_range", 6.0, 0.5)
	tw_light.tween_property(_light_burst, "light_energy", 2.0, 1.5)

	# 4. Partikel bintang.
	_particles.emitting = true

	# 5. Tunggu sebelum hadiah diberikan.
	await get_tree().create_timer(0.5).timeout

	_give_rewards()


# ---------------- HADIAH ----------------
func _give_rewards() -> void:
	for id in reward_items:
		GameState.add_item(id, 1)

	GameState.add_coins(reward_coins)
	GameState.add_xp(reward_xp)

	QuestManager.open_chest()

	GameState.ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	await get_tree().create_timer(1.5).timeout

	_show_end_game_popup()


# ---------------- LAYAR KEMENANGAN ----------------
func _show_end_game_popup() -> void:
	# SOUND 3D: victory fanfare saat permainan selesai.
	if victory_sfx.stream != null:
		victory_sfx.play()

	var layer := CanvasLayer.new()
	layer.layer = 30
	add_child(layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)

	create_tween().tween_property(dim, "color:a", 0.85, 1.0)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var p := QuestManager._make_panel(480.0, 20, 12)
	var panel: PanelContainer = p["root"]
	center.add_child(panel)

	panel.scale = Vector2(0.5, 0.5)
	panel.modulate.a = 0.0

	var tw_pop := create_tween().set_parallel(true)
	tw_pop.tween_property(
		panel,
		"scale",
		Vector2.ONE,
		0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tw_pop.tween_property(
		panel,
		"modulate:a",
		1.0,
		0.5
	)

	var hdr: Label = p["header"]
	hdr.text = "PETUALANGAN SELESAI"

	var body: VBoxContainer = p["body"]

	var title := QuestManager._label(28, QuestManager.GOLD)
	title.text = "KEMENANGAN!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var desc := QuestManager._label(14, QuestManager.TEXT_LIGHT, true)
	desc.text = "Kau telah memecahkan teka-teki Rune, membuka Peti Kuno, dan membawa kedamaian bagi Hutan. Sang Penempa bangga padamu."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var btn_close := Button.new()
	btn_close.text = "Kembali ke Menu"
	btn_close.custom_minimum_size.y = 40
	QuestManager._style_btn(btn_close)

	btn_close.pressed.connect(func():
		GameState.ui_open = false
		get_tree().quit()
	)

	body.add_child(title)
	body.add_child(desc)
	body.add_child(btn_close)
