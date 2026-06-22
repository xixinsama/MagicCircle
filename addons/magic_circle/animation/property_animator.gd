## Records chained method calls and generates a TransformAnimation.
## Implements Manim's .animate syntax for property keyframing.
class_name PropertyAnimator
extends RefCounted

var _mobject: MagicMobject
var _calls: Array[Dictionary] = []  # [{method: String, args: Array}]

func _init(mobject: MagicMobject) -> void:
	_mobject = mobject

# ═══ Recorded method calls (each returns self for chaining) ═══

func shift(offset: Vector2) -> PropertyAnimator:
	_calls.append({"method": "shift", "args": [offset]})
	return self

func move_to(pos: Vector2) -> PropertyAnimator:
	_calls.append({"method": "move_to", "args": [pos]})
	return self

func rotate_mob(angle: float) -> PropertyAnimator:
	_calls.append({"method": "rotate_mob", "args": [angle]})
	return self

func rotate_to(angle: float) -> PropertyAnimator:
	_calls.append({"method": "rotate_to", "args": [angle]})
	return self

func scale_to_uniform(s: float) -> PropertyAnimator:
	_calls.append({"method": "scale_to_uniform", "args": [s]})
	return self

func scale_to_vec(s: Vector2) -> PropertyAnimator:
	_calls.append({"method": "scale_to_vec", "args": [s]})
	return self

func set_fill(color: Color, opacity: float = 1.0) -> PropertyAnimator:
	_calls.append({"method": "set_fill", "args": [color, opacity]})
	return self

func set_stroke(color: Color, width: float = 2.0, opacity: float = 1.0) -> PropertyAnimator:
	_calls.append({"method": "set_stroke", "args": [color, width, opacity]})
	return self

func fade_to(opacity: float) -> PropertyAnimator:
	_calls.append({"method": "fade_to", "args": [opacity]})
	return self

func set_z(z: int) -> PropertyAnimator:
	_calls.append({"method": "set_z", "args": [z]})
	return self

# ═══ Generate TransformAnimation ═══
# Takes snapshot of mobject, applies recorded calls to mobject,
# returns TransformAnimation that goes from snapshot to new state.

func to_animation() -> TransformAnimation:
	if _calls.is_empty():
		return TransformAnimation.new(_mobject, null, 1.0)

	# 1. Snapshot current state (BEFORE applying calls)
	var start_snapshot = _mobject.snapshot()

	# 2. Apply all recorded method calls to the mobject
	# This MUTATES the mobject to its target state
	for call in _calls:
		var method: String = call["method"]
		var args: Array = call["args"]
		_mobject.callv(method, args)

	# 3. Create TransformAnimation with the start snapshot pre-loaded
	var anim = TransformAnimation.new(_mobject, null, 1.0)
	# Override the begin() behavior: use our manual start snapshot
	# instead of the default (which would snapshot AFTER we mutated)
	anim._start_snapshots = [start_snapshot]

	return anim

# ═══ Helpers ═══

func has_calls() -> bool:
	return not _calls.is_empty()

func clear() -> void:
	_calls.clear()
