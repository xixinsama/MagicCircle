# ShapeDrawer - Godot 4.6 形状绘制插件

一个功能强大、高度可扩展的 Godot 4.6 插件，提供类似 Tween 的链式 API 来创建和动画化各种形状。

---

## ✨ 核心特性

### 🎨 丰富的形状库（20+种）

**基础多边形**
- 三角形、正方形、五边形、六边形、七边形、八边形
- N边正多边形（动态边数）

**特殊形状**
- 五角星、六角星、八角星
- 圆形、椭圆、环形
- 菱形、平行四边形

**高级形状**
- 胶囊形、圆角矩形
- 十字形、箭头
- 心形、月牙形
- 自定义顶点形状

### 🎬 强大的动画系统

**基础动画**
- ✓ 旋转（rotate_by / rotate_to）
- ✓ **自身旋转（self_rotate_by / self_rotate_to）** - 🆕 围绕重心旋转
- ✓ 缩放（scale_to）
- ✓ 移动（move_to）
- ✓ 颜色渐变（color_to）
- ✓ 透明度（fade_to）

**高级动画**
- ✓ 轨道运动（orbit_around）- 行星效果
- ✓ 贝塞尔曲线（move_bezier）
- ✓ 路径移动（move_along_path）
- ✓ 独立X/Y缩放（scale_x_to / scale_y_to）
- ✓ 倾斜变形（skew_to）

### 📊 10种缓动函数

- Linear、Ease In/Out/InOut
- Bounce In/Out
- Elastic In/Out
- Back In/Out

### ⚡ 性能优化

- 对象池管理
- 视锥剔除
- 批量绘制
- **智能三角剖分错误处理** - 🆕
- 最高支持500个形状

### 🎨 视觉控制

- **默认不填充，只显示轮廓** - 🆕
- 可选填充模式
- 可调节轮廓宽度和颜色
- 支持透明度控制

---
## 文件结构

```
addons/shape_drawer/
├── plugin.cfg          # 插件配置
├── plugin.gd           # 插件入口
├── shape_drawer.gd     # 全局单例
└── shape_instance.gd   # 形状类
```
---

## 🚀 快速开始

### Hello World

```gdscript
extends Node2D

func _ready():
	# 创建一个自身旋转的星星（不填充，只有轮廓）
	var star = ShapeDrawer.create_shape(
		Vector2(400, 300),              # 位置
		ShapeInstance.ShapeType.STAR,   # 形状
		60.0,                           # 大小
		Color.GOLD,                     # 颜色
		false                           # 不填充（默认）
	)
	
	# 设置轮廓
	star.set_outline_width(3.0)
	
	# 添加自身旋转动画（围绕重心旋转）
	star.self_rotate_by(TAU, 2.0).set_loops(-1)
```

### 链式调用

```gdscript
# 创建复杂动画
var shape = ShapeDrawer.create_shape(pos, type, 50.0, Color.CYAN, false)

# 自身旋转（围绕重心）
shape.self_rotate_by(TAU, 2.0).set_loops(-1)

# 同时脉动
shape.scale_to(70.0, 1.0).scale_to(50.0, 1.0).set_loops(-1).set_parallel()

# 同时闪烁
shape.fade_to(0.3, 1.0).fade_to(1.0, 1.0).set_loops(-1).set_parallel()

# 设置轮廓样式
shape.set_outline_width(3.0).set_outline_color(Color.CYAN)
```

### 填充控制示例

```gdscript
extends Node2D

func _ready():
	var center = get_viewport_rect().size / 2
	
	# 不填充的形状（只有轮廓）- 默认
	var outline_star = ShapeDrawer.create_shape(
		center - Vector2(100, 0),
		ShapeInstance.ShapeType.STAR,
		60.0,
		Color.CYAN,
		false  # 不填充
	)
	outline_star.set_outline_width(3.0)
	outline_star.self_rotate_by(TAU, 2.0).set_loops(-1)
	
	# 填充的形状
	var filled_star = ShapeDrawer.create_shape(
		center + Vector2(100, 0),
		ShapeInstance.ShapeType.STAR,
		60.0,
		Color.MAGENTA,
		true  # 填充
	)
	filled_star.self_rotate_by(TAU, 2.0).set_loops(-1)
```

---

## 📖 API 参考

### ShapeDrawer（全局单例）

#### 基础创建

