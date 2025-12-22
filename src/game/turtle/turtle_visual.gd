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
@export var fx_animation_player: AnimationPlayer
@export var thought_bubble: Node2D
@export var thought_bubble_food: Sprite2D
@export var thought_bubble_pet: Sprite2D
@export var thought_bubble_bath: Sprite2D
@export var thought_bubble_audio: AudioStreamPlayer
@export var fidget_timer: Timer
@export var washing_fx: Node2D
@export var sparkle_fx: Node2D
@export var pet_fx: Node2D
@export var death_audio: AudioStreamPlayer
@export var passing_fx: AnimatedSprite2D


func _ready() -> void:
	fidget_timer.timeout.connect(_on_fidget_timer_timeout)


func set_turtle_variant(new_turtle_variant: TurtleVariant) -> void:
	turtle_variant = new_turtle_variant
	adult_visual.sprite_frames = turtle_variant.adult_sprite_frames if turtle_variant else null
	elder_visual.sprite_frames = turtle_variant.elder_sprite_frames if turtle_variant else null
	ascension_visual.sprite_frames = turtle_variant.passing_sprite_frames if turtle_variant else null


func set_turtle_stage(new_turtle_stage: Enums.TurtleStage):
	turtle_stage = new_turtle_stage
	for c: AnimatedSprite2D in sprites.get_children():
		c.visible = c.get_index() == turtle_stage
		c.frame = 0

	# Update FX positions
	match turtle_stage:
		Enums.TurtleStage.BABY:
			thought_bubble.position = Vector2(-20, 90)
			washing_fx.position = Vector2(0, 80)
			sparkle_fx.position = Vector2(0, 80)
			pet_fx.position = Vector2(0, 100)
		_:
			thought_bubble.position = Vector2.ZERO
			washing_fx.position = Vector2.ZERO
			sparkle_fx.position = Vector2.ZERO
			pet_fx.position = Vector2.ZERO

	if turtle_stage != Enums.TurtleStage.PASSING:
		passing_fx.stop()
		passing_fx.visible = false
		# These have blink frames, so we enable the blink timer.
		fidget_timer.start()
	else:
		fidget_timer.stop()
		passing_fx.visible = true
		# Play the animations for passing
		passing_fx.play()


func play_evolution_effects(p_next_stage: Enums.TurtleStage) -> void:
	fidget_timer.stop()
	match p_next_stage:
		Enums.TurtleStage.PASSING:
			death_audio.play()
		Enums.TurtleStage.BABY:
			animation_player.stop()
			for c: Node2D in sprites.get_children():
				c.visible = c.get_index() == Enums.TurtleStage.EGG
			animation_player.play("egg_crack")
			await animation_player.animation_finished
			for c: Node2D in sprites.get_children():
				c.visible = c.get_index() == Enums.TurtleStage.EGG
			evolution_audio.play()
		_:
			evolution_audio.play()


func set_turtle_wants(new_want: Enums.TurtleWants, from_load: bool) -> void:
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

	if not from_load:
		if new_want != Enums.TurtleWants.NONE:
			thought_bubble_audio.play()


func wash_turtle() -> void:
	fidget_timer.stop()
	fx_animation_player.play("wash")
	await fx_animation_player.animation_finished
	fidget_timer.start()


func pet_turtle() -> void:
	fidget_timer.stop()
	
	var animation_name: String
	match turtle_stage:
		Enums.TurtleStage.BABY:
			animation_name = "baby_blush"
		Enums.TurtleStage.ADULT:
			animation_name = "adult_blush"
		Enums.TurtleStage.ELDERLY:
			animation_name = "elder_blush"
	animation_player.play(animation_name)
	fx_animation_player.play("pet")

	await fx_animation_player.animation_finished
	fidget_timer.start()


func feed_turtle() -> void:
	animation_player.stop()
	fidget_timer.stop()
	if turtle_stage == Enums.TurtleStage.BABY:
		animation_player.play("feed_baby")
		await animation_player.animation_finished
	else:
		fx_animation_player.play("carrot")
		match turtle_stage:
			Enums.TurtleStage.ADULT:
				animation_player.play("adult_eat")
			Enums.TurtleStage.ELDERLY:
				animation_player.play("elder_eat")
		await fx_animation_player.animation_finished
	fidget_timer.start()


func _on_fidget_timer_timeout() -> void:
	var animation_name: StringName
	
	match turtle_stage:
		Enums.TurtleStage.EGG:
			animation_name = "egg_idle"
		_:
			var blink = randi() % 2 == 0 
			
			if blink:
				match turtle_stage:
					Enums.TurtleStage.BABY:
						animation_name = "baby_blink"
					Enums.TurtleStage.ADULT:
						animation_name = "adult_blink"
					Enums.TurtleStage.ELDERLY:
						animation_name = "elder_blink"
					_:
						print("Blink timer called on a stage that doesn't have a blink animation")
						return
			else:
				match turtle_stage:
					Enums.TurtleStage.BABY:
						animation_name = "baby_idle"
					Enums.TurtleStage.ADULT:
						animation_name = "adult_idle"
					Enums.TurtleStage.ELDERLY:
						animation_name = "elder_idle"
					_:
						print("Idle timer called on a stage that doesn't have a blink animation")
						return

	print(animation_name)
	animation_player.play(animation_name)
	fidget_timer.start()
