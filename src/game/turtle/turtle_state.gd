class_name TurtleState
extends Resource

signal variant_changed(new_variant: TurtleVariant)
signal name_changed(new_name: String)
signal stage_changed(new_stage: Enums.TurtleStage)
signal wants_changed(new_wants: Enums.TurtleWants)

@export var turtle_name: String:
	set = set_turtle_name

@export var turtle_stage: Enums.TurtleStage:
	set = set_turtle_stage

@export var turtle_wants: Enums.TurtleWants:
	set = set_turtle_wants

@export var stage_lifetime: float

@export var turtle_variant: TurtleVariant:
	set = set_turtle_variant

func set_turtle_name(new_name: String) -> void:
	if turtle_name != new_name:
		turtle_name = new_name
		name_changed.emit(new_name)

func set_turtle_stage(new_stage: Enums.TurtleStage) -> void:
	if turtle_stage != new_stage:
		turtle_stage = new_stage
		stage_changed.emit(new_stage)

func set_turtle_wants(new_wants: Enums.TurtleWants) -> void:
	if turtle_wants != new_wants:
		turtle_wants = new_wants
		wants_changed.emit(new_wants)

func set_turtle_variant(new_variant: TurtleVariant) -> void:
	if turtle_variant != new_variant:
		turtle_variant = new_variant
		variant_changed.emit(new_variant)

var stage_lifetime_transition_table: Dictionary[Enums.TurtleStage, int] = {
	Enums.TurtleStage.EGG: 24 * 60 * 60, # 1 day.
	Enums.TurtleStage.BABY: 48 * 60 * 60, # 2 days.
	Enums.TurtleStage.ADULT: 72 * 60 * 60, # 3 days.
	Enums.TurtleStage.ELDERLY: 24 * 60 * 60, # 1 day
	Enums.TurtleStage.PASSING: 2 * 60 * 60, # 2 hours.
}

var desire_configuration_table: Dictionary[Enums.TurtleStage, Array] = {
	Enums.TurtleStage.EGG: [],
	Enums.TurtleStage.BABY: [Enums.TurtleWants.FOOD, Enums.TurtleWants.PETS, Enums.TurtleWants.BATH],
	Enums.TurtleStage.ADULT: [Enums.TurtleWants.FOOD, Enums.TurtleWants.PETS, Enums.TurtleWants.BATH],
	Enums.TurtleStage.ELDERLY: [Enums.TurtleWants.FOOD, Enums.TurtleWants.PETS, Enums.TurtleWants.BATH],
	Enums.TurtleStage.PASSING: [],
}

func get_time_to_next_state() -> int:
	return get_next_transition_time() - int(stage_lifetime)


func get_next_transition_time() -> int:
	return stage_lifetime_transition_table[turtle_stage]

func get_possible_wants() -> Array[Enums.TurtleWants]:
	var ret: Array[Enums.TurtleWants] = []
	ret.assign(desire_configuration_table[turtle_stage])
	return ret


static func new_default() -> TurtleState:
	var turtle := TurtleState.new()
	turtle.turtle_name = ""
	turtle.turtle_stage = Enums.TurtleStage.EGG
	turtle.stage_lifetime = 0.0
	turtle.turtle_wants = Enums.TurtleWants.NONE
	return turtle
