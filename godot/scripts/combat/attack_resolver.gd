extends Node
class_name ArenaAttackResolver
static func resolve(attacker:Node,players:Array[Node])->void:
    if not is_instance_valid(attacker) or bool(attacker.get("dead")): return
    var combat=attacker.get("combat")
    if combat==null or combat.state!=ArenaCombatController.State.ACTIVE: return
    if combat.get_meta("resolved",false): return
    combat.set_meta("resolved",true)
    var data:ArenaWeaponData=combat.weapon
    for target in players:
        if target==attacker or not is_instance_valid(target) or bool(target.get("dead")): continue
        if int(target.get("team"))==int(attacker.get("team")): continue
        var delta:Vector2=target.global_position-attacker.global_position
        if absf(delta.y)>70.0: continue
        var facing:int=int(attacker.get("facing"))
        var forward:=delta.x*facing
        if forward>0.0 and forward<=data.attack_range:
            target.receive_attack(attacker.player_id,attacker.team,data,data.knockback,facing)
            combat.hit_confirmed.emit(target.player_id,data.weapon_type)
