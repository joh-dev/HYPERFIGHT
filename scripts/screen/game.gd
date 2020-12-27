extends Node2D

enum GAME_STATE { ready, fight, go, ko, super, win, perfect, draw, premenu, \
				  pause_select, \
				  menu, menu_select, \
				  _continue, continue_select, \
				  restart, restart_select, \
				  next_stage, \
				  end_tutorial, \
				  other_player_wait, \
				  menu_select_online, \
				  rematch, rematch_select }

const STR_READY = "Ready..."
const STR_FIGHT = "FIGHT!"
const STR_KO = "K.O.!"
const STR_DOUBLEKO = "DOUBLE K.O.!"
const STR_SUPERKO = "SUPER K.O.!!"
const STR_DOUBLESUPERKO = "DOUBLE SUPER K.O.!"
const STR_PLAYER1WIN = "Player 1 wins!"
const STR_PLAYER2WIN = "Player 2 wins!"
const STR_PERFECT = "PERFECT"
const STR_DRAW = "DRAW"
const STR_ARCADE_CONTINUES = "Continues: %s"
const STR_ONLINE_DELAY = "Delay: %sf"
const STR_ONLINE_WIN = "%s win"
const STR_ONLINE_WINS = "s"
const STR_INFO = " selected "
const STR_INFO_REMATCH = "Rematch"
const STR_INFO_STAGESELECT = "Stage Select"
const STR_INFO_CHARSELECT = "Char. Select"
const STR_INFO_MAINMENU = "Main Menu"
const STR_INFO_BACKTOLOBBY = "Back to Lobby"

const STR_TUTORIAL = [ \
	"Welcome to HYPERFIGHT!", \
	"We're going to start with the basics of movement, so listen closely.", \
	"Try moving left and right. You can also jump straight up, forwards, and backwards.", \
	"Even if you jump over and switch sides with your opponent, you'll always be facing them.", \
	"Another key part of movement is dashing.", \
	"On the ground, double tap left or right, or hold the Left/Right + Dash buttons, to perform a dash.", \
	"In the air, you can dash in any direction! However, dashing up will only keep you in place.", \
	"It's very important to master dashing, as you're granted invincibility during a dash.", \
	"Now try attacking your opponent! Press the Attack button to use your normal attack.", \
	"Good! Some attacks can even be angled by holding a direction while attacking.", \
	"Your character may have multiple normal attacks, so try checking the move list from the pause menu.", \
	"Any attack you land on your opponent is a knockout, winning the round.", \
	"Points are shown above your name, and you get 1 point for winning a round.", \
	"In this game, you'll have to risk some of your points to gain access to stronger moves.", \
	"Your special attack can only be used if you have at least 1 point. For Shoto Goto, it's a parry.", \
	"Try parrying your opponent's attack!", \
	"Time your parry with the opponent's projectile. Try again! (Be sure to parry only once.)", \
	"Good! You're invincible while using a special attack, so use them to beat out normal attacks.", \
	"Note that a point used for a move cannot be used for another move in the same round.", \
	"Usable points are green, while used points are red. If you lose the round, you also lose your red points.", \
	"However, if you win the round, you keep the points you used and get to use them again for the next round!", \
	"Some moves have special properties. You might notice that your character now has one green and one red point.", \
	"Because you successfully landed the parry, you got back the green point you used plus one red point.", \
	"Now try using your super attack by pressing the Super button, or Attack + Special buttons at the same time.", \
	"Try hitting the opponent with your super attack.", \
	"Nice work! Your super attack costs 2 points, but for most characters,", \
	"landing it will instantly win you the whole game!", \
	"That's all for the tutorial. Try fighting computer opponents in VS CPU or ARCADE MODE to grow stronger!"
]

const buttons_quickmatch_max = 2
const buttons_arcade_max = 3
const buttons_training_max = 5
const buttons_tutorial_max = 2

const delay_buffer = 5
const max_change_delay_timer = 10
const double_frame_time = 2 * (1.0 / Engine.iterations_per_second) * 1000

const change_alpha = 0.06
const max_round_win_timer = 60
const max_delay_timer = 30
const max_press_timer = 60
const transition_fade_alpha = 0.75

var curr_frame = 0
var frame_delay = 0
var input_delay = global.input_delay
var prev_delay = input_delay
var target_delay = input_delay
var change_delay_timer = 0
var player1_frame = 0
var player2_frame = 0
var last_other_frame = 0
var last_other_delay = 0
var last_ping_time = OS.get_ticks_msec()

var transition_alpha = 1
var win_player_num = -1
var state = GAME_STATE.fight
var unpaused_state = GAME_STATE.fight
var win_timer = 90
var delay_timer = -1
var super_frame_delay = 15
var parry_frame_delay = 5
var player_xoffset = 70
var player_yoffset = global.floor_y - 32
var player1
var player2
var player1_scored = false
var player2_scored = false
var my_player
var press_timer = -1
var tutorial_timer = -1
var max_tutorial_timer = 180
var tutorial_index = 0
var option = 1
var other_option = -1
var max_option = 4
var game_over = false
var paused = false
var paused_music = false
var pause_music_pos
var show_hitboxes = false
var reset_pos = global.RESET_POS.middle
var active_buttons

