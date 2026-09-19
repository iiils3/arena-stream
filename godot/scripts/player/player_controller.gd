extends CharacterBody2D
class_name ArenaPlayerController

@export var walk_speed := 220.0
@export var acceleration := 1000.0
@export var deceleration := 1300.0
@export var depth_speed := 180.0
@export var depth_min := 340.0
@export var depth_max := 700.0
@export var player_id := -1
@export var team := 0

var dead := false
var facing := 1
var dodge_time := 0.0
var dodge_direction := Vector2.ZERO
var combat: ArenaCombatController

func _ready() -> void:
    combat = ArenaCombatController.new()
    combat.player_id = player_id
    combat.team = team
    add_child(combat)

func _physics_process(delta: float) -> void:
    if combat:
        combat.tick(delta)

    if dead:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
        move_and_slide()
        return

    if dodge_time > 0.0:
        dodge_time = maxf(0.0, dodge_time - delta)
        velocity = dodge_direction * 620.0
        move_and_slide()
        global_position.y = clamp(global_position.y, depth_min, depth_max)
        return

    var input_vector := Vector2(
        float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
        float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
    ).normalized()

    var target := Vector2(input_vector.x * walk_speed, input_vector.y * depth_speed)
    var rate := acceleration if input_vector.length() > 0.0 else deceleration
    velocity = velocity.move_toward(target, rate * delta)

    if absf(velocity.x) > 1.0:
        facing = 1 if velocity.x > 0.0 else -1

    if Input.is_key_pressed(KEY_L) and input_vector.length() > 0.0:
        dodge_direction = input_vector
        dodge_time = 0.12

    if Input.is_key_pressed(KEY_J):
        combat.try_attack()

    move_and_slide()
    global_position.y = clamp(global_position.y, depth_min, depth_max)
