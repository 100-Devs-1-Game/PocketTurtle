class_name Turtle
extends Area2D

signal state_changed

signal wants_changed

# The amount of time elapsed for this current stage.
@export var stage_elapsed_seconds: float

# The current turtle stage
@export var stage: Enums.TurtleStage = Enums.TurtleStage.EGG: 
	set = set_stage, 
	get = get_stage	

@export var turtle_variants: TurtleVariants
@export var turtle_variant: TurtleVariant:
	set = set_turtle_variant,
	get = get_turtle_variant

@export_category("Nodes")
@export var visual: TurtleVisual:
	set = set_visual,
	get = get_visual

@export var egg_crack_audio: AudioStreamPlayer
@export var egg_visual: AnimatedSprite2D
@export var baby_visual: AnimatedSprite2D
@export var evolution_audio: AudioStreamPlayer
@export var death_audio: AudioStreamPlayer
const BABY_BLUSH = preload("uid://cnuv5y7l44t1a")

var stage_lifetime_transition_table: Dictionary[Enums.TurtleStage, int] = {
	Enums.TurtleStage.EGG: 24 * 60 * 60,
	Enums.TurtleStage.BABY: 48 * 60 * 60,
	Enums.TurtleStage.ADULT: 96 * 60 * 60,
	Enums.TurtleStage.ELDERLY: 24 * 60 * 60,
	Enums.TurtleStage.ASCENSION: 2 * 60 * 60,
}

var desire_configuration_table: Dictionary[Enums.TurtleStage, Array] = {
	Enums.TurtleStage.EGG: [],
	Enums.TurtleStage.BABY: [Enums.TurtleWants.FOOD, Enums.TurtleWants.PETS, Enums.TurtleWants.BATH],
	Enums.TurtleStage.ADULT: [Enums.TurtleWants.FOOD, Enums.TurtleWants.PETS, Enums.TurtleWants.BATH],
	Enums.TurtleStage.ELDERLY: [Enums.TurtleWants.FOOD, Enums.TurtleWants.PETS, Enums.TurtleWants.BATH],
	Enums.TurtleStage.ASCENSION: [],
}

# How often the turtle reevaluates its wants, default is 15 minutes.
const _wants_evaluation_frequency: float = 15 * 60 * 60 
var _wants_evaluation_timer := 0.0
var in_transition = false

# The current want of the turtle.
var current_want: Enums.TurtleWants

func set_stage(next_stage: Enums.TurtleStage) -> void:
	if stage != next_stage:
		in_transition = true
		stage_elapsed_seconds = 0
		stage = next_stage

		if stage == Enums.TurtleStage.BABY:
			# Reroll the turtle variant here.
			var variants: Array[String] = turtle_variants.get_turtle_variants()
			var variant_path: String = variants.pick_random()
			turtle_variant = load(variant_path)

		await _update_visual()

		_wants_evaluation_timer = 0
		current_want = Enums.TurtleWants.NONE
		wants_changed.emit()
		state_changed.emit()
		
		in_transition = false


func _update_visual() -> void:
	match stage:
		Enums.TurtleStage.EGG:
			# TODO: glow fx and maybe a fun egg drop into frame?
			evolution_audio.play()
			for child: Node2D in visual.get_children():
				child.visible = child.get_index() == stage
		Enums.TurtleStage.BABY:
			await play_egg_crack_animation()
		Enums.TurtleStage.ASCENSION:
			death_audio.play()
			for child: Node2D in visual.get_children():
				child.visible = child.get_index() == stage
		_:
			evolution_audio.play()
			for child: Node2D in visual.get_children():
				child.visible = child.get_index() == stage


func get_stage() -> Enums.TurtleStage:
	return stage

# Adds lifetime in seconds.
func add_lifetime(lifetime_secs: float) -> void:
	if in_transition:
		return

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


# Exposing a function to set the want from the debug menu.
func set_want(next_want: Enums.TurtleWants) -> void:
	var last_want := current_want
	current_want = next_want
	
	wants_changed.emit()

	if last_want == Enums.TurtleWants.PETS:
		match stage:
			Enums.TurtleStage.BABY:
				# Blush the baby sprite.
				var reset_baby_to_default = func():
					baby_visual.animation = &"default"
				baby_visual.animation_finished.connect(reset_baby_to_default, CONNECT_ONE_SHOT)
				baby_visual.play(&"blush")


# Exposed function to get the possible wants of a given turtle
func get_possible_wants() -> Array[Enums.TurtleWants]:
	var ret: Array[Enums.TurtleWants] = []
	ret.assign(desire_configuration_table[stage])
	return ret


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

	
func set_turtle_variant(new_turtle_variant: TurtleVariant) -> void:
	turtle_variant = new_turtle_variant
	if visual:
		visual.turtle_variant = turtle_variant

func get_turtle_variant() -> TurtleVariant:
	return turtle_variant


func set_visual(new_visual: TurtleVisual) -> void:
	visual = new_visual
	if visual:
		visual.turtle_variant = turtle_variant


func get_visual() -> TurtleVisual:
	return visual
