
extends CharacterBody3D

enum State { IDLE, WANDER, CHASE, ATTACK, HURT, DEAD, DASH, RETREAT, BOSS_SLAM }
enum AttackKind { STAND, WALK, LUNGE }

signal died(goblin)

@export var stats: GoblinStats

const STAGGER_COOLDOWN := 1.5
var stagger_cd := 0.0

const GRAVITY := 20.0
const ARRIVE_DISTANCE := 0.15
const MAX_WALK_TIME := 4.0
const WANDER_RADIUS := 3.0
const SAFE_CENTER := Vector3(4.5, 0.0, -5.5)
const SAFE_RADIUS := 4.5
const HURT_TIME := 0.35
const NON_LOOP := ["attack", "walk_attack", "run_attack", "hurt", "death", "dash", "slam"]

# --- MEKANIK KHUSUS ELIT ---
const ELIT_DASH_SPEED := 12.0
const ELIT_DASH_RANGE := 5.0
const ELIT_DASH_DURATION := 0.2
const ELIT_DASH_CD := 2.5
const ELIT_SAFE_DISTANCE := 4.5

# --- MEKANIK KHUSUS BOSS (RAJA) ---
const BOSS_SLAM_RANGE := 4.0
const BOSS_SLAM_CD := 5.0
const BOSS_CAST_TIME := 0.8
const BOSS_SLAM_RADIUS := 4.0

const ACTION_OFFSETS := {
	"idle": Vector2(0, 0),
	"walk": Vector2(0, 0),
	"run": Vector2(0, 0),
	"attack": Vector2(0, 0),
	"walk_attack": Vector2(0, 0),
	"run_attack": Vector2(0, 0),
	"hurt": Vector2(0, 0),
	"death": Vector2(0, 0),
	"dash": Vector2(0, 0),
	"slam": Vector2(0, 0),
}

@onready var sprite: AnimatedSprite3D = $Sprite
@onready var col: CollisionShape3D = $CollisionShape3D

# --- AUDIO ---
@onready var hurt_sfx: AudioStreamPlayer = $HurtSFX
@onready var death_sfx: AudioStreamPlayer = $DeathSFX

var state := State.IDLE
var attack_kind := AttackKind.STAND
var hp := 0
var home := Vector3.ZERO
var target := Vector3.ZERO
var facing := "down"
var state_time := 0.0
var idle_duration := 1.0
var walk_time := 0.0
var attack_cd := 0.0
var hit_done := false
var attack_dir := Vector3.ZERO
var player: Node3D = null

var dash_cd := 0.0
var dash_dir := Vector3.ZERO
var is_elite := false

# Variabel Boss
var is_boss := false
var slam_cd := 0.0

var retreat_dir := Vector3.ZERO


func _ready() -> void:
	if stats == null:
		push_error("GoblinStats belum dipasang pada: " + name)
		return

	add_to_group("enemy")
	hp = stats.max_hp
	home = global_position
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

	if stats.sprite_frames:
		sprite.sprite_frames = stats.sprite_frames

	is_elite = (stats.tier == 2)
	is_boss = (stats.tier == 3)

	# Ambil sound dari file GoblinStats .tres
	_setup_goblin_sound()

	var s := stats.size_scale
	sprite.scale = Vector3.ONE * s
	sprite.position.y *= s
	col.scale = Vector3.ONE * s
	col.position.y *= s
	sprite.modulate = stats.tint

	for anim in sprite.sprite_frames.get_animation_names():
		if _action_of(anim) in NON_LOOP:
			sprite.sprite_frames.set_animation_loop(anim, false)

	_enter_idle()


