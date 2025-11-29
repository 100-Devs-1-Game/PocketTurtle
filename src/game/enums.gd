class_name Enums

enum TurtleStage {
	EGG,
	BABY,
	ADULT,
	ELDERLY,
	ASCENSION
}

static func turtle_stage_to_string(turtle_stage: TurtleStage) -> String:
	return str(TurtleStage.keys()[turtle_stage])


enum TurtleWants {
	NONE,
	FOOD,
	PETS,
	BATH
}

static func turtle_wants_to_string(turtle_wants: TurtleWants) -> String:
	return str(TurtleWants.keys()[turtle_wants])
