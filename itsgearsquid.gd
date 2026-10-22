extends Node2D

@export var segment_distance: float = 24.0 # Distance in pixels between segment centers
@export var segment_nodes: Array[Node2D] = []

var history: Array[Vector2] = []

func _physics_process(_delta: float) -> void:
	# 1. Store the current head position at the front of the history array
	history.push_front(global_position)
	
	# 2. Limit history length to prevent memory leaks
	var max_history: int = (segment_nodes.size() + 1) * 50
	if history.size() > max_history:
		history.pop_back()
	
	# 3. Position and rotate each segment along the recorded trail
	var current_target_dist := segment_distance
	for i in range(segment_nodes.size()):
		var segment := segment_nodes[i]
		var pos_info := _get_point_at_distance(current_target_dist)
		
		segment.global_position = pos_info.position
		segment.rotation = pos_info.angle
		
		current_target_dist += segment_distance

# Helper to find position and rotation at a specific distance back in history
func _get_point_at_distance(target_dist: float) -> Dictionary:
	var accumulated_dist := 0.0
	
	for i in range(history.size() - 1):
		var p1 := history[i]
		var p2 := history[i + 1]
		var dist := p1.distance_to(p2)
		
		if accumulated_dist + dist >= target_dist:
			# Interpolate exact point between history points
			var weight := (target_dist - accumulated_dist) / dist
			var pos := p1.lerp(p2, weight)
			var angle := p1.angle_to_point(p2)
			return {"position": pos, "angle": angle}
			
		accumulated_dist += dist
	
	# Fallback if history isn't long enough yet
	return {"position": history.back() if not history.is_empty() else global_position, "angle": 0.0}
