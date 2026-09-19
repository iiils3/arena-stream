extends CharacterBody2D
class_name ArenaPlayerController

@export var walk_speed := 220.0
@export var acceleration := 1000.0
@export var deceleration := 1300.0
@export var depth_speed := 180.0
@export var depth_min := 340.0
@export var depth_max := 700.0

var dead := false
var facing := 1

func _physics_process(delta: float) -> void:
    if dead:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
        move_and_slide()
        return

    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var target := Vector2(input_vector.x * walk_speed, input_vector.y * depth_speed)
    var rate := acceleration if input_vector.length() > 0.0 else deceleration
    velocity = velocity.move_toward(target, rate * delta)

    if absf(velocity.x) > 1.0:
        facing = 1 if velocity.x > 0.0 else -1

    move_and_slide()
    global_position.y = clamp(global_position.y, depth_min, depth_max)
