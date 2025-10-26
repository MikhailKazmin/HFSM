extends State
class_name SitStandUp

var timer: SceneTreeTimer
var cancelled: bool = false

func enter(_msg = null):
	cancelled = false
	anim_player.play("Sit_Floor_StandUp")
	var len := anim_player.get_animation("Sit_Floor_StandUp").length
	timer = get_tree().create_timer(len)
	timer.timeout.connect(_on_done)

func exit():
	if timer:
		timer.timeout.disconnect(_on_done)

func on_deselected():
	cancelled = true
	request("SitDown")

func _on_done():
	if cancelled:
		return
	if machine.is_selected():
		request("Idle")
	else:
		request("SitDown")
