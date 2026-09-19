extends CharacterBody2D
class_name ArenaMeleeFighter

signal hit_landed(attacker, target, damage)
signal defeated(fighter, attacker)
signal state_changed(state_name: String)

enum State { READY, WINDUP, ACTIVE, RECOVERY, BLOCK, DODGE, STAGGER, DEFEATED }

@export var fighter_name := "Fighter"
@export var is_player := false
@export var max_health := 100.0
@export var max_stamina := 100.0
@export var move_speed := 245.0
@export var acceleration := 1200.0
@export var deceleration := 1500.0

var health := 100.0
var stamina := 100.0
var state: State = State.READY
var attack: ArenaMeleeAttack
var attack_clock := 0.0
var attack_total := 0.0
var attack_start_angle := 0.0
var attack_end_angle := 0.0
var attack_hit_targets: Array[Node] = []
var facing := 1
var block_held := false
var dodge_clock := 0.0
var dodge_direction := Vector2.ZERO
var stagger_clock := 0.0
var invulnerable := false
var last_weapon_tip := Vector2.ZERO
var weapon_tip := Vector2.ZERO
var ai_target: Node2D
var combat_radius := 42.0
var mobile_move_input := Vector2.ZERO

func _ready() -> void:
    health = max_health
    stamina = max_stamina
    queue_redraw()

func _physics_process(delta: float) -> void:
    if state == State.DEFEATED:
        return
    _recover_stamina(delta)
    _tick_state(delta)
    if state != State.WINDUP and state != State.ACTIVE and state != State.RECOVERY and state != State.STAGGER and state != State.DEFEATED:
        _move_fighter(delta)
    move_and_slide()
    queue_redraw()

func _recover_stamina(delta: float) -> void:
    var rate := 20.0 if state == State.READY else 7.0
    if block_held:
        rate = -8.0
    stamina = clampf(stamina + rate * delta, 0.0, max_stamina)

func _tick_state(delta: float) -> void:
    if dodge_clock > 0.0:
        dodge_clock = maxf(0.0, dodge_clock - delta)
        if dodge_clock == 0.0:
            invulnerable = false
            state = State.READY
        return
    if stagger_clock > 0.0:
        stagger_clock = maxf(0.0, stagger_clock - delta)
        if stagger_clock == 0.0:
            state = State.READY
        return
    if state == State.WINDUP or state == State.ACTIVE or state == State.RECOVERY:
        attack_clock -= delta
        if attack_clock > 0.0:
            return
        if state == State.WINDUP:
            state = State.ACTIVE
            attack_clock = attack.active
            last_weapon_tip = global_position + _weapon_tip_at(attack_start_angle)
            attack_hit_targets.clear()
            state_changed.emit("active")
        elif state == State.ACTIVE:
            state = State.RECOVERY
            attack_clock = attack.recovery
        else:
            state = State.READY
            state_changed.emit("ready")
        queue_redraw()

func _move_fighter(delta: float) -> void:
    var input_vector := mobile_move_input if is_player and mobile_move_input.length() > 0.05 else (Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down")
    ).normalized() if is_player else Vector2.ZERO)
    if is_player and input_vector.length() > 0.05:
        var target := Vector2(input_vector.x * move_speed, input_vector.y * move_speed * 0.62)
        velocity = velocity.move_toward(target, acceleration * delta)
        if absf(input_vector.x) > 0.2:
            facing = 1 if input_vector.x > 0.0 else -1
    elif not is_player and is_instance_valid(ai_target):
        var delta_pos := ai_target.global_position - global_position
        var desired := Vector2(signf(delta_pos.x), clampf(delta_pos.y / 70.0, -1.0, 1.0))
        if absf(delta_pos.x) > 92.0:
            velocity = velocity.move_toward(Vector2(desired.x * move_speed * 0.72, desired.y * move_speed * 0.45), acceleration * delta)
        else:
            velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
        if absf(delta_pos.x) > 8.0:
            facing = 1 if delta_pos.x > 0.0 else -1
    else:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

    if position.y < 330.0 or position.y > 735.0:
        position.y = clampf(position.y, 330.0, 735.0)

func set_move_input(value: Vector2) -> void:
    mobile_move_input = value.limit_length(1.0)

func perform_attack(kind: int) -> bool:
    if state != State.READY or stamina < ArenaMeleeAttack.for_kind(kind).stamina_cost:
        return false
    attack = ArenaMeleeAttack.for_kind(kind)
    stamina -= attack.stamina_cost
    state = State.WINDUP
    attack_clock = attack.windup
    attack_total = attack.windup + attack.active + attack.recovery
    attack_start_angle = _attack_start_angle(kind)
    attack_end_angle = _attack_end_angle(kind)
    last_weapon_tip = _weapon_tip_at(attack_start_angle)
    attack_hit_targets.clear()
    state_changed.emit("windup")
    queue_redraw()
    return true

func set_block(pressed: bool) -> void:
    if state == State.DEFEATED or state == State.WINDUP or state == State.ACTIVE or state == State.RECOVERY:
        block_held = false
        return
    block_held = pressed and stamina > 2.0
    if block_held:
        state = State.BLOCK
        state_changed.emit("block")
    elif state == State.BLOCK:
        state = State.READY
        state_changed.emit("ready")

func dodge(direction: Vector2) -> bool:
    if state != State.READY or stamina < 20.0:
        return false
    stamina -= 20.0
    dodge_direction = direction.normalized() if direction.length() > 0.05 else Vector2(facing, 0)
    dodge_clock = 0.16
    invulnerable = true
    state = State.DODGE
    velocity = dodge_direction * 520.0
    state_changed.emit("dodge")
    return true

