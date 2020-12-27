extends Node2D

enum ONLINE_LOBBY_STATE { select, back }

var state = ONLINE_LOBBY_STATE.select
var min_bg_move = 1
var max_bg_move = 15
var bg_move = min_bg_move
var transition_alpha = 1
var change_alpha = 0.1
var move_timer = -1
var max_move_timer = 120

var lobby_init = false
var waiting_for_spectators = false
var can_ready = false
var started = false
var stopped_packets = false
var ready_ids = [-1, -1]
var check_ids = []

var player1_id = 0
var player2_id = 0

onready var audio = get_node("AudioStreamPlayer")
onready var bg_grid = get_node("bg_grid")
onready var bg_grid2 = get_node("bg_grid2")
onready var transition = get_node("transition")
onready var menu_yesno = get_node("menu_yesno")
onready var player_banners = get_node("player_banners")
onready var ready_banners = get_node("ready_banners")
onready var timeout_timer = get_node("timeout_timer")
onready var player1_ready_timer = get_node("player1_ready_timer")
onready var player2_ready_timer = get_node("player2_ready_timer")
onready var update_banner_timer = get_node("update_banner_timer")
onready var lobby_chat_banner = get_node("lobby_chat_banner")
onready var label_name = get_node("label_name")
onready var label_info = get_node("label_info")
onready var label_timeout = get_node("label_timeout")
onready var label_player1_ready = get_node("label_player1_ready")
onready var label_player2_ready = get_node("label_player2_ready")

onready var msc_charselect = preload("res://audio/music/menu/charselect.ogg")
onready var snd_select = preload("res://audio/sfx/menu/select1.ogg")
onready var snd_select2 = preload("res://audio/sfx/menu/select2.ogg")

func _ready():
	transition.visible = true
	global_audio.stop()
	global_audio.stream = msc_charselect
	global_audio.play(0)
	
	Steam.connect("lobby_chat_update", self, "lobby_chat_update")
	Steam.connect("lobby_data_update", self, "lobby_data_update")
	Steam.connect("lobby_message", self, "lobby_message")
	
	global.lobby_player1_wins = 0
	global.lobby_player2_wins = 0
	if global.lobby_join:
		send_packet_init(global.host_member_id)
		label_name.text = global.get_lobby_data(global.LOBBY_NAME)
	else:
		if global.curr_lobby_id <= 0:
			global.spectator_member_ids.clear()
			global.lobby_member_ready = [global.LOBBY_READY.not_ready, global.LOBBY_READY.not_ready]
			global.lobby_member_ids.clear()
			global.lobby_member_ids.append(global.steam_id)
			Steam.createLobby(global.host_open, global.host_max_players)
			player_banners.init(global.host_max_players)
			can_ready = ready_banners.update_players()
			lobby_chat_banner.visible = global.host_chat
			lobby_init = true
		else:
			timeout_timer.start()
			broadcast_packet_timer_timeout_start()
			waiting_for_spectators = true
		label_name.text = global.host_name
	if global.curr_lobby_id > 0:
		player_banners.init(Steam.getLobbyMemberLimit(global.curr_lobby_id))
		update_banners()
		lobby_chat_banner.visible = global.lobby_chat
		lobby_chat_banner.update_text()
		lobby_init = true
	
	update_banner_timer.start()

