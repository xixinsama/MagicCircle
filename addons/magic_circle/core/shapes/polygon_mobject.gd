@tool
class_name PolygonMobject
extends MagicMobject

var sides: int = 5:
    set(v):
        sides = max(3, v)
        mark_dirty()
var radius: float = 50.0:
    set(v):
        radius = v
        mark_dirty()

func _init(p_sides: int = 5, p_radius: float = 50.0) -> void:
    sides = max(3, p_sides)
    radius = p_radius
    stroke_color = Color.WHITE
    stroke_width = 2.0

func _build_shape() -> PackedVector2Array:
    var pts = PackedVector2Array()
    for i in range(sides):
        var a = TAU * float(i) / float(sides) - PI / 2.0
        pts.append(Vector2(cos(a), sin(a)) * radius)
    return pts
