extends Node2D

@onready var player = $Player
@onready var hearts = %Hearts
@onready var black_hearts = %BlackHearts
@onready var blackout = $Blackout
@onready var blackout_timer = $BlackoutTimer
@onready var camera_2d = %Camera2D
@onready var ending_timer = $EndingTimer
@onready var blip_sound = $BlipSound
@onready var pause_label = %PauseLabel
@onready var lose_music = $LoseMusic
@onready var win_music = $WinMusic
@onready var main_theme_music = $MainThemeMusic

var ending = false

func _ready():
	hearts.size.x = player.health * 9
	black_hearts.size.x = player.health * 9

func _process(_delta):
	hearts.size.x = player.health * 9
	
	blackout.global_position = camera_2d.global_position - blackout.size / 2
	if player.health <= 0 and !blackout.visible:
		lose_music.play()
		get_tree().paused = true
		hearts.visible = false
		player.sprite_2d.play("Lose")
		blackout.visible = true
		blackout_timer.start()
	
	if ending:
		player.velocity = Vector2.ZERO
		player.can_move = false
	
	if Input.is_action_just_pressed("start") and !blackout.visible and !ending:
		blip_sound.play()
		get_tree().paused = !get_tree().paused
	
	if !blackout.visible:
		pause_label.visible = get_tree().paused

func _on_ending_hitbox_body_entered(_body):
	main_theme_music.stop()
	ending = true
	ending_timer.start()
	win_music.play()
	$EndingHitbox/Label.visible = true

func _on_blackout_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_ending_timer_timeout():
	if !blackout.visible:
		blackout.z_index = 3
		$Blackout/Label.visible = false
		blackout.visible = true
		ending_timer.wait_time = 1.5
		ending_timer.start()
	else:
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_main_theme_music_finished():
	main_theme_music.play()
