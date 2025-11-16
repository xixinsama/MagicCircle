extends RefCounted
class_name ShapeInstance

## 形状实例类 - 支持丰富的形状和动画效果
## 设计为可扩展，方便添加自定义形状和动画

# ============ 枚举定义 ============

## 形状类型枚举
enum ShapeType {
	TRIANGLE,        # 三角形
	SQUARE,          # 正方形
	PENTAGON,        # 五边形
	HEXAGON,         # 六边形
	HEPTAGON,        # 七边形
	OCTAGON,         # 八边形
	CIRCLE,          # 圆形（32边形近似）
	STAR,            # 五角星
	STAR_6,          # 六角星
	STAR_8,          # 八角星
	DIAMOND,         # 菱形
	RHOMBUS,         # 平行四边形菱形
	ELLIPSE,         # 椭圆
	CAPSULE,         # 胶囊形
	ROUNDED_RECT,    # 圆角矩形
	CROSS,           # 十字形
	ARROW,           # 箭头
	HEART,           # 心形
	CRESCENT,        # 月牙形
	RING,            # 环形（空心圆）
	CUSTOM,          # 自定义顶点
	POLYGON_N        # N边正多边形（动态）
}

## 缓动函数类型
enum EaseType {
	LINEAR,          # 线性
	EASE_IN,         # 慢入
	EASE_OUT,        # 慢出
	EASE_IN_OUT,     # 慢入慢出
	BOUNCE_IN,       # 弹跳入
	BOUNCE_OUT,      # 弹跳出
	ELASTIC_IN,      # 弹性入
	ELASTIC_OUT,     # 弹性出
	BACK_IN,         # 回退入
	BACK_OUT,        # 回退出
}

# ============ 形状属性 ============

## 基础属性
var shape_type: ShapeType = ShapeType.CIRCLE
var position: Vector2 = Vector2.ZERO
var size: float = 50.0
var color: Color = Color.WHITE
var rotation_angle: float = 0.0
var opacity: float = 1.0

## 形状特殊属性
var filled: bool = false                 # 是否填充（默认不填充）
var outline_width: float = 2.0           # 轮廓宽度
var outline_color: Color = Color.WHITE   # 轮廓颜色
var custom_vertices: PackedVector2Array = []  # 自定义顶点
var polygon_sides: int = 5                # POLYGON_N类型的边数
var ellipse_ratio: float = 0.6            # 椭圆宽高比
var ring_thickness: float = 0.3           # 环形厚度比例
var star_inner_radius: float = 0.4        # 星形内半径比例

## 高级变换
var scale_x: float = 1.0                 # X轴缩放
var scale_y: float = 1.0                 # Y轴缩放
var skew_x: float = 0.0                  # X轴倾斜
var skew_y: float = 0.0                  # Y轴倾斜
var self_rotation: float = 0.0           # 自身旋转（围绕重心）

# ============ 动画系统 ============

var is_animating: bool = false
var animations: Array[Dictionary] = []
var parallel_animations: Array[Dictionary] = []  # 并行动画专用列表
var sequential_animations: Array[Dictionary] = []  # 顺序动画专用列表
var current_animation_index: int = 0

## 轨道运动属性
var orbit_center: Vector2 = Vector2.ZERO
var orbit_center_node: Node2D = null  # 跟随的节点
var orbit_radius: float = 0.0
var orbit_angle: float = 0.0
var is_orbiting: bool = false

## 节点跟随
var following_node: Node2D = null
var follow_offset: Vector2 = Vector2.ZERO

# ============ 构造函数 ============

func _init(p_position: Vector2, p_shape_type: ShapeType, p_size: float = 50.0, p_color: Color = Color.WHITE):
	position = p_position
	shape_type = p_shape_type
	size = p_size
	color = p_color

# ============ 链式调用 - 基础动画 ============

## 旋转动画
func rotate_by(angle: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "rotate",
		"target": rotation_angle + angle,
		"start": rotation_angle,
		"duration": duration,
		"ease": ease
	})
	return self

