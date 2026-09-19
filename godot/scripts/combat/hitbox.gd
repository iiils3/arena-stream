extends Area2D
class_name ArenaHitbox
var owner_id:=-1
var owner_team:=-1
var weapon_data:ArenaWeaponData
var facing:=1
var already_hit:={}
func setup(p_owner_id:int,p_team:int,p_weapon:ArenaWeaponData,p_facing:int)->void:
    owner_id=p_owner_id
    owner_team=p_team
    weapon_data=p_weapon
    facing=p_facing
    already_hit.clear()
    monitoring=true
    monitorable=true
    collision_layer=4
    collision_mask=8
func scan()->void:
    if weapon_data==null:return
    for area in get_overlapping_areas():
        if not area is ArenaHurtbox:continue
        var hurt:=area as ArenaHurtbox
        if hurt.player_id==owner_id or already_hit.has(hurt.player_id):continue
        if hurt.team==owner_team:continue
        already_hit[hurt.player_id]=true
        hurt.receive_hit(owner_id,owner_team,weapon_data.hits_to_kill,weapon_data.knockback)
