class_name TransformAnimation
extends MagicAnimation

## Interpolates all properties from a start snapshot to a target snapshot.
## The CORE animation type. Supports morphing between two different mobjects.

var _target_snapshots: Array[Dictionary] = []

func _init(mobject: MagicMobject, target_mobject: MagicMobject = null, duration: float = 1.0) -> void:
    super._init(mobject, duration)
    if target_mobject:
        var target_family = _collect_family(target_mobject)
        for mob in target_family:
            _target_snapshots.append(mob.snapshot())

func begin() -> void:
    super.begin()
    # If no explicit target, use current state (works with .animate)
    if _target_snapshots.is_empty():
        for mob in _family:
            _target_snapshots.append(mob.snapshot())

func interpolate_submobject(index: int, alpha: float) -> void:
    if index >= _family.size() or index >= _start_snapshots.size():
        return

    var mob = _family[index]
    var start = _start_snapshots[index]

    var target: Dictionary
    if index < _target_snapshots.size():
        target = _target_snapshots[index]
    else:
        target = start

    # Interpolate each property
    mob.position = _lerp_v2(start.position, target.position, alpha)
    mob.rotation = lerp(float(start.rotation), float(target.rotation), alpha)
    mob.scale = _lerp_v2(start.scale, target.scale, alpha)
    mob.skew = lerp(float(start.skew), float(target.skew), alpha)
    mob.modulate = _lerp_color(start.modulate, target.modulate, alpha)
    mob.self_modulate = _lerp_color(start.self_modulate, target.self_modulate, alpha)
    mob.fill_color = _lerp_color(start.fill_color, target.fill_color, alpha)
    mob.fill_opacity = lerp(float(start.fill_opacity), float(target.fill_opacity), alpha)
    mob.stroke_color = _lerp_color(start.stroke_color, target.stroke_color, alpha)
    mob.stroke_width = lerp(float(start.stroke_width), float(target.stroke_width), alpha)
    mob.stroke_opacity = lerp(float(start.stroke_opacity), float(target.stroke_opacity), alpha)

    # z_index jumps at end
    if alpha >= 1.0:
        mob.z_index = int(target.z_index)
    mob.visible = target.visible if alpha > 0.5 else start.visible

func _lerp_v2(a, b: Vector2, t: float) -> Vector2:
    return a.lerp(b, t)

func _lerp_color(a: Color, b: Color, t: float) -> Color:
    return a.lerp(b, t)