```gdscript
# 创建形状（新增 filled 参数）
create_shape(position: Vector2, type: ShapeType, size: float, color: Color, filled: bool = false) -> ShapeInstance

# 在节点位置创建
create_shape_at_node(node: Node2D, type: ShapeType, size: float, color: Color, filled: bool = false) -> ShapeInstance

# 创建自定义顶点形状
create_custom_shape(position: Vector2, vertices: PackedVector2Array, color: Color, filled: bool = false) -> ShapeInstance

# 创建N边正多边形
create_polygon(position: Vector2, sides: int, size: float, color: Color, filled: bool = false) -> ShapeInstance
```

#### 便捷预设

```gdscript
# 旋转形状
create_rotating_shape(position: Vector2, type: ShapeType, size: float, color: Color, speed: float, clockwise: bool) -> ShapeInstance

# 脉动形状
create_pulsing_shape(position: Vector2, type: ShapeType, size: float, color: Color, scale_factor: float, speed: float) -> ShapeInstance

# 闪烁形状
create_blinking_shape(position: Vector2, type: ShapeType, size: float, color: Color, min_opacity: float, speed: float) -> ShapeInstance

# 彩虹渐变
create_rainbow_shape(position: Vector2, type: ShapeType, size: float, speed: float) -> ShapeInstance

# 轨道运行（行星效果）
create_orbiting_shape(center: Vector2, radius: float, type: ShapeType, size: float, color: Color, speed: float, clockwise: bool) -> ShapeInstance

# 螺旋形状
create_spiral_shape(start_pos: Vector2, type: ShapeType, size: float, color: Color, turns: int, radius: float, duration: float) -> ShapeInstance
```

#### 复杂预设

```gdscript
# 魔法阵
create_magic_circle(center: Vector2, radius: float, layers: int, complexity: int) -> Array[ShapeInstance]

# 粒子爆发
create_particle_burst(center: Vector2, particle_count: int, max_radius: float, duration: float, colors: Array) -> Array[ShapeInstance]

# 波纹效果
create_ripple(center: Vector2, max_radius: float, wave_count: int, duration: float, color: Color) -> Array[ShapeInstance]

# 行星系统
create_planet_system(center: Vector2, planet_count: int, orbit_radius_start: float, orbit_spacing: float) -> Array[ShapeInstance]

# 螺旋星系
create_spiral_galaxy(center: Vector2, arms: int, particles_per_arm: int, max_radius: float) -> Array[ShapeInstance]
```

#### 管理方法

```gdscript
# 清除所有形状
clear_all()

# 移除指定形状
remove_shape(shape: ShapeInstance)

# 获取形状数量
get_shape_count() -> int

# 查找特定类型的形状
find_shapes_by_type(type: ShapeType) -> Array[ShapeInstance]

# 获取性能统计
get_performance_stats() -> Dictionary

# 打印调试信息
print_debug_info()
```

### ShapeInstance（形状实例）

#### 基础动画

```gdscript
# 位置旋转（整体旋转）
rotate_by(angle: float, duration: float, ease: EaseType) -> ShapeInstance
rotate_to(target_angle: float, duration: float, ease: EaseType) -> ShapeInstance

# 🆕 自身旋转（围绕重心旋转）
self_rotate_by(angle: float, duration: float, ease: EaseType) -> ShapeInstance
self_rotate_to(target_angle: float, duration: float, ease: EaseType) -> ShapeInstance

# 缩放
scale_to(target_size: float, duration: float, ease: EaseType) -> ShapeInstance
scale_x_to(target: float, duration: float, ease: EaseType) -> ShapeInstance
scale_y_to(target: float, duration: float, ease: EaseType) -> ShapeInstance

# 移动
move_to(target_position: Vector2, duration: float, ease: EaseType) -> ShapeInstance
move_along_path(points: Array, duration: float, ease: EaseType) -> ShapeInstance
move_bezier(control1: Vector2, control2: Vector2, end: Vector2, duration: float) -> ShapeInstance

# 颜色和透明度
color_to(target_color: Color, duration: float, ease: EaseType) -> ShapeInstance
fade_to(target_opacity: float, duration: float, ease: EaseType) -> ShapeInstance

# 变形
skew_to(x: float, y: float, duration: float, ease: EaseType) -> ShapeInstance
```

#### 高级动画

```gdscript
# 轨道运动（行星效果）
orbit_around(center: Vector2, radius: float, angle_speed: float, duration: float, ease: EaseType) -> ShapeInstance
```

