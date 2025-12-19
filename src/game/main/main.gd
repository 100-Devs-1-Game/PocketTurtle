extends Node

const TITLE_SCREEN_SCENE = "res://game/title_screen/title_screen.tscn"
const GAME_SCREEN_SCENE = "res://game/game/game.tscn"
const TITLE_SCREEN_DELAY = 2.0

func _ready() -> void:
	
	if OS.get_name() != "Web":
		# Set up the Window to be transparent.
		make_window_transparent(get_window())
	
	var title_screen_scene = preload(TITLE_SCREEN_SCENE).instantiate()
	var game_screen_scene = preload(GAME_SCREEN_SCENE)
	add_child(title_screen_scene)
	await get_tree().create_timer(TITLE_SCREEN_DELAY).timeout
	title_screen_scene.queue_free()
	add_child(game_screen_scene.instantiate())

func make_window_transparent(window: Window) -> void:
	ProjectSettings.set("display/window/per_pixel_transparency/allowed", true)
	window.unresizable = true
	window.transparent = true
	window.transparent_bg = true
	window.borderless = true