onready var label_player1 = get_node("GUILayer/label_player1")
onready var label_player1_wins = get_node("GUILayer/label_player1/label_wins")
onready var meter_player1_scythe = get_node("GUILayer/label_player1/meter_scythe")
onready var label_player2 = get_node("GUILayer/label_player2")
onready var label_player2_wins = get_node("GUILayer/label_player2/label_wins")
onready var meter_player2_scythe = get_node("GUILayer/label_player2/meter_scythe")
onready var label_delay = get_node("GUILayer/label_delay")
onready var label_paused = get_node("GUILayer/label_paused_node/label_paused")
onready var label_center = get_node("GUILayer/label_center_node/label_center")
onready var label_timer = get_node("GUILayer/label_timer_node/label_time")
onready var transition = get_node("GUILayer/transition")
onready var menu_banner = get_node("GUILayer/menu_banner")
onready var buttons_menu = get_node("GUILayer/buttons_menu")
onready var buttons_menu_online = get_node("GUILayer/buttons_menu_online")
onready var buttons_rematch = get_node("GUILayer/buttons_rematch")
onready var buttons_continue = get_node("GUILayer/buttons_continue")
onready var buttons_continue_label = get_node("GUILayer/buttons_continue/button_continue/label_continues")
onready var buttons_restart = get_node("GUILayer/buttons_restart")
onready var buttons_restart_label = get_node("GUILayer/buttons_restart/button_restart/label_continues")
onready var buttons_trainingoptions = get_node("GUILayer/buttons_trainingoptions")
onready var buttons_pause = get_node("GUILayer/buttons_pause")
onready var buttons_pause_arcade = get_node("GUILayer/buttons_pause_arcade")
onready var buttons_pause_training = get_node("GUILayer/buttons_pause_training")
onready var buttons_pause_tutorial = get_node("GUILayer/buttons_pause_tutorial")
onready var textbox = get_node("GUILayer/textbox")
onready var move_lists = get_node("GUILayer/move_lists")
onready var move_list_p1 = get_node("GUILayer/move_lists/move_list_p1")
onready var audio = get_node("AudioStreamPlayer")
onready var objects = get_node("objects")
onready var bg_game = get_node("bg_game")
onready var online_timer = get_node("online_timer")

onready var char_goto = preload("res://scenes/char/goto.tscn")
onready var char_yoyo = preload("res://scenes/char/yoyo.tscn")
onready var char_kero = preload("res://scenes/char/kero.tscn")
onready var char_time = preload("res://scenes/char/time.tscn")
onready var char_sword = preload("res://scenes/char/sword.tscn")
onready var char_slime = preload("res://scenes/char/slime.tscn")
onready var char_darkgoto = preload("res://scenes/char/darkgoto.tscn")

onready var snd_select = preload("res://audio/sfx/menu/select1.ogg")
onready var snd_select2 = preload("res://audio/sfx/menu/select2.ogg")
onready var snd_ready = preload("res://audio/sfx/game/announcer/ready.ogg")
onready var snd_fight = preload("res://audio/sfx/game/announcer/fight1.ogg")
onready var snd_fight2 = preload("res://audio/sfx/game/announcer/fight2.ogg")
onready var snd_fight3 = preload("res://audio/sfx/game/announcer/fight3.ogg")
onready var snd_player1win = preload("res://audio/sfx/game/announcer/p1win.ogg")
onready var snd_player2win = preload("res://audio/sfx/game/announcer/p2win.ogg")
onready var snd_ko = preload("res://audio/sfx/game/announcer/ko.ogg")
onready var snd_superko = preload("res://audio/sfx/game/announcer/superko.ogg")
onready var snd_perfect = preload("res://audio/sfx/game/announcer/perfect.ogg")
onready var snd_stronghit = preload("res://audio/sfx/game/char/hit.ogg")
onready var msc_theme_goto = preload("res://audio/music/game/dojo.ogg")
onready var msc_theme_yoyo = preload("res://audio/music/game/rooftop.ogg")
onready var msc_theme_kero = preload("res://audio/music/game/lab.ogg")
onready var msc_theme_time = preload("res://audio/music/game/company.ogg")
onready var msc_theme_sword = preload("res://audio/music/game/bridge.ogg")
onready var msc_theme_slime = preload("res://audio/music/game/factory.ogg")
onready var msc_theme_scythe = preload("res://audio/music/game/sanctuary.ogg")
onready var msc_theme_darkgoto = preload("res://audio/music/game/blackhole.ogg")

func _ready():
	label_center.text = STR_READY
	label_delay.visible = global.online and global.lobby_state != global.LOBBY_STATE.spectate
	init_players()
	play_stage_music()
	play_audio(snd_ready)
	
	if global.turbo_mode:
		Engine.iterations_per_second = 75
	
	if global.online:
		if global.mode == global.MODE.online_quickmatch:
			max_option = buttons_quickmatch_max
		label_player1.text = Steam.getFriendPersonaName(global.lobby_member_ids[0])
		label_player2.text = Steam.getFriendPersonaName(global.lobby_member_ids[1])
		if not global.lobby_state == global.LOBBY_STATE.spectate:
			if global.lobby_state == global.LOBBY_STATE.player2:
				my_player = player2
				player1.set_online_control(false)
				player2.set_online_control(true)
			else:
				my_player = player1
				player1.set_online_control(true)
				player2.set_online_control(false)
				if global.prev_input_delay <= 0:
					send_packet_ping()
		player1.dtdash = bool(int(global.get_lobby_member_data(global.lobby_member_ids[0], global.MEMBER_LOBBY_DTDASH)))
		player1.assuper = bool(int(global.get_lobby_member_data(global.lobby_member_ids[0], global.MEMBER_LOBBY_ASSUPER)))
		player2.dtdash = bool(int(global.get_lobby_member_data(global.lobby_member_ids[1], global.MEMBER_LOBBY_DTDASH)))
		player2.assuper = bool(int(global.get_lobby_member_data(global.lobby_member_ids[1], global.MEMBER_LOBBY_ASSUPER)))
	else:
		if global.mode == global.MODE.arcade:
			buttons_pause = buttons_pause_arcade
			max_option = buttons_arcade_max
		elif global.mode == global.MODE.training:
			buttons_pause = buttons_pause_training
			max_option = buttons_training_max
			player2.cpu_type = global.CPU_TYPE.dummy_standing
		elif global.mode == global.MODE.tutorial:
			buttons_pause = buttons_pause_tutorial
			max_option = buttons_tutorial_max
			tutorial_timer = max_tutorial_timer
			player1.stop_act()
			player2.cpu_type = global.CPU_TYPE.dummy
	
	global.show_hitboxes = false
	global.clear_input_files()
	
	if global.online:
		if global.prev_input_delay <= 0:
			input_delay = 1
			global.prev_input_delay = 1
		else:
			input_delay = global.prev_input_delay
		set_wins_labels()

