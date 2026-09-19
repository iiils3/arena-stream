extends SceneTree

const SHOWCASE_SCENE := preload("res://scenes/showcase/combat_showcase.tscn")

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("ARENA SMOKE TEST FAILED: " + message)
    quit(1)

func _run() -> void:
    var showcase = SHOWCASE_SCENE.instantiate()
    root.add_child(showcase)
    await process_frame
    await process_frame

    if not is_instance_valid(showcase.player) or not is_instance_valid(showcase.enemy):
        _fail("combat showcase must create one player and one AI enemy")
        return

    var player: ArenaMeleeFighter = showcase.player
    var enemy: ArenaMeleeFighter = showcase.enemy

    if player.is_player != true or enemy.is_player != false:
        _fail("fighter roles are incorrect")
        return

    if player.health != player.max_health or enemy.health != enemy.max_health:
        _fail("fighters must start at full health")
        return

    if not player.perform_attack(ArenaMeleeAttack.Kind.SLASH):
        _fail("slash should start from ready state")
        return
    if player.state != ArenaMeleeFighter.State.WINDUP:
        _fail("slash must enter windup")
        return

    player._tick_state(0.16)
    if player.state != ArenaMeleeFighter.State.ACTIVE:
        _fail("slash must enter active state")
        return

    var trace_target := player.global_position + player._weapon_tip_at(player._current_attack_angle())
    enemy.global_position = trace_target
    var before := enemy.health
    player.resolve_active_hit([enemy])
    if enemy.health >= before:
        _fail("active weapon trace must be able to damage a target")
        return

    enemy.state = ArenaMeleeFighter.State.READY
    enemy.stagger_clock = 0.0
    if not enemy.perform_attack(ArenaMeleeAttack.Kind.STAB):
        _fail("enemy stab should start")
        return
    enemy._tick_state(0.13)
    if enemy.state != ArenaMeleeFighter.State.ACTIVE:
        _fail("stab must enter active state")
        return

    player.set_block(true)
    var parry_result := player.receive_melee_hit(enemy, enemy.attack, player.global_position)
    if not parry_result or player.state != ArenaMeleeFighter.State.READY:
        _fail("timed block must parry an incoming active attack")
        return
    if not player.counter_armed:
        _fail("successful parry must open a short counter window")
        return
    if not player.perform_attack(ArenaMeleeAttack.Kind.OVERHEAD):
        _fail("counter attack should start during the counter window")
        return
    if player.attack.damage <= ArenaMeleeAttack.for_kind(ArenaMeleeAttack.Kind.OVERHEAD).damage:
        _fail("counter attack must carry a damage advantage")
        return

    player.state = ArenaMeleeFighter.State.READY
    player.attack = null
    player.attack_clock = 0.0
    if not player.perform_attack(ArenaMeleeAttack.Kind.SLASH):
        _fail("slash should be available for feint")
        return
    if not player.feint() or player.state != ArenaMeleeFighter.State.READY:
        _fail("feint must cancel an early attack")
        return

    enemy.state = ArenaMeleeFighter.State.BLOCK
    enemy.block_held = true
    player.state = ArenaMeleeFighter.State.READY
    if not player.kick():
        _fail("kick should start from ready state")
        return
    player.resolve_kick_hit([enemy])
    if enemy.state != ArenaMeleeFighter.State.STAGGER:
        _fail("kick must break a held guard")
        return

    var stamina_before := player.stamina
    if not player.dodge(Vector2.RIGHT):
        _fail("dodge should consume stamina and start")
        return
    if player.stamina >= stamina_before:
        _fail("dodge must consume stamina")
        return
    if not player.invulnerable:
        _fail("dodge must provide a short invulnerability window")
        return

    print("ARENA COMBAT SMOKE TEST PASSED")
    showcase.queue_free()
    quit(0)
