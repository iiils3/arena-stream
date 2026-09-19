extends Node2D
class_name ArenaController

const PLAYER_COUNT := 8
const TEAM_SIZE := 4

var player_states: Dictionary = {}

func _ready() -> void:
    for index in range(PLAYER_COUNT):
        var team := 0 if index < TEAM_SIZE else 1
        var team_slot := index % TEAM_SIZE
        var gender := "female" if team_slot < 2 else "male"
        player_states[index] = {
            "team": team,
            "gender": gender,
            "alive": true,
            "hp": 100,
            "lives": 2,
            "final_life": false,
            "kills": 0,
        }

func get_team(player_id: int) -> int:
    if not player_states.has(player_id):
        return -1
    return int(player_states[player_id]["team"])

func can_damage(attacker_id: int, target_id: int) -> bool:
    if not player_states.has(attacker_id) or not player_states.has(target_id):
        return false
    return get_team(attacker_id) != get_team(target_id)
