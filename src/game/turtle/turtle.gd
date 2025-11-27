class_name Turtle
extends Area2D


# The amount of time elapsed for this current stage.
@export var stage_elapsed_seconds: float

# The current turtle stage
@export var stage: Enums.TurtleStage = Enums.TurtleStage.EGG

const STAGE_LIFETIME_TRANSITION_TABLE: Dictionary[Enums.TurtleStage, int] = {
	Enums.TurtleStage.EGG: 24 * 60 * 60,
	Enums.TurtleStage.BABY: 48 * 60 * 60,
	Enums.TurtleStage.ADULT: 96 * 60 * 60,
	Enums.TurtleStage.ELDERLY: 24 * 60 * 60,
	Enums.TurtleStage.ASCENSION: 2 * 60 * 60,
}

# Adds lifetime in seconds.
func add_lifetime(lifetime_secs: float) -> void:
	stage_elapsed_seconds += lifetime_secs
	
	# Check for handling a transition to another state.
	var next_transition_time := STAGE_LIFETIME_TRANSITION_TABLE[stage]
	if stage_elapsed_seconds >= next_transition_time:
		# Transition to next stage
		_transition_to_next_life_stage()
	

func _transition_to_next_life_stage() -> void:
	stage_elapsed_seconds = 0
	stage = (stage + 1) % Enums.TurtleStage.size()
