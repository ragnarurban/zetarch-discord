extends Node2D
class_name GroundGenerator

@export var tile_scene: PackedScene
@export var tile_width := 32
@export var ground_y := 400
@export var preload_distance := 2000

var player: CharacterBody2D
var tiles := []

func _process(_delta):
	if not player:
		return

	# Keep ground spawning ahead of player
	var target_x = player.global_position.x + preload_distance

	while tiles.is_empty() or tiles[-1].global_position.x < target_x:
		_spawn_next_tile()

	# Clean tiles behind the player
	for t in tiles:
		if t.global_position.x < player.global_position.x - preload_distance * 1.5:
			tiles.erase(t)
			t.queue_free()

func _spawn_next_tile():
	var new_tile = tile_scene.instantiate()

	var x = 0
	if tiles.is_empty():
		x = 0
	else:
		var last_tile = tiles[-1]
		x = last_tile.global_position.x + tile_width

	new_tile.position = Vector2(x, ground_y)
	add_child(new_tile)
	tiles.append(new_tile)