func _process(delta):
	Steam.run_callbacks()
	
	if not stopped_packets:
		var packet_size = Steam.getAvailableP2PPacketSize(0)
		while packet_size > 0:
			var packet_dict = Steam.readP2PPacket(packet_size, 0)
			var packet = packet_dict["data"]
			var sender_id = packet_dict["steamIDRemote"]
			var packet_type = packet[0]
			match packet_type:
				global.P_TYPE.lobby_init:
					if global.lobby_join:
						send_packet_ready_start(global.host_member_id)
					elif not started:
						global.spectator_member_ids.erase(sender_id)
				global.P_TYPE.lobby_ready:
					if not global.lobby_join and not started and not waiting_for_spectators:
						ready_banners.set_ready(sender_id)
						if global.lobby_member_ids.size() > 2:
							if sender_id == global.lobby_member_ids[0]:
								if global.lobby_member_ready[0] == global.LOBBY_READY.ready:
									player1_ready_timer.stop()
									broadcast_packet_timer_player1_ready_stop()
								elif global.lobby_member_ready[0] == global.LOBBY_READY.not_ready:
									player1_ready_timer.start()
									broadcast_packet_timer_player1_ready_start()
							if sender_id == global.lobby_member_ids[1]:
								if global.lobby_member_ready[1] == global.LOBBY_READY.ready:
									player2_ready_timer.stop()
									broadcast_packet_timer_player2_ready_stop()
								elif global.lobby_member_ready[1] == global.LOBBY_READY.not_ready:
									player2_ready_timer.start()
									broadcast_packet_timer_player2_ready_start()
						check_start()
				global.P_TYPE.lobby_ready_start:
					if global.lobby_join:
						started = true
						set_other_member_id()
						if can_ready and global.lobby_member_ids.size() >= 2:
							send_packet_init(global.other_member_id)
					elif started:
						if not check_ids.has(sender_id) and \
						   (sender_id == ready_ids[0] or sender_id == ready_ids[1]):
							check_ids.append(sender_id)
						if check_ids.size() >= 2:
							global.lobby_member_ready = [global.LOBBY_READY.playing, global.LOBBY_READY.playing]
							global.update_lobby_ready_data()
							if global.lobby_member_ids.size() > 2:
								for i in range(global.lobby_member_ids.size() - 2):
									if global.steam_id != global.lobby_member_ids[i + 2]:
										global.spectator_member_ids.append(global.lobby_member_ids[i + 2])
							broadcast_packet_start()
							start_game()
				global.P_TYPE.lobby_ready_reset:
					if global.lobby_join:
						started = false
				global.P_TYPE.lobby_start:
					if global.lobby_join:
						stopped_packets = true
						update_banners()
						start_game()
						break
				global.P_TYPE.timer_timeout_start:
					if global.lobby_join:
						timeout_timer.start()
				global.P_TYPE.timer_timeout_stop:
					if global.lobby_join:
						timeout_timer.stop()
				global.P_TYPE.timer_player1_ready_start:
					if global.lobby_join:
						player1_ready_timer.start()
				global.P_TYPE.timer_player1_ready_stop:
					if global.lobby_join:
						player1_ready_timer.stop()
				global.P_TYPE.timer_player2_ready_start:
					if global.lobby_join:
						player2_ready_timer.start()
				global.P_TYPE.timer_player2_ready_stop:
					if global.lobby_join:
						player2_ready_timer.stop()
			packet_size = Steam.getAvailableP2PPacketSize(0)
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	if menu_yesno.active:
		transition.set_modulate(Color(1, 1, 1, 0.75))
	elif state == ONLINE_LOBBY_STATE.select:
		if transition_alpha > 0:
			transition_alpha -= change_alpha * (global.fps * delta)
		
		if lobby_init and not started:
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK) and not lobby_chat_banner.is_active() and can_ready:
				if global.lobby_join:
					send_packet_ready(global.host_member_id)
				elif not waiting_for_spectators:
					ready_banners.set_ready(global.steam_id)
					if global.lobby_member_ids.size() > 2:
						if global.steam_id == global.lobby_member_ids[0]:
							if global.lobby_member_ready[0] == global.LOBBY_READY.ready:
								player1_ready_timer.stop()
								broadcast_packet_timer_player1_ready_stop()
							elif global.lobby_member_ready[0] == global.LOBBY_READY.not_ready:
								player1_ready_timer.start()
								broadcast_packet_timer_player1_ready_start()
						if global.steam_id == global.lobby_member_ids[1]:
							if global.lobby_member_ready[1] == global.LOBBY_READY.ready:
								player2_ready_timer.stop()
								broadcast_packet_timer_player2_ready_stop()
							elif global.lobby_member_ready[1] == global.LOBBY_READY.not_ready:
								player2_ready_timer.start()
								broadcast_packet_timer_player2_ready_start()
					check_start()
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_DASH) and not lobby_chat_banner.is_active():
				var skip = bool(int(global.get_lobby_member_data(global.steam_id, global.MEMBER_LOBBY_SKIP)))
				global.set_lobby_member_data(global.MEMBER_LOBBY_SKIP, str(int(!skip)))
		if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_SPECIAL) and not lobby_chat_banner.is_active():
			menu_yesno.active = true
			play_audio(snd_select2)
	elif state == ONLINE_LOBBY_STATE.back:
		if transition_alpha < 4:
			transition_alpha += change_alpha * (global.fps * delta)
		else:
			global.leave_lobby(false)
			get_tree().change_scene(global.SCENE_MENU)
	
	if not global.lobby_join and waiting_for_spectators and global.spectator_member_ids.empty():
		rotate_members()
		waiting_for_spectators = false
		timeout_timer.stop()
		broadcast_packet_timer_timeout_stop()
	
	label_timeout.visible = !timeout_timer.is_stopped()
	label_info.visible = !label_timeout.visible
	label_player1_ready.visible = !player1_ready_timer.is_stopped()
	label_player2_ready.visible = !player2_ready_timer.is_stopped()
	
	label_timeout.text = "Waiting for spectators..." + str(int(timeout_timer.time_left))
	label_player1_ready.text = str(int(player1_ready_timer.time_left))
	label_player2_ready.text = str(int(player2_ready_timer.time_left))
	
	if bg_move > 0:
		bg_grid.position = Vector2(bg_grid.position.x, bg_grid.position.y + bg_move * (global.fps * delta))
		if bg_grid.position.y > 80:
			bg_grid.position = Vector2(bg_grid.position.x, -80)
		bg_grid2.position = Vector2(bg_grid2.position.x, bg_grid2.position.y + bg_move * (global.fps * delta))
		if bg_grid2.position.y > 80:
			bg_grid2.position = Vector2(bg_grid2.position.x, -80)

