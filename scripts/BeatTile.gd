extends StaticBody2D

enum TileType { BASS_LOW, BASS_MID, BASS_HIGH }
@export var tile_type: TileType
@export var ideal_time: float # seconds
@export var note_pitch: String = "C2"

var was_hit := false

func on_player_land(_player = null):
	print("HEY ")  
	if was_hit:
		return
	was_hit = true

	var current_time = AudioManager.get_current_song_time()
	var time_error = abs(current_time - ideal_time)
	
	# +-80ms = 0.08 seconds
	if time_error <= 0.08:
		ResonanceMeter.add_perfect()
		if has_node("Sprite2D"):
			$Sprite2D.modulate = Color(0, 1, 0) # green flash
	else:
		ResonanceMeter.add_miss()
		AudioManager.trigger_stutter()
		if has_node("Sprite2D"):
			$Sprite2D.modulate = Color(1, 0, 0) # red flash

func _ready() -> void:
	# Optional: add collision detection
	if not has_node("Area2D"):
		var area = Area2D.new()
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.extents = Vector2(16, 16)
		area.add_child(shape)
		add_child(area)
		area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		on_player_land(body)
