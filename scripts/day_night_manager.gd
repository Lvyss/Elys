extends Node

@export var sun: DirectionalLight3D
@export var world_env: WorldEnvironment

@export_group("Character Fill")
@export var fill_energy := 0.7                      
@export var fill_color := Color(0.407, 0.387, 0.364, 1.0)    

const CHAR_LAYER := 2          

var base_time := 0.72
var swing_speed := 0.05
var swing_amount := 0.02
var current_time := 0.0

var fill_light: DirectionalLight3D

# Variabel Animasi Kabut
var fog_time := 0.0
var base_fog_density := 0.005 # <--- Diturunin biar tipis di deket

func _ready():
	_setup_environment()
	_setup_character_fill()
	current_time = base_time
	_update_sun(current_time)


func _process(delta):
	var offset = sin(Time.get_ticks_msec() / 1000.0 * swing_speed) * swing_amount
	current_time = base_time + offset
	_update_sun(current_time)
	_update_fill()
	_animate_fog(delta)


func _update_sun(t: float):
	if not sun:
		return
	sun.rotation_degrees.x = lerp(-55.0, -60.0, t)
	sun.rotation_degrees.y = lerp(45.0, 60.0, t)


# ---------------- ANIMASI KABUT ----------------
func _animate_fog(delta: float):
	if not world_env or not world_env.environment:
		return
		
	var env = world_env.environment
	fog_time += delta * 0.4 # Gerakan lebih lambat biar natural
	
	# Kabut bergerak naik turun (menebal & menipis) tapi gak ekstrim
	var wave = sin(fog_time) * 0.01
	env.volumetric_fog_density = base_fog_density + wave


# ---------------- CHARACTER FILL ----------------
func _setup_character_fill() -> void:
	if sun:
		sun.light_cull_mask = 0xFFFFF

	fill_light = DirectionalLight3D.new()
	fill_light.name = "CharacterFill"
	fill_light.light_energy = fill_energy
	fill_light.light_color = fill_color
	fill_light.shadow_enabled = false
	fill_light.light_cull_mask = 1 << (CHAR_LAYER - 1)
	add_child(fill_light)

	get_tree().node_added.connect(_on_node_added)
	_tag_existing.call_deferred()


func _tag_existing() -> void:
	for n in get_tree().root.find_children("*", "AnimatedSprite3D", true, false):
		_tag(n)


func _on_node_added(n: Node) -> void:
	if n is AnimatedSprite3D:
		_tag(n)


func _tag(n: Node) -> void:
	(n as VisualInstance3D).layers |= (1 << (CHAR_LAYER - 1))


func _update_fill() -> void:
	if fill_light == null:
		return
	var cam := get_viewport().get_camera_3d()
	if cam:
		fill_light.global_transform.basis = cam.global_transform.basis
	fill_light.light_energy = fill_energy


# ---------------- LINGKUNGAN ----------------
func _setup_environment():
	if not sun or not world_env:
		return

	var env = world_env.environment

	sun.light_color = Color(0.636, 0.511, 0.388, 1.0)
	sun.light_energy = 1.5

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.15, 0.18, 0.3)
	env.ambient_light_energy = 0.25

	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.05, 0.1)
	env.background_energy_multiplier = 0.3

	# --- VOLUMETRIC FOG (Kabut Depan Tipis) ---
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = base_fog_density
	env.volumetric_fog_albedo = Color(0.6, 0.6, 0.7)
	env.volumetric_fog_emission = Color(0.0, 0.0, 0.0)
	
	# --- DEPTH FOG (Kabut Jarak Jauh Tipis) ---
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	env.fog_light_color = Color(0.4, 0.4, 0.5) 
	env.fog_light_energy = 0.8
	env.fog_density = 0.05 # <--- DITURUNIN DARI 0.15 KE 0.06 (Lebih transparan)
	env.fog_height = 0.5 
	env.fog_height_density = 1.0 # <--- Diturunin biar gak terlalu numpuk di tanah

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.8
	env.glow_enabled = true
	env.glow_intensity = 0.3

	sun.shadow_enabled = true
	sun.shadow_blur = 2.0
	sun.shadow_opacity = 0.5