## 旋转到指定角度
func rotate_to(target_angle: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "rotate",
		"target": target_angle,
		"start": rotation_angle,
		"duration": duration,
		"ease": ease
	})
	return self

## 缩放动画
func scale_to(target_size: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "scale",
		"target": target_size,
		"start": size,
		"duration": duration,
		"ease": ease
	})
	return self

## 颜色动画
func color_to(target_color: Color, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "color",
		"target": target_color,
		"start": color,
		"duration": duration,
		"ease": ease
	})
	return self

## 透明度动画
func fade_to(target_opacity: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "fade",
		"target": clamp(target_opacity, 0.0, 1.0),
		"start": opacity,
		"duration": duration,
		"ease": ease
	})
	return self

## 移动动画
func move_to(target_position: Vector2, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "move",
		"target": target_position,
		"start": position,
		"duration": duration,
		"ease": ease
	})
	return self

# ============ 链式调用 - 高级动画 ============

## 自身旋转（围绕形状重心旋转，不同于位置旋转）
func self_rotate_by(angle: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "self_rotate",
		"target": self_rotation + angle,
		"start": self_rotation,
		"duration": duration,
		"ease": ease
	})
	return self

## 自身旋转到指定角度
func self_rotate_to(target_angle: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "self_rotate",
		"target": target_angle,
		"start": self_rotation,
		"duration": duration,
		"ease": ease
	})
	return self

## 轨道运动（围绕某个点旋转）
func orbit_around(center: Vector2, radius: float, angle_speed: float, duration: float = 0.0, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	orbit_center = center
	orbit_center_node = null
	orbit_radius = radius
	is_orbiting = true
	
	if duration > 0:
		_add_animation({
			"type": "orbit",
			"center": center,
			"radius": radius,
			"angle_speed": angle_speed,
			"duration": duration,
			"ease": ease,
			"start_angle": orbit_angle,
			"is_continuous": false
		})
	else:
		# 持续轨道运动（自动设为并行）
		_add_animation({
			"type": "orbit_continuous",
			"center": center,
			"radius": radius,
			"angle_speed": angle_speed,
			"duration": INF,
			"is_continuous": true,
			"parallel": true  # 自动并行
		})
	return self

## 围绕节点轨道运动
func orbit_around_node(node: Node2D, radius: float, angle_speed: float) -> ShapeInstance:
	orbit_center_node = node
	orbit_center = node.global_position if node else Vector2.ZERO
	orbit_radius = radius
	is_orbiting = true
	
	_add_animation({
		"type": "orbit_node",
		"node": node,
		"radius": radius,
		"angle_speed": angle_speed,
		"duration": INF,
		"is_continuous": true,
		"parallel": true  # 自动并行
	})
	return self

## X轴缩放
func scale_x_to(target: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "scale_x",
		"target": target,
		"start": scale_x,
		"duration": duration,
		"ease": ease
	})
	return self

## Y轴缩放
func scale_y_to(target: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "scale_y",
		"target": target,
		"start": scale_y,
		"duration": duration,
		"ease": ease
	})
	return self

## 倾斜变形
func skew_to(x: float, y: float, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "skew",
		"target_x": x,
		"target_y": y,
		"start_x": skew_x,
		"start_y": skew_y,
		"duration": duration,
		"ease": ease
	})
	return self

## 沿路径移动
func move_along_path(points: Array, duration: float, ease: EaseType = EaseType.LINEAR) -> ShapeInstance:
	_add_animation({
		"type": "path",
		"points": points,
		"duration": duration,
		"ease": ease,
		"current_point": 0
	})
	return self

## 贝塞尔曲线移动
func move_bezier(control1: Vector2, control2: Vector2, end: Vector2, duration: float) -> ShapeInstance:
	_add_animation({
		"type": "bezier",
		"start": position,
		"control1": control1,
		"control2": control2,
		"end": end,
		"duration": duration
	})
	return self

# ============ 持续动画（无限时长）============

