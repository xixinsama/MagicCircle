class_name AnimationGroup
extends RefCounted

var animations: Array[MagicAnimation] = []
var run_time: float = 1.0
var lag_ratio: float = 0.0
var rate_func: Callable

func _init(p_anims: Array[MagicAnimation] = [], p_duration: float = 1.0) -> void:
	animations = p_anims
	run_time = p_duration

func add(anim: MagicAnimation) -> void:
	animations.append(anim)

func size() -> int:
	return animations.size()

func play_on(scene: Node) -> void:
	for i in range(animations.size()):
		var anim = animations[i]

		if rate_func:
			anim.rate_func = rate_func

		anim.run_time = run_time

		if lag_ratio > 0:
			anim.lag_ratio = lag_ratio

		anim.play_on(scene)
