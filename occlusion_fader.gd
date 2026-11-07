extends Node

@export var roots: Array[Node3D]
@export_range(0.0, 1.0) var faded_alpha := 0.25   # 1 = solid, 0 = hilang total
@export var fade_speed := 8.0
@export var look_height := 1.0
@export var margin := 0.0                         # untuk saringan kasar AABB
@export_range(0.1, 1.0) var radius_factor := 0.35 # kecil = lebih ketat (hanya batang)
@export var min_radius := 0.4                     # radius silinder minimal
@export_range(0.5, 1.0) var end_fraction := 0.9   # garis berhenti sebelum hero
@export var sample_step := 0.25                   # jarak antar titik cek (meter)

var _meshes: Array[MeshInstance3D] = []
var _state := {}   # mesh -> {"alpha": float, "mats": Array}


func _ready() -> void:
	await get_tree().process_frame
	collect()


func collect() -> void:
	_meshes.clear()
	_state.clear()
	for n in roots:
		if n == null:
			continue
		if n is MeshInstance3D:
			_meshes.append(n)
		for m in n.find_children("*", "MeshInstance3D", true, false):
			_meshes.append(m)
	print("[OcclusionFader] mesh terdaftar: ", _meshes.size())


func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if cam == null or player == null:
		return

	var from := cam.global_position
	var to := player.global_position + Vector3(0, look_height, 0)

	for m in _meshes:
		if not is_instance_valid(m) or m.mesh == null or not m.is_visible_in_tree():
			continue

		var box: AABB = m.global_transform * m.get_aabb()
		var blocking := _blocks(box, from, to)

		var st = _state.get(m)
		if st == null:
			if not blocking:
				continue
			st = {"alpha": 1.0, "mats": _make_fade_materials(m)}
			_state[m] = st

		var goal := faded_alpha if blocking else 1.0
		var a: float = lerpf(st["alpha"], goal, 1.0 - exp(-fade_speed * delta))
		if absf(a - goal) < 0.01:
			a = goal
		st["alpha"] = a

		if a >= 1.0:
			_restore(m)
			_state.erase(m)
		else:
			for mat in st["mats"]:
				mat.albedo_color.a = a


# Tahap 1: saringan AABB (murah). Tahap 2: cek silinder tegak di sumbu pohon.
func _blocks(box: AABB, from: Vector3, to: Vector3) -> bool:
	if box.grow(margin).intersects_segment(from, to) == null:
		return false

	var c := box.get_center()
	var r := maxf(maxf(box.size.x, box.size.z) * 0.5 * radius_factor, min_radius)
	var y_min := box.position.y
	var y_max := box.end.y

	var seg_len := from.distance_to(to) * end_fraction
	var steps := maxi(int(seg_len / sample_step), 2)
	var end := from.lerp(to, end_fraction)

	for i in steps + 1:
		var p := from.lerp(end, float(i) / steps)
		if p.y < y_min or p.y > y_max:
			continue
		var dx := p.x - c.x
		var dz := p.z - c.z
		if dx * dx + dz * dz <= r * r:
			return true
	return false


func _make_fade_materials(m: MeshInstance3D) -> Array:
	var out := []
	for i in m.mesh.get_surface_count():
		var src := m.get_active_material(i)
		var copy: BaseMaterial3D
		if src is BaseMaterial3D:
			copy = src.duplicate()
		else:
			copy = StandardMaterial3D.new()
		copy.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		copy.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.set_surface_override_material(i, copy)
		out.append(copy)
	return out


func _restore(m: MeshInstance3D) -> void:
	for i in m.mesh.get_surface_count():
		m.set_surface_override_material(i, null)
