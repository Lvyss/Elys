extends CanvasLayer
class_name PauseMenu
## Popup jeda: Lanjutkan Game / Kembali ke Menu Utama.
## Mem-pause seluruh tree selama terbuka dan otomatis un-pause saat ditutup.

signal resumed
signal main_menu_requested

var _closing := false


func _init() -> void:
	layer = 45
	process_mode = Node.PROCESS_MODE_ALWAYS   # tetap jalan walau game di-pause


func _ready() -> void:
	get_tree().paused = true
	_build()
	_animate_in()


# ESC lagi = lanjut main
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_close(resumed)


func _close(result: Signal) -> void:
	if _closing:
		return
	_closing = true
	get_tree().paused = false
	result.emit()
	queue_free()


var _panel: PanelContainer

func _build() -> void:
	# latar gelap
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.03, 0.03, 0.0)
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	create_tween().tween_property(dim, "color:a", 0.7, 0.25)

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# panel sama persis dengan popup quest / menu kematian
	var p: Dictionary = QuestManager._make_panel(400.0, 20, 12)
	_panel = p["root"]
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(_panel)

	(p["header"] as Label).text = "JEDA"
	var body: VBoxContainer = p["body"]

	var title := QuestManager._label(26, QuestManager.GOLD)
	title.text = "GAME DIJEDA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var desc := QuestManager._label(13, QuestManager.TEXT_LIGHT, true)
	desc.text = "Hutan menunggu kembalinya kamu. Progres run ini tidak tersimpan kalau kembali ke menu utama."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var line := ColorRect.new()
	line.custom_minimum_size.y = 2
	line.color = QuestManager.BROWN_MID

	var btn_resume := Button.new()
	btn_resume.text = "Lanjutkan Game"
	btn_resume.custom_minimum_size.y = 42
	QuestManager._style_btn(btn_resume)
	btn_resume.pressed.connect(_close.bind(resumed))

	var btn_menu := Button.new()
	btn_menu.text = "Kembali ke Menu Utama"
	btn_menu.custom_minimum_size.y = 42
	QuestManager._style_btn(btn_menu)
	btn_menu.pressed.connect(_close.bind(main_menu_requested))

	var hint := QuestManager._label(11, Color("#8a7d68"))
	hint.text = "Tekan ESC untuk lanjut"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	body.add_child(title)
	body.add_child(desc)
	body.add_child(line)
	body.add_child(btn_resume)
	body.add_child(btn_menu)
	body.add_child(hint)


func _animate_in() -> void:
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.7, 0.7)
	await get_tree().process_frame
	_panel.pivot_offset = _panel.size * 0.5
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_panel, "modulate:a", 1.0, 0.25)
