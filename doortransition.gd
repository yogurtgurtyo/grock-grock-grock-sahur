extends Area2D

# Assign the Marker2D/Node2D representing the spawn point in the target room
@export var target_spawn_point: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if target_spawn_point != null:
			# Instantly move the player to the target spawn position
			body.global_position = target_spawn_point.global_position
		else:
			push_warning("Target spawn point is not assigned on " + name)
