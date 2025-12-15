extends Camera2D

@export var scroll_speed := 200 # pixels/sec


func shake(intensity: float = 10.0, duration: float = 0.3) -> void:
	var tween = create_tween()
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * intensity
	tween.tween_property(self, "offset", Vector2.ZERO, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
