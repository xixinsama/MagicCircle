@tool
class_name MagicScene
extends Node2D

## Scene base class — like Manim's Scene.
## Users override construct() to build their content.

var _playing: bool = false

func _ready() -> void:
	# Wait one frame for everything to initialize
	await get_tree().process_frame
	construct()

func construct() -> void:
	## Override this method to build your scene content.
	pass

# ═══ Mobject Management ═══

func add(mobject: MagicMobject) -> MagicMobject:
	add_child(mobject)
	return mobject

func remove(mobject: MagicMobject) -> void:
	if mobject.get_parent() == self:
		remove_child(mobject)

func clear_all() -> void:
	for child in get_children():
		if child is MagicMobject:
			child.queue_free()

func get_mobjects() -> Array[MagicMobject]:
	var result: Array[MagicMobject] = []
	for child in get_children():
		if child is MagicMobject:
			result.append(child)
	return result

# ═══ Animation Playback ═══

func play(animation_or_mob, duration: float = -1.0, p_rate_func = null) -> void:
	## Play an animation. Accepts:
	## - MagicAnimation (play directly)
	## - PropertyAnimator (from .animate syntax)
	## - MagicMobject (creates a default TransformAnimation to itself)

	var animation: MagicAnimation

	if animation_or_mob is PropertyAnimator:
		animation = animation_or_mob.to_animation()
	elif animation_or_mob is MagicAnimation:
		animation = animation_or_mob
	elif animation_or_mob is MagicMobject:
		# Default: just show it (fade in)
		animation = FadeInAnimation.new(animation_or_mob, 1.0)
	else:
		push_error("MagicScene.play(): unsupported type: " + str(animation_or_mob))
		return

	if duration > 0:
		animation.run_time = duration
	if p_rate_func:
		animation.rate_func = p_rate_func

	_playing = true
	animation.play_on(self)

	# Wait for animation to complete
	await get_tree().create_timer(animation.run_time + 0.02).timeout
	_playing = false

func wait(duration: float = 1.0) -> void:
	## Pause for duration seconds.
	await get_tree().create_timer(duration).timeout

func is_playing() -> bool:
	return _playing

# ═══ Convenience Methods ═══

func fade_in(mob: MagicMobject, duration: float = 1.0) -> void:
	play(FadeInAnimation.new(mob, duration))

func fade_out(mob: MagicMobject, duration: float = 1.0) -> void:
	play(FadeOutAnimation.new(mob, duration))

func grow_from_center(mob: MagicMobject, center: Vector2 = Vector2.ZERO, duration: float = 1.0) -> void:
	play(GrowFromCenterAnimation.new(mob, center, duration))

func shrink_to_center(mob: MagicMobject, center: Vector2 = Vector2.ZERO, duration: float = 1.0) -> void:
	play(ShrinkToCenterAnimation.new(mob, center, duration))
