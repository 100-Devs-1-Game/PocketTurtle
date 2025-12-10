extends Node2D

const DEFAULT_TURTLE_VARIANTS = preload("res://game/data/turtle_variants/default_turtle_variants.tres")
@export var turtle_controls: TurtleControls
@export var debug_controls: DebugControls
@export var visual: TurtleVisual

# The amount of time elapsed for this current stage.
var turtle: TurtleState

# The factor of how much in-game time elapses for real-life time.
var time_scale_factor := 1.0

const TIME_BETWEEN_SAVES_SECONDS = 1.0
const SAVE_PATH = "user://save.json"
var _save_timer := 0.0

func _ready() -> void:
	turtle = TurtleState.new()
	var save_game_data := SaveGameData.new()
	# Read in the previous save file if it exists
	if FileAccess.file_exists(SAVE_PATH):
		var save_file_contents := FileAccess.get_file_as_string(SAVE_PATH)
		var dict: Dictionary = JSON.parse_string(save_file_contents)
		save_game_data.read_dict(dict)
		time_scale_factor = save_game_data.time_scale
		turtle.turtle_name = save_game_data.turtle_name
		turtle.turtle_stage = save_game_data.turtle_current_stage)
		stage_elapsed_seconds = save_game_data.turtle_stage_lifetime
		set_current_want(save_game_data.turtle_current_want)
		if not save_game_data.turtle_variant.is_empty():
			set_turtle_variant(load(save_game_data.turtle_variant))

	debug_controls.visible = false
	debug_controls.turtle = turtle
	turtle_controls.turtle_name_changed.connect(_on_turtle_controls_turtle_name_changed)
	debug_controls.time_scale_changed.connect(_on_debug_canvas_layer_time_scale_changed)
			
	turtle_controls.set_turtle_name(turtle_name)


func _process(delta: float) -> void:
	add_lifetime(delta * time_scale_factor)
	_save_timer += delta
	if _save_timer >= TIME_BETWEEN_SAVES_SECONDS:
		_save_timer -= TIME_BETWEEN_SAVES_SECONDS
		save_game()

func save_game() -> void:
	var save_game_data := SaveGameData.new()
	save_game_data.turtle_current_stage = stage
	save_game_data.turtle_stage_lifetime = stage_elapsed_seconds
	save_game_data.turtle_current_want = current_want
	if turtle_variant:
		save_game_data.turtle_variant = turtle_variant.resource_path
	save_game_data.turtle_name = turtle_name
	save_game_data.time_scale = time_scale_factor

	var dict := save_game_data.to_dict()
	var json_string := JSON.stringify(dict)
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(json_string)
		f.close()
	else:
		print("Failed to open save file for writing: %d " % FileAccess.get_open_error())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.physical_keycode == Key.KEY_QUOTELEFT and event.pressed:
			debug_controls.visible = not debug_controls.visible


func _exit_tree() -> void:
	save_game()


func _on_debug_canvas_layer_time_scale_changed(new_time_scale: float) -> void:
	time_scale_factor = new_time_scale


func _on_turtle_controls_turtle_name_changed(new_turtle_name: String) -> void:
	turtle_name = new_turtle_name

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

# How often the turtle reevaluates its wants, default is 15 minutes.
const _wants_evaluation_frequency_seconds: float = 15 * 60 
var _wants_evaluation_timer := 0.0
var in_transition = false
var loading_from_save = false

# The current want of the turtle.
var current_want: Enums.TurtleWants

func set_current_want(new_current_want: Enums.TurtleWants) -> void:
	current_want = new_current_want
	visual.set_turtle_wants(new_current_want)

func set_stage(next_stage: Enums.TurtleStage) -> void:
	stage = next_stage
	visual.set_turtle_stage(next_stage)
	match stage:
		Enums.TurtleStage.EGG:
			turtle_controls.visible = false
		Enums.TurtleStage.PASSING:
			turtle_controls.visible = false
		_:
			turtle_controls.visible = true

# Adds lifetime in seconds.
func add_lifetime(lifetime_secs: float) -> void:
	if in_transition:
		return

	stage_elapsed_seconds += lifetime_secs
	debug_controls.set_stage_elapsed_seconds(stage_elapsed_seconds)
	debug_controls.set_time_to_next_stage(stage_lifetime_transition_table[stage] - int(stage_elapsed_seconds))
	
	# Check for handling a transition to another state.
	var next_transition_time := stage_lifetime_transition_table[stage]
	if stage_elapsed_seconds >= next_transition_time:
		var next_stage := (stage + 1) % Enums.TurtleStage.size() as Enums.TurtleStage
		set_stage(next_stage)
	else:
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

	set_current_want(available_wants.pick_random())


func get_time_to_next_state() -> int:
	return stage_lifetime_transition_table[stage] - int(stage_elapsed_seconds)

# Exposed function to get the possible wants of a given turtle
func get_possible_wants() -> Array[Enums.TurtleWants]:
	var ret: Array[Enums.TurtleWants] = []
	ret.assign(desire_configuration_table[stage])
	return ret
	
func set_turtle_variant(new_turtle_variant: TurtleVariant) -> void:
	turtle_variant = new_turtle_variant
	visual.set_turtle_variant(turtle_variant)

func eat_food() -> void:
	if turtle.current_want != Enums.TurtleWants.FOOD:
		return
	current_want = Enums.TurtleWants.NONE
	

func make_window_transparent(window: Window) -> void:
	ProjectSettings.set("display/window/per_pixel_transparency/allowed", true)
	#window.size = window.min_size
	window.unresizable = true
	window.transparent = true
	window.transparent_bg = true
	window.borderless = true