extends Area3D

@export var anim_player: AnimationPlayer
@export var anim_name: String = ""   # kosong = otomatis pilih

var _is_open := false

func _ready() -> void:
	if anim_player == null:
		push_warning("Isi slot Anim Player di Inspector")
		return
	if anim_name == "":
		for a in anim_player.get_animation_list():
			if a != "RESET":
				anim_name = a
				break
	print("Animasi pintu: ", anim_name, " | daftar: ", anim_player.get_animation_list())
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(b: Node3D) -> void:
	if b.is_in_group("player") and not _is_open:
		_is_open = true
		anim_player.play(anim_name)

func _on_exit(b: Node3D) -> void:
	if b.is_in_group("player") and _is_open:
		_is_open = false
		anim_player.play_backwards(anim_name)
