extends Node
class_name ResourceHover

@export var presenter_path: NodePath
var presenter: OutlinePresenter

func _ready() -> void:
	if presenter_path != NodePath():
		presenter = get_node_or_null(presenter_path)
	_apply_hover(false)

func set_hovered(v: bool) -> void:
	_apply_hover(v)

func _apply_hover(v: bool) -> void:
	if presenter:
		presenter.set_enabled(true)
		presenter.set_hovered(v)
