extends Node2D
class_name RhythmEnemyAttackTile

@export var tile_type: String                 # "drum_snare", "drum_hihat", "drum_kick", etc.
@export var enemy_scene: PackedScene
@export var attack_time: float                # FMOD timestamp
@export var lane_y: float

func _ready():
	position.y = lane_y
	_spawn_enemy()

func _spawn_enemy():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		enemy.attack_marker_time = attack_time

		match tile_type:
			"drum_kick":
				enemy.action_type = "attack"

			"drum_snare":
				enemy.action_type = "parry"

			"drum_hihat":
				enemy.action_type = "dodge"

			"bass_drum_combo":
				enemy.action_type = "combo"

		get_parent().add_child(enemy)