func set_wins_labels():
	if global.lobby_player1_wins > 0:
		label_player1_wins.visible = true
		label_player1_wins.text = STR_ONLINE_WIN % str(global.lobby_player1_wins)
		if global.lobby_player1_wins > 1:
			label_player1_wins.text += STR_ONLINE_WINS
	if global.lobby_player2_wins > 0:
		label_player2_wins.visible = true
		label_player2_wins.text = STR_ONLINE_WIN % str(global.lobby_player2_wins)
		if global.lobby_player2_wins > 1:
			label_player2_wins.text += STR_ONLINE_WINS

func init_players():
	label_player1.text = global.get_char_real_name(global.player1_char)
	if global.player1_cpu:
		label_player1.add_color_override("font_color", Color(0.5, 0.5, 0.5))
	label_player2.text = global.get_char_real_name(global.player2_char)
	if global.player2_cpu:
		label_player2.add_color_override("font_color", Color(0.8, 0.8, 0.8))
		move_list_p1.position.y += 36
	player1 = global.get_char_instance(global.player1_char)
	player2 = global.get_char_instance(global.player2_char)
	add_object(player1)
	add_object(player2)
	player1.init(1, player2)
	player2.init(2, player1)
	transition.visible = true
	meter_player1_scythe.visible = (global.player1_char == global.CHAR.scythe)
	meter_player2_scythe.visible = (global.player2_char == global.CHAR.scythe)

func play_stage_music():
	var music
	match global.stage:
		global.STAGE.dojo:
			music = msc_theme_goto
		global.STAGE.rooftop:
			music = msc_theme_yoyo
		global.STAGE.lab:
			music = msc_theme_kero
		global.STAGE.company:
			music = msc_theme_time
		global.STAGE.bridge:
			music = msc_theme_sword
		global.STAGE.factory:
			music = msc_theme_slime
		global.STAGE.sanctuary:
			music = msc_theme_scythe
		global.STAGE.blackhole:
			music = msc_theme_darkgoto
		global.STAGE.training:
			music = msc_theme_goto
	if music != null and global_audio.stream != music:
		global_audio.stream = music
		global_audio.play(0)

func show_move_lists():
	return paused and buttons_pause != buttons_trainingoptions

func add_object(new_object):
	objects.add_child(new_object)

func set_inverted(inverted):
	bg_game.set_inverted(inverted)

func super_flash():
	bg_game.set_modulate(Color(0.4, 0.4, 1))
	frame_delay = super_frame_delay

func parry_flash():
	bg_game.set_modulate(Color(0.75, 0.75, 1))
	frame_delay = parry_frame_delay

func set_zero_delay():
	bg_game.set_modulate(Color(1, 1, 1))
	if frame_delay > 2:
		frame_delay = 0

func set_zero_delay_force():
	bg_game.set_modulate(Color(1, 1, 1))
	frame_delay = 0

func inc_score(player_num):
	if state != GAME_STATE.super:
		if win_player_num < 0:
			win_player_num = player_num
		elif win_player_num != player_num:
			win_player_num = 0
		win_timer = max_round_win_timer
		frame_delay = 2
		delay_timer = max_delay_timer
		state = GAME_STATE.ko
		play_audio(snd_stronghit)
		if global.print_round_end_frame:
			print(curr_frame)
	
func win(player_num):
	if win_player_num < 0 or state == GAME_STATE.ko:
		win_player_num = player_num
	elif win_player_num != player_num:
		win_player_num = 0
	win_timer = max_round_win_timer
	frame_delay = 2
	delay_timer = max_delay_timer
	state = GAME_STATE.super
	play_audio(snd_stronghit)
	if global.print_round_end_frame:
		print(curr_frame)

func update_meter_scythe(meter_points, player_num):
	if player_num == 1:
		meter_player1_scythe.update_points(meter_points)
	elif player_num == 2:
		meter_player2_scythe.update_points(meter_points)

func get_p1_score():
	if player1 == null:
		return 0
	return player1.score

func get_p2_score():
	if player2 == null:
		return 0
	return player2.score

func set_p1_score(new_score):
	if player1 != null:
		player1.set_score(new_score)
		if player1.is_in_group(global.GROUP_CHAR_SCYTHE):
			player1.set_inf_soul_meter(new_score > 5)

func set_p2_score(new_score):
	if player2 != null:
		player2.set_score(new_score)
		if player2.is_in_group(global.GROUP_CHAR_SCYTHE):
			player2.set_inf_soul_meter(new_score > 5)

func is_p2_cpu():
	if player2 != null:
		return player2.cpu
	return true

func set_p2_cpu(is_cpu):
	if player2 != null:
		player2.cpu = is_cpu
		player2.cpu_acted = false

func get_p2_cpu_type():
	if player2 != null:
		return player2.cpu_type
	return global.CPU_TYPE.dummy_standing

func set_p2_cpu_type(cpu_type):
	if player2 != null:
		player2.cpu_type = cpu_type
		player2.cpu_acted = false

func get_reset_pos():
	return reset_pos

func set_reset_pos(reset_pos):
	self.reset_pos = reset_pos

func check_menu_input(player2_enabled):
	if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_UP) or \
	  (Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_UP) and player2_enabled and not global.player2_cpu):
		option -= 1
	if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_DOWN) or \
	  (Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_DOWN) and player2_enabled and not global.player2_cpu):
		option += 1
	if option < 1:
		option = max_option
	elif option > max_option:
		option = 1

func fade_transition_in():
	if transition_alpha < transition_fade_alpha:
		transition_alpha += change_alpha
	else:
		transition_alpha = transition_fade_alpha

func fade_transition_out():
	if transition_alpha > 0:
		transition_alpha -= change_alpha
	else:
		transition_alpha = 0

func set_transition_in():
	if transition_alpha < transition_fade_alpha:
		transition_alpha = transition_fade_alpha

