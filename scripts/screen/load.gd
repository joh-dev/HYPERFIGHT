extends Node2D

var max_transition_timer = 40
var transition_timer = max_transition_timer

onready var logo = get_node("logo")

func _ready():
	global.load_config()

func _process(delta):
	transition_timer -= global.fps * delta
	if transition_timer <= 0:
		if logo.visible:
			logo.visible = false
		else:
			get_tree().change_scene(global.SCENE_MENU)
		transition_timer = max_transition_timer
