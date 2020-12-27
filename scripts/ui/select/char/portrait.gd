extends UiSelectButton

const globalP = preload("res://scripts/global.gd")

export(globalP.CHAR) var character

onready var anim_player = get_node("anim_player")
onready var char_anim_player = get_node("char_anim_player")
onready var label_player1 = get_node("label_player1_node/label_player1")
onready var label_player2 = get_node("label_player2_node/label_player2")

var orig_char = global.CHAR.goto
var curr_anim = "deselect"

func _ready():
	highlight_frame = 3
	max_select_timer = 30
	
	if global.player1_cpu:
		label_player1.add_color_override("font_color", Color(0.4, 0.4, 0.4))
		label_player1.text = "CPU"
	else:
		label_player1.add_color_override("font_color", Color(1, 0, 0))
		label_player1.text = "P1"
	if global.player2_cpu:
		label_player2.add_color_override("font_color", Color(0.4, 0.4, 0.4))
		label_player2.text = "CPU"
	else:
		label_player2.add_color_override("font_color", Color(0, 0.5, 1))
		label_player2.text = "P2"
	label_player1.visible = false
	label_player2.visible = false
	anim_player.play(curr_anim)
	char_anim_player.play(global.get_char_debug_name(character))
	
	orig_char = character
	match character:
		global.CHAR.darkgoto:
			if not global.unlock_char_darkgoto:
				lock()

func lock():
	character = global.CHAR.locked
	char_anim_player.play("locked")
	remove_from_group("ui_select")

func set_highlight(player_num):
	if player_num > 0:
		z_index = 1
		if curr_anim != "select":
			anim_player.play("select")
			curr_anim = "select"
		if player_num == 1:
			label_player1.visible = true
		elif player_num == 2:
			label_player2.visible = true
	else:
		z_index = 0
		if curr_anim != "deselect" and !label_player1.visible and !label_player2.visible:
			anim_player.play("deselect")
			curr_anim = "deselect"
		label_player1.visible = false
		label_player2.visible = false

func find_portrait(find_char):
	if find_char != null:
		for portrait in get_tree().get_nodes_in_group("ui_select"):
			if portrait.character == find_char:
				return portrait
	return null
