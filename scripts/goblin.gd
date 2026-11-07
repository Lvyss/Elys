extends CharacterBody3D

enum State { IDLE, WANDER, CHASE, ATTACK, HURT, DEAD }
enum AttackKind { STAND, WALK, LUNGE }

@export var stats: GoblinStats

const GRAVITY := 20.0
const ARRIVE_DISTANCE := 0.15
const MAX_WALK_TIME := 4.0
const WANDER_RADIUS := 3.0
const HURT_TIME := 0.35
const NON_LOOP := ["attack", "walk_attack", "run_attack", "hurt", "death"]

# Offset per aksi (piksel). Isi dengan angka lamamu kalau ada.
const ACTION_OFFSETS := {
	"idle": Vector2(0, 0),
	"walk": Vector2(0, 0),
	"run": Vector2(0, 0),
	"attack": Vector2(0, 0),
	"walk_attack": Vector2(0, 0),
	"run_attack": Vector2(0, 0),
	"hurt": Vector2(0, 0),
	"death": Vector2(0, 0),
}

@onready var sprite: AnimatedSprite3D = $Sprite
@onready var col: CollisionShape3D = $CollisionShape3D

var state := State.IDLE
var attack_kind := AttackKind.STAND
var hp := 0
var home := Vector3.ZERO
var target := Vector3.ZERO
var facing := "down"            # down / left / up / right
var state_time := 0.0
var idle_duration := 1.0
var walk_time := 0.0
var attack_cd := 0.0
var hit_done := false
var attack_dir := Vector3.ZERO
var player: Node3D = null


func _ready() -> void:
	if stats == null:
		stats = GoblinStats.new()
	add_to_group("enemy")
	hp = stats.max_hp
	home = global_position
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

	if stats.sprite_frames:
		sprite.sprite_frames = stats.sprite_frames

	# Ukuran (boss lebih besar). Posisi Y ikut dikali supaya kaki tetap di tanah.
	var s := stats.size_scale
	sprite.scale = Vector3.ONE * s
	sprite.position.y *= s
	col.scale = Vector3.ONE * s
	col.position.y *= s
	sprite.modulate = stats.tint

	# Animasi non-loop
	for anim in sprite.sprite_frames.get_animation_names():
		if _action_of(anim) in NON_LOOP:
			sprite.sprite_frames.set_animation_loop(anim, false)

	_enter_idle()


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	
		# jatuh keluar peta -> balik ke titik awal
	if global_position.y < -3.0:
		global_position = home + Vector3(0, 0.5, 0)
		velocity = Vector3.ZERO
		
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	if attack_cd > 0.0:
		attack_cd -= delta
	state_time += delta

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D

	var dist := INF
	if player:
		var d := player.global_position - global_position
		d.y = 0.0
		dist = d.length()

	match state:
		State.IDLE:
			_move(Vector3.ZERO)
			if dist <= stats.detect_range:
				_enter_chase()
			elif state_time >= idle_duration:
				_enter_wander()

		State.WANDER:
			var to_t := target - global_position
			to_t.y = 0.0
			walk_time += delta
			if dist <= stats.detect_range:
				_enter_chase()
			elif to_t.length() < ARRIVE_DISTANCE or walk_time > MAX_WALK_TIME:
				_enter_idle()
			else:
				var dir := to_t.normalized()
				_set_facing(dir)
				_move(dir * stats.wander_speed)
				_play("walk_" + facing)

		State.CHASE:
			if dist > stats.lose_range:
				_enter_idle()
			elif attack_cd <= 0.0 and dist <= stats.attack_range * 3.0:
				_enter_attack(dist)
			elif dist <= stats.attack_range:
				_move(Vector3.ZERO)      # tunggu cooldown
				_face_player()
				_play("idle_" + facing)
			else:
				var dir := _dir_to_player()
				_set_facing(dir)
				_move(dir * stats.chase_speed)
				_play("run_" + facing)

		State.ATTACK:
			_process_attack(dist)

		State.HURT:
			_move(Vector3.ZERO)
			if state_time >= HURT_TIME:
				_enter_chase()


# ---------------- STATE ----------------
func _enter_idle() -> void:
	state = State.IDLE
	state_time = 0.0
	idle_duration = randf_range(1.0, 3.0)
	_play("idle_" + facing)


