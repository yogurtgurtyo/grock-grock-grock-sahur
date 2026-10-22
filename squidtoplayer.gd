extends CharacterBody2D  # Change to "extends Node2D" if you are not using physics/collisions

@export var move_speed: float = 120.0     # Speed at which the squid moves toward the player
@export var stop_distance: float = 100.0   # Stops moving when this close to give tentacles room to reach

var player: Node2D

func _physics_process(delta: float) -> void:
	# Locate player in the "player" group if reference is missing
	if not is_instance_valid(player):
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0] as Node2D
		else:
			velocity = Vector2.ZERO
			return

	var distance_to_player := global_position.distance_to(player.global_position)

	# Move toward player if outside stop_distance
	if distance_to_player > stop_distance:
		var direction := (player.global_position - global_position).normalized()
		
		# For CharacterBody2D:
		velocity = direction * move_speed
		move_and_slide()
		
		# If using Node2D instead, replace the two lines above with:
		# global_position += direction * move_speed * delta
	else:
		velocity = Vector2.ZERO
