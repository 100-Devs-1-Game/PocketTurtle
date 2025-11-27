class_name Enums

enum TurtleStage {
	EGG,
	BABY,
	ADULT,
	ELDERLY,
	ASCENSION
}

static func turtle_stage_to_string(turtle_stage: TurtleStage) -> String:
	return str(TurtleStage.values()[turtle_stage])