## 持续自身旋转
func self_rotate_during(angle_speed: float) -> ShapeInstance:
	_add_animation({
		"type": "self_rotate_during",
		"angle_speed": angle_speed,
		"duration": INF,
		"is_continuous": true,
		"parallel": true  # 自动并行
	})
	return self

## 持续位置旋转
func rotate_during(angle_speed: float) -> ShapeInstance:
	_add_animation({
		"type": "rotate_during",
		"angle_speed": angle_speed,
		"duration": INF,
		"is_continuous": true,
		"parallel": true  # 自动并行
	})
	return self

## 跟随节点位置
func follow_node(node: Node2D, offset: Vector2 = Vector2.ZERO) -> ShapeInstance:
	following_node = node
	follow_offset = offset
	_add_animation({
		"type": "follow_node",
		"node": node,
		"offset": offset,
		"duration": INF,
		"is_continuous": true,
		"parallel": true  # 自动并行
	})
	return self

# ============ 链式调用 - 控制选项 ============

## 设置循环次数（-1为无限循环）
func set_loops(loop_count: int = -1) -> ShapeInstance:
	if animations.size() > 0:
		animations[-1]["loops"] = loop_count
		animations[-1]["current_loop"] = 0
	return self

## 设置延迟
func set_delay(delay_time: float) -> ShapeInstance:
	if animations.size() > 0:
		animations[-1]["delay"] = delay_time
		animations[-1]["delay_elapsed"] = 0.0
	return self

## 设置并行执行
func set_parallel() -> ShapeInstance:
	# 将最后一个动画标记为并行
	if animations.size() > 0:
		animations[-1]["parallel"] = true
	return self

## 设置回调
func on_complete(callback: Callable) -> ShapeInstance:
	if animations.size() > 0:
		animations[-1]["on_complete"] = callback
	return self

## 立即执行（跳过队列，直接加入并行动画）
func execute_immediately() -> ShapeInstance:
	if animations.size() > 0:
		var anim = animations[-1]
		anim["parallel"] = true
		anim["immediate"] = true
	return self

# ============ 更新系统 ============

## 更新所有动画
func update(delta: float) -> bool:
	# 更新节点跟随
	if following_node and is_instance_valid(following_node):
		position = following_node.global_position + follow_offset
	
	# 更新轨道中心（如果跟随节点）
	if orbit_center_node and is_instance_valid(orbit_center_node):
		orbit_center = orbit_center_node.global_position
	
	# 首次更新时分类动画
	if animations.size() > 0 and parallel_animations.size() == 0 and sequential_animations.size() == 0:
		_classify_animations()
	
	if parallel_animations.is_empty() and sequential_animations.is_empty():
		is_animating = false
		return false
	
	is_animating = true
	
	# 更新所有并行动画
	_update_parallel_animations(delta)
	
	# 更新顺序动画
	_update_sequential_animations(delta)
	
	return is_animating

## 分类动画为并行和顺序
func _classify_animations():
	parallel_animations.clear()
	sequential_animations.clear()
	
	for anim in animations:
		# 持续动画、标记为parallel的、或标记为immediate的，都加入并行列表
		if anim.get("parallel", false) or anim.get("is_continuous", false) or anim.get("immediate", false):
			parallel_animations.append(anim)
		else:
			sequential_animations.append(anim)
	
	animations.clear()

## 更新并行动画
func _update_parallel_animations(delta: float):
	var i = 0
	while i < parallel_animations.size():
		var anim = parallel_animations[i]
		
		if _update_single_animation(anim, delta):
			# 动画完成，如果不是持续动画则移除
			if not anim.get("is_continuous", false):
				parallel_animations.remove_at(i)
				continue
		
		i += 1

## 更新顺序动画
func _update_sequential_animations(delta: float):
	if current_animation_index >= sequential_animations.size():
		if sequential_animations.size() > 0:
			sequential_animations.clear()
			current_animation_index = 0
		return
	
	var anim = sequential_animations[current_animation_index]
	if _update_single_animation(anim, delta):
		current_animation_index += 1
		if current_animation_index >= sequential_animations.size():
			sequential_animations.clear()
			current_animation_index = 0

