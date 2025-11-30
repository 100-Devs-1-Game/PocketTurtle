class_name SaveGameData
extends Resource


## Properties that are stored as JSON into a save game


# Lifetime of the turtle's stage
@export var turtle_stage_lifetime: float
# It's current stage.
@export var turtle_current_stage: Enums.TurtleStage
# The current want the turtle has
@export var turtle_current_want: Enums.TurtleWants
# The turtle variant 
@export var turtle_variant: String


func to_dict() -> Dictionary:
	return {
		"turtle_stage_lifetime": turtle_stage_lifetime,
		"turtle_current_stage": turtle_current_stage,
		"turtle_current_want": turtle_current_want,
		"turtle_variant": turtle_variant
	}


func read_dict(dict: Dictionary) -> void:
	turtle_stage_lifetime = dict.get("turtle_stage_lifetime")
	turtle_current_stage = dict.get("turtle_current_stage")
	turtle_current_want = dict.get("turtle_current_want")
	turtle_variant = dict.get("turtle_variant")
