extends Node3D
class_name ResourceHarvestable
@onready var label_3d: Label3D = $Label3D

signal died

@export var health := 5

func take_damage(amount: int) -> void:
	health -= amount
	label_3d.text = var_to_str(health) 
	if health <= 0:
		emit_signal("died")
		queue_free()
