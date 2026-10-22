extends Sprite2D

@export_category("Shadow Settings")
@export var speed_multiplier: float = 1.1
@export var acceleration: float = 600.0   
@export var return_speed: float = 400.0   

var submarine_body: CharacterBody2D = null
var current_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	submarine_body = get_parent() as CharacterBody2D
	if not submarine_body:
		push_error("SubmarineShadow must be a direct child of a CharacterBody2D!")

func _process(delta: float) -> void:
	if not submarine_body:
		return

	var sub_velocity = submarine_body.velocity

	if sub_velocity.length() > 5.0:
		# 1. Calculate target offset based on velocity direction and speed
		var target_offset = sub_velocity.normalized() * (sub_velocity.length() * 0.1) * speed_multiplier
		current_offset = current_offset.move_toward(target_offset, acceleration * delta)
	else:
		# 2. Return smoothly back to home position (0, 0)
		current_offset = current_offset.move_toward(Vector2.ZERO, return_speed * delta)

	# Apply the offset to position
	position = current_offset
	
	# 3. Force the shadow to ignore the parent's rotation entirely 
	# (Keeps it completely level regardless of how much the submarine pitches/tilts)
	global_rotation = 0.0
