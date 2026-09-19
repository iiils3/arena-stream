extends Area2D
class_name ArenaHitbox

var owner_id: int = -1
var team: int = -1
var damage_hits: int = 1
var knockback: float = 0.0
var active: bool = false

func activate(p_owner_id: int, p_team: int, p_damage_hits: int, p_knockback: float) -> void:
    owner_id = p_owner_id
    team = p_team
    damage_hits = p_damage_hits
    knockback = p_knockback
    active = true
    monitoring = true

func deactivate() -> void:
    active = false
    monitoring = false
