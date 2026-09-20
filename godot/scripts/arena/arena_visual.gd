extends Node2D
class_name ArenaVisual

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(-200,-200,2200,1200),Color("#17151a"))
    for i in range(14):
        var x := float(i*150)
        var h := float(100+(i%4)*45)
        draw_rect(Rect2(x,280-h,120,h),Color("#28232a"))
        draw_colored_polygon(PackedVector2Array([Vector2(x-10,280-h),Vector2(x+60,220-h),Vector2(x+130,280-h)]),Color("#332c34"))
    draw_rect(Rect2(0,240,1800,210),Color("#3d3435"))
    for x in [80.0,520.0,1240.0,1660.0]:
        draw_rect(Rect2(x,120,150,330),Color("#4a3c3c"))
        draw_rect(Rect2(x-15,100,180,28),Color("#241f24"))
        for y in range(165,420,55):
            draw_rect(Rect2(x+20,y,22,30),Color("#211c20"))
            draw_rect(Rect2(x+108,y,22,30),Color("#211c20"))
    draw_colored_polygon(PackedVector2Array([Vector2(260,340),Vector2(1540,340),Vector2(1740,790),Vector2(60,790)]),Color("#5a4b42"))
    for y in range(340,741,80):
        draw_line(Vector2(160,y),Vector2(1760,y),Color(1,1,1,0.055),2)
    draw_rect(Rect2(430,365,1060,330),Color(0.08,0.05,0.03,0.18),false,4)
    for x in [350.0,1560.0]:
        draw_line(Vector2(x,230),Vector2(x,360),Color("#19171b"),8)
        draw_colored_polygon(PackedVector2Array([Vector2(x,235),Vector2(x+90,250),Vector2(x,285)]),Color("#8f2635"))
        draw_circle(Vector2(x,360),12,Color("#f1b45a"))
        draw_circle(Vector2(x,360),28,Color(1,0.55,0.2,0.08))
