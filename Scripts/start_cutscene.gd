extends Control

@onready var animation_player = $AnimationPlayer
@onready var transition = $Transition
@onready var transition_timer = $TransitionTimer
@onready var blip_sound = $BlipSound
@onready var cutscene_music = $CutsceneMusic

func _ready():
	animation_player.play("Start")

func _process(_delta):
	if Input.is_action_just_pressed("start") and !transition.visible:
		cutscene_music.stop()
		blip_sound.play()
		transition.visible = true
		animation_player.speed_scale = 1000

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Start":
		cutscene_music.stop()
		transition.visible = true
		transition_timer.start()

func _on_transition_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/story_mode.tscn")

func _on_cutscene_music_finished():
	cutscene_music.play()
