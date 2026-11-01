@tool
extends Node3D

@export_tool_button("Generate Collision") var generate_btn = _generate
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
		if c is StaticBody3D and str(c.name).begins_with("AutoCol_"):
			remove_child(c)
			c.free()
			count += 1
	print("[AutoCol] ", name, ": dihapus ", count)

func _generate() -> void:
	_clear()
	var root := get_tree().edited_scene_root
	if root == null:
		push_warning("[AutoCol] Tidak ada scene yang terbuka")
		return
	var to_local := global_transform.affine_inverse()
	var made_count := 0
	var skipped := 0
	for block in get_children():
		if block is StaticBody3D or not (block is Node3D):
			continue
		var meshes := _find_meshes(block, [])
		if meshes.is_empty():
			skipped += 1
			continue
		var body := StaticBody3D.new()
		body.name = "AutoCol_" + str(block.name)
		body.collision_layer = 1
		add_child(body)
		body.owner = root
		var shapes := 0
		for mi in meshes:
			if mi.mesh == null:
				continue
			var base = mi.mesh.create_convex_shape(true, true)
			if base == null:
				continue
			var xf: Transform3D = to_local * mi.global_transform
			var pts := PackedVector3Array()
			for p in base.points:
				pts.append(xf * p)
			var shape := ConvexPolygonShape3D.new()
			shape.points = pts
			var cs := CollisionShape3D.new()
			cs.shape = shape
			body.add_child(cs)
			cs.owner = root
			shapes += 1
		if shapes > 0:
			made_count += 1
		else:
			remove_child(body)
			body.free()
			skipped += 1
	print("[AutoCol] ", name, ": collision dibuat untuk ", made_count, " objek, dilewati ", skipped)
