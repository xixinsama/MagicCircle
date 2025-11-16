extends Node2D

## ShapeDrawer 完整功能演示
## 展示所有形状类型和动画效果

var current_demo: int = 0
var demo_names: Array[String] = []

func _ready():
	# 等待ShapeDrawer就绪
	await get_tree().process_frame
	
	# 注册所有演示
	demo_names = [
		"1. 所有形状类型展示",
		"2. 缓动函数对比",
		"3. 行星轨道系统",
		"4. 魔法阵（增强版）",
		"5. 粒子爆发效果",
		"6. 波纹扩散",
		"7. 螺旋星系",
		"8. 自定义形状",
		"9. 复杂动画链",
		"0. 终极演示"
	]
	
	print("==================================================")
	print("ShapeDrawer 完整功能演示")
	print("==================================================")
	print("按数字键 1-9,0 切换演示")
	print("按 C 清除所有")
	print("按 SPACE 重播当前")
	print("按 D 显示调试信息")
	print("鼠标左键 创建随机形状")
	print("鼠标右键 在点击位置爆发粒子")
	print("==================================================")
	
	play_demo(0)

func _input(event):
	if event is InputEventKey and event.pressed:
		# 数字键切换
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			var index = event.keycode - KEY_1
			if index < 0:
				index = 9  # 0键
			if index < demo_names.size():
				play_demo(index)
		
		# 控制键
		elif event.keycode == KEY_C:
			ShapeDrawer.clear_all()
			print("已清除")
		
		elif event.keycode == KEY_SPACE:
			play_demo(current_demo)
		
		elif event.keycode == KEY_D:
			ShapeDrawer.print_debug_info()
	
	# 鼠标交互
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			create_random_shape_at(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			ShapeDrawer.create_particle_burst(event.position, 20, 150.0, 1.5)

func play_demo(index: int):
	ShapeDrawer.clear_all()
	current_demo = index
	print("\n▶ 播放: %s" % demo_names[index])
	
	match index:
		0: demo_all_shapes()
		1: demo_easing_functions()
		2: demo_planet_system()
		3: demo_magic_circle_enhanced()
		4: demo_particle_burst()
		5: demo_ripples()
		6: demo_spiral_galaxy()
		7: demo_custom_shapes()
		8: demo_complex_animations()
		9: demo_ultimate()

func get_center() -> Vector2:
	return get_viewport_rect().size / 2

# ========== 演示 1: 所有形状类型 ==========
func demo_all_shapes():
	var center = get_center()
	var shape_types = [
		["三角形", ShapeInstance.ShapeType.TRIANGLE],
		["正方形", ShapeInstance.ShapeType.SQUARE],
		["五边形", ShapeInstance.ShapeType.PENTAGON],
		["六边形", ShapeInstance.ShapeType.HEXAGON],
		["七边形", ShapeInstance.ShapeType.HEPTAGON],
		["八边形", ShapeInstance.ShapeType.OCTAGON],
		["圆形", ShapeInstance.ShapeType.CIRCLE],
		["五角星", ShapeInstance.ShapeType.STAR],
		["六角星", ShapeInstance.ShapeType.STAR_6],
		["八角星", ShapeInstance.ShapeType.STAR_8],
		["菱形", ShapeInstance.ShapeType.DIAMOND],
		["平行四边形", ShapeInstance.ShapeType.RHOMBUS],
		["椭圆", ShapeInstance.ShapeType.ELLIPSE],
		["胶囊", ShapeInstance.ShapeType.CAPSULE],
		["圆角矩形", ShapeInstance.ShapeType.ROUNDED_RECT],
		["十字", ShapeInstance.ShapeType.CROSS],
		["箭头", ShapeInstance.ShapeType.ARROW],
		["心形", ShapeInstance.ShapeType.HEART],
		["月牙", ShapeInstance.ShapeType.CRESCENT],
		["环形", ShapeInstance.ShapeType.RING]
	]
	
	var total = shape_types.size()
	var radius = 280.0
	
	for i in range(total):
		var angle = (TAU / total) * i - PI / 2
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		var color = Color.from_hsv(float(i) / total, 0.8, 1.0)
		
		var shape = ShapeDrawer.create_shape(pos, shape_types[i][1], 35.0, color)
		shape.rotate_by(TAU, 3.0).set_loops(-1)
		shape.scale_to(45.0, 1.0).scale_to(35.0, 1.0).set_loops(-1).set_parallel()

# ========== 演示 2: 缓动函数对比 ==========
func demo_easing_functions():
	var center = get_center()
	var ease_types = [
		["LINEAR", ShapeInstance.EaseType.LINEAR],
		["EASE_IN", ShapeInstance.EaseType.EASE_IN],
		["EASE_OUT", ShapeInstance.EaseType.EASE_OUT],
		["EASE_IN_OUT", ShapeInstance.EaseType.EASE_IN_OUT],
		["BOUNCE_OUT", ShapeInstance.EaseType.BOUNCE_OUT],
		["ELASTIC_OUT", ShapeInstance.EaseType.ELASTIC_OUT],
		["BACK_OUT", ShapeInstance.EaseType.BACK_OUT]
	]
	
	var spacing = 80.0
	var start_y = center.y - (ease_types.size() - 1) * spacing / 2
	
	for i in range(ease_types.size()):
		var start_pos = Vector2(100, start_y + i * spacing)
		var end_pos = Vector2(get_viewport_rect().size.x - 100, start_y + i * spacing)
		
		var shape = ShapeDrawer.create_shape(start_pos, ShapeInstance.ShapeType.CIRCLE, 25.0, 
			Color.from_hsv(float(i) / ease_types.size(), 1.0, 1.0))
		
		shape.move_to(end_pos, 2.0, ease_types[i][1])\
			.move_to(start_pos, 2.0, ease_types[i][1])\
			.set_loops(-1)

# ========== 演示 3: 行星系统 ==========
func demo_planet_system():
	var center = get_center()
	ShapeDrawer.create_planet_system(center, 5, 100.0, 50.0)
	
	# 添加一些小行星带
	for i in range(30):
		var angle = randf() * TAU
		var radius = randf_range(250, 300)
		var asteroid = ShapeDrawer.create_orbiting_shape(
			center, radius, ShapeInstance.ShapeType.DIAMOND, 
			randf_range(3, 8), Color.GRAY, randf_range(0.3, 0.7)
		)
		asteroid.fade_to(0.3, 1.0).fade_to(0.8, 1.0).set_loops(-1).set_parallel()

# ========== 演示 4: 增强魔法阵 ==========
func demo_magic_circle_enhanced():
	var center = get_center()
	
	# 主魔法阵
	ShapeDrawer.create_magic_circle(center, 250.0, 4, 3)
	
	# 外圈快速旋转符文
	for i in range(16):
		var angle = (TAU / 16) * i
		var pos = center + Vector2(cos(angle), sin(angle)) * 320
		var rune = ShapeDrawer.create_shape(pos, ShapeInstance.ShapeType.CROSS, 18.0, Color.PURPLE)
		rune.rotate_by(TAU * 3, 1.5).set_loops(-1)
		rune.fade_to(0.2, 0.7).fade_to(1.0, 0.7).set_loops(-1).set_parallel()
	
	# 内圈旋转椭圆
	for i in range(6):
		var shape = ShapeDrawer.create_orbiting_shape(
			center, 60.0, ShapeInstance.ShapeType.ELLIPSE,
			25.0, Color.CYAN, 2.0
		)
		shape.rotate_by(TAU, 1.0).set_loops(-1).set_parallel()

# ========== 演示 5: 粒子爆发 ==========
func demo_particle_burst():
	var center = get_center()
	
	# 多次爆发
	for i in range(5):
		await get_tree().create_timer(i * 0.8).timeout
		var colors = [Color.RED, Color.YELLOW, Color.CYAN, Color.MAGENTA, Color.GREEN]
		ShapeDrawer.create_particle_burst(center, 24, 200.0 + i * 30, 2.0, colors)

# ========== 演示 6: 波纹效果 ==========
func demo_ripples():
	var center = get_center()
	
	# 持续波纹
	for i in range(10):
		await get_tree().create_timer(0.4).timeout
		ShapeDrawer.create_ripple(center, 350.0, 1, 2.5, Color.CYAN)

# ========== 演示 7: 螺旋星系 ==========
func demo_spiral_galaxy():
	var center = get_center()
	ShapeDrawer.create_spiral_galaxy(center, 4, 25, 300.0)
	
	# 中心黑洞效果
	var black_hole = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 40.0, Color.BLACK)
	black_hole.scale_to(50.0, 1.0).scale_to(40.0, 1.0).set_loops(-1)

