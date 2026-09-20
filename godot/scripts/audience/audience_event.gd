extends Resource
class_name ArenaAudienceEvent

enum Kind { DARKNESS, MONSTER_ASSAULT, RAIN, WEAPON_SWAP, FALCON_DIVE, METEOR }

@export var kind: Kind
@export var display_name := ""
@export var duration_seconds := 60.0
@export var lethal := true

static func build(p_kind: Kind) -> ArenaAudienceEvent:
    var event := ArenaAudienceEvent.new()
    event.kind = p_kind
    match p_kind:
        Kind.DARKNESS:
            event.display_name = "BLACKOUT"
            event.duration_seconds = 60.0
        Kind.MONSTER_ASSAULT:
            event.display_name = "MONSTER DESCENDS"
            event.duration_seconds = 60.0
        Kind.RAIN:
            event.display_name = "STORM"
            event.duration_seconds = 120.0
        Kind.WEAPON_SWAP:
            event.display_name = "ARMS SWAP"
            event.duration_seconds = 120.0
        Kind.FALCON_DIVE:
            event.display_name = "FALCON DIVE"
            event.duration_seconds = 4.0
            event.lethal = false
        Kind.METEOR:
            event.display_name = "METEOR STRIKE"
            event.duration_seconds = 5.0
    return event
