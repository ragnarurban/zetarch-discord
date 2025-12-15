extends Node2D
class_name MusicTile

###############################################################################
# CONFIG
###############################################################################

@export var required_action: Player.ActionType
@export var ideal_time: float
@export var scroll_speed := 220.0
@export var lane_index := 1

###############################################################################
# HIT WINDOWS (delegate to judge, but keep for visuals)
###############################################################################

@export var hit_window_ok := 0.15
@export var hit_window_perfect := 0.08

###############################################################################
# STATE
###############################################################################

var resolved := false
var is_active := false
var is_idle := true
var last_checked_buffer_time := -1.0

###############################################################################
# READY
###############################################################################

func _ready():
	add_to_group("music_tiles")

	if Engine.is_editor_hint() == false:
		var viz = HitWindowVisualizer.new()
		add_child(viz)

###############################################################################
# MOVEMENT
###############################################################################

func _physics_process(delta):
	if not is_idle:
		position.x -= scroll_speed * delta
	
	if is_active and not resolved:
		try_resolve()

	# Passed player → auto miss
	if position.x < GameState.player.global_position.x - 40 and not resolved:
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
# RHYTHM EVALUATION (CALLED BY JUDGE TICK OR INPUT)
###############################################################################

func try_resolve():
	if resolved or not is_active:
		return

	var buffer_time = GameState.player.get_buffer_time(required_action)
	
	# No input → do nothing
	if buffer_time < 0:
		return

	# Already evaluated this input
	if buffer_time == last_checked_buffer_time:
		return

	last_checked_buffer_time = buffer_time

	var result := GameState.rhythm_judge.evaluate(
		required_action,
		buffer_time,
		ideal_time
	)

	print("Resolved", result, "delta:", buffer_time - ideal_time)

	match result:
		"perfect_early", "perfect_late","ok_early", "ok_late":
			print("Consumed input:", required_action)
			GameState.player.consume_buffer(required_action)
			GameState.player.try_execute_action(required_action)
			resolve_hit()
		"miss":
			resolve_miss()


###############################################################################
# RESOLUTION
###############################################################################

func resolve_hit():
	resolved = true
	queue_free()

func resolve_miss():
	resolved = true
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