func set_active_buttons():
	match state:
		GAME_STATE.menu:
			if global.mode == global.MODE.online_lobby:
				active_buttons = buttons_menu_online
			else:
				active_buttons = buttons_menu
		GAME_STATE.menu_select:
			active_buttons = buttons_menu
		GAME_STATE.menu_select_online:
			active_buttons = buttons_menu_online
		GAME_STATE.rematch, GAME_STATE.rematch_select:
			active_buttons = buttons_rematch
		GAME_STATE._continue, GAME_STATE.continue_select:
			active_buttons = buttons_continue
		GAME_STATE.restart, GAME_STATE.restart_select:
			active_buttons = buttons_restart
		GAME_STATE.pause_select:
			active_buttons = buttons_pause

func activate_buttons(curr_buttons):
	for button in curr_buttons.get_children():
		button.active = true
		button.highlight(option)

func select_button(curr_buttons):
	for button in curr_buttons.get_children():
		button.select(option)
	press_timer = max_press_timer
	play_audio(snd_select2)

func unpause():
	paused = false
	menu_banner.deactivate()
	label_paused.visible = false
	state = unpaused_state
	for button in buttons_pause.get_children():
		button.active = false
	if not paused_music:
		global_audio.play(pause_music_pos)

func _physics_process(delta):
	if global.steam_enabled:
		Steam.run_callbacks()
		
		if global.online and state != GAME_STATE.menu_select_online:
			var packet_size = Steam.getAvailableP2PPacketSize(0)
			while packet_size > 0:
				var packet_dict = Steam.readP2PPacket(packet_size, 0)
				var packet = packet_dict["data"]
				var sender_id = packet_dict["steamIDRemote"]
				var packet_type = packet[0]
				match packet_type:
					global.P_TYPE.lobby_init:
						if not global.lobby_join:
							global.spectator_member_ids.erase(sender_id)
					global.P_TYPE.game_input:
						var copy_frame = int(packet.subarray(11, -1).get_string_from_ascii())
						var copy_delay = packet[10]
						var copy_map = { \
						  global.INPUT_ACTION_LEFT: bool(packet[2]), \
						  global.INPUT_ACTION_RIGHT: bool(packet[3]), \
						  global.INPUT_ACTION_UP: bool(packet[4]), \
						  global.INPUT_ACTION_DOWN: bool(packet[5]), \
						  global.INPUT_ACTION_ATTACK: bool(packet[6]), \
						  global.INPUT_ACTION_SPECIAL: bool(packet[7]), \
						  global.INPUT_ACTION_SUPER: bool(packet[8]), \
						  global.INPUT_ACTION_DASH: bool(packet[9]) }
						player1.add_online_input(packet[1], copy_map, copy_frame, copy_delay, false)
						player2.add_online_input(packet[1], copy_map, copy_frame, copy_delay, false)
					global.P_TYPE.game_menu:
						var player1 = (packet[1] == 1)
						var info_text
						if player1 and global.lobby_member_ids.size() > 0:
							info_text = Steam.getFriendPersonaName(global.lobby_member_ids[0]) + STR_INFO
						elif player2 and global.lobby_member_ids.size() > 1:
							info_text = Steam.getFriendPersonaName(global.lobby_member_ids[1]) + STR_INFO
						if global.lobby_state == global.LOBBY_STATE.spectate and player1:
							option = packet[2]
						else:
							other_option = packet[2]
						if global.mode == global.MODE.online_lobby:
							if state == GAME_STATE.other_player_wait:
								state = GAME_STATE.menu_select_online
								press_timer = max_press_timer
								if option > 1 or other_option > 1:
									global_audio.stop()
							elif global.lobby_state == global.LOBBY_STATE.spectate:
								state = GAME_STATE.other_player_wait
							match packet[2]:
								1:
									info_text += STR_INFO_REMATCH
								2:
									info_text += STR_INFO_STAGESELECT
								3:
									info_text += STR_INFO_CHARSELECT
								4:
									info_text += STR_INFO_BACKTOLOBBY
						else:
							if state == GAME_STATE.other_player_wait:
								state = GAME_STATE.rematch_select
								if option > 1 or other_option > 1:
									global_audio.stop()
							match other_option:
								1:
									info_text += STR_INFO_REMATCH
								2:
									info_text += STR_INFO_MAINMENU
						global.create_info_text(info_text)
						play_audio(snd_select2)
					global.P_TYPE.game_ping:
						var ping_time = OS.get_ticks_msec() - last_ping_time
						last_ping_time = OS.get_ticks_msec()
						target_delay = ceil((ping_time + delay_buffer) / double_frame_time)
						send_packet_ping()
					global.P_TYPE.lobby_return:
						if global.lobby_join:
							get_tree().change_scene(global.SCENE_ONLINE_LOBBY)
							break
				packet_size = Steam.getAvailableP2PPacketSize(0)
				
				if not global.lobby_join and packet_type != global.P_TYPE.lobby_init and packet_type != global.P_TYPE.game_ping:
					global.relay_packet(packet)
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	label_timer.text = str(int(online_timer.time_left))
	
	if frame_delay <= 0:
		bg_game.set_modulate(Color(1, 1, 1))
	if show_move_lists() and move_lists.position.x > 1:
		move_lists.position.x += (0 - move_lists.position.x) / 4
	elif not show_move_lists() and move_lists.position.x < 199:
		move_lists.position.x += (200 - move_lists.position.x) / 4
	if paused and state != GAME_STATE.pause_select:
		fade_transition_in()
		check_menu_input(true)
		
		for button in buttons_pause.get_children():
			button.active = true
			button.highlight(option)
		if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK) or \
		  (Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_ATTACK) and not global.player2_cpu):
			if not (buttons_pause == buttons_trainingoptions and option <= 5):
				play_audio(snd_select2)
			if buttons_pause == buttons_pause_training and option == 2:
				for button in buttons_pause.get_children():
					button.active = false
				buttons_pause = buttons_trainingoptions
				max_option = 7
				option = 1
			elif buttons_pause == buttons_trainingoptions and option == 6:
				match reset_pos:
					global.RESET_POS.middle:
						player1.reset_pos(Vector2(-player_xoffset, player_yoffset))
						player2.reset_pos(Vector2(player_xoffset, player_yoffset))
						player1.sprite.scale.x = 1
						player2.sprite.scale.x = -1
					global.RESET_POS.middleL:
						player1.reset_pos(Vector2(player_xoffset, player_yoffset))
						player2.reset_pos(Vector2(-player_xoffset, player_yoffset))
						player1.sprite.scale.x = -1
						player2.sprite.scale.x = 1
					global.RESET_POS.left:
						player1.reset_pos(Vector2(-90, player_yoffset))
						player2.reset_pos(Vector2(-120, player_yoffset))
						player1.sprite.scale.x = -1
						player2.sprite.scale.x = 1
					global.RESET_POS.leftR:
						player1.reset_pos(Vector2(-120, player_yoffset))
						player2.reset_pos(Vector2(-90, player_yoffset))
						player1.sprite.scale.x = 1
						player2.sprite.scale.x = -1
					global.RESET_POS.right:
						player1.reset_pos(Vector2(90, player_yoffset))
						player2.reset_pos(Vector2(120, player_yoffset))
						player1.sprite.scale.x = 1
						player2.sprite.scale.x = -1
					global.RESET_POS.rightL:
						player1.reset_pos(Vector2(120, player_yoffset))
						player2.reset_pos(Vector2(90, player_yoffset))
						player1.sprite.scale.x = -1
						player2.sprite.scale.x = 1
				player1.reset_training()
				player2.reset_training()
				set_zero_delay_force()
				for object in objects.get_children():
					if object != player1 and object != player2 and \
					   object != player1.get_shadow() and object != player2.get_shadow():
						if object.is_in_group(global.GROUP_PROJECTILE):
							object.destroy_no_effect()
						else:
							object.queue_free()
				state = GAME_STATE.go
				label_center.visible = false
				win_timer = -1
			elif buttons_pause == buttons_trainingoptions and option == 7:
				for button in buttons_pause.get_children():
					button.active = false
				buttons_pause = buttons_pause_training
				max_option = 5
				option = 1
			elif not (buttons_pause == buttons_trainingoptions and option <= 5):
				for button in buttons_pause.get_children():
					button.select(option)
				press_timer = max_press_timer
				state = GAME_STATE.pause_select
		elif Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_SPECIAL) or \
			(Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_SPECIAL) and not global.player2_cpu):
			if buttons_pause == buttons_trainingoptions:
				for button in buttons_pause.get_children():
					button.active = false
				buttons_pause = buttons_pause_training
				max_option = 5
				option = 1
	else:
		set_active_buttons()
		match state:
			GAME_STATE.menu:
				fade_transition_in()
				if not global.online or global.lobby_state != global.LOBBY_STATE.spectate:
					check_menu_input(global.online)
				activate_buttons(active_buttons)
				
				if not global.online or global.lobby_state != global.LOBBY_STATE.spectate:           
					if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK) or \
					  (Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_ATTACK) and not global.player2_cpu) or global.auto_rematch:
						select_button(active_buttons)
						if global.mode == global.MODE.online_lobby:
							broadcast_packet_menu()
							if other_option > 0:
								state = GAME_STATE.menu_select_online
								if option > 1 or other_option > 1:
									global_audio.stop()
							else:
								state = GAME_STATE.other_player_wait
						else:
							state = GAME_STATE.menu_select
							if option != 1:
								global_audio.stop()
			GAME_STATE.rematch:
				fade_transition_in()
				check_menu_input(global.online)
				activate_buttons(active_buttons)
				
				if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK) or \
				  (Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_ATTACK) and not global.player2_cpu):
					select_button(active_buttons)
					broadcast_packet_menu()
					if option == 2 or other_option > 0:
						state = GAME_STATE.rematch_select
						if option > 1 or other_option > 1:
							global_audio.stop()
					else:
						state = GAME_STATE.other_player_wait
			GAME_STATE._continue:
				fade_transition_in()
				check_menu_input(false)
				activate_buttons(active_buttons)
				buttons_continue_label.text = STR_ARCADE_CONTINUES % str(global.arcade_continues)
				
				if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
					select_button(active_buttons)
					state = GAME_STATE.continue_select
					if option != 1:
						global_audio.stop()
					else:
						global.arcade_continues -= 1
						buttons_continue_label.text = STR_ARCADE_CONTINUES % str(global.arcade_continues)
			GAME_STATE.restart:
				fade_transition_in()
				check_menu_input(false)
				activate_buttons(active_buttons)
				buttons_restart_label.text = STR_ARCADE_CONTINUES % str(global.arcade_continues)
				
				if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
					select_button(active_buttons)
					state = GAME_STATE.restart_select
					if option != 1:
						global_audio.stop()
			GAME_STATE.menu_select, GAME_STATE.menu_select_online, GAME_STATE.rematch_select, \
			GAME_STATE.continue_select, GAME_STATE.restart_select:
				label_timer.visible = false
				if press_timer > 0:
					press_timer -= 1
					set_transition_in()
					if press_timer < max_press_timer / 2 and transition_alpha < 1.5:
						active_buttons.visible = false
						move_lists.visible = false
						menu_banner.deactivate()
						transition_alpha += change_alpha / 4
				else:
					var m_option = max(option, other_option)
					match state:
						GAME_STATE.menu_select:
							match option:
								1:
									get_tree().change_scene(global.SCENE_GAME)
								2:
									get_tree().change_scene(global.SCENE_STAGESELECT)
								3:
									get_tree().change_scene(global.SCENE_CHARSELECT)
								4:
									get_tree().change_scene(global.SCENE_MENU)
						GAME_STATE.menu_select_online:
							match m_option:
								1:
									global.prev_input_delay = input_delay
									get_tree().change_scene(global.SCENE_GAME)
								2:
									get_tree().change_scene(global.SCENE_STAGESELECT)
								3:
									get_tree().change_scene(global.SCENE_CHARSELECT)
								4:
									if global.lobby_state != global.LOBBY_STATE.spectate:
										var consec_matches = global.get_lobby_member_data(global.steam_id, global.MEMBER_LOBBY_CONSEC_MATCHES)
										global.set_lobby_member_data(global.MEMBER_LOBBY_CONSEC_MATCHES, str(int(consec_matches) + 1))
									get_tree().change_scene(global.SCENE_ONLINE_LOBBY)
						GAME_STATE.rematch_select:
							match m_option:
								1:
									get_tree().change_scene(global.SCENE_GAME)
								2:
									global.leave_lobby(false)
									get_tree().change_scene(global.SCENE_MENU)
						GAME_STATE.continue_select:
							match option:
								1:
									get_tree().change_scene(global.SCENE_GAME)
								2:
									get_tree().change_scene(global.SCENE_CHARSELECT)
								3:
									get_tree().change_scene(global.SCENE_MENU)
						GAME_STATE.restart_select:
							match option:
								1:
									global.init_arcade_mode(global.player1_char)
									get_tree().change_scene(global.SCENE_VSSCREEN)
								2:
									get_tree().change_scene(global.SCENE_CHARSELECT)
								3:
									get_tree().change_scene(global.SCENE_MENU)
					queue_free()
			GAME_STATE.pause_select:
				if press_timer > 0:
					press_timer -= 1
					set_transition_in()
					if press_timer < max_press_timer / 2 and transition_alpha < 1.5:
						if ((option != 1 and global.mode != global.MODE.training) or option > 2):
							active_buttons.visible = false
							move_lists.visible = false
							label_paused.visible = false
							menu_banner.deactivate()
							transition_alpha += change_alpha / 4
						else:
							press_timer = 0
				else:
					if global.mode == global.MODE.arcade:
						match option:
							1:
								unpause()
							2:
								get_tree().change_scene(global.SCENE_CHARSELECT)
							3:
								get_tree().change_scene(global.SCENE_MENU)
					elif global.mode == global.MODE.training:
						match option:
							1:
								unpause()
							3:
								get_tree().change_scene(global.SCENE_STAGESELECT)
							4:
								get_tree().change_scene(global.SCENE_CHARSELECT)
							5:
								get_tree().change_scene(global.SCENE_MENU)
					elif global.mode == global.MODE.tutorial:
						match option:
							1:
								unpause()
							2:
								get_tree().change_scene(global.SCENE_MENU)
					else:
						match option:
							1:
								unpause()
							2:
								get_tree().change_scene(global.SCENE_STAGESELECT)
							3:
								get_tree().change_scene(global.SCENE_CHARSELECT)
							4:
								get_tree().change_scene(global.SCENE_MENU)
					if ((option != 1 and global.mode != global.MODE.training) or option > 2):
						queue_free()
			GAME_STATE.end_tutorial:
				fade_transition_in()
				if transition_alpha >= transition_fade_alpha:
					state = GAME_STATE.pause_select
					option = 2
			GAME_STATE.next_stage:
				if transition_alpha < 4:
					transition_alpha += change_alpha
				else:
					if global.set_next_arcade_char():
						get_tree().change_scene(global.SCENE_VSSCREEN)
					else:
						get_tree().change_scene(global.SCENE_ARCADEWIN)
					queue_free()
			_:
				fade_transition_out()
				if global.mode == global.MODE.arcade:
					global.arcade_time += 1
	
	if global.mode == global.MODE.tutorial and not paused:
		if tutorial_timer > 0:
			tutorial_timer -= 1
		elif tutorial_timer == 0:
			if tutorial_index < STR_TUTORIAL.size():
				textbox.add_message(STR_TUTORIAL[tutorial_index])
			textbox.next_message()
			match tutorial_index:
				0:
					max_tutorial_timer = 300
				1:
					max_tutorial_timer = 300
				2:
					max_tutorial_timer = 900
					player1.stop_act()
					player1.start_act()
				3:
					max_tutorial_timer = 600
				4:
					max_tutorial_timer = 300
				5:
					max_tutorial_timer = 900
				6:
					max_tutorial_timer = 600
				7:
					max_tutorial_timer = 450
				8:
					max_tutorial_timer = -1
					player1.start_attack()
				9:
					max_tutorial_timer = 360
				10:
					max_tutorial_timer = 360
				11:
					max_tutorial_timer = 360
				12:
					max_tutorial_timer = 360
				13:
					max_tutorial_timer = 360
				14:
					max_tutorial_timer = 360
				15:
					max_tutorial_timer = -1
					player1.set_score(1)
					player2.set_score(0)
					player1.start_act()
					player2.start_act()
					player2.set_cpu_type(global.CPU_TYPE.dummy_jump_attack)
					player1.start_attack()
					player2.start_attack()
				16:
					max_tutorial_timer = -1
					player1.set_score(1)
					player2.set_score(0)
					player1.start_act()
					player2.start_act()
					player1.start_attack()
					player2.start_attack()
				17:
					player2.set_cpu_type(global.CPU_TYPE.dummy)
					max_tutorial_timer = 450
				18:
					max_tutorial_timer = 450
				19:
					max_tutorial_timer = 450
				20:
					max_tutorial_timer = 450
				21:
					max_tutorial_timer = 450
				22:
					max_tutorial_timer = 450
				23:
					max_tutorial_timer = -1
					player1.set_score(2)
					player1.start_act()
					player2.start_act()
					player1.start_attack()
				24:
					max_tutorial_timer = -1
					player1.set_score(2)
					player1.start_act()
					player2.start_act()
					player1.start_attack()
				25:
					max_tutorial_timer = 300
				26:
					max_tutorial_timer = 300
				27:
					max_tutorial_timer = 450
				28:
					state = GAME_STATE.end_tutorial
			if tutorial_index != 16 and tutorial_index != 24:
				tutorial_index += 1
			tutorial_timer = max_tutorial_timer
		if state == GAME_STATE.ko and (tutorial_index == 9 or tutorial_index == 16 or tutorial_index == 24):
			tutorial_timer = 60
		if state != GAME_STATE.ko and tutorial_index == 16 and player1.anim_player.current_animation != "special":
			if player1.score == 0 and player1.get_red_score() >= 1 and tutorial_timer < 0:
				tutorial_timer = 1
			elif player1.score == 1 and player1.get_red_score() > 1:
				tutorial_timer = 1
				tutorial_index = 17
				player1.stop_act()
		if state == GAME_STATE.super and tutorial_index == 24:
			tutorial_timer = 60
			tutorial_index = 25
	
	player1.preprocess_input(curr_frame <= last_other_frame + last_other_delay)
	player2.preprocess_input(curr_frame <= last_other_frame + last_other_delay)
	if (not global.online or \
	   (((global.lobby_state != global.LOBBY_STATE.spectate and curr_frame <= last_other_frame + last_other_delay) or \
		 (global.lobby_state == global.LOBBY_STATE.spectate and curr_frame <= min(player1_frame, player2_frame))) or \
		  curr_frame <= 0 or game_over)) and not paused:
		prev_delay = input_delay
		if global.online:
			if global.input_delay <= 0:
				if change_delay_timer <= 0:
					if input_delay > target_delay:
						input_delay -= 1
					elif input_delay < target_delay:
						input_delay += 1
					if input_delay < 1:
						input_delay = 1
					elif input_delay > 12:
						input_delay = 12
					change_delay_timer = max_change_delay_timer
				else:
					change_delay_timer -= 1
				if curr_frame <= 0:
					prev_delay = input_delay
			else:
				input_delay = global.input_delay
			label_delay.text = STR_ONLINE_DELAY % str(input_delay)
		
		bg_game.process(curr_frame, frame_delay)
		textbox.process()
		player1.check_dead()
		player2.check_dead()
		player1.preprocess(curr_frame, frame_delay)
		player2.preprocess(curr_frame, frame_delay)
		for object in objects.get_children():
			object.process(curr_frame, frame_delay)
		
		if win_timer > 0:
			win_timer -= 1
		if delay_timer > 0:
			delay_timer -= 1
		if win_timer == 0:
			win_timer_act()
		if delay_timer == 0:
			delay_timer_act()
		
		curr_frame += 1
	
	if not global.online and (Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_START) or \
	  (Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_START) and not global.player2_cpu)) and \
	  state != GAME_STATE.menu and state != GAME_STATE._continue and state != GAME_STATE.restart and \
	  state != GAME_STATE.menu_select and state != GAME_STATE.continue_select and state != GAME_STATE.restart_select and \
	  state != GAME_STATE.pause_select and state != GAME_STATE.end_tutorial and state != GAME_STATE.next_stage:
		if paused:
			paused = false
			menu_banner.deactivate()
			label_paused.visible = false
			for button in buttons_pause.get_children():
				button.active = false
			play_audio(snd_select2)
			if not paused_music:
				global_audio.play(pause_music_pos)
		else:
			paused = true
			menu_banner.activate()
			label_paused.visible = true
			unpaused_state = state
			if buttons_pause != buttons_trainingoptions:
				option = 1
			player1.release_all_actions()
			if not is_p2_cpu():
				player2.release_all_actions()
			for button in buttons_trainingoptions.get_children():
				button.set_label_text()
			play_audio(snd_select2)
			pause_music_pos = global_audio.get_playback_position()
			paused_music = !global_audio.playing
			global_audio.stop()

