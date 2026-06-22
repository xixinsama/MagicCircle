# MagicCircle v2.0 — 修订架构 (Phase 1 核心)

> **关键发现:** Godot 的 Node2D/CanvasItem 已经提供了 Manim Mobject 中 80% 的基础能力。
> 修正后的架构不应重复造轮子，而是继承 Godot 原生能力，只构建 Manim 风格的动画编排层。

---

## 1. Godot 已提供的能力 (不需要我们构建)

### 1.1 Node2D 提供的 transform 系统
```
position: Vector2        ← Manim Mobject.shift()
rotation: float          ← Manim Mobject.rotate()
scale: Vector2           ← Manim Mobject.scale()
skew: float
transform: Transform2D   ← Manim Mobject 的完整变换矩阵
global_position          ← 全局坐标
global_transform         ← 全局变换

方法: translate(), rotate(), apply_scale(), look_at(),
      move_local_x(), move_local_y(), to_global(), to_local()
```

### 1.2 CanvasItem 提供的渲染系统
```
visible: bool            ← show/hide
modulate: Color          ← 颜色调制（影响所有子节点）
self_modulate: Color     ← 仅自身颜色调制
z_index: int             ← 绘制顺序
show_behind_parent: bool
material: Material       ← 自定义 shader
light_mask: int

绘制 (_draw 回调内):
  draw_colored_polygon() draw_polygon() draw_line()
  draw_multiline()       draw_polyline()  draw_dashed_line()
  draw_circle()          draw_arc()       draw_ellipse()
  draw_rect()            draw_ellipse_arc()
  draw_set_transform()   draw_set_transform_matrix()

信号: draw — 可连接此信号在外部添加绘制逻辑
```

### 1.3 Node 提供的场景树 (替代 Manim 的 family)
```
add_child() / remove_child()       ← submobjects 层级
get_children()                      ← get_family()
get_parent()
get_tree()                          ← 访问 SceneTree
queue_redraw()                      ← 触发重绘
_process() / _physics_process()    ← updater 每帧回调
```

### 1.4 Curve2D — 贝塞尔曲线
```
add_point(pos, in, out)             ← 添加控制点
sample_baked(offset)                ← 均匀采样
get_baked_points()                  ← 获取 baked 折线点
get_baked_length()                  ← 曲线总长度
tessellate(max_stages, tolerance)  ← 自适应细分
samplef(fofs)                       ← 按比例采样 (0.0~1.0)
```

### 1.5 Transform2D — 矩阵运算
```
interpolate_with(xform, weight)     ← 最关键！变换插值
translated(offset) / rotated(angle) / scaled(scale)
inverse() / affine_inverse()
```

### 1.6 Tween — 动画引擎
```
create_tween()                      ← 创建 Tween
tween_property(obj, prop, val, dur) ← 属性动画
tween_method(callable, from, to, dur) ← 方法回调动画
tween_callback(callable)            ← 完成回调
tween_interval(time)                ← 等待
set_parallel() / set_loops()       ← 并行/循环
set_trans(trans_type) / set_ease(ease_type)
chain()                             ← 顺序链
```

---

## 2. 修正后的架构总览

