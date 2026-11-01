extends Area3D

@export var roof_meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(b: Node3D) -> void:
	if b.is_in_group("player"):
		_set_inside(true)

func _on_exit(b: Node3D) -> void:
	if b.is_in_group("player"):
		_set_inside(false)

func _set_inside(inside: bool) -> void:
	for m in roof_meshes:
		m.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if inside
			else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		)
