extends Area2D
class_name ArenaArrowProjectile
var owner_id:=-1
var owner_team:=-1
var weapon_data:ArenaWeaponData
var velocity_vector:=Vector2.ZERO
var already_hit:={}
func setup(p_owner_id:int,p_team:int,p_weapon:ArenaWeaponData,start:Vector2,direction:int)->void:
    owner_id=p_owner_id
    owner_team=p_team
    weapon_data=p_weapon
    global_position=start
    velocity_vector=Vector2(direction*weapon_data.projectile_speed,0)
    collision_layer=4
    collision_mask=8
    monitoring=true
    monitorable=true
func _physics_process(delta:float)->void:
    global_position+=velocity_vector*delta
    for area in get_overlapping_areas():
        if not area is ArenaHurtbox:continue
        var hurt:=area as ArenaHurtbox
        if hurt.team==owner_team or already_hit.has(hurt.player_id):continue
        already_hit[hurt.player_id]=true
        hurt.receive_hit(owner_id,owner_team,weapon_data,weapon_data.knockback)
        queue_free()
    if global_position.x < -300.0 or global_position.x > 2100.0:queue_free()
