extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("AUDIENCE SMOKE TEST FAILED: " + message)
    quit(1)

func _run() -> void:
    var director := ArenaAudienceDirector.new()
    root.add_child(director)
    await process_frame

    director.start_round()
    director.round_clock = 300.0
    director._process(0.01)

    if not director.vote_open:
        _fail("first audience vote must open at five minutes")
        return

    if not director.cast_vote("viewer-a", 0):
        _fail("first viewer vote must be accepted")
        return
    if not director.cast_vote("viewer-b", 1):
        _fail("second viewer vote must be accepted")
        return
    if not director.cast_vote("viewer-c", 1):
        _fail("third viewer vote must be accepted")
        return

    if not director.cast_vote("viewer-a", 1):
        _fail("viewer must be able to change an existing vote")
        return

    var counts := director.get_vote_counts()
    if counts[0] != 0 or counts[1] != 3:
        _fail("vote aggregation must replace a changed vote instead of double-counting")
        return

    director.close_vote()
    if director.active_event == null or director.active_event.kind != ArenaAudienceEvent.Kind.MONSTER_ASSAULT:
        _fail("highest vote count must determine the selected audience event")
        return

    director.event_clock = 0.0
    director._process(0.01)
    if director.active_event != null:
        _fail("audience event must finish when its timer expires")
        return

    director.round_clock = 540.0
    director._process(0.01)
    if not director.vote_open:
        _fail("final audience vote must open at nine minutes")
        return

    print("AUDIENCE VOTE SMOKE TEST PASSED")
    quit(0)
