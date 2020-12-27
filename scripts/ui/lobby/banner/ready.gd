extends Sprite

var ready = global.LOBBY_READY.not_ready
var player_id = -1

onready var label_ready = get_node("label_ready")

func set_player_id(new_id):
	if player_id != new_id:
		player_id = new_id
		set_ready(global.LOBBY_READY.not_ready)

func set_ready(ready):
	self.ready = ready
	match ready:
		global.LOBBY_READY.not_ready:
			label_ready.text = "Not ready"
		global.LOBBY_READY.ready:
			label_ready.text = "Ready!"
		global.LOBBY_READY.playing:
			label_ready.text = "Playing"

func flip_ready():
	match ready:
		global.LOBBY_READY.not_ready:
			ready = global.LOBBY_READY.ready
		global.LOBBY_READY.ready:
			ready = global.LOBBY_READY.not_ready
	set_ready(ready)

func get_player_id():
	return player_id

func get_ready():
	return ready

func clear():
	player_id = -1
	label_ready.text = ""
