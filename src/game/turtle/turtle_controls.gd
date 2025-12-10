class_name TurtleControls
extends CanvasLayer

signal feed_pressed()
signal pet_pressed()
signal wash_pressed()
signal turtle_name_changed(new_name: String)


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


func _on_eat_button_pressed() -> void:
	feed_pressed.emit()


func _on_pet_button_pressed() -> void:
	pet_pressed.emit()


func _on_wash_button_pressed() -> void:
	wash_pressed.emit()


func _on_turtle_name_changed(new_text: String) -> void:
	turtle_name_changed.emit(new_text)


func set_turtle_name(new_turtle_name: String) -> void:
	turtle_name_edit.text = new_turtle_name


func set_current_want(want: Enums.TurtleWants) -> void:
	eat_button.disabled = want != Enums.TurtleWants.FOOD
	pet_button.disabled = want != Enums.TurtleWants.PETS
	wash_button.disabled = want != Enums.TurtleWants.BATH
