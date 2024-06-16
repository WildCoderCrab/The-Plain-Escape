extends Control

var current_mode = 0

@onready var arrow = $Arrow
@onready var modes = [$StoryModeLabel, $EndlessModeLabel]
@onready var transition = $Transition
@onready var transition_timer = $TransitionTimer
@onready var high_score_label = $HighScoreLabel
@onready var blip_sound = $BlipSound

func _ready():
	get_tree().paused = false
	high_score_label.text = "Highscore: " + str(Global.save_data.highscore)

func _process(_delta):
	arrow.position.y = modes[current_mode].position.y
	
	if Input.is_action_just_pressed("up") and !transition.visible:
		if current_mode == 1:
			current_mode -= 1
		else:
			current_mode += 1
	elif Input.is_action_just_pressed("down") and !transition.visible:
		if current_mode == 0:
			current_mode += 1
		else:
			current_mode -= 1
	
	if current_mode == 1 and !transition.visible:
		high_score_label.visible = true
	else:
		high_score_label.visible = false
	
	if Input.is_action_just_pressed("start") and !transition.visible:
		blip_sound.play()
		transition.visible = true
		$Helper.visible = false
		transition_timer.start()

func _on_transition_timer_timeout():
	if current_mode == 0:
		get_tree().change_scene_to_file("res://Scenes/start_cutscene.tscn")
	elif current_mode == 1:
		get_tree().change_scene_to_file("res://Scenes/endless_mode.tscn")
