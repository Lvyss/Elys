extends CharacterBody3D

@export var speed: float = 1.5
@export var wander_radius: float = 3.0
@export var max_health: int = 3
@export var detection_range: float = 5.0
@export var attack_range: float = 1.2
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.5

const ARRIVE_DISTANCE: float = 0.15
const MAX_WALK_TIME: float = 4.0
const FIRST_ATTACK_DELAY: float = 0.8

# Pastikan nama animasi di SpriteFrames menggunakan
# akhiran _north, _south, _east, dan _west.
const DIRECTIONS: Array[String] = ["north", "south", "east", "west"]

const ANIM_OFFSETS := {
	"idle_north": Vector2(0, -16),
	"death_north": Vector2(0, 0),
}

@onready var sprite: AnimatedSprite3D = $Sprite
@onready var idle_timer: Timer = $IdleTimer

var home: Vector3
var target: Vector3
var walking: bool = false
var walk_time: float = 0.0

var health: int
var player: Node3D = null
var facing: String = "south"
var attack_timer: float = 0.0
var dead: bool = false


func _ready() -> void:
	home = global_position
	health = max_health

	idle_timer.timeout.connect(_pick_new_target)

	_play_action("idle")
	idle_timer.start(randf_range(1.0, 3.0))


func _physics_process(delta: float) -> void:
	if dead:
		return

	player = _find_player()

	if player != null and _distance_to_player() <= detection_range:
		_chase_or_attack(delta)
	else:
		attack_timer = 0.0
		_wander(delta)

	move_and_slide()


func _find_player() -> Node3D:
	var players := get_tree().get_nodes_in_group("player")

	if players.is_empty():
		return null

	return players[0] as Node3D


func _distance_to_player() -> float:
	if player == null:
		return INF

	var difference: Vector3 = player.global_position - global_position
	difference.y = 0.0
	return difference.length()


func _chase_or_attack(delta: float) -> void:
	idle_timer.stop()

	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0

	var distance: float = to_player.length()

	if distance > 0.001:
		_face_direction(to_player)

	if distance > attack_range:
		attack_timer = 0.0
		walking = false
		velocity = to_player.normalized() * speed
		_play_action("walk")
		return

	velocity = Vector3.ZERO
	walking = false
	attack_timer += delta
	_play_action("attack")

	# Jeda sebelum serangan pertama dan di antara serangan.
	if attack_timer >= FIRST_ATTACK_DELAY:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

		attack_timer = FIRST_ATTACK_DELAY - attack_cooldown


func _wander(delta: float) -> void:
	if walking:
		walk_time += delta

		var to_target: Vector3 = target - global_position
		to_target.y = 0.0

		if to_target.length() <= ARRIVE_DISTANCE or walk_time >= MAX_WALK_TIME:
			_start_idle()
		else:
			velocity = to_target.normalized() * speed
			_face_direction(to_target)
			_play_action("walk")
	else:
		velocity = Vector3.ZERO


func _face_direction(direction: Vector3) -> void:
	# Arah berdasarkan sumbu X/Z Godot.
	# X positif = east, X negatif = west.
	# Z positif = south, Z negatif = north.
	if absf(direction.x) > absf(direction.z):
		facing = "east" if direction.x > 0.0 else "west"
	else:
		facing = "south" if direction.z > 0.0 else "north"


func _play_action(action: String) -> void:
	var animation_name: String = action + "_" + facing

	if sprite.sprite_frames == null:
		push_warning("Sprite belum memiliki SpriteFrames.")
		return

	if not sprite.sprite_frames.has_animation(animation_name):
		push_warning("Animasi tidak ditemukan: " + animation_name)
		return

	# Jangan mulai ulang animasi setiap frame.
	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _start_idle() -> void:
	walking = false
	velocity = Vector3.ZERO
	_play_action("idle")
	idle_timer.start(randf_range(1.0, 3.0))


func _pick_new_target() -> void:
	if dead:
		return

	if player != null and _distance_to_player() <= detection_range:
		return

	var angle: float = randf() * TAU
	var distance: float = randf_range(1.0, wander_radius)

	target = home + Vector3(
		cos(angle) * distance,
		0.0,
		sin(angle) * distance
	)

	walk_time = 0.0
	walking = true
	_play_action("walk")


func take_damage(amount: int) -> void:
	if dead:
		return

	health -= amount

	if health <= 0:
		_die()


func _die() -> void:
	dead = true
	walking = false
	velocity = Vector3.ZERO
	idle_timer.stop()

	_play_action("death")

	var death_animation: String = "death_" + facing
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(death_animation):
		await sprite.animation_finished

	queue_free()


func _on_sprite_animation_changed() -> void:
	if ANIM_OFFSETS.has(sprite.animation):
		sprite.offset = ANIM_OFFSETS[sprite.animation]
	else:
		sprite.offset = Vector2.ZERO
