# player.gd
extends CharacterBody3D

signal died
signal pause_requested

const SPEED := 3.0
const RUN_SPEED := 6.0
const DASH_SPEED := 15.0
const DASH_DURATION := 0.2
const DASH_COOLDOWN := 0.6
const ATTACK_COOLDOWN := 0.5
const ATTACK_RANGE := 1.3
const ATTACK_HIT_DELAY := 0.15
const JUMP_VELOCITY := 7.0
const GRAVITY := 20.0
const MAX_FALL_SPEED := 30.0
const INVULN_TIME := 0.6

# Tabel loop animasi (kunci = awalan nama animasi)
const ANIM_LOOP := {
	"idle": true,
	"walking": true,
	"running": true,
	"attack": false,
	"dash": false,
	"jump": false,
	"death": false,
}

const DAMAGE_NUMBER_SCENE = preload("res://scenes/DamageNumber.tscn")

@onready var sprite: AnimatedSprite3D = $Sprite
@onready var shadow_sprite: AnimatedSprite3D = $ShadowSprite

var invuln_timer := 0.0

var facing_local := Vector2(0, 1)   # arah hadap relatif layar (0,1 = menghadap kamera / "down")

var is_dashing := false
var is_attacking := false
var anim_lock := false      # true selama animasi attack belum selesai
var is_dead := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var attack_cooldown_timer := 0.0
var dash_direction := Vector3.ZERO
var attack_direction := Vector3.FORWARD
var action_dir_name := ""   # arah animasi yang dikunci saat attack/dash/death
var _just_captured := false # klik pertama untuk menangkap mouse tidak boleh jadi attack

# --- VARIABEL BARU UNTUK STUN ---
var is_stunned := false
var stun_timer := 0.0

func _ready() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_snap_length = 0.5
	add_to_group("player")
	
	# Inisialisasi HP dari GameState
	GameState.hp_current = GameState.hp_max
	GameState.hp_changed.emit(GameState.hp_current, GameState.hp_max)
	
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.animation_finished.connect(_on_animation_finished)
	shadow_sprite.sprite_frames = sprite.sprite_frames
	shadow_sprite.billboard = sprite.billboard

	# Atur loop dari tabel
	for anim in sprite.sprite_frames.get_animation_names():
		var key := String(anim).get_slice("_", 0)
		if ANIM_LOOP.has(key):
			sprite.sprite_frames.set_animation_loop(anim, ANIM_LOOP[key])

	# Awalnya menghadap ke arah kamera (animasi "down")
	_update_animation(Vector2.ZERO, false)


# ---------------- INPUT NON-GERAK ----------------
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pause_requested.emit()
		return

	if event.is_action_pressed("use_potion"):
		if not GameState.use_item(&"ramuan_taring"):
			GameState.use_item(&"ramuan_hijau")
		return
		
	# Klik saat kursor bebas = tangkap kursor lagi (wajib di versi web)
	if event is InputEventMouseButton and event.pressed \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_just_captured = true
		get_viewport().set_input_as_handled()


# ---------------- LOOP UTAMA ----------------
func _physics_process(delta: float) -> void:
	var skip_attack := _just_captured
	_just_captured = false

	_tick_timers(delta)
	_apply_gravity(delta)

	if is_dead:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
		
	# --- JIKA PLAYER TERSTUN ---
	if is_stunned:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		
		# Efek getar / kelap-kelip tanda stun
		sprite.modulate = Color(0.5, 0.5, 1.0) if int(stun_timer * 15.0) % 2 == 0 else Color.WHITE
		return # Hentikan semua kontrol di sini (gak bisa gerak/loncat/nyerang)
	
	if GameState.ui_open:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_update_animation(Vector2.ZERO, false)
		return
		
	# --- MULAI DASH (klik kanan / Q + arah WASD) ---
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 \
			and not anim_lock and not is_dashing:
		var input_dash := Input.get_vector("left", "right", "up", "down")
		if input_dash != Vector2.ZERO:
			_start_dash(input_dash)

	# --- MULAI ATTACK (klik kiri / J) ---
	if Input.is_action_just_pressed("attack") and not skip_attack \
			and attack_cooldown_timer <= 0.0 and not anim_lock and not is_dashing \
			and is_on_floor() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
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
		return

	# --- SELAMA ATTACK: diam ---
	if anim_lock:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# --- JUMP ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- GERAK ---
	var input := Input.get_vector("left", "right", "up", "down")
	var dir := _screen_to_world(input)
	var is_running := Input.is_action_pressed("sprint") and input != Vector2.ZERO
	var current_speed := RUN_SPEED if is_running else SPEED

	if input.length() > 0.1:
		facing_local = input.normalized()

	velocity.x = dir.x * current_speed
	velocity.z = dir.z * current_speed

	move_and_slide()
	_update_animation(input, is_running)