# ========== 演示 8: 自定义形状 ==========
func demo_custom_shapes():
	var center = get_center()
	
	# 自定义三角波形
	var wave_vertices = PackedVector2Array()
	for i in range(20):
		var x = (i - 10) * 15.0
		var y = sin(float(i) * 0.5) * 30.0
		wave_vertices.append(Vector2(x, y))
	
	var wave = ShapeDrawer.create_custom_shape(center, wave_vertices, Color.AQUA)
	wave.rotate_by(TAU, 4.0).set_loops(-1)
	wave.scale_y_to(2.0, 1.0).scale_y_to(1.0, 1.0).set_loops(-1).set_parallel()
	
	# 自定义星形
	var star_verts = PackedVector2Array([
		Vector2(0, -60), Vector2(15, -20), Vector2(60, -15),
		Vector2(20, 5), Vector2(35, 50), Vector2(0, 25),
		Vector2(-35, 50), Vector2(-20, 5), Vector2(-60, -15),
		Vector2(-15, -20)
	])
	
	var custom_star = ShapeDrawer.create_custom_shape(center + Vector2(150, 0), star_verts, Color.GOLD)
	custom_star.rotate_by(TAU, 3.0).set_loops(-1)
	
	# N边多边形动画
	for sides in range(3, 13):
		var angle = (TAU / 10) * (sides - 3)
		var pos = center + Vector2(cos(angle), sin(angle)) * 200
		var poly = ShapeDrawer.create_polygon(pos, sides, 30.0, Color.from_hsv(float(sides - 3) / 10, 1.0, 1.0))
		poly.rotate_by(TAU, 2.0 + sides * 0.1).set_loops(-1)

