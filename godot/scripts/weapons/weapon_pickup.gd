extends Area2D
class_name ArenaWeaponPickup

@export var weapon_type: ArenaWeaponData.WeaponType = ArenaWeaponData.WeaponType.SWORD
@export var pickup_id := -1
@export var team_owner := -1

var weapon_data: ArenaWeaponData

func _ready() -> void:
    weapon_data = _make_weapon()
    collision_layer = 16
    collision_mask = 2
    body_entered.connect(_on_body_entered)
    queue_redraw()

func _make_weapon() -> ArenaWeaponData:
    match weapon_type:
        ArenaWeaponData.WeaponType.SWORD:
            return ArenaWeaponData.sword()
        ArenaWeaponData.WeaponType.SPEAR:
            return ArenaWeaponData.spear()
        _:
            return ArenaWeaponData.bow()

func _on_body_entered(body: Node2D) -> void:
    if not body is ArenaPlayerController:
        return
    if body.dead:
        return
    if team_owner >= 0 and int(body.team) != team_owner:
        return

    body.combat.equip(weapon_data)
    if body.visual:
        body.visual.weapon_type = weapon_type
        body.visual.queue_redraw()
    queue_free()

func _draw() -> void:
    var c := (
        Color("#d8dce2")
        if weapon_type != ArenaWeaponData.WeaponType.BOW
        else Color("#d4a74b")
    )
    draw_circle(Vector2.ZERO, 20, Color(0,0,0,0.22))
    draw_line(Vector2(-12,10), Vector2(12,-10), c, 5, true)
