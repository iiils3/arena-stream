extends Node3D
class_name Arena3DVerticalSlice

const PLAYER_COLORS := [
    Color("#c79a55"),
    Color("#4d7894"),
    Color("#9a4f49"),
    Color("#7b6b9a")
]
const PLAYER_NAMES := ["VANGUARD", "WARDEN", "SPEAR", "RAIDER"]
const ENEMY_COLOR := Color("#5b626b")

var players: Array[Node3D] = []
var enemies: Array[Node3D] = []
var elapsed := 0.0
var camera: Camera3D
var status_label: Label
var progress_label: Label
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 4217
    _build_camera()
    _build_world()
    _build_team()
    _build_enemy_army(12)
    _build_ui()

func _process(delta: float) -> void:
    elapsed += delta
    _animate_fighters(delta)
    _update_camera()
    _update_ui()

func _build_world() -> void:
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#101722")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#8090a8")
    env.ambient_light_energy = 0.65
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.environment = env
    add_child(environment)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    add_child(sun)

    var moon_fill := DirectionalLight3D.new()
    moon_fill.rotation_degrees = Vector3(-25, 145, 0)
    moon_fill.light_color = Color("#7890b5")
    moon_fill.light_energy = 0.22
    add_child(moon_fill)

    _make_ground()
    _make_fortress()
    _make_props()

func _make_ground() -> void:
    var ground := StaticBody3D.new()
    ground.name = "Battlefield"
    add_child(ground)

    var mesh := BoxMesh.new()
    mesh.size = Vector3(42, 0.4, 34)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#51473d")
    mat.roughness = 0.95
    mesh.material = mat

    var floor := MeshInstance3D.new()
    floor.mesh = mesh
    floor.position = Vector3(0, -0.2, 0)
    ground.add_child(floor)

    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = mesh.size
    collider.shape = shape
    collider.position = floor.position
    ground.add_child(collider)

    for i in range(36):
        var stone := MeshInstance3D.new()
        var sm := BoxMesh.new()
        sm.size = Vector3(rng.randf_range(0.18, 0.55), 0.08, rng.randf_range(0.18, 0.45))
        sm.material = _mat(Color("#62564a"))
        stone.mesh = sm
        stone.position = Vector3(rng.randf_range(-19, 19), 0.05, rng.randf_range(-13, 13))
        stone.rotation.y = rng.randf_range(0, TAU)
        add_child(stone)

func _make_fortress() -> void:
    _box("BackWall", Vector3(30, 7, 1.2), Vector3(0, 3.5, -13), Color("#3c424a"))

    for side in [-1.0, 1.0]:
        var tower_x := side * 11.5
        _box("Tower", Vector3(4.2, 10, 4.2), Vector3(tower_x, 5, -12.2), Color("#454b54"))
        for row in range(3):
            _box("TowerStone", Vector3(4.5, 0.18, 4.5), Vector3(tower_x, 2.0 + row * 2.7, -10.0), Color("#59606a"))
        for b in range(4):
            _box("Battlement", Vector3(0.7, 0.8, 0.9), Vector3(tower_x - 1.6 + b * 1.05, 10.4, -12.0), Color("#59606a"))

    _box("GateHouse", Vector3(10, 7.5, 2.6), Vector3(0, 3.75, -11.8), Color("#343a43"))
    _box("GateOpening", Vector3(5.0, 5.4, 2.8), Vector3(0, 2.5, -10.3), Color("#11151a"))
    _box("GateTimber", Vector3(5.2, 0.35, 0.35), Vector3(0, 5.3, -9.8), Color("#6d5845"))

    for x in [-2.0, -1.0, 0.0, 1.0, 2.0]:
        _box("Portcullis", Vector3(0.18, 4.8, 0.22), Vector3(x, 2.6, -9.0), Color("#77746e"))

    for x in [-7.0, 7.0]:
        _make_banner(Vector3(x, 6.8, -10.7), -1.0 if x < 0 else 1.0)

func _make_banner(pos: Vector3, direction: float) -> void:
    _box("BannerPole", Vector3(0.08, 3.2, 0.08), pos + Vector3(0, -1.0, 0), Color("#8a744f"))
    var flag := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(2.2, 1.3, 0.05)
    mesh.material = _mat(Color("#762d3a"))
    flag.mesh = mesh
    flag.position = pos + Vector3(0.95 * direction, -0.55, 0)
    flag.scale.x = direction
    add_child(flag)

func _make_props() -> void:
    for x in [-9.0, 9.0]:
        _make_brazier(Vector3(x, 0, -6.0))
        _make_barricade(Vector3(x * 0.65, 0, 2.5), -x * 0.04)

