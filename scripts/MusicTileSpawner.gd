extends Node
class_name MusicTileSpawner

@export var tile_factory: Node
@export var scroll_speed: float = 100.0 # should be song tempo

# Player is stationary
@export var player_x: float = 100.0
@export var screen_width: float = 1024.0   # adjust to your window size

# Timing windows
@export var timing_good: float = 0.08
@export var timing_ok: float = 0.14

# Preloaded FMOD marker → tile mapping
@export var marker_actions := {
	"BassHigh": {"type": "bass_high"},
	"BassDouble": {"type": "bass_double"},
	"BassLow": {"type": "bass_low"},
	"Kick": {"type": "drum_kick"},
	"Snare": {"type": "drum_snare"},
	"HiHat": {"type": "drum_hihat"},
	"BDCombo": {"type": "bass_drum_combo"},
	"SustainStart": {"type": "sustained_bass", "sustain_start": true},
	"SustainEnd":   {"type": "sustained_bass", "sustain_end": true}
}

var tiles: Array = []
var sustain_buffer: Dictionary = {}
var song_start_time: float = 0.0
var fmod_markers := []
@export var is_idle := true
@export var player_path: NodePath
@onready var player: Player = get_node(player_path)

func _ready():
	# Assume AudioManager has already started the song
	song_start_time = AudioManager.get_current_song_time()
	_preload_all_tiles()

# ------------------------
# Preload all markers
# ------------------------
func _preload_all_tiles():
	var json_str = FileAccess.get_file_as_string("res://markers/markers.json")
	fmod_markers = JSON.parse_string(json_str)
	for m in fmod_markers:
		var _name = m.get("name", "")
		var time_sec = m.get("time", 0.0)
		if not marker_actions.has(_name):
			continue
		var def = marker_actions[_name]

		var lane = m.get("lane", "mid")
		if lane is Array:
			lane = lane.pick_random()
		_spawn_tile(
			def["type"],
			time_sec,
			lane
		)

func _spawn_tile(tile_type: String, marker_time: float, lane_name: String):
	var tile_scene: PackedScene = tile_factory.get_scene(tile_type)
	if not tile_scene:
		push_error("Unknown tile type: %s" % tile_type)
		return

	if not GameState.LANE.has(lane_name):
		push_error("Unknown lane: %s" % lane_name)
		return

	var tile = tile_scene.instantiate()
	tile.required_action = tile_type
	tile.ideal_time = marker_time
	tile.lane_index = GameState.get_lane_index(lane_name)

	# Y comes ONLY from lane
	tile.global_position.y = GameState.get_lane_y(lane_name)

	# Time math
	var marker_sec := marker_time / 1000.0
	var song_time := AudioManager.get_current_song_time()
	var time_until_hit := marker_sec - song_time

	# Reaction buffer (very important)
	var reaction_time := 0.25

	tile.global_position.x = player.global_position.x + scroll_speed * (time_until_hit + reaction_time )

	add_child(tile)
	tiles.append(tile)

#func _spawn_tile(tile_type: String, marker_time: float):
	#var tile_scene: PackedScene = tile_factory.get_scene(tile_type)
	#if not tile_scene:
		#push_error("Unknown tile type: %s" % tile_type)
		#return
	#var tile = tile_scene.instantiate()
	#tile.tile_type = tile_type
	#tile.ideal_time = marker_time
	#tile.position.y = lane_map.get(tile_type, 300.0)
	## Convert marker time from ms → seconds
	#var marker_sec = marker_time / 1000.0
	#var time_until_hit = marker_sec - song_start_time
	#
##
	## Compute X so tile reaches player exactly at marker_time
	## Tiles move left toward stationary player at scroll_speed
	#var sprite := tile.get_node("Sprite2D")
	#var final_size = sprite.texture.get_size() * sprite.global_scale
	## add some space to let the player react, like a action window
	#tile.position.x = %Player.global_position.x + 100 + (scroll_speed * time_until_hit)
##
	#add_child(tile)
	##await get_tree().process_frame  # Wait until tile._ready() runs
	##GameState.player.connect(
		##"action_performed",
		##Callable(tile, "_on_player_action")
	##)
	#tiles.append(tile)
	##print("Spawned ",  tile, " at ", marker_time, tile_type)

func _spawn_sustained_tile(tile_type: String, start_time: float, end_time: float):
	pass
	#var scene: PackedScene = tile_factory.get_scene(tile_type)
	#if not scene:
		#push_error("Unknown sustained tile type: %s" % tile_type)
		#return
#
	#var tile = scene.instantiate()
	#tile.tile_type = tile_type
	#tile.ideal_time = start_time
	#tile.sustain_end_time = end_time
	#tile.position.y = lane_map[tile_type]
#
	#var time_until_hit = start_time - song_start_time
	#var tile_x = player_x + scroll_speed * time_until_hit
	#if tile_x < screen_width:
		#tile_x = screen_width + 50
#
	#tile.position.x = tile_x
#
	#add_child(tile)
	#tiles.append(tile)

func move_tiles() -> void:
	for child in get_children():
		child.scroll_speed = scroll_speed
		child.is_idle = false
