extends State
class_name Idle_Unselected

func enter(_msg = null):
	anim_player.play("Sit_Floor_Idle")
	var mv := machine.get_capability(MovementCapability)
	if mv:
		mv.stop()
	var eyes := machine.get_capability(EyeColorCapability)
	if eyes:
		eyes.set_color(Color.WHITE)

func on_selected():
	request("SitStandUp")
