@tool
extends Node3D

# Mesh yang di-skip: kata kunci nama induk/mesh, dan nama node persis
@export var skip_keywords: PackedStringArray = ["Door", "Glass", "Knob", "Bolt"]
@export var skip_nodes: PackedStringArray = []   # isi: "Object_7", dst. (atap, tangga)

@export_tool_button("Generate Collision") var gen_btn = generate
@export_tool_button("Clear Collision") var clear_btn = clear

func _should_skip(m: MeshInstance3D) -> bool:
	if String(m.name) in skip_nodes:
		return true
	var n: Node = m
	while n and n != self:
		for k in skip_keywords:
			if String(n.name).containsn(k):
				return true
		n = n.get_parent()
	return false

func clear() -> void:
	for m in find_children("*", "MeshInstance3D", true, false):
		for c in m.get_children():
			if String(c.name).begins_with("AutoCol"):
				c.queue_free()

func generate() -> void:
	clear()
	var root := get_tree().edited_scene_root
	var count := 0
	for m in find_children("*", "MeshInstance3D", true, false):
		var mesh := m as MeshInstance3D
		if mesh.mesh == null or _should_skip(mesh):
			continue
		var body := StaticBody3D.new()
		body.name = "AutoCol_" + String(mesh.name)
		body.collision_layer = 1
		body.collision_mask = 1
		var cs := CollisionShape3D.new()
		cs.shape = mesh.mesh.create_trimesh_shape()
		mesh.add_child(body)
		body.add_child(cs)
		body.owner = root
		cs.owner = root
		count += 1
	print("Collision dibuat untuk ", count, " mesh")
