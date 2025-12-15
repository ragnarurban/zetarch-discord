extends CanvasLayer
class_name HitFeedbackManager

@export var feedback_scene: PackedScene
@export var _offset := Vector2(0, -60)

func _ready():
	var judge := GameState.rhythm_judge
	judge.hit_judged.connect(_on_hit_judged)

func _on_hit_judged(action, result: String, diff: float):
	var fb := feedback_scene.instantiate() as EarlyLateFeedback
	add_child(fb)

	# Place near player
	var player_pos := GameState.player.global_position
	fb.position = player_pos + _offset

	fb.show_feedback(result, diff)
