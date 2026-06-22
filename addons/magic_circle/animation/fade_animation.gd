class_name FadeInAnimation
extends MagicAnimation

## Fades the mobject from invisible to its current modulate alpha.

func interpolate_submobject(index: int, alpha: float) -> void:
    if index >= _family.size():
        return
    var mob = _family[index]
    var start = _start_snapshots[index]
    var target_alpha = start.modulate.a

    mob.modulate = start.modulate
    mob.modulate.a = lerp(0.0, target_alpha, alpha)
    mob.self_modulate = start.self_modulate
    mob.self_modulate.a = lerp(0.0, start.self_modulate.a, alpha)

    # Also fade fill/stroke opacity
    mob.fill_opacity = lerp(0.0, float(start.fill_opacity), alpha)
    mob.stroke_opacity = lerp(0.0, float(start.stroke_opacity), alpha)


class_name FadeOutAnimation
extends MagicAnimation

## Fades the mobject from its current modulate alpha to invisible.

func interpolate_submobject(index: int, alpha: float) -> void:
    if index >= _family.size():
        return
    var mob = _family[index]
    var start = _start_snapshots[index]
    var start_alpha = start.modulate.a

    mob.modulate = start.modulate
    mob.modulate.a = lerp(start_alpha, 0.0, alpha)
    mob.self_modulate = start.self_modulate
    mob.self_modulate.a = lerp(start.self_modulate.a, 0.0, alpha)

    mob.fill_opacity = lerp(float(start.fill_opacity), 0.0, alpha)
    mob.stroke_opacity = lerp(float(start.stroke_opacity), 0.0, alpha)
