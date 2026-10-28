extends Camera3D

@export var follow_speed := 10.0
@export var mouse_sensitivity := 0.003
@export var min_pitch_deg := -35.0   # negatif = kamera di bawah hero, mendongak ke atas
@export var max_pitch_deg := 70.0    # paling tinggi (hampir dari atas)
@export var min_distance := 4.0
@export var max_distance := 16.0
@export var zoom_step := 0.8
@export var look_height := 1.0       # titik yang dilihat (setinggi dada hero)
@export var ground_height := 0.0     # tinggi tanah
@export var min_cam_height := 0.4    # kamera tidak boleh lebih rendah dari ini
@export var close_distance := 1.5    # jarak minimum kalau sangat mendongak

var target: Node3D
var yaw := 0.0
var pitch := 0.0
var distance := 10.0          # jarak yang diinginkan (diatur scroll)
var current_distance := 10.0  # jarak sebenarnya setelah dibatasi tanah
var focus := Vector3.ZERO

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player") as Node3D
	if target == null:
		return
	focus = target.global_position + Vector3(0, look_height, 0)
	# Baca sudut awal dari posisi kamera di editor
	var offset := global_position - focus
	distance = offset.length()
	current_distance = distance
	yaw = atan2(offset.x, offset.z)
	pitch = asin(offset.y / distance)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch += event.relative.y * mouse_sensitivity
		pitch = clampf(pitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(distance - zoom_step, min_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(distance + zoom_step, max_distance)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().quit()

func _process(delta: float) -> void:
	if target == null:
		return
	var goal := target.global_position + Vector3(0, look_height, 0)
	focus = focus.lerp(goal, 1.0 - exp(-follow_speed * delta))

	# Batasi jarak supaya kamera tidak tembus tanah
	var allowed := distance
	var s := sin(pitch)
	if s < 0.0:
		var room := focus.y - (ground_height + min_cam_height)
		allowed = minf(distance, maxf(room / -s, close_distance))

	# Halus: jarak mendekat atau menjauh tidak loncat
	current_distance = lerpf(current_distance, allowed, 1.0 - exp(-12.0 * delta))

	var offset := Vector3(
		current_distance * cos(pitch) * sin(yaw),
		current_distance * sin(pitch),
		current_distance * cos(pitch) * cos(yaw))
	global_position = focus + offset
	global_rotation = Vector3(-pitch, yaw, 0.0)
