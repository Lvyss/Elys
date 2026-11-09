extends Label3D

func _ready() -> void:
	# Acak arah lompatan: -1 (kiri) atau 1 (kanan)
	var jump_dir := 1.0 if randf() > 0.5 else -1.0
	
	var tween = create_tween().set_parallel(true)
	
	# 1. Melompat ke samping (X) sejauh 1.0 unit
	tween.tween_property(self, "position:x", position.x + (1.0 * jump_dir), 0.6)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	# 2. Sedikit melengkung ke atas (Y) sejauh 0.5 unit
	tween.tween_property(self, "position:y", position.y + 0.5, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 3. Memudar perlahan
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.3)
	
	# Hancurkan diri sendiri setelah selesai
	tween.chain().tween_callback(queue_free)
