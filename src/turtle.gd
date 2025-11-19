extends Node2D
class_name TurtleController

enum LifeStage{EGG, BABY, ADULT, ELDER, PASSING}
enum TurtleType{NONE, A, B, C}

@onready var turtle_sprite: Sprite2D = $turtle_sprite
@onready var age_timer: Timer = $time_until_age



@export var egg_total_seconds: float = 600.0
@export var baby_seconds: float = 600.0
@export var adult_seconds: float = 900.0
@export var elder_seconds: float = 900.0
@export var passing_seconds: float = 6.0


var current_stage: LifeStage = LifeStage.EGG
var current_type: TurtleType = TurtleType.NONE
var stage_started: bool = false
var is_doing_action: bool = false
var egg_phase: int = 0


var blink_elapsed: float = 0.0
var blink_wait: float = 0.0


signal died
signal born



@export_group("Egg")
@export var egg_stage_1: Texture2D
@export var egg_stage_2: Texture2D
@export var egg_stage_3: Texture2D
@export var egg_stage_4: Texture2D

@export_group("Egg / Baby")
@export var baby_idle: Texture2D

@export_group("Adult A (feed-heavy)")
@export var adult_a_idle: Texture2D
@export var adult_a_blink: Texture2D
@export var adult_a_blush: Texture2D
@export var adult_a_eat: Texture2D

@export_group("Adult B (play-heavy)")
@export var adult_b_idle: Texture2D
@export var adult_b_blink: Texture2D
@export var adult_b_blush: Texture2D
@export var adult_b_eat: Texture2D

@export_group("Adult C (clean-heavy)")
@export var adult_c_idle: Texture2D
@export var adult_c_blink: Texture2D
@export var adult_c_blush: Texture2D
@export var adult_c_eat: Texture2D

@export_group("Elder A")
@export var elder_a_idle: Texture2D
@export var elder_a_blink: Texture2D
@export var elder_a_blush: Texture2D
@export var elder_a_eat: Texture2D
@export var elder_a_passing: Texture2D

@export_group("Elder B")
@export var elder_b_idle: Texture2D
@export var elder_b_blink: Texture2D
@export var elder_b_blush: Texture2D
@export var elder_b_eat: Texture2D
@export var elder_b_passing: Texture2D

@export_group("Elder C")
@export var elder_c_idle: Texture2D
@export var elder_c_blink: Texture2D
@export var elder_c_blush: Texture2D
@export var elder_c_eat: Texture2D
@export var elder_c_passing: Texture2D


func _ready() -> void :

    if not age_timer.timeout.is_connected(_on_time_until_age_timeout):
        age_timer.timeout.connect(_on_time_until_age_timeout)

    _set_stage(LifeStage.EGG)


    blink_elapsed = 0.0
    blink_wait = randf_range(2.0, 4.0)


func _process(delta: float) -> void :

    if is_doing_action or current_stage == LifeStage.PASSING:
        return

    blink_elapsed += delta
    if blink_elapsed >= blink_wait:
        blink_elapsed = 0.0
        blink_wait = randf_range(2.0, 4.0)
        _do_blink()





func on_feed() -> void :
    _register_attention()
    await _play_eat_animation()

func on_pet() -> void :
    _register_attention()
    await _play_blush_animation()

func on_wash() -> void :
    _register_attention()
    await _play_wash_animation()






func _register_attention() -> void :

    if current_stage == LifeStage.EGG:
        return

    if not stage_started:
        stage_started = true
        var time_for_stage: = _get_stage_seconds(current_stage)
        if time_for_stage > 0.0:
            age_timer.wait_time = time_for_stage
            age_timer.start()


func _get_stage_seconds(stage: LifeStage) -> float:
    match stage:
        LifeStage.EGG:

            return egg_total_seconds / 4.0
        LifeStage.BABY:
            return baby_seconds
        LifeStage.ADULT:
            return adult_seconds
        LifeStage.ELDER:
            return elder_seconds
        LifeStage.PASSING:
            return passing_seconds
    return 0.0


func _set_stage(new_stage: LifeStage) -> void :
    $Evolution.play(0)
    current_stage = new_stage
    is_doing_action = false
    age_timer.stop()

    if new_stage == LifeStage.EGG:

        egg_phase = 0
        stage_started = true
        age_timer.wait_time = _get_stage_seconds(LifeStage.EGG)

        age_timer.start()
    else:
        stage_started = false
    if new_stage == LifeStage.PASSING:
        $Death.play(0)
    turtle_sprite.texture = _get_idle_texture()
    turtle_sprite.modulate = Color.WHITE
    print("Stage -> ", current_stage, " egg_phase: ", egg_phase)


