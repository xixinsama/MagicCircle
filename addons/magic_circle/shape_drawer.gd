extends Node

## ShapeDrawer 全局单例
## 高性能形状绘制和动画系统

# ============ 配置常量 ============

const MAX_SHAPES = 65535  # 最大形状数量限制
const ENABLE_OBJECT_POOL = true  # 启用对象池优化

# ============ 核心数据 ============

var shapes: Array[ShapeInstance] = []  # 活跃的形状列表
var shape_pool: Array[ShapeInstance] = []  # 形状对象池
var canvas_layer: CanvasLayer  # 绘制层
var draw_node: Node2D  # 绘制节点

# 性能统计
var _frame_time: float = 0.0
var _update_time: float = 0.0
var _draw_time: float = 0.0

# 绘制优化
var _batch_draw_enabled: bool = true
var _culling_enabled: bool = true

# ============ 初始化 ============

func _ready():
	_setup_draw_system()
	_initialize_pool()
	set_process(true)
	
	print("✓ ShapeDrawer 已就绪")
	print("  - 最大形状数: %d" % MAX_SHAPES)
	print("  - 对象池: %s" % ("启用" if ENABLE_OBJECT_POOL else "禁用"))

## 设置绘制系统
func _setup_draw_system():
	# 创建画布层
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "ShapeDrawerCanvas"
	canvas_layer.layer = 100  # 最上层
	add_child(canvas_layer)
	
	# 创建绘制节点
	draw_node = Node2D.new()
	draw_node.name = "ShapeDrawNode"
	canvas_layer.add_child(draw_node)
	
	# 连接绘制信号
	draw_node.draw.connect(_on_draw)

## 初始化对象池
func _initialize_pool():
	if not ENABLE_OBJECT_POOL:
		return
	
	# 预创建一些形状对象
	for i in range(20):
		var shape = ShapeInstance.new(Vector2.ZERO, ShapeInstance.ShapeType.CIRCLE)
		shape_pool.append(shape)

# ============ 主循环 ============

func _process(delta: float):
	var start_time = Time.get_ticks_usec()
	
	# 更新所有形状动画
	var i = 0
	while i < shapes.size():
		var shape = shapes[i]
		
		# 更新动画
		if not shape.update(delta):
			# 动画完成且透明度为0，移除形状
			if shape.opacity <= 0.0:
				_remove_shape_at_index(i)
				continue
		
		i += 1
	
	# 请求重绘
	draw_node.queue_redraw()
	
	_update_time = (Time.get_ticks_usec() - start_time) / 1000.0

## 绘制回调
func _on_draw():
	var start_time = Time.get_ticks_usec()
	
	# 批量绘制所有形状
	if _batch_draw_enabled:
		_batch_draw_shapes()
	else:
		for shape in shapes:
			_draw_single_shape(shape)
	
	_draw_time = (Time.get_ticks_usec() - start_time) / 1000.0

## 批量绘制（性能优化）
func _batch_draw_shapes():
	# 按形状类型分组绘制可以提高性能
	# 但当前实现为简单遍历，可根据需要优化
	
	for shape in shapes:
		# 视锥剔除（可选）
		if _culling_enabled and not _is_shape_visible(shape):
			continue
		
		_draw_single_shape(shape)

## 绘制单个形状
func _draw_single_shape(shape: ShapeInstance):
	var vertices = shape.get_shape_vertices()
	if vertices.is_empty() or vertices.size() < 3:
		return
	
	# 应用变换
	var transform = Transform2D()
	transform = transform.translated(shape.position)
	transform = transform.rotated(shape.rotation_angle)
	
	# 应用透明度
	var draw_color = shape.color
	draw_color.a *= shape.opacity
	
	# 转换顶点
	var transformed_vertices = PackedVector2Array()
	for vertex in vertices:
		transformed_vertices.append(transform * vertex)
	
	# 检查顶点有效性（防止三角剖分失败）
	if not _is_valid_polygon(transformed_vertices):
		# 如果多边形无效，只绘制轮廓
		_draw_outline_only(transformed_vertices, draw_color, shape.outline_width)
		return
	
	# 绘制填充或轮廓
	if shape.filled:
		# 绘制填充
		draw_node.draw_colored_polygon(transformed_vertices, draw_color)
	
	# 绘制轮廓
	var outline_color = shape.outline_color
	outline_color.a *= shape.opacity
	var outline_width = shape.outline_width if shape.outline_width > 0 else 2.0
	
	for i in range(vertices.size()):
		var p1 = transformed_vertices[i]
		var p2 = transformed_vertices[(i + 1) % vertices.size()]
		draw_node.draw_line(p1, p2, outline_color, outline_width)

