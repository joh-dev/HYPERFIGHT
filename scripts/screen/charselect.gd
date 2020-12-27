extends Node2D

enum CHARSELECT_STATE { select, move, back }

const STR_ARCADE_TIME = "%02d:%02d:%03d"
const STR_ARCADE_NOTCOMPLETED = "Not\ncompleted"

var state = CHARSELECT_STATE.select
var min_bg_move = 1
var max_bg_move = 15
var bg_move_player1 = min_bg_move
var bg_move_player2 = min_bg_move
var transition_alpha = 0
var change_alpha = 0.1
var move_timer = -1
var max_move_timer = 120
var square_timer = 0
var max_square_timer = 5

var lobby_init = false
var lobby_id = 0
var last_highlighted_char = global.CHAR.goto
var confirmed_player1 = false
var confirmed_player2 = false
var set_char = false

onready var audio = get_node("AudioStreamPlayer")
onready var bg_grid_player1 = get_node("bg_grid_player1")
onready var bg_grid_player2 = get_node("bg_grid_player2")
onready var transition = get_node("transition")
onready var portraits = get_node("portraits")
onready var preview_player1 = get_node("preview_player1")
onready var preview_player2 = get_node("preview_player2")
onready var portrait_player1 = get_node("portraits/portrait_goto")
onready var portrait_player2 = get_node("portraits/portrait_goto")
onready var portrait_darkgoto = get_node("portraits/portrait_darkgoto")
onready var online_labels = get_node("online_labels")
onready var label_name_player1 = get_node("online_labels/label_name_player1")
onready var label_name_player2 = get_node("online_labels/label_name_player2")
onready var label_timer = get_node("online_labels/label_timer")
onready var label_time = get_node("label_time")
onready var menu_yesno = get_node("menu_yesno")
onready var online_timer = get_node("online_timer")

onready var grid_square = preload("res://scenes/ui/select/grid_square.tscn")

onready var msc_charselect = preload("res://audio/music/menu/charselect.ogg")
onready var snd_select = preload("res://audio/sfx/menu/select1.ogg")
onready var snd_select2 = preload("res://audio/sfx/menu/select2.ogg")

func _ready():
	transition.visible = true
	if global.mode == global.MODE.arcade:
		preview_player2.visible = false
	else:
		label_time.visible = false
	if not global_audio.playing:
		global_audio.stream = msc_charselect
		global_audio.play(0)
	
	if global.mode == global.MODE.online_lobby:
		update_lobby_names()
		online_labels.visible = true
		online_timer.start()
	else:
		online_labels.visible = false

