extends CharacterBody3D
class_name Minion

@onready var anim_player: AnimationPlayer = $Rig/AnimationPlayer
@onready var machine: StateMachine = $HFSM

func _ready():
	machine.bind_unit(self)

func issue_move_order(p: Vector3):
	machine.route_move_order(p)
