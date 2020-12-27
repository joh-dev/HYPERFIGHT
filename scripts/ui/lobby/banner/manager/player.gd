extends Node2D

var max_players = 8
var player_banners = []

func init(max_players):
	self.max_players = max_players
	for i in range(8):
		var banner = get_node("lobby_player_banner_player" + str(i + 1))
		if i < max_players:
			player_banners.append(banner)
		else:
			player_banners.append(null)
			banner.disable()
	update()

func update():
	for i in range(max_players):
		if player_banners[i] != null:
			if i < global.lobby_member_ids.size():
				player_banners[i].set_name(Steam.getFriendPersonaName(global.lobby_member_ids[i]))
				player_banners[i].set_win_ratio(global.get_lobby_member_data(global.lobby_member_ids[i], global.MEMBER_LOBBY_WINS),
												global.get_lobby_member_data(global.lobby_member_ids[i], global.MEMBER_LOBBY_MATCHES))
				player_banners[i].set_skip(global.get_lobby_member_data(global.lobby_member_ids[i], global.MEMBER_LOBBY_SKIP))
				player_banners[i].set_avatar(Steam.getSmallFriendAvatar(global.lobby_member_ids[i]))
			else:
				player_banners[i].clear()