func _process(delta):
	if global.steam_enabled:
		Steam.run_callbacks()
		
		if global.mode == global.MODE.online_lobby:
			if not (confirmed_player1 or confirmed_player2) or global.lobby_state == global.LOBBY_STATE.spectate:
				var packet_size = Steam.getAvailableP2PPacketSize(0)
				while packet_size > 0:
					var packet_dict = Steam.readP2PPacket(packet_size, 0)
					var packet = packet_dict["data"]
					var sender_id = packet_dict["steamIDRemote"]
					var packet_type = packet[0]
					match packet_type:
						global.P_TYPE.cs_highlight:
							var player1 = (packet[1] == 1)
							var packet_char = packet[2]
							var highlight_portrait = null
							for portrait in portraits.get_children():
								if portrait.orig_char == packet_char:
									highlight_portrait = portrait
							if highlight_portrait != null:
								if player1:
									portrait_player1 = highlight_portrait
									preview_player1.set_char(packet_char)
								else:
									portrait_player2 = highlight_portrait
									preview_player2.set_char(packet_char)
						global.P_TYPE.cs_select:
							var player1 = (packet[1] == 1)
							var packet_char = packet[2]
							var highlight_portrait = null
							for portrait in portraits.get_children():
								if portrait.orig_char == packet_char:
									highlight_portrait = portrait
							if highlight_portrait != null:
								if player1:
									portrait_player1 = highlight_portrait
									portrait_player1.select_confirm()
									preview_player1.set_char(packet_char)
								else:
									portrait_player2 = highlight_portrait
									portrait_player2.select_confirm()
									preview_player2.set_char(packet_char)
								play_audio(snd_select)
							if player1:
								preview_player1.select()
							else:
								preview_player2.select()
						global.P_TYPE.cs_back:
							var player1 = (packet[1] == 1)
							if player1:
								preview_player1.back()
							else:
								preview_player2.back()
						global.P_TYPE.cs_palette:
							var player1 = (packet[1] == 1)
							var palette_num = packet[2]
							if player1:
								if not preview_player1.selected_palette:
									if palette_num > global.get_char_max_palette(preview_player1.curr_char):
										palette_num = -1
									preview_player1.set_palette_num(palette_num)
							else:
								if not preview_player2.selected_palette:
									if palette_num > global.get_char_max_palette(preview_player2.curr_char):
										palette_num = -1
									preview_player2.set_palette_num(palette_num)
						global.P_TYPE.cs_select_palette:
							var player1 = (packet[1] == 1)
							var palette_num = packet[2]
							if player1:
								if palette_num > global.get_char_max_palette(preview_player1.curr_char):
									palette_num = -1
								preview_player1.set_palette_num(palette_num)
								preview_player1.select_palette()
							else:
								if palette_num > global.get_char_max_palette(preview_player2.curr_char):
									palette_num = -1
								preview_player2.set_palette_num(palette_num)
								preview_player2.select_palette()
							play_audio(snd_select)
						global.P_TYPE.cs_confirmed_player1:
							global.set_char(packet[1], packet[2], 1)
							confirmed_player1 = true
							if not global.lobby_join:
								global.relay_packet(packet)
							if global.lobby_state != global.LOBBY_STATE.spectate:
								break
						global.P_TYPE.cs_confirmed_player2:
							global.set_char(packet[1], packet[2], 2)
							confirmed_player2 = true
							if not global.lobby_join:
								global.relay_packet(packet)
							if global.lobby_state != global.LOBBY_STATE.spectate:
								break
						global.P_TYPE.lobby_return:
							if global.lobby_join:
								get_tree().change_scene(global.SCENE_ONLINE_LOBBY)
								break
					packet_size = Steam.getAvailableP2PPacketSize(0)
					
					if not global.lobby_join and packet_type != global.P_TYPE.lobby_init:
						global.relay_packet(packet)
				
				if (global.lobby_state == global.LOBBY_STATE.player1 and not preview_player1.selected and last_highlighted_char != preview_player1.curr_char) or \
				   (global.lobby_state == global.LOBBY_STATE.player2 and not preview_player2.selected and last_highlighted_char != preview_player2.curr_char):
					broadcast_packet_highlight()
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	label_timer.text = str(int(online_timer.time_left))
	
	preview_player1.process(delta)
	preview_player2.process(delta)
	if bg_move_player1 > min_bg_move:
		bg_move_player1 -= 0.5 * (global.fps * delta)
	else:
		bg_move_player1 = min_bg_move
	if bg_move_player2 > min_bg_move:
		bg_move_player2 -= 0.5 * (global.fps * delta)
	else:
		bg_move_player2 = min_bg_move
	
	if square_timer <= 0:
		if randi() % 5 < 1:
			var g = grid_square.instance()
			if randi() % 2 < 1:
				g.position = Vector2(-56 + (randi() % 8) * 16, -72)
			else:
				g.position = Vector2(-56 + (randi() % 8) * 16, 72)
				g.up = true
			add_child(g)
		square_timer = max_square_timer
	else:
		square_timer -= 1 * (global.fps * delta)
	
	if menu_yesno.active:
		transition.set_modulate(Color(1, 1, 1, 0.75))
	elif state == CHARSELECT_STATE.select:
		if transition_alpha > 0:
			transition_alpha -= change_alpha * (global.fps * delta)
		
		if global.mode != global.MODE.online_lobby or not online_timer.is_stopped():
			var selected = false
			
			if global.mode != global.MODE.online_lobby or global.lobby_state == global.LOBBY_STATE.player1:
				if not preview_player1.selected:
					portrait_player1 = portrait_player1.select(1)
					if global.mode == global.MODE.arcade:
						var time = global.get_record_arcade(preview_player1.curr_char)
						label_time.visible = (preview_player1.curr_char != global.CHAR.random)
						if time != null and time >= 0:
							var mins = time / 3600
							var secs = (time / 60) % 60
							var msecs = floor((time % 60) * 16.667)
							if mins > 99:
								mins = 99
							label_time.text = STR_ARCADE_TIME % [mins, secs, msecs]
						else:
							label_time.text = STR_ARCADE_NOTCOMPLETED
					if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
						highlight_portraits()
						portrait_player1.select_confirm()
						preview_player1.select()
						bg_move_player1 = max_bg_move
						play_audio(snd_select)
						selected = true
						broadcast_packet_select()
					if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_SPECIAL) and global.mode != global.MODE.online_lobby:
						menu_yesno.active = true
						play_audio(snd_select2)
				elif not preview_player1.selected_palette:
					if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_LEFT):
						preview_player1.previous_palette()
						broadcast_packet_palette()
					if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_RIGHT):
						preview_player1.next_palette()
						broadcast_packet_palette()
					if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
						preview_player1.select_palette()
						bg_move_player1 = max_bg_move
						play_audio(snd_select)
						selected = true
						broadcast_packet_select_palette()
			
			if global.mode != global.MODE.online_lobby or global.lobby_state == global.LOBBY_STATE.player2:
				if not preview_player2.selected:
					if global.mode == global.MODE.arcade:
						preview_player2.selected = true
						preview_player2.selected_palette = true
					elif global.mode == global.MODE.versus_cpu or global.mode == global.MODE.training or global.mode == global.MODE.online_lobby:
						if (preview_player1.selected_palette or global.mode == global.MODE.online_lobby) and not selected:
							portrait_player2 = portrait_player2.select(1)
							if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
								highlight_portraits()
								portrait_player2.select_confirm()
								preview_player2.select()
								bg_move_player2 = max_bg_move
								play_audio(snd_select)
								broadcast_packet_select()
					elif global.mode == global.MODE.versus_player:
						portrait_player2 = portrait_player2.select(2)
						if Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_ATTACK):
							highlight_portraits()
							portrait_player2.select_confirm()
							preview_player2.select()
							bg_move_player2 = max_bg_move
							play_audio(snd_select)
				elif not preview_player2.selected_palette:
					if global.mode == global.MODE.versus_cpu or global.mode == global.MODE.training or global.mode == global.MODE.online_lobby:
						if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_LEFT):
							preview_player2.previous_palette()
							broadcast_packet_palette()
						if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_RIGHT):
							preview_player2.next_palette()
							broadcast_packet_palette()
						if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
							preview_player2.select_palette()
							bg_move_player2 = max_bg_move
							play_audio(snd_select)
							selected = true
							broadcast_packet_select_palette()
					elif global.mode == global.MODE.versus_player:
						if Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_LEFT):
							preview_player2.previous_palette()
						if Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_RIGHT):
							preview_player2.next_palette()
						if Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_ATTACK):
							preview_player2.select_palette()
							bg_move_player2 = max_bg_move
							play_audio(snd_select)
							selected = true
			
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_SPECIAL):
				if (global.mode == global.MODE.versus_cpu or global.mode == global.MODE.training or \
				   (global.mode == global.MODE.online_lobby and global.lobby_state == global.LOBBY_STATE.player2)) and \
				   (preview_player2.selected or preview_player2.selected_palette):
					preview_player2.back()
					broadcast_packet_back()
				elif global.mode != global.MODE.online_lobby or \
					(global.mode == global.MODE.online_lobby and global.lobby_state == global.LOBBY_STATE.player1):
					preview_player1.back()
					broadcast_packet_back()
			elif Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_SPECIAL):
				if global.mode == global.MODE.versus_player:
					preview_player2.back()
			
		highlight_portraits()
		
		if preview_player1.selected_palette and preview_player2.selected_palette:
			move_timer = max_move_timer
			transition_alpha = 0
			state = CHARSELECT_STATE.move
			if global.mode == global.MODE.arcade:
				global_audio.stop()
	elif state == CHARSELECT_STATE.back:
		if transition_alpha < 4:
			transition_alpha += change_alpha * (global.fps * delta)
		else:
			global.leave_lobby(false)
			get_tree().change_scene(global.SCENE_MENU)
	else:
		label_timer.visible = false
		if move_timer > 0:
			move_timer -= 1 * (global.fps * delta)
			if transition_alpha < 1 and move_timer < max_move_timer / 4:
				transition_alpha += change_alpha * (global.fps * delta)
		else:
			if not global.mode == global.MODE.online_lobby:
				global.set_char(preview_player1.curr_char, preview_player1.palette_num, 1)
				global.set_char(preview_player2.curr_char, preview_player2.palette_num, 2)
				global.differ_palettes()
				if global.mode == global.MODE.arcade:
					global.init_arcade_mode(global.player1_char)
					get_tree().change_scene(global.SCENE_VSSCREEN)
				else:
					get_tree().change_scene(global.SCENE_STAGESELECT)
			elif global.lobby_state == global.LOBBY_STATE.player1:
				if not set_char:
					global.set_char(preview_player1.curr_char, preview_player1.palette_num, 1)
					broadcast_packet_confirmed_player1()
					set_char = true
				if confirmed_player2:
					global.differ_palettes()
					if global.stage_select == global.STAGE_SELECT.random:
						get_tree().change_scene(global.SCENE_VSSCREEN)
					else:
						get_tree().change_scene(global.SCENE_STAGESELECT)
			elif global.lobby_state == global.LOBBY_STATE.player2:
				if not set_char:
					global.set_char(preview_player2.curr_char, preview_player2.palette_num, 2)
					broadcast_packet_confirmed_player2()
					set_char = true
				if confirmed_player1:
					global.differ_palettes()
					if global.stage_select == global.STAGE_SELECT.random:
						get_tree().change_scene(global.SCENE_VSSCREEN)
					else:
						get_tree().change_scene(global.SCENE_STAGESELECT)
			else:
				if confirmed_player1 and confirmed_player2:
					global.differ_palettes()
					if global.stage_select == global.STAGE_SELECT.random:
						get_tree().change_scene(global.SCENE_VSSCREEN)
					else:
						get_tree().change_scene(global.SCENE_STAGESELECT)
	
	bg_grid_player1.position = Vector2(bg_grid_player1.position.x, bg_grid_player1.position.y + bg_move_player1 * (global.fps * delta))
	if bg_grid_player1.position.y > 80:
		bg_grid_player1.position = Vector2(bg_grid_player1.position.x, -80)
	bg_grid_player2.position = Vector2(bg_grid_player2.position.x, bg_grid_player2.position.y + bg_move_player2 * (global.fps * delta))
	if bg_grid_player2.position.y > 80:
		bg_grid_player2.position = Vector2(bg_grid_player2.position.x, -80)