#### 控制选项

```gdscript
# 设置循环（-1 = 无限）
set_loops(loop_count: int) -> ShapeInstance

# 设置延迟
set_delay(delay_time: float) -> ShapeInstance

# 设置并行执行
set_parallel() -> ShapeInstance

# 完成回调
on_complete(callback: Callable) -> ShapeInstance
```

#### 自定义

```gdscript
# 设置自定义顶点
set_custom_vertices(vertices: PackedVector2Array) -> ShapeInstance

# 设置多边形边数
set_polygon_sides(sides: int) -> ShapeInstance

# 🆕 填充控制
set_filled(is_filled: bool) -> ShapeInstance
set_outline_width(width: float) -> ShapeInstance
set_outline_color(color: Color) -> ShapeInstance
```

---

## 💡 使用示例

### 示例 1: 魔法阵

```gdscript
extends Node2D

func _ready():
	var center = get_viewport_rect().size / 2
	
	# 一键创建绚丽魔法阵
	ShapeDrawer.create_magic_circle(center, 250.0, 3, 2)
	
	print("按 C 键清除")
	print("点击鼠标创建新形状")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		ShapeDrawer.clear_all()
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var shape = ShapeDrawer.create_rotating_shape(
				event.position,
				ShapeInstance.ShapeType.STAR,
				40.0,
				Color.from_hsv(randf(), 1.0, 1.0),
				2.0
			)
			shape.fade_to(0.0, 3.0)  # 3秒后消失
```

### 示例 2: 行星系统（自转+公转）

```gdscript
func create_solar_system():
	var center = get_viewport_rect().size / 2
	
	# 创建太阳
	var sun = ShapeDrawer.create_pulsing_shape(
		center,
		ShapeInstance.ShapeType.STAR,
		70.0,
		Color.YELLOW,
		1.3,
		0.5,
		true  # 填充
	)
	
	# 创建行星（公转+自转）
	for i in range(5):
		var radius = 120.0 + i * 60.0
		var speed = 1.0 / (1.0 + i * 0.3)
		
		var planet = ShapeDrawer.create_orbiting_shape(
			center,
			radius,
			ShapeInstance.ShapeType.HEXAGON,
			15.0 + i * 3.0,
			Color.from_hsv(float(i) / 5.0, 0.7, 1.0),
			speed,
			true,
			false  # 不填充
		)
		planet.set_outline_width(2.5)
		
		# 行星自转（围绕自己的重心旋转）
		planet.self_rotate_by(TAU, 2.0).set_loops(-1).set_parallel()
```

### 示例 3: 粒子爆发

```gdscript
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# 鼠标右键触发粒子爆发
			ShapeDrawer.create_particle_burst(
				event.position,
				30,      # 30个粒子
				200.0,   # 最大半径
				2.0,     # 持续2秒
				[]       # 使用默认彩虹色
			)
```

### 示例 4: 自定义形状

```gdscript
func create_custom_lightning():
	# 定义闪电形状的顶点
	var vertices = PackedVector2Array([
		Vector2(0, -100),
		Vector2(10, -60),
		Vector2(-5, -60),
		Vector2(15, -20),
		Vector2(-10, -20),
		Vector2(5, 20),
		Vector2(-15, 20),
		Vector2(0, 100)
	])
	
	var lightning = ShapeDrawer.create_custom_shape(
		Vector2(400, 300),
		vertices,
		Color.CYAN
	)
	
	# 闪烁效果
	lightning.fade_to(1.0, 0.05)\
		.fade_to(0.0, 0.05)\
		.fade_to(1.0, 0.05)\
		.fade_to(0.0, 0.1)
```

### 示例 5: 复杂动画链

```gdscript
func create_complex_animation():
	var shape = ShapeDrawer.create_shape(
		Vector2(100, 300),
		ShapeInstance.ShapeType.STAR,
		40.0,
		Color.GOLD
	)
	
	# 顺序执行的复杂动画
	shape.move_to(Vector2(700, 300), 2.0, ShapeInstance.EaseType.EASE_IN_OUT)\
		.rotate_by(TAU * 2, 2.0, ShapeInstance.EaseType.ELASTIC_OUT)\
		.color_to(Color.RED, 1.0)\
		.scale_to(80.0, 0.5, ShapeInstance.EaseType.BOUNCE_OUT)\
		.scale_to(40.0, 0.5)\
		.fade_to(0.0, 1.0)\
		.set_loops(3)  # 重复3次
	
	# 并行执行的旋转
	shape.rotate_by(TAU, 10.0).set_loops(-1).set_parallel()
```

