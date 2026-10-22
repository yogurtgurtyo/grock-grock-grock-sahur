extends Button

# Assign the Marker2D/Node2D representing the spawn point in the target room
@export var target_spawn_point: Node2D

func _ready() -> void:
	# Connect the button's built-in pressed signal to our function
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if target_spawn_point == null:
		push_warning("Target spawn point is not assigned on " + name)
		return
	
	# Find the player in the scene using the "Player" group
	var player = get_tree().get_first_node_in_group("Player")
	
	if player != null and player is Node2D:
		# Instantly move the player to the target spawn position
		player.global_position = target_spawn_point.global_position
	else:
		push_warning("Could not find a valid Node2D player in the 'Player' group.")
