class_name ItemPickup
extends Node3D

const PICKUP_RADIUS := 1.0     # jarak otomatis terambil
const MAGNET_RADIUS := 2.5     # mulai tersedot ke hero
const MAGNET_SPEED := 8.0
const PICKUP_DELAY := 0.6      # jeda supaya efek muncul terlihat dulu
const HOVER_HEIGHT := 0.45

var item_id: StringName = &""

var _sprite: Sprite3D
var _age := 0.0
var _collected := false
var _player: Node3D
var _data: ItemData


func _ready() -> void:
	_data = GameState.get_item_data(item_id)
	if _data == null or _data.icon == null:
		push_warning("ItemPickup: data/ikon item '%s' tidak ditemukan" % item_id)
		queue_free()
		return

	_sprite = Sprite3D.new()
	_sprite.texture = _data.icon
	_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_sprite.shaded = false
	_sprite.pixel_size = 0.5 / maxf(_data.icon.get_width(), 1.0)   # ikon setinggi sekitar 0.5 m
	_sprite.position.y = 0.1
	add_child(_sprite)


func _process(delta: float) -> void:
	if _collected or _sprite == null:
		return
	_age += delta

	# Muncul (naik) lalu melayang pelan
	var pop := clampf(_age / 0.35, 0.0, 1.0)
	var y := lerpf(0.1, HOVER_HEIGHT, pop)
	if pop >= 1.0:
		y += sin(_age * 3.0) * 0.06
	_sprite.position.y = y

	if _age < PICKUP_DELAY:
		return

	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
		return

	var to := (_player.global_position + Vector3(0, 0.5, 0)) - global_position
	var d := to.length()
	if d <= PICKUP_RADIUS:
		_collect()
	elif d <= MAGNET_RADIUS:
		global_position += to.normalized() * MAGNET_SPEED * delta


func _collect() -> void:
	_collected = true
	GameState.add_item(item_id)

	# Teks "+ Nama Item" naik lalu memudar
	var label := Label3D.new()
	label.text = "+ " + _data.display_name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.006
	label.outline_size = 12
	label.position.y = _sprite.position.y + 0.4
	add_child(label)

	var tw := create_tween().set_parallel(true)
	tw.tween_property(_sprite, "scale", Vector3.ZERO, 0.25)
	tw.tween_property(label, "position:y", label.position.y + 0.6, 0.7)
	tw.tween_property(label, "modulate:a", 0.0, 0.7)
	tw.chain().tween_callback(queue_free)
