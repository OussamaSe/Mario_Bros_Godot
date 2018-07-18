extends Node2D

export (PackedScene) var Goomba

func _ready():
	$AudioStreamPlayer.play()
	var goomba = Goomba.instance()
	add_child(goomba)
	goomba.position = $GoombaSpawn/Position2D.position