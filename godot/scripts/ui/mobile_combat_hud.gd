extends CanvasLayer
class_name ArenaMobileCombatHUD

var fighter: ArenaMeleeFighter
var joystick_center := Vector2(150, 930)
var joystick_radius := 92.0
var joystick_touch := -1
var joystick_vector := Vector2.ZERO
var action_rects := {
    "slash": Rect2(1600, 820, 105, 105),
    "overhead": Rect2(1735, 710, 105, 105),
    "stab": Rect2(1470, 710, 105, 105),
    "block": Rect2(1600, 955, 105, 85),
    "dodge": Rect2(1740, 930, 105, 85)
}
var pressed := {}

func _ready() -> void:
    layer = 20
    process_input = true
    set_process_input(true)
    queue_redraw()

func bind_fighter(value: ArenaMeleeFighter) -> void:
    fighter = value

func _process(_delta: float) -> void:
    if is_instance_valid(fighter):
        fighter.set_move_input(joystick_vector)
    queue_redraw()

func _input(event: InputEvent) -> void:
    if not is_instance_valid(fighter):
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.distance_to(joystick_center) <= joystick_radius * 1.25 and joystick_touch == -1:
                joystick_touch = event.index
                _update_joystick(event.position)
            else:
                _action_down(event.position)
        elif event.index == joystick_touch:
            joystick_touch = -1
            joystick_vector = Vector2.ZERO
        else:
            _action_up(event.position)
    elif event is InputEventScreenDrag and event.index == joystick_touch:
        _update_joystick(event.position)

func _update_joystick(position: Vector2) -> void:
    joystick_vector = (position - joystick_center).limit_length(joystick_radius) / joystick_radius

func _action_down(position: Vector2) -> void:
    for key in action_rects:
        if action_rects[key].has_point(position):
            pressed[key] = true
            match key:
                "slash": fighter.perform_attack(ArenaMeleeAttack.Kind.SLASH)
                "overhead": fighter.perform_attack(ArenaMeleeAttack.Kind.OVERHEAD)
                "stab": fighter.perform_attack(ArenaMeleeAttack.Kind.STAB)
                "block": fighter.set_block(true)
                "dodge": fighter.dodge(joystick_vector if joystick_vector.length() > 0.1 else Vector2(fighter.facing, 0))
            break

func _action_up(position: Vector2) -> void:
    for key in action_rects:
        if action_rects[key].has_point(position):
            pressed.erase(key)
            if key == "block":
                fighter.set_block(false)
            break

func _draw() -> void:
    draw_circle(joystick_center, joystick_radius, Color(0.05,0.06,0.08,0.22))
    draw_circle(joystick_center, joystick_radius, Color(0.85,0.88,0.92,0.45), false, 3.0)
    draw_circle(joystick_center + joystick_vector * 48.0, 44.0, Color(0.85,0.88,0.92,0.18))
    draw_circle(joystick_center + joystick_vector * 48.0, 44.0, Color(0.85,0.88,0.92,0.45), false, 3.0)
    _draw_action("slash", "⚔")
    _draw_action("overhead", "↑")
    _draw_action("stab", "→")
    _draw_action("block", "◈")
    _draw_action("dodge", "◇")

func _draw_action(key: String, label: String) -> void:
    var rect: Rect2 = action_rects[key]
    var active := pressed.has(key)
    var alpha := 0.38 if active else 0.20
    draw_rect(rect, Color(0.05,0.06,0.08,alpha), true)
    draw_rect(rect, Color(0.88,0.9,0.94,0.55), false, 3.0)
    draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x*0.5-12, rect.position.y+66), label, HORIZONTAL_ALIGNMENT_CENTER, 30, 30, Color(0.95,0.95,0.95,0.85))
