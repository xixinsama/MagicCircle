class_name MagicAnimation
extends RefCounted

## Base class for all animations. Wraps Godot Tween for execution.
## Supports Manim-style run_time, rate_func, and lag_ratio.

var run_time: float = 1.0
var rate_func: Callable
var lag_ratio: float = 0.0
var remover: bool = false
var suspend_updaters: bool = true

var _mobject: MagicMobject
var _family: Array[MagicMobject] = []
var _start_snapshots: Array[Dictionary] = []
var _finished: bool = false

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

func begin() -> void:
	_start_snapshots.clear()
	for mob in _family:
		_start_snapshots.append(mob.snapshot())
	_finished = false

func interpolate_submobject(index: int, alpha: float) -> void:
	pass  # override in subclass

func finish() -> void:
	_finished = true
	if remover and is_instance_valid(_mobject):
		_mobject.queue_free()

func is_finished() -> bool:
	return _finished

## Play this animation on a scene node.
## Each sub-object gets its own Tween for proper parallel staggering.
func play_on(scene: Node) -> void:
	begin()

	# Default rate_func: linear
	var rf = rate_func if rate_func else func(t): return t

	var n = max(1, _family.size())
	var all_finished: Array[bool] = []
	all_finished.resize(n)
	all_finished.fill(false)

	for i in range(n):
		var sub_run_time = run_time
		var start_delay: float = 0.0

		if lag_ratio > 0 and n > 1:
			# Each sub-object starts with a delay, runs for reduced time
			var stagger = lag_ratio * run_time
			start_delay = stagger * float(i) / float(n - 1)
			sub_run_time = run_time - stagger

		# Each sub-object gets its own independent tween
		var sub_tween = scene.create_tween()

		if start_delay > 0:
			sub_tween.tween_interval(start_delay)

		sub_tween.tween_method(
			func(alpha: float):
				var effective = rf.call(clamp(alpha, 0.0, 1.0))
				interpolate_submobject(i, effective)
				if i < _family.size() and is_instance_valid(_family[i]):
					_family[i].queue_redraw()
			,
			0.0, 1.0, sub_run_time
		)

		# Track completion per sub-object
		var idx = i
		sub_tween.tween_callback(func():
			all_finished[idx] = true
			var all_done = true
			for b in all_finished:
				if not b:
					all_done = false
					break
			if all_done:
				finish()
		)
