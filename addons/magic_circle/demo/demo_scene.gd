extends MagicScene

## Phase 1 Core System Demo
## Demonstrates: shapes, fade, transform, grow, .animate syntax, magic circle

func construct() -> void:
	print("=".repeat(50))
	print("Magic Circle v2.0 — Phase 1 Core Demo")
	print("=".repeat(50))

	await demo_1_shapes()
	await wait(1.0)
	clear_all()

	await demo_2_fade()
	await wait(1.0)
	clear_all()

	await demo_3_transform()
	await wait(1.0)
	clear_all()

	await demo_4_grow()
	await wait(1.0)
	clear_all()

	await demo_5_animate()
	await wait(1.0)
	clear_all()

	await demo_6_magic_circle()
	print("=".repeat(50))
	print("Demo complete! All core systems working.")
	print("=".repeat(50))


# ═══════════════════════════════════════════
# Demo 1: All Shape Types
# ═══════════════════════════════════════════
func demo_1_shapes() -> void:
	print("▶ Demo 1: Shape Types")

	var center = Vector2(640, 360)
	var labels = ["Circle", "Triangle", "Square", "Pentagon", "Hexagon", "Star"]
	var colors = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.CYAN, Color.MAGENTA]

	# Circle
	var c = CircleMobject.new(40.0)
	c.position = center + Vector2(-200, -100)
	c.fill_color = Color.RED
	c.fill_opacity = 0.5
	c.stroke_color = Color.RED
	add(c)

	# Triangle
	var t = PolygonMobject.new(3, 45.0)
	t.position = center + Vector2(0, -100)
	t.fill_color = Color.ORANGE
	t.fill_opacity = 0.5
	t.stroke_color = Color.ORANGE
	add(t)

	# Square
	var s = PolygonMobject.new(4, 40.0)
	s.position = center + Vector2(200, -100)
	s.fill_color = Color.YELLOW
	s.fill_opacity = 0.5
	s.stroke_color = Color.YELLOW
	add(s)

	# Pentagon
	var p = PolygonMobject.new(5, 42.0)
	p.position = center + Vector2(-200, 100)
	p.fill_color = Color.GREEN
	p.fill_opacity = 0.5
	p.stroke_color = Color.GREEN
	add(p)

	# Hexagon
	var h = PolygonMobject.new(6, 42.0)
	h.position = center + Vector2(0, 100)
	h.fill_color = Color.CYAN
	h.fill_opacity = 0.5
	h.stroke_color = Color.CYAN
	add(h)

	# Star
	var star = StarMobject.new(5, 45.0, 20.0)
	star.position = center + Vector2(200, 100)
	star.fill_color = Color.MAGENTA
	star.fill_opacity = 0.5
	star.stroke_color = Color.MAGENTA
	add(star)

	await wait(0.3)
	print("  6 shapes displayed")


# ═══════════════════════════════════════════
# Demo 2: Fade In / Fade Out
# ═══════════════════════════════════════════
func demo_2_fade() -> void:
	print("▶ Demo 2: Fade Animations")

	var center = Vector2(640, 360)

	# Create a circle
	var circle = CircleMobject.new(60.0)
	circle.position = center
	circle.fill_color = Color.DODGER_BLUE
	circle.fill_opacity = 0.8
	circle.stroke_color = Color.WHITE
	circle.stroke_width = 3.0
	circle.modulate.a = 0.0  # Start invisible
	add(circle)

	print("   Fading in...")
	await play(FadeInAnimation.new(circle, 1.5))

	print("   Fading out...")
	await play(FadeOutAnimation.new(circle, 1.5))


# ═══════════════════════════════════════════
# Demo 3: Transform (morph between shapes)
# ═══════════════════════════════════════════
func demo_3_transform() -> void:
	print("▶ Demo 3: Transform Animation")

	var center = Vector2(640, 360)

	# Start: Square on the left
	var square = PolygonMobject.new(4, 50.0)
	square.position = Vector2(300, 360)
	square.fill_color = Color.CRIMSON
	square.fill_opacity = 0.9
	square.stroke_color = Color.WHITE
	square.stroke_width = 2.0
	add(square)

	# Target: Circle on the right
	var circle = CircleMobject.new(50.0)
	circle.position = Vector2(900, 360)
	circle.fill_color = Color.ROYAL_BLUE
	circle.fill_opacity = 0.9
	circle.stroke_color = Color.WHITE
	circle.stroke_width = 2.0
	# Don't add target to scene — Transform will show square morphing

	print("   Square morphs into Circle (position + color + shape)...")
	var anim = TransformAnimation.new(square, circle, 2.5)
	anim.rate_func = RateFunctions.ease_in_out_cubic
	await play(anim)

	# Now square looks like circle and is at circle's position
	# Add the real circle and fade the transformed one
	add(circle)
	circle.modulate.a = 0.0
	await play(FadeOutAnimation.new(square, 0.5))
	await play(FadeInAnimation.new(circle, 0.5))

	print("   Transform complete")