```
┌──────────────────────────────────────────────────────────┐
│                    🎬 用户 API                            │
│                                                          │
│  class MyScene extends MagicScene:                       │
│    func construct():                                     │
│      var c = CircleMobject.new(50.0)                     │
│      c.position = Vector2(400, 300)                      │
│      add(c)                                              │
│      play(c.animate.scale_to(2.0).fade_out(), 2.0)      │
│      play(FadeIn.from(c), 1.0)                           │
└──────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────┐
│               🎯 插件构建的层次 (3个核心类)                │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  MagicMobject (extends Node2D)                    │   │
│  │  = 形状数据 + _draw() + 动画辅助 + .animate       │   │
│  │                                                   │   │
│  │  继承获得: position, rotation, scale,             │   │
│  │           visible, modulate, z_index,             │   │
│  │           transform, queue_redraw, _process       │   │
│  │                                                   │   │
│  │  新增:                                            │   │
│  │    - fill_color / fill_opacity                    │   │
│  │    - stroke_color / stroke_width                  │   │
│  │    - _build_shape() → 子类重写                    │   │
│  │    - .animate → PropertyAnimator                  │   │
│  │    - copy() / snapshot() / apply_snapshot()       │   │
│  │    - add_updater() / remove_updater()             │   │
│  └────────────────────┬─────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼─────────────────────────────┐   │
│  │  MagicAnimation (extends RefCounted)              │   │
│  │  = 动画编排 + rate_func + lag_ratio               │   │
│  │                                                   │   │
│  │  底层驱动: Godot Tween                             │   │
│  │  上层封装: Manim 风格的 Animation 抽象              │   │
│  │                                                   │   │
│  │  方法:                                             │   │
│  │    - begin() / interpolate(alpha) / finish()      │   │
│  │    - run_time / rate_func / lag_ratio             │   │
│  │    - play_on(scene) → 启动 Tween 驱动              │   │
│  └────────────────────┬─────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼─────────────────────────────┐   │
│  │  MagicScene (extends Node2D)                      │   │
│  │  = 场景管理 + play() 编排                          │   │
│  │                                                   │   │
│  │  方法:                                             │   │
│  │    - construct() → 用户重写                       │   │
│  │    - add(mob) / remove(mob)                       │   │
│  │    - play(anim_or_mob, duration, rate_func)       │   │
│  │    - wait(duration)                               │   │
│  │    - clear()                                      │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────┐
│                 🔧 Godot 原生层                            │
│  Node2D.transform    Tween    CanvasItem._draw()         │
│  Curve2D             Camera2D   Transform2D.interp()     │
└──────────────────────────────────────────────────────────┘
```

---

## 3. 核心类详细设计

### 3.1 MagicMobject (extends Node2D)

```gdscript
@tool
class_name MagicMobject
extends Node2D

## 所有视觉对象的基类
## 继承 Node2D → CanvasItem → Node 的全部能力

# ═══ 视觉样式 (插件新增) ═══
var fill_color: Color = Color.TRANSPARENT    # 填充色 (透明=不填充)
var fill_opacity: float = 1.0
var stroke_color: Color = Color.WHITE       # 描边色
var stroke_width: float = 2.0               # 描边宽
var stroke_opacity: float = 1.0

# ═══ 形状数据 ═══
var _shape_points: PackedVector2Array = []   # 缓存形状顶点

# ═══ 动画支持 ═══
var _updaters: Array[Callable] = []
var _saved_state: Dictionary = {}

# ═══ 生命周期 ═══
func _ready() -> void:
    _shape_points = _build_shape()

func _draw() -> void:
    # 子类可以重写，也可以使用 _shape_points
    _draw_shape_outline(_shape_points, stroke_color * Color(1,1,1,stroke_opacity), stroke_width)
    if fill_color.a > 0:
        _draw_shape_fill(_shape_points, fill_color * Color(1,1,1,fill_opacity))

# ═══ 形状构建 (子类重写) ═══
func _build_shape() -> PackedVector2Array:
    return PackedVector2Array()

# ═══ 绘制辅助 ═══
func _draw_shape_fill(points: PackedVector2Array, color: Color) -> void:
    if points.size() >= 3:
        draw_colored_polygon(points, color)

func _draw_shape_outline(points: PackedVector2Array, color: Color, width: float) -> void:
    if points.size() >= 2 and width > 0:
        draw_polyline(points, color, width, true)  # antialiased

# ═══ 状态快照 (用于 Transform 动画) ═══
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

func apply_snapshot(snap: Dictionary) -> void:
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

func copy() -> MagicMobject:
    var dup = duplicate()  # Node.duplicate()
    return dup

# ═══ Updater 系统 ═══
func add_updater(callback: Callable) -> void:
    _updaters.append(callback)

func remove_updater(callback: Callable) -> void:
    _updaters.erase(callback)

func _process(delta: float) -> void:
    for updater in _updaters:
        updater.call(self, delta)

# ═══ .animate 语法入口 ═══
var animate: PropertyAnimator:
    get:
        return PropertyAnimator.new(self)
```

### 3.2 形状子类示例

