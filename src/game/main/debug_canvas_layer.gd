extends CanvasLayer

@export var turtle: Turtle
@export_category("Nodes")
@export var turtle_stage_label: Label


func _process(delta: float) -> void:
	turtle_stage_label.text = Enums.turtle_stage_to_string(turtle.stage)