## 检查多边形是否有效
func _is_valid_polygon(vertices: PackedVector2Array) -> bool:
	if vertices.size() < 3:
		return false
	
	# 检查是否有重复顶点
	for i in range(vertices.size()):
		for j in range(i + 1, vertices.size()):
			if vertices[i].distance_to(vertices[j]) < 0.1:
				return false
	
	# 检查面积是否为0（共线）
	var area = 0.0
	for i in range(vertices.size()):
		var j = (i + 1) % vertices.size()
		area += vertices[i].x * vertices[j].y
		area -= vertices[j].x * vertices[i].y
	
	return abs(area) > 0.01

## 仅绘制轮廓（用于无效多边形）
func _draw_outline_only(vertices: PackedVector2Array, color: Color, width: float):
	var outline_width = width if width > 0 else 2.0
	for i in range(vertices.size()):
		var p1 = vertices[i]
		var p2 = vertices[(i + 1) % vertices.size()]
		draw_node.draw_line(p1, p2, color, outline_width)

## 视锥剔除检查
func _is_shape_visible(shape: ShapeInstance) -> bool:
	var viewport = get_viewport()
	if not viewport:
		return true
	
	var screen_rect = viewport.get_visible_rect()
	var shape_rect = Rect2(shape.position - Vector2.ONE * shape.size, Vector2.ONE * shape.size * 2)
	
	return screen_rect.intersects(shape_rect)

# ============ 形状创建 API ============

## 基础创建方法
func create_shape(at_position: Vector2, shape_type: ShapeInstance.ShapeType, size: float = 50.0, color: Color = Color.WHITE, filled: bool = false) -> ShapeInstance:
	if shapes.size() >= MAX_SHAPES:
		push_warning("达到最大形状数量限制: %d" % MAX_SHAPES)
		return null
	
	var shape: ShapeInstance
	
	# 从对象池获取或创建新对象
	if ENABLE_OBJECT_POOL and shape_pool.size() > 0:
		shape = shape_pool.pop_back()
		# 重置属性
		shape.position = at_position
		shape.shape_type = shape_type
		shape.size = size
		shape.color = color
		shape.filled = filled
		shape.rotation_angle = 0.0
		shape.self_rotation = 0.0
		shape.opacity = 1.0
		shape.outline_width = 2.0
		shape.outline_color = color
		shape.animations.clear()
		shape.current_animation_index = 0
	else:
		shape = ShapeInstance.new(at_position, shape_type, size, color)
		shape.filled = filled
	
	shapes.append(shape)
	return shape

## 在节点位置创建
func create_shape_at_node(node: Node2D, shape_type: ShapeInstance.ShapeType, size: float = 50.0, color: Color = Color.WHITE, filled: bool = false) -> ShapeInstance:
	var pos = node.global_position if node is Node2D else Vector2.ZERO
	return create_shape(pos, shape_type, size, color, filled)

## 创建自定义顶点形状
func create_custom_shape(at_position: Vector2, vertices: PackedVector2Array, color: Color = Color.WHITE, filled: bool = false) -> ShapeInstance:
	var shape = create_shape(at_position, ShapeInstance.ShapeType.CUSTOM, 1.0, color, filled)
	if shape:
		shape.set_custom_vertices(vertices)
	return shape

## 创建N边正多边形
func create_polygon(at_position: Vector2, sides: int, size: float = 50.0, color: Color = Color.WHITE, filled: bool = false) -> ShapeInstance:
	var shape = create_shape(at_position, ShapeInstance.ShapeType.POLYGON_N, size, color, filled)
	if shape:
		shape.set_polygon_sides(sides)
	return shape

# ============ 便捷预设 API ============

## 创建旋转形状
func create_rotating_shape(at_position: Vector2, shape_type: ShapeInstance.ShapeType, size: float = 50.0, color: Color = Color.WHITE, speed: float = 1.0, clockwise: bool = true, filled: bool = false) -> ShapeInstance:
	var shape = create_shape(at_position, shape_type, size, color, filled)
	if shape:
		var direction = 1.0 if clockwise else -1.0
		shape.self_rotate_by(TAU * direction, 2.0 / speed).set_loops(-1)
	return shape

