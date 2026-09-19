extends Camera2D
class_name ArenaGroupCamera

@export var min_zoom := 0.65
@export var max_zoom := 1.15
@export var zoom_speed := 4.0
@export var follow_speed := 5.0
@export var padding := Vector2(320.0, 220.0)
@export var impact_decay := 12.0

var impact_offset := Vector2.ZERO

func shake(offset: Vector2) -> void:
    impact_offset += offset

func update_from_players(players: Array[Node2D], delta: float) -> void:
    var living: Array[Node2D] = []
    for player in players:
        if is_instance_valid(player) and not bool(player.get("dead")):
            living.append(player)

    if living.is_empty():
        return

    var min_pos := living[0].global_position
    var max_pos := living[0].global_position

    for player in living:
        min_pos = min_pos.min(player.global_position)
        max_pos = max_pos.max(player.global_position)

    var center := (min_pos + max_pos) * 0.5
    global_position = global_position.lerp(center + impact_offset, 1.0 - exp(-follow_speed * delta))
    impact_offset = impact_offset.lerp(Vector2.ZERO, 1.0 - exp(-impact_decay * delta))

    var span := max_pos - min_pos + padding
    var required := max(span.x / 1920.0, span.y / 1080.0)
    var target_zoom := clamp(1.0 / max(required, 0.01), min_zoom, max_zoom)
    var target := Vector2(target_zoom, target_zoom)
    zoom = zoom.lerp(target, 1.0 - exp(-zoom_speed * delta))
