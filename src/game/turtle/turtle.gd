class_name Turtle
extends Area2D

signal stage_changed(prev_stage: Enums.TurtleStage, new_stage: Enums.TurtleStage)
signal wants_changed(prev_want: Enums.TurtleWants, new_want: Enums.TurtleWants)

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
	
@export var turtle_name: String

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
const _wants_evaluation_frequency_seconds: float = 15 * 60 
var _wants_evaluation_timer := 0.0
var in_transition = false
var loading_from_save = false

# The current want of the turtle.
var current_want: Enums.TurtleWants: 
	set = set_current_want,
	get = get_current_want

func set_current_want(new_current_want: Enums.TurtleWants) -> void:
	var previous_want := current_want
	current_want = new_current_want
	wants_changed.emit(previous_want, current_want)

func get_current_want() -> Enums.TurtleWants:
	return current_want

func set_stage(next_stage: Enums.TurtleStage) -> void:
	var prev_stage := stage
	if loading_from_save:
		stage = next_stage
		_update_visual()
		stage_changed.emit(prev_stage, stage)
		return

	if stage != next_stage:
		in_transition = true
		stage_elapsed_seconds = 0
		stage = next_stage

		if stage == Enums.TurtleStage.BABY:
			# Reroll the turtle variant here.
			var variant_path: String = turtle_variants.get_random_variant()
			turtle_variant = load(variant_path)

		await _update_visual()

		_wants_evaluation_timer = 0
		current_want = Enums.TurtleWants.NONE
		stage_changed.emit(prev_stage, stage)
		in_transition = false


func _update_visual() -> void:
	
	if loading_from_save:
		# Simple transition
		for child: Node2D in visual.sprites.get_children():
			child.visible = child.get_index() == stage
		return

	match stage:
		Enums.TurtleStage.EGG:
			# TODO: glow fx and maybe a fun egg drop into frame?
			evolution_audio.play()
			for child: Node2D in visual.sprites.get_children():
				child.visible = child.get_index() == stage
		Enums.TurtleStage.BABY:
			await visual.play_egg_crack_animation()
		Enums.TurtleStage.ASCENSION:
			death_audio.play()
			for child: Node2D in visual.sprites.get_children():
				child.visible = child.get_index() == stage
		_:
			evolution_audio.play()
			for child: Node2D in visual.sprites.get_children():
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
	if current_want != Enums.TurtleWants.NONE:
		return

	_wants_evaluation_timer += lifetime_secs
	if _wants_evaluation_timer >= _wants_evaluation_frequency_seconds:
		_wants_evaluation_timer -= _wants_evaluation_frequency_seconds
		_set_next_want()


func _set_next_want() -> void:
	var available_wants: Array = desire_configuration_table[stage]
	if available_wants.is_empty():
		return
	
	current_want = available_wants.pick_random()
	

func _transition_to_next_life_stage() -> void:
	set_stage((stage + 1) % Enums.TurtleStage.size() as Enums.TurtleStage)


func get_time_to_next_state() -> int:
	return stage_lifetime_transition_table[stage] - int(stage_elapsed_seconds)


# Exposing a function to set the want from the debug menu.
func set_want(next_want: Enums.TurtleWants) -> void:
	var last_want := current_want
	current_want = next_want

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