# ---------------- SOUND SETUP ----------------
func _setup_goblin_sound() -> void:
	# Sound dibaca langsung dari resource .tres
	hurt_sfx.stream = stats.hurt_sound
	death_sfx.stream = stats.death_sound

	print("=== GOBLIN SOUND CHECK ===")
	print("Goblin: ", name)
	print("Tier: ", stats.tier)
	print("Hurt Sound: ", stats.hurt_sound)
	print("Death Sound: ", stats.death_sound)
	print("==========================")

	if hurt_sfx.stream == null:
		push_warning("Hurt sound belum diisi pada resource: " + stats.display_name)

	if death_sfx.stream == null:
		push_warning("Death sound belum diisi pada resource: " + stats.display_name)


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	if global_position.y < -3.0:
		global_position = home + Vector3(0, 0.5, 0)
		velocity = Vector3.ZERO

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	if attack_cd > 0.0:
		attack_cd -= delta
	if stagger_cd > 0.0:
		stagger_cd -= delta
	if dash_cd > 0.0:
		dash_cd -= delta
	if slam_cd > 0.0:
		slam_cd -= delta

	state_time += delta

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D

	var dist := INF
	if player and not _player_is_safe():
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
			else:
				if is_boss:
					# --- LOGIKA BOSS ---
					if slam_cd <= 0.0 and dist <= BOSS_SLAM_RANGE:
						_enter_boss_slam()
					elif dist <= stats.attack_range and attack_cd <= 0.0:
						_enter_attack(dist)
					elif dist > stats.attack_range:
						var dir := _dir_to_player()
						_set_facing(dir)
						_move(dir * stats.chase_speed)
						_play("run_" + facing)
					else:
						_move(Vector3.ZERO)
						_face_player()
						_play("idle_" + facing)

				elif is_elite:
					# --- LOGIKA ELIT ---
					if dash_cd <= 0.0:
						if dist <= ELIT_DASH_RANGE and dist > 1.5:
							_enter_dash()
						elif dist > ELIT_DASH_RANGE:
							var dir := _dir_to_player()
							_set_facing(dir)
							_move(dir * stats.wander_speed)
							_play("walk_" + facing)
						else:
							_move(Vector3.ZERO)
							_face_player()
							_play("idle_" + facing)
					else:
						if dist < ELIT_SAFE_DISTANCE:
							_enter_retreat()
						else:
							_move(Vector3.ZERO)
							_face_player()
							_play("idle_" + facing)
				else:
					# --- LOGIKA GOBLIN BIASA ---
					if attack_cd <= 0.0 and dist <= stats.attack_range * 3.0:
						_enter_attack(dist)
					elif dist <= stats.attack_range:
						_move(Vector3.ZERO)
						_face_player()
						_play("idle_" + facing)
					else:
						var dir := _dir_to_player()
						_set_facing(dir)
						_move(dir * stats.chase_speed)
						_play("run_" + facing)

		State.ATTACK:
			_process_attack(dist)

		State.DASH:
			_process_dash(dist)

		State.BOSS_SLAM:
			_process_boss_slam(dist)

		State.RETREAT:
			if is_on_wall():
				var side := Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
				retreat_dir = (retreat_dir + side).normalized()

			_move(retreat_dir * stats.wander_speed)
			_set_facing(retreat_dir)
			_play("walk_" + facing)

			if dist > ELIT_SAFE_DISTANCE + 1.0:
				_enter_chase()

		State.HURT:
			_move(Vector3.ZERO)
			if state_time >= HURT_TIME:
				_enter_chase()


# ---------------- LOGIKA BOSS SLAM ----------------
func _enter_boss_slam() -> void:
	state = State.BOSS_SLAM
	state_time = 0.0
	hit_done = false
	_face_player()

	# Animasi ancang-ancang
	_play("attack_" + facing, true)

	var base_scale := Vector3.ONE * stats.size_scale
	var base_pos := sprite.position

	var tw := create_tween()

	tw.tween_property(sprite, "modulate", Color(1.0, 0.0, 0.0), BOSS_CAST_TIME * 0.5)
	tw.parallel().tween_property(sprite, "scale", base_scale * 1.3, BOSS_CAST_TIME).set_trans(Tween.TRANS_ELASTIC)
	tw.tween_property(sprite, "modulate", Color(1.0, 0.3, 0.3), BOSS_CAST_TIME * 0.5)

	for i in range(10):
		tw.tween_property(sprite, "position", base_pos + Vector3(randf_range(-0.15, 0.15), randf_range(-0.15, 0.15), 0), 0.04)

	tw.tween_property(sprite, "position", base_pos, 0.05)
	tw.parallel().tween_property(sprite, "scale", base_scale, 0.1).set_trans(Tween.TRANS_SINE)


func _shake_sprite(original_pos: Vector3, duration: float) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		sprite.position = original_pos + Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), 0)
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	sprite.position = original_pos


func _process_boss_slam(dist: float) -> void:
	_move(Vector3.ZERO)

	if not hit_done and state_time >= BOSS_CAST_TIME:
		hit_done = true
		slam_cd = BOSS_SLAM_CD
		attack_cd = stats.attack_cooldown
		_do_slam_damage()

	if state_time >= BOSS_CAST_TIME + 0.5:
		_enter_chase()


func _do_slam_damage() -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0), 0.1)
	tw.tween_property(sprite, "modulate", stats.tint, 0.3)

	if player == null:
		return

	var d := player.global_position - global_position
	d.y = 0.0

	var hit_radius := stats.attack_range + 1.0

	if d.length() <= hit_radius:
		print("Player KENA HEAVY ATTACK!")
		if player.has_method("take_damage"):
			player.take_damage(int(stats.damage * 3.0))


# ---------------- STATE DASH ELIT ----------------
func _enter_dash() -> void:
	state = State.DASH
	state_time = 0.0
	hit_done = false
	dash_dir = _dir_to_player()
	_set_facing(dash_dir)

	_play("run_" + facing, true)

	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.2, 0.2), 0.15)
	tw.tween_property(sprite, "modulate", stats.tint, 0.1)


func _process_dash(dist: float) -> void:
	_move(dash_dir * ELIT_DASH_SPEED)

	if not hit_done and state_time >= 0.1:
		if dist <= stats.attack_range + 0.8:
			hit_done = true
			if player and player.has_method("take_damage"):
				player.take_damage(int(stats.damage * 1.5))
				_play("attack_" + facing, true)
				_move(Vector3.ZERO)

	if state_time >= ELIT_DASH_DURATION:
		dash_cd = ELIT_DASH_CD
		attack_cd = stats.attack_cooldown
		_enter_retreat()


