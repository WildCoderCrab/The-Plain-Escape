extends CharacterBody2D

signal hit(knockback: float)

const SPEED = 80.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1
var is_dead = false
var knockback_direction = 0

@onready var ray_cast_1 = $RayCast1
@onready var ray_cast_2 = $RayCast2
@onready var collision_shape_2d = $CollisionShape2D
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D
@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	if not is_on_floor() and !is_dead:
		velocity.y += gravity * delta
	
	animated_sprite_2d.flip_h = direction < 0
	animated_sprite_2d.play("Run")
	
	if !is_dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, 15)
		
		if ray_cast_1.is_colliding():
			direction = -1
		elif ray_cast_2.is_colliding():
			direction = 1
	else:
		velocity.y = move_toward(velocity.y, -250, 150)
		velocity.x = knockback_direction * SPEED * 5
		
		if !visible_on_screen_notifier_2d.is_on_screen():
			queue_free()
	
	move_and_slide()

func _on_hit(knockback):
	is_dead = true
	collision_shape_2d.set_deferred("disabled", true)
	knockback_direction = knockback
