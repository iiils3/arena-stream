extends Resource
class_name ArenaWeaponData

enum WeaponType { SWORD, SPEAR, BOW }

@export var weapon_type: WeaponType = WeaponType.BOW
@export var display_name: String = "Bow"
@export var hits_to_kill: int = 2
@export var attack_range: float = 150.0
@export var active_time: float = 0.14
@export var recovery_time: float = 0.32
@export var knockback: float = 90.0
@export var projectile_speed: float = 700.0
@export var projectile: bool = false

static func sword() -> ArenaWeaponData:
    var d := ArenaWeaponData.new()
    d.weapon_type = WeaponType.SWORD
    d.display_name = "Sword"
    d.hits_to_kill = 5
    d.attack_range = 105.0
    d.active_time = 0.12
    d.recovery_time = 0.28
    d.knockback = 110.0
    return d

static func spear() -> ArenaWeaponData:
    var d := ArenaWeaponData.new()
    d.weapon_type = WeaponType.SPEAR
    d.display_name = "Spear"
    d.hits_to_kill = 4
    d.attack_range = 155.0
    d.active_time = 0.10
    d.recovery_time = 0.36
    d.knockback = 125.0
    return d

static func bow() -> ArenaWeaponData:
    var d := ArenaWeaponData.new()
    d.weapon_type = WeaponType.BOW
    d.display_name = "Bow"
    d.hits_to_kill = 2
    d.attack_range = 650.0
    d.active_time = 0.08
    d.recovery_time = 0.44
    d.knockback = 70.0
    d.projectile = true
    return d