func _enter_retreat() -> void:
	state = State.RETREAT
	state_time = 0.0

	var dir_to_player := _dir_to_player()
	var backward := -dir_to_player
	var side := Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()

	retreat_dir = (backward + side * 0.5).normalized()


# ---------------- STATE NORMAL ----------------
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
	if state != State.CHASE and state != State.DASH and state != State.RETREAT:
		QuestManager.warn_danger(stats.tier)
	state = State.CHASE
	state_time = 0.0


func _enter_attack(dist: float) -> void:
	state = State.ATTACK
	state_time = 0.0
	hit_done = false

	if dist <= stats.attack_range:
		attack_kind = AttackKind.STAND
	elif dist <= stats.attack_range * 1.7:
		attack_kind = AttackKind.WALK
	else:
		attack_kind = AttackKind.LUNGE

	attack_dir = _dir_to_player()
	_set_facing(attack_dir)

	match attack_kind:
		AttackKind.STAND:
			_play("attack_" + facing, true)
		AttackKind.WALK:
			_play("walk_attack_" + facing, true)
		AttackKind.LUNGE:
			_play("run_attack_" + facing, true)

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

	if is_elite and state == State.DASH:
		print(name, " kebal saat dash!")
		return

	hp -= amount
	print(name, " HP: ", hp, "/", stats.max_hp)

	# Jika HP habis, langsung jalankan suara kematian
	if hp <= 0:
		_die()
		return

	# SOUND: goblin terkena damage
	if hurt_sfx.stream != null:
		hurt_sfx.stop()
		hurt_sfx.play()
		print("HURT SOUND PLAYING: ", name)
	else:
		print("HURT SOUND KOSONG: ", name)

	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tw.tween_property(sprite, "modulate", stats.tint, 0.15)

	if stats.can_stagger and state != State.ATTACK and state != State.BOSS_SLAM and stagger_cd <= 0.0:
		stagger_cd = STAGGER_COOLDOWN
		state = State.HURT
		state_time = 0.0
		_play("hurt_" + facing, true)
	elif state == State.IDLE or state == State.WANDER:
		_enter_chase()


func _die() -> void:
	state = State.DEAD
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	remove_from_group("enemy")

	# SOUND: goblin mati
	hurt_sfx.stop()

	if death_sfx.stream != null:
		death_sfx.play()
		print("DEATH SOUND PLAYING: ", name)
	else:
		print("DEATH SOUND KOSONG: ", name)

	GameState.add_xp(stats.xp_reward)
	print(name, " mati, Hero dapat ", stats.xp_reward, " XP")

	_drop_loot()
	QuestManager.report_kill(stats.tier)
	died.emit(self)

	var anim := "death_" + facing
	if sprite.sprite_frames.has_animation(anim):
		_play(anim, true)
		await sprite.animation_finished

	var tw := create_tween()
	tw.tween_property(sprite, "scale", Vector3.ZERO, 0.4)
	await tw.finished

	# Tunggu suara kematian selesai sebelum menghapus goblin
	if death_sfx.playing:
		await death_sfx.finished

	queue_free()


func _drop_loot() -> void:
	_roll_drop(stats.drop_item_id, stats.drop_chance)
	_roll_drop(stats.bonus_item_id, stats.bonus_chance)
	_roll_shard()


func _roll_drop(id: StringName, chance: float) -> void:
	if id == &"" or randf() > chance:
		return
	_make_pickup(id)


func _roll_shard() -> void:
	var id := stats.shard_id
	if id == &"" or GameState.shards_dropped.has(id):
		return

	GameState.kills[id] = GameState.kills.get(id, 0) + 1
	var pity: bool = stats.shard_pity > 0 and GameState.kills[id] >= stats.shard_pity

	if pity or randf() < stats.shard_chance:
		GameState.shards_dropped[id] = true
		_make_pickup(id)


func _make_pickup(id: StringName) -> void:
	var pickup := ItemPickup.new()
	pickup.item_id = id
	get_parent().add_child(pickup)
	pickup.global_position = global_position + Vector3(
		randf_range(-0.3, 0.3), 0.1, randf_range(-0.3, 0.3))


# ---------------- GERAK & ANIMASI ----------------
func _move(horizontal: Vector3) -> void:
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	move_and_slide()


func _player_is_safe() -> bool:
	if player == null:
		return false

	var d := player.global_position - SAFE_CENTER
	d.y = 0.0
	return d.length() < SAFE_RADIUS


func _dir_to_player() -> Vector3:
	if player == null:
		return Vector3.ZERO

	var d := player.global_position - global_position
	d.y = 0.0
	return d.normalized()


func _face_player() -> void:
	_set_facing(_dir_to_player())


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


func _action_of(anim: String) -> String:
	var i := anim.rfind("_")
	return anim.substr(0, i) if i > 0 else anim
