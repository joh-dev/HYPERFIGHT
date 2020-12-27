extends Node2D

enum ARCADEWIN_STATE { congrats, time, unlock, unlocked, ok, ok_select, transition }

const STR_NEWRECORD = "New record!"
const STR_TIME = "%02d:%02d:%03d"
const STR_COLOR4 = "%s\nColor 4"
const STR_CHARACTER = "Character\n%s"
const STR_STAGE = "Stage\n%s"

var state = ARCADEWIN_STATE.congrats
var max_press_timer = 120
var press_timer = max_press_timer
var bg_move = 4
var bg_grid_edge = 128
var transition_alpha = 1
var change_alpha = 0.1
var ignore_first_delta = true

onready var audio = get_node("AudioStreamPlayer")
onready var bg_grid = get_node("bg_grid")
onready var transition = get_node("transition")
onready var preview_player1 = get_node("preview_player1")
onready var label_congrats = get_node("label_congrats")
onready var label_time = get_node("labels/label_time")
onready var label_time2 = get_node("labels/label_time/label_time2")
onready var label_unlock = get_node("labels/label_unlock")
onready var button_ok = get_node("button_ok")

onready var msc_arcade_win = preload("res://audio/music/menu/arcadewin.ogg")
onready var snd_select = preload("res://audio/sfx/menu/select1.ogg")
onready var snd_select2 = preload("res://audio/sfx/menu/select2.ogg")

func _ready():
	global_audio.stop()
	global_audio.stream = msc_arcade_win
	global_audio.play(0)
	transition.visible = true
	preview_player1.set_char(global.player1_char)
	preview_player1.set_palette_num(global.player1_palette)
	preview_player1.select()
	label_time.visible = false
	label_unlock.visible = false
	button_ok.active = false

func _process(delta):
	if ignore_first_delta:
		delta = 0
		ignore_first_delta = false
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	preview_player1.process(delta)
	
	match state:
		ARCADEWIN_STATE.congrats:
			if transition_alpha > 0:
				transition_alpha -= change_alpha * (global.fps * delta)
			if press_timer > 0:
				press_timer -= 1 * (global.fps * delta)
			elif press_timer <= 0:
				label_time.visible = true
				var time = global.get_record_arcade(global.player1_char)
				if time < 0 or global.arcade_time < time:
					label_time2.text = STR_NEWRECORD
					global.set_record_arcade(global.player1_char, global.arcade_time)
				var mins = global.arcade_time / 3600
				var secs = (global.arcade_time / 60) % 60
				var msecs = floor((global.arcade_time % 60) * 16.667)
				if mins > 99:
					mins = 99
				label_time.text = STR_TIME % [mins, secs, msecs]
				press_timer = max_press_timer
				state = ARCADEWIN_STATE.time
		ARCADEWIN_STATE.time:
			if press_timer > 0:
				press_timer -= 1 * (global.fps * delta)
			elif press_timer <= 0:
				state = ARCADEWIN_STATE.unlock
		ARCADEWIN_STATE.unlock:
			if not global.is_color4_unlocked(global.player1_char):
				global.unlock_color4(global.player1_char)
				label_unlock.visible = true
				label_unlock.text = STR_COLOR4 % global.get_char_real_name(global.player1_char)
				press_timer = max_press_timer
				state = ARCADEWIN_STATE.unlocked
				play_audio(snd_select)
			else:
				var unlock_char = global.unlock_char()
				if unlock_char != null:
					label_unlock.visible = true
					label_unlock.text = STR_CHARACTER % global.get_char_real_name(unlock_char)
					press_timer = max_press_timer
					state = ARCADEWIN_STATE.unlocked
					play_audio(snd_select)
				else:
					var unlock_stage = global.unlock_stage()
					if unlock_stage != null:
						label_unlock.visible = true
						label_unlock.text = STR_STAGE % global.get_stage_real_name(unlock_stage)
						press_timer = max_press_timer
						state = ARCADEWIN_STATE.unlocked
						play_audio(snd_select)
					else:
						button_ok.active = true
						state = ARCADEWIN_STATE.ok
		ARCADEWIN_STATE.unlocked:
			if press_timer > 0:
				press_timer -= 1 * (global.fps * delta)
			elif press_timer <= 0:
				state = ARCADEWIN_STATE.unlock
		ARCADEWIN_STATE.ok:
			button_ok.highlight(1)
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
				button_ok.select(1)
				press_timer = max_press_timer / 2
				state = ARCADEWIN_STATE.ok_select
				play_audio(snd_select2)
		ARCADEWIN_STATE.ok_select:
			if press_timer > 0:
				press_timer -= 1 * (global.fps * delta)
			elif press_timer <= 0:
				state = ARCADEWIN_STATE.transition
		_:
			if transition_alpha < 4:
				transition_alpha += change_alpha * (global.fps * delta)
			else:
				get_tree().change_scene(global.SCENE_MENU)
	
	if bg_move != 0:
		bg_grid.position = Vector2(bg_grid.position.x + bg_move * (global.fps * delta), bg_grid.position.y)
		if bg_grid.position.x > bg_grid_edge:
			bg_grid.position = Vector2(-bg_grid_edge, position.y)
		elif bg_grid.position.x < -bg_grid_edge:
			bg_grid.position = Vector2(bg_grid_edge, position.y)

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)
