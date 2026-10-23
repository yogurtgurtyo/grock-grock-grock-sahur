extends Area2D

# How strongly this bone pushes away from other tentacles
@export var push_strength: float = 150.0

# Reference to the root CharacterBody2D of this squid
@onready var character_body: CharacterBody2D = owner as CharacterBody2D

func _physics_process(delta: float) -> void:
	if not character_body:
		return

	# Check all areas currently overlapping with this bone
	for overlapping_area in get_overlapping_areas():
		
		# CRITICAL: Ignore collisions with our own squid's other tentacles/parts
		if overlapping_area.owner == character_body:
			continue
			
		# Calculate direction vector pointing away from the overlapping bone
		var push_direction := (global_position - overlapping_area.global_position).normalized()
		
		# Apply a push force to the root CharacterBody2D so it slides away
		character_body.velocity += push_direction * push_strength * delta
		character_body.move_and_slide()
