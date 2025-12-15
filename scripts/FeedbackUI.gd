extends Control
class_name EarlyLateFeedback

@export var perfect_color := Color(0.3, 1.0, 0.6)
@export var ok_color := Color(1.0, 0.85, 0.3)
@export var miss_color := Color(1.0, 0.3, 0.3)

@export var float_distance := 24.0
@export var lifetime := 0.6

@onready var label: Label = $Label

func show_feedback(result: String, diff: float):
	# Determine timing text
	var timing_text := ""
	if result.contains("early"):
		timing_text = "EARLY"
	elif result.contains("late"):
		timing_text = "LATE"

	# Determine hit tier
	if result.begins_with("perfect"):
		label.text = "PERFECT\n" + timing_text
		label.modulate = perfect_color
	elif result.begins_with("ok"):
		label.text = "OK\n" + timing_text
		label.modulate = ok_color
	else:
		label.text = "MISS"
		label.modulate = miss_color

	label.scale = Vector2.ONE
	label.modulate.a = 1.0

	# Animate
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - float_distance, lifetime)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(label, "modulate:a", 0.0, lifetime)

	tween.tween_callback(queue_free)
