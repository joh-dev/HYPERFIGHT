extends UiSelectButton

const globalP = preload("res://scripts/global.gd")

export(globalP.STAGE) var stage

onready var spr_long = preload("res://graphics/ui/select/stage/portrait_long.png")
onready var anim_player = get_node("anim_player")
onready var stage_anim_player = get_node("stage_anim_player")

var orig_stage = global.STAGE.dojo
var curr_anim = "deselect"

func _ready():
	highlight_frame = 3
	anim_player.play(curr_anim)
	stage_anim_player.play(global.get_stage_debug_name(stage))
	
	orig_stage = stage
	match stage:
		global.STAGE.blackhole:
			if not global.unlock_stage_blackhole:
				lock()
		global.STAGE.random:
			texture = spr_long

func lock():
	stage = global.STAGE.locked
	stage_anim_player.play("locked")
	remove_from_group("ui_select")

func set_highlight(player_num):
	if player_num > 0:
		z_index = 1
		if curr_anim != "select":
			anim_player.play("select")
			curr_anim = "select"
	else:
		z_index = 0
		if curr_anim != "deselect":
			anim_player.play("deselect")
			curr_anim = "deselect"

func select_up_override():
	var new_sportrait = null
	match stage:
		global.STAGE.dojo, global.STAGE.rooftop:
			new_sportrait = global.STAGE.random
		global.STAGE.random:
			new_sportrait = global.STAGE.sanctuary
	return find_sportrait(new_sportrait)

func select_down_override():
	var new_sportrait = null
	match stage:
		global.STAGE.factory:
			if global.unlock_stage_blackhole:
				new_sportrait = global.STAGE.blackhole
			else:
				new_sportrait = global.STAGE.random
		global.STAGE.sanctuary, global.STAGE.blackhole:
			new_sportrait = global.STAGE.random
	return find_sportrait(new_sportrait)

func select_left_override():
	var new_sportrait = null
	match stage:
		global.STAGE.sanctuary:
			if global.unlock_stage_blackhole:
				new_sportrait = global.STAGE.blackhole
			else:
				new_sportrait = global.STAGE.sanctuary
		global.STAGE.blackhole:
			new_sportrait = global.STAGE.sanctuary
		global.STAGE.random:
			new_sportrait = global.STAGE.random
	return find_sportrait(new_sportrait)

func select_right_override():
	var new_sportrait = null
	match stage:
		global.STAGE.sanctuary:
			if global.unlock_stage_blackhole:
				new_sportrait = global.STAGE.blackhole
			else:
				new_sportrait = global.STAGE.sanctuary
		global.STAGE.random:
			new_sportrait = global.STAGE.random
	return find_sportrait(new_sportrait)

func find_sportrait(find_stage):
	if find_stage != null:
		for portrait in get_tree().get_nodes_in_group("ui_select"):
			if portrait.stage == find_stage:
				return portrait
	return null