func highlight_portraits():
	for portrait in portraits.get_children():
		portrait.set_highlight(0)
		if portrait == portrait_player1:
			portrait.set_highlight(1)
			preview_player1.set_char(portrait.character)
		if portrait == portrait_player2 and \
		   (global.mode == global.MODE.versus_player or global.mode == global.MODE.versus_cpu or \
			global.mode == global.MODE.training or global.mode == global.MODE.online_lobby):
			portrait.set_highlight(2)
			preview_player2.set_char(portrait.character)

func back():
	state = CHARSELECT_STATE.back
	global_audio.stop()

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)

func update_lobby_names():
	label_name_player1.text = Steam.getFriendPersonaName(global.lobby_member_ids[0])
	label_name_player2.text = Steam.getFriendPersonaName(global.lobby_member_ids[1])

func broadcast_packet_highlight():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.cs_highlight)
		if global.lobby_state == global.LOBBY_STATE.player1:
			packet.append(1)
			packet.append(preview_player1.curr_char)
			last_highlighted_char = preview_player1.curr_char
		else:
			packet.append(2)
			packet.append(preview_player2.curr_char)
			last_highlighted_char = preview_player2.curr_char
		global.broadcast_packet(packet)

func broadcast_packet_select():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.cs_select)
		if global.lobby_state == global.LOBBY_STATE.player1:
			packet.append(1)
			packet.append(preview_player1.curr_char)
		else:
			packet.append(2)
			packet.append(preview_player2.curr_char)
		global.broadcast_packet(packet)

