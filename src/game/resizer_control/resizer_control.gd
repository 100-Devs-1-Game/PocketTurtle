class_name ResizerControl
extends Control

signal grabbed
signal moved(delta: Vector2i)
signal clicked
signal released

var is_grabbed := false
var last_mouse_pos := Vector2i.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_grabbed = event.is_pressed()
		if is_grabbed:
			last_mouse_pos = DisplayServer.mouse_get_position()
			grabbed.emit()
		else:
			released.emit()
	else:
		if event is InputEventMouseMotion and is_grabbed:
			var current_mouse_pos = DisplayServer.mouse_get_position()
			var delta = current_mouse_pos - last_mouse_pos
			last_mouse_pos = current_mouse_pos
			moved.emit(delta)
