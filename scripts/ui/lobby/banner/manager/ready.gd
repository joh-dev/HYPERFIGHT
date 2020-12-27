extends Node2D

onready var banner_player1 = get_node("lobby_ready_banner_player1")
onready var banner_player2 = get_node("lobby_ready_banner_player2")

func update():
	banner_player1.set_ready(global.lobby_member_ready[0])
	banner_player2.set_ready(global.lobby_member_ready[1])

func update_players():
	var can_ready = false
	var force_unready = false
	for i in range(2):
		var curr_banner = banner_player1
		if i > 0:
			curr_banner = banner_player2
		if i < global.lobby_member_ids.size():
			curr_banner.set_player_id(global.lobby_member_ids[i])
			if global.lobby_member_ids[i] == Steam.getSteamID():
				can_ready = true
		else:
			curr_banner.clear()
	update()
	return can_ready

func set_ready(player_id):
	var changed_ready = false
	if banner_player1.get_player_id() == player_id and banner_player1.get_ready() != global.LOBBY_READY.playing:
		banner_player1.flip_ready()
		global.lobby_member_ready[0] = banner_player1.get_ready()
		changed_ready = true
	elif banner_player2.get_player_id() == player_id and banner_player2.get_ready() != global.LOBBY_READY.playing:
		banner_player2.flip_ready()
		global.lobby_member_ready[1] = banner_player2.get_ready()
		changed_ready = true
	if changed_ready:
		global.update_lobby_ready_data()
