extends Capability
class_name HarvestCapability

@export var detection_radius: float = 12.0
@export var interact_distance: float = 1.4

var resource_target: ResourceHarvestable

func acquire_target(res: ResourceHarvestable):
	if resource_target and resource_target != res:
		if resource_target.died.is_connected(_on_resource_died):
			resource_target.died.disconnect(_on_resource_died)
	resource_target = res
	if res and not res.died.is_connected(_on_resource_died):
		res.died.connect(_on_resource_died, CONNECT_ONE_SHOT)

func clear_target():
	if resource_target and resource_target.died.is_connected(_on_resource_died):
		resource_target.died.disconnect(_on_resource_died)
	resource_target = null

func current_target() -> ResourceHarvestable:
	return resource_target

func find_nearest() -> ResourceHarvestable:
	var best: ResourceHarvestable
	var best_d := INF
	var origin := unit.global_transform.origin
	for n in get_tree().get_nodes_in_group("Harvestable"):
		if not (n is ResourceHarvestable):
			continue
		var d := origin.distance_to(n.global_transform.origin)
		if d <= detection_radius and d < best_d:
			best_d = d
			best = n
	return best

func _on_resource_died():
	resource_target = null
