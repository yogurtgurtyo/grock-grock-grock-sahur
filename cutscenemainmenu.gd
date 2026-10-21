class_name SpriteCutscene
extends Sprite2D

## Emitted when the cutscene completes naturally.
signal finished
## Emitted if the cutscene is skipped by the user.
signal skipped

@export_group("Cutscene Settings")
## Frames played per second.
@export var fps: float = 8.0
## Start frame index (defaults to 0).
@export var start_frame: int = 0
## End frame index. If set to -1, plays until the final frame of the sprite sheet.
@export var end_frame: int = -1
## Automatically start playing when the scene loads.
@export var autoplay: bool = true

@export_group("Skip Settings")
## Allow player to skip via keyboard/gamepad input action.
@export var allow_input_skip: bool = true
## The Input Map action name used to skip (e.g. "ui_cancel", "skip", "ui_accept").
@export var skip_input_action: StringName = &"ui_cancel"

var _is_playing: bool = false
var _frame_timer: float = 0.0
var _current_frame_float: float = 0.0
var _target_end_frame: int = 0


func _ready() -> void:
	if autoplay:
		play()


func _process(delta: float) -> void:
	if not _is_playing:
		return
	
	# Advance frame sequence based on elapsed time
	_current_frame_float += fps * delta
	var current_step := int(_current_frame_float)
	
	if current_step <= _target_end_frame:
		frame = current_step
	else:
		# Reached end of cutscene
		frame = _target_end_frame
		_is_playing = false
		finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_playing or not allow_input_skip:
		return
	
	if event.is_action_pressed(skip_input_action):
		get_viewport().set_input_as_handled()
		skip_cutscene()


## Starts playing the cutscene animation.
func play() -> void:
	var total_available_frames := (hframes * vframes) - 1
	
	# Resolve the final frame boundary
	if end_frame < 0 or end_frame > total_available_frames:
		_target_end_frame = total_available_frames
	else:
		_target_end_frame = end_frame
	
	# Clamp starting frame within bounds
	start_frame = clampi(start_frame, 0, _target_end_frame)
	
	frame = start_frame
	_current_frame_float = float(start_frame)
	_is_playing = true


## Stops playback immediately.
func stop() -> void:
	_is_playing = false


## Call this to manually skip the cutscene (e.g. from a UI Button press).
func skip_cutscene() -> void:
	if not _is_playing:
		return
	
	_is_playing = false
	frame = _target_end_frame
	skipped.emit()


## Returns whether the cutscene is currently running.
func is_playing() -> bool:
	return _is_playing


func _on_button_pressed() -> void:
	pass # Replace with function body.
