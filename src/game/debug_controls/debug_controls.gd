class_name DebugControls
extends PanelContainer


const GAME_SPEEDS = [
	{
		"text": "1x",
		"value": 1.0,
	},
	{
		"text": "2x",
		"value": 2.0,
	},
	{
		"text": "5x",
		"value": 5.0,
	},
	{
		"text": "10x",
		"value": 10.0,
	},
	{
		"text": "100x",
		"value": 100.0,
	},
	{
		"text": "1000x",
		"value": 1000.0,
	},
]


signal debug_time_scale_changed(new_time_scale: float)
signal debug_turtle_stage_changed(new_stage: Enums.TurtleStage)
signal debug_turtle_want_changed(new_want: Enums.TurtleWants)

@export_category("Nodes")
@export var turtle_stage_label: Label
@export var turtle_stage_timer_label: Label
@export var set_state_option_button: OptionButton
@export var time_to_next_state_label: Label
@export var current_want_label: Label
@export var set_current_want_option_button: OptionButton
@export var set_time_scale_option_button: OptionButton


var turtle: TurtleState:
	set = set_turtle

func set_turtle(new_turtle: TurtleState) -> void:
	turtle = new_turtle
	turtle.stage_changed.connect(_on_turtle_state_changed)
	_on_turtle_state_changed(turtle.turtle_stage)
	turtle.wants_changed.connect(_on_turtle_wants_changed)
	_on_turtle_wants_changed(turtle.turtle_wants)

var time_scale_factor: float = 1.0:
	set = set_time_scale_factor

func set_time_scale_factor(new_time_scale: float) -> void:
	time_scale_factor = new_time_scale
	var selected_index := 0
	for i in range(set_time_scale_option_button.item_count):
		var dict: Dictionary = GAME_SPEEDS[i]
		var is_same_value := is_equal_approx(dict["value"], time_scale_factor)
		set_time_scale_option_button.set_item_disabled(i, is_same_value)
		if is_same_value:
			selected_index = i
	
	print("Setting time scale to %f, selected %d" % [time_scale_factor, selected_index])
	set_time_scale_option_button.selected = selected_index

# Time since last update.
var _update_timer := 0.0
# Update every second
var _update_delay := 1.0

func _ready() -> void:
	visible = false
	for k in Enums.TurtleStage.keys():
		set_state_option_button.add_item(k)
	for dict in GAME_SPEEDS:
		set_time_scale_option_button.add_item(dict["text"])

	set_state_option_button.item_selected.connect(_on_set_state_option_button_item_selected)
	set_current_want_option_button.item_selected.connect(_on_set_current_want_option_button_item_selected)
	set_time_scale_option_button.item_selected.connect(_on_set_time_scale_option_button_item_selected)


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= _update_delay:
		_update_timer -= _update_delay
		_refresh_view()

func _refresh_view() -> void:
	turtle_stage_timer_label.text = "%0.2f" % turtle.stage_lifetime
	time_to_next_state_label.text = _time_to_string(turtle.get_time_to_next_state())

func _on_turtle_state_changed(new_stage: Enums.TurtleStage) -> void:
	if !is_inside_tree():
		return

	turtle_stage_label.text = Enums.turtle_stage_to_string(new_stage)
	set_state_option_button.selected = new_stage
	for i in range(set_state_option_button.item_count):
		set_state_option_button.set_item_disabled(i, i == new_stage)

	set_current_want_option_button.clear()
	var possible_wants := turtle.get_possible_wants()
	if not possible_wants.is_empty():
		possible_wants.push_front(Enums.TurtleWants.NONE)
	for want in possible_wants:
		set_current_want_option_button.add_item(
			Enums.turtle_wants_to_string(want),
			want
		)
		set_current_want_option_button.set_item_disabled(want, want == turtle.turtle_wants)
	set_current_want_option_button.selected = turtle.turtle_wants
	
	_refresh_view()


func _on_set_state_option_button_item_selected(index: int) -> void:
	debug_turtle_stage_changed.emit(index as Enums.TurtleStage)
	

func _on_turtle_wants_changed(new_wants: Enums.TurtleWants) -> void:
	current_want_label.text = Enums.turtle_wants_to_string(new_wants)
	set_current_want_option_button.clear()

	var possible_wants := turtle.get_possible_wants()
	if not possible_wants.is_empty():
		possible_wants.push_front(Enums.TurtleWants.NONE)

	for want in possible_wants:
		set_current_want_option_button.add_item(
			Enums.turtle_wants_to_string(want),
			want
		)
		set_current_want_option_button.set_item_disabled(want, want == new_wants)
	set_current_want_option_button.selected = new_wants
	
func _time_to_string(time: int) -> String:
	var ret := ""
	const SECONDS_TO_HOURS = 60 * 60
	const SECONDS_TO_MINUTES = 60
	const DAYS_TO_SECONDS = 24 * SECONDS_TO_HOURS

	@warning_ignore("integer_division")
	var days: int = floor(time / DAYS_TO_SECONDS)
	time -= (days * DAYS_TO_SECONDS)
	if days > 0:
		ret += "%d %s" % [days, "days" if days != 1 else "day"]
	
	if time < 0:
		return ret

	
	@warning_ignore("integer_division")
	var hours: int = floor(time / SECONDS_TO_HOURS)
	time -= (hours * SECONDS_TO_HOURS)
	if hours > 0:
		if ret.length() > 0:
			ret += ", "
		ret += "%d %s" % [hours, "hours" if hours != 1 else "hour"]

	if time < 0:
		return ret


	@warning_ignore("integer_division")
	var minutes: int = floor(time / SECONDS_TO_MINUTES)
	time -= (minutes * SECONDS_TO_MINUTES)
	if minutes > 0:
		if ret.length() > 0:
			ret += ", "
		ret += "%d %s" % [minutes, "minutes" if minutes != 1 else "minute"]

	if time < 0:
		return ret

	var seconds := time
	if ret.length() > 0:
		ret += ", "
	ret += "%d %s" % [seconds, "seconds" if seconds != 1 else "second"]
	return ret


func _on_set_current_want_option_button_item_selected(idx: int) -> void:
	var want := idx as Enums.TurtleWants
	debug_turtle_want_changed.emit(want)


func _on_set_time_scale_option_button_item_selected(idx: int) -> void:
	time_scale_factor = GAME_SPEEDS[idx]["value"]
	debug_time_scale_changed.emit(time_scale_factor)
