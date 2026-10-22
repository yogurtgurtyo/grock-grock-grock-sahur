extends Control  # (Change to Node2D or whatever type your joystick node is if it's not a Control)

@export var cutscene: SpriteCutscene  ## Drag your SpriteCutscene node here in the Inspector
@export var hide_during_cutscene: bool = true  ## If true, hides the joystick while playing and shows it when done

func _ready() -> void:
	if not cutscene:
		push_warning("SpriteCutscene node is unassigned on the joystick script!")
		return
	
	# Initial state setup
	if hide_during_cutscene:
		visible = false
	
	# Connect to both signals
	cutscene.finished.connect(_on_cutscene_ended)
	cutscene.skipped.connect(_on_cutscene_ended)

func _on_cutscene_ended() -> void:
	# Toggle visibility back on (or off, depending on your preference)
	visible = true
	
	# Optional: Disconnect signals so this only happens once
	if cutscene:
		if cutscene.finished.is_connected(_on_cutscene_ended):
			cutscene.finished.disconnect(_on_cutscene_ended)
		if cutscene.skipped.is_connected(_on_cutscene_ended):
			cutscene.skipped.disconnect(_on_cutscene_ended)
