extends State
class_name SitDown

var timer: SceneTreeTimer

func enter(_msg = null):
	anim_player.play("Sit_Floor_Down")
	var len := anim_player.get_animation("Sit_Floor_Down").length
	timer = get_tree().create_timer(len)
	timer.timeout.connect(_on_done)

func exit():
	if timer:
		timer.timeout.disconnect(_on_done)

func _on_done():
	request("Idle_Unselected")
