extends Node
class_name ArenaAllyBot

@export var fighter_path: NodePath
var fighter: ArenaMeleeFighter
var think_clock := 0.0

func _ready() -> void:
    fighter = get_node(fighter_path) as ArenaMeleeFighter
    fighter.is_player = false

func _physics_process(delta: float) -> void:
    if fighter == null or fighter.state == ArenaMeleeFighter.State.DEFEATED:
        return

    think_clock -= delta
    if think_clock > 0.0:
        return
    think_clock = randf_range(0.10, 0.20)

    var target := fighter.ai_target
    if not is_instance_valid(target) or target.state == ArenaMeleeFighter.State.DEFEATED:
        return

    var distance := fighter.global_position.distance_to(target.global_position)
    if distance <= 150.0 and fighter.state == ArenaMeleeFighter.State.READY:
        var roll := randf()
        if roll < 0.10:
            fighter.set_block(true)
        else:
            fighter.set_block(false)
            var kind := ArenaMeleeAttack.Kind.SLASH
            if roll > 0.78:
                kind = ArenaMeleeAttack.Kind.OVERHEAD
            elif roll > 0.58:
                kind = ArenaMeleeAttack.Kind.STAB
            fighter.perform_attack(kind)
    elif distance > 180.0 and fighter.state == ArenaMeleeFighter.State.BLOCK:
        fighter.set_block(false)
