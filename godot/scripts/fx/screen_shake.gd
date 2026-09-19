extends Node
class_name ArenaScreenShake

signal shake_requested(amount: float, duration: float)

func small_hit() -> void:
    shake_requested.emit(2.0, 0.08)

func heavy_hit() -> void:
    shake_requested.emit(5.0, 0.14)

func death() -> void:
    shake_requested.emit(9.0, 0.22)
