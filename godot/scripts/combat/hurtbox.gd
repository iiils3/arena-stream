extends Area2D
class_name ArenaHurtbox

@export var team := -1
@export var player_id := -1
signal hit_received(attacker_id:int,weapon:ArenaWeaponData,knockback:float)

func receive_hit(attacker_id:int,attacker_team:int,_hits:int,knockback:float)->void:
    if attacker_team==team: return
    var weapon=ArenaWeaponData.bow()
    hit_received.emit(attacker_id,weapon,knockback)
