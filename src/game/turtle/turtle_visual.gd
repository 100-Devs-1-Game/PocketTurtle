class_name TurtleVisual
extends Node2D

@export var turtle_variant: TurtleVariant:
	set = set_turtle_variant,
	get = get_turtle_variant
	

@export_category("Nodes")
@export var sprites: Node2D
@export var egg_visual: AnimatedSprite2D
@export var baby_visual: AnimatedSprite2D
@export var egg_crack_audio: AudioStreamPlayer
@export var evolution_audio: AudioStreamPlayer

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
	
func play_egg_crack_animation() -> void:
	# TODO: could this be done in an animation player instead?
	var frames: Array[float] = [1.5, 2.5, 2.5]

	# Egg Cracking
	egg_visual.visible = true
	egg_visual.z_index  = 1
	egg_visual.animation = &"egg_crack"
	egg_crack_audio.play()
	
	var wiggle_egg = func() -> Signal:
		var tw := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(egg_visual, "rotation_degrees", -15, 0.1)
		tw.tween_property(egg_visual, "rotation_degrees", 15, 0.2)
		tw.tween_property(egg_visual, "rotation_degrees", 0, 0.1)
		return tw.finished

	for i in range(frames.size()):
		var frame_timing := frames[i]
		egg_visual.frame = i + 1
		if i != frames.size() - 1:
			wiggle_egg.call()
			var timer := get_tree().create_timer(frame_timing)
			await timer.timeout
	
	# Start baby on the outside, bring into forward frame
	baby_visual.visible = true
	baby_visual.z_index = 0
	evolution_audio.play()
	
	# Roll the egg off stage.
	
	var egg_roll_tween := get_tree().create_tween()
	egg_roll_tween.tween_property(egg_visual, "position:x", 1000, 1.0)

	var set_egg_rotation := func(val: float):
		egg_visual.rotation_degrees = (val * 360.0)
	var hide_egg_visual := func():
		egg_visual.z_index = 0
		egg_visual.visible = 0 
		egg_visual.rotation_degrees = 0
		egg_visual.position = Vector2.ZERO
		egg_visual.visible = false
		egg_visual.animation = &"default"
	
	egg_roll_tween.parallel().tween_method(set_egg_rotation, 0.0, 2.0, 2.0)
	egg_roll_tween.tween_callback(hide_egg_visual)

	# Bounce baby up, bring into front, bring baby down.
	baby_visual.z_index = 0
	var bounce_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	baby_visual.scale = Vector2.ZERO
	bounce_tween.parallel().tween_property(baby_visual, "scale", Vector2.ONE, 0.5)
	bounce_tween.tween_property(baby_visual, "position:y", -200.0, 0.25)
	bounce_tween.tween_property(baby_visual, "position:y", 0.0, 0.25)
	await bounce_tween.finished