## 更新单个动画
func _update_single_animation(anim: Dictionary, delta: float) -> bool:
	# 处理延迟
	if anim.has("delay") and anim["delay"] > 0:
		anim["delay_elapsed"] = anim.get("delay_elapsed", 0.0) + delta
		if anim["delay_elapsed"] < anim["delay"]:
			return false
	
	# 初始化经过时间
	if not anim.has("elapsed"):
		anim["elapsed"] = 0.0
	
	anim["elapsed"] += delta
	
	var progress = min(anim["elapsed"] / anim["duration"], 1.0) if anim["duration"] > 0 else 1.0
	var eased_progress = _apply_easing(progress, anim.get("ease", EaseType.LINEAR))
	
	# 根据动画类型应用变换
	match anim["type"]:
		"rotate":
			rotation_angle = lerp(anim["start"], anim["target"], eased_progress)
		
		"self_rotate":
			self_rotation = lerp(anim["start"], anim["target"], eased_progress)
		
		"scale":
			size = lerp(anim["start"], anim["target"], eased_progress)
		
		"color":
			color = anim["start"].lerp(anim["target"], eased_progress)
		
		"fade":
			opacity = lerp(anim["start"], anim["target"], eased_progress)
		
		"move":
			position = anim["start"].lerp(anim["target"], eased_progress)
		
		"orbit":
			var angle_delta = anim["angle_speed"] * delta
			orbit_angle += angle_delta
			position = anim["center"] + Vector2(cos(orbit_angle), sin(orbit_angle)) * anim["radius"]
		
		"orbit_continuous":
			var angle_delta = anim["angle_speed"] * delta
			orbit_angle += angle_delta
			position = anim["center"] + Vector2(cos(orbit_angle), sin(orbit_angle)) * anim["radius"]
			return false  # 永不结束
		
		"orbit_node":
			# 跟随节点的轨道运动
			if anim["node"] and is_instance_valid(anim["node"]):
				var node_pos = anim["node"].global_position
				var angle_delta = anim["angle_speed"] * delta
				orbit_angle += angle_delta
				position = node_pos + Vector2(cos(orbit_angle), sin(orbit_angle)) * anim["radius"]
			return false  # 永不结束
		
		"self_rotate_during":
			# 持续自身旋转
			var angle_delta = anim["angle_speed"] * delta
			self_rotation += angle_delta
			return false  # 永不结束
		
		"rotate_during":
			# 持续位置旋转
			var angle_delta = anim["angle_speed"] * delta
			rotation_angle += angle_delta
			return false  # 永不结束
		
		"follow_node":
			# 跟随节点
			if anim["node"] and is_instance_valid(anim["node"]):
				position = anim["node"].global_position + anim["offset"]
			return false  # 永不结束
		
		"scale_x":
			scale_x = lerp(anim["start"], anim["target"], eased_progress)
		
		"scale_y":
			scale_y = lerp(anim["start"], anim["target"], eased_progress)
		
		"skew":
			skew_x = lerp(anim["start_x"], anim["target_x"], eased_progress)
			skew_y = lerp(anim["start_y"], anim["target_y"], eased_progress)
		
		"path":
			_update_path_animation(anim, eased_progress)
		
		"bezier":
			position = _bezier_curve(anim["start"], anim["control1"], anim["control2"], anim["end"], eased_progress)
	
	# 检查是否完成
	if progress >= 1.0:
		# 调用完成回调
		if anim.has("on_complete"):
			anim["on_complete"].call()
		
		# 检查循环
		if anim.has("loops"):
			var loops = anim["loops"]
			if loops == -1:  # 无限循环
				anim["elapsed"] = 0.0
				# 重置起始值
				_reset_animation_start_values(anim)
				return false
			else:
				anim["current_loop"] = anim.get("current_loop", 0) + 1
				if anim["current_loop"] < loops:
					anim["elapsed"] = 0.0
					_reset_animation_start_values(anim)
					return false
		
		return true
	
	return false