func rotate_members():
	global.lobby_member_ready = [global.LOBBY_READY.not_ready, global.LOBBY_READY.not_ready]
	if global.lobby_rotate != global.LOBBY_ROTATE.none:
		match global.lobby_rotate:
			global.LOBBY_ROTATE.player1:
				if global.lobby_member_ids.size() > 0:
					var first_member = global.lobby_member_ids.pop_front()
					global.lobby_member_ids.push_back(first_member)
					var second_member = global.lobby_member_ids[0]
					var consec_matches = int(global.get_lobby_member_data(second_member, global.MEMBER_LOBBY_CONSEC_MATCHES))
					if consec_matches >= global.host_match_limit and global.host_match_limit > 0:
						second_member = global.lobby_member_ids.pop_front()
						global.lobby_member_ids.push_back(second_member)
			global.LOBBY_ROTATE.player2:
				if global.lobby_member_ids.size() > 1:
					var second_member = global.lobby_member_ids[1]
					global.lobby_member_ids.remove(1)
					global.lobby_member_ids.push_back(second_member)
					var first_member = global.lobby_member_ids[0]
					var consec_matches = int(global.get_lobby_member_data(first_member, global.MEMBER_LOBBY_CONSEC_MATCHES))
					if consec_matches >= global.host_match_limit and global.host_match_limit > 0:
						first_member = global.lobby_member_ids.pop_front()
						global.lobby_member_ids.push_back(first_member)
			global.LOBBY_ROTATE.both:
				if global.lobby_member_ids.size() > 0:
					var first_member = global.lobby_member_ids.pop_front()
					global.lobby_member_ids.push_back(first_member)
					var second_member = global.lobby_member_ids.pop_front()
					global.lobby_member_ids.push_back(second_member)
		process_skips()
		global.lobby_rotate = global.LOBBY_ROTATE.none
	global.update_lobby_member_data()
	global.update_lobby_stage_data()
	
	check_ready_timers()

func back():
	state = ONLINE_LOBBY_STATE.back

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)

func check_start():
	if global.lobby_member_ready[0] == global.LOBBY_READY.ready and \
	   global.lobby_member_ready[1] == global.LOBBY_READY.ready and not started:
		started = true
		ready_ids = [global.lobby_member_ids[0], global.lobby_member_ids[1]]
		check_ids = []
		if ready_ids.has(global.steam_id):
			check_ids.append(global.steam_id)
		set_other_member_id()
		broadcast_packet_ready_start()
		if can_ready:
			send_packet_init(global.other_member_id)

func set_other_member_id():
	if global.steam_id == global.lobby_member_ids[0]:
		global.other_member_id = global.lobby_member_ids[1]
		global.lobby_state = global.LOBBY_STATE.player1
	elif global.steam_id == global.lobby_member_ids[1]:
		global.other_member_id = global.lobby_member_ids[0]
		global.lobby_state = global.LOBBY_STATE.player2
	else:
		global.lobby_state = global.LOBBY_STATE.spectate
		global.set_lobby_member_data(global.MEMBER_LOBBY_CONSEC_MATCHES, str(0))

func process_skips():
	if global.lobby_member_ids.size() > 1:
		var skip_ids = []
		for i in range(global.lobby_member_ids.size() - 1):
			var skip = bool(int(global.get_lobby_member_data(global.lobby_member_ids[i], global.MEMBER_LOBBY_SKIP)))
			if skip:
				skip_ids.append(global.lobby_member_ids[i])
		for i in range(skip_ids.size()):
			global.lobby_member_ids.erase(skip_ids[i])
			global.lobby_member_ids.append(skip_ids[i])

func check_ready_timers():
	if not global.lobby_join and not waiting_for_spectators:
		if global.lobby_member_ids.size() > 2:
			if player1_id != global.lobby_member_ids[0]:
				player1_id = global.lobby_member_ids[0]
				player1_ready_timer.start()
				broadcast_packet_timer_player1_ready_start()
			if player2_id != global.lobby_member_ids[1]:
				player2_id = global.lobby_member_ids[1]
				player2_ready_timer.start()
				broadcast_packet_timer_player2_ready_start()
		else:
			player1_id = 0
			player2_id = 0
			player1_ready_timer.stop()
			player2_ready_timer.stop()
			broadcast_packet_timer_player1_ready_stop()
			broadcast_packet_timer_player2_ready_stop()

