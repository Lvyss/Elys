extends CharacterBody3D

const TALK_RANGE := 2.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var prompt: Label3D = $Prompt

var _player: Node3D


func _ready() -> void:
	add_to_group("npc")
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func _process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
		return
	var shop := get_tree().get_first_node_in_group("shop")
	var near := global_position.distance_to(_player.global_position) <= TALK_RANGE
	prompt.visible = near and not (shop and shop.visible)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("E ditekan, prompt visible: ", prompt.visible)
		if not prompt.visible:
			return
		var shop := get_tree().get_first_node_in_group("shop")
		print("shop ditemukan: ", shop)
		if shop:
			shop.open()
			get_viewport().set_input_as_handled()
