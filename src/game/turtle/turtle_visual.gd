class_name TurtleVisual
extends Node2D

@export var turtle_variant: TurtleVariant:
	set = set_turtle_variant,
	get = get_turtle_variant
	

@export_category("Nodes")
@export var egg_visual: AnimatedSprite2D
@export var baby_visual: AnimatedSprite2D

@export var adult_visual: Sprite2D:
	set = set_adult_visual,
	get = get_adult_visual

@export var elder_visual: Sprite2D:
	set = set_elder_visual,
	get = get_elder_visual

@export var ascension_visual: Sprite2D:
	set = set_ascension_visual,
	get = get_ascension_visual


func set_adult_visual(new_adult_visual: Sprite2D) -> void:
	adult_visual = new_adult_visual
	if turtle_variant:
		adult_visual.texture = turtle_variant.texture_adult


func get_adult_visual() -> Sprite2D:
	return adult_visual


func set_elder_visual(new_elder_visual: Sprite2D) -> void:
	elder_visual = new_elder_visual
	if turtle_variant:
		elder_visual.texture = turtle_variant.texture_elder


func get_elder_visual() -> Sprite2D:
	return elder_visual


func set_ascension_visual(new_ascension_visual: Sprite2D) -> void:
	ascension_visual = new_ascension_visual
	if turtle_variant:
		ascension_visual.texture = turtle_variant.texture_ascension


func get_ascension_visual() -> Sprite2D:
	return ascension_visual


func set_turtle_variant(new_turtle_variant: TurtleVariant) -> void:
	turtle_variant = new_turtle_variant
	if adult_visual:
		adult_visual.texture = turtle_variant.texture_adult if turtle_variant else null
		elder_visual.texture = turtle_variant.texture_elder if turtle_variant else null
		ascension_visual.texture = turtle_variant.texture_ascension if turtle_variant else null


func get_turtle_variant() -> TurtleVariant:
	return turtle_variant
