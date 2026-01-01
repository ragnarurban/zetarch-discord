extends Node2D
class_name MusicTile

###############################################################################
# CONFIG
###############################################################################

@export var required_action: Player.ActionType
@export var ideal_time: float
@export var scroll_speed := 600.0
@export var lane_index := 1

enum TileIntent {
	COLLECT,
	ATTACK,
	DEFEND,
	DODGE,
	SLIDE,
	HOLD
}

###############################################################################
# HIT WINDOWS (delegate to judge, but keep for visuals)
###############################################################################

@export var hit_window_ok := 0.15
@export var hit_window_perfect := 0.08
@export var HIT_X := 10.0 # PLAYER X position

###############################################################################
# STATE
###############################################################################

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
var resolved := false
var is_active := false
var is_idle := true

###############################################################################
# READY
###############################################################################

func _ready():
	add_to_group("music_tiles")
	animated_sprite.play('idle')

	# if Engine.is_editor_hint() == false:
	# 	var viz = HitWindowVisualizer.new()
	# 	add_child(viz)

###############################################################################
# MOVEMENT
###############################################################################

func _physics_process(_delta):
	if resolved:
		return
	
	var song_time := AudioManager.get_current_song_time()
	var dt := ideal_time - song_time
	
	if abs(dt) < 0.02:
		print("NOTE AT HIT LINE", global_position.x)
	
	global_position.x = HIT_X + dt * scroll_speed

	# auto miss
	if dt < -GameState.rhythm_judge.ok_window:
		resolve_miss()
###############################################################################
# HIT ZONE LOGIC
###############################################################################

func _on_hit_area_body_entered(body):
	if resolved:
		return

	if body != GameState.player:
		return

	# Must be in same lane
	if body.current_lane != lane_index:
		return

	is_active = true

func _on_hit_area_body_exited(body):
	if body == GameState.player:
		is_active = false

###############################################################################
# RESOLUTION
###############################################################################

func resolve_miss():
	resolved = true
	animated_sprite.play("hit")
	var anim_length = get_animation_length("hit")
	await get_tree().create_timer(anim_length / animated_sprite.speed_scale).timeout
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if resolved:
		return
	if body != GameState.player:
		return
	if body.current_lane != lane_index:
		return
	is_active = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == GameState.player:
		is_active = false

func get_animation_length(anim_name: String) -> float:
	var frames = animated_sprite.sprite_frames.get_frame_count(anim_name)
	var fps = animated_sprite.sprite_frames.get_animation_speed(anim_name)
	if fps <= 0:
		return 0.0
	return frames / fps

func on_resolved(result: String) -> void:
	resolved = true

	match result:
		"perfect", "good", "ok":
			animated_sprite.play("hit")
		"miss":
			animated_sprite.play("miss")

	await animated_sprite.animation_finished
	queue_free()