```gdscript
# ═══════════════════════════════════
# CircleMobject
# ═══════════════════════════════════
class_name CircleMobject
extends MagicMobject

var radius: float = 50.0:
    set(v):
        radius = v
        _shape_points = _build_shape()
        queue_redraw()

func _init(p_radius: float = 50.0) -> void:
    radius = p_radius

func _build_shape() -> PackedVector2Array:
    # 使用 Godot 原生 draw_circle 更好，但为了
    # 统一到 polygon 管线，生成近似多边形顶点
    var pts = PackedVector2Array()
    var n = 64
    for i in range(n):
        var a = TAU * i / n
        pts.append(Vector2(cos(a), sin(a)) * radius)
    return pts

func _draw() -> void:
    if fill_color.a > 0:
        draw_circle(Vector2.ZERO, radius, fill_color)
    if stroke_width > 0:
        draw_arc(Vector2.ZERO, radius, 0, TAU, 64, stroke_color, stroke_width, true)


# ═══════════════════════════════════
# PolygonMobject (正N边形)
# ═══════════════════════════════════
class_name PolygonMobject
extends MagicMobject

var sides: int = 5:
    set(v):
        sides = max(3, v)
        _shape_points = _build_shape()
        queue_redraw()
var radius: float = 50.0:
    set(v):
        radius = v
        _shape_points = _build_shape()
        queue_redraw()

func _init(p_sides: int = 5, p_radius: float = 50.0) -> void:
    sides = p_sides
    radius = p_radius

func _build_shape() -> PackedVector2Array:
    var pts = PackedVector2Array()
    for i in range(sides):
        var a = TAU * i / sides - PI / 2
        pts.append(Vector2(cos(a), sin(a)) * radius)
    return pts


# ═══════════════════════════════════
# StarMobject
# ═══════════════════════════════════
class_name StarMobject
extends MagicMobject

var points: int = 5
var outer_radius: float = 50.0
var inner_radius: float = 20.0

func _init(p_points: int = 5, p_outer: float = 50.0, p_inner: float = 20.0) -> void:
    points = p_points
    outer_radius = p_outer
    inner_radius = p_inner

func _build_shape() -> PackedVector2Array:
    var pts = PackedVector2Array()
    var n = points * 2
    for i in range(n):
        var a = TAU * i / n - PI / 2
        var r = outer_radius if i % 2 == 0 else inner_radius
        pts.append(Vector2(cos(a), sin(a)) * r)
    return pts


# ═══════════════════════════════════
# BezierMobject (贝塞尔曲线形状)
# ═══════════════════════════════════
class_name BezierMobject
extends MagicMobject

var curve: Curve2D = Curve2D.new()

func _build_shape() -> PackedVector2Array:
    return curve.get_baked_points()

func add_curve_point(pos: Vector2, in_dir: Vector2 = Vector2.ZERO, out_dir: Vector2 = Vector2.ZERO) -> void:
    curve.add_point(pos, in_dir, out_dir)
    _shape_points = curve.get_baked_points()
    queue_redraw()

func sample_at(alpha: float) -> Vector2:
    return curve.samplef(alpha)  # 0.0~1.0 按比例采样
```

### 3.3 MagicAnimation (动画基类)

```gdscript
class_name MagicAnimation
extends RefCounted

## 动画抽象基类
## 封装 Godot Tween，提供 Manim 风格的动画控制

# ═══ 时间控制 ═══
var run_time: float = 1.0
var rate_func: Callable = RateFunctions.linear
var lag_ratio: float = 0.0    # 子对象错开 (0=同时, 1=顺序)
var remover: bool = false

# ═══ 内部 ═══
var _mobject: MagicMobject
var _family: Array[MagicMobject] = []
var _start_snapshots: Array[Dictionary] = []
var _tween: Tween = null

func _init(mobject: MagicMobject, duration: float = 1.0) -> void:
    _mobject = mobject
    run_time = duration
    _family = _collect_family(mobject)

func _collect_family(mob: MagicMobject) -> Array[MagicMobject]:
    var result: Array[MagicMobject] = [mob]
    for child in mob.get_children():
        if child is MagicMobject:
            result.append_array(_collect_family(child))
    return result

# ═══ 子类重写 ═══
func begin() -> void:
    _start_snapshots.clear()
    for mob in _family:
        _start_snapshots.append(mob.snapshot())

func interpolate_submobject(index: int, alpha: float) -> void:
    pass  # 子类实现

func finish() -> void:
    if remover and _mobject:
        _mobject.queue_free()

# ═══ Tween 集成 ═══
func play_on(scene: MagicScene) -> void:
    begin()
    _tween = scene.create_tween()

    # 对每个 family 成员应用 lag_ratio
    for i in range(_family.size()):
        var sub_tween = _tween
        if lag_ratio > 0:
            var delay = lag_ratio * run_time * float(i) / max(1, _family.size() - 1)
            sub_tween = _tween.set_delay(delay)

        # 使用 tween_method 驱动 interpolate
        var sub_run_time = run_time * (1.0 - lag_ratio) if lag_ratio > 0 else run_time
        sub_tween.tween_method(
            func(alpha: float):
                var effective_alpha = rate_func.call(alpha)
                interpolate_submobject(i, effective_alpha)
                for mob in _family:
                    mob.queue_redraw()
            ,
            0.0, 1.0, sub_run_time
        )

    _tween.tween_callback(func(): finish())
```

