extends Node2D
class_name ArenaCombatShowcase

var fighter_scene := preload("res://scenes/showcase/fighter.tscn")
var hud_scene := preload("res://scenes/showcase/mobile_hud.tscn")
var player: ArenaMeleeFighter
var enemy: ArenaMeleeFighter
var elapsed := 0.0

func _ready() -> void:
    player = fighter_scene.instantiate()
    player.fighter_name = "PLAYER"
    player.is_player = true
    player.position = Vector2(720, 570)
    add_child(player)

    enemy = fighter_scene.instantiate()
    enemy.fighter_name = "GUARD"
    enemy.is_player = false
    enemy.position = Vector2(1180, 570)
    add_child(enemy)

    player.hit_landed.connect(_on_hit_landed)
    enemy.hit_landed.connect(_on_hit_landed)
    player.defeated.connect(_on_defeated)
    enemy.defeated.connect(_on_defeated)
    player.ai_target = enemy
    enemy.ai_target = player
    var hud := hud_scene.instantiate()
    add_child(hud)
    hud.get_node("Controls").bind_fighter(player)
    var bot := preload("res://scripts/ai/melee_bot.gd").new()
    bot.fighter_path = NodePath("..")
    enemy.add_child(bot)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    if is_instance_valid(player) and is_instance_valid(enemy):
        player.resolve_active_hit([enemy])
        enemy.resolve_active_hit([player])
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not is_instance_valid(player):
        return
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_J:
                player.perform_attack(ArenaMeleeAttack.Kind.SLASH)
            KEY_I:
                player.perform_attack(ArenaMeleeAttack.Kind.OVERHEAD)
            KEY_K:
                player.perform_attack(ArenaMeleeAttack.Kind.STAB)
            KEY_SPACE:
                player.set_block(true)
            KEY_L:
                player.dodge(Vector2(player.facing, 0))
            KEY_SHIFT:
                player.set_block(false)
                if absf(enemy.global_position.x - player.global_position.x) < 95.0:
                    enemy.stagger_clock = 0.45
                    enemy.state = ArenaMeleeFighter.State.STAGGER
            KEY_R:
                _reset_fight()

    if event is InputEventKey and not event.pressed and event.keycode == KEY_SPACE:
        player.set_block(false)

func _on_hit_landed(_attacker, target, _damage) -> void:
    if target == enemy:
        var cam := get_node_or_null("Camera2D") as Camera2D
        if cam:
            cam.offset = Vector2(randf_range(-5,5), randf_range(-3,3))

func _on_defeated(_fighter, _attacker) -> void:
    await get_tree().create_timer(1.0).timeout
    _reset_fight()

func _reset_fight() -> void:
    player.global_position = Vector2(720,570)
    enemy.global_position = Vector2(1180,570)
    player.health = player.max_health
    enemy.health = enemy.max_health
    player.stamina = player.max_stamina
    enemy.stamina = enemy.max_stamina
    player.state = ArenaMeleeFighter.State.READY
    enemy.state = ArenaMeleeFighter.State.READY
    player.attack = null
    enemy.attack = null
    player.velocity = Vector2.ZERO
    enemy.velocity = Vector2.ZERO
    queue_redraw()