---

## 🎮 交互控制示例

```gdscript
extends Node2D

var demo_active: bool = false

func _ready():
	print("按键说明:")
	print("  SPACE - 创建/清除魔法阵")
	print("  R - 创建随机形状")
	print("  P - 创建行星系统")
	print("  C - 清除所有")

func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
	
	var center = get_viewport_rect().size / 2
	
	match event.keycode:
		KEY_SPACE:
			if demo_active:
				ShapeDrawer.clear_all()
				demo_active = false
			else:
				ShapeDrawer.create_magic_circle(center, 250.0, 3)
				demo_active = true
		
		KEY_R:
			var types = [
				ShapeInstance.ShapeType.TRIANGLE,
				ShapeInstance.ShapeType.SQUARE,
				ShapeInstance.ShapeType.STAR,
				ShapeInstance.ShapeType.HEART
			]
			ShapeDrawer.create_rotating_shape(
				center + Vector2(randf_range(-200, 200), randf_range(-200, 200)),
				types[randi() % types.size()],
				randf_range(30, 60),
				Color.from_hsv(randf(), 1.0, 1.0),
				randf_range(0.5, 2.0)
			)
		
		KEY_P:
			ShapeDrawer.create_planet_system(center, 5, 100.0, 60.0)
		
		KEY_C:
			ShapeDrawer.clear_all()
			demo_active = false
```

---

## ⚙️ 配置和优化

### 性能配置

```gdscript
# 在 shape_drawer.gd 中修改常量
const MAX_SHAPES = 500              # 最大形状数量
const ENABLE_OBJECT_POOL = true     # 启用对象池

# 运行时调整
ShapeDrawer.set_batch_draw(true)    # 批量绘制
ShapeDrawer.set_culling(true)       # 视锥剔除
ShapeDrawer.set_canvas_layer(100)   # 设置层级
```

### 性能监控

```gdscript
# 获取性能统计
var stats = ShapeDrawer.get_performance_stats()
print("形状数: %d" % stats.shape_count)
print("更新耗时: %.2f ms" % stats.update_time_ms)
print("绘制耗时: %.2f ms" % stats.draw_time_ms)

# 或直接打印
ShapeDrawer.print_debug_info()
```

---

## 🔧 扩展开发

插件设计为高度可扩展：

1. **添加新形状** - 在 `ShapeType` 枚举中添加，实现顶点生成函数
2. **添加新动画** - 在 `_update_single_animation()` 中添加 case
3. **添加新缓动** - 在 `_apply_easing()` 中实现
4. **创建预设** - 在 `shape_drawer.gd` 中添加便捷方法

详见 **扩展开发指南**。

---

## 📊 性能指标

- **最大形状数**: 500（可配置）
- **推荐同屏**: <100 个形状
- **更新开销**: ~0.1-0.5ms（100形状）
- **绘制开销**: ~0.5-2ms（100形状）
- **内存占用**: ~10KB/形状（对象池）

---

## 🐛 故障排除

| 问题 | 解决方案 |
|------|---------|
| 看不到形状 | 确认插件已启用，位置在屏幕内 |
| 动画卡顿 | 减少形状数量，启用视锥剔除 |
| ShapeDrawer未定义 | 重启Godot编辑器 |
| 性能问题 | 查看性能统计，优化动画数量 |

---

## 📝 更新日志

### v1.1.0 (最新)
- 🆕 添加自身旋转动画 (`self_rotate_by` / `self_rotate_to`)
- 🆕 默认不填充，只显示轮廓
- 🆕 填充控制 API (`set_filled`, `set_outline_width`, `set_outline_color`)
- 🔧 修复三角剖分错误
- 🔧 改进多边形有效性检查
- ⚡ 优化绘制性能

### v1.0.0
- ✓ 20+ 种形状类型
- ✓ 10+ 种动画效果
- ✓ 10 种缓动函数
- ✓ 对象池优化
- ✓ 视锥剔除
- ✓ 完整API文档

---

## 📄 许可证

MIT License - 自由使用和修改

---

## 🤝 贡献

欢迎提交 Issues 和 Pull Requests！

---

**开始创造令人惊叹的视觉效果吧！** ✨🎨
