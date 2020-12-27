extends Node2D

export var player_num = 1
export var y_scroll_offset = 0

var curr_char = global.CHAR.goto
var palette_num = -1
var selected = false
var selected_palette = false
var scrolling = false
var select_x = 60
var target_x = -4
var orig_y
var unselect_y = 5
var select_y = 13
var ignore_first_delta = true

onready var anim_player = get_node("AnimationPlayer")
onready var char_spr = get_node("char")
onready var label_name = get_node("label_name")
onready var paint = get_node("paint")

func _ready():
	if player_num == 1 and global.player1_cpu:
		label_name.add_color_override("font_color_shadow", Color(0.3, 0.3, 0.3))
		paint.set_modulate(Color(0.5, 0.5, 0.5, 0.75))
	if player_num == 2:
		if global.player2_cpu:
			label_name.add_color_override("font_color_shadow", Color(0.4, 0.4, 0.4))
			paint.set_modulate(Color(0.75, 0.75, 0.75, 0.75))
		else:
			label_name.add_color_override("font_color_shadow", Color(0.25, 0.25, 1))
			paint.set_modulate(Color(0.25, 0.5, 1, 0.75))
		char_spr.position = Vector2(char_spr.position.x * -1, char_spr.position.y)
		label_name.set_position(Vector2(label_name.get_position().x + 4, label_name.get_position().y))
		paint.scale.x = 1
		char_spr.scale.x = -1
		select_x *= -1
		target_x *= -1
	label_name.text = global.get_char_real_name(curr_char)
	
	orig_y = position.y
	if y_scroll_offset != 0:
		position = Vector2(position.x, position.y + y_scroll_offset)
	
	anim_player.playback_speed = 0
	anim_player.play("goto")
	
	char_spr.get_material().set_shader_param(global.SHADERPARAM_THRESHOLD, 0.001)
	char_spr.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 0)

func set_char(char_name):
	if not selected:
		label_name.text = global.get_char_real_name(char_name)
		var debug_name = global.get_char_debug_name(char_name)
		if anim_player.current_animation != debug_name:
			anim_player.play(debug_name)
			anim_player.seek(0, true)
		if curr_char != char_name:
			char_spr.position = Vector2(position.x + select_x, char_spr.position.y)
		if curr_char == global.CHAR.random:
			char_spr.scale.x = 1
		elif player_num == 2:
			char_spr.scale.x = -1
		curr_char = char_name
	elif not selected_palette:
		label_name.text = "< Color: " + str(palette_num + 2) + " >"
	else:
		label_name.text = global.get_char_real_name(char_name) + "\nREADY!"

func process(delta):
	if ignore_first_delta:
		delta = 0
		ignore_first_delta = false
	
	anim_player.seek(anim_player.current_animation_position + 1 * (global.fps * delta), true)
	char_spr.position = Vector2(char_spr.position.x + (target_x - char_spr.position.x) / 4 * (global.fps * delta), char_spr.position.y)
	if scrolling:
		position = Vector2(position.x, position.y - sign(y_scroll_offset) * 0.1 * (global.fps * delta))
	elif y_scroll_offset != 0:
		position = Vector2(position.x, position.y + (orig_y - position.y) / 8 * (global.fps * delta))
		if abs(orig_y - position.y) <= 1:
			scrolling = true
	var white_amount = char_spr.get_material().get_shader_param(global.SHADERPARAM_WHITEAMOUNT)
	if white_amount > 0:
		char_spr.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, white_amount - 0.05 * (global.fps * delta))

func select():
	if not selected:
		selected = true
		if curr_char == global.CHAR.random:
			selected_palette = true
			char_spr.scale.x = 1
		else:
			char_spr.position = Vector2(char_spr.position.x, position.y + select_y)
			if player_num == 2:
				char_spr.scale.x = -1
		palette_num = -1
		anim_player.play(anim_player.current_animation + "_select")
		char_spr.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 1)

func back():
	if selected_palette:
		selected_palette = false
		if curr_char == global.CHAR.random:
			selected = false
	elif selected:
		selected = false
		palette_num = -1
		set_palette()
		char_spr.position = Vector2(position.x + select_x, position.y + unselect_y)

func previous_palette():
	palette_num -= 1
	if palette_num < -1:
		palette_num = global.get_char_max_palette(curr_char)
	set_palette()

func next_palette():
	palette_num += 1
	if palette_num > global.get_char_max_palette(curr_char):
		palette_num = -1
	set_palette()

func select_palette():
	if selected:
		selected_palette = true
		char_spr.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 1)

func set_palette_num(new_palette_num):
	palette_num = new_palette_num
	if palette_num > global.get_char_max_palette(curr_char):
		palette_num = -1
	set_palette()

func set_palette():
	if palette_num <= -1 or palette_num > global.get_char_max_palette(curr_char):
		var palette = global.get_char_palette(curr_char, -1)
		if palette != null:
			for i in range(palette.size()):
				set_palette_color(Color(), i, true)
				set_palette_color(Color(), i, false)
	else:
		var palette = global.get_char_palette(curr_char, -1)
		if palette != null:
			for i in range(palette.size()):
				set_palette_color(palette[i], i, true)
		palette = global.get_char_palette(curr_char, palette_num)
		if palette != null:
			for i in range(palette.size()):
				set_palette_color(palette[i], i, false)

func set_palette_color(palette_color, palette_num, default):
	global.set_material_palette_color(char_spr.material, palette_color, palette_num, default)

func set_at_target_x():
	char_spr.position.x = target_x
