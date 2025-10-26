extends Capability
class_name MovementCapability

@export var move_speed: float = 4.0
@export var turn_speed: float = 10.0
@export var arrive_distance: float = 0.6

var target_position: Vector3
var has_target := false
var agent: NavigationAgent3D

func setup(u: Minion, m: StateMachine):
	super.setup(u, m)
	agent = u.get_node("NavigationAgent3D")

func set_move_target(p: Vector3):
	target_position = p
	agent.target_position = p
	has_target = true

func clear_target():
	has_target = false

func is_moving() -> bool:
	return has_target and not agent.is_navigation_finished()

func is_finished() -> bool:
	return agent.is_navigation_finished()

func step(delta: float):
	if agent.is_navigation_finished():
		unit.velocity = Vector3.ZERO
		unit.move_and_slide()
		return
	var next := agent.get_next_path_position()
	var dir := (next - unit.global_transform.origin)
	var flat := Vector3(dir.x, 0.0, dir.z).normalized()
	if flat.length() > 0.0001:
		var yaw := atan2(flat.x, flat.z)
		unit.rotation.y = lerp_angle(unit.rotation.y, yaw, clamp(turn_speed * delta, 0.0, 1.0))
	unit.velocity = flat * move_speed
	unit.move_and_slide()

func stop():
	unit.velocity = Vector3.ZERO
	unit.move_and_slide()