func win_timer_act():
	match state:
		GAME_STATE.ko:
			label_center.visible = true
			if win_player_num == 1:
				player1.inc_score()
				player2.update_score()
				player1_scored = true
				label_center.text = STR_KO
			elif win_player_num == 2:
				player2.inc_score()
				player1.update_score()
				player2_scored = true
				label_center.text = STR_KO
			else:
				player1.inc_score()
				player2.inc_score()
				player1_scored = true
				player2_scored = true
				label_center.text = STR_DOUBLEKO
			win_player_num = -1
			state = GAME_STATE.ready
			win_timer = max_round_win_timer
			if not (global.infinite_rounds or global.mode == global.MODE.training):
				if player1.score >= 5 and player2.score >= 5:
					state = GAME_STATE.draw
				elif player1.score >= 5 or player2.score >= 5:
					state = GAME_STATE.win
				if state != GAME_STATE.ready:
					win_timer = 90
			play_audio(snd_ko)
		GAME_STATE.super:
			label_center.visible = true
			if win_player_num == 1:
				player1.win_score()
				player2.update_score()
				player1_scored = true
				label_center.text = STR_SUPERKO
			elif win_player_num == 2:
				player2.win_score()
				player1.update_score()
				player2_scored = true
				label_center.text = STR_SUPERKO
			else:
				player1.win_score()
				player2.win_score()
				player1_scored = true
				player2_scored = true
				label_center.text = STR_DOUBLESUPERKO
			win_player_num = -1
			win_timer = max_round_win_timer
			if (global.infinite_rounds or global.mode == global.MODE.training):
				state = GAME_STATE.ready
			else:
				if player1.score >= 5 and player2.score >= 5:
					state = GAME_STATE.draw
				else:
					state = GAME_STATE.win
				if state != GAME_STATE.ready:
					win_timer = 90
			play_audio(snd_superko)
		GAME_STATE.win:
			state = GAME_STATE.premenu
			game_over = true
			win_timer = 120
			if player1.score >= 5:
				label_center.text = STR_PLAYER1WIN
				player1.win()
				if not player2_scored:
					state = GAME_STATE.perfect
				play_audio(snd_player1win)
				global.lobby_player1_wins += 1
			else:
				label_center.text = STR_PLAYER2WIN
				player2.win()
				if not player1_scored:
					state = GAME_STATE.perfect
				play_audio(snd_player2win)
				global.lobby_player2_wins += 1
			if global.online:
				set_wins_labels()
		GAME_STATE.draw:
			state = GAME_STATE.premenu
			game_over = true
			label_center.text = STR_DRAW
			win_timer = 120
		GAME_STATE.ready:
			if global.mode != global.MODE.tutorial:
				player1.start_act()
				player2.start_act()
			label_center.text = STR_READY
			state = GAME_STATE.fight
			win_timer = 60
		GAME_STATE.fight:
			if global.mode != global.MODE.tutorial:
				player1.start_act()
				player2.start_act()
				player1.start_attack()
				player2.start_attack()
			label_center.text = STR_FIGHT
			state = GAME_STATE.go
			win_timer = 60
			var rand = randi() % 3
			if rand == 0:
				play_audio(snd_fight)
			elif rand == 1:
				play_audio(snd_fight2)
			else:
				play_audio(snd_fight3)
		GAME_STATE.perfect:
			label_center.text = STR_PERFECT
			state = GAME_STATE.premenu
			win_timer = 90
			play_audio(snd_perfect)
		GAME_STATE.premenu:
			label_center.visible = false
			win_timer = -1
			if global.mode == global.MODE.arcade:
				if player1.score >= 5 and player2.score < 5:
					state = GAME_STATE.next_stage
				elif global.arcade_continues > 0:
					state = GAME_STATE._continue
					menu_banner.activate()
				else:
					state = GAME_STATE.restart
					menu_banner.activate()
			elif global.mode == global.MODE.online_quickmatch:
				state = GAME_STATE.rematch
				option = 1
				menu_banner.activate()
			elif global.mode == global.MODE.online_lobby:
				if (global.lobby_state == global.LOBBY_STATE.player1 and player1.score >= 5 and player2.score < 5) or \
				   (global.lobby_state == global.LOBBY_STATE.player2 and player2.score >= 5 and player1.score < 5):
					var wins = global.get_lobby_member_data(global.steam_id, global.MEMBER_LOBBY_WINS)
					global.set_lobby_member_data(global.MEMBER_LOBBY_WINS, str(int(wins) + 1))
				if global.lobby_state != global.LOBBY_STATE.spectate:
					var matches = global.get_lobby_member_data(global.steam_id, global.MEMBER_LOBBY_MATCHES)
					global.set_lobby_member_data(global.MEMBER_LOBBY_MATCHES, str(int(matches) + 1))
				
				var rematch_style = int(global.get_lobby_data(global.LOBBY_REMATCH_STYLE))
				var rotation_style = int(global.get_lobby_data(global.LOBBY_ROTATION_STYLE))
				
				if global.lobby_player1_wins > global.lobby_player2_wins:
					global.lobby_rotate = global.LOBBY_ROTATE.player2
				elif global.lobby_player1_wins < global.lobby_player2_wins:
					global.lobby_rotate = global.LOBBY_ROTATE.player1
				else:
					global.lobby_rotate = global.LOBBY_ROTATE.both
				
				if rotation_style == global.LOBBY_ROTATION.lose:
					if global.lobby_rotate == global.LOBBY_ROTATE.player1:
						global.lobby_rotate = global.LOBBY_ROTATE.player2
					elif global.lobby_rotate == global.LOBBY_ROTATE.player2:
						global.lobby_rotate = global.LOBBY_ROTATE.player1
				elif rotation_style == global.LOBBY_ROTATION.none:
					global.lobby_rotate = global.LOBBY_ROTATE.both
				
				if rematch_style == global.LOBBY_REMATCH.inf or \
				   (rematch_style == global.LOBBY_REMATCH.bo5 and max(global.lobby_player1_wins, global.lobby_player2_wins) < 3) or \
				   (rematch_style == global.LOBBY_REMATCH.bo3 and max(global.lobby_player1_wins, global.lobby_player2_wins) < 2):
					state = GAME_STATE.menu
					option = 1
					menu_banner.activate()
					online_timer.start()
					label_timer.visible = true
				else:
					state = GAME_STATE.menu_select_online
					option = 4
					press_timer = max_press_timer
			elif global.mode != global.MODE.tutorial:
				state = GAME_STATE.menu
				option = 1
				menu_banner.activate()
		_:
			label_center.visible = false
			win_timer = -1

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)