func receive_melee_hit(attacker: ArenaMeleeFighter, incoming: ArenaMeleeAttack, hit_point: Vector2) -> bool:
    if state == State.DEFEATED or invulnerable:
        return false

    var incoming_dir := signf(attacker.global_position.x - global_position.x)
    if incoming_dir == 0.0:
        incoming_dir = -facing

    if state == State.BLOCK:
        stamina = maxf(0.0, stamina - incoming.guard_damage)
        if stamina <= 0.0:
            block_held = false
            state = State.STAGGER
            stagger_clock = 0.45
            state_changed.emit("guard_break")
        return true

    health = maxf(0.0, health - incoming.damage)
    velocity = Vector2(incoming_dir * incoming.knockback, -35.0)
    stagger_clock = incoming.stagger
    state = State.STAGGER
    state_changed.emit("hit")
    hit_landed.emit(attacker, self, incoming.damage)

    if health <= 0.0:
        state = State.DEFEATED
        defeated.emit(self, attacker)
    return true

func resolve_active_hit(targets: Array[Node]) -> void:
    if state != State.ACTIVE or attack == null:
        return
    var current_tip := global_position + _weapon_tip_at(_current_attack_angle())
    for target in targets:
        if target == self or not is_instance_valid(target) or not target is ArenaMeleeFighter:
            continue
        if attack_hit_targets.has(target):
            continue
        if target.state == State.DEFEATED:
            continue
        if global_position.distance_to(target.global_position) > attack.reach + 85.0:
            continue
        if _segment_hits_circle(last_weapon_tip, current_tip, target.global_position, target.combat_radius):
            if target.receive_melee_hit(self, attack, current_tip):
                attack_hit_targets.append(target)
                hit_landed.emit(self, target, attack.damage)
    last_weapon_tip = current_tip

func _segment_hits_circle(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool:
    var segment := b - a
    var len_sq := segment.length_squared()
    if len_sq <= 0.001:
        return a.distance_to(center) <= radius
    var t := clampf((center - a).dot(segment) / len_sq, 0.0, 1.0)
    var closest := a + segment * t
    return closest.distance_to(center) <= radius

func _attack_start_angle(kind: int) -> float:
    match kind:
        ArenaMeleeAttack.Kind.SLASH:
            return deg_to_rad(-78.0) * facing
        ArenaMeleeAttack.Kind.OVERHEAD:
            return deg_to_rad(-120.0) * facing
        ArenaMeleeAttack.Kind.STAB:
            return deg_to_rad(-8.0) * facing
    return 0.0

func _attack_end_angle(kind: int) -> float:
    match kind:
        ArenaMeleeAttack.Kind.SLASH:
            return deg_to_rad(58.0) * facing
        ArenaMeleeAttack.Kind.OVERHEAD:
            return deg_to_rad(12.0) * facing
        ArenaMeleeAttack.Kind.STAB:
            return deg_to_rad(8.0) * facing
    return 0.0

func _current_attack_angle() -> float:
    if attack == null:
        return 0.0
    var elapsed := attack_total - attack_clock
    var active_progress := clampf((elapsed - attack.windup) / maxf(0.001, attack.active), 0.0, 1.0)
    if state == State.WINDUP:
        var wind_progress := clampf(elapsed / maxf(0.001, attack.windup), 0.0, 1.0)
        return lerpf(0.0, attack_start_angle, wind_progress)
    if state == State.ACTIVE:
        return lerpf(attack_start_angle, attack_end_angle, active_progress)
    return attack_end_angle

func _weapon_tip_at(angle: float) -> Vector2:
    var origin := Vector2(24.0 * facing, -22.0)
    var local := Vector2(cos(angle), sin(angle)) * (attack.reach if attack else 90.0)
    return origin + local

func get_attack_progress() -> float:
    if attack_total <= 0.0 or attack == null:
        return 0.0
    var elapsed := attack_total - maxf(0.0, attack_clock)
    return clampf(elapsed / attack_total, 0.0, 1.0)

func _draw() -> void:
    var body := Color("#8d2637") if is_player else Color("#333943")
    var trim := Color("#d6b36a")
    var metal := Color("#cfd5dc")
    var dark := Color("#171a20")
    draw_ellipse(Vector2(0, 28), Vector2(31, 10), Color(0,0,0,0.32))
    draw_rect(Rect2(-15, -5, 30, 34), body)
    draw_rect(Rect2(-18, 5, 36, 7), trim)
    draw_circle(Vector2(0,-28), 15, Color("#c98e69"))
    draw_arc(Vector2(0,-28), 16, PI, TAU, 20, dark, 7.0)
    draw_line(Vector2(-11, 8), Vector2(-18, 28), dark, 9.0)
    draw_line(Vector2(11, 8), Vector2(18, 28), dark, 9.0)
    draw_line(Vector2(8*facing, -12), Vector2(26*facing, -20), Color("#c98e69"), 8.0)
    var angle := 0.0
    if attack != null:
        angle = _current_attack_angle()
    else:
        angle = deg_to_rad(-5.0 * facing)
    var tip := _weapon_tip_at(angle)
    draw_line(Vector2(26*facing,-20), tip, metal, 7.0, true)
    draw_line(tip, tip + Vector2(8*facing,0), trim, 3.0, true)
    if state == State.BLOCK:
        draw_arc(Vector2(18*facing,-5), 42, -1.2, 1.2, 18, Color(0.75,0.85,1.0,0.85), 7.0)
    if state == State.STAGGER:
        draw_circle(Vector2(0,-52), 4, Color("#f2c14e"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for i in range(24):
        var a := TAU * float(i) / 24.0
        points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(points, color)
