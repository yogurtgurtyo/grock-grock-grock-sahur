extends Node2D

@export var camera: Camera2D = null  # Drag your child Camera2D here (optional if it's named Camera2D)

var shake_strength: float = 0.0
var shake_timer: float = 0.0

func _ready() -> void:
	# Ensure it's in the group so group-calls from the squid work automatically
	if not is_in_group("camera"):
		add_to_group("camera")
		
	# Automatically find the child Camera2D if not manually assigned
	if not camera:
		camera = get_node_or_null("Camera2D")

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		if camera:
			# Apply random shaking offset directly to the child camera
			camera.offset = Vector2(
				randf_range(-shake_strength, shake_strength), 
				randf_range(-shake_strength, shake_strength)
			)
	else:
		shake_timer = 0.0
		if camera:
			camera.offset = Vector2.ZERO

# This is the function called by the squid script
func shake(intensity: float, duration: float) -> void:
	shake_strength = intensity
	shake_timer = duration
