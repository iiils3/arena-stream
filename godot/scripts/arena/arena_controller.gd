extends Node2D
class_name ArenaController
const PLAYER_COUNT:=8
const TEAM_SIZE:=4
var player_states:Dictionary={}
var players:Array[Node]=[]
var player_scene:PackedScene=preload("res://scenes/player/arena_player.tscn")
var spawn_points:Array[Vector2]=[
    Vector2(650,430),Vector2(760,510),Vector2(650,590),Vector2(760,670),
    Vector2(1270,430),Vector2(1160,510),Vector2(1270,590),Vector2(1160,670)
]
func _ready()->void:
    for index in range(PLAYER_COUNT):
        var team:=0 if index<TEAM_SIZE else 1
        var team_slot:=index%TEAM_SIZE
        var gender:="female" if team_slot<2 else "male"
        player_states[index]={"team":team,"gender":gender,"alive":true,"lives":2,"final_life":false,"kills":0}
        var player:=player_scene.instantiate()
        player.name="Player_%02d"%index
        player.player_id=index
        player.team=team
        player.gender=gender
        player.position=spawn_points[index]
        $Players.add_child(player)
        players.append(player)
        player.player_defeated.connect(_on_player_defeated)
        player.life.life_lost.connect(_on_life_lost.bind(index))
        player.life.final_life_entered.connect(_on_final_life.bind(index))
        player.life.eliminated.connect(_on_eliminated.bind(index))
    var camera: ArenaGroupCamera=$CameraRig
    camera.update_from_players(players,0.016)
func _physics_process(_delta:float)->void:
    var now:=Time.get_ticks_msec()/1000.0
    for player in players:
        if player.dead and player.life.ready_for_final_life(now):
            _respawn_player(player,true)
    var camera: ArenaGroupCamera=$CameraRig
    camera.update_from_players(players,0.016)
func _on_player_defeated(player_id:int,attacker_id:int)->void:
    if not player_states.has(player_id):return
    player_states[player_id]["alive"]=false
    if attacker_id>=0 and player_states.has(attacker_id):
        player_states[attacker_id]["kills"]=int(player_states[attacker_id]["kills"])+1
    var player=players[player_id]
    player.life.on_death(Time.get_ticks_msec()/1000.0)
func _on_life_lost(remaining:int,player_id:int)->void:
    player_states[player_id]["lives"]=remaining
    player_states[player_id]["alive"]=false
    if remaining>0:
        _schedule_respawn(players[player_id],ArenaLifeSystem.FIRST_RESPAWN,false)
func _on_final_life(player_id:int)->void:
    player_states[player_id]["final_life"]=true
func _on_eliminated(seconds:float,player_id:int)->void:
    player_states[player_id]["alive"]=false
func _schedule_respawn(player:Node,delay:float,as_final:bool)->void:
    await get_tree().create_timer(delay,true,true).timeout
    if is_instance_valid(player) and player.dead:
        _respawn_player(player,as_final)
func _respawn_player(player:Node,as_final:bool)->void:
    player.respawn(spawn_points[int(player.player_id)],as_final)
    player_states[int(player.player_id)]["alive"]=true
    if as_final:
        player_states[int(player.player_id)]["final_life"]=true
func get_team(player_id:int)->int:
    return int(player_states[player_id]["team"]) if player_states.has(player_id) else -1
func can_damage(attacker_id:int,target_id:int)->bool:
    return player_states.has(attacker_id) and player_states.has(target_id) and get_team(attacker_id)!=get_team(target_id)
