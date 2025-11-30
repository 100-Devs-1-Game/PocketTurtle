class_name TurtleVariants
extends Resource

const VARIANTS_DIRECTORY = "res://game/data/turtle_variants"

@export_file("*.tres", "*.res") var variants: Array[String]:
	set = set_variants,
	get = get_variants

func set_variants(new_variants: Array[String]) -> void:
	variants = new_variants


func get_variants() -> Array[String]:
	return variants

func get_random_variant() -> String:
	return variants.pick_random()
