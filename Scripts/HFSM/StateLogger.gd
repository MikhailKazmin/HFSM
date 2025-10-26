extends Node
class_name StateLogger

@export var state_machine_path: NodePath

var sm: StateMachine
var history: Array = []

func _ready():
	if state_machine_path != NodePath():
		sm = get_node(state_machine_path)
	else:
		sm = get_parent()
	sm.state_changed.connect(_on_state_changed)

func _on_state_changed(from_state: String, to_state: String):
	var line := "[State]: " + from_state + " -> " + to_state
	history.append(line)
	print(line)
