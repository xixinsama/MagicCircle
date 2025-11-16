extends Node2D

var p1: ShapeInstance
@onready var moving_node: Marker2D = $Marker2D

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		ShapeDrawer.clear_all()
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var shapes := create_system(event.position)
			for s in shapes:
				#s.set_parallel()
				s.fade_to(0.0, 2.5).set_parallel()
			
func create_system(center: Vector2) -> Array[ShapeInstance]:
	var shapes: Array[ShapeInstance] = []
	var sun = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 10, Color.YELLOW, true)
	shapes.append(sun)
	
	var orbit1 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 20)
	orbit1.set_outline_width(1)
	shapes.append(orbit1)
	var planet1 = ShapeDrawer.create_shape(center+Vector2(0, -20), ShapeInstance.ShapeType.CIRCLE, 4)
	planet1.orbit_around(center, 20, 3)
	shapes.append(planet1)
	var tri = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.TRIANGLE, 20)
	tri.set_outline_width(0.5)
	tri.self_rotate_by(PI + 0.85, 0.1)
	tri.self_rotate_during(3)
	shapes.append(tri)
	
	var orbit2 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 30)
	orbit2.set_outline_width(1)
	shapes.append(orbit2)
	var planet2 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 6)
	planet2.orbit_around(center, 30, 2)
	shapes.append(planet2)
	var squa = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.SQUARE, 30)
	squa.set_outline_width(0.5)
	squa.set_delay(0.1).self_rotate_by(PI + 0.23, 0.1)
	squa.self_rotate_during(2)
	shapes.append(squa)
	
	var orbit3 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 50)
	orbit3.set_outline_width(1)
	shapes.append(orbit3)
	var planet3 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 10)
	planet3.orbit_around(center, 50, 1)
	shapes.append(planet3)
	var tri1 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.TRIANGLE, 50)
	tri1.set_outline_width(0.5)
	tri1.set_delay(0.1).self_rotate_by(PI + 0.62, 0.1)
	tri1.self_rotate_during(1)
	shapes.append(tri1)
	var tri2 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.TRIANGLE, 50)
	tri2.set_outline_width(0.5)
	tri2.set_delay(0.1).self_rotate_by(2 * PI + 0.62, 0.1)
	tri2.self_rotate_during(1)
	shapes.append(tri2)
	
	var orbit4 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 80, Color.AQUAMARINE)
	orbit4.set_outline_width(1)
	shapes.append(orbit4)
	var orbit5 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 84, Color.SKY_BLUE)
	orbit5.set_outline_width(1)
	shapes.append(orbit5)
	var planet4 = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 16)
	planet4.orbit_around(center, 80, 4)
	shapes.append(planet4)
	var star = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.STAR, 84, Color.DEEP_SKY_BLUE)
	star.set_outline_width(2)
	star.set_delay(0.1).self_rotate_by(PI + 0.12, 0.1)
	star.self_rotate_during(4)
	shapes.append(star)
	
	return shapes
