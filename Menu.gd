extends CanvasLayer

func _ready():
	pass

func _on_Button_pressed():
	get_node("/root/global").goto_scene("res://Main.tscn")