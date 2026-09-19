extends Resource
class_name ArenaStageDefinition

@export var stage_id := 1
@export var location_name := "The Ashen Gate"
@export var time_of_day := "Night"
@export var kill_requirement := 8
@export var time_limit_seconds := 600
@export var enemy_count := 8
@export var environment_key := "ashen_gate"
@export var monster_available := false
@export var monster_equivalent_kills := 2
@export var notes := ""

static func build(id: int, location: String, tod: String, environment: String, monster: bool = false) -> ArenaStageDefinition:
    var stage := ArenaStageDefinition.new()
    stage.stage_id = id
    stage.location_name = location
    stage.time_of_day = tod
    stage.environment_key = environment
    stage.kill_requirement = 6 + id * 2
    stage.enemy_count = stage.kill_requirement
    stage.monster_available = monster
    stage.notes = "Team must reach the kill requirement before the 10-minute limit."
    return stage
