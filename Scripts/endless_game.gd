extends Node2D

var Enemy = preload("res://Scenes/enemy.tscn")
var Archer_enemy = preload("res://Scenes/archer_enemy.tscn")
var enemy_list = []
var score = 0

@onready var spawn_point_1 = $SpawnPoint1
@onready var spawn_point_2 = $SpawnPoint2
@onready var spawn_timer = $SpawnTimer
@onready var player = $Player
@onready var hearts = %Hearts
@onready var black_hearts = %BlackHearts
@onready var score_label = %ScoreLabel
@onready var blackout = $Blackout
@onready var blackout_timer = $BlackoutTimer
@onready var camera_2d = %Camera2D
@onready var blip_sound = $BlipSound
@onready var pause_label = %PauseLabel
@onready var lose_music = $LoseMusic
@onready var main_theme_music = $MainThemeMusic

func _ready():
	randomize()
	player.health = 5
	
	black_hearts.size.x = player.health * 9
	hearts.size.x = player.health * 9

func _process(_delta):
	hearts.size.x = player.health * 9
	
	score_label.text = "Score: " + str(score)
	
	blackout.global_position = camera_2d.global_position - blackout.size / 2
	if player.health <= 0 and !blackout.visible:
		lose_music.play()
		get_tree().paused = true
		hearts.visible = false
		if score > Global.save_data.highscore:
			Global.save_data.highscore = score
			Global.save_data.save()
		player.sprite_2d.play("Lose")
		blackout.visible = true
		blackout_timer.start()
	
	if Input.is_action_just_pressed("start") and !blackout.visible:
		blip_sound.play()
		get_tree().paused = !get_tree().paused
	
	if !blackout.visible:
		pause_label.visible = get_tree().paused
	
	for enemy in enemy_list:
		if enemy.is_dead:
			enemy_list.erase(enemy)
			score += 10

func spawn_enemy():
	if enemy_list.size() < 7:
		var rand_enemy = randi_range(1, 2)
		if rand_enemy == 1:
			var enemy1 = Enemy.instantiate()
			add_child(enemy1)
			enemy1.global_position = spawn_point_1.global_position if randi_range(1, 2) == 1 else spawn_point_2.global_position 
			enemy_list.append(enemy1)
		else:
			var enemy2 = Archer_enemy.instantiate()
			add_child(enemy2)
			enemy2.global_position = spawn_point_1.global_position if randi_range(1, 2) == 1 else spawn_point_2.global_position 
			enemy_list.append(enemy2)

func _on_spawn_timer_timeout():
	spawn_enemy()
	spawn_timer.start()

func _on_blackout_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_main_theme_music_finished():
	main_theme_music.play()
