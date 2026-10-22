extends Sprite2D

@export var fade_duration: float = 1.0
## Drag your SpriteCutscene node into this slot in the Inspector
@export var cutscene: SpriteCutscene 

func _ready() -> void:
	if cutscene:
		# Trigger fade whether it finishes naturally or gets skipped
		cutscene.finished.connect(_start_fade)
		cutscene.skipped.connect(_start_fade)
	else:
		push_warning("Cutscene node is missing/unassigned!")

func _start_fade() -> void:
	# Prevent double-triggering if signals overlap
	if cutscene:
		cutscene.finished.disconnect(_start_fade)
		cutscene.skipped.disconnect(_start_fade)
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)
