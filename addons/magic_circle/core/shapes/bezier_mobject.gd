@tool
class_name BezierMobject
extends MagicMobject

var curve: Curve2D = Curve2D.new()

func _init() -> void:
    stroke_color = Color.WHITE
    stroke_width = 2.0
    curve.bake_interval = 3.0  # finer bake for smoother rendering

func add_point(pos: Vector2, in_dir: Vector2 = Vector2.ZERO, out_dir: Vector2 = Vector2.ZERO) -> void:
    curve.add_point(pos, in_dir, out_dir)
    mark_dirty()

func clear_curve() -> void:
    curve.clear_points()
    mark_dirty()

func sample_at(alpha: float) -> Vector2:
    # alpha in [0, 1], returns point along curve
    return curve.samplef(clamp(alpha, 0.0, 1.0))

func get_total_length() -> float:
    return curve.get_baked_length()

func set_point_position(index: int, pos: Vector2) -> void:
    curve.set_point_position(index, pos)
    mark_dirty()

func _build_shape() -> PackedVector2Array:
    if curve.point_count == 0:
        return PackedVector2Array()
    # Use tessellate for adaptive, or get_baked_points for uniform
    return curve.get_baked_points()
