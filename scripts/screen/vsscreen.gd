extends Node2D

enum VSSCREEN_STATE { vs, transition }

const STR_STAGE = "STAGE %s"
const STR_FINALSTAGE = "FINAL STAGE"

var state = VSSCREEN_STATE.vs
var max_press_timer = 150
var press_timer = max_press_timer
var bg_move = 0.1
var bg_grid_modulate = 2.5
var bg_grid_edge = 128
var transition_alpha = 1
var change_alpha = 0.1
var ignore_first_delta = true

onready var audio = get_node("AudioStreamPlayer")
onready var bg_grid = get_node("bg_grid")
onready var transition = get_node("transition")
onready var preview_player1 = get_node("preview_player1")
onready var preview_player2 = get_node("preview_player2")
onready var label_stage = get_node("label_stage")
onready var label_player1_name = get_node("label_player1_name")
onready var label_player2_name = get_node("label_player2_name")

onready var msc_vsscreen = preload("res://audio/music/menu/vsscreen.ogg")

func _ready():
	global.prev_input_delay = 0
	global_audio.stop()
	global_audio.stream = msc_vsscreen
	global_audio.play(0)
	transition.visible = true
	preview_player1.set_char(global.player1_char)
	preview_player1.set_palette_num(global.player1_palette)
	preview_player1.set_at_target_x()
	preview_player2.set_char(global.player2_char)
	preview_player2.set_palette_num(global.player2_palette)
	preview_player2.set_at_target_x()
	if global.mode == global.MODE.arcade:
		label_stage.text = STR_STAGE % str(global.arcade_stage)
		if global.arcade_stage == global.max_arcade_stage:
			label_stage.text = STR_FINALSTAGE
	else:
		label_stage.visible = false
	if global.online:
		label_player1_name.text = Steam.getFriendPersonaName(global.lobby_member_ids[0])
		label_player2_name.text = Steam.getFriendPersonaName(global.lobby_member_ids[1])
	else:
		label_player1_name.visible = false
		label_player2_name.visible = false

func _process(delta):
	if ignore_first_delta:
		delta = 0
		ignore_first_delta = false
	
	if global.steam_enabled:
		Steam.run_callbacks()
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	preview_player1.process(delta)
	preview_player2.process(delta)
	if state == VSSCREEN_STATE.vs:
		if transition_alpha > 0:
			transition_alpha -= change_alpha * (global.fps * delta)
		if press_timer > 0:
			press_timer -= 1 * (global.fps * delta)
		elif press_timer <= 0:
			state = VSSCREEN_STATE.transition
	else:
		if transition_alpha < 4:
			transition_alpha += change_alpha * (global.fps * delta)
		else:
			global_audio.stop()
			get_tree().change_scene(global.SCENE_GAME)
	
	if bg_move != 0:
		bg_move += 0.1 * (global.fps * delta)
		bg_grid.position = Vector2(bg_grid.position.x + bg_move * (global.fps * delta), bg_grid.position.y)
		if bg_grid.position.x > bg_grid_edge:
			bg_grid.position = Vector2(-bg_grid_edge, position.y)
		elif bg_grid.position.x < -bg_grid_edge:
			bg_grid.position = Vector2(bg_grid_edge, position.y)
		
		if bg_grid_modulate > 1:
			bg_grid_modulate -= 0.02 * (global.fps * delta)
		bg_grid.set_modulate(Color(bg_grid_modulate, bg_grid_modulate, bg_grid_modulate))

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)
