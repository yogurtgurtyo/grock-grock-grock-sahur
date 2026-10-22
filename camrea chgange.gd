class_name CutsceneCameraController
extends Node

@export_group("References")
## The cutscene instance to listen to.
@export var cutscene: SpriteCutscene
## The camera to activate during the cutscene.
@export var cutscene_camera: Camera2D
## The camera to activate once the cutscene finishes or is skipped.
@export var main_camera: Camera2D

@export_group("Behavior")
## Disable the cutscene camera when the cutscene ends.
@export var disable_cutscene_cam_on_end: bool = true
## Enable the main camera when the cutscene ends.
@export var enable_main_cam_on_end: bool = true


func _ready() -> void:
	if not cutscene:
		push_error("CutsceneCameraController: No SpriteCutscene assigned!")
		return

	# Connect to both finished and skipped signals
	cutscene.finished.connect(_on_cutscene_ended)
	cutscene.skipped.connect(_on_cutscene_ended)

	# Set initial camera states for start of cutscene
	_setup_initial_cameras()


func _setup_initial_cameras() -> void:
	if cutscene_camera:
		cutscene_camera.enabled = true
	if main_camera:
		main_camera.enabled = false


func _on_cutscene_ended() -> void:
	# Disconnect signals to prevent double-firing
	if cutscene.finished.is_connected(_on_cutscene_ended):
		cutscene.finished.disconnect(_on_cutscene_ended)
	if cutscene.skipped.is_connected(_on_cutscene_ended):
		cutscene.skipped.disconnect(_on_cutscene_ended)

	# Switch camera states
	if cutscene_camera and disable_cutscene_cam_on_end:
		cutscene_camera.enabled = false

	if main_camera and enable_main_cam_on_end:
		main_camera.enabled = true
