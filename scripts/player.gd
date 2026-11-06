extends CharacterBody3D

const SPEED := 3.0
const RUN_SPEED := 6.0
const DASH_SPEED := 15.0
const DASH_DURATION := 0.2
const DASH_COOLDOWN := 0.6
const ATTACK_COOLDOWN := 0.5
const ATTACK_RANGE := 1.3
const ATTACK_DAMAGE := 10
const ATTACK_HIT_DELAY := 0.15
const JUMP_VELOCITY := 7.0
const GRAVITY := 20.0
const MAX_FALL_SPEED := 30.0

@onready var sprite: AnimatedSprite3D = $Sprite

var facing := "south"
var is_dashing := false
var is_attacking := false
var anim_lock := false  # true selama animasi attack belum selesai
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var attack_cooldown_timer := 0.0
var dash_direction := Vector3.ZERO
var is_dead := false
var current_debug_anim := ""


func _ready() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_snap_length = 0.5
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

	# Animasi aksi tidak boleh loop, supaya animation_finished terpanggil
	for anim in sprite.sprite_frames.get_animation_names():
		if anim.begins_with("dash_") or anim.begins_with("attack_") \
				or anim.begins_with("jump_") or anim.begins_with("fall_"):
			sprite.sprite_frames.set_animation_loop(anim, false)

	_update_animation(Vector2.ZERO, false)


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.x = 0.0
		velocity.z = 0.0
		_apply_gravity(delta)
		move_and_slide()
		return

	_apply_gravity(delta)

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	# --- KILL / DEATH (Enter) ---
	if Input.is_action_just_pressed("kill") and not is_dashing:
		_play_death()
		return

	# --- MULAI DASH (WASD + F) ---
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and not anim_lock and not is_dashing:
		var input_dash := Input.get_vector("left", "right", "up", "down")
		if input_dash != Vector2.ZERO:
			_start_dash(input_dash)
		else:
			print("[GAGAL DASH] Tekan WASD sambil F")

	# --- MULAI ATTACK (klik kiri) ---
	if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0.0 \
			and not anim_lock and not is_dashing and is_on_floor() \
			and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_start_attack()

	# --- SELAMA DASH ---
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED
		move_and_slide()
		if dash_timer <= 0.0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN
			current_debug_anim = ""   # paksa animasi berikutnya diputar ulang
			sprite.speed_scale = 1.0
		return

	# --- SELAMA ANIMASI ATTACK: diam ---
	if anim_lock:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# --- JUMP ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- INPUT GERAK ---
	var input := Input.get_vector("left", "right", "up", "down")
	var dir := _screen_to_world(input)

	var is_running := Input.is_action_pressed("sprint") and input != Vector2.ZERO
	var current_speed := RUN_SPEED if is_running else SPEED

	velocity.x = dir.x * current_speed
	velocity.z = dir.z * current_speed

	move_and_slide()
	_update_animation(input, is_running)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = maxf(velocity.y - GRAVITY * delta, -MAX_FALL_SPEED)
	elif velocity.y < 0.0:
		velocity.y = 0.0


# Ubah arah layar (input) jadi arah dunia mengikuti kamera
func _screen_to_world(input: Vector2) -> Vector3:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return Vector3(input.x, 0.0, input.y)
	var forward := -cam.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := cam.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	return right * input.x + forward * -input.y


# ---------------- DASH ----------------
func _start_dash(input_dir: Vector2) -> void:
	dash_direction = _screen_to_world(input_dir).normalized()
	is_dashing = true
	dash_timer = DASH_DURATION
	_update_facing(Vector3(input_dir.x, 0.0, input_dir.y))  # arah layar

	var anim := "dash_" + facing
	if sprite.sprite_frames.has_animation(anim):
		# hitung kecepatan putar supaya animasi selesai tepat di DASH_DURATION
		var frames := sprite.sprite_frames.get_frame_count(anim)
		var fps := sprite.sprite_frames.get_animation_speed(anim)
		var natural_len := frames / maxf(fps, 0.01)
		var play_scale := natural_len / DASH_DURATION

		current_debug_anim = anim
		sprite.stop()
		sprite.frame = 0
		sprite.play(anim, play_scale)  # custom_speed
		print("[OK] DASH: ", anim, " | speed x", snappedf(play_scale, 0.01))
	else:
		print("[ERROR] Animasi '", anim, "' NGGAK ADA di SpriteFrames!")


