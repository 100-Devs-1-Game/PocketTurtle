class_name SaveGameData
extends Resource


## Properties that are stored as JSON into a save game
const VERSION = 2

# Lifetime of the turtle's stage
@export var turtle_stage_lifetime: float
# It's current stage.
@export var turtle_current_stage: Enums.TurtleStage
# The current want the turtle has
@export var turtle_current_want: Enums.TurtleWants
# The turtle variant index into the variants array
@export var turtle_variant_index: int = -1
# The time scale scale factor
@export var time_scale: float = 1.0
# The name of the turtle
@export var turtle_name: String
# Are sound effects enabled?
@export var sfx_enabled: bool = true
# What the window position was last recorded as
@export var window_position: Vector2i
# What the last saved window size was.
@export var window_size: Vector2i

func to_dict() -> Dictionary:
	return {
		"version": VERSION,
		"turtle_stage_lifetime": turtle_stage_lifetime,
		"turtle_current_stage": turtle_current_stage,
		"turtle_current_want": turtle_current_want,
		"turtle_variant_index": turtle_variant_index,
		"time_scale": time_scale,
		"turtle_name": turtle_name,
		"sfx_enabled": sfx_enabled,
		"window_position": {
			"x": window_position.x,
			"y": window_position.y
		},
		"window_size" : {
			"x": window_size.x,
			"y": window_size.y,
		}
	}


func read_dict(dict: Dictionary) -> Error:
	if !dict.has("version") or VERSION != dict["version"]:
		return FAILED
	
	turtle_stage_lifetime = dict.get("turtle_stage_lifetime")
	turtle_current_stage = dict.get("turtle_current_stage")
	turtle_current_want = dict.get("turtle_current_want")
	turtle_variant_index = dict.get("turtle_variant_index") if dict.has("turtle_variant_index") else -1
	time_scale = dict.get("time_scale") if dict.has("time_scale") else 1.0
	if time_scale < 0 or is_zero_approx(time_scale):
		time_scale = 1.0
	turtle_name = dict.get("turtle_name") if dict.has("turtle_name") else "Tortle"
	sfx_enabled = dict.get("sfx_enabled") if dict.has("sfx_enabled") else true
	if OS.get_name() != "web":
		
		var window_position_json = dict.get("window_position")
		if window_position_json is Dictionary:
			if window_position_json.has("x") and window_position_json.has("y"):
				window_position.x = window_position_json.get("x")
				window_position.y = window_position_json.get("y")
			else:
				window_position = get_default_window_position()
		
		var window_size_json = dict.get("window_size")
		if window_size_json is Dictionary:
			if window_size_json.has("x") and window_size_json.has("y"):
				window_size.x = window_size_json.get("x")
				window_size.y = window_size_json.get("y")
			else:
				window_size = Vector2(540, 960)

	return OK

func save_turtle(turtle: TurtleState) -> void:
	turtle_stage_lifetime = turtle.stage_lifetime
	turtle_current_stage = turtle.turtle_stage
	turtle_current_want = turtle.turtle_wants
	turtle_name = turtle.turtle_name
	turtle_variant_index = turtle.turtle_variant_index

func load_turtle(turtle: TurtleState) -> void:
	turtle.turtle_name = turtle_name
	turtle.stage_lifetime = turtle_stage_lifetime
	turtle.turtle_stage = turtle_current_stage
	turtle.turtle_wants = turtle_current_want
	turtle.turtle_variant_index = turtle_variant_index


func get_default_window_position() -> Vector2i:
	var rect := DisplayServer.get_display_safe_area()
	var dims := DisplayServer.window_get_size()
	return rect.get_center() - (dims / 2)