## 创建脉动形状
func create_pulsing_shape(at_position: Vector2, shape_type: ShapeInstance.ShapeType, size: float = 50.0, color: Color = Color.WHITE, scale_factor: float = 1.5, speed: float = 1.0, filled: bool = false) -> ShapeInstance:
	var shape = create_shape(at_position, shape_type, size, color, filled)
	if shape:
		shape.scale_to(size * scale_factor, 0.5 / speed)\
			.scale_to(size, 0.5 / speed)\
			.set_loops(-1)
	return shape

## 创建闪烁形状
func create_blinking_shape(at_position: Vector2, shape_type: ShapeInstance.ShapeType, size: float = 50.0, color: Color = Color.WHITE, min_opacity: float = 0.2, speed: float = 1.0, filled: bool = false) -> ShapeInstance:
	var shape = create_shape(at_position, shape_type, size, color, filled)
	if shape:
		shape.fade_to(min_opacity, 0.5 / speed)\
			.fade_to(1.0, 0.5 / speed)\
			.set_loops(-1)
	return shape

## 创建彩虹渐变形状
func create_rainbow_shape(at_position: Vector2, shape_type: ShapeInstance.ShapeType, size: float = 50.0, speed: float = 1.0, filled: bool = false) -> ShapeInstance:
	var shape = create_shape(at_position, shape_type, size, Color.RED, filled)
	if shape:
		shape.color_to(Color.ORANGE, 0.5 / speed)\
			.color_to(Color.YELLOW, 0.5 / speed)\
			.color_to(Color.GREEN, 0.5 / speed)\
			.color_to(Color.CYAN, 0.5 / speed)\
			.color_to(Color.BLUE, 0.5 / speed)\
			.color_to(Color.MAGENTA, 0.5 / speed)\
			.color_to(Color.RED, 0.5 / speed)\
			.set_loops(-1)
	return shape

## 创建轨道运行形状（行星效果）
func create_orbiting_shape(center: Vector2, radius: float, shape_type: ShapeInstance.ShapeType, size: float = 30.0, color: Color = Color.WHITE, speed: float = 1.0, clockwise: bool = true, filled: bool = false) -> ShapeInstance:
	var start_pos = center + Vector2(radius, 0)
	var shape = create_shape(start_pos, shape_type, size, color, filled)
	if shape:
		var angle_speed = (TAU / 3.0) * speed * (1.0 if clockwise else -1.0)
		shape.orbit_around(center, radius, angle_speed)
	return shape

## 创建螺旋形状
func create_spiral_shape(start_pos: Vector2, shape_type: ShapeInstance.ShapeType, size: float = 20.0, color: Color = Color.WHITE, turns: int = 3, radius: float = 200.0, duration: float = 3.0, filled: bool = false) -> ShapeInstance:
	var shape = create_shape(start_pos, shape_type, size, color, filled)
	if shape:
		# 创建螺旋路径点
		var points = []
		var segments = turns * 16
		for i in range(segments + 1):
			var t = float(i) / segments
			var angle = t * turns * TAU
			var r = radius * t
			points.append(start_pos + Vector2(cos(angle), sin(angle)) * r)
		
		shape.move_along_path(points, duration)
	return shape

# ============ 复杂预设 ============