func _make_brazier(pos: Vector3) -> void:
    _cylinder("BrazierPost", 0.14, 1.4, pos + Vector3(0, 0.7, 0), Color("#302722"))
    _cylinder("BrazierBowl", 0.55, 0.25, pos + Vector3(0, 1.45, 0), Color("#24201e"))
    var light := OmniLight3D.new()
    light.position = pos + Vector3(0, 1.65, 0)
    light.light_color = Color("#e6a15b")
    light.light_energy = 3.5
    light.omni_range = 7.0
    add_child(light)
    var flame := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.22
    sphere.height = 0.5
    sphere.material = _mat(Color("#eaa04d"))
    flame.mesh = sphere
    flame.position = pos + Vector3(0, 1.7, 0)
    flame.name = "Flame"
    add_child(flame)

func _make_barricade(pos: Vector3, angle: float) -> void:
    for i in range(3):
        var p := pos + Vector3((i - 1) * 1.0, 0.9, 0)
        _box("BarricadePost", Vector3(0.16, 1.8, 0.16), p, Color("#604733"))
    _box("BarricadeBeam", Vector3(3.2, 0.22, 0.22), pos + Vector3(0, 1.25, 0), Color("#75543c")).rotation.y = angle

func _build_team() -> void:
    var positions := [
        Vector3(-2.7, 0, 2.6),
        Vector3(-0.9, 0, 3.3),
        Vector3(0.9, 0, 3.3),
        Vector3(2.7, 0, 2.6)
    ]
    for i in range(4):
        var fighter := _make_fighter(PLAYER_NAMES[i], PLAYER_COLORS[i], positions[i], true, i)
        players.append(fighter)

func _build_enemy_army(count: int) -> void:
    for i in range(count):
        var row := i / 6
        var col := i % 6
        var x := (col - 2.5) * 1.75
        var z := -4.0 - row * 1.65
        var fighter := _make_fighter("GUARD %02d" % (i + 1), ENEMY_COLOR, Vector3(x, 0, z), false, i)
        enemies.append(fighter)

func _make_fighter(label_text: String, armor: Color, pos: Vector3, is_player: bool, variant: int) -> Node3D:
    var root := Node3D.new()
    root.name = label_text.replace(" ", "_")
    root.position = pos
    add_child(root)

    var torso := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.42
    capsule.height = 1.25
    capsule.material = _mat(armor, 0.72)
    torso.mesh = capsule
    torso.position.y = 1.25
    root.add_child(torso)

    var chest := MeshInstance3D.new()
    var chest_mesh := BoxMesh.new()
    chest_mesh.size = Vector3(0.95, 0.7, 0.5)
    chest_mesh.material = _mat(armor.darkened(0.18), 0.82)
    chest.mesh = chest_mesh
    chest.position = Vector3(0, 1.4, 0)
    root.add_child(chest)

    var head := MeshInstance3D.new()
    var helmet := SphereMesh.new()
    helmet.radius = 0.34
    helmet.height = 0.68
    helmet.material = _mat(Color("#252a31"))
    head.mesh = helmet
    head.position = Vector3(0, 2.18, 0)
    root.add_child(head)

    var visor := MeshInstance3D.new()
    var visor_mesh := BoxMesh.new()
    visor_mesh.size = Vector3(0.46, 0.12, 0.12)
    visor_mesh.material = _mat(Color("#111418"))
    visor.mesh = visor_mesh
    visor.position = Vector3(0, 2.17, -0.29)
    root.add_child(visor)

    for side in [-1.0, 1.0]:
        var shoulder := MeshInstance3D.new()
        var shoulder_mesh := SphereMesh.new()
        shoulder_mesh.radius = 0.27
        shoulder_mesh.height = 0.5
        shoulder_mesh.material = _mat(armor)
        shoulder.mesh = shoulder_mesh
        shoulder.position = Vector3(side * 0.55, 1.55, 0)
        root.add_child(shoulder)

    var weapon := MeshInstance3D.new()
    var blade := BoxMesh.new()
    var is_spear := is_player and variant == 2
    var is_greatsword := is_player and variant == 3
    blade.size = Vector3(0.09 if not is_spear else 0.07, 1.8 if not is_spear else 2.7, 0.16)
    blade.material = _mat(Color("#c8c5bd"), 0.35, 0.8)
    weapon.mesh = blade
    weapon.position = Vector3(0.72, 1.15, -0.18)
    weapon.rotation_degrees = Vector3(0, 0, -18 if not is_spear else -6)
    if is_greatsword:
        blade.size = Vector3(0.12, 2.25, 0.2)
    root.add_child(weapon)

    var grip := MeshInstance3D.new()
    var grip_mesh := CylinderMesh.new()
    grip_mesh.top_radius = 0.055
    grip_mesh.bottom_radius = 0.055
    grip_mesh.height = 0.7
    grip_mesh.material = _mat(Color("#4b3426"))
    grip.mesh = grip_mesh
    grip.position = Vector3(0.68, 0.72, -0.18)
    root.add_child(grip)

    if is_player:
        var plate := MeshInstance3D.new()
        var plate_mesh := BoxMesh.new()
        plate_mesh.size = Vector3(1.05, 0.16, 0.58)
        plate_mesh.material = _mat(armor.lightened(0.12), 0.5)
        plate.mesh = plate_mesh
        plate.position = Vector3(0, 1.65, -0.03)
        root.add_child(plate)

    var tag := Label3D.new()
    tag.text = label_text
    tag.font_size = 22 if is_player else 15
    tag.outline_size = 8
    tag.modulate = Color("#f2dfb6") if is_player else Color("#aab1ba")
    tag.position = Vector3(0, 2.85, 0)
    tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    root.add_child(tag)

    root.set_meta("player", is_player)
    root.set_meta("variant", variant)
    root.set_meta("weapon", weapon)
    return root

