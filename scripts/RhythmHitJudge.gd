extends Node
class_name RhythmHitJudge

###############################################################################
# CONFIG
###############################################################################

@export var perfect_window: float = 0.08    # ± 80 ms
@export var ok_window: float = 0.15         # ± 150 ms

###############################################################################
# STATE
###############################################################################

var resonance_bar: ResonanceBar

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
	resonance_bar = get_tree().get_first_node_in_group("resonance_bar")

###############################################################################
# PUBLIC API
# Central call for tiles and enemies
###############################################################################

func evaluate(action_type: Player.ActionType, buffer_time: float, ideal_time: float) -> String:
	last_eval_time = AudioManager.get_current_song_time()
	last_action = action_type

	# No buffered input → miss
	if buffer_time < 0:
		last_diff = INF
		_emit("miss", action_type, INF)
		return "miss"

	var diff = abs(buffer_time - ideal_time)
	last_diff = diff

	if diff <= perfect_window:
		resonance_bar.add_perfect()
		_emit("perfect", action_type, diff)
		return "perfect"

	if diff <= ok_window:
		resonance_bar.add_ok()
		_emit("ok", action_type, diff)
		return "ok"

	resonance_bar.add_miss()
	_emit("miss", action_type, diff)
	return "miss"

###############################################################################
# INTERNAL SIGNAL WRAPPER
###############################################################################

func _emit(type: String, action_type: Player.ActionType, diff: float):
	last_result = type
	emit_signal("hit_judged", action_type, type, diff)

	match type:
		"perfect":
			emit_signal("perfect", action_type)
		"ok":
			emit_signal("ok", action_type)
		"miss":
			emit_signal("miss", action_type)
