extends Node


@onready var popup_menu: PopupMenu = $StatusIndicator/PopupMenu
@onready var debug_canvas_layer: CanvasLayer = $DebugCanvasLayer


var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")


func _ready() -> void:
	# TODO: This will be done to set up the fun little desktop pet.
	# Windows: 
	# OS.has_feature("win32")
	# Anchor to the bottom right.
	#var taskbar_position := (DisplayServer.screen_get_usable_rect().end.y - viewport_height)

	# TODO: MacOS, top right or top left.
	# OS.has_feature("mac")
	
	# TODO: Web, no changes.
	# OS.has_feature("web")

	#var main_window := get_window()
	#main_window.min_size = Vector2(200, 300)
	#main_window.position = Vector2i(floor(DisplayServer.screen_get_size().x - viewport_width), taskbar_position)
	#make_window_transparent(main_window)
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.physical_keycode == Key.KEY_QUOTELEFT and event.pressed:
			debug_canvas_layer.visible = not debug_canvas_layer.visible


func _exit_tree() -> void:
	print("exiting!")



func make_window_transparent(window: Window) -> void:
	ProjectSettings.set("display/window/per_pixel_transparency/allowed", true)
	window.size = window.min_size
	window.unresizable = true
	window.transparent = true
	window.transparent_bg = true
	window.borderless = true
