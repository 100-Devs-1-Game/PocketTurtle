extends CanvasLayer

@export var turtle: Turtle: set = set_turtle, get = get_turtle
func set_turtle(new_turtle: Turtle) -> void:
	turtle = new_turtle
	if turtle:
		turtle.state_changed.connect(_on_turtle_state_changed)
		turtle.wants_changed.connect(_on_turtle_wants_changed)
	
func get_turtle() -> Turtle:
	return turtle

@export_category("Nodes")
@export var button_controls: Control
@export var eat_button: BaseButton
@export var pet_button: BaseButton
@export var wash_button: BaseButton

func _ready() -> void:
	eat_button.pressed.connect(_on_eat_button_pressed)
	pet_button.pressed.connect(_on_pet_button_pressed)
	wash_button.pressed.connect(_on_wash_button_pressed)
	_on_turtle_state_changed()
	_on_turtle_wants_changed()


func _on_turtle_wants_changed() -> void:
	eat_button.disabled = turtle.current_want != "eat"
	pet_button.disabled = turtle.current_want != "pet"
	wash_button.disabled = turtle.current_want != "wash"

func _on_eat_button_pressed() -> void:
	pass


func _on_pet_button_pressed() -> void:
	pass


func _on_wash_button_pressed() -> void:
	pass


func _on_turtle_state_changed() -> void:
	button_controls.visible = turtle.stage != Enums.TurtleStage.EGG and turtle.stage != Enums.TurtleStage.ASCENSION 
