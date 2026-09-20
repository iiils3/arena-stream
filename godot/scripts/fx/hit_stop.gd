extends Node
class_name ArenaHitStop

var remaining := 0.0

func trigger(duration: float = 0.055) -> void:
    remaining = maxf(remaining, duration)

func _process(delta: float) -> void:
    if remaining > 0.0:
        remaining = maxf(0.0, remaining - delta)
