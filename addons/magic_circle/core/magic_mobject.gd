@tool
class_name MagicMobject
extends Node2D

# ═══ Visual Properties ═══
var fill_color: Color = Color.TRANSPARENT    # transparent = no fill
var fill_opacity: float = 1.0
var stroke_color: Color = Color.WHITE
var stroke_width: float = 2.0
var stroke_opacity: float = 1.0

# ═══ Shape Data (cached) ═══
var _shape_points: PackedVector2Array = []
var _shape_dirty: bool = true  # recalculate shape when true

# ═══ Updaters ═══
var _updaters: Array[Callable] = []

# ═══ Lifecycle ═══
func _ready():
	if _shape_dirty:
		_shape_points = _build_shape()
		_shape_dirty = false
	queue_redraw()

func _draw():
	# Apply the shape's own transform on top of Node2D's transform
	# Node2D's position/rotation/scale are already applied by Godot
	# We just draw the shape at local origin

	if _shape_dirty:
		_shape_points = _build_shape()
		_shape_dirty = false

	var pts = _shape_points
	if pts.size() < 3:
		return

	# Fill
	if fill_color.a > 0 and fill_opacity > 0:
		var col = fill_color
		col.a *= fill_opacity
		draw_colored_polygon(pts, col)

	# Stroke (outline)
	if stroke_width > 0 and stroke_opacity > 0 and stroke_color.a > 0:
		var col = stroke_color
		col.a *= stroke_opacity
		# Close the outline by appending first point
		var outline_pts = PackedVector2Array()
		outline_pts.append_array(pts)
		outline_pts.append(pts[0])
		draw_polyline(outline_pts, col, stroke_width, true)

# ═══ Shape Building (override in subclasses) ═══
func _build_shape() -> PackedVector2Array:
	return PackedVector2Array()

# ═══ Force shape rebuild ═══
func mark_dirty():
	_shape_dirty = true
	_shape_points = _build_shape()
	_shape_dirty = false
	queue_redraw()

# ═══ State Snapshot (for Transform animation) ═══
func snapshot() -> Dictionary:
	return {
		"position": position,
		"rotation": rotation,
		"scale": scale,
		"skew": skew,
		"modulate": modulate,
		"self_modulate": self_modulate,
		"fill_color": fill_color,
		"fill_opacity": fill_opacity,
		"stroke_color": stroke_color,
		"stroke_width": stroke_width,
		"stroke_opacity": stroke_opacity,
		"visible": visible,
		"z_index": z_index,
	}

func apply_snapshot(snap: Dictionary):
	position = snap.position
	rotation = snap.rotation
	scale = snap.scale
	skew = snap.skew
	modulate = snap.modulate
	self_modulate = snap.self_modulate
	fill_color = snap.fill_color
	fill_opacity = snap.fill_opacity
	stroke_color = snap.stroke_color
	stroke_width = snap.stroke_width
	stroke_opacity = snap.stroke_opacity
	visible = snap.visible
	z_index = snap.z_index
	queue_redraw()

# ═══ Updater System ═══
func add_updater(callback: Callable):
	if not callback in _updaters:
		_updaters.append(callback)

func remove_updater(callback: Callable):
	_updaters.erase(callback)

func clear_updaters():
	_updaters.clear()

func _process(delta: float):
	for updater in _updaters:
		updater.call(self, delta)

# ═══ Fluent Style API ═══
# These methods return self for chaining, but THEY MUTATE the mobject in place.
# When called from .animate, the PropertyAnimator records them.
# When called directly, they modify the mobject immediately.

func set_fill(color: Color, opacity: float = 1.0) -> MagicMobject:
	fill_color = color
	fill_opacity = opacity
	queue_redraw()
	return self

func set_stroke(color: Color, width: float = 2.0, opacity: float = 1.0) -> MagicMobject:
	stroke_color = color
	stroke_width = width
	stroke_opacity = opacity
	queue_redraw()
	return self

func shift(offset: Vector2) -> MagicMobject:
	position += offset
	return self

func move_to(pos: Vector2) -> MagicMobject:
	position = pos
	return self

func rotate_mob(angle: float) -> MagicMobject:
	rotation += angle
	return self

func rotate_to(angle: float) -> MagicMobject:
	rotation = angle
	return self

func scale_to_vec(s: Vector2) -> MagicMobject:
	scale = s
	return self

func scale_to_uniform(s: float) -> MagicMobject:
	scale = Vector2(s, s)
	return self

func fade_to(opacity: float) -> MagicMobject:
	modulate.a = clamp(opacity, 0.0, 1.0)
	return self

func set_z(z: int) -> MagicMobject:
	z_index = z
	return self

# ═══ .animate entry ═══
# PropertyAnimator is in a separate file, but we need to reference it here.
# We use a getter that lazy-loads the class.
var _animator: RefCounted = null

var animate:
	get:
		# Load PropertyAnimator class and create instance
		var PA = load("res://addons/magic_circle/animation/property_animator.gd")
		if PA:
			return PA.new(self)
		return null

# ═══ Debug ═══
func _to_string():
	return "MagicMobject(%s pos=%s rot=%.2f scale=%s)" % [get_class(), position, rotation, scale]
