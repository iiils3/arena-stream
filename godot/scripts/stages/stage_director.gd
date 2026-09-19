extends Node
class_name ArenaStageDirector

signal stage_started(stage: ArenaStageDefinition)
signal stage_progress_changed(kills: int, required: int)
signal stage_cleared(stage: ArenaStageDefinition)
signal stage_failed(stage: ArenaStageDefinition)
signal round_finished

const ROUND_LIMIT := 600.0
const INTERMISSION := 60.0

var stages: Array[ArenaStageDefinition] = []
var current_stage_index := 0
var equivalent_kills := 0
var round_clock := 0.0
var intermission_clock := 0.0
var running := false
var intermission := false

func _ready() -> void:
    stages = [
        ArenaStageDefinition.build(1, "The Ashen Gate", "Night", "ashen_gate"),
        ArenaStageDefinition.build(2, "The Valley Road", "Morning", "valley_road"),
        ArenaStageDefinition.build(3, "The Dust Street", "Afternoon", "dust_street"),
        ArenaStageDefinition.build(4, "Castle Gate", "Afternoon", "castle_gate"),
        ArenaStageDefinition.build(5, "Castle Interior", "Evening", "castle_interior"),
        ArenaStageDefinition.build(6, "The Prince's Gate", "Night", "princes_gate", true)
    ]

func start_run() -> void:
    current_stage_index = 0
    _begin_stage()

func _process(delta: float) -> void:
    if intermission:
        intermission_clock = maxf(0.0, intermission_clock - delta)
        if intermission_clock <= 0.0:
            intermission = false
            _begin_stage()
        return
    if not running or stages.is_empty():
        return
    round_clock += delta
    if round_clock >= ROUND_LIMIT:
        _fail_stage()

func fail_current_stage() -> void:
    _fail_stage()

func register_normal_kill() -> void:
    if not running:
        return
    equivalent_kills += 1
    _emit_progress()
    _check_clear()

func register_monster_kill() -> void:
    if not running:
        return
    equivalent_kills += 2
    _emit_progress()
    _check_clear()

func _check_clear() -> void:
    var stage := stages[current_stage_index]
    if equivalent_kills < stage.kill_requirement:
        return
    running = false
    stage_cleared.emit(stage)
    current_stage_index += 1
    if current_stage_index >= stages.size():
        round_finished.emit()
        return
    _start_intermission()

func _fail_stage() -> void:
    if not running:
        return
    running = false
    stage_failed.emit(stages[current_stage_index])
    _start_intermission()

func _start_intermission() -> void:
    intermission = true
    intermission_clock = INTERMISSION

func _begin_stage() -> void:
    if current_stage_index >= stages.size():
        round_finished.emit()
        return
    equivalent_kills = 0
    round_clock = 0.0
    running = true
    stage_started.emit(stages[current_stage_index])
    _emit_progress()

func _emit_progress() -> void:
    if stages.is_empty():
        return
    stage_progress_changed.emit(equivalent_kills, stages[current_stage_index].kill_requirement)

func get_current_stage() -> ArenaStageDefinition:
    if stages.is_empty() or current_stage_index >= stages.size():
        return null
    return stages[current_stage_index]

func get_remaining_seconds() -> int:
    return max(0, int(ROUND_LIMIT - round_clock))

func get_intermission_remaining_seconds() -> int:
    return max(0, int(ceil(intermission_clock)))
