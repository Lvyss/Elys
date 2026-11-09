
extends Control

@export var next_scene_path: String = "res://scenes/maps/main_menu.tscn"
@export var seconds_per_dot: float = 1.0
@export var max_dots: int = 3

@onready var loading_text: Label = $LoadingText


func _ready() -> void:
	await start_loading()


func start_loading() -> void:
	for dot_count in range(max_dots + 1):
		loading_text.text = "Loading" + " .".repeat(dot_count)

		await get_tree().create_timer(seconds_per_dot).timeout

	await change_to_next_scene()


func change_to_next_scene() -> void:
	if ResourceLoader.exists(next_scene_path):
		await SceneTransition.change_scene(next_scene_path)
	else:
		push_error("Scene tujuan tidak ditemukan: " + next_scene_path)
