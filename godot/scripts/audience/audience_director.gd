extends Node
class_name ArenaAudienceDirector

signal vote_opened(options: Array[ArenaAudienceEvent], closes_in: int)
signal vote_closed(winner: ArenaAudienceEvent)
signal event_started(event: ArenaAudienceEvent)
signal event_finished(event: ArenaAudienceEvent)

const FIRST_VOTE_AT := 300.0
const FINAL_VOTE_AT := 540.0
const ROUND_LIMIT := 600.0
const VOTE_DURATION := 30.0

var options: Array[ArenaAudienceEvent] = []
var active_event: ArenaAudienceEvent
var round_clock := 0.0
var vote_clock := 0.0
var vote_open := false
var final_vote_done := false
var first_vote_done := false

func _ready() -> void:
    options = [
        ArenaAudienceEvent.build(ArenaAudienceEvent.Kind.DARKNESS),
        ArenaAudienceEvent.build(ArenaAudienceEvent.Kind.MONSTER_ASSAULT),
        ArenaAudienceEvent.build(ArenaAudienceEvent.Kind.RAIN),
        ArenaAudienceEvent.build(ArenaAudienceEvent.Kind.WEAPON_SWAP),
        ArenaAudienceEvent.build(ArenaAudienceEvent.Kind.FALCON_DIVE),
        ArenaAudienceEvent.build(ArenaAudienceEvent.Kind.METEOR)
    ]

func start_round() -> void:
    round_clock = 0.0
    vote_clock = 0.0
    vote_open = false
    first_vote_done = false
    final_vote_done = false
    active_event = null

func _process(delta: float) -> void:
    round_clock += delta
    if active_event != null:
        vote_clock = maxf(0.0, vote_clock - delta)
        if vote_clock <= 0.0:
            var finished := active_event
            active_event = null
            event_finished.emit(finished)
    if vote_open:
        vote_clock = maxf(0.0, vote_clock - delta)
        if vote_clock <= 0.0:
            close_vote(0)
        return
    if not first_vote_done and round_clock >= FIRST_VOTE_AT:
        _open_vote(false)
    elif not final_vote_done and round_clock >= FINAL_VOTE_AT:
        _open_vote(true)

func submit_vote(option_index: int) -> void:
    if not vote_open or option_index < 0 or option_index >= options.size():
        return
    close_vote(option_index)

func close_vote(option_index: int) -> void:
    if not vote_open:
        return
    vote_open = false
    var winner := options[clampi(option_index, 0, options.size() - 1)]
    if round_clock < FINAL_VOTE_AT:
        first_vote_done = true
    else:
        final_vote_done = true
    vote_closed.emit(winner)
    _start_event(winner)

func _open_vote(is_final: bool) -> void:
    vote_open = true
    vote_clock = VOTE_DURATION
    if is_final:
        final_vote_done = true
    else:
        first_vote_done = true
    vote_opened.emit(options, int(VOTE_DURATION))

func _start_event(event: ArenaAudienceEvent) -> void:
    active_event = event
    vote_clock = event.duration_seconds
    event_started.emit(event)

func get_round_seconds() -> int:
    return max(0, int(ROUND_LIMIT - round_clock))

func get_vote_seconds() -> int:
    return max(0, int(ceil(vote_clock)))