# ========== 演示 9: 复杂动画链 ==========
func demo_complex_animations():
	var center = get_center()
	
	# 复杂轨迹运动
	var shape = ShapeDrawer.create_shape(center + Vector2(-200, -200), ShapeInstance.ShapeType.STAR, 40.0, Color.GOLD)
	
	# 贝塞尔曲线移动
	shape.move_bezier(
		center + Vector2(200, -200),
		center + Vector2(200, 200),
		center + Vector2(-200, 200),
		2.0
	)
	
	# 颜色渐变
	shape.color_to(Color.RED, 0.5)\
		.color_to(Color.BLUE, 0.5)\
		.color_to(Color.GREEN, 0.5)\
		.color_to(Color.GOLD, 0.5)\
		.set_parallel()
	
	# 旋转和缩放
	shape.rotate_by(TAU * 2, 2.0).set_parallel()
	shape.scale_to(60.0, 1.0).scale_to(40.0, 1.0).set_parallel()
	
	shape.set_loops(-1)
	
	# 多个形状的同步动画
	for i in range(8):
		var angle = (TAU / 8) * i
		var follower = ShapeDrawer.create_shape(
			center + Vector2(cos(angle), sin(angle)) * 100,
			ShapeInstance.ShapeType.HEXAGON,
			20.0,
			Color.from_hsv(float(i) / 8, 1.0, 1.0)
		)
		
		follower.orbit_around(center, 100.0, 2.0).set_loops(-1)
		follower.rotate_by(TAU, 1.0).set_loops(-1).set_parallel()

