@tool
class_name StarMobject
extends MagicMobject

var points: int = 5:
    set(v):
        points = max(2, v)
        mark_dirty()
var outer_radius: float = 50.0:
    set(v):
        outer_radius = v
        mark_dirty()
var inner_radius: float = 20.0:
    set(v):
        inner_radius = v
        mark_dirty()

func _init(p_points: int = 5, p_outer: float = 50.0, p_inner: float = 20.0) -> void:
    points = max(2, p_points)
    outer_radius = p_outer
    inner_radius = p_inner
    stroke_color = Color.WHITE
    stroke_width = 2.0

func _build_shape() -> PackedVector2Array:
    var pts = PackedVector2Array()
    var n = points * 2
    for i in range(n):
        var a = TAU * float(i) / float(n) - PI / 2.0
        var r = outer_radius if i % 2 == 0 else inner_radius
        pts.append(Vector2(cos(a), sin(a)) * r)
    return pts
