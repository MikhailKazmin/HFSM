extends Node
class_name StateMachine

signal state_changed(from_state: String, to_state: String)

@export var initial_state: String = "Emerge"

var unit: Minion
var states := {}
var current_state: State

func _ready():
	for c in get_children():
		if c is State:
			states[c.name] = c

func bind_unit(u: Minion):
	unit = u
	for s in states.values():
		s.setup(u, self)
	var caps := get_node("../Capabilities")
	if caps:
		for c in caps.get_children():
			if c is Capability:
				c.setup(u, self)
	transition_to(initial_state)

func get_capability(cls) -> Capability:
	var caps := get_node_or_null("../Capabilities")
	if caps == null:
		return null
	for c in caps.get_children():
		if c is Capability and is_instance_of(c, cls):
			return c
	return null

func route_move_order(p: Vector3):
	var mv := get_capability(MovementCapability)
	if mv:
		mv.set_move_target(p)
	if current_state:
		current_state.on_move_order()

func notify_target_set():
	if current_state:
		current_state.on_target_set()

func notify_selected():
	if current_state:
		current_state.on_selected()

func notify_deselected():
	if current_state:
		current_state.on_deselected()

func is_selected() -> bool:
	var sel := get_capability(SelectionCapability)
	return sel != null and sel.selected

func go_idle_selected():
	transition_to("Idle")

func go_idle_unselected():
	transition_to("SitDown")

func route_idle_by_selection():
	if is_selected():
		go_idle_selected()
	else:
		go_idle_unselected()

func transition_to(name: String, msg = null):
	var from_name := ""
	if current_state:
		from_name = current_state.name
		current_state.exit()
	current_state = states.get(name)
	if current_state:
		current_state.enter(msg)
	emit_signal("state_changed", from_name, name)

func _physics_process(delta):
	if current_state:
		current_state.physics(delta)

func _unhandled_input(event):
	if current_state:
		current_state.input(event)

func current_state_name() -> String:
	return current_state.name if current_state else ""
