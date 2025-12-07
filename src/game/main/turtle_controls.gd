class_name TurtleControls
extends CanvasLayer

signal turtle_name_changed(new_name: String)

const WASH_FX_DURATION_SECONDS = 3.0
const SPARKLE_FX_DURATION_SECONDS = 3.0
const PET_FX_DURATION_SECONDS = 1.5

@export var wash_fx: WashFx
@export var sparkle_fx: SparkleFx
@export var pet_fx: PetFx

@export var turtle: Turtle: set = set_turtle, get = get_turtle
func set_turtle(new_turtle: Turtle) -> void:
	turtle = new_turtle
	if turtle:
		turtle.stage_changed.connect(func(_prev_stage, _new_stage): _on_turtle_state_changed())
		turtle.wants_changed.connect(func(_prev_want, _new_want): _on_turtle_wants_changed())
		turtle_name_edit.text = turtle.turtle_name
	
func get_turtle() -> Turtle:
	return turtle

@export_category("Nodes")
@export var turtle_name_edit: LineEdit
@export var button_controls: Control
@export var eat_button: BaseButton
@export var pet_button: BaseButton
@export var wash_button: BaseButton

func _ready() -> void:
	eat_button.pressed.connect(_on_eat_button_pressed)
	pet_button.pressed.connect(_on_pet_button_pressed)
	wash_button.pressed.connect(_on_wash_button_pressed)
	turtle_name_edit.text_changed.connect(_on_turtle_name_changed)
	_on_turtle_state_changed()
	_on_turtle_wants_changed()


func _on_turtle_wants_changed() -> void:
	eat_button.disabled = turtle.current_want != Enums.TurtleWants.FOOD
	pet_button.disabled = turtle.current_want != Enums.TurtleWants.PETS
	wash_button.disabled = turtle.current_want != Enums.TurtleWants.BATH

func _on_eat_button_pressed() -> void:
	eat_button.disabled = true
	turtle.eat_food()


func _on_pet_button_pressed() -> void:
	pet_button.disabled = true
	turtle.set_want(Enums.TurtleWants.NONE)
	pet_fx.play(PET_FX_DURATION_SECONDS)
	

func _on_wash_button_pressed() -> void:
	wash_button.disabled = true
	turtle.set_want(Enums.TurtleWants.NONE)
	await wash_fx.play(WASH_FX_DURATION_SECONDS)
	sparkle_fx.play(SPARKLE_FX_DURATION_SECONDS)

func _on_turtle_state_changed() -> void:
	button_controls.visible = turtle.stage != Enums.TurtleStage.EGG and turtle.stage != Enums.TurtleStage.ASCENSION 


func _on_turtle_name_changed(new_text: String) -> void:
	turtle_name_changed.emit(new_text)


func set_turtle_name(new_turtle_name: String) -> void:
	turtle_name_edit.text = new_turtle_name
