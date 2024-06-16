extends Area2D

const SPEED = 150

var velocity = Vector2.ZERO

@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D

func _physics_process(delta):
	velocity = Vector2(SPEED * delta, 0)
	global_position += velocity.rotated(rotation)
	
	if !visible_on_screen_notifier_2d.is_on_screen():
		queue_free()
