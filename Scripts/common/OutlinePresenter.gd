extends Node
class_name OutlinePresenter

@export var shader: Shader
@export var color: Color = Color(0.2, 0.7, 1.0, 1.0) : set = set_color
@export var width: float = 0.08 : set = set_width
@export var enabled: bool = true : set = set_enabled
@export var mesh_paths: Array[NodePath] = [] : set = set_mesh_paths
@export var root_path: NodePath
@export var debug_force_on: bool = false : set = set_debug_force_on

var _meshes: Array[MeshInstance3D] = []
var _hovered := false
var _selected := false
var _mat: ShaderMaterial

func _ready() -> void:
	_mat = ShaderMaterial.new()
	if shader: _mat.shader = shader
	_mat.set_shader_parameter("outline_color", color)
	_mat.set_shader_parameter("outline_width", width)
	rebuild()
	_update()

func rebuild() -> void:
	_meshes.clear()
	if mesh_paths.size() > 0:
		for p in mesh_paths:
			var n := get_node_or_null(p)
			if n is MeshInstance3D:
				_meshes.append(n)
	else:
		var root := get_node_or_null(root_path)
		if root == null:
			root = get_parent()
		_collect_from(root)
	_update()

func set_mesh_paths(v: Array[NodePath]) -> void:
	mesh_paths = v
	rebuild()

func set_color(v: Color) -> void:
	color = v
	if _mat: _mat.set_shader_parameter("outline_color", color)
	_update()

func set_width(v: float) -> void:
	width = v
	if _mat: _mat.set_shader_parameter("outline_width", width)
	_update()

func set_enabled(v: bool) -> void:
	enabled = v
	_update()

func set_debug_force_on(v: bool) -> void:
	debug_force_on = v
	_update()

func set_hovered(v: bool) -> void:
	_hovered = v
	_update()

func set_selected(v: bool) -> void:
	_selected = v
	_update()

func _collect_from(n: Node) -> void:
	if n is MeshInstance3D:
		_meshes.append(n)
	for c in n.get_children():
		_collect_from(c)

func _apply(active: bool) -> void:
	for m in _meshes:
		if not is_instance_valid(m):
			continue
		# принудительно снимаем и ставим — исключаем «залипание»
		m.material_overlay = null
		if active:
			m.material_overlay = _mat

func _update() -> void:
	var active := debug_force_on or (enabled and (_hovered or _selected))
	_apply(active)
