extends Node2D
class_name HitWindowVisualizer

@export var perfect_color := Color(0.3, 1.0, 0.6, 0.35)
@export var ok_color := Color(1.0, 0.8, 0.3, 0.25)
@export var height := 48.0

var tile: MusicTile

func _ready():
	tile = get_parent()

func _draw():
	if not tile or tile.resolved:
		return

	var speed = tile.scroll_speed
	var perfect_dist = speed * tile.hit_window_perfect
	var ok_dist = speed * tile.hit_window_ok

	# OK window (draw first, bigger)
	draw_rect(
		Rect2(
			Vector2(-ok_dist, -height / 2),
			Vector2(ok_dist * 2, height)
		),
		ok_color
	)

	# Perfect window (inside OK)
	draw_rect(
		Rect2(
			Vector2(-perfect_dist, -height / 2),
			Vector2(perfect_dist * 2, height)
		),
		perfect_color
	)
