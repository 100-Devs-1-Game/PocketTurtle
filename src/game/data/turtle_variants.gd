class_name TurtleVariants
extends Resource

const VARIANTS_DIRECTORY = "res://game/data/turtle_variants"

func get_turtle_variants() -> Array[String]:
	var ret: Array[String] = []
	var files := DirAccess.get_files_at(VARIANTS_DIRECTORY)
	for f in files:
		ret.push_back(VARIANTS_DIRECTORY + "/" + f)
	return ret
