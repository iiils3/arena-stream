extends Node
class_name ArenaMeleeBot

@export var fighter_path: NodePath
var fighter: ArenaMeleeFighter
var think_clock := 0.0
var next_action := 0.0

func _ready() -> void:
    fighter = get_node(fighter_path) as ArenaMeleeFighter
    fighter.is_player = false

func _physics_process(delta: float) -> void:
    if fighter == null or fighter.state == ArenaMeleeFighter.State.DEFEATED:
        return
    think_clock -= delta
    if think_clock > 0.0:
        return
    think_clock = randf_range(0.08, 0.18)
    var target := fighter.ai_target
    if not is_instance_valid(target):
        return
    var distance := fighter.global_position.distance_to(target.global_position)
    if distance < 155.0 and fighter.state == ArenaMeleeFighter.State.READY:
        var roll := randf()
        if roll < 0.18:
            fighter.set_block(true)
            next_action = 0.45
        elif roll < 0.30:
            fighter.set_block(false)
            fighter.dodge(Vector2(-fighter.facing, 0))
        else:
            fighter.set_block(false)
            var kind := ArenaMeleeAttack.Kind.SLASH
            if roll > 0.78:
                kind = ArenaMeleeAttack.Kind.OVERHEAD
            elif roll > 0.58:
                kind = ArenaMeleeAttack.Kind.STAB
            fighter.perform_attack(kind)
    elif distance < 220.0 and fighter.state == ArenaMeleeFighter.State.READY:
        fighter.set_block(randf() < 0.15)
