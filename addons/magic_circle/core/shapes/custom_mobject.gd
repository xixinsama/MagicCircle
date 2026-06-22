@tool
class_name CustomMobject
extends MagicMobject

var custom_vertices: PackedVector2Array = []:
    set(v):
        custom_vertices = v
        mark_dirty()

func _init(p_vertices: PackedVector2Array = []) -> void:
    custom_vertices = p_vertices
    stroke_color = Color.WHITE
    stroke_width = 2.0

func _build_shape() -> PackedVector2Array:
    return custom_vertices

func set_vertices(verts: PackedVector2Array) -> void:
    custom_vertices = verts
    mark_dirty()
