class_name GrabberControl
extends Control

signal grabbed
signal moved(delta: Vector2i)
signal released

var is_grabbed := false
var move_delta: Vector2i

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_grabbed = event.is_pressed()
		set_process(is_grabbed)
		if is_grabbed:
			grabbed.emit()
		else:
			released.emit()
	else:
		if event is InputEventMouseMotion and is_grabbed:
			move_delta = event.relative

func _process(_p_delta: float) -> void:
	if move_delta:
		moved.emit(move_delta)
		move_delta = Vector2i.ZERO