## 创建魔法阵
func create_magic_circle(center: Vector2, radius: float = 200.0, layers: int = 3, complexity: int = 2) -> Array[ShapeInstance]:
	var magic_shapes: Array[ShapeInstance] = []
	
	# 多层旋转环
	for layer in range(layers):
		var layer_radius = radius - layer * (radius / (layers + 1))
		var num_shapes = 6 + layer * complexity * 2
		var shape_types = [
			ShapeInstance.ShapeType.TRIANGLE,
			ShapeInstance.ShapeType.SQUARE,
			ShapeInstance.ShapeType.PENTAGON,
			ShapeInstance.ShapeType.HEXAGON,
			ShapeInstance.ShapeType.STAR
		]
		
		for i in range(num_shapes):
			var angle = (TAU / num_shapes) * i
			var pos = center + Vector2(cos(angle), sin(angle)) * layer_radius
			
			var shape_type = shape_types[layer % shape_types.size()]
			var hue = float(layer) / layers
			var color = Color.from_hsv(hue, 0.8, 1.0)
			
			var shape = create_shape(pos, shape_type, 15.0 + layer * 5, color)
			if shape:
				var dir = 1.0 if layer % 2 == 0 else -1.0
				shape.rotate_by(TAU * dir, 3.0 + layer * 0.5).set_loops(-1)
				shape.fade_to(0.3, 1.0).fade_to(1.0, 1.0).set_loops(-1).set_parallel()
				magic_shapes.append(shape)
	
	# 中心星星
	var center_star = create_shape(center, ShapeInstance.ShapeType.STAR, 50.0, Color.WHITE)
	if center_star:
		center_star.rotate_by(TAU, 4.0).set_loops(-1)
		center_star.scale_to(70.0, 1.0).scale_to(50.0, 1.0).set_loops(-1).set_parallel()
		center_star.color_to(Color.GOLD, 1.0).color_to(Color.WHITE, 1.0).set_loops(-1).set_parallel()
		magic_shapes.append(center_star)
	
	# 快速旋转内圈
	var inner_count = 8
	for i in range(inner_count):
		var angle = (TAU / inner_count) * i
		var pos = center + Vector2(cos(angle), sin(angle)) * (radius * 0.4)
		var shape = create_shape(pos, ShapeInstance.ShapeType.HEXAGON, 12.0, Color.DEEP_PINK)
		if shape:
			shape.rotate_by(-TAU * 2, 2.0).set_loops(-1)
			magic_shapes.append(shape)
	
	# 外圈符文
	var outer_count = 12
	for i in range(outer_count):
		var angle = (TAU / outer_count) * i
		var pos = center + Vector2(cos(angle), sin(angle)) * (radius * 1.15)
		var shape = create_shape(pos, ShapeInstance.ShapeType.STAR, 20.0, Color.ORANGE)
		if shape:
			shape.rotate_by(TAU * 0.5, 2.0).set_loops(-1)
			shape.fade_to(0.2, 1.5).fade_to(1.0, 1.5).set_loops(-1).set_parallel()
			magic_shapes.append(shape)
	
	return magic_shapes

## 创建粒子爆发效果
func create_particle_burst(center: Vector2, particle_count: int = 30, max_radius: float = 250.0, duration: float = 2.0, colors: Array = []) -> Array[ShapeInstance]:
	var particles: Array[ShapeInstance] = []
	
	if colors.is_empty():
		# 默认彩虹色
		for i in range(7):
			colors.append(Color.from_hsv(float(i) / 7.0, 1.0, 1.0))
	
	for i in range(particle_count):
		var angle = (TAU / particle_count) * i + randf_range(-0.1, 0.1)
		var target_radius = randf_range(max_radius * 0.7, max_radius)
		var target_pos = center + Vector2(cos(angle), sin(angle)) * target_radius
		
		var color = colors[i % colors.size()]
		var shape = create_shape(center, ShapeInstance.ShapeType.CIRCLE, randf_range(8, 15), color)
		
		if shape:
			shape.move_to(target_pos, duration, ShapeInstance.EaseType.EASE_OUT)
			shape.scale_to(20.0, duration * 0.3).scale_to(5.0, duration * 0.7).set_parallel()
			shape.fade_to(0.0, duration * 1.2).set_parallel()
			shape.rotate_by(TAU * randf_range(1, 3), duration).set_parallel()
			particles.append(shape)
	
	return particles

## 创建波纹效果
func create_ripple(center: Vector2, max_radius: float = 300.0, wave_count: int = 5, duration: float = 2.0, color: Color = Color.CYAN) -> Array[ShapeInstance]:
	var ripples: Array[ShapeInstance] = []
	
	for i in range(wave_count):
		await get_tree().create_timer(duration / wave_count * i).timeout
		
		var ripple = create_shape(center, ShapeInstance.ShapeType.CIRCLE, 10.0, color)
		if ripple:
			ripple.scale_to(max_radius, duration, ShapeInstance.EaseType.EASE_OUT)
			ripple.fade_to(0.0, duration, ShapeInstance.EaseType.EASE_OUT).set_parallel()
			ripples.append(ripple)
	
	return ripples

