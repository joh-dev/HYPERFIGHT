class_name UiMenuButton
extends Sprite

signal rebound

export var text = ""
export var option_num = 1
export var color = Color(1, 1, 1)
export var setting_slide = false
export var setting_rebind = false
export var setting_text = false
export var rebind_player1 = true
export var rebind_input = "left"
export var rebind_axis = false
export var inactive_y = 150
export var layer = 0
export var page = 1
export var disabled = false

var select_timer = -1
var max_select_timer = 60
var move_factor = 4
var orig_pos
var active = false
var rebinding = false
var editing = false
var first_input = false
var opened = false
var activated = false
var set_page_visible = true
var up = true
var alpha = 1

onready var anim_player = get_node("AnimationPlayer")
onready var label = get_node("label_text")
onready var back_rect = get_node("back_rect")
onready var back_label = get_node("back_rect/back_label")
onready var line_edit

func _ready():
	set_label_text()
	set_rebind_text()
	
	orig_pos = position
	position.y += inactive_y
	
	back_rect.visible = false
	if setting_slide:
		anim_player.play("slide")
		check_slide_edges()
		frame = 0
	elif setting_rebind:
		anim_player.play("rebind_close")
		anim_player.seek(0.1, true)
	else:
		anim_player.play("normal_close")
		anim_player.seek(0.1, true)
		if setting_text:
			line_edit = get_node("back_rect/line_edit")
			line_edit.text = get_edit_text()
			line_edit.editable = false
			line_edit.visible = false
			back_rect.visible = true
			back_label.text = get_edit_text()
			max_select_timer = 30
	
	if disabled:
		alpha = 0.5
	
	set_process_input(false)

func _process(delta):
	if set_page_visible:
		visible = check_page()
	
	if select_timer > 0:
		select_timer -= 1 * (global.fps * delta)
		var temp = int(select_timer / 3)
		if temp % 2 == 0:
			label.visible = true
		else:
			label.visible = false
	else:
		label.visible = true
	if active:
		if not activated:
			if up:
				position.y = orig_pos.y - inactive_y
			else:
				position.y = orig_pos.y + inactive_y
			activated = true
		position.y += (orig_pos.y - position.y) / move_factor * (global.fps * delta)
	else:
		activated = false
		if up:
			position.y += (orig_pos.y + inactive_y - position.y) / move_factor * (global.fps * delta)
		else:
			position.y += (orig_pos.y - inactive_y - position.y) / move_factor * (global.fps * delta)
	if setting_slide:
		if not active:
			frame = 0
		if frame >= 1:
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_LEFT) or Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_LEFT):
				setting_slide_left()
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_RIGHT) or Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_RIGHT):
				setting_slide_right()

func _input(event):
	if rebinding:
		get_tree().set_input_as_handled()
		if not first_input:
			first_input = true
		else:
			var can_rebind = true
			if (event is InputEventJoypadMotion and ((event.axis_value > -0.8 and event.axis_value < 0.8) or not rebind_axis)) or \
			   ((event is InputEventKey or event is InputEventJoypadButton) and not event.pressed):
				can_rebind = false
			elif event is InputEventJoypadMotion:
				if event.axis_value > 0:
					event.axis_value = 1
				else:
					event.axis_value = -1
			if can_rebind:
				global.set_input(rebind_player1, event, rebind_input)
				set_rebind_text()
				set_process_input(false)
				rebinding = false
				emit_signal("rebound")

func set_label_text():
	label.text = text

func set_rebind_text():
	if setting_rebind:
		var prefix = global.INPUT_PLAYER1
		if not rebind_player1:
			prefix = global.INPUT_PLAYER2
		var actions = InputMap.get_action_list(prefix + rebind_input)
		var input_str_key = ""
		var input_str_pad = ""
		var input_str_stick = ""
		for action in actions:
			if action is InputEventKey:
				input_str_key = OS.get_scancode_string(action.scancode)
			elif action is InputEventJoypadButton:
				input_str_pad = "D" + str(action.device) + " BTN" + str(action.button_index)
			elif action is InputEventJoypadMotion:
				input_str_stick = "D" + str(action.device) + " AX" + str(action.axis) + " " + str(action.axis_value)
		if rebind_axis:
			label.text = input_str_key + "/" + input_str_pad + "/" + input_str_stick
		else:
			label.text = input_str_key + "/" + input_str_pad

func setting_slide_left():
	pass

func setting_slide_right():
	pass

func check_slide_edges():
	pass

func check_page():
	return true

func get_edit_text():
	return ""

func set_edit_text():
	back_label.text = line_edit.text

func highlight(highlight_num):
	if option_num == highlight_num and visible:
		if setting_rebind:
			if rebinding:
				if anim_player.current_animation != "rebind_set_open" and frame < 4:
					anim_player.play("rebind_set_open")
			else:
				if anim_player.current_animation != "rebind_set_close" and frame >= 4:
					anim_player.play("rebind_set_close")
				elif anim_player.current_animation != "rebind_open" and not opened:
					opened = true
					anim_player.play("rebind_open")
		elif setting_slide:
			frame = 1
			if setting_slide:
				check_slide_edges()
		else:
			if anim_player.current_animation != "normal_open" and not opened:
				opened = true
				anim_player.play("normal_open")
		label.add_color_override("font_color", Color(0.5, 1, 0.5, alpha))
		z_index = 100
		return true
	else:
		if setting_rebind:
			if anim_player.current_animation != "rebind_close" and opened:
				opened = false
				anim_player.play("rebind_close")
		elif setting_slide:
			frame = 0
		elif anim_player.current_animation != "normal_close" and opened:
			opened = false
			anim_player.play("normal_close")
			if setting_text:
				line_edit.editable = false
				line_edit.visible = false
				editing = false
		label.add_color_override("font_color", Color(1, 1, 1, alpha))
		z_index = 0
		return false

func select(highlight_num):
	if option_num == highlight_num and not setting_slide and visible:
		if setting_rebind and not rebinding:
			rebinding = true
			first_input = false
			set_process_input(true)
		elif setting_text:
			line_edit.editable = !line_edit.editable
			line_edit.visible = line_edit.editable
			editing = line_edit.editable
			if editing:
				line_edit.grab_focus()
				line_edit.caret_position = len(line_edit.text)
			else:
				set_edit_text()
			select_timer = max_select_timer
		elif not setting_rebind:
			select_timer = max_select_timer
			return true
	return false

func activate(prev_layer):
	active = true
	activated = false
	up = (prev_layer > layer)

func deactivate(next_layer):
	if active:
		up = (next_layer < layer)
	active = false

func set_orig_pos(new_orig_pos):
	orig_pos = new_orig_pos
