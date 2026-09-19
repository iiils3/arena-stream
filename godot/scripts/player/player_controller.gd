extends CharacterBody2D
class_name ArenaPlayerController
signal player_attacked(player_id:int,weapon_type:int)
signal player_hit(player_id:int)
signal player_defeated(player_id:int,attacker_id:int)
@export var walk_speed:=220.0
@export var acceleration:=1000.0
@export var deceleration:=1300.0
@export var depth_speed:=180.0
@export var depth_min:=340.0
@export var depth_max:=700.0
@export var player_id:=-1
@export var team:=0
@export var gender:="female"
var dead:=false
var facing:=1
var dodge_time:=0.0
var dodge_direction:=Vector2.ZERO
var combat:ArenaCombatController
var visual:ArenaPlayerVisual
var life:ArenaLifeSystem
var last_attack_pressed:=false
var last_dodge_pressed:=false
var knockback_velocity:=Vector2.ZERO
var last_attacker:=-1
func _ready()->void:
    add_to_group("arena_players")
    combat=ArenaCombatController.new()
    combat.player_id=player_id
    combat.team=team
    add_child(combat)
    life=ArenaLifeSystem.new()
    add_child(life)
    combat.attack_started.connect(_on_attack_started)
    combat.damage_taken.connect(_on_damage_taken)
    combat.defeated.connect(_on_defeated)
    visual=get_node_or_null("Visual") as ArenaPlayerVisual
    var hurt=get_node_or_null("Hurtbox") as ArenaHurtbox
    if hurt:
        hurt.player_id=player_id
        hurt.team=team
        hurt.hit_received.connect(_on_hurtbox_hit)
    if visual:visual.set_state(team,gender,facing,combat.weapon.weapon_type)
func _physics_process(delta:float)->void:
    if combat:combat.tick(delta)
    knockback_velocity=knockback_velocity.move_toward(Vector2.ZERO,900.0*delta)
    if dead:
        velocity=knockback_velocity
        move_and_slide()
        return
    var input_vector:=Vector2(Input.get_axis("ui_left","ui_right"),Input.get_axis("ui_up","ui_down")).normalized()
    var dodge_pressed:=Input.is_key_pressed(KEY_L)
    var attack_pressed:=Input.is_key_pressed(KEY_J)
    if dodge_pressed and not last_dodge_pressed and input_vector.length()>0.0:
        dodge_direction=input_vector
        dodge_time=0.12
    last_dodge_pressed=dodge_pressed
    if attack_pressed and not last_attack_pressed:combat.try_attack()
    last_attack_pressed=attack_pressed
    if dodge_time>0.0:
        dodge_time=maxf(0.0,dodge_time-delta)
        velocity=dodge_direction*620.0+knockback_velocity
    else:
        var target:=Vector2(input_vector.x*walk_speed,input_vector.y*depth_speed)
        var rate:=acceleration if input_vector.length()>0.0 else deceleration
        velocity=velocity.move_toward(target,rate*delta)+knockback_velocity
    if absf(velocity.x)>1.0:
        facing=1 if velocity.x>0.0 else -1
        if visual:visual.facing=facing
    move_and_slide()
    global_position.y=clamp(global_position.y,depth_min,depth_max)
    z_index=int(global_position.y)
func receive_attack(attacker_id:int,attacker_team:int,weapon_data:ArenaWeaponData,knockback:float,direction:int)->void:
    if dead:return
    if combat.apply_hit(attacker_id,attacker_team,weapon_data,knockback):
        last_attacker=attacker_id
        knockback_velocity=Vector2(direction*knockback,0)
        player_hit.emit(player_id)
func respawn(at:Vector2,as_final:=false)->void:
    global_position=at
    dead=false
    visible=true
    collision_layer=2
    combat.revive()
    if as_final:
        life.consume_final_life()
        combat.hit_count=0
    if visual:visual.visible=true
func _on_hurtbox_hit(attacker_id:int,weapon:ArenaWeaponData,knockback:float)->void:
    if dead:return
    var attacker_team:=-1
    var attacker_node:Node=null
    for candidate in get_tree().get_nodes_in_group("arena_players"):
        if int(candidate.player_id)==attacker_id:
            attacker_node=candidate
            attacker_team=int(candidate.team)
            break
    if attacker_team==team:return
    receive_attack(attacker_id,attacker_team,weapon,knockback,signf(global_position.x-(attacker_node.global_position.x if attacker_node else global_position.x)))
func _on_attack_started(weapon_type:int)->void:
    if visual:visual.trigger_attack(weapon_type)
    var data:ArenaWeaponData=combat.weapon
    if weapon_type==ArenaWeaponData.WeaponType.BOW:
        _spawn_arrow(data)
    else:
        _spawn_melee_hitbox(data)
    player_attacked.emit(player_id,weapon_type)

func _spawn_melee_hitbox(data:ArenaWeaponData)->void:
    var hitbox:=ArenaHitbox.new()
    hitbox.setup(player_id,team,data,facing)
    var shape:=CollisionShape2D.new()
    var rect:=RectangleShape2D.new()
    rect.size=Vector2(data.attack_range,58.0)
    shape.shape=rect
    shape.position=Vector2(facing*(data.attack_range*0.5+20.0),-10)
    hitbox.add_child(shape)
    get_parent().add_child(hitbox)
    hitbox.global_position=global_position
    hitbox.scan()
    await get_tree().create_timer(data.active_time, true, true).timeout
    if is_instance_valid(hitbox):hitbox.queue_free()

func _spawn_arrow(data:ArenaWeaponData)->void:
    var arrow:=ArenaArrowProjectile.new()
    arrow.setup(player_id,team,data,global_position+Vector2(facing*35.0,-12.0),facing)
    var shape:=CollisionShape2D.new()
    var circle:=CircleShape2D.new()
    circle.radius=7.0
    shape.shape=circle
    arrow.add_child(shape)
    get_parent().add_child(arrow)
func _on_damage_taken(_attacker_id:int,_weapon_type:int)->void:
    if visual:visual.hit_flash()
func _on_defeated(attacker_id:int)->void:
    if dead:return
    dead=true
    last_attacker=attacker_id
    collision_layer=0
    visible=false
    player_defeated.emit(player_id,attacker_id)