## 重置动画起始值（用于循环）
func _reset_animation_start_values(anim: Dictionary):
	match anim["type"]:
		"rotate":
			anim["start"] = rotation_angle
		"self_rotate":
			anim["start"] = self_rotation
		"scale":
			anim["start"] = size
		"color":
			anim["start"] = color
		"fade":
			anim["start"] = opacity
		"move":
			anim["start"] = position

## 路径动画更新
func _update_path_animation(anim: Dictionary, progress: float):
	var points = anim["points"]
	if points.size() < 2:
		return
	
	var total_segments = points.size() - 1
	var segment_progress = progress * total_segments
	var current_segment = int(segment_progress)
	var segment_t = segment_progress - current_segment
	
	if current_segment >= total_segments:
		position = points[-1]
	else:
		position = points[current_segment].lerp(points[current_segment + 1], segment_t)

## 贝塞尔曲线计算
func _bezier_curve(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	
	return uuu * p0 + 3 * uu * t * p1 + 3 * u * tt * p2 + ttt * p3

# ============ 缓动函数 ============

func _apply_easing(t: float, ease_type: EaseType) -> float:
	match ease_type:
		EaseType.LINEAR:
			return t
		
		EaseType.EASE_IN:
			return t * t
		
		EaseType.EASE_OUT:
			return t * (2.0 - t)
		
		EaseType.EASE_IN_OUT:
			return t * t * (3.0 - 2.0 * t)
		
		EaseType.BOUNCE_OUT:
			if t < (1.0 / 2.75):
				return 7.5625 * t * t
			elif t < (2.0 / 2.75):
				t -= (1.5 / 2.75)
				return 7.5625 * t * t + 0.75
			elif t < (2.5 / 2.75):
				t -= (2.25 / 2.75)
				return 7.5625 * t * t + 0.9375
			else:
				t -= (2.625 / 2.75)
				return 7.5625 * t * t + 0.984375
		
		EaseType.BOUNCE_IN:
			return 1.0 - _apply_easing(1.0 - t, EaseType.BOUNCE_OUT)
		
		EaseType.ELASTIC_OUT:
			if t == 0.0 or t == 1.0:
				return t
			return pow(2.0, -10.0 * t) * sin((t - 0.075) * (2.0 * PI) / 0.3) + 1.0
		
		EaseType.ELASTIC_IN:
			return 1.0 - _apply_easing(1.0 - t, EaseType.ELASTIC_OUT)
		
		EaseType.BACK_OUT:
			var c1 = 1.70158
			var c3 = c1 + 1.0
			return 1.0 + c3 * pow(t - 1.0, 3.0) + c1 * pow(t - 1.0, 2.0)
		
		EaseType.BACK_IN:
			var c1 = 1.70158
			var c3 = c1 + 1.0
			return c3 * t * t * t - c1 * t * t
	
	return t

# ============ 形状顶点生成 ============

## 获取形状顶点（带变换）
func get_shape_vertices() -> PackedVector2Array:
	var vertices = _get_base_vertices()
	
	# 应用缩放和倾斜
	var transformed = PackedVector2Array()
	for vertex in vertices:
		var v = vertex
		v.x *= scale_x
		v.y *= scale_y
		v.x += v.y * skew_x
		v.y += v.x * skew_y
		
		# 应用自身旋转（围绕重心）
		if self_rotation != 0.0:
			var cos_angle = cos(self_rotation)
			var sin_angle = sin(self_rotation)
			var rotated = Vector2(
				v.x * cos_angle - v.y * sin_angle,
				v.x * sin_angle + v.y * cos_angle
			)
			v = rotated
		
		transformed.append(v)
	
	return transformed

## 获取基础顶点（未变换）
func _get_base_vertices() -> PackedVector2Array:
	match shape_type:
		ShapeType.TRIANGLE:
			return _get_regular_polygon_vertices(3)
		ShapeType.SQUARE:
			return _get_regular_polygon_vertices(4)
		ShapeType.PENTAGON:
			return _get_regular_polygon_vertices(5)
		ShapeType.HEXAGON:
			return _get_regular_polygon_vertices(6)
		ShapeType.HEPTAGON:
			return _get_regular_polygon_vertices(7)
		ShapeType.OCTAGON:
			return _get_regular_polygon_vertices(8)
		ShapeType.CIRCLE:
			return _get_regular_polygon_vertices(32)
		ShapeType.STAR:
			return _get_star_vertices(5, size, size * star_inner_radius)
		ShapeType.STAR_6:
			return _get_star_vertices(6, size, size * star_inner_radius)
		ShapeType.STAR_8:
			return _get_star_vertices(8, size, size * star_inner_radius)
		ShapeType.DIAMOND:
			return _get_diamond_vertices()
		ShapeType.RHOMBUS:
			return _get_rhombus_vertices()
		ShapeType.ELLIPSE:
			return _get_ellipse_vertices()
		ShapeType.CAPSULE:
			return _get_capsule_vertices()
		ShapeType.ROUNDED_RECT:
			return _get_rounded_rect_vertices()
		ShapeType.CROSS:
			return _get_cross_vertices()
		ShapeType.ARROW:
			return _get_arrow_vertices()
		ShapeType.HEART:
			return _get_heart_vertices()
		ShapeType.CRESCENT:
			return _get_crescent_vertices()
		ShapeType.RING:
			return _get_ring_vertices()
		ShapeType.POLYGON_N:
			return _get_regular_polygon_vertices(polygon_sides)
		ShapeType.CUSTOM:
			return custom_vertices if custom_vertices.size() > 0 else _get_regular_polygon_vertices(3)
	
	return PackedVector2Array()

## 正多边形
func _get_regular_polygon_vertices(sides: int) -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var angle_step = TAU / sides
	for i in range(sides):
		var angle = i * angle_step - PI / 2
		vertices.append(Vector2(cos(angle), sin(angle)) * size)
	return vertices

## 星形
func _get_star_vertices(points: int, outer: float, inner: float) -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var angle_step = TAU / (points * 2)
	for i in range(points * 2):
		var angle = i * angle_step - PI / 2
		var radius = outer if i % 2 == 0 else inner
		vertices.append(Vector2(cos(angle), sin(angle)) * radius)
	return vertices

## 菱形（旋转45度的正方形）
func _get_diamond_vertices() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])

