@tool
extends Node3D

# Mesh dengan kata ini di namanya diabaikan (lingkaran rune, dekor datar, dll.)
@export var skip_keywords: PackedStringArray = ["Rune", "Ring", "Circle", "Glow"]
# Box dikecilkan sedikit di lebar/dalam supaya hero tidak "nyangkut" di tepi
@export_range(0.5, 1.0, 0.01) var shrink_xz: float = 0.85

@export_tool_button("Generate Box Collision") var gen_btn = generate
@export_tool_button("Clear Collision") var clear_btn = clear


func clear() -> void:
	# Hapus collision lama yang berat (AutoCol_...) di seluruh isi Altar
	for n in find_children("AutoCol*", "", true, false):
		n.get_parent().remove_child(n)
		n.free()
	# Hapus hasil skrip ini
	for n in find_children("SimpleCol", "", true, false):
		n.get_parent().remove_child(n)
		n.free()


func _skip(m: Node) -> bool:
	for k in skip_keywords:
		if String(m.name).containsn(k):
			return true
	return false


func generate() -> void:
	clear()
	var root := get_tree().edited_scene_root
	var count := 0

	for stone in get_children():
		if not (stone is Node3D):
			continue

		# Gabungkan AABB semua mesh di dalam batu, dalam ruang lokal batu
		var merged := AABB()
		var has := false
		var inv := (stone as Node3D).global_transform.affine_inverse()

		for m in stone.find_children("*", "MeshInstance3D", true, false):
			var mi := m as MeshInstance3D
			if mi.mesh == null or _skip(mi):
				continue
			var a: AABB = (inv * mi.global_transform) * mi.mesh.get_aabb()
			if has:
				merged = merged.merge(a)
			else:
				merged = a
				has = true

		if not has:
			continue

		var shape := BoxShape3D.new()
		shape.size = Vector3(merged.size.x * shrink_xz, merged.size.y, merged.size.z * shrink_xz)

		var cs := CollisionShape3D.new()
		cs.name = "SimpleCol"
		cs.shape = shape
		cs.position = merged.get_center()

		# Kalau batu sudah StaticBody3D, shape langsung ditempel. Kalau belum, dibuatkan body.
		if stone is CollisionObject3D:
			stone.add_child(cs)
			cs.owner = root
		else:
			var body := StaticBody3D.new()
			body.name = "SimpleCol"
			body.collision_layer = 1
			body.collision_mask = 1
			stone.add_child(body)
			body.owner = root
			body.add_child(cs)
			cs.owner = root
		count += 1

	print("Box collision dibuat untuk ", count, " batu")
