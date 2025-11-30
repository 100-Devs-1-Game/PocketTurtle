class_name EatFx
extends Node2D


@export_category("Nodes")
@export var audio_stream_player: AudioStreamPlayer
@export var animated_sprite_2d: AnimatedSprite2D


func _ready() -> void:
	visible = false


func play() -> void:
	visible = true
	audio_stream_player.playing = true
	animated_sprite_2d.play()
	await animated_sprite_2d.animation_looped
	animated_sprite_2d.stop()
	visible = false
	audio_stream_player.playing = false
