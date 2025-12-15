extends CanvasLayer
class_name RhythmDebugHUD

@export var show_debug := true
@export var font_size := 18

var player
var rhythm_judge

func _ready():
	player = get_tree().get_first_node_in_group("player")
	rhythm_judge = RhythmHitJudge
	
	if not show_debug:
		visible = false

func _process(delta):
	if not show_debug:
		visible = false
		return

	_draw_debug()

func _draw_debug():
	var t = AudioManager.get_current_song_time()

	var text := ""
	text += "[SONG TIME] %.3f\n" % t
	text += "-----------------------------\n"

	# Last judgment:
	text += "[LAST ACTION] %s\n" % rhythm_judge.last_action
	text += "[LAST RESULT] %s\n" % rhythm_judge.last_result
	if rhythm_judge.last_diff < INF:
		text += "[DIFF] %.3f sec  (%.1f ms)\n" % [rhythm_judge.last_diff, rhythm_judge.last_diff * 1000]
	else:
		text += "[DIFF] No input\n"

	text += "-----------------------------\n"

	# Player input buffers
	text += "[BUFFERS]\n"
	text += "Attack:       %s\n" % _fmt_buffer(player.buffered_attack_time)
	text += "Parry:        %s\n" % _fmt_buffer(player.buffered_parry_time)
	text += "Dodge:        %s\n" % _fmt_buffer(player.buffered_dodge_time)
	text += "Jump:         %s\n" % _fmt_buffer(player.buffered_jump_time)
	text += "Down Jump:    %s\n" % _fmt_buffer(player.buffered_down_jump_time)

	text += "-----------------------------\n"

	# Player states
	text += "[PLAYER STATES]\n"
	text += "Parrying:     %s\n" % str(player.is_parrying)
	text += "Invulnerable: %s\n" % str(player.is_invulnerable)
	text += "On Floor:     %s\n" % str(player.is_on_floor())
	text += "Velocity:     %s\n" % str(player.velocity)

	# Render text
	if not has_node("Label"):
		var label := Label.new()
		label.name = "Label"
		label.set("theme_override_font_sizes/font_size", font_size)
		add_child(label)

	$Label.text = text

func _fmt_buffer(t: float) -> String:
	if t < 0:
		return "None"
	return "%.3f (age %.3f)" % [t, AudioManager.get_current_song_time() - t]

func _input(event):
	if event.is_action_pressed("ui_debug"):
		show_debug = !show_debug
	visible = show_debug
