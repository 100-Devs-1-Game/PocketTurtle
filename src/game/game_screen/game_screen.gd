extends Node2D

@export var debug_canvas_layer: CanvasLayer
@export var turtle: Turtle

var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

# The factor of how much in-game time elapses for real-life time.
var time_scale_factor := 1.0

const TIME_BETWEEN_SAVES_SECONDS = 1.0
const SAVE_PATH = "user://save.json"
var _save_timer := 0.0

@export var turtle_variants: TurtleVariants:
	set = set_turtle_variants,
	get = get_turtle_variants

func set_turtle_variants(new_turtle_variants: TurtleVariants) -> void:
	turtle_variants = new_turtle_variants
	if turtle:
		turtle.turtle_variants = turtle_variants

func get_turtle_variants() -> TurtleVariants:
	return turtle_variants
		

func _ready() -> void:
	turtle.turtle_variants = turtle_variants
	
	var save_game_data := SaveGameData.new()
	# Read in the previous save file if it exists
	if FileAccess.file_exists(SAVE_PATH):
		var save_file_contents := FileAccess.get_file_as_string(SAVE_PATH)
		var dict: Dictionary = JSON.parse_string(save_file_contents)
		save_game_data.read_dict(dict)
		turtle.loading_from_save = true
		turtle.stage = save_game_data.turtle_current_stage
		turtle.stage_elapsed_seconds = save_game_data.turtle_stage_lifetime
		turtle.current_want = save_game_data.turtle_current_want
		if not save_game_data.turtle_variant.is_empty():
			turtle.turtle_variant = load(save_game_data.turtle_variant)
		turtle.loading_from_save = false

	
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


func _process(delta: float) -> void:
	turtle.add_lifetime(delta * time_scale_factor)
	_save_timer += delta
	if _save_timer >= TIME_BETWEEN_SAVES_SECONDS:
		_save_timer -= TIME_BETWEEN_SAVES_SECONDS
		save_game()

func save_game() -> void:
	var save_game_data := SaveGameData.new()
	save_game_data.turtle_current_stage = turtle.stage
	save_game_data.turtle_stage_lifetime = turtle.stage_elapsed_seconds
	save_game_data.turtle_current_want = turtle.current_want
	if turtle.turtle_variant:
		save_game_data.turtle_variant = turtle.turtle_variant.resource_path
	var dict := save_game_data.to_dict()
	var json_string := JSON.stringify(dict)
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(json_string)
		f.close()
	else:
		print("Failed to open save file for writing: %d " % FileAccess.get_open_error())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.physical_keycode == Key.KEY_QUOTELEFT and event.pressed:
			debug_canvas_layer.visible = not debug_canvas_layer.visible


func _exit_tree() -> void:
	save_game()

func make_window_transparent(window: Window) -> void:
	ProjectSettings.set("display/window/per_pixel_transparency/allowed", true)
	#window.size = window.min_size
	window.unresizable = true
	window.transparent = true
	window.transparent_bg = true
	window.borderless = true
