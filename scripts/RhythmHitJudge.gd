extends Node
class_name RhythmHitJudge

###############################################################################
# CONFIG
###############################################################################

@export var perfect_window := 0.055
@export var good_window := 0.090
@export var ok_window := 0.140

###############################################################################
# STATE
###############################################################################

# For debug UI
var last_eval_time := 0.0
var last_diff := INF
var last_result := "none"
var last_action: Player.ActionType

###############################################################################
# SIGNALS
###############################################################################

signal hit_judged(action_type: String, result: String, diff: float)
signal perfect(action_type: String)
signal ok(action_type: String)
signal miss(action_type: String)

###############################################################################
# READY
###############################################################################

func _ready():
	pass

###############################################################################
# PUBLIC API
# Central call for tiles and enemies
###############################################################################

func resolve_tile(tile: MusicTile, input_time: float) -> void:
	if tile.resolved:
		return

	var delta := input_time - tile.ideal_time
	var abs_diff :float = abs(delta)

	var result := "miss"

	if abs_diff <= perfect_window:
		result = "perfect"
	elif abs_diff <= good_window:
		result = "good"
	elif abs_diff <= ok_window:
		result = "ok"

	# Apply result
	match result:
		"perfect":
			GameState.resonance_ui.add_perfect()
			GameState.player.try_execute_action(tile.required_action)

		"good":
			GameState.resonance_ui.add_ok()
			GameState.player.try_execute_action(tile.required_action)

		"ok":
			GameState.resonance_ui.add_ok()

		"miss":
			GameState.resonance_ui.add_miss()

	tile.on_resolved(result)

###############################################################################
# INTERNAL SIGNAL WRAPPER
###############################################################################

func _emit(type: String, action_type: Player.ActionType, diff: float):
	last_result = type
	emit_signal("hit_judged", action_type, type, diff)

	if type.begins_with("perfect"):
		emit_signal("perfect", action_type)
	elif type.begins_with("ok"):
		emit_signal("ok", action_type)
	else:
		emit_signal("miss", action_type)

func judge_input(action, input_time):
	var best_tile = null
	var best_diff = INF
	
	for tile in get_tree().get_nodes_in_group("music_tiles"):
		if tile.resolved:
			continue
		if tile.required_action != action:
			continue
		if tile.lane_index != GameState.player.current_lane:
			continue

		var diff :float = input_time - tile.ideal_time
		var abs_diff :float = abs(diff)

		if abs_diff < best_diff:
			best_diff = abs_diff
			best_tile = tile

	if best_tile == null:
		GameState.resonance_ui.add_miss()
		return

	resolve_tile(best_tile, input_time)
