extends CanvasLayer


@export var turtle: Turtle: set = set_turtle, get = get_turtle
@export_category("Nodes")
@export var turtle_stage_label: Label
@export var turtle_stage_timer_label: Label
@export var set_state_option_button: OptionButton


# Time since last update.
var _update_timer := 0.0
# Update every second
var _update_delay := 1.0


func _ready() -> void:
	for k in Enums.TurtleStage.keys():
		set_state_option_button.add_item(k)
	set_state_option_button.item_selected.connect(_on_set_state_option_button_item_selected)
	_on_turtle_state_changed()


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= _update_delay:
		_update_timer -= _update_delay
		_refresh_view()


func set_turtle(new_turtle: Turtle) -> void:
	turtle = new_turtle
	if turtle:
		turtle.state_changed.connect(_on_turtle_state_changed)
		_on_turtle_state_changed()


func get_turtle() -> Turtle:
	return turtle


func _refresh_view() -> void:
	turtle_stage_timer_label.text = "%0.2f" % turtle.stage_elapsed_seconds


func _on_turtle_state_changed() -> void:
	if !is_inside_tree():
		return

	turtle_stage_label.text = Enums.turtle_stage_to_string(turtle.stage)
	set_state_option_button.selected = turtle.stage
	for i in range(set_state_option_button.item_count):
		set_state_option_button.set_item_disabled(i, i == turtle.stage)


func _on_set_state_option_button_item_selected(index: int) -> void:
	turtle.set_stage(index as Enums.TurtleStage)
	