# ---------------- ATTACK ----------------
func _start_attack() -> void:
	var anim := "attack_" + facing
	if not sprite.sprite_frames.has_animation(anim):
		print("[ERROR] Animasi '", anim, "' NGGAK ADA di SpriteFrames!")
		return
	is_attacking = true
	anim_lock = true
	attack_cooldown_timer = ATTACK_COOLDOWN
	current_debug_anim = anim
	sprite.speed_scale = 1.0
	sprite.stop()
	sprite.play(anim)
	print("[OK] ATTACK: ", anim)
	get_tree().create_timer(ATTACK_HIT_DELAY).timeout.connect(_do_hit)


func _facing_vector() -> Vector3:
	match facing:
		"north": return _screen_to_world(Vector2(0, -1)).normalized()
		"south": return _screen_to_world(Vector2(0, 1)).normalized()
		"east": return _screen_to_world(Vector2(1, 0)).normalized()
		_: return _screen_to_world(Vector2(-1, 0)).normalized()


func _do_hit() -> void:
	if is_dead:
		return
	var fwd := _facing_vector()
	for e in get_tree().get_nodes_in_group("enemy"):
		if not (e is Node3D):
			continue
		var to: Vector3 = e.global_position - global_position
		to.y = 0.0
		var dist := to.length()
		if dist <= ATTACK_RANGE and (dist < 0.01 or to.normalized().dot(fwd) > 0.3):
			if e.has_method("take_damage"):
				e.take_damage(ATTACK_DAMAGE)
				print("HIT: ", e.name)


# ---------------- ANIMASI ----------------
func _update_facing(vec: Vector3) -> void:
	if vec.length() < 0.1:
		return
	if absf(vec.x) > absf(vec.z):
		facing = "east" if vec.x > 0.0 else "west"
	else:
		facing = "south" if vec.z > 0.0 else "north"


func _update_animation(input: Vector2, is_running: bool) -> void:
	var moving := input != Vector2.ZERO
	if moving:
		_update_facing(Vector3(input.x, 0.0, input.y))

	# Di udara: jump saat naik, fall saat turun
	if not is_on_floor():
		var air := "jump_" if velocity.y > 0.0 else "fall_"
		if not sprite.sprite_frames.has_animation(air + facing):
			air = "jump_"
		_play_animation(air + facing)
		return

	var action := "idle_"
	if moving:
		action = "running_" if is_running else "walking_"
	_play_animation(action + facing)


func _play_animation(animation_name: String) -> void:
	if current_debug_anim != animation_name:
		current_debug_anim = animation_name
		if not sprite.sprite_frames.has_animation(animation_name):
			print("[ERROR] Animasi '", animation_name, "' NGGAK ADA di SpriteFrames!")
		else:
			print("[OK] Play Animasi: ", animation_name)

	if sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)
		elif not sprite.is_playing():
			# animasi udara tidak boleh diulang, biarkan berhenti di frame terakhir
			var in_air := animation_name.begins_with("jump_") or animation_name.begins_with("fall_")
			if not in_air:
				sprite.play(animation_name)


func _play_death() -> void:
	var animation_name := "death_" + facing
	if sprite.sprite_frames.has_animation(animation_name):
		is_dead = true
		velocity.x = 0.0
		velocity.z = 0.0
		sprite.speed_scale = 1.0
		sprite.play(animation_name)
		print("PLAY DEATH: ", animation_name)


func _on_animation_finished() -> void:
	var a := String(sprite.animation)
	if a.begins_with("attack_"):
		anim_lock = false
		is_attacking = false
		current_debug_anim = ""
		return
	if is_dead:
		sprite.stop()
