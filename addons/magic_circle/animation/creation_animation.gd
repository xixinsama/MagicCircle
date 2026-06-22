class_name GrowFromCenterAnimation
extends MagicAnimation

var _center: Vector2 = Vector2.ZERO

func _init(mobject: MagicMobject, center: Vector2 = Vector2.ZERO, duration: float = 1.0) -> void:
    super._init(mobject, duration)
    _center = center

func interpolate_submobject(index: int, alpha: float) -> void:
    if index >= _family.size():
        return
    var mob = _family[index]
    var start = _start_snapshots[index]

    # Scale from 0 to original
    mob.scale = start.scale * alpha

    # Position interpolates from center to original position
    mob.position = _center.lerp(start.position, alpha)

    # Fade in as it grows
    mob.modulate = start.modulate
    mob.modulate.a = lerp(0.0, start.modulate.a, alpha)


class_name ShrinkToCenterAnimation
extends MagicAnimation

var _center: Vector2 = Vector2.ZERO

func _init(mobject: MagicMobject, center: Vector2 = Vector2.ZERO, duration: float = 1.0) -> void:
    super._init(mobject, duration)
    _center = center

func interpolate_submobject(index: int, alpha: float) -> void:
    if index >= _family.size():
        return
    var mob = _family[index]
    var start = _start_snapshots[index]

    # Scale from original to 0
    mob.scale = start.scale * (1.0 - alpha)

    # Position interpolates from original to center
    mob.position = start.position.lerp(_center, alpha)

    # Fade out as it shrinks
    mob.modulate = start.modulate
    mob.modulate.a = lerp(start.modulate.a, 0.0, alpha)