### 3.4 具体动画类

```gdscript
# ═══════════════════════════════════
# TransformAnimation (核心!)
# 从一个状态快照插值到当前状态
# ═══════════════════════════════════
class_name TransformAnimation
extends MagicAnimation

var _target_snapshots: Array[Dictionary] = []

func _init(mobject: MagicMobject, target_mobject: MagicMobject = null, duration: float = 1.0) -> void:
    super._init(mobject, duration)
    if target_mobject:
        for mob in _collect_family(target_mobject):
            _target_snapshots.append(mob.snapshot())

func begin() -> void:
    super.begin()
    # 如果没有 target，用当前状态作为 target (配合 .animate)
    if _target_snapshots.is_empty():
        for mob in _family:
            _target_snapshots.append(mob.snapshot())

func interpolate_submobject(index: int, alpha: float) -> void:
    if index >= _family.size() or index >= _start_snapshots.size():
        return

    var mob = _family[index]
    var start = _start_snapshots[index]
    var target: Dictionary

    if index < _target_snapshots.size():
        target = _target_snapshots[index]
    else:
        target = start  # fallback: no change

    # 逐属性插值
    mob.position = start.position.lerp(target.position, alpha)
    mob.rotation = lerp(start.rotation, target.rotation, alpha)
    mob.scale = start.scale.lerp(target.scale, alpha)
    mob.skew = lerp(start.skew, target.skew, alpha)
    mob.modulate = start.modulate.lerp(target.modulate, alpha)
    mob.self_modulate = start.self_modulate.lerp(target.self_modulate, alpha)
    mob.fill_color = start.fill_color.lerp(target.fill_color, alpha)
    mob.fill_opacity = lerp(start.fill_opacity, target.fill_opacity, alpha)
    mob.stroke_color = start.stroke_color.lerp(target.stroke_color, alpha)
    mob.stroke_width = lerp(start.stroke_width, target.stroke_width, alpha)
    mob.stroke_opacity = lerp(start.stroke_opacity, target.stroke_opacity, alpha)


# ═══════════════════════════════════
# FadeInAnimation
# ═══════════════════════════════════
class_name FadeInAnimation
extends MagicAnimation

func interpolate_submobject(index: int, alpha: float) -> void:
    var mob = _family[index]
    var start = _start_snapshots[index]
    mob.modulate = start.modulate
    mob.modulate.a = lerp(0.0, start.modulate.a, alpha)
    mob.self_modulate = start.self_modulate
    mob.self_modulate.a = lerp(0.0, start.self_modulate.a, alpha)

# ═══════════════════════════════════
# FadeOutAnimation
# ═══════════════════════════════════
class_name FadeOutAnimation
extends MagicAnimation

func interpolate_submobject(index: int, alpha: float) -> void:
    var mob = _family[index]
    var start = _start_snapshots[index]
    mob.modulate = start.modulate
    mob.modulate.a = lerp(start.modulate.a, 0.0, alpha)
    mob.self_modulate = start.self_modulate
    mob.self_modulate.a = lerp(start.self_modulate.a, 0.0, alpha)


# ═══════════════════════════════════
# GrowFromCenterAnimation
# ═══════════════════════════════════
class_name GrowFromCenterAnimation
extends MagicAnimation

var _center: Vector2

func _init(mobject: MagicMobject, center: Vector2 = Vector2.ZERO, duration: float = 1.0) -> void:
    super._init(mobject, duration)
    _center = center

func interpolate_submobject(index: int, alpha: float) -> void:
    var mob = _family[index]
    var start = _start_snapshots[index]
    mob.position = _center.lerp(start.position, alpha)
    mob.scale = Vector2.ONE * alpha * start.scale


# ═══════════════════════════════════
# WriteAnimation (描边写出 - 贝塞尔专用)
# ═══════════════════════════════════
class_name WriteAnimation
extends MagicAnimation

func interpolate_submobject(index: int, alpha: float) -> void:
    var mob = _family[index]
    if mob is BezierMobject:
        # 逐渐增加描边不透明度来模拟"写出"
        mob.stroke_opacity = alpha
        # 高级: 修改 shape_points 只包含部分曲线
    else:
        # 对其他形状: 整体淡入
        mob.modulate.a = alpha
```

