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