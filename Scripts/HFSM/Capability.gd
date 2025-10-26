extends Node
class_name Capability

var unit: Minion
var machine: StateMachine

func setup(u: Minion, m: StateMachine):
	unit = u
	machine = m