### 3.5 PropertyAnimator (.animate 语法)

```gdscript
class_name PropertyAnimator
extends RefCounted

## 记录方法调用链，play() 时生成 TransformAnimation

var _mobject: MagicMobject
var _method_calls: Array[Dictionary] = []

func _init(mobject: MagicMobject) -> void:
    _mobject = mobject

# ═══ 链式方法 (每个返回 self) ═══
func shift(offset: Vector2) -> PropertyAnimator:
    _method_calls.append({"method": "position", "args": [offset], "op": "add"})
    return self

func move_to(pos: Vector2) -> PropertyAnimator:
    _method_calls.append({"method": "position", "args": [pos], "op": "set"})
    return self

func rotate(angle: float) -> PropertyAnimator:
    _method_calls.append({"method": "rotation", "args": [angle], "op": "add"})
    return self

func scale_to(factor) -> PropertyAnimator:
    var v = factor if factor is Vector2 else Vector2(factor, factor)
    _method_calls.append({"method": "scale", "args": [v], "op": "set"})
    return self

func set_fill(color: Color, opacity: float = 1.0) -> PropertyAnimator:
    _method_calls.append({"method": "fill_color", "args": [color], "op": "set"})
    _method_calls.append({"method": "fill_opacity", "args": [opacity], "op": "set"})
    return self

func set_stroke(color: Color, width: float = 2.0) -> PropertyAnimator:
    _method_calls.append({"method": "stroke_color", "args": [color], "op": "set"})
    _method_calls.append({"method": "stroke_width", "args": [width], "op": "set"})
    return self

func fade_in() -> PropertyAnimator:
    _method_calls.append({"method": "modulate", "args": [Color.WHITE], "op": "set"})
    return self

func fade_out() -> PropertyAnimator:
    _method_calls.append({"method": "modulate", "args": [Color.TRANSPARENT], "op": "set"})
    return self

# ═══ 生成动画 ═══
func to_animation() -> TransformAnimation:
    # 1. 复制原始 mobject
    var start_copy = _mobject.duplicate()  # Node.duplicate() handles children

    # 2. 在原始上应用所有方法调用 (这是目标状态)
    for call in _method_calls:
        match call["op"]:
            "add":
                var prop = _mobject.get(call["method"])
                _mobject.set(call["method"], prop + call["args"][0])
            "set":
                _mobject.set(call["method"], call["args"][0])

    # 3. 创建 Transform 动画: start_copy(原始) → _mobject(目标)
    #    注意: 这里的概念是 Transform 让 show_target=true
    #    用户看到的是 _mobject 从 start_copy 的状态变到 _mobject 当前的状态

    var anim = TransformAnimation.new(_mobject)  # _mobject 已经被修改了
    anim._start_snapshots = [start_copy.snapshot()]  # 起始状态来自 copy
    # target 就是 _mobject 当前状态 (已在上面修改)
    return anim
```

### 3.6 MagicScene

