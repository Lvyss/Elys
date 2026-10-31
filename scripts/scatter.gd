@tool
extends Node3D

@export var item_scene: PackedScene
@export var count := 40
@export var area_min := Vector2(-10.0, -10.0)   # X, Z
@export var area_max := Vector2(10.0, 10.0)
@export var scale_range := Vector2(0.8, 1.3)
@export var random_seed := 1
@export var regenerate := false:
	set(value):
		regenerate = false
		if value and is_inside_tree():
			_generate()

func _generate() -> void:
	for child in get_children():
		child.queue_free()
	if item_scene == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	for i in count:
		var node := item_scene.instantiate() as Node3D
		add_child(node)
		node.owner = get_tree().edited_scene_root
		node.position = Vector3(
			rng.randf_range(area_min.x, area_max.x),
			0.0,
			rng.randf_range(area_min.y, area_max.y))
		node.rotation.y = rng.randf() * TAU
		node.scale = Vector3.ONE * rng.randf_range(scale_range.x, scale_range.y)
