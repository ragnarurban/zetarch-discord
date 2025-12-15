extends Area2D
class_name RhythmProjectile

@export var speed: float = 450.0
@export var timing_window: float = 0.12     # ± timing window
@export var lifetime: float = 2.0

var target
var direction: Vector2
var action_type: String
var attack_time: float

var resonance_bar
var player
var audio_manager

func init(action_type:String, start_pos:Vector2, target_pos:Vector2, marker_time:float):
	self.action_type = action_type
	self.position = start_pos
	self.attack_time = marker_time
	resonance_bar = get_tree().get_first_node_in_group("resonance_bar")
	player = get_tree().get_first_node_in_group("player")
	audio_manager = AudioManager

	direction = (target_pos - start_pos).normalized()

func _process(delta):
	var song_time = audio_manager.get_current_song_time()

	position += direction * speed * delta

	if song_time > attack_time + lifetime:
		queue_free()

func _on_body_entered(body):
	if body is Player:
		_handle_hit()

func _handle_hit():
	var current_time = audio_manager.get_current_song_time()
	var diff = abs(current_time - attack_time)

	match action_type:
		"parry":
			if player.is_parrying and diff <= timing_window:
				resonance_bar.add_perfect()
			elif player.is_parrying:
				resonance_bar.add_ok()
			else:
				player.receive_enemy_hit()
				resonance_bar.add_miss()

		"dodge":
			if player.is_invulnerable and diff <= timing_window:
				resonance_bar.add_perfect()
			elif player.is_invulnerable:
				resonance_bar.add_ok()
			else:
				player.receive_enemy_hit()
				resonance_bar.add_miss()

	queue_free()
