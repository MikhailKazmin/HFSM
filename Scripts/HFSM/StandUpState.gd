extends State
class_name StandUpState

var timer: SceneTreeTimer

func enter(_msg = null):
	anim_player.play("Lie_StandUp")
	var len := anim_player.get_animation("Lie_StandUp").length
	timer = get_tree().create_timer(len)
	timer.timeout.connect(_on_done)

func exit():
	if timer:
		timer.timeout.disconnect(_on_done)

func _on_done():
	var sel := machine.get_capability(SelectionCapability)
	if sel:
		sel.set_selectable(true)
	request("SitDown")
