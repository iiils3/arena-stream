extends Resource
class_name ArenaAttackData

@export var windup := 0.08
@export var active := 0.10
@export var recovery := 0.30
@export var hit_stop := 0.055
@export var camera_shake := 3.0
@export var movement_multiplier := 0.15

static func for_weapon(type: int) -> ArenaAttackData:
    var data := ArenaAttackData.new()
    match type:
        ArenaWeaponData.WeaponType.SWORD:
            data.windup = 0.09
            data.active = 0.12
            data.recovery = 0.28
            data.hit_stop = 0.055
            data.camera_shake = 3.5
            data.movement_multiplier = 0.10
        ArenaWeaponData.WeaponType.SPEAR:
            data.windup = 0.11
            data.active = 0.10
            data.recovery = 0.36
            data.hit_stop = 0.065
            data.camera_shake = 4.0
            data.movement_multiplier = 0.08
        ArenaWeaponData.WeaponType.BOW:
            data.windup = 0.13
            data.active = 0.08
            data.recovery = 0.44
            data.hit_stop = 0.035
            data.camera_shake = 2.0
            data.movement_multiplier = 0.20
    return data
