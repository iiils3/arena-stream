extends Node
class_name ArenaCombatController

signal attack_started(weapon_type: int)
signal attack_finished()
signal hit_confirmed(target_id: int, weapon_type: int)
signal damage_taken(attacker_id: int, weapon_type: int)
signal defeated(attacker_id: int)

enum State { READY, ACTIVE, RECOVERY, DEFEATED }

@export var player_id: int = -1
@export var team: int = -1
@export var hit_points: int = 2

var state := State.READY
var weapon := ArenaWeaponData.bow()
var attack_cooldown := 0.0
var attack_clock := 0.0
var hit_count := 0
var last_attacker := -1

func equip(data: ArenaWeaponData) -> void:
    weapon = data

func tick(delta: float) -> void:
    if attack_cooldown > 0.0:
        attack_cooldown = maxf(0.0, attack_cooldown - delta)
    if state == State.ACTIVE or state == State.RECOVERY:
        attack_clock -= delta
        if attack_clock <= 0.0:
            if state == State.ACTIVE:
                state = State.RECOVERY
                attack_clock = weapon.recovery_time
            else:
                state = State.READY
                attack_finished.emit()

func try_attack() -> bool:
    if state != State.READY or attack_cooldown > 0.0:
        return false
    state = State.ACTIVE
    attack_clock = weapon.active_time
    attack_cooldown = weapon.active_time + weapon.recovery_time
    attack_started.emit(weapon.weapon_type)
    return true

func apply_hit(attacker_id: int, attacker_team: int, weapon_data: ArenaWeaponData, knockback_amount: float) -> bool:
    if state == State.DEFEATED or attacker_team == team:
        return false
    last_attacker = attacker_id
    hit_count += 1
    damage_taken.emit(attacker_id, weapon_data.weapon_type)
    if hit_count >= weapon_data.hits_to_kill:
        state = State.DEFEATED
        defeated.emit(attacker_id)
    return true

func revive() -> void:
    state = State.READY
    hit_count = 0
    last_attacker = -1
