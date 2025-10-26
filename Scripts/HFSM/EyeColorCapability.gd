extends Capability
class_name EyeColorCapability

@export var eye_mesh_path: NodePath
@export var eye_name_hint: String = "eyes"
@export var search_root_path: NodePath = NodePath("Rig")

var mesh: MeshInstance3D
var mats: Array[BaseMaterial3D] = []

func setup(u: Minion, m: StateMachine) -> void:
	super.setup(u, m)
	mesh = _resolve_eye_mesh(u)
	_prepare_override_materials()

func set_color(c: Color) -> void:
	if mats.is_empty():
		_prepare_override_materials()
	for mat in mats:
		if mat:
			mat.emission_enabled = true
			mat.albedo_color = c
			mat.emission = c

func _resolve_eye_mesh(unit: Node) -> MeshInstance3D:
	if eye_mesh_path != NodePath():
		var n := unit.get_node_or_null(eye_mesh_path)
		if n is MeshInstance3D:
			return n
	for g in unit.get_tree().get_nodes_in_group("eyes"):
		if g is MeshInstance3D and unit.is_ancestor_of(g):
			return g
	var root := unit.get_node_or_null(search_root_path)
	if root == null:
		root = unit
	var lower_hint := eye_name_hint.to_lower()
	var found := _dfs_find_mesh(root, func(mi: MeshInstance3D) -> bool:
		return mi.name.to_lower().find(lower_hint) >= 0
	)
	if found:
		return found
	return _dfs_find_mesh(root, func(_mi: MeshInstance3D) -> bool: return true)

func _dfs_find_mesh(n: Node, pred: Callable) -> MeshInstance3D:
	if n is MeshInstance3D and bool(pred.call(n)):
		return n
	for c in n.get_children():
		var r := _dfs_find_mesh(c, pred)
		if r:
			return r
	return null

func _prepare_override_materials() -> void:
	mats.clear()
	if not (mesh and mesh.mesh):
		return
	var sc := mesh.mesh.get_surface_count()
	for i in range(sc):
		var mat := mesh.get_surface_override_material(i)
		if mat == null:
			var src := mesh.mesh.surface_get_material(i)
			if src is BaseMaterial3D:
				mat = (src as BaseMaterial3D).duplicate(true)
			else:
				mat = StandardMaterial3D.new()
			mesh.set_surface_override_material(i, mat)
		if mat is BaseMaterial3D:
			mats.append(mat)
