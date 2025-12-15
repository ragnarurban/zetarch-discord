extends CharacterBody2D
class_name Player

###############################################################################
# STATE
###############################################################################

enum PlayerState {
	IDLE,     # dialogs, pauses, cutscenes
	RUN,      # normal rhythm gameplay
	ACTION    # locked performing an action
}

var state: PlayerState = PlayerState.RUN
@onready var visual: AnimatedSprite2D = $Visual

###############################################################################
# CONFIG
###############################################################################

@export var jump_arc_height := 48.0
@export var jump_arc_time := 0.35
@export var input_buffer_len := 0.18
@export var lane_change_time := 0.18

###############################################################################
# LANES
###############################################################################

var current_lane := 1
var target_lane := 1
var is_changing_lane := false
var lane_t := 0.0
var start_y := 0.0

###############################################################################
# RHYTHM INPUT BUFFERING
###############################################################################

var buffered_jump_time := -1.0
var buffered_attack_time := -1.0

###############################################################################
# TIMING
###############################################################################

var jump_t := 0.0
var is_fake_jumping := false
var current_anim := ""

###############################################################################
# SIGNALS
###############################################################################

signal action_performed(action_type)

enum ActionType {
	JUMP,
	ATTACK
}

###############################################################################
# READY
###############################################################################

func _ready() -> void:
	GameState.player = self
	play_anim("run")

###############################################################################
# INPUT (BUFFER ONLY)
###############################################################################

func _input(event):
	if state == PlayerState.IDLE:
		return

	var t := AudioManager.get_current_song_time()

	if event.is_action_pressed("ui_up"):
		request_lane_change(current_lane + 1)
	elif event.is_action_pressed("ui_down"):
		request_lane_change(current_lane - 1)

	if event.is_action_pressed("jump"):
		buffered_jump_time = t
	if event.is_action_pressed("attack"):
		buffered_attack_time = t

###############################################################################
# BUFFER CLEANUP
###############################################################################

func _process(_delta):
	_clear_expired_buffers()

func _clear_expired_buffers():
	var now := AudioManager.get_current_song_time()
	if buffered_jump_time >= 0 and now - buffered_jump_time > input_buffer_len:
		buffered_jump_time = -1.0
	if buffered_attack_time >= 0 and now - buffered_attack_time > input_buffer_len:
		buffered_attack_time = -1.0

###############################################################################
# PHYSICS
###############################################################################

func _physics_process(delta):
	_update_lane_movement(delta)
	_update_fake_jump(delta)

	var base_y = GameState.get_lane_y(GameState.LANE_INDEX_TO_NAME[current_lane])
	if is_changing_lane:
		base_y = lerp(start_y, GameState.get_lane_y(GameState.LANE_INDEX_TO_NAME[target_lane]), ease(lane_t, -2.0))

	if is_fake_jumping:
		var height = 4.0 * jump_arc_height * jump_t * (1.0 - jump_t)
		global_position.y = base_y - height
	else:
		global_position.y = base_y

	move_and_slide()

###############################################################################
# LANE MOVEMENT
###############################################################################

func request_lane_change(new_lane: int):
	if new_lane < 0 or new_lane >= GameState.LANE.size():
		return
	if new_lane == current_lane:
		return

	target_lane = new_lane
	start_y = global_position.y
	lane_t = 0.0
	is_changing_lane = true

func _update_lane_movement(delta):
	if not is_changing_lane:
		return

	lane_t += delta / lane_change_time
	lane_t = min(lane_t, 1.0)

	global_position.y = lerp(
		start_y,
		GameState.get_lane_y(GameState.LANE_INDEX_TO_NAME[current_lane]),
		ease(lane_t, -2.0)
	)

	if lane_t >= 1.0:
		current_lane = target_lane
		is_changing_lane = false

###############################################################################
# RHYTHM-GATED ACTION EXECUTION
###############################################################################

func try_execute_action(action: ActionType):
	if state != PlayerState.RUN:
		return
	if not GameState.is_action_allowed(action):
		return
	match action:
		ActionType.JUMP:
			_execute_jump()
		ActionType.ATTACK:
			_execute_attack()

###############################################################################
# ACTION IMPLEMENTATIONS
###############################################################################

func _execute_jump():
	state = PlayerState.ACTION
	jump_t = 0.0
	is_fake_jumping = true
	emit_signal("action_performed", ActionType.JUMP)
	play_anim("jump")

	var anim_length = get_animation_length("jump")
	await get_tree().create_timer(anim_length / visual.speed_scale).timeout
	if state == PlayerState.ACTION:
		state = PlayerState.RUN
		play_anim("run")

func _execute_attack():
	state = PlayerState.ACTION
	emit_signal("action_performed", ActionType.ATTACK)
	play_anim("attack")

	var anim_length = get_animation_length("attack")
	await get_tree().create_timer(anim_length / visual.speed_scale).timeout
	if state == PlayerState.ACTION:
		state = PlayerState.RUN
		play_anim("run")

###############################################################################
# COYOTE TIME
###############################################################################

func can_jump_now() -> bool:
	return true

###############################################################################
# ANIMATION HELPERS
###############################################################################

func play_anim(_name: String):
	if current_anim == _name:
		return
	current_anim = _name
	visual.play(_name)

func get_animation_length(anim_name: String) -> float:
	var frames = visual.sprite_frames.get_frame_count(anim_name)
	var fps = visual.sprite_frames.get_animation_speed(anim_name)
	if fps <= 0:
		return 0.0
	return frames / fps

func set_idle(enabled: bool):
	if enabled:
		state = PlayerState.IDLE
		play_anim("idle")
	else:
		state = PlayerState.RUN
		play_anim("run")

###############################################################################
# FAKE JUMP ARC
###############################################################################

func _update_fake_jump(delta):
	if not is_fake_jumping:
		return

	jump_t += delta / jump_arc_time
	jump_t = min(jump_t, 1.0)

	if jump_t >= 1.0:
		is_fake_jumping = false

###############################################################################
# INPUT BUFFER ACCESSORS
###############################################################################

func get_buffer_time(action: ActionType) -> float:
	match action:
		ActionType.JUMP:
			return buffered_jump_time
		ActionType.ATTACK:
			return buffered_attack_time
	return -1.0

func consume_buffer(action: ActionType):
	match action:
		ActionType.JUMP:
			buffered_jump_time = -1.0
		ActionType.ATTACK:
			buffered_attack_time = -1.0
