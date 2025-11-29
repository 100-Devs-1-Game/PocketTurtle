extends CanvasLayer


@export var turtle: Turtle: set = set_turtle, get = get_turtle
@export_category("Nodes")
@export var turtle_stage_label: Label
@export var turtle_stage_timer_label: Label
@export var set_state_option_button: OptionButton
@export var time_to_next_state_label: Label
@export var current_want_label: Label
@export var set_current_want_option_button: OptionButton


# Time since last update.
var _update_timer := 0.0
# Update every second
var _update_delay := 1.0


func _ready() -> void:
	visible = false
	for k in Enums.TurtleStage.keys():
		set_state_option_button.add_item(k)
	set_state_option_button.item_selected.connect(_on_set_state_option_button_item_selected)
	set_current_want_option_button.item_selected.connect(_on_set_current_want_option_button_item_selected)
	_on_turtle_state_changed()
	_on_turtle_wants_changed()


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= _update_delay:
		_update_timer -= _update_delay
		_refresh_view()


func set_turtle(new_turtle: Turtle) -> void:
	turtle = new_turtle
	if turtle:
		turtle.state_changed.connect(_on_turtle_state_changed)
		turtle.wants_changed.connect(_on_turtle_wants_changed)
		_on_turtle_state_changed()


func get_turtle() -> Turtle:
	return turtle


func _refresh_view() -> void:
	turtle_stage_timer_label.text = "%0.2f" % turtle.stage_elapsed_seconds
	time_to_next_state_label.text = _time_to_string(turtle.get_time_to_next_state())

func _on_turtle_state_changed() -> void:
	if !is_inside_tree():
		return

	turtle_stage_label.text = Enums.turtle_stage_to_string(turtle.stage)
	set_state_option_button.selected = turtle.stage
	for i in range(set_state_option_button.item_count):
		set_state_option_button.set_item_disabled(i, i == turtle.stage)
	_refresh_view()


func _on_set_state_option_button_item_selected(index: int) -> void:
	turtle.set_stage(index as Enums.TurtleStage)
	

func _on_turtle_wants_changed() -> void:
	current_want_label.text = Enums.turtle_wants_to_string(turtle.current_want)
	set_current_want_option_button.clear()
	var possible_wants = turtle.get_possible_wants()
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
	var last_want := turtle.current_want
	if last_want != want:
		turtle.set_want(want)
		set_current_want_option_button.set_item_disabled(last_want, false)
		set_current_want_option_button.set_item_disabled(want, true)
