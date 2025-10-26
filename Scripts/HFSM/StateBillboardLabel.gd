extends Label3D
class_name StateBillboardLabel

@export var state_machine_path: NodePath

var sm: StateMachine

func _ready():
	if state_machine_path != NodePath():
		sm = get_node(state_machine_path)
	else:
		sm = get_parent().get_node("HFSM")
	text = sm.current_state_name()
	sm.state_changed.connect(_on_state_changed)

func _process(_dt):
	var cam := get_viewport().get_camera_3d()
	if cam:
		look_at(cam.global_transform.origin, Vector3.UP)
		rotate_y(PI)

func _on_state_changed(_from, to):
	text = to