func _build_camera() -> void:
    camera = Camera3D.new()
    camera.name = "BattleCamera"
    add_child(camera)
    camera.current = true
    camera.fov = 58.0
    camera.near = 0.05
    camera.far = 200.0
    camera.position = Vector3(0, 12.5, 19.5)
    camera.look_at(Vector3(0, 1.1, -1.0), Vector3.UP)

func _update_camera() -> void:
    if camera == null:
        return
    var team_center := Vector3.ZERO
    for p in players:
        team_center += p.position
    team_center /= max(1, players.size())
    var target := team_center + Vector3(0, 0.0, -1.0)
    camera.look_at(target, Vector3.UP)

func _animate_fighters(_delta: float) -> void:
    for i in range(players.size()):
        var p := players[i]
        var phase := elapsed * 2.1 + i * 0.9
        p.position.y = abs(sin(phase)) * 0.025
        p.rotation.y = sin(elapsed * 0.65 + i) * 0.06
        var weapon := p.get_meta("weapon") as Node3D
        if weapon:
            var swing := sin(elapsed * 3.0 + i * 1.7)
            weapon.rotation.z = deg_to_rad(-18.0 + swing * 16.0)
    for i in range(enemies.size()):
        var e := enemies[i]
        var phase := elapsed * 1.6 + i * 0.47
        e.position.y = abs(sin(phase)) * 0.02
        var dir := (Vector3.ZERO - e.position).normalized()
        if e.position.distance_to(Vector3.ZERO) > 5.2:
            e.position += dir * 0.22 * _delta
        e.rotation.y = lerp_angle(e.rotation.y, atan2(-e.position.x, -e.position.z), 0.04)

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    layer.name = "HUD"
    add_child(layer)

    var title := Label.new()
    title.position = Vector2(42, 30)
    title.text = "THE ASHEN GATE  •  NIGHT BATTLE"
    title.add_theme_font_size_override("font_size", 30)
    title.add_theme_color_override("font_color", Color("#eee7da"))
    layer.add_child(title)

    progress_label = Label.new()
    progress_label.position = Vector2(44, 76)
    progress_label.add_theme_font_size_override("font_size", 18)
    progress_label.add_theme_color_override("font_color", Color("#c8a46c"))
    layer.add_child(progress_label)

    status_label = Label.new()
    status_label.position = Vector2(1450, 36)
    status_label.size = Vector2(420, 170)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", Color("#e0d9cd"))
    layer.add_child(status_label)

    var note := Label.new()
    note.position = Vector2(44, 1000)
    note.text = "4 PLAYERS  •  AI ARMY  •  LIVE SPECTATOR CAMERA"
    note.add_theme_font_size_override("font_size", 16)
    note.add_theme_color_override("font_color", Color("#aeb5bd"))
    layer.add_child(note)

func _update_ui() -> void:
    var elapsed_seconds := int(elapsed) % 600
    var remaining := 600 - elapsed_seconds
    var mins := remaining / 60
    var secs := remaining % 60
    progress_label.text = "STAGE 01    •    4 HUMAN PLAYERS    •    ENEMY ARMY 12    •    %02d:%02d" % [mins, secs]
    status_label.text = "VANGUARD\nWARDEN\nSPEAR\nRAIDER\n\nVIEW: TEAM BATTLE"

func _box(node_name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = node_name
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = _mat(color)
    node.mesh = mesh
    node.position = pos
    add_child(node)
    return node

func _cylinder(node_name: String, radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = node_name
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.material = _mat(color)
    node.mesh = mesh
    node.position = pos
    add_child(node)
    return node

func _mat(color: Color, roughness: float = 0.82, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material
