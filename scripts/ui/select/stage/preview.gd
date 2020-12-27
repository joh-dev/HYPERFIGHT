extends Node2D

var selected = false
var forward = true
var downward = false
var bg_move_x = 0.4
var bg_move_y = 0.2
var curr_stage = global.STAGE.dojo

onready var bg = get_node("bg_game")
onready var label_name = get_node("label_name")

func _ready():
	label_name.text = global.get_stage_real_name(bg.get_stage())

func set_stage(stage_name):
	curr_stage = stage_name
	if not selected:
		label_name.text = global.get_stage_real_name(stage_name)
		var debug_name = global.get_stage_debug_name(stage_name)
		if bg.get_stage() != debug_name:
			bg.set_stage(debug_name)
			if stage_name == global.STAGE.random:
				bg.region_rect.position = Vector2(0, 0)
			else:
				bg.region_rect.position = Vector2(0, 37)
			forward = true
			downward = false

func select():
	selected = true

func _process(delta):
	if curr_stage != global.STAGE.random:
		if forward:
			bg.region_rect.position.x += bg_move_x * (global.fps * delta)
			if bg.region_rect.position.x >= 156:
				forward = false
		else:
			bg.region_rect.position.x -= bg_move_x * (global.fps * delta)
			if bg.region_rect.position.x <= 0:
				forward = true
		if downward:
			bg.region_rect.position.y += bg_move_y * (global.fps * delta)
			if bg.region_rect.position.y >= 75:
				downward = false
		else:
			bg.region_rect.position.y -= bg_move_y * (global.fps * delta)
			if bg.region_rect.position.y <= 0:
				downward = true