## 平行四边形菱形
func _get_rhombus_vertices() -> PackedVector2Array:
	var half = size * 0.5
	return PackedVector2Array([
		Vector2(-half, -size),
		Vector2(half, -size),
		Vector2(size, size),
		Vector2(0, size)
	])

## 椭圆
func _get_ellipse_vertices() -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var segments = 32
	var angle_step = TAU / segments
	for i in range(segments):
		var angle = i * angle_step
		vertices.append(Vector2(cos(angle) * size, sin(angle) * size * ellipse_ratio))
	return vertices

## 胶囊形
func _get_capsule_vertices() -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var radius = size * 0.3
	var length = size * 0.7
	var segments = 16
	
	# 上半圆
	for i in range(segments / 2 + 1):
		var angle = PI + (PI / (segments / 2)) * i
		vertices.append(Vector2(cos(angle) * radius, sin(angle) * radius - length))
	
	# 下半圆
	for i in range(segments / 2 + 1):
		var angle = (PI / (segments / 2)) * i
		vertices.append(Vector2(cos(angle) * radius, sin(angle) * radius + length))
	
	return vertices

## 圆角矩形
func _get_rounded_rect_vertices() -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var w = size
	var h = size * 0.6
	var radius = size * 0.2
	var segments = 4
	
	# 右上角
	for i in range(segments + 1):
		var angle = -PI/2 + (PI/2 / segments) * i
		vertices.append(Vector2(w - radius + cos(angle) * radius, -h + radius + sin(angle) * radius))
	
	# 右下角
	for i in range(segments + 1):
		var angle = 0 + (PI/2 / segments) * i
		vertices.append(Vector2(w - radius + cos(angle) * radius, h - radius + sin(angle) * radius))
	
	# 左下角
	for i in range(segments + 1):
		var angle = PI/2 + (PI/2 / segments) * i
		vertices.append(Vector2(-w + radius + cos(angle) * radius, h - radius + sin(angle) * radius))
	
	# 左上角
	for i in range(segments + 1):
		var angle = PI + (PI/2 / segments) * i
		vertices.append(Vector2(-w + radius + cos(angle) * radius, -h + radius + sin(angle) * radius))
	
	return vertices

