extends Area2D
class_name CameraZone2D

## The Camera2D to enable when entering this zone.
@export var target_camera_to_enable: Camera2D

## Optional: Set to true if the target_camera_to_enable should start enabled.
@export var active_on_start: bool = false

## Name of the group that identifies player/valid entities.
@export var player_group_name: StringName = &"player"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if target_camera_to_enable:
		target_camera_to_enable.enabled = active_on_start
		
	# If active on start, ensure all other cameras match the initial state
	if active_on_start:
		_set_other_cameras_enabled(false)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(player_group_name):
		_switch_cameras(true)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(player_group_name):
		_switch_cameras(false)


func _switch_cameras(entering_zone: bool) -> void:
	if target_camera_to_enable:
		target_camera_to_enable.enabled = entering_zone
		
	# Disable all other cameras when entering; you can customize exit behavior if needed
	if entering_zone:
		_set_other_cameras_enabled(false)


func _set_other_cameras_enabled(state: bool) -> void:
	# Gets the root or tree to search for all Camera2D nodes in the scene
	var all_cameras = get_tree().get_nodes_in_group("cameras") # Alternatively, search the tree or tree root
	
	# If you aren't using a "cameras" group, we can fetch them from the scene tree root:
	var root = get_tree().root
	_recursive_toggle_cameras(root, state)


func _recursive_toggle_cameras(node: Node, state: bool) -> void:
	for child in node.get_children():
		if child is Camera2D and child != target_camera_to_enable:
			child.enabled = state
		if child.get_child_count() > 0:
			_recursive_toggle_cameras(child, state)