func _draw() -> void:
    # Establishing composition: distant fortress, layered terrain, then the combat lane.
    draw_rect(Rect2(0, 0, 1920, 1080), Color("#0a0d13"))

    for band in range(7):
        var band_y := 120.0 + float(band) * 70.0
        var shade := 0.055 + float(band) * 0.012
        draw_rect(Rect2(0, band_y, 1920, 72), Color(shade, shade + 0.012, shade + 0.028))

    # Moon and distant mountain silhouettes.
    draw_circle(Vector2(1510, 205), 76.0, Color("#d7d8cf", 0.78))
    draw_circle(Vector2(1532, 187), 76.0, Color("#11151e", 0.72))

    draw_colored_polygon(PackedVector2Array([
        Vector2(0, 475), Vector2(180, 330), Vector2(340, 445), Vector2(530, 300),
        Vector2(730, 450), Vector2(920, 325), Vector2(1110, 450), Vector2(1320, 290),
        Vector2(1540, 445), Vector2(1730, 315), Vector2(1920, 440), Vector2(1920, 560),
        Vector2(0, 560)
    ]), Color("#151b24"))

    draw_colored_polygon(PackedVector2Array([
        Vector2(0, 500), Vector2(240, 395), Vector2(470, 500), Vector2(720, 370),
        Vector2(990, 505), Vector2(1260, 380), Vector2(1500, 500), Vector2(1760, 365),
        Vector2(1920, 485), Vector2(1920, 590), Vector2(0, 590)
    ]), Color("#202631"))

    # Fortress silhouette.
    draw_rect(Rect2(650, 245, 620, 315), Color("#2b3039"))
    draw_rect(Rect2(610, 185, 125, 375), Color("#343a45"))
    draw_rect(Rect2(1185, 185, 125, 375), Color("#343a45"))
    draw_rect(Rect2(770, 295, 380, 265), Color("#222731"))
    draw_rect(Rect2(835, 330, 250, 230), Color("#080b10"))

    for x in [610.0, 675.0, 1185.0, 1250.0]:
        for battlement in range(3):
            draw_rect(Rect2(x + float(battlement) * 38.0, 165, 25, 28), Color("#3d444f"))

    draw_rect(Rect2(735, 240, 450, 22), Color("#1a1f28"))
    draw_line(Vector2(740, 262), Vector2(1180, 262), Color("#606975", 0.35), 3.0)

    # Gate depth and portcullis.
    draw_rect(Rect2(805, 330, 310, 230), Color("#11151c"))
    draw_arc(Vector2(960, 375), 155, PI, TAU, 32, Color("#555d68", 0.8), 10.0)
    for x in range(830, 1100, 34):
        draw_line(Vector2(x, 375), Vector2(x, 555), Color("#454b55"), 7.0)

    # Banners.
    draw_line(Vector2(755, 230), Vector2(755, 380), Color("#7b6b54"), 4.0)
    draw_colored_polygon(PackedVector2Array([
        Vector2(758, 235), Vector2(850, 255), Vector2(758, 290)
    ]), Color("#8b2637"))
    draw_line(Vector2(1165, 230), Vector2(1165, 380), Color("#7b6b54"), 4.0)
    draw_colored_polygon(PackedVector2Array([
        Vector2(1162, 235), Vector2(1070, 255), Vector2(1162, 290)
    ]), Color("#8b2637"))

    # Ground plane with depth bands.
    draw_colored_polygon(PackedVector2Array([
        Vector2(0, 525), Vector2(1920, 525), Vector2(1920, 1080), Vector2(0, 1080)
    ]), Color("#403a35"))
    for depth in range(9):
        var y := 565.0 + float(depth) * 58.0
        var alpha := 0.11 - float(depth) * 0.006
        draw_line(Vector2(0, y), Vector2(1920, y), Color(0.92, 0.86, 0.74, alpha), 2.0)

    # Perspective seams make the arena read as a physical space instead of a flat panel.
    for x in range(-500, 2500, 170):
        draw_line(Vector2(960, 540), Vector2(x, 1080), Color(0.08, 0.07, 0.065, 0.22), 2.0)

    # Stone foreground walls and iron details.
    draw_rect(Rect2(35, 505, 145, 575), Color("#20242b"))
    draw_rect(Rect2(1740, 505, 145, 575), Color("#20242b"))
    for y in range(530, 1080, 82):
        draw_line(Vector2(35, y), Vector2(180, y), Color("#454a52", 0.35), 2.0)
        draw_line(Vector2(1740, y), Vector2(1885, y), Color("#454a52", 0.35), 2.0)

    # Braziers and restrained light pools.
    for x in [585.0, 1335.0]:
        draw_circle(Vector2(x, 515), 34.0, Color("#111318"))
        draw_circle(Vector2(x, 505), 18.0, Color("#8f4825", 0.72))
        draw_circle(Vector2(x, 495), 10.0, Color("#e2a14b", 0.9))
        draw_circle(Vector2(x, 485), 5.0, Color("#f5d38a", 0.95))
        draw_circle(Vector2(x, 510), 74.0, Color(0.75, 0.36, 0.12, 0.045))

    # Combat-stage framing.
    draw_rect(Rect2(52, 48, 430, 116), Color(0.03, 0.04, 0.055, 0.76))
    draw_line(Vector2(52, 164), Vector2(482, 164), Color("#a48a62", 0.55), 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(78, 88), "THE ASHEN GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#e8dfcf"))
    draw_string(ThemeDB.fallback_font, Vector2(78, 123), "NIGHT WATCH  •  OUTER WALL", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#9fa6b0"))
    draw_string(ThemeDB.fallback_font, Vector2(78, 148), "DUEL GROUND  /  LIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#c59a67"))

    # Compact combat readout.
    draw_rect(Rect2(690, 48, 540, 74), Color(0.03, 0.04, 0.055, 0.68))
    draw_string(ThemeDB.fallback_font, Vector2(715, 78), "STAGE 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#a48a62"))
    draw_string(ThemeDB.fallback_font, Vector2(715, 108), "BREAK THE WATCH  •  0 / 8", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#e8dfcf"))
    draw_string(ThemeDB.fallback_font, Vector2(1115, 96), "09:58", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#e8dfcf"))

    # Player status strips; keep the battlefield unobstructed.
    if is_instance_valid(player):
        draw_rect(Rect2(58, 940, 300, 82), Color(0.03, 0.04, 0.055, 0.72))
        draw_string(ThemeDB.fallback_font, Vector2(78, 968), "VANGUARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#d9d1c4"))
        draw_string(ThemeDB.fallback_font, Vector2(78, 997), "HP %03d   ST %03d" % [int(player.health), int(player.stamina)], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#eee7db"))
        draw_rect(Rect2(185, 957, 145, 8), Color("#181b20"))
        draw_rect(Rect2(185, 957, 145 * clampf(player.health / player.max_health, 0.0, 1.0), 8), Color("#a63a42"))

    if is_instance_valid(enemy):
        draw_rect(Rect2(1562, 940, 300, 82), Color(0.03, 0.04, 0.055, 0.72))
        draw_string(ThemeDB.fallback_font, Vector2(1582, 968), "CASTLE GUARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#d9d1c4"))
        draw_string(ThemeDB.fallback_font, Vector2(1582, 997), "HP %03d   ST %03d" % [int(enemy.health), int(enemy.stamina)], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#eee7db"))
        draw_rect(Rect2(1689, 957, 145, 8), Color("#181b20"))
        draw_rect(Rect2(1689, 957, 145 * clampf(enemy.health / enemy.max_health, 0.0, 1.0), 8), Color("#6e737c"))
