class_name Turtle
extends Area2D

signal state_changed

signal wants_changed
signal wash_state_changed
signal pet_state_changed
signal hunger_state_changed

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

var stage_lifetime_transition_table: Dictionary[Enums.TurtleStage, int] = {
	Enums.TurtleStage.EGG: 24 * 60 * 60,
	Enums.TurtleStage.BABY: 48 * 60 * 60,
	Enums.TurtleStage.ADULT: 96 * 60 * 60,
	Enums.TurtleStage.ELDERLY: 24 * 60 * 60,
	Enums.TurtleStage.ASCENSION: 2 * 60 * 60,
}

var desire_configuration_table: Dictionary[Enums.TurtleStage, Array] = {
	Enums.TurtleStage.EGG: [],
	Enums.TurtleStage.BABY: ["bath", "eat", "pet"],
	Enums.TurtleStage.ADULT: ["bath", "eat", "pet"],
	Enums.TurtleStage.ELDERLY: ["bath", "eat", "pet"],
	Enums.TurtleStage.ASCENSION: [],
}

var want_signals_table = {
	"bath": wash_state_changed,
	"pet": pet_state_changed,
	"eat": hunger_state_changed
}

# How often the turtle reevaluates its wants 
const _wants_evaluation_frequency: float = 15 * 60 * 60 
var _wants_evaluation_timer := 0.0

# The current want of the turtle.
var current_want: String

func set_stage(next_stage: Enums.TurtleStage) -> void:
	stage_elapsed_seconds = 0
	stage = next_stage
	
	for child: Node2D in visual.get_children():
		child.visible = child.get_index() == stage

	_wants_evaluation_timer = 0
	current_want = ""
	wants_changed.emit()
	state_changed.emit()


func get_stage() -> Enums.TurtleStage:
	return stage

# Adds lifetime in seconds.
func add_lifetime(lifetime_secs: float) -> void:
	stage_elapsed_seconds += lifetime_secs
	
	# Check for handling a transition to another state.
	var next_transition_time := stage_lifetime_transition_table[stage]
	if stage_elapsed_seconds >= next_transition_time:
		# Transition to next stage
		_transition_to_next_life_stage()
	
	_update_wants(lifetime_secs)


func _update_wants(lifetime_secs: float) -> void:
	_wants_evaluation_timer += lifetime_secs
	if _wants_evaluation_timer >= _wants_evaluation_frequency:
		_wants_evaluation_timer -= _wants_evaluation_frequency
		_set_next_want()


func _set_next_want() -> void:
	var available_wants: Array = desire_configuration_table[stage]
	if available_wants.is_empty():
		return
	
	current_want = available_wants.pick_random()
	wants_changed.emit()
	

func _transition_to_next_life_stage() -> void:
	set_stage((stage + 1) % Enums.TurtleStage.size() as Enums.TurtleStage)


func get_time_to_next_state() -> int:
	return stage_lifetime_transition_table[stage] - stage_elapsed_seconds

	
