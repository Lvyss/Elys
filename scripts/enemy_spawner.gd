extends Node3D

@export var goblin_scene: PackedScene
@export var stats_lv1: GoblinStats
@export var stats_lv2: GoblinStats
@export var stats_boss: GoblinStats

const MAX_GROUND_Y := 0.3     # lebih tinggi dari ini dianggap tebing/pohon, bukan tanah
const SEARCH_ATTEMPTS := 40


func _ready() -> void:
	# tunggu collision tebing/pohon terdaftar di physics
	await get_tree().physics_frame
	await get_tree().physics_frame

	var spawns := [
		{"name": "GoblinLv1_A", "stats": stats_lv1, "pos": Vector3(5.5, 0, 5.0)},
		{"name": "GoblinLv1_B", "stats": stats_lv1, "pos": Vector3(7.0, 0, 2.5)},
		{"name": "GoblinLv2_A", "stats": stats_lv2, "pos": Vector3(-3.5, 0, -5.0)},
		{"name": "GoblinLv2_B", "stats": stats_lv2, "pos": Vector3(-5.5, 0, -3.0)},
		{"name": "GoblinLv2_C", "stats": stats_lv2, "pos": Vector3(-7.5, 0, -3.5)},
		{"name": "GoblinBoss", "stats": stats_boss, "pos": Vector3(-6.5, 0, 4.5)},
	]

	for s in spawns:
		_spawn(s["name"], s["stats"], s["pos"])


func _spawn(goblin_name: String, stats: GoblinStats, wanted: Vector3) -> void:
	var radius := 0.5 * stats.size_scale + 0.2
	var pos = _find_free_spot(wanted, radius)
	if pos == null:
		push_warning("%s: tidak ada titik aman dekat %s, geser angkanya" % [goblin_name, wanted])
		return
	var g := goblin_scene.instantiate()
	g.name = goblin_name
	g.stats = stats
	g.position = pos          # set sebelum add_child supaya 'home' benar
	add_child(g)


func _find_free_spot(center: Vector3, radius: float):
	var space := get_world_3d().direct_space_state
	var shape := SphereShape3D.new()
	shape.radius = radius

	for i in SEARCH_ATTEMPTS:
		# percobaan pertama tepat di titik, berikutnya melebar pelan-pelan
		var spread := 0.0 if i == 0 else 0.3 + i * 0.15
		var ang := randf() * TAU
		var x := center.x + cos(ang) * spread
		var z := center.z + sin(ang) * spread

		# tetap di dalam arena 18x18
		if absf(x) > 8.0 or absf(z) > 8.0:
			continue

		# 1) cari tinggi tanah dengan raycast dari atas
		var ray := PhysicsRayQueryParameters3D.create(Vector3(x, 10, z), Vector3(x, -2, z))
		var hit := space.intersect_ray(ray)
		if hit.is_empty() or hit.position.y > MAX_GROUND_Y:
			continue          # kena tebing/pohon/batu, bukan tanah datar

		# 2) cek ruang kosong di sekeliling (bola sedikit di atas tanah)
		var q := PhysicsShapeQueryParameters3D.new()
		q.shape = shape
		q.transform = Transform3D(Basis.IDENTITY, Vector3(x, hit.position.y + radius + 0.1, z))
		q.collision_mask = 1
		if space.intersect_shape(q, 1).is_empty():
			return Vector3(x, hit.position.y + 0.1, z)

	return null
