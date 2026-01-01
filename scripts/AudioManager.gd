extends Node

var music_instance: FmodEvent
var is_playing := false
var song_start_timeline_pos := 0

# Holds all loaded events
var available_events : Array = []
var current_song_time := 0.0
var last_time := 0.0
var event_path := "event:/MainSong"
var input_offset := 0.030

func _ready():
	pass

	#music_instance = FmodServer.create_event_instance("event:/MainSong")
	#FmodHandler.instance.play_event("event:/MainSong")

func start_song(_event_path: String) -> void:
	music_instance = FmodServer.create_event_instance("event:/MainSong")
	if music_instance:
		music_instance.start()
	last_time = 0.0

func get_current_song_time() -> float:
	if music_instance == null:
		return 0.0

	# Call get_timeline_position and store the result in pos
	var t_ms = music_instance.get_timeline_position()
	var t :float = t_ms / 1000.0
	
	# monotonic guarantee
	if t < last_time:
		t = last_time
	else:
		last_time = t
	

	#print('[AUDIO MANAGER] [get_current_song_time] ', t, ' [t_ms] ', t_ms)
	return t

func set_resonance(resonance: float) -> void:
	resonance = clamp(resonance, 0.0, 1.0)

	if music_instance == null:
		return

	# Direct parameter control
	music_instance.set_parameter_by_name("Resonance", resonance)

	var pitch = lerp(-10.0, 0.0, resonance)
	var lowpass = lerp(500.0, 20000.0, resonance)
	var reverb = lerp(0.2, 2.0, resonance)

	music_instance.set_parameter_by_name("PitchShift", pitch)
	music_instance.set_parameter_by_name("LowPassCutoff", lowpass)
	music_instance.set_parameter_by_name("ReverbDecay", reverb)
	print("New resonance is ", resonance)

func trigger_stutter() -> void:
	if music_instance == null:
		return

	music_instance.set_parameter_by_name("Stutter", 1.0)

	await get_tree().create_timer(0.1).timeout

	music_instance.set_parameter_by_name("Stutter", 0.0)
	
func _on_timeline_marker():
	print("Timeline marker")

func get_event_instance():
	return music_instance
