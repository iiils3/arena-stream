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
var player_queue: ArenaPlayerQueue
var players: Array[ArenaMeleeFighter] = []
var enemies: Array[ArenaMeleeFighter] = []
var player_names: Array[String] = []
var player_lives: Dictionary = {}
var player_slots: Array[String] = ["", "", "", ""]
var fighter_slots: Dictionary = {}
var prepared_intermission := false
var local_player: ArenaMeleeFighter
var pulse := 0.0

func _ready() -> void:
    stage_director = ArenaStageDirector.new()
    add_child(stage_director)
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
    for slot in TEAM_SIZE:
        if not player_slots[slot].is_empty():
            player_queue.mark_player_out(slot)
            player_slots[slot] = ""
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

    if remaining > 0 and not player_queue.waiting_players.has(name):
        player_queue.register_player(name)

    if _active_players().is_empty() and stage_director.running:
        stage_director.fail_current_stage()

func _prepare_intermission_team() -> void:
    if stage_director.current_stage_index > 0 and stage_director.get_current_stage() != null:
        pass

    if _active_players().is_empty():
        player_slots = player_queue.begin_team()
    else:
        player_slots = player_queue.replace_missing_slots()

    _spawn_team()

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
    draw_rect(Rect2(0, 0, 1920, 1080), Color("#090c12"))

    for band in range(8):
        var y := 90.0 + float(band) * 62.0
        draw_rect(Rect2(0, y, 1920, 64), Color(0.06 + band * 0.008, 0.07 + band * 0.008, 0.09 + band * 0.01))

    draw_circle(Vector2(1530, 175), 72.0, Color("#d9d8cb", 0.75))
    draw_circle(Vector2(1550, 157), 72.0, Color("#11151e", 0.70))

    draw_colored_polygon(PackedVector2Array([
        Vector2(0, 470), Vector2(180, 330), Vector2(360, 440), Vector2(560, 300),
        Vector2(760, 450), Vector2(960, 315), Vector2(1160, 450), Vector2(1370, 295),
        Vector2(1580, 445), Vector2(1760, 325), Vector2(1920, 440), Vector2(1920, 570),
        Vector2(0, 570)
    ]), Color("#151b24"))

    draw_rect(Rect2(620, 245, 680, 310), Color("#292f39"))
    draw_rect(Rect2(570, 185, 125, 370), Color("#343a45"))
    draw_rect(Rect2(1225, 185, 125, 370), Color("#343a45"))
    draw_rect(Rect2(760, 300, 400, 255), Color("#20252e"))
    draw_rect(Rect2(830, 335, 260, 220), Color("#080b10"))

    for x in [570.0, 635.0, 1225.0, 1290.0]:
        for battlement in range(3):
            draw_rect(Rect2(x + battlement * 38.0, 165, 25, 28), Color("#3d444f"))

    draw_rect(Rect2(0, 520, 1920, 560), Color("#403a35"))
    for depth in range(9):
        var y := 565.0 + depth * 58.0
        draw_line(Vector2(0, y), Vector2(1920, y), Color(0.92, 0.86, 0.74, 0.10 - depth * 0.006), 2.0)

    for x in range(-500, 2500, 170):
        draw_line(Vector2(960, 540), Vector2(x, 1080), Color(0.08, 0.07, 0.065, 0.22), 2.0)

    draw_rect(Rect2(34, 500, 145, 580), Color("#20242b"))
    draw_rect(Rect2(1741, 500, 145, 580), Color("#20242b"))

    for x in [590.0, 1330.0]:
        draw_circle(Vector2(x, 505), 18.0, Color("#8f4825", 0.70))
        draw_circle(Vector2(x, 495), 10.0, Color("#e2a14b", 0.90))
        draw_circle(Vector2(x, 485), 5.0, Color("#f5d38a", 0.95))

    draw_rect(Rect2(52, 45, 510, 122), Color(0.02, 0.03, 0.045, 0.82))
    draw_line(Vector2(52, 167), Vector2(562, 167), Color("#a48a62", 0.55), 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(78, 86), "THE ASHEN GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#e8dfcf"))
    draw_string(ThemeDB.fallback_font, Vector2(78, 121), "STAGE RUN  /  FOUR FIGHTERS", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#9fa6b0"))
    draw_string(ThemeDB.fallback_font, Vector2(78, 148), "LIVE BATTLE  •  10 MINUTE LIMIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#c59a67"))

    var stage := stage_director.get_current_stage()
    if stage != null:
        var remaining := stage_director.get_remaining_seconds()
        var minutes := remaining / 60
        var seconds := remaining % 60
        var time_text := "%02d:%02d" % [minutes, seconds]
        var progress := stage_director.equivalent_kills
        var required := stage.kill_requirement

        draw_rect(Rect2(680, 45, 560, 92), Color(0.02, 0.03, 0.045, 0.78))
        draw_string(ThemeDB.fallback_font, Vector2(708, 76), "STAGE %02d" % stage.stage_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#a48a62"))
        draw_string(ThemeDB.fallback_font, Vector2(708, 108), "%d / %d ENEMIES" % [progress, required], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#e8dfcf"))
        draw_string(ThemeDB.fallback_font, Vector2(1115, 105), time_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#e8dfcf"))

    draw_rect(Rect2(1430, 45, 438, 122), Color(0.02, 0.03, 0.045, 0.82))
    draw_string(ThemeDB.fallback_font, Vector2(1455, 78), "TEAM", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#a48a62"))
    var team_line := ""
    for slot in TEAM_SIZE:
        var name := player_slots[slot]
        team_line += ("%s" % name) if not name.is_empty() else "OPEN"
        if slot < TEAM_SIZE - 1:
            team_line += "  •  "
    draw_string(ThemeDB.fallback_font, Vector2(1455, 110), team_line, HORIZONTAL_ALIGNMENT_LEFT, 385, 14, Color("#e8dfcf"))
    draw_string(ThemeDB.fallback_font, Vector2(1455, 140), "ACTIVE %d / 4  •  QUEUE %d" % [_active_players().size(), player_queue.get_waiting_count()], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#9fa6b0"))

    if stage_director.intermission:
        var left := stage_director.get_intermission_remaining_seconds()
        draw_rect(Rect2(620, 830, 680, 150), Color(0.02, 0.03, 0.045, 0.90))
        draw_string(ThemeDB.fallback_font, Vector2(770, 875), "NEXT ROUND", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#a48a62"))
        draw_string(ThemeDB.fallback_font, Vector2(770, 918), "%02d" % left, HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color("#e8dfcf"))
        draw_string(ThemeDB.fallback_font, Vector2(850, 918), "SECONDS", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#9fa6b0"))

    draw_rect(Rect2(58, 942, 420, 74), Color(0.02, 0.03, 0.045, 0.76))
    draw_string(ThemeDB.fallback_font, Vector2(78, 972), "LOCAL CONTROL  J/I/K  •  SPACE BLOCK  •  L DODGE  •  SHIFT KICK  •  F FEINT", HORIZONTAL_ALIGNMENT_LEFT, 380, 14, Color("#d9d1c4"))
