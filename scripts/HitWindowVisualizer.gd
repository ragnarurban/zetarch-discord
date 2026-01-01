extends Node2D
class_name HitWindowVisualizer

@export var perfect_color := Color(0.3, 1.0, 0.6, 0.35)
@export var good_color := Color(1.0, 0.8, 0.3, 0.25)
@export var late_color := Color(1.0, 0.8, 0.3, 0.25)
@export var height := 48.0

@export var perfect_window := 0.055
@export var good_window := 0.090
@export var ok_window := 0.140

var tile: MusicTile

func _ready():
	tile = get_parent()

func _draw():
	if not tile or tile.resolved:
		return

	var speed = tile.scroll_speed
	var perfect_dist = speed * perfect_window
	var good_dist = speed * good_window
	var late_dist = speed * ok_window

	# Late windows (draw first, bigger)
	draw_rect(
		Rect2(
			Vector2(-late_dist, -height / 2),
			Vector2(late_dist * 2, height)
		),
		late_color
	)
	
	# Good window (draw first, bigger)
	draw_rect(
		Rect2(
			Vector2(-good_dist, -height / 2),
			Vector2(good_dist * 2, height)
		),
		good_color
	)

	# Perfect window (inside OK)
	draw_rect(
		Rect2(
			Vector2(-perfect_dist, -height / 2),
			Vector2(perfect_dist * 2, height)
		),
		perfect_color
	)
