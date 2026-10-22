extends Sprite2D

## Animation speed in frames per second
@export var fps: float = 10.0

## Whether the animation should loop continuously
@export var loop: bool = true

## Auto-play animation on node load
@export var autoplay: bool = true

var _frame_timer: float = 0.0
var _is_playing: bool = false
var _total_frames: int = 0

func _ready() -> void:
	# Calculate total frames from grid dimensions (hframes * vframes)
	_total_frames = hframes * vframes
	
	if autoplay:
		play()

func _process(delta: float) -> void:
	if not _is_playing or _total_frames <= 1 or fps <= 0.0:
		return

	_frame_timer += delta
	var frame_duration: float = 1.0 / fps

	while _frame_timer >= frame_duration:
		_frame_timer -= frame_duration
		_advance_frame()

func _advance_frame() -> void:
	if frame + 1 < _total_frames:
		frame += 1
	elif loop:
		frame = 0
	else:
		_is_playing = false

## Call this to start or resume playing
func play() -> void:
	_is_playing = true

## Call this to pause playback
func pause() -> void:
	_is_playing = false

## Call this to stop playback and reset to the first frame
func stop() -> void:
	_is_playing = false
	frame = 0
	_frame_timer = 0.0
