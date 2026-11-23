extends Node3D
## Kunci hadiah yang muncul dramatis di tengah altar setelah 3 rune selesai.
## Menggunakan gambar icon dari ItemData.

@export var item_id: StringName = &"kunci_peti"
@export var interact_range: float = 3.5
@export var drop_height: float = 5.0        # Dari atas berapa meter
@export var drop_duration: float = 2.5      # Durasi jatuh
@export var spin_speed: float = 60.0        # Putaran
@export var bob_amplitude: float = 0.15
@export var bob_speed: float = 2.0

var _sprite: Sprite3D
var _light: OmniLight3D
var _prompt: Label3D
var _hero: Node3D
var _near := false
var _ready_to_collect := false
var _collected := false
var _float_time := 0.0
var _base_y := 1.2 # Ketinggian akhir kunci melayang

func _ready() -> void:
	# --- 1. Ambil data item & icon dari .tres ---
	var item_data := GameState.get_item_data(item_id)
	
	_sprite = Sprite3D.new()
	_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Selalu menghadap kamera
	_sprite.no_depth_test = true # Biar gak nembus objek lain
	_sprite.pixel_size = 0.001 # Ukuran pixel art (sesuaikan jika terlalu besar/kecil)
	_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST # Bikin pixel art tajam
	
	if item_data and item_data.icon:
		_sprite.texture = item_data.icon
	else:
		push_warning("Icon untuk " + item_id + " tidak ditemukan, pakai kotak fallback.")
		# Fallback kalau icon gak ada, pakai kotak emas sederhana
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.8, 0.2))
		_sprite.texture = ImageTexture.create_from_image(img)

	# Tambahkan sedikit efek menyala (modulate) pada gambar
	_sprite.modulate = Color(1.2, 1.1, 0.8) 
	add_child(_sprite)

	# --- 2. Cahaya (Glow) ---
	_light = OmniLight3D.new()
	_light.light_color = Color(1.0, 0.8, 0.3)
	_light.omni_range = 3.0
	_light.light_energy = 0.0
	_light.shadow_enabled = false
	add_child(_light)
	# Posisi cahaya disamakan dengan tinggi kunci
	_light.position = Vector3(0, _base_y, 0)

	# --- 3. Prompt Interaksi ---
	_prompt = Label3D.new()
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.no_depth_test = false
	_prompt.pixel_size = 0.006
	_prompt.outline_size = 12
	_prompt.text = "E: Ambil Kunci"
	_prompt.visible = false
	add_child(_prompt)
	_prompt.position = Vector3(0, _base_y + 0.8, 0)

	# --- 4. Mulai Animasi ---
	_play_spawn_animation()


func _play_spawn_animation() -> void:
	# Posisi awal: jauh di atas, skala 0, belum ada cahaya
	_sprite.position = Vector3(0, _base_y + drop_height, 0)
	_sprite.scale = Vector3.ZERO
	_light.light_energy = 0.0

	# 1. Skala membesar (pop)
	var tw_scale := create_tween()
	tw_scale.tween_property(_sprite, "scale", Vector3.ONE * 1.5, 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# 2. Jatuh perlahan (Lambat di akhir biar estetik)
	var tw_drop := create_tween().set_parallel(true)
	tw_drop.tween_property(_sprite, "position:y", _base_y, drop_duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw_drop.tween_property(_light, "light_energy", 2.5, drop_duration * 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	await tw_drop.finished

	# 3. Efek memantul (bounce) halus
	var tw_bounce := create_tween()
	tw_bounce.tween_property(_sprite, "position:y", _base_y + 0.3, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw_bounce.tween_property(_sprite, "position:y", _base_y, 0.4)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tw_bounce.finished

	_ready_to_collect = true


func _process(delta: float) -> void:
	_float_time += delta

	# Efek melayang (bob) naik-turun halus
	if _ready_to_collect and not _collected and _sprite:
		_sprite.position.y = _base_y + sin(_float_time * bob_speed) * bob_amplitude
		# Karena Sprite3D selalu menghadap kamera, kita gak bisa muter sumbu Y-nya
		# Jadi kita kasih efek muter 2D (goyang kiri-kanan sedikit) biar hidup
		_sprite.rotation_degrees.z = sin(_float_time * 2.0) * 5.0 

	# Glow pulse pada cahaya
	if _light and not _collected:
		_light.light_energy = 2.5 + 0.4 * sin(_float_time * 3.0)

	# Deteksi player
	if _hero == null or not is_instance_valid(_hero):
		_hero = get_tree().get_first_node_in_group("player") as Node3D
	_near = false
	if _hero and _ready_to_collect and not _collected:
		var d := _hero.global_position - global_position
		d.y = 0.0
		_near = d.length() < interact_range

	_prompt.visible = _near and not GameState.ui_open and not _collected


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if not _near or GameState.ui_open or _collected or not _ready_to_collect:
		return
	get_viewport().set_input_as_handled()
	_collect()


func _collect() -> void:
	_collected = true
	_prompt.visible = false
	GameState.add_item(item_id, 1)
	GameState.set_flag(&"rune_key_taken", true)

	var txt := "Kunci Peti Kuno didapatkan!"
	QuestManager._show_toast("HADIAH", "Kunci Rune", txt)

	# Efek burst saat diambil: membesar + terbang ke atas + memudar
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_sprite, "scale", Vector3.ONE * 2.5, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sprite, "position:y", _sprite.position.y + 1.0, 0.3)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sprite, "modulate:a", 0.0, 0.3)
	tw.tween_property(_light, "light_energy", 8.0, 0.2)
	await tw.finished

	queue_free()
