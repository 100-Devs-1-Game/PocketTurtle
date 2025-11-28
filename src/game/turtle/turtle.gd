class_name Turtle
extends Area2D

signal state_changed

# The amount of time elapsed for this current stage.
@export var stage_elapsed_seconds: float

# The current turtle stage
@export var stage: Enums.TurtleStage = Enums.TurtleStage.EGG: 
	set = set_stage, 
	get = get_stage
	
@onready var visual: Node2D = $Visual

@onready var egg_sprite: Sprite2D = $Visual/Egg
@onready var baby_sprite: Sprite2D = $Visual/Baby
@onready var adult_sprite: Sprite2D = $Visual/Adult
@onready var elderly_sprite: Sprite2D = $Visual/Elder
@onready var ascension_sprite: Sprite2D = $Visual/Ascension

func set_stage(next_stage: Enums.TurtleStage) -> void:
	stage_elapsed_seconds = 0
	stage = next_stage
	
	for child: Node2D in visual.get_children():
		child.visible = child.get_index() == stage

	state_changed.emit()


func get_stage() -> Enums.TurtleStage:
	return stage


var stage_lifetime_transition_table: Dictionary[Enums.TurtleStage, int] = {
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
	var next_transition_time := stage_lifetime_transition_table[stage]
	if stage_elapsed_seconds >= next_transition_time:
		# Transition to next stage
		_transition_to_next_life_stage()


func _transition_to_next_life_stage() -> void:
	set_stage((stage + 1) % Enums.TurtleStage.size() as Enums.TurtleStage)


func get_time_to_next_state() -> int:
	return stage_lifetime_transition_table[stage] - stage_elapsed_seconds
