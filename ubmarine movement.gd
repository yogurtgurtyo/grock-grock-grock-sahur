extends CharacterBody2D

@export_category("Submarine 2D Settings")
@export var max_speed: float = 300.0
@export var acceleration: float = 800.0
@export var water_drag: float = 500.0     
@export var rotation_speed: float = 5.0   

@export_category("Virtual Joystick Reference")
@export var virtual_joystick: Control = null 

@export_category("Sprite Nodes")
@export var sprite_right: Sprite2D = null
@export var sprite_left: Sprite2D = null

# Tracks the current locked-in direction state (-1 for Left, 1 for Right)
var current_facing_direction: int = 1

func _ready() -> void:
	if not sprite_right:
		sprite_right = get_node_or_null("Sprite2D")
	if not sprite_left:
		sprite_left = get_node_or_null("Sprite2D2")
		
	_update_sprite_visibility(current_facing_direction)

func _physics_process(delta: float) -> void:
	# 1. Get Input
	var input_vector := Vector2.ZERO
	
	if virtual_joystick and virtual_joystick.has_method("get_output"):
		input_vector = virtual_joystick.get_output() 
	else:
		input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 2. Handle Acceleration and Water Drag
	if input_vector != Vector2.ZERO:
		var target_velocity = input_vector * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
		# Pitch rotation with direction correction
		# Multiplying by current_facing_direction ensures pitching works correctly when facing left
		if abs(input_vector.x) > 0.1:
			var target_rotation = input_vector.y * 0.2 * current_facing_direction
			rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, water_drag * delta)
		rotation = lerp_angle(rotation, 0.0, rotation_speed * delta)

	# 3. Directional Sprite Switching Logic
	if abs(velocity.x) > 20.0: 
		var new_direction = 1 if velocity.x > 0 else -1
		
		if new_direction != current_facing_direction:
			current_facing_direction = new_direction
			_update_sprite_visibility(current_facing_direction)

	# 4. Move the submarine
	move_and_slide()

func _update_sprite_visibility(dir: int) -> void:
	if sprite_right:
		sprite_right.visible = (dir > 0)
	if sprite_left:
		sprite_left.visible = (dir < 0)
