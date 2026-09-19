extends Node2D
class_name ArenaPlayerVisual

@export var team := 0
@export var gender := "female"
@export var facing := 1
@export var weapon_type := 2
var flash := 0.0
var attack := 0.0
var attack_total := 0.22
var attack_weapon := 2

func set_state(p_team:int, p_gender:String, p_facing:int, p_weapon:int) -> void:
    team = p_team
    gender = p_gender
    facing = p_facing
    weapon_type = p_weapon
    queue_redraw()

func trigger_attack(p_weapon:int, windup:float = 0.08, active:float = 0.10, recovery:float = 0.30) -> void:
    attack_total = maxf(0.01, windup + active + recovery)
    attack = attack_total
    attack_weapon = p_weapon
    queue_redraw()

func hit_flash() -> void:
    flash = 0.10
    queue_redraw()

func _process(delta:float) -> void:
    flash = maxf(0.0, flash - delta)
    attack = maxf(0.0, attack - delta)
    queue_redraw()

func _draw() -> void:
    var skin := Color("#d7a47c") if gender == "male" else Color("#e2b28e")
    var cloth := Color("#8f2635") if team == 0 else Color("#245c91")
    if flash > 0.0:
        cloth = Color.WHITE
        skin = Color.WHITE
    var dark := Color("#171923")
    var metal := Color("#d8dce2")
    var gold := Color("#d4a74b")
    draw_ellipse(Vector2(0,24), Vector2(30,9), Color(0,0,0,0.35))
    draw_rect(Rect2(-13,4,10,22), dark)
    draw_rect(Rect2(3,4,10,22), dark)
    draw_rect(Rect2(-17,22,16,6), dark)
    draw_rect(Rect2(1,22,16,6), dark)
    draw_colored_polygon(PackedVector2Array([Vector2(-18,-20),Vector2(18,-20),Vector2(14,7),Vector2(-14,7)]), cloth)
    draw_rect(Rect2(-15,1,30,5), gold)
    draw_circle(Vector2(0,-31),12,skin)
    draw_arc(Vector2(0,-31),12,PI,TAU,12,dark,5.0)
    if gender == "female":
        draw_circle(Vector2(-11,-27),6,dark)
        draw_circle(Vector2(11,-27),6,dark)
    var arm_end := Vector2(27*facing,-9)
    draw_line(Vector2(10*facing,-14),arm_end,skin,7.0,true)
    var weapon_dir := Vector2(facing,0)
    if attack > 0.0:
        var progress := 1.0 - attack/attack_total
        var sweep := 52.0*progress
        weapon_dir = Vector2(facing,0).rotated(deg_to_rad(-28.0*facing+sweep*facing))
    if weapon_type == 0:
        draw_line(arm_end,arm_end+weapon_dir*58,metal,5.0,true)
        draw_line(arm_end+weapon_dir*57,arm_end+weapon_dir*69,gold,3.0,true)
    elif weapon_type == 1:
        draw_line(arm_end-weapon_dir*12,arm_end+weapon_dir*72,dark,4.0,true)
        draw_line(arm_end+weapon_dir*58,arm_end+weapon_dir*82,metal,5.0,true)
    else:
        draw_line(Vector2(18*facing,-16),Vector2(31*facing,-2),gold,4.0,true)
        draw_arc(Vector2(31*facing,-2),13,PI*0.65,PI*1.35,10,metal,3.0)
        if attack > 0.0:
            draw_line(Vector2(31*facing,-2),Vector2(125*facing,-2),metal,2.0,true)

func draw_ellipse(center:Vector2, radius:Vector2, color:Color) -> void:
    var pts := PackedVector2Array()
    for i in range(24):
        var a := TAU*float(i)/24.0
        pts.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y))
    draw_colored_polygon(pts,color)
