extends CharacterBody3D

const SPEED := 3.0
const RUN_SPEED := 5.5
const JUMP_VELOCITY := 7.0
const DASH_SPEED := 10.0
const DASH_DURATION := 0.18
const KILL_SPEED_SCALE := 7.0

@onready var sprite: AnimatedSprite3D = $Sprite

var facing := "south"
var is_killing := false
var is_dashing := false
var dash_timer := 0.0
var dash_direction := Vector3.ZERO


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if is_killing:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Klik kanan: kill
	if Input.is_action_just_pressed("kill"):
		_play_kill()

		if is_killing:
			velocity.x = 0.0
			velocity.z = 0.0
			move_and_slide()
			return

	# Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Space: lompat
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Baca input WASD
	var input := Input.get_vector("left", "right", "up", "down")
	var direction := _get_camera_relative_direction(input)

	_update_facing(input)

	# Klik kiri: dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		_start_dash(direction)

	# Gerakan dash atau jalan/lari
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED

		if dash_timer <= 0.0:
			is_dashing = false
	else:
		var is_running := Input.is_key_pressed(KEY_SHIFT) and input != Vector2.ZERO
		var current_speed := RUN_SPEED if is_running else SPEED

		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	move_and_slide()
	_update_animation(input)


func _get_camera_relative_direction(input: Vector2) -> Vector3:
	var camera := get_viewport().get_camera_3d()

	if camera == null:
		return Vector3(input.x, 0.0, input.y).normalized()

	var forward := -camera.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := camera.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()

	return (right * input.x + forward * -input.y).normalized()


func _update_facing(input: Vector2) -> void:
	if input == Vector2.ZERO:
		return

	if absf(input.x) > absf(input.y):
		facing = "east" if input.x > 0.0 else "west"
	else:
		facing = "south" if input.y > 0.0 else "north"


func _start_dash(direction: Vector3) -> void:
	if direction == Vector3.ZERO:
		match facing:
			"north":
				dash_direction = Vector3(0.0, 0.0, -1.0)
			"south":
				dash_direction = Vector3(0.0, 0.0, 1.0)
			"east":
				dash_direction = Vector3(1.0, 0.0, 0.0)
			"west":
				dash_direction = Vector3(-1.0, 0.0, 0.0)
	else:
		dash_direction = direction

	is_dashing = true
	dash_timer = DASH_DURATION


func _update_animation(input: Vector2) -> void:
	var animation_prefix := "idle_"

	if is_dashing:
		animation_prefix = "dash_"
	elif not is_on_floor():
		animation_prefix = "jump_"
	elif input != Vector2.ZERO:
		if Input.is_key_pressed(KEY_SHIFT):
			animation_prefix = "running_"
		else:
			animation_prefix = "walking_"

	var animation_name := animation_prefix + facing

	if sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)
		elif not sprite.is_playing():
			sprite.play(animation_name)


func _play_kill() -> void:
	var animation_name := "kill_" + facing

	if sprite.sprite_frames.has_animation(animation_name):
		is_killing = true
		is_dashing = false
		sprite.speed_scale = KILL_SPEED_SCALE
		sprite.play(animation_name)
	else:
		push_warning("Animasi tidak ditemukan: " + animation_name)


func _on_animation_finished() -> void:
	if is_killing:
		is_killing = false
		sprite.speed_scale = 1.0

		var idle_animation := "idle_" + facing
		if sprite.sprite_frames.has_animation(idle_animation):
			sprite.play(idle_animation)
