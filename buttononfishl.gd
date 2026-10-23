extends Control

@export_category("Score Settings")
@export var target_score: int = 5                  # The score required to reveal the button
@export var target_button: Button = null            # Drag your Button node here in the Inspector

var current_score: int = 0

func _ready() -> void:
	# Automatically join the "score_ui" group so the squid can call add_score()
	if not is_in_group("score_ui"):
		add_to_group("score_ui")
		
	# Ensure the button starts hidden when the game launches (optional)
	if target_button:
		target_button.visible = false

# This function is automatically called when any squid is collected
func add_score(amount: int) -> void:
	current_score += amount
	print("Score updated: ", current_score, " / ", target_score)
	
	# Check if we have enough score to reveal the button
	if current_score >= target_score:
		if target_button and not target_button.visible:
			target_button.visible = true
			print("Target score reached! Button is now visible.")