func _on_time_until_age_timeout() -> void :
    match current_stage:
        LifeStage.EGG:


            if egg_phase < 3:
                $Egg.play(0)
                egg_phase += 1
                turtle_sprite.texture = _get_idle_texture()
                age_timer.wait_time = _get_stage_seconds(LifeStage.EGG)
                age_timer.start()
            else:
                egg_phase = 0
                _set_stage(LifeStage.BABY)

        LifeStage.BABY:

            _choose_turtle_type_from_care()
            Global.reset_care_stats()
            _set_stage(LifeStage.ADULT)

        LifeStage.ADULT:
            _set_stage(LifeStage.ELDER)

        LifeStage.ELDER:
            _set_stage(LifeStage.PASSING)

        LifeStage.PASSING:
            Global.reset_care_stats()
            current_type = TurtleType.NONE
            _set_stage(LifeStage.EGG)


func _choose_turtle_type_from_care() -> void :
    var feed_count: int = Global.times_fed
    var play_count: int = Global.times_played
    var clean_count: int = Global.times_cleaned

    var max_value: int = max(feed_count, play_count, clean_count)

    if max_value == 0:
        current_type = TurtleType.A
    elif feed_count >= play_count and feed_count >= clean_count:
        current_type = TurtleType.A
    elif play_count >= feed_count and play_count >= clean_count:
        current_type = TurtleType.B
    else:
        current_type = TurtleType.C






func _get_idle_texture() -> Texture2D:
    match current_stage:
        LifeStage.EGG:

            match egg_phase:
                0:
                    return egg_stage_1
                1:
                    return egg_stage_2
                2:
                    return egg_stage_3
                3:
                    return egg_stage_4
            return egg_stage_1
        LifeStage.BABY:
            emit_signal("born")
            return baby_idle
        LifeStage.ADULT:
            match current_type:
                TurtleType.A: return adult_a_idle
                TurtleType.B: return adult_b_idle
                TurtleType.C: return adult_c_idle
        LifeStage.ELDER:
            match current_type:
                TurtleType.A: return elder_a_idle
                TurtleType.B: return elder_b_idle
                TurtleType.C: return elder_c_idle
        LifeStage.PASSING:
            emit_signal("died")
            match current_type:
                TurtleType.A: return elder_a_passing
                TurtleType.B: return elder_b_passing
                TurtleType.C: return elder_c_passing
    return egg_stage_1


func _get_blink_texture() -> Texture2D:
    match current_stage:
        LifeStage.ADULT:
            match current_type:
                TurtleType.A: return adult_a_blink
                TurtleType.B: return adult_b_blink
                TurtleType.C: return adult_c_blink
        LifeStage.ELDER:
            match current_type:
                TurtleType.A: return elder_a_blink
                TurtleType.B: return elder_b_blink
                TurtleType.C: return elder_c_blink
    return _get_idle_texture()


func _get_blush_texture() -> Texture2D:
    match current_stage:
        LifeStage.ADULT:
            match current_type:
                TurtleType.A: return adult_a_blush
                TurtleType.B: return adult_b_blush
                TurtleType.C: return adult_c_blush
        LifeStage.ELDER:
            match current_type:
                TurtleType.A: return elder_a_blush
                TurtleType.B: return elder_b_blush
                TurtleType.C: return elder_c_blush
    return _get_idle_texture()


func _get_eat_texture() -> Texture2D:
    match current_stage:
        LifeStage.ADULT:
            match current_type:
                TurtleType.A: return adult_a_eat
                TurtleType.B: return adult_b_eat
                TurtleType.C: return adult_c_eat
        LifeStage.ELDER:
            match current_type:
                TurtleType.A: return elder_a_eat
                TurtleType.B: return elder_b_eat
                TurtleType.C: return elder_c_eat
    return _get_idle_texture()






func _do_blink() -> void :

    var original_texture: Texture2D = turtle_sprite.texture
    turtle_sprite.texture = _get_blink_texture()
    await get_tree().create_timer(0.15).timeout
    turtle_sprite.texture = original_texture


func _play_eat_animation() -> void :
    if current_stage == LifeStage.PASSING:
        return

    is_doing_action = true
    var original_texture: Texture2D = turtle_sprite.texture

    turtle_sprite.texture = _get_eat_texture()
    await get_tree().create_timer(0.3).timeout
    turtle_sprite.texture = original_texture

    is_doing_action = false


func _play_blush_animation() -> void :
    if current_stage == LifeStage.PASSING:
        return

    is_doing_action = true
    var original_texture: Texture2D = turtle_sprite.texture

    turtle_sprite.texture = _get_blush_texture()
    await get_tree().create_timer(0.6).timeout
    turtle_sprite.texture = original_texture

    is_doing_action = false


func _play_wash_animation() -> void :

    await _play_blush_animation()