## 创建行星系统
func create_planet_system(center: Vector2, planet_count: int = 5, orbit_radius_start: float = 100.0, orbit_spacing: float = 60.0) -> Array[ShapeInstance]:
	var system: Array[ShapeInstance] = []
	
	# 中心太阳
	var sun = create_pulsing_shape(center, ShapeInstance.ShapeType.STAR, 60.0, Color.YELLOW, 1.3, 0.5)
	system.append(sun)
	
	# 轨道行星
	for i in range(planet_count):
		var orbit_radius = orbit_radius_start + i * orbit_spacing
		var planet_size = 15.0 + randf_range(-5, 5)
		var planet_color = Color.from_hsv(randf(), 0.7, 1.0)
		var speed = 1.0 / (1.0 + i * 0.3)  # 外圈慢
		
		var planet = create_orbiting_shape(center, orbit_radius, ShapeInstance.ShapeType.CIRCLE, planet_size, planet_color, speed)
		if planet:
			planet.rotate_by(TAU, 3.0).set_loops(-1).set_parallel()
			system.append(planet)
	
	return system

## 创建螺旋星系
func create_spiral_galaxy(center: Vector2, arms: int = 3, particles_per_arm: int = 20, max_radius: float = 300.0) -> Array[ShapeInstance]:
	var galaxy: Array[ShapeInstance] = []
	
	for arm in range(arms):
		var arm_angle_offset = (TAU / arms) * arm
		
		for i in range(particles_per_arm):
			var t = float(i) / particles_per_arm
			var angle = t * TAU * 2 + arm_angle_offset  # 2圈螺旋
			var radius = t * max_radius
			var pos = center + Vector2(cos(angle), sin(angle)) * radius
			
			var star = create_shape(pos, ShapeInstance.ShapeType.STAR, randf_range(5, 12), Color.from_hsv(0.6, 0.3, 1.0))
			if star:
				star.fade_to(0.3, randf_range(1, 2)).fade_to(1.0, randf_range(1, 2)).set_loops(-1)
				star.rotate_by(TAU, randf_range(3, 6)).set_loops(-1).set_parallel()
				galaxy.append(star)
	
	return galaxy

# ============ 形状管理 ============

## 清除所有形状
func clear_all():
	# 返回对象池
	if ENABLE_OBJECT_POOL:
		for shape in shapes:
			if shape_pool.size() < 100:  # 池大小限制
				shape_pool.append(shape)
	
	shapes.clear()

## 移除指定形状
func remove_shape(shape: ShapeInstance):
	var index = shapes.find(shape)
	if index >= 0:
		_remove_shape_at_index(index)

## 移除指定索引的形状
func _remove_shape_at_index(index: int):
	if index < 0 or index >= shapes.size():
		return
	
	var shape = shapes[index]
	shapes.remove_at(index)
	
	# 返回对象池
	if ENABLE_OBJECT_POOL and shape_pool.size() < 100:
		shape_pool.append(shape)

## 获取形状数量
func get_shape_count() -> int:
	return shapes.size()

## 查找特定类型的形状
func find_shapes_by_type(shape_type: ShapeInstance.ShapeType) -> Array[ShapeInstance]:
	var result: Array[ShapeInstance] = []
	for shape in shapes:
		if shape.shape_type == shape_type:
			result.append(shape)
	return result

# ============ 配置和调试 ============

## 启用/禁用批量绘制
func set_batch_draw(enabled: bool):
	_batch_draw_enabled = enabled

## 启用/禁用视锥剔除
func set_culling(enabled: bool):
	_culling_enabled = enabled

## 设置绘制层级
func set_canvas_layer(layer: int):
	if canvas_layer:
		canvas_layer.layer = layer

## 获取性能统计
func get_performance_stats() -> Dictionary:
	return {
		"shape_count": shapes.size(),
		"update_time_ms": _update_time,
		"draw_time_ms": _draw_time,
		"pool_size": shape_pool.size()
	}

## 打印调试信息
func print_debug_info():
	var stats = get_performance_stats()
	print("=== ShapeDrawer 调试信息 ===")
	print("形状数量: %d / %d" % [stats.shape_count, MAX_SHAPES])
	print("更新时间: %.2f ms" % stats.update_time_ms)
	print("绘制时间: %.2f ms" % stats.draw_time_ms)
	print("对象池: %d" % stats.pool_size)
	print("===========================")
