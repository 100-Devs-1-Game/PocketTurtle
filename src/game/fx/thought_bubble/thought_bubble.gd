class_name ThoughtBubble
extends Node2D


@export var turtle: Turtle: set = set_turtle, get = get_turtle
@export_category("Nodes")
@export var audio_stream_player: AudioStreamPlayer

func set_turtle(new_turtle: Turtle) -> void:
	turtle = new_turtle
	if turtle:
		turtle.wants_changed.connect(_on_turtle_wants_changed)

func get_turtle() -> Turtle:
	return turtle


@export var thought_bubble_feed: Sprite2D
@export var thought_bubble_pet: Sprite2D
@export var thought_bubble_wash: Sprite2D


func _ready() -> void:
	refresh_view()


func _on_turtle_wants_changed() -> void:
	refresh_view()


func refresh_view() -> void:
	var wants := turtle.current_want
	if wants != Enums.TurtleWants.NONE:
		visible = true
		thought_bubble_feed.visible = wants == Enums.TurtleWants.FOOD
		thought_bubble_pet.visible = wants == Enums.TurtleWants.PETS
		thought_bubble_wash.visible = wants == Enums.TurtleWants.BATH
		audio_stream_player.play()
	else:
		visible = false
