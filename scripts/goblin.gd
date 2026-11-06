extends CharacterBody3D

@export var wander_speed := 1.5
@export var chase_speed := 3.0
@export var wander_radius := 3.0
@export var detect_range := 8.0
@export var lose_range := 11.0
@export var attack_range := 1.2
@export var attack_damage := 10
@export var attack_cooldown := 1.0
@export var windup_time := 0.4      # kedip merah sebelum mengayun
@export var attack_total := 0.8     # durasi seluruh serangan
@export var max_hp := 40

const GRAVITY := 20.0
const ARRIVE_DISTANCE := 0.15
const MAX_WALK_TIME := 4.0

# Offset per aksi (piksel). Yang tidak ditulis = (0, 0)
const ACTION_OFFSETS := {
	"idle": Vector2(0, 0),
	"walk": Vector2(0, 0),
	"attack": Vector2(0, 0),
	"death": Vector2(0, 0),
}

enum State { IDLE, WANDER, CHASE, ATTACK, DEAD }

@onready var sprite: AnimatedSprite3D = $Sprite

var state := State.IDLE
var hp := 0
var home := Vector3.ZERO
var target := Vector3.ZERO
var facing := "south"
var state_time := 0.0        # waktu di state saat ini
var idle_duration := 1.0
var walk_time := 0.0
var attack_cd := 0.0
var hit_done := false
var player: Node3D = null


func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	home = global_position
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

	# Animasi serangan dan mati tidak boleh loop
	for anim in sprite.sprite_frames.get_animation_names():
		if anim.begins_with("attack_") or anim.begins_with("death_"):
			sprite.sprite_frames.set_animation_loop(anim, false)

	_enter_idle()


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	# gravitasi
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	if attack_cd > 0.0:
		attack_cd -= delta
	state_time += delta

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D

	var dist_to_player := INF
	if player:
		var d := player.global_position - global_position
		d.y = 0.0
		dist_to_player = d.length()

	match state:
		State.IDLE:
			_move(Vector3.ZERO)
			if _can_chase(dist_to_player):
				_enter_chase()
			elif state_time >= idle_duration:
				_enter_wander()
		State.WANDER:
			var to_t := target - global_position
			to_t.y = 0.0
			walk_time += delta
			if _can_chase(dist_to_player):
				_enter_chase()
			elif to_t.length() < ARRIVE_DISTANCE or walk_time > MAX_WALK_TIME:
				_enter_idle()
			else:
				var dir := to_t.normalized()
				_set_facing(dir)
				_move(dir * wander_speed)
				_play("walk_" + facing)
		State.CHASE:
			if dist_to_player > lose_range:
				_enter_idle()
			elif dist_to_player <= attack_range and attack_cd <= 0.0:
				_enter_attack()
			elif dist_to_player <= attack_range:
				_move(Vector3.ZERO)       # tunggu cooldown, jangan menempel
				_play_idle()
			else:
				var dir := player.global_position - global_position
				dir.y = 0.0
				dir = dir.normalized()
				_set_facing(dir)
				_move(dir * chase_speed)
				_play("walk_" + facing)
		State.ATTACK:
			_move(Vector3.ZERO)
			if not hit_done and state_time >= windup_time:
				hit_done = true
				_do_attack_hit(dist_to_player)
			if state_time >= attack_total:
				attack_cd = attack_cooldown
				_enter_chase()


# ---------------- STATE ----------------
func _enter_idle() -> void:
	state = State.IDLE
	state_time = 0.0
	idle_duration = randf_range(1.0, 3.0)
	_play_idle()


func _enter_wander() -> void:
	var angle := randf() * TAU
	var dist := randf_range(1.0, wander_radius)
	target = home + Vector3(cos(angle), 0.0, sin(angle)) * dist
	walk_time = 0.0
	state = State.WANDER
	state_time = 0.0


func _enter_chase() -> void:
	state = State.CHASE
	state_time = 0.0


func _enter_attack() -> void:
	state = State.ATTACK
	state_time = 0.0
	hit_done = false
	# hadap pemain
	var d := player.global_position - global_position
	d.y = 0.0
	_set_facing(d.normalized())
	_play("attack_" + facing, true)
	# kedip merah sebagai peringatan
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.35, 0.35), windup_time * 0.5)
	tw.tween_property(sprite, "modulate", Color.WHITE, windup_time * 0.5)


func _can_chase(dist: float) -> bool:
	return player != null and dist <= detect_range


# ---------------- SERANGAN ----------------
func _do_attack_hit(dist: float) -> void:
	if player == null:
		return
	if dist <= attack_range + 0.3:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
		else:
			print("Goblin kena hero (hero belum punya take_damage)")


func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	hp -= amount
	print(name, " HP: ", hp, "/", max_hp)
	# kedip merah singkat
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	if hp <= 0:
		_die()


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


# Arah dunia -> arah layar (east/west/north/south) mengikuti kamera
func _set_facing(dir_world: Vector3) -> void:
	if dir_world.length() < 0.05:
		return
	var cam := get_viewport().get_camera_3d()
	var sx := dir_world.x
	var sy := -dir_world.z   # tanpa kamera: -Z = atas layar
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
		facing = "east" if sx > 0.0 else "west"
	else:
		facing = "north" if sy > 0.0 else "south"


func _play_idle() -> void:
	var idle_name := "idle_" + facing
	if sprite.sprite_frames.has_animation(idle_name):
		_play(idle_name)
		return
	# tidak ada animasi idle: berhenti di frame pertama animasi walk
	var walk_name := "walk_" + facing
	if sprite.sprite_frames.has_animation(walk_name):
		if sprite.animation != walk_name:
			sprite.animation = walk_name
		sprite.stop()
		sprite.frame = 0
		_apply_offset(walk_name)


func _play(anim: String, restart := false) -> void:
	if not sprite.sprite_frames.has_animation(anim):
		print("[GOBLIN ERROR] Animasi '", anim, "' NGGAK ADA di SpriteFrames!")
		return
	if restart or sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
	_apply_offset(anim)


func _apply_offset(anim: String) -> void:
	var action := anim.get_slice("_", 0)
	sprite.offset = ACTION_OFFSETS.get(action, Vector2.ZERO)
