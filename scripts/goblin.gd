extends CharacterBody3D

@export var speed := 1.5
@export var wander_radius := 3.0

const ARRIVE_DISTANCE := 0.15
const MAX_WALK_TIME := 4.0

# Offset khusus per animasi (piksel). Yang tidak ditulis = (0, 0)
const ANIM_OFFSETS := {
	"idle": Vector2(0, -16),    # ganti angkanya kalau posisinya geser
	"death": Vector2(0, 0),
}

@onready var sprite: AnimatedSprite3D = $Sprite
@onready var idle_timer: Timer = $IdleTimer

var home := Vector3.ZERO
var target := Vector3.ZERO
var walking := false
var walk_time := 0.0

func _ready() -> void:
	home = global_position
	sprite.animation_changed.connect(_apply_offset)
	idle_timer.timeout.connect(_pick_new_target)
	_start_idle()
	_apply_offset()

func _physics_process(delta: float) -> void:
	if walking:
		walk_time += delta
		var to_target := target - global_position
		to_target.y = 0.0
		if to_target.length() < ARRIVE_DISTANCE or walk_time > MAX_WALK_TIME:
			_start_idle()
		else:
			var dir := to_target.normalized()
			velocity = dir * speed
			if absf(dir.x) > 0.1:
				# Aset menghadap KANAN: flip kalau jalan ke kiri
				sprite.flip_h = dir.x < 0.0
	else:
		velocity = Vector3.ZERO
	move_and_slide()

func _start_idle() -> void:
	walking = false
	sprite.play("idle")
	idle_timer.start(randf_range(1.0, 3.0))

func _pick_new_target() -> void:
	var angle := randf() * TAU
	var dist := randf_range(1.0, wander_radius)
	target = home + Vector3(cos(angle), 0.0, sin(angle)) * dist
	walk_time = 0.0
	walking = true
	sprite.play("run")

func _apply_offset() -> void:
	sprite.offset = ANIM_OFFSETS.get(sprite.animation, Vector2.ZERO)
