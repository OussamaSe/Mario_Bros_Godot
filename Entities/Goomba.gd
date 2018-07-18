extends KinematicBody2D

signal mario_hit

const GRAVITY = 550.0

var movement = Vector2()

var move_left = true

func _ready():
	pass

func _physics_process(delta):
	movement.y += GRAVITY * delta
	
	if is_on_floor():
		movement.y = 0
	
	if is_on_wall():
		if move_left:
			move_left = false
		else:
			move_left = true
	
	if move_left:
		movement.x = -120.0
	else:
		movement.x = 120.0
		
	if not get_node("Sprite/AnimationPlayer").current_animation == "walk":
    	get_node("Sprite/AnimationPlayer").play("walk")
	move_and_slide(movement, Vector2(0, -1))
	
	var collision = get_slide_count() - 1
	if collision > -1:
		var coll_body = get_slide_collision(collision)
		if coll_body.collider.is_in_group("Mario"):
			emit_signal("mario_hit")