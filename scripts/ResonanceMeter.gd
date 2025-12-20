extends Node
class_name ResonanceBar

###############################################################################
# --- CONFIGURABLE SCORING ---
###############################################################################

@export_group("Resonance Values")
@export var max_resonance: float = 100.0
@export var starting_resonance: float = 60.0

@export_subgroup("Hit Bonuses")
@export var perfect_gain: float = 3.0
@export var ok_gain: float = 1.0
@export var good_gain: float = 0.0 # “good” but neutral if you want

@export_subgroup("Fail Penalties")
@export var miss_penalty: float = 6.0
@export var hit_penalty: float = 4.0 # collision penalty

@export_subgroup("Sustain Notes")
@export var sustain_gain_rate: float = 2.5 # per second when held correctly
@export var sustain_fail_penalty: float = 10.0

@export_group("UI")
@export var smooth_ui: bool = true
@export var ui_lerp_speed: float = 8.0

###############################################################################
# INTERNAL STATE
###############################################################################

var resonance: float
var ui_resonance: float # for smooth bar animation
var is_dead := false

###############################################################################
# SIGNALS
###############################################################################

signal resonance_changed(new_value: float)
signal resonance_hit_feedback(kind: String) # "perfect", "ok", "miss", etc.
signal resonance_depleted()

###############################################################################
# READY
###############################################################################

func _ready():
	resonance = starting_resonance
	ui_resonance = resonance
	
	if (GameState.resonance_ui):
		print("Shhhhh ", GameState.resonance_ui)

		GameState.resonance_ui.max_value = max_resonance
		GameState.resonance_ui.value = ui_resonance

	# Update FMOD driven systems
	AudioManager.set_resonance(resonance / max_resonance)

###############################################################################
# PROCESS (smooth UI)
###############################################################################

func _process(delta):
	if smooth_ui:
		ui_resonance = lerp(ui_resonance, resonance, delta * ui_lerp_speed)
	else:
		ui_resonance = resonance

	if (GameState.resonance_ui):
		GameState.resonance_ui.value = ui_resonance

###############################################################################
# API — ADD/REMOVE RESONANCE
###############################################################################

func _apply(value: float, feedback: String):
	if is_dead:
		return

	resonance = clamp(resonance + value, 0.0, max_resonance)
	emit_signal("resonance_changed", resonance)
	emit_signal("resonance_hit_feedback", feedback)

	# Send 0–1 to FMOD
	AudioManager.set_resonance(resonance / max_resonance)
	
	print("APPLY RESONANCE value ", value)
	

	if resonance <= 0 and not is_dead:
		_handle_death()

func _handle_death():
	is_dead = true
	emit_signal("resonance_depleted")
	print("Resonance depleted → restarting...")
	get_tree().reload_current_scene()

###############################################################################
# SCORING — PUBLIC METHODS
###############################################################################

func add_perfect():
	_apply(+perfect_gain, "perfect")

func add_ok():
	_apply(+ok_gain, "ok")

func add_miss():
	_apply(-miss_penalty, "miss")

func add_hit_penalty():
	_apply(-hit_penalty, "hit")

# for sustained notes: call each frame while holding correctly
func add_sustain(delta: float):
	_apply(+sustain_gain_rate * delta, "sustain")

func sustain_fail():
	_apply(-sustain_fail_penalty, "sustain_fail")

###############################################################################
# UTILITY
###############################################################################

func get_ratio() -> float:
	return resonance / max_resonance
