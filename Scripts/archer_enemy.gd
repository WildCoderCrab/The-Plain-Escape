extends CharacterBody2D

enum {
	RUNNING = 0,
	SHOOTING
}

signal hit(knockback: float)

const SPEED = 60.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1
var is_dead = false
var can_shoot = true
var state = RUNNING
var knockback_direction = 0

@onready var ray_cast_1 = $RayCast1
@onready var ray_cast_2 = $RayCast2
@onready var sight = $Sight
@onready var collision_shape_2d = $CollisionShape2D
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shoot_delay = $ShootDelay

func _physics_process(delta):
	if not is_on_floor() and !is_dead:
		velocity.y += gravity * delta
	
	match state:
		RUNNING:
			running_state(delta)
		SHOOTING:
			shooting_state()
	
	move_and_slide()

func running_state(_delta):
	animated_sprite_2d.flip_h = direction < 0
	sight.target_position.x = direction * 120
	animated_sprite_2d.play("Run")
	
	if !is_dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, 15)
		
		if ray_cast_1.is_colliding():
			direction = -1
		elif ray_cast_2.is_colliding():
			direction = 1
	else:
		velocity.y = move_toward(velocity.y, -250, 150)
		velocity.x = knockback_direction * SPEED * 6
		
		if !visible_on_screen_notifier_2d.is_on_screen():
			queue_free()
	
	if sight.is_colliding() and can_shoot:
		state = SHOOTING
		shoot_delay.start()

func shooting_state():
	if can_shoot:
		animated_sprite_2d.play("Shoot")
	else:
		animated_sprite_2d.play("Run")
	
	if is_dead:
		velocity.x = knockback_direction * SPEED * 6
		velocity.y = move_toward(velocity.y, -250, 150)
	else:
		velocity.x = 0

func shoot():
	var arrow = preload("res://Scenes/arrow.tscn").instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = Vector2(global_position.x, global_position.y + 1)
	if direction == 1: arrow.rotation_degrees = 0
	else: arrow.rotation_degrees = 180

func _on_hit(knockback):
	is_dead = true
	knockback_direction = knockback
	collision_shape_2d.set_deferred("disabled", true)

func _on_shoot_delay_timeout():
	state = RUNNING
	can_shoot = !can_shoot
	if !can_shoot and sight.is_colliding():
		shoot()
		shoot_delay.start()
