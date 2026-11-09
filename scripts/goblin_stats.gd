class_name GoblinStats
extends Resource

@export var display_name := "Goblin"
@export var sprite_frames: SpriteFrames
@export var tint := Color.WHITE
@export var size_scale := 1.0

@export_group("Statistik")
@export var max_hp := 40
@export var damage := 10
@export var wander_speed := 1.5
@export var chase_speed := 3.0
@export var detect_range := 8.0
@export var lose_range := 11.0

@export_group("Serangan")
@export var attack_range := 1.2
@export var attack_cooldown := 1.0
@export var windup_time := 0.4
@export var attack_total := 0.8
@export var can_stagger := true   # boss: matikan supaya tidak kena stun
