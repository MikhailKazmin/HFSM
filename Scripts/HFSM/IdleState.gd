extends State
class_name IdleState

var tick := 0.0

func enter(_msg = null):
	anim_player.play("Idle")
	var mv := machine.get_capability(MovementCapability)
	if mv:
		mv.stop()
	var eyes := machine.get_capability(EyeColorCapability)
	if eyes:
		eyes.set_color(Color(1.0, 1.0, 0.0))
	tick = 0.0

func physics(delta):
	tick += delta
	if tick >= 2.0:
		tick = 0.0
		var cap := machine.get_capability(HarvestCapability)
		if cap:
			var res = cap.find_nearest()
			if res:
				cap.acquire_target(res)
				request("SeekResource")

func on_move_order():
	var mv := machine.get_capability(MovementCapability)
	if mv and mv.has_target:
		request("Travel")

func on_deselected():
	request("SitDown")
