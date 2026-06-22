class_name RateFunctions
extends RefCounted

# ---------------------------------------------------------------------------
# Rate Functions (Timing / Easing Curves)
#
# All functions accept a time value t in [0, 1] and return a progress value
# in [0, 1] (with the exception of Back and Elastic variants which may
# overshoot slightly).
#
# Organized into sections:
#   Basic, Sine, Polynomial (Quad/Cubic/Quart/Quint), Exponential,
#   Circular, Back, Elastic, Bounce, In-Out variants.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Internal helper
# ---------------------------------------------------------------------------
static func _clamp01(t):
	return clamp(t, 0.0, 1.0)


# ===========================================================================
# Basic
# ===========================================================================

static func linear(t):
	return _clamp01(t)


static func smooth(t):
	# Smoothstep: 3t^2 - 2t^3
	t = _clamp01(t)
	return t * t * (3.0 - 2.0 * t)


static func smoother(t):
	# Smootherstep: 6t^5 - 15t^4 + 10t^3
	t = _clamp01(t)
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)


static func there_and_back(t):
	# Goes 0 -> 1 -> 0 using smoothstep
	t = _clamp01(t)
	return smooth(1.0 - abs(2.0 * t - 1.0))


static func running_start(t):
	# Starts fast then slows down
	t = _clamp01(t)
	return pow(t, 0.3)


static func rush_into(t):
	# Accelerates into the target (fast start, slow finish)
	t = _clamp01(t)
	return 2.0 * t - t * t


static func rush_from(t):
	# Rushes away from the start (slow start, fast finish)
	t = _clamp01(t)
	return t * t


static func double_smooth(t):
	# Smooth of smooth for extra easing
	t = _clamp01(t)
	return smooth(smooth(t))


# ===========================================================================
# Sine
# ===========================================================================

static func ease_in_sine(t):
	t = _clamp01(t)
	return 1.0 - cos(t * PI * 0.5)


static func ease_out_sine(t):
	t = _clamp01(t)
	return sin(t * PI * 0.5)


static func ease_in_out_sine(t):
	t = _clamp01(t)
	return -(cos(PI * t) - 1.0) * 0.5


# ===========================================================================
# Polynomial — Quad
# ===========================================================================

static func ease_in_quad(t):
	t = _clamp01(t)
	return t * t


static func ease_out_quad(t):
	t = _clamp01(t)
	return t * (2.0 - t)


static func ease_in_out_quad(t):
	t = _clamp01(t)
	if t < 0.5:
		return 2.0 * t * t
	else:
		var v = -2.0 * t + 2.0
		return 1.0 - v * v * 0.5


# ===========================================================================
# Polynomial — Cubic
# ===========================================================================

static func ease_in_cubic(t):
	t = _clamp01(t)
	return t * t * t


static func ease_out_cubic(t):
	t = _clamp01(t)
	var v = 1.0 - t
	return 1.0 - v * v * v


static func ease_in_out_cubic(t):
	t = _clamp01(t)
	if t < 0.5:
		return 4.0 * t * t * t
	else:
		var v = -2.0 * t + 2.0
		return 1.0 - v * v * v * 0.5


# ===========================================================================
# Polynomial — Quart
# ===========================================================================

static func ease_in_quart(t):
	t = _clamp01(t)
	return t * t * t * t


static func ease_out_quart(t):
	t = _clamp01(t)
	var v = 1.0 - t
	return 1.0 - v * v * v * v


# ===========================================================================
# Polynomial — Quint
# ===========================================================================

static func ease_in_quint(t):
	t = _clamp01(t)
	return t * t * t * t * t


static func ease_out_quint(t):
	t = _clamp01(t)
	var v = 1.0 - t
	return 1.0 - v * v * v * v * v


# ===========================================================================
# Exponential
# ===========================================================================

static func ease_in_expo(t):
	t = _clamp01(t)
	if t == 0.0:
		return 0.0
	return pow(2.0, 10.0 * t - 10.0)


static func ease_out_expo(t):
	t = _clamp01(t)
	if t == 1.0:
		return 1.0
	return 1.0 - pow(2.0, -10.0 * t)


# ===========================================================================
# Circular
# ===========================================================================

static func ease_in_circ(t):
	t = _clamp01(t)
	return 1.0 - sqrt(1.0 - t * t)


static func ease_out_circ(t):
	t = _clamp01(t)
	return sqrt(1.0 - (t - 1.0) * (t - 1.0))


# ===========================================================================
# Back
# ===========================================================================

static func ease_in_back(t):
	t = _clamp01(t)
	const c1 = 1.70158
	return (c1 + 1.0) * t * t * t - c1 * t * t


static func ease_out_back(t):
	t = _clamp01(t)
	const c1 = 1.70158
	var v = t - 1.0
	return 1.0 + (c1 + 1.0) * v * v * v + c1 * v * v


static func ease_in_out_back(t):
	t = _clamp01(t)
	const c1 = 1.70158
	const c2 = c1 * 1.525

	if t < 0.5:
		var v = 2.0 * t
		return (v * v * ((c2 + 1.0) * v - c2)) * 0.5
	else:
		var v = 2.0 * t - 2.0
		return (v * v * ((c2 + 1.0) * v + c2) + 2.0) * 0.5


# ===========================================================================
# Elastic
# ===========================================================================

static func ease_in_elastic(t):
	t = _clamp01(t)
	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	return -pow(2.0, 10.0 * t - 10.0) * sin((t - 1.075) * 2.0 * PI / 0.3)


static func ease_out_elastic(t):
	t = _clamp01(t)
	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	return pow(2.0, -10.0 * t) * sin((t - 0.075) * 2.0 * PI / 0.3) + 1.0


static func ease_in_out_elastic(t):
	t = _clamp01(t)
	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0

	const c5 = 2.0 * PI / 4.5
	if t < 0.5:
		return -(pow(2.0, 20.0 * t - 10.0) * sin((20.0 * t - 11.125) * c5)) * 0.5
	else:
		return (pow(2.0, -20.0 * t + 10.0) * sin((20.0 * t - 11.125) * c5)) * 0.5 + 1.0


# ===========================================================================
# Bounce
# ===========================================================================

static func ease_out_bounce(t):
	t = _clamp01(t)
	const n1 = 7.5625
	const d1 = 2.75

	if t < 1.0 / d1:
		return n1 * t * t
	elif t < 2.0 / d1:
		t -= 1.5 / d1
		return n1 * t * t + 0.75
	elif t < 2.5 / d1:
		t -= 2.25 / d1
		return n1 * t * t + 0.9375
	else:
		t -= 2.625 / d1
		return n1 * t * t + 0.984375


static func ease_in_bounce(t):
	t = _clamp01(t)
	return 1.0 - ease_out_bounce(1.0 - t)


static func ease_in_out_bounce(t):
	t = _clamp01(t)
	if t < 0.5:
		return (1.0 - ease_out_bounce(1.0 - 2.0 * t)) * 0.5
	else:
		return (1.0 + ease_out_bounce(2.0 * t - 1.0)) * 0.5