# ═══════════════════════════════════════════
# Demo 4: GrowFromCenter / ShrinkToCenter
# ═══════════════════════════════════════════
func demo_4_grow() -> void:
	print("▶ Demo 4: Grow / Shrink Animations")

	var center = Vector2(640, 360)

	# Create a star
	var star = StarMobject.new(5, 60.0, 25.0)
	star.position = center
	star.fill_color = Color.GOLD
	star.fill_opacity = 0.9
	star.stroke_color = Color.ORANGE
	star.stroke_width = 3.0
	add(star)

	print("   Growing from center...")
	await play(GrowFromCenterAnimation.new(star, center, 1.5))

	await wait(0.5)

	# Create another shape
	var hex = PolygonMobject.new(6, 55.0)
	hex.position = center
	hex.fill_color = Color.MEDIUM_PURPLE
	hex.fill_opacity = 0.9
	hex.stroke_color = Color.WHITE
	hex.stroke_width = 2.0
	add(hex)

	await wait(0.3)

	print("   Shrinking to center...")
	await play(ShrinkToCenterAnimation.new(star, center, 1.5))
	star.queue_free()


# ═══════════════════════════════════════════
# Demo 5: .animate Syntax
# ═══════════════════════════════════════════
func demo_5_animate() -> void:
	print("▶ Demo 5: .animate Syntax")

	var center = Vector2(640, 360)

	var circle = CircleMobject.new(40.0)
	circle.position = center + Vector2(-200, 0)
	circle.fill_color = Color.CORAL
	circle.fill_opacity = 0.8
	circle.stroke_color = Color.WHITE
	circle.stroke_width = 2.0
	add(circle)

	print("   .animate chain: shift + rotate + change color + grow...")

	# Chain multiple property changes
	await play(
		circle.animate
			.shift(Vector2(400, 0))
			.rotate_mob(TAU)
			.set_fill(Color.SPRING_GREEN, 0.9)
			.scale_to_uniform(1.5)
			.to_animation(),
		2.0,
		RateFunctions.ease_in_out_cubic
	)

	print("   .animate complete")

	# Fade out the result
	await play(FadeOutAnimation.new(circle, 1.0))


# ═══════════════════════════════════════════
# Demo 6: Magic Circle (preset)
# ═══════════════════════════════════════════
func demo_6_magic_circle() -> void:
	print("▶ Demo 6: Magic Circle")

	var center = Vector2(640, 360)
	var layers = 3
	var base_radius = 200.0
	var created: Array[MagicMobject] = []

	# Create concentric rings of shapes
	for layer in range(layers):
		var r = base_radius - layer * 55.0
		var count = 6 + layer * 3
		var hue = float(layer) / float(layers)

		for i in range(count):
			var angle = TAU * float(i) / float(count)
			var pos = center + Vector2(cos(angle), sin(angle)) * r

			var shape: MagicMobject
			if layer == 0:
				shape = CircleMobject.new(18.0)
			elif layer == 1:
				shape = PolygonMobject.new(6, 18.0)
			else:
				shape = StarMobject.new(5, 18.0, 8.0)

			shape.position = pos
			shape.fill_color = Color.from_hsv(hue + float(i) * 0.05, 0.8, 1.0)
			shape.fill_opacity = 0.7
			shape.stroke_color = Color.WHITE
			shape.stroke_width = 1.5
			shape.modulate.a = 0.0  # Start invisible
			add(shape)
			created.append(shape)

	# Center star
	var center_star = StarMobject.new(5, 50.0, 20.0)
	center_star.position = center
	center_star.fill_color = Color.GOLD
	center_star.fill_opacity = 1.0
	center_star.stroke_color = Color.WHITE
	center_star.stroke_width = 3.0
	center_star.modulate.a = 0.0
	add(center_star)
	created.append(center_star)

	# Fade in all at once with stagger
	var group = AnimationGroup.new([], 2.0)
	group.lag_ratio = 0.8
	for shape in created:
		group.add(FadeInAnimation.new(shape, 1.5))

	await play(group)

	# Start rotation updaters for all
	for shape in created:
		var speed = randf_range(0.3, 1.5)
		var dir = 1.0 if randi() % 2 == 0 else -1.0
		shape.add_updater(func(mob, delta):
			mob.rotation += delta * speed * dir
		)

	print("   Magic circle active! Shapes rotating with updaters.")
	await wait(3.0)

	# Fade out
	for shape in created:
		shape.clear_updaters()

	var fade_group = AnimationGroup.new([], 1.5)
	fade_group.lag_ratio = 0.5
	for shape in created:
		fade_group.add(FadeOutAnimation.new(shape, 1.5))

	await play(fade_group)
	print("   Magic circle complete")
