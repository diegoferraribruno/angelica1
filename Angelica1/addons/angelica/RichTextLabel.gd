extends RichTextLabel

func _ready() -> void:
	bbcode_text = "[url=save][save][/url] [url=pong][pong][/url] [url=volume][volume][/url] [url=edit menu][menu][/url] [url=bye][Bye!][/url] [url=hide][hide][/url] [url=mini][mini][/url] [url=link ko-fi][k-f][/url] [url=editor][editor][/url]"
	connect("meta_clicked", self, "handle")
func handle(argument):
	get_node("../..")._on_LineEdit_text_entered(argument)