# ========== 演示 0: 终极演示 ==========
func demo_ultimate():
	var center = get_center()
	
	# 背景魔法阵
	ShapeDrawer.create_magic_circle(center, 300.0, 3, 2)
	
	# 行星系统
	ShapeDrawer.create_planet_system(center, 3, 150.0, 40.0)
	
	# 螺旋粒子
	for arm in range(3):
		var offset = (TAU / 3) * arm
		for i in range(15):
			var t = float(i) / 15
			var angle = t * TAU * 2 + offset
			var radius = t * 200
			var pos = center + Vector2(cos(angle), sin(angle)) * radius
			
			var particle = ShapeDrawer.create_shape(pos, ShapeInstance.ShapeType.STAR, 10.0, 
				Color.from_hsv(t, 1.0, 1.0))
			particle.fade_to(0.3, 1.0).fade_to(1.0, 1.0).set_loops(-1)
			particle.rotate_by(TAU, 2.0).set_loops(-1).set_parallel()
	
	# 持续波纹
	for i in range(20):
		await get_tree().create_timer(0.5).timeout
		if current_demo != 9:  # 切换演示时停止
			break
		var ripple = ShapeDrawer.create_shape(center, ShapeInstance.ShapeType.CIRCLE, 10.0, 
			Color(1, 1, 1, 0.5))
		ripple.scale_to(400.0, 3.0, ShapeInstance.EaseType.EASE_OUT)
		ripple.fade_to(0.0, 3.0).set_parallel()

# ========== 辅助函数 ==========
func create_random_shape_at(pos: Vector2):
	var types = [
		ShapeInstance.ShapeType.TRIANGLE, ShapeInstance.ShapeType.SQUARE,
		ShapeInstance.ShapeType.PENTAGON, ShapeInstance.ShapeType.HEXAGON,
		ShapeInstance.ShapeType.STAR, ShapeInstance.ShapeType.CIRCLE,
		ShapeInstance.ShapeType.DIAMOND, ShapeInstance.ShapeType.HEART
	]
	
	var shape = ShapeDrawer.create_shape(
		pos,
		types[randi() % types.size()],
		randf_range(25, 50),
		Color.from_hsv(randf(), 1.0, 1.0)
	)
	
	# 随机动画
	match randi() % 5:
		0:  # 旋转+脉动
			shape.rotate_by(TAU, 2.0).set_loops(3)
			shape.scale_to(70.0, 1.0).scale_to(30.0, 1.0).set_loops(3).set_parallel()
		1:  # 螺旋移动
			var target = pos + Vector2(randf_range(-200, 200), randf_range(-200, 200))
			shape.move_to(target, 2.0, ShapeInstance.EaseType.EASE_IN_OUT)
			shape.rotate_by(TAU * 3, 2.0).set_parallel()
		2:  # 彩虹渐变
			shape.color_to(Color.RED, 0.3).color_to(Color.YELLOW, 0.3)\
				.color_to(Color.GREEN, 0.3).color_to(Color.CYAN, 0.3)\
				.set_loops(2)
		3:  # 弹跳效果
			shape.scale_to(80.0, 0.5, ShapeInstance.EaseType.BOUNCE_OUT)\
				.scale_to(40.0, 0.5, ShapeInstance.EaseType.BOUNCE_OUT)\
				.set_loops(3)
		4:  # 弹性旋转
			shape.rotate_by(TAU, 1.0, ShapeInstance.EaseType.ELASTIC_OUT).set_loops(2)
	
	# 最后淡出消失
	shape.fade_to(0.0, 1.0).set_delay(3.0)
