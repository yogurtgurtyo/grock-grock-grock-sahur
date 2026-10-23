extends CharacterBody2D

# Movement Settings
@export var move_speed: float = 120.0          # Speed during full pursuit
@export var stalk_speed: float = 60.0          # Speed while stalking
@export var retreat_speed: float = 200.0       # Speed when fleeing from a flash
@export var stop_distance: float = 100.0       # Final distance to give tentacles room

# AI & Flash Settings
@export var stalk_duration: float = 5.0        # Time spent stalking before attacking
@export var preferred_stalk_distance: float = 250.0  # Distance to maintain while stalking
@export var flash_radius: float = 350.0        # Maximum distance the flash can reach to affect this squid

# Randomized Retreat Settings (in seconds)
@export var min_retreat_duration: float = 2.0  # Minimum time spent fleeing
@export var max_retreat_duration: float = 5.0  # Maximum time spent fleeing

@export_category("Sprite & Rotation Settings")
@export var sprite: Sprite2D = null
@export var max_rotation_degrees: float = 35.0
@export var rotation_speed: float = 6.0

@export_category("Collection & Proximity Sequence")
@export var collection_radius: float = 30.0
@export var player_awareness_radius: float = 250.0
@export var heart_1: Sprite2D = null
@export var heart_2: Sprite2D = null
@export var heart_3: Sprite2D = null
@export var heart_4: Sprite2D = null
@export var alternate_heart_texture: Texture2D = null
@export var time_per_heart: float = 1.0

@export_category("Camera Shake Settings")
@export var enable_camera_shake: bool = true
@export var target_camera: Camera2D = null     # Drag your child Camera2D here directly
@export var shake_intensity: float = 5.0
@export var shake_duration: float = 0.2

@export_category("Heart Image Effects")
@export var heart_image_1: Texture2D = null
@export var heart_image_2: Texture2D = null
@export var heart_image_3: Texture2D = null

@export_category("Scene Transition on Completion")
@export_file("*.tscn") var target_scene_path: String = ""
@export var scene_transition_delay: float = 2.0

enum State { STALKING, ATTACKING, RETREATING }
var current_state: State = State.STALKING

var player: Node2D = null
var stalk_timer: float = 0.0
var retreat_timer: float = 0.0
var time_near_player: float = 0.0
var previous_active_steps: int = 0
var has_been_flashed: bool = false
var scene_transition_triggered: bool = false

func _ready() -> void:
	stalk_timer = stalk_duration
	add_to_group("squids")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")

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
	var direction_to_player := (player.global_position - global_position).normalized()

	# 1. Collection Check
	if distance_to_player <= collection_radius:
		get_tree().call_group("score_ui", "add_score", 1)
		queue_free()
		return

	# State Machine logic
	match current_state:
		State.STALKING:
			_process_stalking(delta, distance_to_player, direction_to_player)

		State.ATTACKING:
			_process_attacking(distance_to_player, direction_to_player)

		State.RETREATING:
			_process_retreating(delta, direction_to_player)

	# 2. Heart Proximity Sequence (Only active after being flashed at least once)
	var player_nearby: bool = distance_to_player <= player_awareness_radius
	if has_been_flashed and not scene_transition_triggered:
		if player_nearby:
			time_near_player += delta
		else:
			time_near_player = max(0.0, time_near_player - delta)

		var hearts: Array[Sprite2D] = [heart_1, heart_2, heart_3, heart_4]
		var active_steps: int = int(time_near_player / time_per_heart)
		
		for i in range(hearts.size()):
			if hearts[i] and alternate_heart_texture:
				if i < active_steps:
					hearts[i].texture = alternate_heart_texture

		# Trigger camera shake and spawn scaled images when a new heart step is reached
		if active_steps > previous_active_steps:
			if enable_camera_shake:
				if is_instance_valid(target_camera):
					if target_camera.has_method("shake"):
						target_camera.shake(shake_intensity, shake_duration)
				else:
					get_tree().call_group("camera", "shake", shake_intensity, shake_duration)
			
			# Spawn more images each time a higher heart tier is reached
			_spawn_heart_images(active_steps)

			# Check if the final heart (4th heart) has been reached
			if active_steps >= 4 and target_scene_path != "":
				scene_transition_triggered = true
				print("Final heart reached! Changing scene in ", scene_transition_delay, " seconds.")
				get_tree().create_timer(scene_transition_delay).timeout.connect(func():
					get_tree().change_scene_to_file(target_scene_path)
				)
		
		previous_active_steps = active_steps

	# 3. Flipping & Submarine-style Pitch Rotation
	if velocity.length_squared() > 1.0:
		var facing_dir: int = 1
		if abs(velocity.x) > 10.0:
			facing_dir = 1 if velocity.x > 0 else -1
			if sprite:
				sprite.flip_h = (facing_dir < 0)

		var max_rad: float = deg_to_rad(max_rotation_degrees)
		var target_rotation: float = clamp(velocity.y * 0.005 * facing_dir, -max_rad, max_rad)
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

func _spawn_heart_images(multiplier: int) -> void:
	if not is_instance_valid(player):
		return

	var textures: Array[Texture2D] = [heart_image_1, heart_image_2, heart_image_3]
	
	for m in range(multiplier):
		for tex in textures:
			if tex:
				var img_sprite = Sprite2D.new()
				img_sprite.texture = tex
				get_tree().current_scene.add_child(img_sprite)
				img_sprite.global_position = player.global_position
				
				var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
				var target_pos = img_sprite.global_position + random_dir * randf_range(30.0, 70.0)
				
				var tween = create_tween().set_parallel(true)
				tween.tween_property(img_sprite, "global_position", target_pos, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(img_sprite, "scale", Vector2.ZERO, 0.4).from(Vector2.ONE * 1.2)
				tween.tween_property(img_sprite, "modulate:a", 0.0, 0.4)
				tween.chain().tween_callback(img_sprite.queue_free)

func _process_stalking(delta: float, distance: float, direction: Vector2) -> void:
	if not has_been_flashed:
		current_state = State.ATTACKING
		return

	stalk_timer -= delta
	if stalk_timer <= 0.0:
		current_state = State.ATTACKING
		return

	var speed_factor: float = clampf(distance / preferred_stalk_distance, 0.0, 1.0)
	velocity = direction * stalk_speed * speed_factor
	move_and_slide()

func _process_attacking(distance: float, direction: Vector2) -> void:
	if distance > stop_distance:
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _process_retreating(delta: float, direction: Vector2) -> void:
	retreat_timer -= delta
	if retreat_timer <= 0.0:
		current_state = State.STALKING
		stalk_timer = stalk_duration
		return

	var away_direction := -direction
	velocity = away_direction * retreat_speed
	move_and_slide()

# --- TRIGGERED WHEN FLASHED ---
func get_flashed() -> void:
	if not is_instance_valid(player):
		return
	
	var distance_to_player := global_position.distance_to(player.global_position)
	
	if distance_to_player <= flash_radius:
		has_been_flashed = true
		current_state = State.RETREATING
		retreat_timer = randf_range(min_retreat_duration, max_retreat_duration)
		print("Squid was flashed! Retreating for ", snapped(retreat_timer, 0.1), " seconds.")
	else:
		print("Squid was too far away to be affected.")
