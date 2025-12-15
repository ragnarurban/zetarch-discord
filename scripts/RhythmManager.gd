# RhythmManager.gd
extends Node
class_name RhythmManager

signal beat(beat_idx: int, bar: int)
signal marker(name: String, position_ms: int)

var emitter: FmodEventEmitter2D

func _ready() -> void:
	emitter= FmodEventEmitter2D.new()
	emitter.event_name = "event:/MainSong"
	emitter.autoplay = true
	add_child(emitter)

	emitter.timeline_beat.connect(_on_beat)
	emitter.timeline_marker.connect(_on_marker)
	

func _on_beat(params: Dictionary) -> void:
	# params contains: beat (int), bar (int), tempo (float), time_signature_upper, time_signature_lower, position (ms)
	emit_signal("beat", params.beat, params.bar)

func _on_marker(params: Dictionary) -> void:
	emit_signal("marker", params.name, params.position)