```gdscript
class_name MagicScene
extends Node2D

## Scene 基类 — 用户继承并重写 construct()
## 负责管理所有 MagicMobject 并驱动动画

func _ready() -> void:
    await get_tree().process_frame
    construct()

func construct() -> void:
    pass  # 用户重写

# ═══ 对象管理 ═══
func add(mobject: MagicMobject) -> MagicMobject:
    add_child(mobject)
    return mobject

func remove(mobject: MagicMobject) -> void:
    if mobject.get_parent() == self:
        remove_child(mobject)

func clear() -> void:
    for child in get_children():
        if child is MagicMobject:
            child.queue_free()

# ═══ 动画播放 ═══
func play(animation_or_mob, duration: float = 1.0, rate_func = null) -> void:
    var animation: MagicAnimation

    if animation_or_mob is MagicAnimation:
        animation = animation_or_mob
    elif animation_or_mob is PropertyAnimator:
        animation = animation_or_mob.to_animation()
    elif animation_or_mob is MagicMobject:
        animation = TransformAnimation.new(animation_or_mob, animation_or_mob, duration)

    if rate_func:
        animation.rate_func = rate_func
    if duration != 1.0:
        animation.run_time = duration

    animation.play_on(self)
    await get_tree().create_timer(animation.run_time + 0.05).timeout

func wait(duration: float = 1.0) -> void:
    await get_tree().create_timer(duration).timeout
```

### 3.7 RateFunctions

```gdscript
class_name RateFunctions
extends RefCounted

## 15+ 种速率函数 (对标 Manim 的 rate_func)

static func linear(t: float) -> float:
    return clamp(t, 0.0, 1.0)

static func smooth(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

static func smoother(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)

static func there_and_back(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    return smooth(1.0 - abs(2.0 * t - 1.0))

static func running_start(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    return pow(t, 0.3)

static func rush_into(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    return 2.0 * t - t * t

static func rush_from(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    return t * t

static func ease_in_sine(t: float) -> float:
    return 1.0 - cos(t * PI / 2.0)

static func ease_out_sine(t: float) -> float:
    return sin(t * PI / 2.0)

static func ease_in_out_sine(t: float) -> float:
    return -(cos(PI * t) - 1.0) / 2.0

static func ease_in_quad(t: float) -> float:
    return t * t

static func ease_out_quad(t: float) -> float:
    return t * (2.0 - t)

static func ease_in_cubic(t: float) -> float:
    return t * t * t

static func ease_out_cubic(t: float) -> float:
    var f = t - 1.0
    return f * f * f + 1.0

static func ease_in_back(t: float) -> float:
    var c1 = 1.70158
    return (c1 + 1.0) * t * t * t - c1 * t * t

static func ease_out_back(t: float) -> float:
    var c1 = 1.70158
    var f = t - 1.0
    return 1.0 + (c1 + 1.0) * f * f * f + c1 * f * f

static func ease_out_bounce(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    if t < 4.0 / 11.0:
        return 121.0 * t * t / 16.0
    elif t < 8.0 / 11.0:
        return (363.0 / 40.0 * t * t) - (99.0 / 10.0 * t) + 17.0 / 5.0
    elif t < 9.0 / 10.0:
        return (4356.0 / 361.0 * t * t) - (35442.0 / 1805.0 * t) + 16061.0 / 1805.0
    else:
        return (54.0 / 5.0 * t * t) - (513.0 / 25.0 * t) + 268.0 / 25.0

static func ease_out_elastic(t: float) -> float:
    t = clamp(t, 0.0, 1.0)
    if t == 0.0 or t == 1.0:
        return t
    return pow(2.0, -10.0 * t) * sin((t - 0.075) * TAU / 0.3) + 1.0
```

---

## 4. 与旧架构的关键变更对比

| 决策 | v1 提案 | v2 修正 | 理由 |
|------|---------|---------|------|
| Mobject 基类 | RefCounted | **Node2D** | 免费获得 transform/visible/z_index/scene_tree |
| 属性管理 | 自己维护 position/rotation/scale | **继承 Node2D 属性** | 避免重复维护，且与 Tween/Camera 互通 |
| 贝塞尔系统 | 自己封装 Curve2D | **直接使用 Curve2D** | Curve2D 已满足需求 (samplef, tessellate) |
| 变换插值 | 逐属性 lerp | **可选用 Transform2D.interpolate_with()** | Godot 原生支持 |
| 动画引擎 | 自建 Tween 包装 | **直接使用 Godot Tween** | Tween 已提供所有需要的底层能力 |
| 绘制 | 手动 polygon 生成 | **用原生 draw_circle/draw_ellipse/draw_arc** | 性能更好，代码更少 |
| 渲染器 | 独立 MagicRenderer | **不需要! Node2D._draw() 自己处理** | Godot 自动管理 |
| 文本系统 | TextMobject | **不需要! 用户用 Label/rich_text** | Godot 已有完整文本系统 |
| 摄像机 | 自定义 | **用 Camera2D 即可** | 无需重复 |
| 颜色调制 | color + opacity 属性 | **用 modulate/self_modulate** | CanvasItem 原生支持 |
| 层级系统 | submobjects 列表 | **用 add_child/get_children** | 场景树就是层级树 |
| Family 遍历 | 递归遍历 submobjects | **Node 已递归处理** | queue_redraw 等自动传播 |

