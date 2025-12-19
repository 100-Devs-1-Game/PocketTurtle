extends Node2D

const TIME_BETWEEN_SAVES_SECONDS = 1.0
const SAVE_PATH = "user://save.json"
# How often the turtle reevaluates its wants, default is 15 minutes.
const WANTS_EVALUATION_FREQUENCY_SECONDS: float = 15 * 60

@export var turtle_controls: TurtleControls
@export var debug_controls: DebugControls
@export var visual: TurtleVisual
@export var turtle_texture_button: BaseButton
@export var settings_menu: SettingsMenu
@export var grabber_control: GrabberControl

var turtle: TurtleState

# The factor of how much in-game time elapses for real-life time.
var time_scale_factor := 1.0
var _wants_evaluation_timer := 0.0
var _save_timer := 0.0

enum GameState {
	NAMING,
	PLAYING
}

var game_state: GameState = GameState.NAMING
var sfx_enabled: bool = true

func _ready() -> void:
	turtle = TurtleState.new()
	var save_game_data := SaveGameData.new()
	# Read in the previous save file if it exists
	if FileAccess.file_exists(SAVE_PATH):
		var save_file_contents := FileAccess.get_file_as_string(SAVE_PATH)
		var dict: Dictionary = JSON.parse_string(save_file_contents)
		if save_game_data.read_dict(dict) == OK:
			time_scale_factor = save_game_data.time_scale
			save_game_data.load_turtle(turtle)
			sfx_enabled = save_game_data.sfx_enabled
		else:
			# Missing or corrupt save file, use default.
			turtle = TurtleState.new_default()
	else:
		# No save file, initialize with defaults.
		turtle = TurtleState.new_default()

	if turtle.turtle_stage != Enums.TurtleStage.EGG or turtle.turtle_name != "":
		game_state = GameState.PLAYING
	

	turtle_texture_button.pressed.connect(_on_turtle_texture_button_pressed)
	settings_menu.visible = false
	settings_menu.close_requested.connect(_on_settings_menu_close_requested)
	settings_menu.sfx_changed.connect(_on_settings_menu_sfx_changed)
	set_sfx_enabled(sfx_enabled)
	settings_menu.set_sfx_eanbled(sfx_enabled)
	
	debug_controls.visible = false
	debug_controls.turtle = turtle
	debug_controls.time_scale_factor = time_scale_factor
	debug_controls.debug_time_scale_changed.connect(_on_debug_controls_time_scale_changed)
	debug_controls.debug_turtle_stage_changed.connect(_on_debug_controls_turtle_stage_changed)
	debug_controls.debug_turtle_want_changed.connect(_on_debug_controls_turtle_want_changed)

	print("Turtle name on load: %s" % turtle.turtle_name)
	turtle_controls.set_naming_controls_enabled(game_state == GameState.NAMING)
	turtle_controls.set_controls_enabled(turtle.turtle_stage != Enums.TurtleStage.EGG and turtle.turtle_stage != Enums.TurtleStage.PASSING)
	turtle_controls.set_current_want(turtle.turtle_wants)
	turtle_controls.turtle_name = turtle.turtle_name
	turtle_controls.turtle_name_changed.connect(_on_turtle_controls_turtle_name_changed)
	turtle_controls.feed_pressed.connect(_on_turtle_controls_feed_pressed)
	turtle_controls.pet_pressed.connect(_on_turtle_controls_pet_pressed)
	turtle_controls.wash_pressed.connect(_on_turtle_controls_wash_pressed)

	visual.set_turtle_stage(turtle.turtle_stage)
	visual.set_turtle_wants(turtle.turtle_wants, true)
	visual.set_turtle_variant(turtle.turtle_variant)
	
	# Show the grabber control for a bit after the game starts.
	var is_web := OS.get_name() == "web"
	grabber_control.visible = not is_web
	if not is_web:
		get_window().position = save_game_data.window_position
		grabber_control.moved.connect(_on_grabber_control_moved)


func _process(delta: float) -> void:
	if game_state == GameState.PLAYING:
		add_lifetime(delta * time_scale_factor)
		_save_timer += delta
		if _save_timer >= TIME_BETWEEN_SAVES_SECONDS:
			_save_timer -= TIME_BETWEEN_SAVES_SECONDS
			save_game()


func save_game() -> void:
	var save_game_data := SaveGameData.new()
	save_game_data.save_turtle(turtle)
	save_game_data.time_scale = time_scale_factor
	save_game_data.sfx_enabled = sfx_enabled
	save_game_data.window_position = get_window().position

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


func set_current_want(new_current_want: Enums.TurtleWants) -> void:
	turtle.turtle_wants = new_current_want
	turtle_controls.set_current_want(new_current_want)
	visual.set_turtle_wants(new_current_want, false)


