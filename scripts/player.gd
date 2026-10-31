extends CharacterBody3D

const SPEED := 4.5
const GRAVITY := 20.0
const JUMP_VELOCITY := 7.0

@onready var sprite: AnimatedSprite3D = $Sprite

var facing := "down"   # "down", "up", atau "side"

func _physics_process(delta: float) -> void:
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

	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()

	_update_animation(input)

func _update_animation(input: Vector2) -> void:
	var moving := input != Vector2.ZERO

	if moving:
		if absf(input.x) > absf(input.y):
			facing = "side"
			# Aset menghadap KANAN: flip kalau jalan ke kiri
			sprite.flip_h = input.x < 0.0
		else:
			facing = "down" if input.y > 0.0 else "up"

	var action := "walk_" if moving else "idle_"
	sprite.play(action + facing)
