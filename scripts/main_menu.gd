extends Control

@onready var start_button: Button = $Start
@onready var about_button: Button = $About
@onready var quit_button: Button = $Quit

const HOVER_COLOR := Color(1.25, 1.25, 1.25)
const PULSE_FACTOR := 0.94
const PRESS_FACTOR := 0.88
const PULSE_TIME := 0.3

# Bagian rect tombol yang DIBUANG dari tiap sisi (0.0 - 0.5).
# x = kiri/kanan, y = atas/bawah. Perbesar angkanya kalau area masih kelebihan.
const HIT_MARGIN := Vector2(0.13, 0.27)

var _buttons: Array[Button] = []
var _scale_tweens: Dictionary = {}
var _color_tweens: Dictionary = {}
var _base_scale: Dictionary = {}
var _hovered: Button = null
var _locked := false


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	about_button.pressed.connect(_on_about_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	_buttons = [start_button, about_button, quit_button]
	for btn in _buttons:
		_base_scale[btn] = btn.scale

		# Pivot ke tengah + imbangi posisi supaya tombol tidak bergeser
		btn.pivot_offset = btn.size / 2.0
		btn.position -= btn.pivot_offset * (Vector2.ONE - btn.scale)

		# Mouse ditangani script kita, bukan oleh rect tombol yang kebesaran
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.focus_mode = Control.FOCUS_NONE


# --- DETEKSI HOVER (hitbox kecil) ---

func _is_over(btn: Button) -> bool:
	var p := btn.get_local_mouse_position()   # sudah memperhitungkan scale & pivot
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
		Input.CURSOR_POINTING_HAND if now else Input.CURSOR_ARROW)


func _input(event: InputEvent) -> void:
	if _locked or _hovered == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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

	var c := _new_tween(_color_tweens, btn)
	c.tween_property(btn, "modulate", HOVER_COLOR, 0.08)

	var s := _new_tween(_scale_tweens, btn)
	s.set_loops()
	s.tween_property(btn, "scale", base * PULSE_FACTOR, PULSE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	s.tween_property(btn, "scale", base, PULSE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_button_unhover(btn: Button) -> void:
	var c := _new_tween(_color_tweens, btn)
	c.tween_property(btn, "modulate", Color.WHITE, 0.12)

	var s := _new_tween(_scale_tweens, btn)
	s.tween_property(btn, "scale", _base_scale[btn], 0.12).set_trans(Tween.TRANS_SINE)


# --- EFEK KLIK ---

func _play_click(btn: Button) -> Tween:
	var base: Vector2 = _base_scale[btn]

	var c := _new_tween(_color_tweens, btn)
	c.tween_property(btn, "modulate", Color(1.6, 1.6, 1.6), 0.06)
	c.tween_property(btn, "modulate", HOVER_COLOR, 0.15)

	var s := _new_tween(_scale_tweens, btn)
	s.tween_property(btn, "scale", base * PRESS_FACTOR, 0.06).set_trans(Tween.TRANS_SINE)
	s.tween_property(btn, "scale", base, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return s


# --- AKSI TOMBOL ---

func _on_start_pressed() -> void:
	_locked = true
	await _play_click(start_button).finished
	await SceneTransition.change_scene("res://scenes/maps/loading_screen2.tscn")


func _on_about_pressed() -> void:
	_play_click(about_button)
	print("About ditekan!")


func _on_quit_pressed() -> void:
	_locked = true
	await _play_click(quit_button).finished
	get_tree().quit()
