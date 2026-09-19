extends Node
class_name ArenaAudienceDirector

signal vote_opened(options: Array[ArenaAudienceEvent>, closes_in: int)
signal vote_updated(counts: Array[int])
signal vote_closed(winner: ArenaAudienceEvent)
signal event_started(event: ArenaAudienceEvent)
signal event_finished(event: ArenaAudienceEvent)

const FIRST_VOTE_AT := 300.0
const FINAL_VOTE_AT := 540.0
const ROUND_LIMIT := 600.0
const VOTE_DURATION := 30.0

var options: Array[ArenaAudienceEvent] = []
var vote_counts: Array[int] = []
var voter_choices: Dictionary = {}
var active_event: ArenaAudienceEvent
var round_clock := 0.0
var vote_clock := 0.0
var event_clock := 0.0
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
    vote_counts.resize(options.size())
    vote_counts.fill(0)

func start_round() -> void:
    round_clock = 0.0
    vote_clock = 0.0
    event_clock = 0.0
    vote_open = false
    first_vote_done = false
    final_vote_done = false
    active_event = null
    voter_choices.clear()
    vote_counts.fill(0)

func _process(delta: float) -> void:
    round_clock += delta

    if active_event != null:
        event_clock = maxf(0.0, event_clock - delta)
        if event_clock <= 0.0:
            var finished := active_event
            active_event = null
            event_finished.emit(finished)

    if vote_open:
        vote_clock = maxf(0.0, vote_clock - delta)
        if vote_clock <= 0.0:
            close_vote()
        return

    if not first_vote_done and round_clock >= FIRST_VOTE_AT:
        _open_vote(false)
    elif not final_vote_done and round_clock >= FINAL_VOTE_AT:
        _open_vote(true)

func cast_vote(voter_id: String, option_index: int) -> bool:
    if not vote_open or voter_id.strip_edges().is_empty():
        return false
    if option_index < 0 or option_index >= options.size():
        return false

    var id := voter_id.strip_edges()
    if voter_choices.has(id):
        var previous: int = voter_choices[id]
        if previous == option_index:
            return true
        vote_counts[previous] = maxi(0, vote_counts[previous] - 1)

    voter_choices[id] = option_index
    vote_counts[option_index] += 1
    vote_updated.emit(vote_counts.duplicate())
    return true

func submit_vote(option_index: int) -> void:
    cast_vote("local", option_index)

func close_vote() -> void:
    if not vote_open:
        return

    vote_open = false
    var winner_index := _winning_option_index()
    if round_clock < FINAL_VOTE_AT:
        first_vote_done = true
    else:
        final_vote_done = true

    var winner := options[winner_index]
    vote_closed.emit(winner)
    _start_event(winner)

func _winning_option_index() -> int:
    var winner_index := 0
    var winner_count := -1
    for index in vote_counts.size():
        if vote_counts[index] > winner_count:
            winner_count = vote_counts[index]
            winner_index = index
    return winner_index

func _open_vote(is_final: bool) -> void:
    vote_open = true
    vote_clock = VOTE_DURATION
    vote_counts.fill(0)
    voter_choices.clear()
    if is_final:
        final_vote_done = true
    else:
        first_vote_done = true
    vote_opened.emit(options, int(VOTE_DURATION))
    vote_updated.emit(vote_counts.duplicate())

func _start_event(event: ArenaAudienceEvent) -> void:
    active_event = event
    event_clock = event.duration_seconds
    event_started.emit(event)

func get_round_seconds() -> int:
    return max(0, int(ROUND_LIMIT - round_clock))

func get_vote_seconds() -> int:
    return max(0, int(ceil(vote_clock)))

func get_event_seconds() -> int:
    return max(0, int(ceil(event_clock)))

func get_vote_counts() -> Array[int]:
    return vote_counts.duplicate()
