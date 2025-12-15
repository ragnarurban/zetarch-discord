extends Node
class_name MusicTileFactory

@export var tile_scenes := {
	"bass_high": preload("res://tiles/BassHigh.tscn"),
	"bass_double": preload("res://tiles/BassHigh.tscn"),
	"bass_low": preload("res://tiles/BassHigh.tscn"),

	"drum_kick": preload("res://tiles/BassHigh.tscn"),
	"drum_snare": preload("res://tiles/Snare.tscn"),
	"drum_hihat": preload("res://tiles/BassHigh.tscn"),

	"bass_drum_combo": preload("res://tiles/BassHigh.tscn"),

	"sustained_bass": preload("res://tiles/BassHigh.tscn")
}

func get_scene(type: String) -> PackedScene:
	return tile_scenes.get(type, null)
