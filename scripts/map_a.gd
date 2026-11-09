extends Node3D # atau Node2D, sesuaikan dengan root scene map-mu

@onready var player = $Player # Pastikan path ke node Player benar
@onready var hp_label = $CanvasLayer/HealthLabel

func _ready() -> void:
	# Hubungkan sinyal dari player ke fungsi di map
	player.health_changed.connect(_on_player_health_changed)
	
	# Set teks HP awal saat game baru dimulai
	hp_label.text = "HP: %d / %d" % [player.hp, player.max_hp]

func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	# Update teks setiap kali player kena damage
	hp_label.text = "HP: %d / %d" % [current_hp, max_hp]
	
	# (Opsional) Bikin teks HP berkedip merah sebentar kalau kena hit
	var tween = create_tween()
	hp_label.modulate = Color.RED
	tween.tween_property(hp_label, "modulate", Color.WHITE, 0.3)
