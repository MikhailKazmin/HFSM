extends State
class_name SeekResourceState

func enter(_msg = null):
	anim_player.play("Running_A")
	var eyes := machine.get_capability(EyeColorCapability)
	if eyes:
		eyes.set_color(Color(0.2, 0.6, 1.0))
	var cap := machine.get_capability(HarvestCapability)
	var mv := machine.get_capability(MovementCapability)
	if not cap or not mv or not cap.current_target():
		machine.route_idle_by_selection()
		return
	mv.set_move_target(cap.current_target().global_transform.origin)

func physics(delta):
	var cap := machine.get_capability(HarvestCapability)
	var mv := machine.get_capability(MovementCapability)
	if not cap or not mv or not cap.current_target():
		machine.route_idle_by_selection()
		return
	mv.set_move_target(cap.current_target().global_transform.origin)
	mv.step(delta)
	var pos = cap.current_target().global_transform.origin
	var d := unit.global_transform.origin.distance_to(pos)
	if d <= cap.interact_distance:
		request("Harvest")

func on_move_order():
	var cap := machine.get_capability(HarvestCapability)
	if cap:
		cap.clear_target()
	request("Travel")