---

## 5. Phase 1 文件结构 (仅核心)

```
addons/magic_circle/
│
├── plugin.cfg                     # [修改] 插件配置
├── plugin.gd                      # [修改] EditorPlugin → 注册 MagicSceneRunner
│
├── core/
│   ├── magic_mobject.gd           # [新建] MagicMobject 基类 (extends Node2D)
│   ├── rate_functions.gd          # [新建] RateFunctions 库
│   │
│   └── shapes/                    # [新建] 预定义形状
│       ├── circle_mobject.gd      #   Circle
│       ├── polygon_mobject.gd     #   Polygon, Triangle, Square, Pentagon...
│       ├── star_mobject.gd        #   Star (5/6/8-point)
│       ├── bezier_mobject.gd      #   Bezier curve shape
│       └── custom_mobject.gd      #   Custom vertex shape
│
├── animation/
│   ├── magic_animation.gd         # [新建] Animation 基类
│   ├── transform_animation.gd     # [新建] Transform (=property interpolation)
│   ├── fade_animation.gd          # [新建] FadeIn, FadeOut
│   ├── creation_animation.gd      # [新建] GrowFromCenter, ShrinkToCenter
│   ├── property_animator.gd       # [新建] .animate 语法
│   └── animation_group.gd         # [新建] AnimationGroup (parallel/sequential)
│
├── scene/
│   └── magic_scene.gd             # [新建] MagicScene (extends Node2D)
│
├── presets/                       # [迁移] 基于新架构重写
│   ├── magic_circles.gd           #   魔法阵预设
│   ├── particle_systems.gd        #   粒子效果预设
│   └── planetary.gd               #   行星/星系预设
│
└── demo/                          # [重写] 新 API 演示
    ├── basic_shapes.gd
    ├── animations.gd
    ├── transforms.gd
    └── magic_demo.gd
```

**删除的文件 (从旧架构):**
- ~~shape_drawer.gd~~ → 功能拆分到 MagicScene + MagicMobject
- ~~shape_instance.gd~~ → 被 MagicMobject 替代

---

## 6. Phase 1 实施清单

### P1.1: 基础设施 (1 天)
- [ ] `plugin.gd` — 修改为注册 MagicScene (仍可用 SceneRunner)
- [ ] `magic_mobject.gd` — MagicMobject 基类 (snapshot, apply_snapshot, copy, updaters, .animate getter)
- [ ] `rate_functions.gd` — 15+ rate functions

### P1.2: 形状系统 (1 天)
- [ ] `circle_mobject.gd` — Circle (用 draw_circle + draw_arc)
- [ ] `polygon_mobject.gd` — Polygon (N-sided), Triangle, Square, Pentagon, Hexagon
- [ ] `star_mobject.gd` — Star (5/6/8 point)
- [ ] `bezier_mobject.gd` — Bezier shape (Curve2D backed)
- [ ] `custom_mobject.gd` — Custom vertex array

### P1.3: 动画系统 (2 天)
- [ ] `magic_animation.gd` — 基类 (begin, interpolate_submobject, finish, play_on with Tween + lag_ratio)
- [ ] `transform_animation.gd` — 属性插值 (核心!)
- [ ] `fade_animation.gd` — FadeIn / FadeOut
- [ ] `creation_animation.gd` — GrowFromCenter / ShrinkToCenter
- [ ] `property_animator.gd` — .animate 语法 (方法链 → Transform)
- [ ] `animation_group.gd` — 并行/顺序组合

### P1.4: Scene 系统 (0.5 天)
- [ ] `magic_scene.gd` — add/remove/play/wait/clear/construct

