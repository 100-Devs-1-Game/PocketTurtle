class_name SaveGameData
extends Resource


## Properties that are stored as JSON into a save game
const VERSION = 1

# Lifetime of the turtle's stage
@export var turtle_stage_lifetime: float
# It's current stage.
@export var turtle_current_stage: Enums.TurtleStage
# The current want the turtle has
@export var turtle_current_want: Enums.TurtleWants
# The turtle variant 
@export var turtle_variant: String
# The time scale scale factor
@export var time_scale: float = 1.0
# The name of the turtle
@export var turtle_name: String
# Are sound effects enabled?
@export var sfx_enabled: bool = true

func to_dict() -> Dictionary:
	return {
		"version": VERSION,
		"turtle_stage_lifetime": turtle_stage_lifetime,
		"turtle_current_stage": turtle_current_stage,
		"turtle_current_want": turtle_current_want,
		"turtle_variant": turtle_variant,
		"time_scale": time_scale,
		"turtle_name": turtle_name,
		"sfx_enabled": sfx_enabled,
	}


func read_dict(dict: Dictionary) -> Error:
	if !dict.has("version") or VERSION != dict["version"]:
		return FAILED
	
	turtle_stage_lifetime = dict.get("turtle_stage_lifetime")
	turtle_current_stage = dict.get("turtle_current_stage")
	turtle_current_want = dict.get("turtle_current_want")
	turtle_variant = dict.get("turtle_variant")
	time_scale = dict.get("time_scale") if dict.has("time_scale") else 1.0
	if time_scale < 0 or is_zero_approx(time_scale):
		time_scale = 1.0
	turtle_name = dict.get("turtle_name") if dict.has("turtle_name") else "Tortle"
	sfx_enabled = dict.get("sfx_enabled") if dict.has("sfx_enabled") else true
	return OK

func save_turtle(turtle: TurtleState) -> void:
	turtle_stage_lifetime = turtle.stage_lifetime
	turtle_current_stage = turtle.turtle_stage
	turtle_current_want = turtle.turtle_wants
	turtle_variant = turtle.turtle_variant.resource_path if turtle.turtle_variant else ""
	turtle_name = turtle.turtle_name

func load_turtle(turtle: TurtleState) -> void:
	turtle.turtle_name = turtle_name
	turtle.stage_lifetime = turtle_stage_lifetime
	turtle.turtle_stage = turtle_current_stage
	turtle.turtle_wants = turtle_current_want
	if turtle_variant != "":
		turtle.turtle_variant = load(turtle_variant)
