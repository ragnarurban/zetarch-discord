extends Node2D
class_name Game

@onready var audio_manager = AudioManager
@onready var player: CharacterBody2D = $World/Player
@onready var resonance_bar = $ResonanceBar
@onready var music_spawner = $MusicTileSpawner
@onready var forest: Parallax2D = $Background/Forest
@onready var ground: Parallax2D = $World/Ground
@onready var sky: Parallax2D = $Background/Sky
@onready var clouds_far: Parallax2D = $Background/CloudsFar
@onready var mountains_far: Parallax2D = $Background/MountainsFar
@onready var clouds_close: Parallax2D = $Background/CloudsClose
@onready var mountains_close: Parallax2D = $Background/MountainsClose


@export var background_scroll = {
	"Sky": Vector2(-1,0),
	"CloudsFar": Vector2(-10,0),
	"MountainsFar": Vector2(-15,0),
	"CloudsClose": Vector2(-20,0),
	"MountainsClose": Vector2(-25,0),
	"Forest": Vector2(-50,0),
	"Ground": Vector2(-75,0)
}
var rhythm_hit_judge: RhythmHitJudge

func _ready():
	# Initialize FMOD audio & sync
	sky.autoscroll = Vector2.ZERO
	clouds_far.autoscroll = Vector2.ZERO
	mountains_far.autoscroll = Vector2.ZERO
	clouds_close.autoscroll = Vector2.ZERO
	mountains_close.autoscroll = Vector2.ZERO
	forest.autoscroll = Vector2.ZERO
	ground.autoscroll = Vector2.ZERO
	
	# Give systems references
	#player.resonance_system = resonance_bar
	#music_spawner.resonance_system = resonance_bar
	
	# Register to RhythmHitJudge
	GameState.rhythm_judge.resonance_bar = resonance_bar

	# Reset resonance
	AudioManager.set_resonance(resonance_bar.starting_resonance)
	
	player.set_idle(true)
	await get_tree().create_timer(3.0).timeout
	start_game()
	
func start_game():
	# Start moving backgrounds
	sky.autoscroll = background_scroll['Sky']
	clouds_far.autoscroll = background_scroll['CloudsFar']
	mountains_far.autoscroll = background_scroll['MountainsFar']
	clouds_close.autoscroll = background_scroll['CloudsClose']
	mountains_close.autoscroll = background_scroll['MountainsClose']
	forest.autoscroll = background_scroll['Forest']
	ground.autoscroll = background_scroll['Ground']
	
	# Start song
	audio_manager.start_song("event:/MainSong")
	
	# Move the tiles
	music_spawner.move_tiles()
	
	player.set_idle(false)
	


func _on_fmod_event_emitter_2d_timeline_beat(params: Dictionary) -> void:
	print("HEY ", params)
	AudioManager.current_song_time = params.get("position", 0.0)
