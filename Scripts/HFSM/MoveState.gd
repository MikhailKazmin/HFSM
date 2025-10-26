extends State
class_name TravelState

func enter(_msg = null):
	anim_player.play("Running_A")
	var eyes := machine.get_capability(EyeColorCapability)
	if eyes:
		eyes.set_color(Color(0.2, 0.6, 1.0))

func physics(delta):
	var mv := machine.get_capability(MovementCapability)
	if not mv:
		machine.route_idle_by_selection()
		return
	mv.step(delta)
	if mv.is_finished():
		mv.clear_target()
		machine.route_idle_by_selection()