func set_stage(next_stage: Enums.TurtleStage) -> void:
	turtle.turtle_stage = next_stage
	turtle.stage_lifetime = 0.0
	turtle_controls.set_controls_enabled(false)
	await visual.play_evolution_effects(next_stage)
	visual.set_turtle_stage(next_stage)
	match next_stage:
		Enums.TurtleStage.EGG:
			game_state = GameState.NAMING
			turtle_controls.set_naming_controls_enabled(true)
			turtle.turtle_variant = load(TurtleState.DEFAULT_TURTLE_VARIANTS.get_random_variant())
			visual.set_turtle_variant(turtle.turtle_variant)
			set_current_want(Enums.TurtleWants.NONE)
			turtle_controls.set_controls_enabled(false)
		Enums.TurtleStage.PASSING:
			set_current_want(Enums.TurtleWants.NONE)
			turtle_controls.set_controls_enabled(false)
		_:
			game_state = GameState.PLAYING
			turtle_controls.set_naming_controls_enabled(false)
			turtle_controls.set_controls_enabled(true)

# Adds lifetime in seconds.
func add_lifetime(lifetime_secs: float) -> void:
	turtle.stage_lifetime += lifetime_secs
	
	# Check for handling a transition to another state.
	var next_transition_time := turtle.get_next_transition_time()
	if turtle.stage_lifetime >= next_transition_time:
		var next_stage := (turtle.turtle_stage + 1) % Enums.TurtleStage.size() as Enums.TurtleStage
		set_stage(next_stage)
	else:
		_update_wants(lifetime_secs)


func _update_wants(lifetime_secs: float) -> void:
	if turtle.turtle_wants != Enums.TurtleWants.NONE:
		return

	_wants_evaluation_timer += lifetime_secs
	if _wants_evaluation_timer >= WANTS_EVALUATION_FREQUENCY_SECONDS:
		_wants_evaluation_timer -= WANTS_EVALUATION_FREQUENCY_SECONDS
		_set_next_want()


func _set_next_want() -> void:
	var available_wants: Array = turtle.get_possible_wants()
	if available_wants.is_empty():
		return

	set_current_want(available_wants.pick_random())


func set_turtle_variant(new_turtle_variant: TurtleVariant) -> void:
	turtle.turtle_variant = new_turtle_variant
	visual.set_turtle_variant(new_turtle_variant)

#region Debug Controls Callbacks

func _on_debug_controls_time_scale_changed(new_time_scale: float) -> void:
	time_scale_factor = new_time_scale

func _on_debug_controls_turtle_stage_changed(new_stage: Enums.TurtleStage) -> void:
	set_stage(new_stage)

func _on_debug_controls_turtle_want_changed(new_want: Enums.TurtleWants) -> void:
	set_current_want(new_want)

#endregion

#region Turtle Controls Callbacks

func _on_turtle_controls_turtle_name_changed(new_turtle_name: String) -> void:
	turtle.turtle_name = new_turtle_name
	if game_state == GameState.NAMING:
		game_state = GameState.PLAYING
		turtle_controls.set_naming_controls_enabled(false)
		save_game()

func _on_turtle_controls_feed_pressed() -> void:
	if turtle.turtle_wants != Enums.TurtleWants.FOOD:
		return
	set_current_want(Enums.TurtleWants.NONE)
	visual.feed_turtle()

func _on_turtle_controls_pet_pressed() -> void:
	if turtle.turtle_wants != Enums.TurtleWants.PETS:
		return
	set_current_want(Enums.TurtleWants.NONE)
	visual.pet_turtle()

func _on_turtle_controls_wash_pressed() -> void:
	if turtle.turtle_wants != Enums.TurtleWants.BATH:
		return
	set_current_want(Enums.TurtleWants.NONE)
	visual.wash_turtle()

#endregion

func _on_turtle_texture_button_pressed() -> void:
	settings_menu.visible = true

func _on_settings_menu_close_requested() -> void:
	settings_menu.visible = false

func _on_settings_menu_sfx_changed(p_sfx_enabled: bool) -> void:
	set_sfx_enabled(p_sfx_enabled)

func set_sfx_enabled(p_sfx_enabled: bool) -> void:
	sfx_enabled = p_sfx_enabled
	var sfx_bus_index := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(sfx_bus_index, not sfx_enabled)


func _on_grabber_control_moved(p_delta: Vector2i) -> void:
	var window_position = get_window().position + p_delta
	var window_size := DisplayServer.window_get_size()
	var safe_area := DisplayServer.get_display_safe_area()
	var end_point := safe_area.end - window_size
	window_position.x = clamp(window_position.x, safe_area.position.x, end_point.x)
	window_position.y =  clamp(window_position.y, safe_area.position.y, end_point.y)
	get_window().position = window_position
