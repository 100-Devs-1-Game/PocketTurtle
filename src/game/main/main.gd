extends Node

@onready var a_elder_1: Sprite2D = $AElder1
@onready var popup_menu: PopupMenu = $StatusIndicator/PopupMenu

var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready() -> void:
	
	# Windows: 
	# OS.has_feature("win32")
	# Anchor to the bottom right.
	var taskbar_position := (DisplayServer.screen_get_usable_rect().end.y - viewport_height)
	
	# TODO: MacOS, top right or top left.
	# OS.has_feature("mac")
	
	# TODO: Web, no changes.
	# OS.has_feature("web")

	var main_window := get_window()
	main_window.min_size = Vector2(viewport_width, viewport_height)
	main_window.position = Vector2i(floor(DisplayServer.screen_get_size().x - viewport_width), taskbar_position)
	make_window_transparent(main_window)


func make_window_transparent(window: Window) -> void:
	window.size = window.min_size
	window.unresizable = true
	window.transparent = true
	window.transparent_bg = true
	window.borderless = true
