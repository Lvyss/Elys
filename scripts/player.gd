
extends CharacterBody3D

const SPEED := 4.5
const GRAVITY := 20.0
const JUMP_VELOCITY := 7.0

@onready var sprite: AnimatedSprite3D = $Sprite

var facing := "south"

# Running
var last_tap_time: Dictionary = {}
var running_action := ""

# Kill
var is_killing := false


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(_delta: float) -> void:

	# KILL menggunakan tombol Enter
	if Input.is_action_just_pressed("kill") and not is_killing:
		_play_kill()

	# Hentikan gerakan selama animasi kill
	if is_killing:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Jump menggunakan tombol Space
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Deteksi double tap WASD
	_check_double_tap()

	var input := Input.get_vector("left", "right", "up", "down")

	# Arah gerak mengikuti kamera
	var cam := get_viewport().get_camera_3d()
	var dir := Vector3.ZERO

	if cam:
		var forward := -cam.global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()

		var right := cam.global_transform.basis.x
		right.y = 0.0
		right = right.normalized()

		dir = right * input.x + forward * -input.y
	else:
		dir = Vector3(input.x, 0.0, input.y)

<<<<<<<<< Temporary merge branch 1
	# Tentukan running
	var is_running := (
		running_action != ""
		and Input.is_action_pressed(running_action)
		and input != Vector2.ZERO
	)

	# Kecepatan player
	var current_speed := RUN_SPEED if is_running else SPEED

	velocity.x = dir.x * current_speed
	velocity.z = dir.z * current_speed
=========
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
>>>>>>>>> Temporary merge branch 2

	move_and_slide()

	_update_animation(input, is_running)


func _check_double_tap() -> void:
	var actions := ["left", "right", "up", "down"]

	for action in actions:
		if Input.is_action_just_pressed(action):
			var current_time := Time.get_ticks_msec()
			var previous_time: int = last_tap_time.get(action, -10000)

			if current_time - previous_time <= DOUBLE_TAP_TIME:
				running_action = action
			else:
				running_action = ""

			last_tap_time[action] = current_time

	# Running berhenti ketika tombol dilepaskan
	if running_action != "" and not Input.is_action_pressed(running_action):
		running_action = ""


func _update_animation(input: Vector2, is_running: bool) -> void:
	var moving := input != Vector2.ZERO

	# Menentukan arah karakter
	if moving:
		if absf(input.x) > absf(input.y):
			facing = "east" if input.x > 0.0 else "west"
		else:
			facing = "south" if input.y > 0.0 else "north"

	# Menentukan animasi
	var action := "idle_"

	if moving:
		action = "running_" if is_running else "walking_"

	var animation_name := action + facing

	if sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)
		elif not sprite.is_playing():
			sprite.play(animation_name)


func _play_kill() -> void:
	var animation_name := "kill_" + facing

	if sprite.sprite_frames.has_animation(animation_name):
		is_killing = true
		running_action = ""

		# Percepat animasi kill
		sprite.speed_scale = KILL_SPEED_SCALE

		# Mainkan kill dari awal
		sprite.play(animation_name)
	else:
		push_warning("Animasi tidak ditemukan: " + animation_name)


func _on_animation_finished() -> void:
	if is_killing:
		is_killing = false

		# Kembalikan kecepatan animasi normal
		sprite.speed_scale = 1.0

		# Kembali ke idle sesuai arah terakhir
		var idle_animation := "idle_" + facing

		if sprite.sprite_frames.has_animation(idle_animation):
			sprite.play(idle_animation)
