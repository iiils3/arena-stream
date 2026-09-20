extends Resource
class_name ArenaMeleeAttack

enum Kind { SLASH, OVERHEAD, STAB }

@export var kind: Kind = Kind.SLASH
@export var windup := 0.18
@export var active := 0.18
@export var recovery := 0.34
@export var stamina_cost := 12.0
@export var damage := 28.0
@export var guard_damage := 18.0
@export var reach := 118.0
@export var arc_degrees := 105.0
@export var knockback := 170.0
@export var stagger := 0.18

static func for_kind(p_kind: int) -> ArenaMeleeAttack:
    var a := ArenaMeleeAttack.new()
    a.kind = p_kind
    match p_kind:
        Kind.SLASH:
            a.windup = 0.16
            a.active = 0.18
            a.recovery = 0.34
            a.stamina_cost = 12.0
            a.damage = 28.0
            a.guard_damage = 18.0
            a.reach = 122.0
            a.arc_degrees = 112.0
            a.knockback = 165.0
        Kind.OVERHEAD:
            a.windup = 0.28
            a.active = 0.16
            a.recovery = 0.46
            a.stamina_cost = 18.0
            a.damage = 42.0
            a.guard_damage = 25.0
            a.reach = 116.0
            a.arc_degrees = 72.0
            a.knockback = 230.0
        Kind.STAB:
            a.windup = 0.12
            a.active = 0.12
            a.recovery = 0.30
            a.stamina_cost = 10.0
            a.damage = 24.0
            a.guard_damage = 15.0
            a.reach = 148.0
            a.arc_degrees = 18.0
            a.knockback = 110.0
    return a
