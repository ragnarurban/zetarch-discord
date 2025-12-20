extends Node

var player: Player
var current_lane := 1
var rhythm_judge: RhythmHitJudge
var resonance_ui: ResonanceBar

const LANE := {
	"low": 305.0,
	"mid": 280.0,
	"top": 255.0
}

enum PlayerState {
	IDLE, # dialogs, pauses, cutscenes
	RUN, # normal rhythm gameplay
	ACTION # locked performing an action
}

enum Phase {
	TUTORIAL,
	RUNNER,
	COMBAT,
	BOSS_MICHAEL,
	DIALOG
}

const PHASE_ACTIONS := {
	Phase.TUTORIAL: [
		Player.ActionType.JUMP
	],

	Phase.RUNNER: [
		Player.ActionType.JUMP,
		Player.ActionType.ATTACK
	],

	Phase.COMBAT: [
		Player.ActionType.ATTACK,
		#Player.ActionType.DODGE
	],

	Phase.BOSS_MICHAEL: [
		Player.ActionType.JUMP,
		Player.ActionType.ATTACK,
		#Player.ActionType.PARRY
	],

	Phase.DIALOG: []
}

var current_phase := Phase.RUNNER


const LANE_INDEX_TO_NAME := ["low", "mid", "top"]

func get_lane_index(index: String) -> int:
	return LANE_INDEX_TO_NAME.find(index)

func get_lane_y(index: String) -> float:
	return LANE[index]

func is_action_allowed(action: int) -> bool:
	return action in PHASE_ACTIONS.get(current_phase, [])
	
func set_phase(new_phase: Phase):
	current_phase = new_phase

	if new_phase == Phase.DIALOG:
		player.set_idle(true)
	else:
		player.set_idle(false)

func _ready() -> void:
	rhythm_judge = RhythmHitJudge.new()
