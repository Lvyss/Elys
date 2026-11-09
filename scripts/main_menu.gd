
extends Control

@onready var start_button: Button = $Start
@onready var about_button: Button = $About
@onready var quit_button: Button = $Quit


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	about_button.pressed.connect(_on_about_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	print("Main Menu berhasil dimuat!")


func _on_start_pressed() -> void:
	print("Memulai permainan...")

	await SceneTransition.change_scene(
        "res://scenes/maps/loading_screen2.tscn"
	)


func _on_about_pressed() -> void:
	print("About ditekan!")


func _on_quit_pressed() -> void:
	print("Keluar dari game!")
	get_tree().quit()
