extends Area2D
class_name ArenaHurtbox

@export var team: int = -1
@export var player_id: int = -1

signal hit_received(attacker_id: int, hits: int, knockback: float)

func receive_hit(attacker_id: int, attacker_team: int, hits: int, knockback: float) -> void:
    if attacker_team == team:
        return
    hit_received.emit(attacker_id, hits, knockback)
