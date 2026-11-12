extends CanvasLayer

signal profile_pressed

@onready var hp_bar: TextureProgressBar = $Root/Bar/HPBar
@onready var xp_bar: TextureProgressBar = $Root/Bar/XPBar
@onready var cd_overlay: TextureProgressBar = $Root/Bar/DashSlot/CDOverlay
@onready var cd_label: Label = $Root/Bar/DashSlot/CDLabel
@onready var profile_btn: TextureButton = $Root/Bar/ProfileSlot

var player: Node
var _hp_tween: Tween
var _xp_tween: Tween


func _ready() -> void:
	add_to_group("hud")
	cd_overlay.max_value = 100
	cd_overlay.value = 0
	cd_label.visible = false

	GameState.hp_changed.connect(_on_hp_changed)
	GameState.xp_changed.connect(_on_xp_changed)

	hp_bar.max_value = GameState.hp_max
	hp_bar.value = GameState.hp_current
	xp_bar.max_value = GameState.XP_PER_LEVEL
	xp_bar.value = GameState.xp

	profile_btn.pressed.connect(func(): profile_pressed.emit())


func _process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	cd_overlay.value = player.get_dash_ratio() * 100.0

	var remaining: float = player.dash_cooldown_timer
	cd_label.visible = remaining > 0.0
	if cd_label.visible:
		cd_label.text = "%.1f" % remaining


func _on_hp_changed(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	if _hp_tween:
		_hp_tween.kill()
	_hp_tween = create_tween()
	_hp_tween.tween_property(hp_bar, "value", float(current), 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_xp_changed(current: int, maximum: int, _level: int) -> void:
	xp_bar.max_value = maximum
	if _xp_tween:
		_xp_tween.kill()
	_xp_tween = create_tween()
	_xp_tween.tween_property(xp_bar, "value", float(current), 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("profile"):
		profile_pressed.emit()
