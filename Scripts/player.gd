extends CharacterBody2D

const SPEED = 120.0
const ACCELERATION = 15.0
const DASH_SPEED = 420.0
const JUMP_VELOCITY = -300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dash_direction = 1
var can_dash = true
var health = 3
var can_hurt = true
var can_move = true

@onready var sprite_2d = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var hurt_timer = $HurtTimer
@onready var jump_sound = $JumpSound
@onready var hurt_sound = $HurtSound
@onready var hit_sound = $HitSound
@onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 400)
		sprite_2d.play("Jump")
	else:
		if velocity.x > SPEED or velocity.x < -SPEED:
			sprite_2d.play("Dash")
		elif velocity.x != 0:
			sprite_2d.play("Run")
		else:
			sprite_2d.play("Idle")
	
	if Input.is_action_just_pressed("button_a") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	
	if Input.is_action_just_pressed("button_b") and can_dash and can_move:
		velocity.x = dash_direction * DASH_SPEED
		can_dash = false
		dash_timer.start()
	
	var direction = Input.get_axis("left", "right")
	if direction and can_move:
		sprite_2d.flip_h = direction < 0
		dash_direction = direction
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * 2)
	
	move_and_slide()

func _on_dash_timer_timeout():
	can_dash = true

func _on_hitbox_body_entered(body):
	if velocity.x > SPEED or velocity.x < -SPEED:
		body.emit_signal("hit", dash_direction)
		hit_sound.play()
	else:
		if can_hurt:
			hurt_sound.play()
			animation_player.play("Hurt")
			hurt_timer.start()
			can_hurt = false
			health -= 1

func _on_hurt_timer_timeout():
	can_hurt = true
	animation_player.play("RESET")

func _on_hitbox_area_entered(area):
	if velocity.x > SPEED or velocity.x < -SPEED:
		area.queue_free()
	else:
		if can_hurt:
			hurt_sound.play()
			animation_player.play("Hurt")
			hurt_timer.start()
			can_hurt = false
			health -= 1