func _enter_wander() -> void:
	var angle := randf() * TAU
	var d := randf_range(1.0, WANDER_RADIUS)
	target = home + Vector3(cos(angle), 0.0, sin(angle)) * d
	walk_time = 0.0
	state = State.WANDER
	state_time = 0.0


func _enter_chase() -> void:
	state = State.CHASE
	state_time = 0.0


func _enter_attack(dist: float) -> void:
	state = State.ATTACK
	state_time = 0.0
	hit_done = false

	# Pilih jenis serangan berdasarkan jarak ke hero
	if dist <= stats.attack_range:
		attack_kind = AttackKind.STAND
	elif dist <= stats.attack_range * 1.7:
		attack_kind = AttackKind.WALK
	else:
		attack_kind = AttackKind.LUNGE

	attack_dir = _dir_to_player()
	_set_facing(attack_dir)

	match attack_kind:
		AttackKind.STAND: _play("attack_" + facing, true)
		AttackKind.WALK:  _play("walk_attack_" + facing, true)
		AttackKind.LUNGE: _play("run_attack_" + facing, true)

	# Kedip merah = peringatan sebelum mengayun
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.35, 0.35), stats.windup_time * 0.5)
	tw.tween_property(sprite, "modulate", stats.tint, stats.windup_time * 0.5)


func _process_attack(dist: float) -> void:
	match attack_kind:
		AttackKind.STAND:
			_move(Vector3.ZERO)
		AttackKind.WALK:
			_move(attack_dir * stats.chase_speed * 0.5)
		AttackKind.LUNGE:
			_move(attack_dir * stats.chase_speed * 1.8)

	if not hit_done and state_time >= stats.windup_time:
		hit_done = true
		_do_attack_hit(dist)

	if state_time >= stats.attack_total:
		attack_cd = stats.attack_cooldown
		_enter_chase()


func _do_attack_hit(dist: float) -> void:
	if player == null:
		return
	if dist <= stats.attack_range + 0.5:
		if player.has_method("take_damage"):
			player.take_damage(stats.damage)
		else:
			print(name, " kena hero (hero belum punya take_damage)")


# ---------------- DAMAGE ----------------
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	hp -= amount
	print(name, " HP: ", hp, "/", stats.max_hp)

	if hp <= 0:
		_die()
		return

	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tw.tween_property(sprite, "modulate", stats.tint, 0.15)

	if stats.can_stagger:
		state = State.HURT
		state_time = 0.0
		_play("hurt_" + facing, true)


func _die() -> void:
	state = State.DEAD
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	remove_from_group("enemy")
	var anim := "death_" + facing
	if sprite.sprite_frames.has_animation(anim):
		_play(anim, true)
		await sprite.animation_finished
	var tw := create_tween()
	tw.tween_property(sprite, "scale", Vector3.ZERO, 0.4)
	await tw.finished
	queue_free()


# ---------------- GERAK & ANIMASI ----------------
func _move(horizontal: Vector3) -> void:
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	move_and_slide()


func _dir_to_player() -> Vector3:
	if player == null:
		return Vector3.ZERO
	var d := player.global_position - global_position
	d.y = 0.0
	return d.normalized()


func _face_player() -> void:
	_set_facing(_dir_to_player())


# Arah dunia -> arah layar (down/left/up/right) mengikuti kamera
func _set_facing(dir_world: Vector3) -> void:
	if dir_world.length() < 0.05:
		return
	var sx := dir_world.x
	var sy := -dir_world.z
	var cam := get_viewport().get_camera_3d()
	if cam:
		var right := cam.global_transform.basis.x
		right.y = 0.0
		right = right.normalized()
		var fwd := -cam.global_transform.basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		sx = dir_world.dot(right)
		sy = dir_world.dot(fwd)
	if absf(sx) > absf(sy):
		facing = "right" if sx > 0.0 else "left"
	else:
		facing = "up" if sy > 0.0 else "down"


func _play(anim: String, restart := false) -> void:
	if not sprite.sprite_frames.has_animation(anim):
		print("[GOBLIN ERROR] Animasi '", anim, "' tidak ada di SpriteFrames!")
		return
	if restart or sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
	sprite.offset = ACTION_OFFSETS.get(_action_of(anim), Vector2.ZERO)


# "walk_attack_left" -> "walk_attack"
func _action_of(anim: String) -> String:
	var i := anim.rfind("_")
	return anim.substr(0, i) if i > 0 else anim