func start_game():
	global.get_lobby_stage_data()
	get_tree().change_scene(global.SCENE_CHARSELECT)

func update_banners():
	player_banners.update()
	can_ready = ready_banners.update_players()
	check_ready_timers()

func lobby_chat_update(lobby_id, user_id, change_user_id, chat_state):
	match chat_state:
		0x0001:
			if not global.lobby_join:
				update_banners()
			update_banner_timer.start()
		0x0002, 0x0004:
			if not global.lobby_join:
				if started and (user_id == ready_ids[0] or user_id == ready_ids[1]):
					started = false
					broadcast_packet_ready_reset()
				update_banners()

func lobby_data_update(success, lobby_id, user_id, key):
	update_banners()
	if global.lobby_join:
		lobby_init = true
	elif global.lobby_member_ids.has(user_id) and global.lobby_member_ids.size() > 1 and not started and not waiting_for_spectators:
		process_skips()
		global.lobby_member_ready = [global.LOBBY_READY.not_ready, global.LOBBY_READY.not_ready]
		global.update_lobby_member_data()
		global.update_lobby_ready_data()

func lobby_message(result, user_id, msg, type):
	var char_idx = msg.find(global.LOBBY_MSG_SEP_CHAR)
	match msg.left(char_idx):
		global.LOBBY_MSG_CHAT:
			lobby_chat_banner.update_text()

func send_packet_init(user_id):
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.lobby_init)
	Steam.sendP2PPacket(user_id, packet, 2, 0)

func broadcast_packet_init():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.lobby_init)
	for i in range(len(global.lobby_member_ids)):
		var user_id = global.lobby_member_ids[i]
		if user_id != global.steam_id and user_id != global.host_member_id:
			Steam.sendP2PPacket(user_id, packet, 2, 0)

func send_packet_ready(user_id):
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.lobby_ready)
	Steam.sendP2PPacket(user_id, packet, 2, 0)

func send_packet_ready_start(user_id):
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.lobby_ready_start)
	Steam.sendP2PPacket(user_id, packet, 2, 0)

func broadcast_lobby_packet(packet):
	for i in range(len(global.lobby_member_ids)):
		var user_id = global.lobby_member_ids[i]
		if user_id != global.steam_id:
			Steam.sendP2PPacket(user_id, packet, 2, 0)

func broadcast_packet_ready_start():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.lobby_ready_start)
	broadcast_lobby_packet(packet)

func broadcast_packet_ready_reset():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.lobby_ready_reset)
	broadcast_lobby_packet(packet)

func broadcast_packet_start():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.lobby_start)
	broadcast_lobby_packet(packet)

func broadcast_packet_timer_timeout_start():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.timer_timeout_start)
	broadcast_lobby_packet(packet)
	
func broadcast_packet_timer_timeout_stop():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.timer_timeout_stop)
	broadcast_lobby_packet(packet)
	
func broadcast_packet_timer_player1_ready_start():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.timer_player1_ready_start)
	broadcast_lobby_packet(packet)
	
func broadcast_packet_timer_player1_ready_stop():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.timer_player1_ready_stop)
	broadcast_lobby_packet(packet)
	
func broadcast_packet_timer_player2_ready_start():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.timer_player2_ready_start)
	broadcast_lobby_packet(packet)
	
func broadcast_packet_timer_player2_ready_stop():
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.timer_player2_ready_stop)
	broadcast_lobby_packet(packet)

func _on_timeout_timer_timeout():
	if not global.lobby_join and waiting_for_spectators:
		for spectator_id in global.spectator_member_ids:
			var kick_str = global.LOBBY_MSG_TIMEOUT + global.LOBBY_MSG_SEP_CHAR
			kick_str += str(spectator_id)
			Steam.sendLobbyChatMsg(global.curr_lobby_id, kick_str)
		global.spectator_member_ids.clear()
		rotate_members()
		waiting_for_spectators = false

func _on_player1_ready_timer_timeout():
	if not global.lobby_join and global.lobby_member_ids.size() > 2 and not waiting_for_spectators:
		global.lobby_member_ready = [global.LOBBY_READY.not_ready, global.LOBBY_READY.not_ready]
		var first_member = global.lobby_member_ids.pop_front()
		global.lobby_member_ids.push_back(first_member)
		process_skips()
		global.update_lobby_member_data()
		global.update_lobby_stage_data()
		check_ready_timers()

func _on_player2_ready_timer_timeout():
	if not global.lobby_join and global.lobby_member_ids.size() > 2 and not waiting_for_spectators:
		var second_member = global.lobby_member_ids[1]
		global.lobby_member_ids.remove(1)
		global.lobby_member_ids.push_back(second_member)
		process_skips()
		global.update_lobby_member_data()
		global.update_lobby_stage_data()
		check_ready_timers()

func _on_update_banner_timer_timeout():
	update_banners()
