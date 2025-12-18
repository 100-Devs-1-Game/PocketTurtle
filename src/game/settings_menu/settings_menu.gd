class_name SettingsMenu
extends Control

signal close_requested
signal sfx_changed(enabled: bool)


@export var close_button: BaseButton
@export var sfx_check_button: CheckButton
@export var credits_show_button: BaseButton
@export var credits_menu: Control
@export var credits_close_button: BaseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	sfx_check_button.toggled.connect(_on_sfx_check_button_toggled)
	credits_show_button.pressed.connect(_on_credits_show_button_pressed)
	credits_close_button.pressed.connect(_on_credits_close_button_pressed)

func _on_close_button_pressed() -> void:
	close_requested.emit()


func set_sfx_eanbled(p_enabled: bool) -> void:
	sfx_check_button.button_pressed = p_enabled


func _on_sfx_check_button_toggled(p_is_toggled: bool) -> void:
	sfx_changed.emit(p_is_toggled)


func _on_credits_close_button_pressed() -> void:
	credits_menu.visible = false


func _on_credits_show_button_pressed() -> void:
	credits_menu.visible = true
