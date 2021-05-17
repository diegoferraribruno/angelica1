extends RichTextLabel

func _ready():
	visible_characters = 0

func _process(delta):
	var total = self.get_total_character_count()
	if visible_characters < total:
		visible_characters +=7

func _on_SendButton_button_up():
	var total = self.get_total_character_count()
	visible_characters = total

func _on_LineEdit_text_entered(new_text):
	var total = self.get_total_character_count()
	visible_characters = total
