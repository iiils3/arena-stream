extends Node
class_name ArenaTeamManager

const TEAM_A := 0
const TEAM_B := 1
const TEAM_SIZE := 4

var players: Dictionary = {}

func register_player(player_id: int, team: int, gender: String) -> bool:
    if team not in [TEAM_A, TEAM_B]:
        return false
    var count := 0
    for p in players.values():
        if p.team == team:
            count += 1
    if count >= TEAM_SIZE:
        return false
    players[player_id] = { "team": team, "gender": gender, "kills": 0 }
    return true

func add_kill(player_id: int) -> void:
    if players.has(player_id):
        players[player_id].kills += 1

func get_team_kills(team: int) -> int:
    var total := 0
    for p in players.values():
        if p.team == team:
            total += p.kills
    return total

func leader_for_team(team: int) -> int:
    var best_id := -1
    var best_kills := -1
    for id in players:
        var p = players[id]
        if p.team == team and p.kills > best_kills:
            best_id = id
            best_kills = p.kills
    return best_id