### P1.5: 预设迁移 (1 天)
- [ ] `magic_circles.gd` — 基于新 API 重写 create_magic_circle
- [ ] `particle_systems.gd` — create_particle_burst, create_ripple
- [ ] `planetary.gd` — create_planet_system, create_spiral_galaxy, create_orbiting_shape

### P1.6: Demo 重写 (0.5 天)
- [ ] `basic_shapes.gd` — 展示所有形状
- [ ] `animations.gd` — 所有动画类型
- [ ] `transforms.gd` — Transform 演示
- [ ] `magic_demo.gd` — 魔法效果总览

---

## 7. Phase 1 用户 API 预览

```gdscript
# ═══════════════════════════════════════════
# 最简单的用法
# ═══════════════════════════════════════════
class MyScene extends MagicScene:
    func construct():
        # 创建圆形
        var circle = CircleMobject.new(50.0)
        circle.fill_color = Color.GOLD
        circle.stroke_color = Color.WHITE
        circle.stroke_width = 3.0
        circle.position = Vector2(400, 300)
        add(circle)  # 添加到场景
        
        # 动画: 旋转 + 淡出
        play(circle.animate.rotate(TAU).fade_out(), 2.0)


# ═══════════════════════════════════════════
# Transform 动画 (Manim 风格)
# ═══════════════════════════════════════════
class TransformDemo extends MagicScene:
    func construct():
        var rect = PolygonMobject.new(4, 40.0)  # 正方形
        rect.fill_color = Color.BLUE
        rect.position = Vector2(200, 300)
        add(rect)
        
        var circle = CircleMobject.new(60.0)      # 圆形
        circle.fill_color = Color.RED
        circle.position = Vector2(600, 300)
        add(circle)
        
        # 正方形变形为圆形 (位置+颜色+形状一起变)
        play(TransformAnimation.new(rect, circle), 2.0,
             RateFunctions.ease_in_out_cubic)
        
        wait(1.0)
        
        # 圆形旋转并淡出
        play(circle.animate.rotate(TAU * 2).fade_out(), 2.5)


# ═══════════════════════════════════════════
# 动画组合 + lag_ratio
# ═══════════════════════════════════════════
class GroupDemo extends MagicScene:
    func construct():
        # 创建10个圆排成一行
        for i in range(10):
            var c = CircleMobject.new(20.0)
            c.fill_color = Color.from_hsv(float(i) / 10, 1.0, 1.0)
            c.position = Vector2(100 + i * 60, 300)
            add(c)
        
        # 错开淡入 (每个在前一个70%时开始)
        var all_circles = get_children().filter(
            func(c): return c is CircleMobject)
        
        var anim = AnimationGroup.new()
        for c in all_circles:
            anim.add(FadeInAnimation.new(c, 1.0))
        anim.lag_ratio = 0.7
        
        play(anim, 2.0)


# ═══════════════════════════════════════════
# 魔法阵 (预设 API)
# ═══════════════════════════════════════════
class MagicDemo extends MagicScene:
    func construct():
        var center = get_viewport_rect().size / 2
        var magic = MagicPresets.create_magic_circle(center, 250.0, 3, 2)
        for mob in magic:
            add(mob)
        
        # 整体淡入
        for mob in magic:
            play(FadeInAnimation.new(mob, 1.5),
                 RateFunctions.ease_out_cubic)
```

---

## 8. 关键设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| Mobject 是 Node2D | ✅ 是 | 免费获得 transform/visible/z_index/scene_tree/Tween |
| 贝塞尔用 Curve2D | ✅ 直接使用 | Godot 已实现完整功能 |
| 动画引擎用 Tween | ✅ 底层用 Tween | Tween 已提供所有基础能力，我们只做高层抽象 |
| _draw() 绘制 | ✅ 用原生方法 | draw_circle/ellipse/rect 比手动 polygon 更快更准确 |
| 文本渲染 | ❌ 不构建 | Godot Label/Font 已完善 |
| LaTeX | ❌ 不构建 | 超出 Phase 1 范围 |
| 3D 支持 | ❌ 不构建 | Phase 1 专注 2D |
| 摄像机系统 | ❌ 不构建 | 用 Camera2D 即可 |
| 对象池 | ⏸ 延迟 | Node 的创建/释放已足够高效 |

---

*修订于 2026-06-21 — 基于 Godot 4.7 (latest) 官方文档验证*
