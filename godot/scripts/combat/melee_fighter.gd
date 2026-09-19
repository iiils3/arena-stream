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
var parry_clock := 0.0
var counter_clock := 0.0
var counter_armed := false
var invulnerable := false
var last_weapon_tip := Vector2.ZERO
var weapon_tip := Vector2.ZERO
var ai_target: Node2D
var combat_radius := 42.0
var mobile_move_input := Vector2.ZERO
var feint_cooldown := 0.0
var kick_clock := 0.0

func _ready() -> void:
    health = max_health
    stamina = max_stamina
    queue_redraw()

func _physics_process(delta: float) -> void:
    if state == State.DEFEATED:
        return
    _recover_stamina(delta)
    parry_clock = maxf(0.0, parry_clock - delta)
    counter_clock = maxf(0.0, counter_clock - delta)
    feint_cooldown = maxf(0.0, feint_cooldown - delta)
    if counter_clock == 0.0:
        counter_armed = false
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
    if kick_clock > 0.0:
        kick_clock = maxf(0.0, kick_clock - delta)
        if kick_clock == 0.0:
            state = State.READY
        return
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
    if counter_armed and counter_clock > 0.0:
        attack.damage *= 1.18
        attack.guard_damage *= 1.12
        attack.windup *= 0.65
        counter_armed = false
        counter_clock = 0.0
    stamina -= attack.stamina_cost
    state = State.WINDUP
    attack_clock = attack.windup
    attack_total = attack.windup + attack.active + attack.recovery
    attack_start_angle = _attack_start_angle(kind)
    attack_end_angle = _attack_end_angle(kind)
    last_weapon_tip = global_position + _weapon_tip_at(attack_start_angle)
    attack_hit_targets.clear()
    state_changed.emit("windup")
    queue_redraw()
    return true

func feint() -> bool:
    if state != State.WINDUP or attack == null or feint_cooldown > 0.0:
        return false
    var refund := attack.stamina_cost * 0.35
    stamina = minf(max_stamina, stamina + refund)
    attack = null
    attack_clock = 0.0
    attack_hit_targets.clear()
    state = State.READY
    feint_cooldown = 0.22
    state_changed.emit("feint")
    queue_redraw()
    return true

func kick() -> bool:
    if state != State.READY or stamina < 16.0:
        return false
    stamina -= 16.0
    kick_clock = 0.22
    state = State.ACTIVE
    state_changed.emit("kick")
    queue_redraw()
    return true

func resolve_kick_hit(targets: Array[Node]) -> void:
    if state != State.ACTIVE or kick_clock <= 0.0:
        return
    var kick_origin := global_position + Vector2(42.0 * facing, -4.0)
    for target in targets:
        if target == self or not is_instance_valid(target) or not target is ArenaMeleeFighter:
            continue
        if target.state == State.DEFEATED:
            continue
        if kick_origin.distance_to(target.global_position) > 86.0:
            continue
        target._receive_kick()
    kick_clock = -1.0
    state = State.RECOVERY
    attack_clock = 0.28

func _receive_kick() -> void:
    if state == State.BLOCK:
        block_held = false
        parry_clock = 0.0
        stamina = maxf(0.0, stamina - 32.0)
        state = State.STAGGER
        stagger_clock = 0.5 if stamina > 0.0 else 0.7
        state_changed.emit("kick_guard_break")
        return
    velocity = Vector2(facing * 115.0, -45.0)
    state = State.STAGGER
    stagger_clock = 0.34
    state_changed.emit("kicked")

func set_block(pressed: bool) -> void:
    if state == State.DEFEATED or state == State.WINDUP or state == State.ACTIVE or state == State.RECOVERY:
        block_held = false
        return
    block_held = pressed and stamina > 2.0
    if block_held:
        parry_clock = 0.16
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

func _interrupt_attack(duration: float) -> void:
    if state == State.DEFEATED:
        return
    attack_clock = 0.0
    attack = null
    attack_hit_targets.clear()
    block_held = false
    state = State.STAGGER
    stagger_clock = duration
    state_changed.emit("interrupted")

