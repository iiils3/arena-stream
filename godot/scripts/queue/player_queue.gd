extends Node
class_name ArenaPlayerQueue

signal team_ready(players: Array)
signal replacement_needed(slot_index: int, player_name: String)
signal player_removed(player_name: String)

const TEAM_SIZE := 4
var waiting_players: Array[String] = []
var active_players: Array[String] = ["", "", "", ""]
var registration_counter := 0

func register_player(display_name: String) -> bool:
    var name := display_name.strip_edges()
    if name.is_empty() or waiting_players.has(name) or active_players.has(name):
        return false
    waiting_players.append(name)
    registration_counter += 1
    return true

func begin_team() -> Array[String]:
    for slot in TEAM_SIZE:
        active_players[slot] = _pop_waiting()
    team_ready.emit(active_players.duplicate())
    return active_players.duplicate()

func replace_missing_slots() -> Array[String]:
    for slot in TEAM_SIZE:
        if active_players[slot].is_empty():
            active_players[slot] = _pop_waiting()
    return active_players.duplicate()

func mark_player_out(slot_index: int) -> void:
    if slot_index < 0 or slot_index >= TEAM_SIZE:
        return
    var name := active_players[slot_index]
    if name.is_empty():
        return
    active_players[slot_index] = ""
    player_removed.emit(name)

func get_active_count() -> int:
    var count := 0
    for name in active_players:
        if not name.is_empty():
            count += 1
    return count

func get_waiting_count() -> int:
    return waiting_players.size()

func _pop_waiting() -> String:
    if waiting_players.is_empty():
        return ""
    return waiting_players.pop_front()