func delay_timer_act():
	frame_delay -= 2
	if frame_delay <= 0:
		frame_delay = 0
		delay_timer = -1
	else:
		delay_timer = max_delay_timer

func broadcast_packet_input(input_player_num, copy_map, copy_frame, copy_delay):
	if global.other_member_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.game_input)
		packet.append(input_player_num)
		packet.append(int(copy_map[global.INPUT_ACTION_LEFT]))
		packet.append(int(copy_map[global.INPUT_ACTION_RIGHT]))
		packet.append(int(copy_map[global.INPUT_ACTION_UP]))
		packet.append(int(copy_map[global.INPUT_ACTION_DOWN]))
		packet.append(int(copy_map[global.INPUT_ACTION_ATTACK]))
		packet.append(int(copy_map[global.INPUT_ACTION_SPECIAL]))
		packet.append(int(copy_map[global.INPUT_ACTION_SUPER]))
		packet.append(int(copy_map[global.INPUT_ACTION_DASH]))
		packet.append(copy_delay)
		packet.append_array(str(copy_frame).to_ascii())
		global.broadcast_packet(packet)

func broadcast_packet_menu():
	if global.other_member_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.game_menu)
		if global.lobby_state == global.LOBBY_STATE.player1:
			packet.append(1)
		else:
			packet.append(2)
		packet.append(option)
		global.broadcast_packet(packet)

func send_packet_ping():
	if global.other_member_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.game_ping)
		Steam.sendP2PPacket(global.other_member_id, packet, 2, 0)

func _on_online_timer_timeout():
	if state == GAME_STATE.menu and global.lobby_state != global.LOBBY_STATE.spectate:
		state = GAME_STATE.menu_select_online
		option = 4
		press_timer = max_press_timer
		broadcast_packet_menu()
