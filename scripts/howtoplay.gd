
extends Control

@export_file("*.tscn") var about_scene_path: String

@onready var bgm: AudioStreamPlayer = $BGM
@onready var click_sfx: AudioStreamPlayer = $SFXClick
@onready var back_button: Button = $Back


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

	# Putar BGM
	if not bgm.playing:
		bgm.play()


func _on_back_pressed() -> void:
	if about_scene_path.is_empty():
		push_warning("About scene path belum diatur!")
		return

	# Putar suara klik
	click_sfx.play()

	# Tunggu suara klik selesai
	await click_sfx.finished

	# Kembali ke About
	get_tree().change_scene_to_file(about_scene_path)
