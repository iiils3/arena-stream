extends Node2D
class_name ArenaStageRun

const TEAM_SIZE := 4
const PLAYER_SPAWN := [
    Vector2(820, 690),
    Vector2(900, 650),
    Vector2(980, 650),
    Vector2(1060, 690)
]
const ENEMY_SPAWN := [
    Vector2(430, 600), Vector2(520, 520), Vector2(610, 680), Vector2(700, 500),
    Vector2(1490, 600), Vector2(1400, 520), Vector2(1310, 680), Vector2(1220, 500)
]
const PLAYER_NAMES := ["Vanguard", "Warden", "Ranger", "Knight", "Mercenary", "Scout", "Guard", "Fighter"]

var fighter_scene := preload("res://scenes/showcase/fighter.tscn")
var hud_scene := preload("res://scenes/showcase/mobile_hud.tscn")
var enemy_bot_script := preload("res://scripts/ai/melee_bot.gd")
var ally_bot_script := preload("res://scripts/ai/ally_bot.gd")

var stage_director: ArenaStageDirector
var audience_director: ArenaAudienceDirector
var player_queue: ArenaPlayerQueue
var players: Array[ArenaMeleeFighter] = []
var enemies: Array[ArenaMeleeFighter] = []
var player_names: Array[String] = []
var player_lives: Dictionary = {}
var player_slots: Array[String] = ["", "", "", ""]
var fighter_slots: Dictionary = {}
var prepared_intermission := false
var run_team_active := false
var local_player: ArenaMeleeFighter
var pulse := 0.0

func _ready() -> void:
    stage_director = ArenaStageDirector.new()
    add_child(stage_director)
    audience_director = ArenaAudienceDirector.new()
    add_child(audience_director)
    audience_director.vote_closed.connect(_on_audience_event_selected)
    audience_director.event_started.connect(_on_audience_event_started)
    audience_director.event_finished.connect(_on_audience_event_finished)
    player_queue = ArenaPlayerQueue.new()
    add_child(player_queue)

    stage_director.stage_started.connect(_on_stage_started)
    stage_director.stage_progress_changed.connect(_on_stage_progress)
    stage_director.stage_cleared.connect(_on_stage_cleared)
    stage_director.stage_failed.connect(_on_stage_failed)
    stage_director.round_finished.connect(_on_run_finished)

    for index in PLAYER_NAMES.size():
        var name: String = PLAYER_NAMES[index]
        player_queue.register_player(name)
        player_lives[name] = 2

    player_slots = player_queue.begin_team()
    _spawn_team()
    stage_director.start_run()
    audience_director.start_round()
    queue_redraw()

func _process(delta: float) -> void:
    pulse += delta

    if stage_director.intermission and not prepared_intermission:
        prepared_intermission = true
        _prepare_intermission_team()

    _update_targets()
    _process_enemy_hits()
    _process_player_hits()
    queue_redraw()

func _update_targets() -> void:
    var active_players := _active_players()
    var active_enemies := _active_enemies()

    for enemy in active_enemies:
        enemy.ai_target = _nearest_target(enemy.global_position, active_players)

    for ally in players:
        if ally == local_player or ally.state == ArenaMeleeFighter.State.DEFEATED:
            continue
        ally.ai_target = _nearest_target(ally.global_position, active_enemies)

func _process_enemy_hits() -> void:
    var active_players := _active_players()
    for enemy in _active_enemies():
        enemy.resolve_active_hit(active_players)
        enemy.resolve_kick_hit(active_players)

func _process_player_hits() -> void:
    var active_enemies := _active_enemies()
    for player in players:
        if player.state == ArenaMeleeFighter.State.DEFEATED:
            continue
        player.resolve_active_hit(active_enemies)
        player.resolve_kick_hit(active_enemies)

