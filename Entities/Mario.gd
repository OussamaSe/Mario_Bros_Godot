extends KinematicBody2D
signal dead
signal won
signal hit_by_enemy
#--------------------------------------------------------
#World_Constants
const GRAVITY = 2000.0
const JUMPFORCE = 1000.0
const WALKSPEED = 25.0
const MAX_SPEED = 600.0
const STOP_FORCE = 4000.0

#movement-Vector
var movement = Vector2()

#State of Mario (small, big, flower) and if star is activated
enum state_power {SMALL, BIG, FLOWER}
enum state_movement {IDLE, WALK, SLIDE, JUMP, FALL, DUCK, DEAD}
var star = false
var state

#bool to play Animation
var animation_playing = false

#---------------------------------------------------------
func _ready():
	position = Vector2(32*4, 240-16*2-15)
	state = IDLE



func _physics_process(delta):
	movement.y += GRAVITY * delta

	#reset fall-speed if mario is on floor
	if is_on_floor():
		movement.y = 0
		state = IDLE

	# set behavior for pressing left or right
	if Input.is_action_pressed("ui_right"):
		movement.x += WALKSPEED
		$Sprite_Small.flip_h = false
		state = WALK if state!=JUMP else JUMP
		if state == WALK and movement.x < 0: state = SLIDE
	elif Input.is_action_pressed("ui_left"):
		movement.x -= WALKSPEED
		$Sprite_Small.flip_h = true
		state = WALK if state!=JUMP else JUMP
		if state == WALK and movement.x > 0: state = SLIDE
	else:
		var direction = sign(movement.x)
		var velo = abs(movement.x)
		
		if direction*velo < 0:
			movement.x += STOP_FORCE*delta
		else:
			movement.x -= STOP_FORCE*delta
		
		if velo <= 40:
			movement.x = 0
			if movement.y == 0: state = IDLE 
	# sprinting will just increase max speed
	if Input.is_action_pressed("ui_sprint"):
		movement.x = clamp(movement.x, -MAX_SPEED*1.5, MAX_SPEED*1.5)
	else:
		movement.x = clamp(movement.x, -MAX_SPEED, MAX_SPEED)

	#jump will be higher if in duck state
	if Input.is_action_pressed("ui_down") and state == IDLE:
		state = DUCK

	# state is fall if movement.y is greater then 40 (should be 0, but bug with "is_on_floor()"-method)
	if movement.y>40:
		state = FALL

	# behavior for jump control
	if Input.is_action_pressed("ui_jump") and state != JUMP and state != FALL:
		get_node("SFX_Jump").play()
		movement.y = -JUMPFORCE-400 if state == DUCK else -JUMPFORCE 
		state = JUMP

	# Animations depending on which state mario is on
	match state:
		IDLE: $AnimationPlayer.play("idle_small")
		WALK: 
			if not get_node("AnimationPlayer").current_animation == "walk_small":
    		get_node("AnimationPlayer").play("walk_small")
		JUMP: $AnimationPlayer.play("jump_small")
		FALL: $AnimationPlayer.play("jump_small")
		SLIDE: 
			$AnimationPlayer.play("slide_small")
			$SFX_Slide.play()
		DEAD: $AnimationPlayer.play("dead_small")
		DUCK: $AnimationPlayer.play("duck_small")

	var collision = get_slide_count() - 1
	if collision > -1:
		var coll_body = get_slide_collision(collision)
		if coll_body.collider.is_in_group("Enemies"):
			if coll_body.normal != Vector2(0, -1):
				state = DEAD
			else:
				movement.y = -750
		if coll_body.collider.is_in_group("WinningFlag"):
			state = DEAD
		print(coll_body.collider)
	if state == DEAD:
		emit_signal("dead")
		
	move_and_slide(movement, Vector2(0,-1))