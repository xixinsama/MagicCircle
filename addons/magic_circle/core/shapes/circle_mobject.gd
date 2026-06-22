@tool
class_name CircleMobject
extends MagicMobject

var radius: float = 50.0:
    set(v):
        radius = v
        mark_dirty()

func _init(p_radius: float = 50.0) -> void:
    radius = p_radius
    # Default stroke
    stroke_color = Color.WHITE
    stroke_width = 2.0

func _build_shape() -> PackedVector2Array:
    var pts = PackedVector2Array()
    var n = 64
    for i in range(n):
        var a = TAU * float(i) / float(n)
        pts.append(Vector2(cos(a), sin(a)) * radius)
    return pts
