extends Control
class_name EarlyLateFeedback

@export var perfect_color := Color(0.3, 1.0, 0.6)
@export var ok_color := Color(1.0, 0.85, 0.3)
@export var miss_color := Color(1.0, 0.3, 0.3)

@export var float_distance := 24.0
@export var lifetime := 0.6

@onready var label: Label = $Label
