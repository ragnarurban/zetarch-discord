extends CharacterBody2D
class_name RhythmEnemy

@export var attack_marker_time: float = 0.0       # FMOD timestamp of attack moment
@export var action_type: String = "attack"        # "attack", "parry", "dodge", "combo"
@export var projectile_scene: PackedScene         # optional
@export var attack_range: float = 80.0            # for melee kick/snare
@export var hit_window: float = 0.12              # ± timing window
@export var despawn_delay: float = 0.6

var has_attacked := false
var is_dead := false

var resonance_bar: Node
var player: Node
var audio_manager

func _ready():
	player = get_tree().get_first_node_in_group("player")
	resonance_bar = get_tree().get_first_node_in_group("resonance_bar")
	audio_manager = AudioManager

func _process(delta):
	if is_dead:
		return

	var song_time = audio_manager.get_current_song_time()

	# Enemy attacks when time matches marker
	if not has_attacked and abs(song_time - attack_marker_time) <= hit_window:
		_perform_attack()
		has_attacked = true

	# Despawn after attack
	if has_attacked and song_time > attack_marker_time + despawn_delay:
		queue_free()

func _perform_attack():
	match action_type:
		"attack":
			_do_melee_attack()

		"parry":
			_spawn_parry_projectile()

		"dodge":
			_spawn_dodge_projectile()

		"combo":
			_do_combo_attack()

func _do_melee_attack():
	if player_exists_in_range():
		player.receive_enemy_hit()
		resonance_bar.add_miss()
	else:
		# Player dodged or parried correctly
		resonance_bar.add_ok()

func _do_combo_attack():
	if player_exists_in_range():
		player.receive_enemy_hit()
		resonance_bar.add_miss()
	else:
		resonance_bar.add_perfect()

func _spawn_parry_projectile():
	if projectile_scene:
		var p = projectile_scene.instantiate()
		p.init("parry", global_position, player.global_position, attack_marker_time)
		get_parent().add_child(p)

func _spawn_dodge_projectile():
	if projectile_scene:
		var p = projectile_scene.instantiate()
		p.init("dodge", global_position, player.global_position, attack_marker_time)
		get_parent().add_child(p)

func player_exists_in_range() -> bool:
	if not player:
		return false
	return global_position.distance_to(player.global_position) <= attack_range