## 十字形
func _get_cross_vertices() -> PackedVector2Array:
	var w = size * 0.3
	var h = size
	return PackedVector2Array([
		Vector2(-w, -h), Vector2(w, -h),
		Vector2(w, -w), Vector2(h, -w),
		Vector2(h, w), Vector2(w, w),
		Vector2(w, h), Vector2(-w, h),
		Vector2(-w, w), Vector2(-h, w),
		Vector2(-h, -w), Vector2(-w, -w)
	])

## 箭头
func _get_arrow_vertices() -> PackedVector2Array:
	var w = size * 0.3
	var h = size
	return PackedVector2Array([
		Vector2(0, -h),
		Vector2(w * 2, 0),
		Vector2(w, 0),
		Vector2(w, h),
		Vector2(-w, h),
		Vector2(-w, 0),
		Vector2(-w * 2, 0)
	])

## 心形
func _get_heart_vertices() -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var segments = 64
	for i in range(segments):
		var t = (float(i) / segments) * TAU
		var x = 16.0 * pow(sin(t), 3.0)
		var y = -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		vertices.append(Vector2(x, y) * size * 0.05)
	return vertices

## 月牙形
func _get_crescent_vertices() -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var segments = 32
	var offset = size * 0.4
	
	# 外圆
	for i in range(segments):
		var angle = (float(i) / segments) * TAU
		vertices.append(Vector2(cos(angle), sin(angle)) * size)
	
	# 内圆（反向）
	for i in range(segments, 0, -1):
		var angle = (float(i) / segments) * TAU
		vertices.append(Vector2(cos(angle), sin(angle)) * size * 0.7 + Vector2(offset, 0))
	
	return vertices

## 环形（空心圆）
func _get_ring_vertices() -> PackedVector2Array:
	var vertices = PackedVector2Array()
	var segments = 32
	var inner_radius = size * (1.0 - ring_thickness)
	
	# 外圆
	for i in range(segments):
		var angle = (float(i) / segments) * TAU
		vertices.append(Vector2(cos(angle), sin(angle)) * size)
	
	# 内圆（反向，形成空洞）
	for i in range(segments, 0, -1):
		var angle = (float(i) / segments) * TAU
		vertices.append(Vector2(cos(angle), sin(angle)) * inner_radius)
	
	return vertices

# ============ 辅助方法 ============

## 添加动画
func _add_animation(anim_data: Dictionary):
	animations.append(anim_data)

## 清除所有动画
func clear_animations():
	animations.clear()
	parallel_animations.clear()
	sequential_animations.clear()
	current_animation_index = 0
	is_animating = false

## 清除并行动画
func clear_parallel_animations():
	parallel_animations.clear()

## 清除顺序动画
func clear_sequential_animations():
	sequential_animations.clear()
	current_animation_index = 0

## 设置自定义顶点
func set_custom_vertices(vertices: PackedVector2Array) -> ShapeInstance:
	custom_vertices = vertices
	shape_type = ShapeType.CUSTOM
	return self

## 设置多边形边数
func set_polygon_sides(sides: int) -> ShapeInstance:
	polygon_sides = max(3, sides)
	shape_type = ShapeType.POLYGON_N
	return self

## 设置填充
func set_filled(is_filled: bool) -> ShapeInstance:
	filled = is_filled
	return self

## 设置轮廓宽度
func set_outline_width(width: float) -> ShapeInstance:
	outline_width = width
	return self

## 设置轮廓颜色
func set_outline_color(col: Color) -> ShapeInstance:
	outline_color = col
	return self
