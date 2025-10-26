extends Camera3D
class_name SelectionController

@export var move_speed: float = 10.0
@export var mouse_sens: float = 0.08
@export var rotation_smooth_time: float = 0.06
@export var max_ray_length: float = 1000.0
@export var formation_spacing: float = 2.0
@export var hover_hz: float = 30.0
@export var ray_mask: int = -1  # все слои

var yaw: float = 0.0
var pitch: float = 0.0
var target_yaw: float = 0.0
var target_pitch: float = 0.0
var _rot_vel: Vector2 = Vector2.ZERO
var _hover_acc: float = 0.0

var hovered_unit: Minion
var hovered_resource: ResourceHarvestable
var selected_units: Array[Minion] = []

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		target_yaw -= mm.relative.x * mouse_sens * 0.01
		target_pitch -= mm.relative.y * mouse_sens * 0.01
		target_pitch = clamp(target_pitch, -1.4, 1.4)
	if event is InputEventMouseButton and event.pressed:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_on_left_click(mb)
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			_on_right_click()

func _process(delta: float) -> void:
	var r: Vector2 = _smooth_damp_vec2(Vector2(yaw, pitch), Vector2(target_yaw, target_pitch), delta)
	yaw = r.x
	pitch = r.y
	var t: Transform3D = global_transform
	var b: Basis = Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch)
	t.basis = b.orthonormalized()
	global_transform = t
	_hover_acc += delta
	if _hover_acc >= 1.0 / max(1.0, hover_hz):
		_hover_acc = 0.0
		_update_hover()

func _physics_process(delta: float) -> void:
	var dir: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir -= global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		dir += global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += global_transform.basis.x
	if Input.is_action_pressed("move_up"):
		dir += Vector3.UP
	if Input.is_action_pressed("move_down"):
		dir -= Vector3.UP
	if dir != Vector3.ZERO:
		global_translate(dir.normalized() * move_speed * delta)

func _smooth_damp_vec2(current: Vector2, target: Vector2, delta: float) -> Vector2:
	var omega: float = 2.0 / max(0.0001, rotation_smooth_time)
	var x: float = omega * delta
	var exp: float = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change: Vector2 = current - target
	var temp: Vector2 = (_rot_vel + change * omega) * delta
	_rot_vel = (_rot_vel - temp * omega) * exp
	return target + (change + temp) * exp

func _center_ray() -> Dictionary:
	var c: Vector2 = get_viewport().size * 0.5
	var from: Vector3 = project_ray_origin(c)
	var n: Vector3 = project_ray_normal(c)
	var to: Vector3 = from + n * max_ray_length
	return {"from": from, "to": to}

func _ray_pick() -> Node:
	var r: Dictionary = _center_ray()
	var from: Vector3 = r["from"]
	var to: Vector3 = r["to"]
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collide_with_bodies = true
	q.collide_with_areas = true     # было false
	q.collision_mask = ray_mask     # явная маска
	var hit: Dictionary = space.intersect_ray(q)
	if not hit.has("collider"):
		return null
	return hit.collider

func _find_root_minion(node: Node) -> Minion:
	var n: Node = node
	while n and not (n is Minion):
		n = n.get_parent()
	return n as Minion

func _find_root_resource(node: Node) -> ResourceHarvestable:
	var n: Node = node
	while n and not (n is ResourceHarvestable):
		n = n.get_parent()
	return n as ResourceHarvestable

func _update_hover() -> void:
	var col: Node = _ray_pick()

	var new_unit: Minion = _find_root_minion(col) if col != null else null
	var new_res: ResourceHarvestable = _find_root_resource(col) if col != null else null

	# сброс прошлых ховеров, если цель изменилась или ничего не под прицелом
	if hovered_unit and hovered_unit != new_unit:
		var prev_ucap: SelectionCapability = hovered_unit.machine.get_capability(SelectionCapability)
		if prev_ucap: prev_ucap.set_hovered(false)
		hovered_unit = null
	if hovered_resource and hovered_resource != new_res:
		var prev_rp: OutlinePresenter = hovered_resource.get_node_or_null("OutlinePresenter")
		if prev_rp: prev_rp.set_hovered(false)
		hovered_resource = null

	# приоритет: юнит, иначе ресурс
	if new_unit:
		var ucap: SelectionCapability = new_unit.machine.get_capability(SelectionCapability)
		if ucap and ucap.is_selectable():
			hovered_unit = new_unit
			ucap.set_hovered(true)
			return
	# если юнит не подходит, пробуем ресурс
	if new_res and hovered_unit == null:
		var rp: OutlinePresenter = new_res.get_node_or_null("OutlinePresenter")
		if rp:
			hovered_resource = new_res
			rp.set_hovered(true)
	else:
		# если ничего не под прицелом — гасим текущие
		if hovered_unit:
			var ucap2: SelectionCapability = hovered_unit.machine.get_capability(SelectionCapability)
			if ucap2: ucap2.set_hovered(false)
			hovered_unit = null
		if hovered_resource:
			var rp2: OutlinePresenter = hovered_resource.get_node_or_null("OutlinePresenter")
			if rp2: rp2.set_hovered(false)
			hovered_resource = null



func _on_left_click(event: InputEventMouseButton) -> void:
	var add: bool = event.ctrl_pressed
	var col: Node = _ray_pick()
	var m: Minion = _find_root_minion(col) if col != null else null

	if m == null:
		_clear_selection()
		return
	if add:
		if selected_units.has(m):
			_deselect(m)
		else:
			_select(m, true)
	else:
		_clear_selection()
		_select(m, true)

func _on_right_click() -> void:
	if selected_units.is_empty():
		return
	var r: Dictionary = _center_ray()
	var from: Vector3 = r["from"]
	var to: Vector3 = r["to"]
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collide_with_areas = false
	q.collide_with_bodies = true
	var hit: Dictionary = space.intersect_ray(q)
	if not hit.has("position"):
		return
	var point: Vector3 = hit.position
	if selected_units.size() == 1:
		selected_units[0].issue_move_order(point)
		return
	var right: Vector3 = global_transform.basis.x.normalized()
	var count: int = selected_units.size()
	var start: float = -0.5 * float(count - 1) * formation_spacing
	for i in range(count):
		var u: Minion = selected_units[i]
		var pos: Vector3 = point + right * (start + float(i) * formation_spacing)
		u.issue_move_order(pos)

func _select(m: Minion, hover_off: bool) -> void:
	if not selected_units.has(m):
		selected_units.append(m)
	var selcap: SelectionCapability = m.machine.get_capability(SelectionCapability)
	if selcap:
		selcap.set_selected(true)
	if hover_off and selcap:
		selcap.set_hovered(false)

func _deselect(m: Minion) -> void:
	if selected_units.has(m):
		selected_units.erase(m)
	var selcap: SelectionCapability = m.machine.get_capability(SelectionCapability)
	if selcap:
		selcap.set_selected(false)

func _clear_selection() -> void:
	for u in selected_units:
		var selcap: SelectionCapability = u.machine.get_capability(SelectionCapability)
		if selcap:
			selcap.set_selected(false)
	selected_units.clear()
