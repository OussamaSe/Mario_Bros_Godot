extends Node

func _ready():
	pass
func game_over():
	get_node("/root/global").goto_scene("res://Menu.tscn")
	print("did it")