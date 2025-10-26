extends Node
class_name State

var machine: StateMachine
var unit: Minion
var anim_player: AnimationPlayer

func setup(u: Minion, m: StateMachine) -> void:
	unit = u
	machine = m
	anim_player = u.anim_player

func enter(_msg = null) -> void:
	pass

func exit() -> void:
	pass

func physics(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func on_target_set() -> void:
	pass

func on_move_order() -> void:
	pass

func on_selected() -> void:
	pass

func on_deselected() -> void:
	pass

func request(state_name: String, msg = null) -> void:
	machine.transition_to(state_name, msg)
