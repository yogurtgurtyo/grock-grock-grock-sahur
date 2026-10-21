extends Button

# Drag and drop the scene you want to load into this field in the Inspector,
# or pass a file path like "res://MyNextScene.tscn"
@export_file("*.tscn") var target_scene: String

func _ready() -> void:
	# Connect the button's "pressed" signal to the handler function
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
	else:
		print("Warning: No target scene assigned to the button!")
