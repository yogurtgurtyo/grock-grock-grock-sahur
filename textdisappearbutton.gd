extends Control

@export var button: Button ## Drag your child Button node here in the Inspector
@export var target_text_node: CanvasItem ## Drag your Label, RichTextLabel, or text node here in the Inspector
@export var secondary_target_node: CanvasItem ## Drag an additional node here to also turn its visibility off

func _ready() -> void:
	if not button:
		push_warning("Button node is unassigned on the Control script!")
		return
	
	# Connect to the child button's pressed signal
	button.pressed.connect(_on_child_button_pressed)

func _on_child_button_pressed() -> void:
	if target_text_node:
		target_text_node.visible = false
	else:
		push_warning("Target text node is unassigned on the Control script!")
		
	if secondary_target_node:
		secondary_target_node.visible = true