func _spawn_team() -> void:
    for fighter in players:
        if is_instance_valid(fighter):
            fighter.queue_free()
    players.clear()
    fighter_slots.clear()
    local_player = null

    for slot in TEAM_SIZE:
        var name := player_slots[slot]
        if name.is_empty():
            continue

        var fighter: ArenaMeleeFighter = fighter_scene.instantiate()
        fighter.fighter_name = name.to_upper()
        fighter.is_player = slot == 0
        fighter.position = PLAYER_SPAWN[slot]
        add_child(fighter)
        fighter.defeated.connect(_on_player_defeated)
        fighter_slots[fighter] = slot
        players.append(fighter)

        if slot == 0:
            local_player = fighter
        else:
            var bot := ally_bot_script.new()
            bot.fighter_path = NodePath("..")
            fighter.add_child(bot)

    if is_instance_valid(local_player):
        var hud := get_node_or_null("MobileCombatHUD")
        if hud == null:
            hud = hud_scene.instantiate()
            hud.name = "MobileCombatHUD"
            add_child(hud)
        hud.get_node("Controls").bind_fighter(local_player)


func _spawn_missing_team_members() -> void:
    for slot in TEAM_SIZE:
        var name := player_slots[slot]
        if name.is_empty():
            continue

        var existing := false
        for fighter in players:
            if not is_instance_valid(fighter):
                continue
            if int(fighter_slots.get(fighter, -1)) == slot and fighter.state != ArenaMeleeFighter.State.DEFEATED:
                existing = true
                break
        if existing:
            continue

        var fighter: ArenaMeleeFighter = fighter_scene.instantiate()
        fighter.fighter_name = name.to_upper()
        fighter.is_player = slot == 0
        fighter.position = PLAYER_SPAWN[slot]
        add_child(fighter)
        fighter.defeated.connect(_on_player_defeated)
        fighter_slots[fighter] = slot
        players.append(fighter)

        if slot == 0:
            local_player = fighter
        else:
            var bot := ally_bot_script.new()
            bot.fighter_path = NodePath("..")
            fighter.add_child(bot)

    if is_instance_valid(local_player):
        var hud := get_node_or_null("MobileCombatHUD")
        if hud == null:
            hud = hud_scene.instantiate()
            hud.name = "MobileCombatHUD"
            add_child(hud)
        hud.get_node("Controls").bind_fighter(local_player)

func _spawn_enemies(count: int) -> void:
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    enemies.clear()

    for index in count:
        var enemy: ArenaMeleeFighter = fighter_scene.instantiate()
        enemy.fighter_name = "GUARD %02d" % (index + 1)
        enemy.is_player = false
        enemy.position = ENEMY_SPAWN[index % ENEMY_SPAWN.size()]
        add_child(enemy)
        enemy.defeated.connect(_on_enemy_defeated)

        var bot := enemy_bot_script.new()
        bot.fighter_path = NodePath("..")
        enemy.add_child(bot)
        enemies.append(enemy)

func _on_stage_started(stage: ArenaStageDefinition) -> void:
    prepared_intermission = false
    _spawn_enemies(stage.enemy_count)
    queue_redraw()

func _on_stage_progress(_kills: int, _required: int) -> void:
    queue_redraw()

func _on_stage_cleared(_stage: ArenaStageDefinition) -> void:
    prepared_intermission = false
    queue_redraw()

func _on_stage_failed(_stage: ArenaStageDefinition) -> void:
    prepared_intermission = false
    run_team_active = false
    for slot in TEAM_SIZE:
        if not player_slots[slot].is_empty():
            player_queue.mark_player_out(slot)
            player_slots[slot] = ""
    for fighter in players:
        if is_instance_valid(fighter):
            fighter.queue_free()
    players.clear()
    fighter_slots.clear()
    local_player = null
    queue_redraw()

func _on_enemy_defeated(enemy: ArenaMeleeFighter, attacker: ArenaMeleeFighter) -> void:
    if not enemies.has(enemy):
        return
    if is_instance_valid(attacker) and players.has(attacker):
        stage_director.register_normal_kill()
    else:
        stage_director.register_normal_kill()

    var enemy_index := enemies.find(enemy)
    if enemy_index >= 0:
        enemies.remove_at(enemy_index)
    await get_tree().create_timer(0.35).timeout
    if is_instance_valid(enemy):
        enemy.queue_free()

func _on_player_defeated(fighter: ArenaMeleeFighter, _attacker: ArenaMeleeFighter) -> void:
    var slot := int(fighter_slots.get(fighter, -1))
    if slot < 0 or slot >= TEAM_SIZE:
        return

    var name := fighter.fighter_name.capitalize()
    var remaining := int(player_lives.get(name, 2)) - 1
    player_lives[name] = remaining
    player_queue.mark_player_out(slot)
    player_slots[slot] = ""
    fighter_slots.erase(fighter)

    if _active_players().is_empty() and stage_director.running:
        stage_director.fail_current_stage()

