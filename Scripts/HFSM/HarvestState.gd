extends State
class_name HarvestState

var running := false
var interrupted := false

func enter(_msg = null):
	var mv := machine.get_capability(MovementCapability)
	if mv:
		mv.stop()
	var eyes := machine.get_capability(EyeColorCapability)
	if eyes:
		eyes.set_color(Color(0.2, 1.0, 0.2))
	interrupted = false
	var cap := machine.get_capability(HarvestCapability)
	if not cap or not cap.current_target():
		machine.route_idle_by_selection()
		return
	if running:
		return
	_start_harvest()

func exit():
	interrupted = true

func on_move_order():
	interrupted = true
	request("Travel")

func physics(delta):
	var cap := machine.get_capability(HarvestCapability)
	if not cap or not cap.current_target():
		return
	var to = cap.current_target().global_transform.origin - unit.global_transform.origin
	to.y = 0.0
	to = to.normalized()
	if to.length() > 0.0001:
		var yaw := atan2(to.x, to.z)
		unit.rotation.y = lerp_angle(unit.rotation.y, yaw, 0.5)

func _anim_len() -> float:
	return unit.anim_player.get_animation("1H_Melee_Attack_Chop").length

func _hit_time() -> float:
	return _anim_len() * 0.4

func _start_harvest() -> void:
	running = true
	await _do_hits()
	running = false
	if interrupted:
		return
	machine.route_idle_by_selection()

func _do_hits() -> void:
	var i := 0
	while i < 5:
		var cap := machine.get_capability(HarvestCapability)
		if interrupted or not cap or not cap.current_target():
			break
		unit.anim_player.play("1H_Melee_Attack_Chop")
		var hit_timer := get_tree().create_timer(_hit_time())
		await hit_timer.timeout
		if interrupted or not cap.current_target():
			break
		cap.current_target().take_damage(1)
		var rest_timer := get_tree().create_timer(max(0.0, _anim_len() - _hit_time()))
		await rest_timer.timeout
		i += 1
