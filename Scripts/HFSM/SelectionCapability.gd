extends Capability
class_name SelectionCapability

signal selected_changed(selected: bool)

@export var presenter_path: NodePath

var presenter: OutlinePresenter
var selected := false
var hovered := false
var selectable := false

func setup(u: Minion, m: StateMachine) -> void:
	super.setup(u, m)
	_try_bind_presenter(u)
	_update()

func _try_bind_presenter(u: Node) -> void:
	if presenter_path != NodePath():
		presenter = u.get_node_or_null(presenter_path)
		if presenter: return
	presenter = u.get_node_or_null("OutlinePresenter")
	if presenter: return
	for child in u.get_children():
		presenter = _find_outline_presenter(child)
		if presenter: return

func _find_outline_presenter(n: Node) -> OutlinePresenter:
	if n is OutlinePresenter:
		return n
	for c in n.get_children():
		var r := _find_outline_presenter(c)
		if r: return r
	return null

func set_hovered(v: bool) -> void:
	hovered = v
	_update()

func set_selected(v: bool) -> void:
	if not selectable and v:
		return
	if selected == v:
		return
	selected = v
	selected_changed.emit(selected)
	_update()
	if selected:
		machine.notify_selected()
	else:
		machine.notify_deselected()

func set_selectable(v: bool) -> void:
	selectable = v
	if not selectable:
		selected = false
		hovered = false
	_update()

func is_selected() -> bool: return selected
func is_selectable() -> bool: return selectable

func _update() -> void:
	if presenter:
		var show_hover := hovered and selectable
		presenter.set_enabled(true)
		presenter.set_hovered(show_hover)
		presenter.set_selected(false) # контур НИКОГДА не держим по выбору
