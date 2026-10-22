extends Node2D

@export_category("Reach & Tracking")
@export var max_reach: float = 350.0
@export var tracking_speed: float = 6.0

@export_category("Idle Wiggle (When no player)")
@export var enable_idle_wiggle: bool = true
@export var wiggle_speed: float = 2.0
@export var wiggle_amplitude: float = 40.0

@onready var ik_target: Node2D = $IKTarget

var player: Node2D

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0] as Node2D

	var target_local_pos := _get_target_local_position()

	# Smoothly move IKTarget using local position
	ik_target.position = ik_target.position.lerp(target_local_pos, tracking_speed * delta)


func _get_target_local_position() -> Vector2:
	if is_instance_valid(player):
		# to_local() converts the player's world position into local coordinates relative to the squid
		var local_player_pos := to_local(player.global_position)
		
		# Clamp reach distance relative to squid center (0, 0)
		return local_player_pos.limit_length(max_reach)

	# Idle wiggle in local space
	if enable_idle_wiggle:
		var time := Time.get_ticks_msec() * 0.001 * wiggle_speed
		return Vector2(
			cos(time) * wiggle_amplitude,
			sin(time * 1.5) * wiggle_amplitude + (max_reach * 0.5)
		)

	return Vector2.ZERO # (0, 0) in local space