func _prepare_intermission_team() -> void:
    if not run_team_active:
        player_slots = player_queue.begin_team()
        run_team_active = true
    else:
        player_slots = player_queue.replace_missing_slots()

    _spawn_missing_team_members()

func _active_players() -> Array[ArenaMeleeFighter]:
    var result: Array[ArenaMeleeFighter] = []
    for player in players:
        if is_instance_valid(player) and player.state != ArenaMeleeFighter.State.DEFEATED:
            result.append(player)
    return result

func _active_enemies() -> Array[ArenaMeleeFighter]:
    var result: Array[ArenaMeleeFighter] = []
    for enemy in enemies:
        if is_instance_valid(enemy) and enemy.state != ArenaMeleeFighter.State.DEFEATED:
            result.append(enemy)
    return result

func _nearest_target(origin: Vector2, targets: Array[ArenaMeleeFighter]) -> ArenaMeleeFighter:
    var best: ArenaMeleeFighter
    var best_distance := INF
    for target in targets:
        if not is_instance_valid(target):
            continue
        var distance := origin.distance_squared_to(target.global_position)
        if distance < best_distance:
            best_distance = distance
            best = target
    return best

func _on_audience_event_selected(_event: ArenaAudienceEvent) -> void:
    queue_redraw()

func _on_audience_event_started(_event: ArenaAudienceEvent) -> void:
    queue_redraw()

func _on_audience_event_finished(_event: ArenaAudienceEvent) -> void:
    queue_redraw()

func _on_run_finished() -> void:
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    enemies.clear()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not is_instance_valid(local_player):
        return
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_J:
                local_player.perform_attack(ArenaMeleeAttack.Kind.SLASH)
            KEY_I:
                local_player.perform_attack(ArenaMeleeAttack.Kind.OVERHEAD)
            KEY_K:
                local_player.perform_attack(ArenaMeleeAttack.Kind.STAB)
            KEY_SPACE:
                local_player.set_block(true)
            KEY_L:
                local_player.dodge(Vector2(local_player.facing, 0))
            KEY_SHIFT:
                local_player.kick()
            KEY_F:
                local_player.feint()
    if event is InputEventKey and not event.pressed and event.keycode == KEY_SPACE:
        local_player.set_block(false)