func broadcast_packet_back():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.cs_back)
		if global.lobby_state == global.LOBBY_STATE.player1:
			packet.append(1)
		else:
			packet.append(2)
		global.broadcast_packet(packet)

func broadcast_packet_palette():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.cs_palette)
		if global.lobby_state == global.LOBBY_STATE.player1:
			packet.append(1)
			packet.append(preview_player1.palette_num)
		else:
			packet.append(2)
			packet.append(preview_player2.palette_num)
		global.broadcast_packet(packet)

func broadcast_packet_select_palette():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.cs_select_palette)
		if global.lobby_state == global.LOBBY_STATE.player1:
			packet.append(1)
			packet.append(preview_player1.palette_num)
		else:
			packet.append(2)
			packet.append(preview_player2.palette_num)
		global.broadcast_packet(packet)

func broadcast_packet_confirmed_player1():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.cs_confirmed_player1)
		packet.append(global.player1_char)
		packet.append(global.player1_palette)
		global.broadcast_packet(packet)

func broadcast_packet_confirmed_player2():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.cs_confirmed_player2)
		packet.append(global.player2_char)
		packet.append(global.player2_palette)
		global.broadcast_packet(packet)

func _on_online_timer_timeout():
	if state == CHARSELECT_STATE.select:
		if global.lobby_state == global.LOBBY_STATE.player1:
			if not preview_player1.selected:
				portrait_player1.select_confirm()
				preview_player1.select()
				bg_move_player1 = max_bg_move
				play_audio(snd_select)
				broadcast_packet_select()
			if not preview_player1.selected_palette:
				preview_player1.select_palette()
				bg_move_player1 = max_bg_move
				play_audio(snd_select)
				broadcast_packet_select_palette()
		elif global.lobby_state == global.LOBBY_STATE.player2:
			if not preview_player2.selected:
				portrait_player2.select_confirm()
				preview_player2.select()
				bg_move_player2 = max_bg_move
				play_audio(snd_select)
				broadcast_packet_select()
			if not preview_player2.selected_palette:
				preview_player2.select_palette()
				bg_move_player2 = max_bg_move
				play_audio(snd_select)
				broadcast_packet_select_palette()
