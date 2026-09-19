extends SceneTree

const ARENA_SCENE := preload("res://scenes/arena_stream_arena.tscn")

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("ARENA SMOKE TEST FAILED: " + message)
    quit(1)

func _run() -> void:
    var arena = ARENA_SCENE.instantiate()
    root.add_child(arena)

    await process_frame
    await process_frame

    if arena.players.size() != 8:
        _fail("expected 8 players, got %d" % arena.players.size())
        return

    if arena.get_node("Players").get_child_count() != 8:
        _fail("Players node does not contain exactly 8 fighters")
        return

    var female_by_team := {0: 0, 1: 0}
    var male_by_team := {0: 0, 1: 0}

    for player in arena.players:
        var team := int(player.team)
        var gender := String(player.gender)
        if gender == "female":
            female_by_team[team] += 1
        elif gender == "male":
            male_by_team[team] += 1
        else:
            _fail("unknown gender assignment: %s" % gender)
            return

    if female_by_team[0] != 2 or female_by_team[1] != 2:
        _fail("each team must have exactly 2 female fighters")
        return
    if male_by_team[0] != 2 or male_by_team[1] != 2:
        _fail("each team must have exactly 2 male fighters")
        return

    var attack_probe := ArenaCombatController.new()
    attack_probe.equip(ArenaWeaponData.sword())
    if not attack_probe.try_attack() or attack_probe.state != ArenaCombatController.State.WINDUP:
        _fail("attack must enter windup state")
        return
    attack_probe.tick(0.10)
    if attack_probe.state != ArenaCombatController.State.ACTIVE:
        _fail("attack must enter active state after windup")
        return
    attack_probe.tick(0.13)
    if attack_probe.state != ArenaCombatController.State.RECOVERY:
        _fail("attack must enter recovery after active window")
        return
    attack_probe.tick(0.30)
    if attack_probe.state != ArenaCombatController.State.READY:
        _fail("attack must return to ready after recovery")
        return

    var sword := ArenaWeaponData.sword()
    var spear := ArenaWeaponData.spear()
    var bow := ArenaWeaponData.bow()

    if sword.hits_to_kill != 5:
        _fail("sword threshold changed")
        return
    if spear.hits_to_kill != 4:
        _fail("spear threshold changed")
        return
    if bow.hits_to_kill != 2:
        _fail("bow threshold changed")
        return

    if not arena.can_damage(0, 4):
        _fail("opposing teams must be damageable")
        return
    if arena.can_damage(0, 1):
        _fail("friendly fire must be disabled")
        return

    var falcon_combat := ArenaCombatController.new()
    falcon_combat.weapon = bow
    falcon_combat.hit_count = bow.hits_to_kill - 1
    if not falcon_combat.apply_nonlethal_hit(-1):
        _fail("falcon nonlethal hit should register")
        return
    if falcon_combat.state == ArenaCombatController.State.DEFEATED:
        _fail("falcon damage must never defeat a fighter")
        return

    var pickups_node := arena.get_node("Pickups")
    var pickups := pickups_node.get_child_count()
    if pickups != 16:
        _fail("expected 16 weapon pickups, got %d" % pickups)
        return

    for i in range(16):
        var pickup = pickups_node.get_child(i)
        var expected_team := 0 if i < 8 else 1
        if int(pickup.team_owner) != expected_team:
            _fail("pickup %d has wrong team owner" % i)
            return

    var life := ArenaLifeSystem.new()
    life.on_death(100.0)
    if life.lives != 1 or life.final_life:
        _fail("first death must leave one starting life")
        return

    life.on_death(100.0)
    if life.lives != 0 or not life.final_life:
        _fail("second starting death must enter final-life state")
        return
    if life.eliminated_until != 280.0:
        _fail("full elimination must be 180 seconds")
        return

    if not life.ready_for_final_life(280.0):
        _fail("final life should become available after 180 seconds")
        return

    life.consume_final_life()
    if life.eliminated_until != 0.0:
        _fail("final-life timer was not cleared")
        return

    var final_player = arena.players[0]
    final_player.life.final_life = true
    final_player.receive_attack(4, 1, bow, bow.knockback, 1)
    if not final_player.dead:
        _fail("Final Life must be defeated by one valid hit")
        return

    print("ARENA SMOKE TEST PASSED")
    arena.queue_free()
    quit(0)