func _draw() -> void:
    # Ashen Gate presentation slice: layered depth, masonry, torch light, and a clear combat lane.
    draw_rect(Rect2(0, 0, 1920, 1080), Color("#080b10"))

    # Night sky gradient bands.
    for band in range(12):
        var sky_y := float(band) * 48.0
        var t := float(band) / 11.0
        draw_rect(Rect2(0, sky_y, 1920, 50), Color(0.035 + t * 0.025, 0.045 + t * 0.028, 0.065 + t * 0.035))

    # Moon, haze and distant ridgeline.
    draw_circle(Vector2(1505, 175), 78.0, Color(0.82, 0.83, 0.79, 0.82))
    draw_circle(Vector2(1532, 151), 78.0, Color(0.045, 0.055, 0.075, 0.88))
    for haze in range(4):
        draw_rect(Rect2(0, 390 + haze * 30, 1920, 32), Color(0.20, 0.23, 0.27, 0.035))

    draw_colored_polygon(PackedVector2Array([
        Vector2(0, 500), Vector2(150, 370), Vector2(300, 450), Vector2(470, 315),
        Vector2(650, 455), Vector2(840, 335), Vector2(1020, 455), Vector2(1210, 320),
        Vector2(1400, 450), Vector2(1600, 335), Vector2(1770, 445), Vector2(1920, 365),
        Vector2(1920, 575), Vector2(0, 575)
    ]), Color("#151b24"))

    # Main curtain wall.
    draw_rect(Rect2(485, 255, 950, 320), Color("#2a2f37"))
    draw_rect(Rect2(510, 280, 900, 285), Color("#343a43"))
    draw_line(Vector2(510, 305), Vector2(1410, 305), Color("#4d545e"), 3.0)
    draw_line(Vector2(510, 410), Vector2(1410, 410), Color("#252a32"), 5.0)
    draw_line(Vector2(510, 515), Vector2(1410, 515), Color("#252a32"), 5.0)

    # Individual masonry blocks.
    for row in range(3):
        var row_y := 330.0 + row * 105.0
        var offset := 0.0 if row % 2 == 0 else 55.0
        for col in range(9):
            var bx := 510.0 + offset + col * 112.0
            if bx > 1400.0:
                continue
            draw_rect(Rect2(bx, row_y, 106, 94), Color("#30363f"))
            draw_line(Vector2(bx + 5, row_y + 6), Vector2(bx + 101, row_y + 6), Color(1, 1, 1, 0.055), 2.0)

    _draw_gate_tower(Vector2(545, 145), false)
    _draw_gate_tower(Vector2(1245, 145), true)

    # Gatehouse depth and arched entrance.
    draw_rect(Rect2(720, 300, 480, 275), Color("#22272f"))
    draw_rect(Rect2(770, 335, 380, 240), Color("#11151b"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(770, 575), Vector2(770, 410), Vector2(805, 365), Vector2(850, 335),
        Vector2(1070, 335), Vector2(1115, 365), Vector2(1150, 410), Vector2(1150, 575)
    ]), Color("#0b0e13"))
    draw_arc(Vector2(960, 410), 190, PI, TAU, 42, Color("#555c66"), 9.0)

    # Portcullis and gate timber.
    for x in range(800, 1140, 32):
        draw_line(Vector2(x, 365), Vector2(x, 575), Color("#4c5158"), 7.0)
    for y in range(405, 575, 38):
        draw_line(Vector2(785, y), Vector2(1135, y), Color("#3c4149"), 5.0)
    draw_line(Vector2(785, 375), Vector2(1135, 375), Color("#747a82"), 4.0)

    # Banners and ironwork.
    _draw_banner(Vector2(705, 210), 1)
    _draw_banner(Vector2(1215, 210), -1)
    draw_line(Vector2(930, 245), Vector2(930, 300), Color("#8d744d"), 4.0)
    draw_line(Vector2(990, 245), Vector2(990, 300), Color("#8d744d"), 4.0)

    # Battlements across the wall.
    for x in range(500, 1420, 62):
        draw_rect(Rect2(x, 235, 40, 32), Color("#454b54"))
        draw_rect(Rect2(x + 5, 230, 30, 8), Color("#555c65"))

    # Foreground combat floor with a strong perspective read.
    draw_colored_polygon(PackedVector2Array([
        Vector2(0, 540), Vector2(1920, 540), Vector2(1920, 1080), Vector2(0, 1080)
    ]), Color("#3c3732"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(220, 540), Vector2(1700, 540), Vector2(1920, 1080), Vector2(0, 1080)
    ]), Color("#4a433c"))

    for depth in range(11):
        var y := 560.0 + depth * 52.0
        draw_line(Vector2(120, y), Vector2(1800, y), Color(0.16, 0.14, 0.12, 0.34), 2.0)
    for x in range(-400, 2400, 180):
        draw_line(Vector2(960, 540), Vector2(x, 1080), Color(0.08, 0.07, 0.06, 0.32), 2.0)

    # Mud, stones and timber debris break the procedural floor pattern.
    for i in range(22):
        var px := 120.0 + float((i * 173) % 1660)
        var py := 610.0 + float((i * 97) % 410)
        var r := 3.0 + float(i % 4)
        draw_circle(Vector2(px, py), r, Color(0.16, 0.14, 0.12, 0.55))
    for x in [300.0, 1620.0]:
        draw_rect(Rect2(x, 705, 14, 135), Color("#211c19"))
        draw_line(Vector2(x + 7, 720), Vector2(x + 64, 770), Color("#5a4433"), 9.0)
        draw_line(Vector2(x + 7, 770), Vector2(x - 45, 820), Color("#4c3a2d"), 8.0)

    # Side parapets frame the arena without hiding fighters.
    draw_rect(Rect2(28, 510, 150, 570), Color("#20242b"))
    draw_rect(Rect2(1742, 510, 150, 570), Color("#20242b"))
    for y in range(545, 1080, 78):
        draw_line(Vector2(38, y), Vector2(168, y), Color("#4b5058", 0.42), 2.0)
        draw_line(Vector2(1752, y), Vector2(1882, y), Color("#4b5058", 0.42), 2.0)

    _draw_torch(Vector2(600, 525))
    _draw_torch(Vector2(1320, 525))
    _draw_torch(Vector2(250, 590))
    _draw_torch(Vector2(1670, 590))

    # Small atmospheric foreground silhouettes.
    for x in [410.0, 1510.0]:
        draw_rect(Rect2(x, 575, 20, 92), Color("#25201d"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(x - 25, 590), Vector2(x + 10, 555), Vector2(x + 45, 590)
        ]), Color("#302a26"))

    # Main stage title.
    draw_rect(Rect2(48, 42, 520, 126), Color(0.018, 0.022, 0.032, 0.86))
    draw_line(Vector2(48, 168), Vector2(568, 168), Color("#a48a62", 0.62), 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(76, 84), "THE ASHEN GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#eee7da"))
    draw_string(ThemeDB.fallback_font, Vector2(76, 119), "OUTER WALL  •  NIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#aab0b8"))
    draw_string(ThemeDB.fallback_font, Vector2(76, 148), "FOUR FIGHTERS  /  BREAK THE WATCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#c7a36e"))

    var stage := stage_director.get_current_stage()
    if stage != null:
        var remaining := stage_director.get_remaining_seconds()
        var minutes := remaining / 60
        var seconds := remaining % 60
        var progress := stage_director.equivalent_kills
        var required := stage.kill_requirement

        draw_rect(Rect2(690, 42, 545, 96), Color(0.018, 0.022, 0.032, 0.88))
        draw_string(ThemeDB.fallback_font, Vector2(718, 74), "STAGE %02d" % stage.stage_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#a48a62"))
        draw_string(ThemeDB.fallback_font, Vector2(718, 108), "BREAK THE WATCH    %d / %d" % [progress, required], HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#eee7da"))
        draw_string(ThemeDB.fallback_font, Vector2(1110, 108), "%02d:%02d" % [minutes, seconds], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#eee7da"))

    # Team panel.
    draw_rect(Rect2(1420, 42, 448, 126), Color(0.018, 0.022, 0.032, 0.88))
    draw_string(ThemeDB.fallback_font, Vector2(1446, 72), "TEAM", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#a48a62"))
    var team_line := ""
    for slot in TEAM_SIZE:
        var name := player_slots[slot]
        team_line += name if not name.is_empty() else "OPEN"
        if slot < TEAM_SIZE - 1:
            team_line += "  •  "
    draw_string(ThemeDB.fallback_font, Vector2(1446, 101), team_line, HORIZONTAL_ALIGNMENT_LEFT, 400, 13, Color("#eee7da"))
    draw_string(ThemeDB.fallback_font, Vector2(1446, 132), "ACTIVE %d / 4   •   QUEUE %d" % [_active_players().size(), player_queue.get_waiting_count()], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#aab0b8"))

    # Audience state.
    if audience_director != null:
        if audience_director.vote_open:
            draw_rect(Rect2(1385, 190, 483, 318), Color(0.018, 0.022, 0.032, 0.94))
            draw_string(ThemeDB.fallback_font, Vector2(1415, 225), "AUDIENCE VOTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#eee7da"))
            draw_string(ThemeDB.fallback_font, Vector2(1415, 252), "CHOOSE AN EVENT  •  %02d SEC" % audience_director.get_vote_seconds(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a48a62"))
            var counts := audience_director.get_vote_counts()
            for i in options.size():
                var event: ArenaAudienceEvent = audience_director.options[i]
                draw_string(ThemeDB.fallback_font, Vector2(1418, 284 + i * 34), "%d  %s" % [i + 1, event.display_name], HORIZONTAL_ALIGNMENT_LEFT, 300, 14, Color("#d9d1c4"))
                draw_string(ThemeDB.fallback_font, Vector2(1795, 284 + i * 34), "%02d" % counts[i], HORIZONTAL_ALIGNMENT_LEFT, 35, 14, Color("#c7a36e"))
        elif audience_director.active_event != null:
            draw_rect(Rect2(1390, 190, 478, 78), Color(0.018, 0.022, 0.032, 0.90))
            draw_string(ThemeDB.fallback_font, Vector2(1415, 216), "AUDIENCE EVENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#a48a62"))
            draw_string(ThemeDB.fallback_font, Vector2(1415, 245), "%s   /   %02d SEC" % [audience_director.active_event.display_name, audience_director.get_event_seconds()], HORIZONTAL_ALIGNMENT_LEFT, 435, 15, Color("#eee7da"))

    # Intermission presentation.
    if stage_director.intermission:
        var left := stage_director.get_intermission_remaining_seconds()
        draw_rect(Rect2(620, 820, 680, 170), Color(0.018, 0.022, 0.032, 0.94))
        draw_string(ThemeDB.fallback_font, Vector2(765, 862), "NEXT BATTLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#a48a62"))
        draw_string(ThemeDB.fallback_font, Vector2(765, 915), "%02d" % left, HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color("#eee7da"))
        draw_string(ThemeDB.fallback_font, Vector2(850, 915), "SECONDS", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#aab0b8"))
        draw_string(ThemeDB.fallback_font, Vector2(765, 946), "SURVIVORS ADVANCE  •  EMPTY SLOTS ARE REFILLED", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d9d1c4"))

    # Controls are deliberately compact so the battlefield stays dominant.
    draw_rect(Rect2(52, 942, 520, 74), Color(0.018, 0.022, 0.032, 0.78))
    draw_string(ThemeDB.fallback_font, Vector2(74, 970), "J / I / K  ATTACK    SPACE  BLOCK    L  DODGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d9d1c4"))
    draw_string(ThemeDB.fallback_font, Vector2(74, 996), "SHIFT  KICK    F  FEINT    1–6  AUDIENCE VOTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#aab0b8"))

func _draw_gate_tower(origin: Vector2, mirrored: bool) -> void:
    var dir := -1.0 if mirrored else 1.0
    draw_rect(Rect2(origin.x, origin.y, 155, 430), Color("#343a43"))
    draw_rect(Rect2(origin.x + 12, origin.y + 18, 131, 400), Color("#2b3038"))
    for row in range(4):
        draw_line(
            Vector2(origin.x + 15, origin.y + 55 + row * 88),
            Vector2(origin.x + 140, origin.y + 55 + row * 88),
            Color("#1f242b"),
            4.0
        )
    for slot in range(3):
        var wx := origin.x + 28 + slot * 43
        draw_rect(Rect2(wx, origin.y + 95, 20, 42), Color("#11151a"))
        draw_rect(Rect2(wx + 3, origin.y + 98, 14, 3), Color("#59606a"))
    for battlement in range(3):
        draw_rect(Rect2(origin.x + 8 + battlement * 49, origin.y - 14, 34, 28), Color("#4a515a"))
    draw_line(Vector2(origin.x + 24, origin.y + 30), Vector2(origin.x + 24, origin.y + 205), Color("#7f6a4b"), 4.0)
    var flag_x := origin.x + 27
    var flag_points := PackedVector2Array([
        Vector2(flag_x, origin.y + 35),
        Vector2(flag_x + 72 * dir, origin.y + 52),
        Vector2(flag_x, origin.y + 76)
    ])
    draw_colored_polygon(flag_points, Color("#7f2637"))
    draw_line(Vector2(origin.x + 126, origin.y + 175), Vector2(origin.x + 126, origin.y + 230), Color("#8d744d"), 3.0)

func _draw_banner(base: Vector2, direction: float) -> void:
    draw_line(base, base + Vector2(0, 110), Color("#8d744d"), 4.0)
    draw_colored_polygon(PackedVector2Array([
        base + Vector2(3, 4),
        base + Vector2(82 * direction, 23),
        base + Vector2(3, 52)
    ]), Color("#7f2637"))
    draw_line(base + Vector2(10, 14), base + Vector2(55 * direction, 25), Color("#b99063", 0.55), 2.0)

func _draw_torch(pos: Vector2) -> void:
    var flicker := sin(pulse * 8.0 + pos.x) * 2.5
    draw_circle(pos + Vector2(0, 3), 30, Color(0.80, 0.38, 0.10, 0.035))
    draw_circle(pos + Vector2(0, 1), 16, Color(0.82, 0.40, 0.12, 0.10))
    draw_line(pos + Vector2(0, 16), pos + Vector2(0, 55), Color("#3a2921"), 7.0)
    draw_circle(pos + Vector2(0, flicker), 9, Color("#c45f23", 0.78))
    draw_circle(pos + Vector2(0, -6 + flicker), 5, Color("#f0b95f", 0.94))
    draw_circle(pos + Vector2(0, -12 + flicker), 2.5, Color("#fff0bd", 0.98))

