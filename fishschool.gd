extends CharacterBody2D

@export_category("Fish Settings")
@export var anchor_marker: Marker2D = null
@export var sprite: Sprite2D = null ## Drag your Sprite2D node here
@export var max_speed: float = 160.0
@export var acceleration: float = 250.0
@export var rotation_speed: float = 6.0
@export var max_rotation_degrees: float = 35.0

@export_category("Zones, Awareness & Collection")
@export var max_radius: float = 200.0
@export var player_awareness_radius: float = 250.0 ## Distance at which the fish flees the player
@export var extended_radius: float = 350.0 ## Max leash distance when avoiding the player
@export var collection_radius: float = 30.0 ## Distance at which the player catches the fish
@export var change_target_interval: float = 3.0

var player: Node2D = null
var target_position: Vector2 = Vector2.ZERO
var timer: float = 0.0

func _ready() -> void:
	if not anchor_marker:
		push_warning("Anchor Marker2D is unassigned!")
		return
	
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
		
	global_position = anchor_marker.global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	_pick_new_target()

func _physics_process(delta: float) -> void:
	if not anchor_marker:
		return

	# 1. Player check for awareness
	if not is_instance_valid(player):
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0] as Node2D

	# 2. Check if player collected the fish (Smooth distance check)
	if is_instance_valid(player):
		if global_position.distance_to(player.global_position) <= collection_radius:
			get_tree().call_group("score_ui", "add_score", 1)
			queue_free()
			return

	var player_nearby: bool = false
	if is_instance_valid(player):
		player_nearby = global_position.distance_to(player.global_position) <= player_awareness_radius

	# 3. Target calculation: Flee away from player when nearby, otherwise wander normally
	if player_nearby:
		var flee_dir: Vector2 = (global_position - player.global_position).normalized()
		target_position = global_position + flee_dir * 200.0
	else:
		timer -= delta
		if timer <= 0.0 or global_position.distance_to(target_position) < 15.0:
			_pick_new_target()

	# 4. Acceleration & Movement
	var direction: Vector2 = (target_position - global_position).normalized()
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	move_and_slide()

	# 5. Flipping & Pitch Rotation (Submarine style)
	if velocity.length_squared() > 1.0:
		var facing_dir: int = 1
		if abs(velocity.x) > 10.0:
			facing_dir = 1 if velocity.x > 0 else -1
			if sprite:
				sprite.flip_h = (facing_dir < 0)

		var max_rad: float = deg_to_rad(max_rotation_degrees)
		var target_rotation: float = clamp(velocity.y * 0.005 * facing_dir, -max_rad, max_rad)
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	# 6. Leash boundary check (uses extended radius when player is nearby)
	var active_radius: float = extended_radius if player_nearby else max_radius
	var dist_to_anchor: float = global_position.distance_to(anchor_marker.global_position)
	if dist_to_anchor > active_radius:
		var dir_to_anchor: Vector2 = (anchor_marker.global_position - global_position).normalized()
		global_position = anchor_marker.global_position - (dir_to_anchor * active_radius)
		if not player_nearby:
			_pick_new_target()

func _pick_new_target() -> void:
	timer = change_target_interval
	var angle: float = randf() * TAU
	target_position = anchor_marker.global_position + Vector2(cos(angle), sin(angle)) * randf_range(30.0, max_radius)
