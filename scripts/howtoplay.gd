extends Control

@export_file("*.tscn") var about_scene_path: String


func _ready() -> void:
	$Back.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	if about_scene_path.is_empty():
		push_warning("About scene path belum diatur!")
		return

	get_tree().change_scene_to_file(about_scene_path)
