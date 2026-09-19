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

    enemy.global_position = player.global_position + Vector2(82, 0)
    var before := enemy.health
    player.resolve_active_hit([enemy])
    if enemy.health >= before:
        _fail("active weapon trace must be able to damage a target")
        return

    enemy.state = ArenaMeleeFighter.State.READY
    if not enemy.perform_attack(ArenaMeleeAttack.Kind.STAB):
        _fail("enemy stab should start")
        return
    enemy._tick_state(0.12)
    if enemy.state != ArenaMeleeFighter.State.ACTIVE:
        _fail("stab must enter active state")
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
