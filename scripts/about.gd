
extends Control

@onready var how_to_play_button: Button = $HowToPlay
@onready var credit_button: Button = $Credit
@onready var back_button: Button = $Back

@onready var bgm: AudioStreamPlayer = $BGM
@onready var click_sfx: AudioStreamPlayer = $SFXClick

const HOW_TO_PLAY_SCENE := "res://scenes/maps/howtoplay.tscn"
const CREDIT_SCENE := "res://scenes/maps/credit.tscn"
const HOME_SCENE := "res://scenes/maps/main_menu.tscn"

const HOVER_COLOR := Color(1.25, 1.25, 1.25)
const PULSE_FACTOR := 0.94
const PRESS_FACTOR := 0.88
const PULSE_TIME := 0.3

const HIT_MARGIN := Vector2(0.13, 0.27)

var _buttons: Array[Button] = []
var _scale_tweens: Dictionary = {}
var _color_tweens: Dictionary = {}
var _base_scale: Dictionary = {}

var _hovered: Button = null
var _locked := false


func _ready() -> void:
	# Hubungkan tombol
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	credit_button.pressed.connect(_on_credit_pressed)
	back_button.pressed.connect(_on_back_pressed)

	# Daftar tombol
	_buttons = [
		how_to_play_button,
		credit_button,
		back_button
	]

	# Pengaturan awal tombol
	for btn in _buttons:
		_base_scale[btn] = btn.scale

		btn.pivot_offset = btn.size / 2.0
		btn.position -= btn.pivot_offset * (Vector2.ONE - btn.scale)

		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.focus_mode = Control.FOCUS_NONE

	# Putar BGM
	if not bgm.playing:
		bgm.play()


# --- DETEKSI HOVER ---

func _is_over(btn: Button) -> bool:
	var p := btn.get_local_mouse_position()
	var m := btn.size * HIT_MARGIN

	return Rect2(m, btn.size - m * 2.0).has_point(p)


func _process(_delta: float) -> void:
	if _locked:
		return

	var now: Button = null

	for btn in _buttons:
		if _is_over(btn):
			now = btn
			break

	if now == _hovered:
		return

	if _hovered:
		_on_button_unhover(_hovered)

	if now:
		_on_button_hover(now)

	_hovered = now

	Input.set_default_cursor_shape(
		Input.CURSOR_POINTING_HAND if now else Input.CURSOR_ARROW
	)


func _input(event: InputEvent) -> void:
	if _locked or _hovered == null:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_hovered.pressed.emit()
			get_viewport().set_input_as_handled()


# --- TWEEN ---

func _new_tween(store: Dictionary, btn: Control) -> Tween:
	if store.has(btn) and store[btn] and store[btn].is_valid():
		store[btn].kill()

	var t := create_tween()
	store[btn] = t

	return t


# --- HOVER ---

func _on_button_hover(btn: Button) -> void:
	var base: Vector2 = _base_scale[btn]

	# Efek warna
	var c := _new_tween(_color_tweens, btn)
	c.tween_property(
		btn, "modulate", HOVER_COLOR, 0.08
	)

	# Efek pulse
	var s := _new_tween(_scale_tweens, btn)
	s.set_loops()

	s.tween_property(
		btn, "scale", base * PULSE_FACTOR, PULSE_TIME
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	s.tween_property(
		btn, "scale", base, PULSE_TIME
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_button_unhover(btn: Button) -> void:
	# Mengembalikan warna
	var c := _new_tween(_color_tweens, btn)
	c.tween_property(
		btn, "modulate", Color.WHITE, 0.12
	)

	# Mengembalikan ukuran
	var s := _new_tween(_scale_tweens, btn)
	s.tween_property(
		btn, "scale", _base_scale[btn], 0.12
	).set_trans(Tween.TRANS_SINE)


# --- EFEK KLIK + SOUND ---

func _play_click(btn: Button) -> Tween:
	var base: Vector2 = _base_scale[btn]

	# Putar sound klik
	click_sfx.play()

	# Efek flash
	var c := _new_tween(_color_tweens, btn)

	c.tween_property(
		btn, "modulate", Color(1.6, 1.6, 1.6), 0.06
	)

	c.tween_property(
		btn, "modulate", HOVER_COLOR, 0.15
	)

	# Efek tekan
	var s := _new_tween(_scale_tweens, btn)

	s.tween_property(
		btn, "scale", base * PRESS_FACTOR, 0.06
	).set_trans(Tween.TRANS_SINE)

	s.tween_property(
		btn, "scale", base, 0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	return s


# --- NAVIGASI SCENE ---

func _on_how_to_play_pressed() -> void:
	if _locked:
		return

	_locked = true
	_play_click(how_to_play_button)

	await SceneTransition.change_scene(HOW_TO_PLAY_SCENE)


func _on_credit_pressed() -> void:
	if _locked:
		return

	_locked = true
	_play_click(credit_button)

	await SceneTransition.change_scene(CREDIT_SCENE)


func _on_back_pressed() -> void:
	if _locked:
		return

	_locked = true
	_play_click(back_button)

	await SceneTransition.change_scene(HOME_SCENE)
