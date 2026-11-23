extends MeshInstance3D
## Zona maut kabut: keluar dari kotak half_size (shader) = kena damage besar sampai mati.

## Jarak melewati tepi kotak sebelum damage mulai (meter).
## Kabut mulai tipis di tepi, jadi kasih jeda biar terasa "sudah masuk kabut".
@export var damage_start_offset := 1.5
## Popup peringatan muncul sekian meter SEBELUM zona damage.
@export var warn_distance := 3.0
## Jeda antar tick damage (detik)
@export var tick_interval := 0.4
## Damage per tick sebagai persen HP maksimum: kecil di tepi, besar di bagian dalam
@export_range(0.05, 1.0) var damage_percent_min := 0.15
@export_range(0.05, 1.0) var damage_percent_max := 0.35
## Kedalaman (meter) di mana damage mencapai maksimum
@export var full_damage_depth := 5.0

var _player: Node3D
var _center := Vector2.ZERO
var _half := Vector2(8.5, 8.5)
var _tick := 0.3


func _ready() -> void:
	var mat := get_active_material(0) as ShaderMaterial
	if mat:
		_center = mat.get_shader_parameter("center")
		_half = mat.get_shader_parameter("half_size")
	else:
		push_warning("OuterDarkness: ShaderMaterial tidak ditemukan, pakai nilai default")


func _physics_process(delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Node3D
		return
	if _player.get("is_dead"):
		return

	# >0 = di luar kotak, <0 = di dalam kotak
	var p := Vector2(_player.global_position.x, _player.global_position.z) - _center
	var depth := maxf(absf(p.x) - _half.x, absf(p.y) - _half.y)
	var into_fog := depth - damage_start_offset  # >0 = sudah di zona maut

	# Peringatan saat mendekati kabut
	if into_fog > -warn_distance:
		QuestManager.warn_fog()

	# Damage besar berulang selama di dalam kabut
	if into_fog > 0.0:
		_tick -= delta
		if _tick <= 0.0:
			_tick = tick_interval
			var t := clampf(into_fog / full_damage_depth, 0.0, 1.0)
			var pct := lerpf(damage_percent_min, damage_percent_max, t)
			var dmg := maxi(1, ceili(GameState.hp_max * pct))
			_player.take_damage(dmg, true)
	else:
		_tick = 0.3  # jeda singkat sebelum tick pertama saat masuk kabut
