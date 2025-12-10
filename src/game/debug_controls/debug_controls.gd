class_name DebugControls
extends CanvasLayer


signal debug_time_scale_changed(new_time_scale: float)
signal debug_turtle_name_changed(new_name: String)
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


var stage_elapsed_seconds: float:
	set = set_stage_elapsed_seconds

func set_stage_elapsed_seconds(new_seconds: float) -> void:
	stage_elapsed_seconds = new_seconds

var time_to_next_stage: int:
	set = set_time_to_next_stage

func set_time_to_next_stage(new_time: int) -> void:
	time_to_next_stage = new_time
	
var current_stage: Enums.TurtleStage:
	set = set_current_stage

func set_current_stage(new_stage: Enums.TurtleStage) -> void:
	current_stage = new_stage
	_on_turtle_state_changed()


# Time since last update.
var _update_timer := 0.0
# Update every second
var _update_delay := 1.0


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


func _ready() -> void:
	visible = false
	for k in Enums.TurtleStage.keys():
		set_state_option_button.add_item(k)
	for dict in GAME_SPEEDS:
		set_time_scale_option_button.add_item(dict["text"])

	set_state_option_button.item_selected.connect(_on_set_state_option_button_item_selected)
	set_current_want_option_button.item_selected.connect(_on_set_current_want_option_button_item_selected)
	set_time_scale_option_button.item_selected.connect(_on_set_time_scale_option_button_item_selected)
	_on_turtle_state_changed()
	_on_turtle_wants_changed()


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= _update_delay:
		_update_timer -= _update_delay
		_refresh_view()

func _refresh_view() -> void:
	turtle_stage_timer_label.text = "%0.2f" % stage_elapsed_seconds
	time_to_next_state_label.text = _time_to_string(time_to_next_stage)

func _on_turtle_state_changed() -> void:
	if !is_inside_tree():
		return

	turtle_stage_label.text = Enums.turtle_stage_to_string(current_stage)
	set_state_option_button.selected = current_stage
	for i in range(set_state_option_button.item_count):
		set_state_option_button.set_item_disabled(i, i == current_stage)
	_refresh_view()


func _on_set_state_option_button_item_selected(index: int) -> void:
	debug_turtle_stage_changed.emit(index as Enums.TurtleStage)
	

func _on_turtle_wants_changed() -> void:
	current_want_label.text = Enums.turtle_wants_to_string(current_want)
	set_current_want_option_button.clear()
	if not possible_wants.is_empty():
		possible_wants.push_front(Enums.TurtleWants.NONE)

	for want in possible_wants:
		set_current_want_option_button.add_item(
			Enums.turtle_wants_to_string(want),
			want
		)
		set_current_want_option_button.set_item_disabled(want, want == turtle.current_want)
	set_current_want_option_button.selected = turtle.current_want
	
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
	debug_turtle_stage_changed.emit(want)

func _on_set_time_scale_option_button_item_selected(idx: int) -> void:
	debug_time_scale_changed.emit(GAME_SPEEDS[idx]["value"])

	
