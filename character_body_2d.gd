extends CharacterBody2D

const SPEED = 75.0
const JUMP_VELOCITY = -150.0

# Adjust this value to make the animation cycle faster or slower relative to movement speed
@export var anim_speed_scale: float = 0.02

@onready var sprite: Sprite2D = $Sprite2D

var anim_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction and handle movement/deceleration
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Update frame-based animation
	_update_animation(delta)


func _update_animation(delta: float) -> void:
	var current_speed = abs(velocity.x)

	# Flip sprite according to facing direction
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	# Animate if moving along the ground
	if current_speed > 10.0 and is_on_floor():
		# Advance timer proportional to current speed
		anim_timer += (current_speed * 2.5) * delta * anim_speed_scale
		
		# Cycle through frames 0 to 3
		sprite.frame = int(anim_timer) % 4
	else:
		# Idle frame when stopped or in air
		sprite.frame = 0
		anim_timer = 0.0
