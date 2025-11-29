class_name WashFx
extends Node2D
@export_category("Nodes")
@export var audio_stream_player: AudioStreamPlayer
@export var animated_sprite_2d: AnimatedSprite2D

func _ready() -> void:
	visible = false

func play(duration: float) -> void:
	visible = true
	audio_stream_player.playing = true
	var timer := get_tree().create_timer(duration)
	await timer.timeout
	visible = false
	audio_stream_player.playing = false
