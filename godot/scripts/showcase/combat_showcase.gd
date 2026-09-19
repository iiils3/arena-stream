extends Node2D
class_name ArenaCombatShowcase

var fighter_scene := preload("res://scenes/showcase/fighter.tscn")
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
    draw_rect(Rect2(0,0,1920,1080), Color("#101116"))
    # distant medieval skyline
    for i in range(12):
        var x := float(i * 180)
        var h := float(130 + (i % 4) * 55)
        draw_rect(Rect2(x, 420-h, 150, h), Color("#25272e"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(x-10,420-h), Vector2(x+75,360-h), Vector2(x+160,420-h)
        ]), Color("#30323a"))
    # gate and towers
    draw_rect(Rect2(780, 180, 360, 300), Color("#34363d"))
    draw_rect(Rect2(850, 275, 220, 205), Color("#17191e"))
    draw_rect(Rect2(735, 145, 80, 335), Color("#41434a"))
    draw_rect(Rect2(1105, 145, 80, 335), Color("#41434a"))
    draw_rect(Rect2(710, 125, 500, 26), Color("#17191e"))
    # banners
    draw_colored_polygon(PackedVector2Array([Vector2(780,185),Vector2(860,205),Vector2(780,235)]),Color("#8b2635"))
    draw_colored_polygon(PackedVector2Array([Vector2(1110,185),Vector2(1030,205),Vector2(1110,235)]),Color("#8b2635"))
    # battlefield
    draw_colored_polygon(PackedVector2Array([
        Vector2(0,520),Vector2(1920,520),Vector2(1920,1080),Vector2(0,1080)
    ]), Color("#4a4039"))
    for y in range(610, 1050, 70):
        draw_line(Vector2(0,y), Vector2(1920,y), Color(1,1,1,0.035), 2)
    # foreground pillars
    draw_rect(Rect2(60, 500, 110, 580), Color("#282a30"))
    draw_rect(Rect2(1750, 500, 110, 580), Color("#282a30"))
    # fire bowls
    for x in [610.0,1310.0]:
        draw_circle(Vector2(x,500), 24, Color("#17191e"))
        draw_circle(Vector2(x,490), 12, Color("#e6a23c"))
        draw_circle(Vector2(x,482), 7, Color("#f4d37a"))
    # title
    draw_string(ThemeDB.fallback_font, Vector2(70,80), "ARENA STREAM // COMBAT TEST", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#e7dfcf"))
    draw_string(ThemeDB.fallback_font, Vector2(70,116), "J Slash   I Overhead   K Stab   SPACE Block   L Dodge   SHIFT Kick   R Reset", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#aeb4bf"))
    draw_string(ThemeDB.fallback_font, Vector2(70,155), "Target: weighty directional medieval melee — mobile controls will replace keyboard in production.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8f969f"))
    if is_instance_valid(player):
        draw_string(ThemeDB.fallback_font, Vector2(70,980), "PLAYER  HP %03d   STAMINA %03d" % [int(player.health), int(player.stamina)], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#e7dfcf"))
    if is_instance_valid(enemy):
        draw_string(ThemeDB.fallback_font, Vector2(1480,980), "GUARD  HP %03d   STAMINA %03d" % [int(enemy.health), int(enemy.stamina)], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#e7dfcf"))
