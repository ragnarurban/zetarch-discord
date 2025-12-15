extends Control

@onready var portrait = $Portrait
@onready var text_label = $Text

func show_dialog(portrait_texture: Texture2D, text: String)->void:
	portrait.texture = portrait_texture
	text_label = ""
	# TODO change into the builtin text show hide mode
	for i in range(text.length()):
		text_label.text += text[i]
		await get_tree().create_timer(0.03).timeout
