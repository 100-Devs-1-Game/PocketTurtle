class_name TurtleVisual
extends Node2D

var turtle_variant: TurtleVariant:
	set = set_turtle_variant

var turtle_stage: Enums.TurtleStage:
	set = set_turtle_stage

@export_category("Nodes")
@export var sprites: Node2D
@export var egg_visual: AnimatedSprite2D
@export var baby_visual: AnimatedSprite2D
@export var adult_visual: AnimatedSprite2D
@export var elder_visual: AnimatedSprite2D
@export var ascension_visual: AnimatedSprite2D
@export var egg_crack_audio: AudioStreamPlayer
@export var evolution_audio: AudioStreamPlayer
@export var animation_player: AnimationPlayer
@export var thought_bubble_food: Sprite2D
@export var thought_bubble_pet: Sprite2D
@export var thought_bubble_bath: Sprite2D
@export var thought_bubble_audio: AudioStreamPlayer
@export var blink_timer: Timer


func _ready() -> void:
	blink_timer.timeout.connect(_on_blink_timer_timeout)


func set_turtle_variant(new_turtle_variant: TurtleVariant) -> void:
	turtle_variant = new_turtle_variant
	adult_visual.sprite_frames = turtle_variant.adult_sprite_frames if turtle_variant else null
	elder_visual.texture = turtle_variant.elder_sprite_frames if turtle_variant else null
	ascension_visual.texture = turtle_variant.passing_sprite_frames if turtle_variant else null


func set_turtle_stage(new_turtle_stage: Enums.TurtleStage):
	turtle_stage = new_turtle_stage
	for c: Node2D in sprites.get_children():
		c.visible = c.get_index() == turtle_stage

	# if turtle_stage == Enums.TurtleStage.BABY or turtle_stage == Enums.TurtleStage.ADULT or turtle_stage == Enums.TurtleStage.ELDERLY:
		# These have blink frames, so we enable the blink timer.
		# blink_timer.start()
		

func set_turtle_wants(new_want: Enums.TurtleWants) -> void:
	match new_want:
		Enums.TurtleWants.FOOD:
			thought_bubble_food.visible = true
			thought_bubble_pet.visible = false
			thought_bubble_bath.visible = false
		Enums.TurtleWants.PETS:
			thought_bubble_food.visible = false
			thought_bubble_pet.visible = true
			thought_bubble_bath.visible = false
		Enums.TurtleWants.BATH:
			thought_bubble_food.visible = false
			thought_bubble_pet.visible = false
			thought_bubble_bath.visible = true
		_:
			thought_bubble_food.visible = false
			thought_bubble_pet.visible = false
			thought_bubble_bath.visible = false
	if new_want != Enums.TurtleWants.NONE:
		thought_bubble_audio.play()


func _on_blink_timer_timeout() -> void:
	var animation_name: StringName
	match turtle_stage:
		Enums.TurtleStage.BABY:
			animation_name = "blink_baby"
		Enums.TurtleStage.ADULT:
			animation_name = "blink_adult"
		Enums.TurtleStage.ELDERLY:
			animation_name = "blink_elderly"
		_:
			print("Blink timer called on a stage that doesn't have a blink animation")
			return

	animation_player.play(animation_name)
