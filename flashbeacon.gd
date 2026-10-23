extends Button

# Declare the custom signal
signal flashed

@export var target_sprite: CanvasItem ## Drag your Sprite2D, TextureRect, or Node2D sprite here in the Inspector
@export var fade_duration: float = 1.0 ## Duration in seconds for the sprite to fade out
@export var cooldown_time: float = 1.0 ## Cooldown time in seconds before the button can be pressed again

func _ready() -> void:
	# Connect the built-in pressed signal to our function
	pressed.connect(_on_button_pressed)
	
	# Ensure the target sprite starts hidden
	if target_sprite:
		target_sprite.visible = false

func _on_button_pressed() -> void:
	# ... (your existing code for fading the sprite and emitting the signal) ...
	
	flashed.emit()

	# Tell all squids in the "squids" group to retreat
	for squid in get_tree().get_nodes_in_group("squids"):
		if squid.has_method("get_flashed"):
			squid.get_flashed()
	# Disable the button immediately to start the cooldown and block spamming
	disabled = true

	# Make the sprite visible and reset its opacity to fully opaque
	target_sprite.visible = true
	target_sprite.modulate.a = 1.0

	# Use a Tween to smoothly fade out the alpha channel
	var tween := create_tween()
	tween.tween_property(target_sprite, "modulate:a", 0.0, fade_duration)
	
	# Hide the sprite completely once the fade finishes
	tween.tween_callback(func(): target_sprite.visible = false)

	# Emit your custom signal
	flashed.emit()

	# Wait for the cooldown duration, then re-enable the button
	if cooldown_time > 0.0:
		await get_tree().create_timer(cooldown_time).timeout
	
	disabled = false