func _tick_timers(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	# Timer Stun
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
			sprite.modulate = Color.WHITE # Balikin warna normal
			print("Player bangun dari stun!")

	# Kebal + kedip setelah kena damage
	if invuln_timer > 0.0:
		invuln_timer -= delta
		sprite.modulate.a = 0.45 if int(invuln_timer * 20.0) % 2 == 0 else 1.0
	elif sprite.modulate.a != 1.0 and not is_stunned:
		sprite.modulate.a = 1.0

func get_dash_ratio() -> float:
	if is_dashing:
		return 1.0
	return clampf(dash_cooldown_timer / DASH_COOLDOWN, 0.0, 1.0)
	
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = maxf(velocity.y - GRAVITY * delta, -MAX_FALL_SPEED)
	elif velocity.y < 0.0:
		velocity.y = 0.0


# ---------------- FUNGSI STUN DARI BOSS ----------------
func stun(duration: float) -> void:
	if is_dead or is_stunned: return
	
	is_stunned = true
	stun_timer = duration
	is_dashing = false
	anim_lock = false
	print("PLAYER TERSTUN!")
	_update_animation(Vector2.ZERO, false)


# ---------------- KAMERA ----------------
func _cam_axes() -> Array:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return [Vector3.RIGHT, Vector3.FORWARD]
	var forward := -cam.global_transform.basis.z
	forward.y = 0.0
	var right := cam.global_transform.basis.x
	right.y = 0.0
	return [right.normalized(), forward.normalized()]


func _screen_to_world(input: Vector2) -> Vector3:
	var axes := _cam_axes()
	return axes[0] * input.x + axes[1] * -input.y


func _dir_name() -> String:
	if absf(facing_local.x) > absf(facing_local.y):
		return "right" if facing_local.x > 0.0 else "left"
	return "down" if facing_local.y > 0.0 else "up"

# ---------------- DASH ----------------
func _start_dash(input_dir: Vector2) -> void:
	dash_direction = _screen_to_world(input_dir).normalized()
	facing_local = input_dir.normalized()
	is_dashing = true
	dash_timer = DASH_DURATION
	action_dir_name = _dir_name()

	var anim := "dash_" + action_dir_name
	if not sprite.sprite_frames.has_animation(anim):
		push_warning("Animasi '%s' tidak ada di SpriteFrames" % anim)
		return

	var frames := sprite.sprite_frames.get_frame_count(anim)
	var fps := sprite.sprite_frames.get_animation_speed(anim)
	var natural_len := frames / maxf(fps, 0.01)
	sprite.play(anim, natural_len / DASH_DURATION)


# ---------------- ATTACK ----------------
func _start_attack() -> void:
	action_dir_name = _dir_name()
	var anim := "attack_" + action_dir_name
	if not sprite.sprite_frames.has_animation(anim):
		push_warning("Animasi '%s' tidak ada di SpriteFrames" % anim)
		return
	is_attacking = true
	anim_lock = true
	attack_cooldown_timer = ATTACK_COOLDOWN
	attack_direction = _screen_to_world(facing_local).normalized()
	sprite.no_depth_test = true
	sprite.play(anim)
	get_tree().create_timer(ATTACK_HIT_DELAY).timeout.connect(_do_hit)


# --- LOGIKA HIT (DAMAGE, GETAR, HIT STOP) ---
func _do_hit() -> void:
	if is_dead:
		return
		
	var hit_something := false
	
	for e in get_tree().get_nodes_in_group("enemy"):
		if not (e is Node3D):
			continue
		var to: Vector3 = e.global_position - global_position
		to.y = 0.0
		var dist := to.length()
		
		if dist <= ATTACK_RANGE and (dist < 0.01 or to.normalized().dot(attack_direction) > 0.3):
			if e.has_method("take_damage"):
				e.take_damage(GameState.damage)
				_spawn_damage_number(e, GameState.damage)
				hit_something = true
				
	# --- EFEK NGE-HIT MUSUH ---
	# --- EFEK NGE-HIT MUSUH ---
	if hit_something:
		# 1. Getar Kamera (Tajam & Cepat)
		var cam = get_viewport().get_camera_3d()
		if cam and cam.has_method("shake"):
			cam.shake(0.06, 0.15, 80.0) 
			


func _spawn_damage_number(enemy_node: Node3D, damage_amount: int) -> void:
	var dmg_num = DAMAGE_NUMBER_SCENE.instantiate()
	dmg_num.text = str(damage_amount)
	
	enemy_node.add_child(dmg_num)
	
	var enemy_height := 1.0
	for child in enemy_node.get_children():
		if child is MeshInstance3D:
			enemy_height = child.get_aabb().size.y
			break
			
	var random_side := 1.0 if randf() > 0.5 else -1.0
	var pos_x = (enemy_height * 0.2) * random_side
	var pos_y = (enemy_height * 0.2) - (enemy_height * 0.5)
	
	dmg_num.position = Vector3(pos_x, pos_y, 0)
	
	var enemy_scale := enemy_node.global_transform.basis.get_scale()
	dmg_num.scale = Vector3.ONE / enemy_scale


# ---------------- HP & DEATH ----------------
func take_damage(amount: int) -> void:
	if is_dead or invuln_timer > 0.0:
		return
		
	invuln_timer = INVULN_TIME
	
	GameState.take_damage(amount)
	
	# --- EFEK KENA HIT MUSUH ---
	# Getar Kamera (Lebih parah, agak lambat, goyang kasar)
	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("shake"):
		cam.shake(0.2, 0.3, 40.0) # (Kekuatan, Durasi, Kecepatan)
	
	if GameState.hp_current <= 0:
		_die()


func _die() -> void:
	is_dead = true
	is_dashing = false
	is_attacking = false
	anim_lock = false
	velocity.x = 0.0
	velocity.z = 0.0
	sprite.modulate.a = 1.0
	sprite.no_depth_test = false
	action_dir_name = _dir_name()
	var anim := "death_" + action_dir_name
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	died.emit()


# ---------------- ANIMASI ----------------
func _update_animation(input: Vector2, is_running: bool) -> void:
	var dir_name := _dir_name()

	if not is_on_floor():
		var air := "jump_" + dir_name
		if not sprite.sprite_frames.has_animation(air):
			return
		if velocity.y > 0.0:
			_play(air, false)
		elif sprite.animation != air or sprite.is_playing():
			sprite.play(air)
			sprite.frame = sprite.sprite_frames.get_frame_count(air) - 1
			sprite.pause()
		return

	var action := "idle_"
	if input != Vector2.ZERO:
		action = "running_" if is_running else "walking_"
	_play(action + dir_name)


func _play(anim: String, restart_if_stopped := true) -> void:
	if not sprite.sprite_frames.has_animation(anim):
		return
	var old := String(sprite.animation)
	if old == anim:
		if restart_if_stopped and not sprite.is_playing():
			sprite.play(anim)
		return

	var f := sprite.frame
	var p := sprite.frame_progress
	var same_kind := old.get_slice("_", 0) == anim.get_slice("_", 0) \
			and sprite.sprite_frames.has_animation(old) \
			and sprite.sprite_frames.get_frame_count(old) == sprite.sprite_frames.get_frame_count(anim)
	sprite.play(anim)
	if same_kind:
		sprite.set_frame_and_progress(f, p)


func _on_animation_finished() -> void:
	if String(sprite.animation).begins_with("attack_"):
		anim_lock = false
		is_attacking = false
		sprite.no_depth_test = false

func _process(_delta: float) -> void:
	if shadow_sprite.animation != sprite.animation:
		shadow_sprite.animation = sprite.animation
	shadow_sprite.frame = sprite.frame
	shadow_sprite.offset = sprite.offset
	shadow_sprite.flip_h = sprite.flip_h
