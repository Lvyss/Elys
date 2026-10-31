@tool
extends Node3D

# Bagian bawah pohon yang diberi collision (0.25 = 25% tinggi total)
@export_range(0.05, 1.0, 0.01) var cut_fraction: float = 0.25
# Lebar batang diukur dari titik di dasar pohon, lalu dikali angka ini.
# Kecilkan kalau cabang masih ikut, besarkan kalau batang terpotong.
@export_range(0.5, 2.0, 0.05) var trunk_margin: float = 1.05
# Bagian dasar yang dipakai untuk mengukur lebar batang (0.1 = 10% tinggi)
@export_range(0.02, 0.5, 0.01) var measure_fraction: float = 0.08

@export_tool_button("Generate Trunk Collision") var generate_btn = _generate
@export_tool_button("Clear Collision") var clear_btn = _clear

func _find_meshes(n: Node, out: Array) -> Array:
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children(true):
		if not (c is StaticBody3D):
			_find_meshes(c, out)
	return out

func _clear() -> void:
	var count := 0
	for c in get_children():
		if c is StaticBody3D and (str(c.name).begins_with("TrunkCol_") or str(c.name).begins_with("AutoCol_")):
			remove_child(c)
			c.free()
			count += 1
	print("[TrunkCol] ", name, ": dihapus ", count)

func _generate() -> void:
	_clear()
	var root := get_tree().edited_scene_root
	if root == null:
		return
	var to_local := global_transform.affine_inverse()
	var made := 0
	for tree in get_children():
		if tree is StaticBody3D or not (tree is Node3D):
			continue
		var origin: Vector3 = (to_local * tree.global_transform).origin
		var all_pts := PackedVector3Array()
		for mi in _find_meshes(tree, []):
			if mi.mesh == null:
				continue
			var base = mi.mesh.create_convex_shape(false, false)
			if base == null:
				continue
			var xf: Transform3D = to_local * mi.global_transform
			for p in base.points:
				all_pts.append(xf * p)
		if all_pts.size() < 4:
			print("[TrunkCol] ", tree.name, ": tidak ada mesh")
			continue
		var min_y := INF
		var max_y := -INF
		for p in all_pts:
			min_y = minf(min_y, p.y)
			max_y = maxf(max_y, p.y)
		var h := max_y - min_y

		# 1) ukur lebar batang dari titik di dasar saja
		var measure_y := min_y + h * measure_fraction
		var base_r := 0.0
		for p in all_pts:
			if p.y <= measure_y:
				base_r = maxf(base_r, Vector2(p.x - origin.x, p.z - origin.z).length())
		var limit_r := base_r * trunk_margin

		# 2) ambil bagian bawah, buang titik di luar lebar batang (cabang)
		var cut_y := min_y + h * cut_fraction
		var pts := PackedVector3Array()
		for p in all_pts:
			if p.y > cut_y:
				continue
			if Vector2(p.x - origin.x, p.z - origin.z).length() > limit_r:
				continue
			pts.append(p)
		print("[TrunkCol] ", tree.name, ": radius dasar ", snappedf(base_r, 0.01), " titik dipakai ", pts.size(), "/", all_pts.size())
		if pts.size() < 4:
			continue
		var body := StaticBody3D.new()
		body.name = "TrunkCol_" + str(tree.name)
		body.collision_layer = 1
		add_child(body)
		body.owner = root
		var shape := ConvexPolygonShape3D.new()
		shape.points = pts
		var cs := CollisionShape3D.new()
		cs.shape = shape
		body.add_child(cs)
		cs.owner = root
		made += 1
	print("[TrunkCol] ", name, ": dibuat untuk ", made, " pohon")
