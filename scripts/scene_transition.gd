extends CanvasLayer

var fade_duration: float = 0.8
var is_transitioning: bool = false
var overlay: ColorRect


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS  # tetap jalan walau game di-pause

	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)


func change_scene(scene_path: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true

	# Blok input selama transisi
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var fade_out := create_tween()
	fade_out.tween_property(overlay, "color:a", 1.0, fade_duration)
	await fade_out.finished

	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Gagal membuka scene: " + scene_path)
		await fade_in()
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		is_transitioning = false
		return

	# Tunggu scene baru benar-benar terpasang (+ _ready selesai) dan tergambar
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	await fade_in()

	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false


func fade_in() -> void:
	var fade := create_tween()
	fade.tween_property(overlay, "color:a", 0.0, fade_duration * 1.3)
	await fade.finished
