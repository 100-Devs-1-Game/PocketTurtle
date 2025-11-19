extends Node2D

@onready var turtle = $turtle
var oneshot = false


func _ready() -> void :
    $title_screen.start(3)


func _on_wash_button_pressed() -> void :
    $ThoughtBubbleWash.visible = false
    Global.times_cleaned += 1
    turtle.on_wash()
    $clean.play(0)
    $washing.play("default")
    await $washing.animation_finished
    $all_clean.play(0)
    $washing.play("sparkles")


func _on_pet_button_pressed() -> void :
    $ThoughtBubblePet.visible = false
    Global.times_played += 1
    turtle.on_pet()
    $pet.play(0)
    $petting.play("default")

func _on_feed_button_pressed() -> void :
    $ThoughtBubbleFeed.visible = false
    Global.times_fed += 1
    turtle.on_feed()
    $fed.play(0)
    $eating.play("default")
    await $eating.animation_finished
    $all_fed.play(0)


func _on_thought_bubble_timeout() -> void :
    var list = [$ThoughtBubbleFeed, $ThoughtBubblePet, $ThoughtBubbleWash]
    for item in list:
        item.visible = false
    var shown = list.pick_random()
    shown.visible = true
    $thought_bubble.start(180)


func _on_turtle_died() -> void :
    print("NOOO LITTLE SLUGGER")
    $thought_bubble.stop()
    oneshot = false

func _on_turtle_born() -> void :
    print("BIRTH HATH HAPPENED")
    if !oneshot: $thought_bubble.start(10)
    oneshot = true


func _on_title_screen_timeout() -> void :
    $PocketTurtleTitle.visible = false
