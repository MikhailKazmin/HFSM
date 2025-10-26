extends State
class_name EmergeState

@export var emerge_depth: float = 1.2
@export var duration: float = 1.0

var start_pos: Vector3
var tween: Tween

func enter(_msg = null):
	var sel := machine.get_capability(SelectionCapability)
	if sel:
		sel.set_selectable(false)
	anim_player.play("Lie_Pose")
	start_pos = unit.global_transform.origin
	unit.global_transform.origin = start_pos - Vector3.UP * emerge_depth
	tween = unit.create_tween()
	tween.tween_property(unit, "global_transform:origin", start_pos, duration)
	tween.finished.connect(_on_done)

func exit():
	if tween and tween.is_running():
		tween.kill()

func _on_done():
	request("StandUp")