func receive_melee_hit(attacker: ArenaMeleeFighter, incoming: ArenaMeleeAttack, hit_point: Vector2) -> bool:
    if state == State.DEFEATED or invulnerable:
        return false

    var incoming_dir := signf(attacker.global_position.x - global_position.x)
    if incoming_dir == 0.0:
        incoming_dir = -facing

    if state == State.BLOCK:
        if parry_clock > 0.0:
            block_held = false
            parry_clock = 0.0
            state = State.READY
            counter_armed = true
            counter_clock = 0.42
            attacker._interrupt_attack(0.34)
            state_changed.emit("parry")
            return true
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
    var primary := Color("#7d2536") if is_player else Color("#343b46")
    var secondary := Color("#c4a46c") if is_player else Color("#78818d")
    var steel := Color("#d4d8dc")
    var shadow := Color("#11151b")
    var leather := Color("#241c1a")

    # Ground contact.
    draw_ellipse(Vector2(0, 29), Vector2(36, 11), Color(0, 0, 0, 0.34))

    # Legs and boots.
    draw_line(Vector2(-11, 10), Vector2(-19, 31), shadow, 11.0, true)
    draw_line(Vector2(11, 10), Vector2(19, 31), shadow, 11.0, true)
    draw_line(Vector2(-20, 30), Vector2(-8, 30), leather, 7.0, true)
    draw_line(Vector2(8, 30), Vector2(20, 30), leather, 7.0, true)

    # Layered torso armor.
    draw_colored_polygon(PackedVector2Array([
        Vector2(-18, -8), Vector2(18, -8), Vector2(23, 20),
        Vector2(11, 30), Vector2(-11, 30), Vector2(-23, 20)
    ]), primary)
    draw_rect(Rect2(-16, 4, 32, 8), secondary)
    draw_line(Vector2(0, -5), Vector2(0, 26), Color(1, 1, 1, 0.18), 2.0)
    draw_rect(Rect2(-13, 18, 26, 5), leather)

    # Pauldrons.
    draw_circle(Vector2(-21, -3), 10, secondary)
    draw_circle(Vector2(21, -3), 10, secondary)
    draw_arc(Vector2(-21, -3), 11, PI * 0.1, PI * 0.9, 12, steel, 2.0)
    draw_arc(Vector2(21, -3), 11, PI * 0.1, PI * 0.9, 12, steel, 2.0)

    # Head, neck and helmet.
    draw_rect(Rect2(-7, -18, 14, 9), leather)
    draw_circle(Vector2(0, -30), 16, Color("#b97f62"))
    draw_arc(Vector2(0, -31), 17, PI, TAU, 18, shadow, 8.0)
    draw_rect(Rect2(-17, -33, 34, 8), steel)
    draw_rect(Rect2(-14, -40, 28, 7), primary)
    draw_line(Vector2(-12, -28), Vector2(12, -28), steel, 3.0)
    draw_rect(Rect2(4 * facing, -27, 11 * facing, 3), shadow)

    # Weapon hand and guard.
    draw_circle(Vector2(25 * facing, -18), 7, Color("#b97f62"))
    var angle := deg_to_rad(-8.0 * facing)
    if attack != null:
        angle = _current_attack_angle()
    var local_tip := _weapon_tip_at(angle)
    draw_line(Vector2(27 * facing, -18), local_tip, steel, 8.0, true)
    draw_line(Vector2(27 * facing, -18), local_tip, Color("#f3f0e8", 0.55), 2.0, true)
    var guard_center := Vector2(30 * facing, -18)
    draw_line(guard_center + Vector2(0, -8), guard_center + Vector2(0, 8), secondary, 5.0, true)
    draw_circle(local_tip, 3.0, Color("#f0d38a", 0.8))

    # Defensive read.
    if state == State.BLOCK:
        draw_arc(Vector2(20 * facing, -5), 48, -1.25, 1.25, 24, Color(0.78, 0.86, 0.95, 0.72), 5.0)
        if parry_clock > 0.0:
            draw_arc(Vector2(20 * facing, -5), 55, -1.0, 1.0, 20, Color(0.92, 0.78, 0.45, 0.9), 4.0)
    elif counter_armed:
        draw_arc(Vector2(0, -28), 23, 0.15, PI - 0.15, 18, Color(0.85, 0.72, 0.4, 0.8), 3.0)

    if state == State.STAGGER:
        draw_circle(Vector2(0, -55), 4.0, Color("#e2b24e"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for i in range(24):
        var a := TAU * float(i) / 24.0
        points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(points, color)
