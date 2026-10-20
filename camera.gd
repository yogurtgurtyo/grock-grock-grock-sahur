extends Area2D
class_name CameraZone2D

## The Camera2D to enable when entering this zone.
@export var target_camera_to_enable: Camera2D

## The Camera2D to disable when entering this zone.
@export var target_camera_to_disable: Camera2D

## Optional: Set to true if the target_camera_to_enable should start enabled.
@export var active_on_start: bool = false

## Name of the group that identifies player/valid entities.
@export var player_group_name: StringName = &"player"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if target_camera_to_enable:
		target_camera_to_enable.enabled = active_on_start
	
	if target_camera_to_disable:
		target_camera_to_disable.enabled = !active_on_start


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(player_group_name):
		_switch_cameras(true)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(player_group_name):
		_switch_cameras(false)


func _switch_cameras(entering_zone: bool) -> void:
	if target_camera_to_enable:
		target_camera_to_enable.enabled = entering_zone
		
	if target_camera_to_disable:
		target_camera_to_disable.enabled = !entering_zone
