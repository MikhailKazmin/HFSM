extends Control
class_name Crosshair

@export var size_crosshair = 12
@export var thickness = 2
@export var gap = 6

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw():
	var c := get_rect().size * 0.5
	var g := float(gap)
	var s := float(size_crosshair)
	var t := float(thickness)
	draw_line(c + Vector2(-g, 0), c + Vector2(-g - s, 0), Color.RED, t)
	draw_line(c + Vector2(g, 0), c + Vector2(g + s, 0), Color.RED, t)
	draw_line(c + Vector2(0, -g), c + Vector2(0, -g - s), Color.RED, t)
	draw_line(c + Vector2(0, g), c + Vector2(0, g + s), Color.RED, t)

func _process(_dt):
	queue_redraw()
