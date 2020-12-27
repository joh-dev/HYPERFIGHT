class_name UiSelectButton
extends Sprite

var select_timer = -1
var max_select_timer = 60
var highlight_frame = 1

func _process(delta):
	if select_timer > 0:
		select_timer -= 1 * (global.fps * delta)
		var temp = int(select_timer / 3)
		if temp % 2 == 0:
			frame = highlight_frame
		else:
			frame = 0

func set_highlight(player_num):
	if player_num > 0:
		frame = highlight_frame
	else:
		frame = 0

func select(player_num):
	var player_prefix = global.INPUT_PLAYER1
	if player_num != 1:
		player_prefix = global.INPUT_PLAYER2
	if Input.is_action_just_pressed(player_prefix + global.INPUT_ACTION_LEFT):
		return select_left()
	if Input.is_action_just_pressed(player_prefix + global.INPUT_ACTION_RIGHT):
		return select_right()
	if Input.is_action_just_pressed(player_prefix + global.INPUT_ACTION_UP):
		return select_up()
	if Input.is_action_just_pressed(player_prefix + global.INPUT_ACTION_DOWN):
		return select_down()
	return self

func select_left():
	var override_portrait = select_left_override()
	if override_portrait != null:
		return override_portrait
	var new_portrait = self
	var pos = position
	var can_wrap = true
	for portrait in get_tree().get_nodes_in_group("ui_select"):
		if abs(pos.x - portrait.position.x) > abs(pos.y - portrait.position.y):
			if pos.x - portrait.position.x > 0 and \
			   (pos.distance_to(portrait.position) <= pos.distance_to(new_portrait.position) or new_portrait == self):
				new_portrait = portrait
				can_wrap = false
			if can_wrap and pos.x - portrait.position.x < 0 and \
			   (abs(pos.y - portrait.position.y) < abs(pos.y - new_portrait.position.y) or
			   (abs(pos.x - portrait.position.x) >= abs(pos.x - new_portrait.position.x) and
			   abs(pos.y - portrait.position.y) <= abs(pos.y - new_portrait.position.y)) or new_portrait == self):
				new_portrait = portrait
	return new_portrait

func select_right():
	var override_portrait = select_right_override()
	if override_portrait != null:
		return override_portrait
	var new_portrait = self
	var pos = position
	var can_wrap = true
	for portrait in get_tree().get_nodes_in_group("ui_select"):
		if abs(pos.x - portrait.position.x) > abs(pos.y - portrait.position.y):
			if pos.x - portrait.position.x < 0 and \
			   (pos.distance_to(portrait.position) <= pos.distance_to(new_portrait.position) or new_portrait == self):
				new_portrait = portrait
				can_wrap = false
			if can_wrap and pos.x - portrait.position.x > 0 and \
			   (abs(pos.y - portrait.position.y) < abs(pos.y - new_portrait.position.y) or
			   (abs(pos.x - portrait.position.x) >= abs(pos.x - new_portrait.position.x) and
			   abs(pos.y - portrait.position.y) <= abs(pos.y - new_portrait.position.y)) or new_portrait == self):
				new_portrait = portrait
	return new_portrait

func select_up():
	var override_portrait = select_up_override()
	if override_portrait != null:
		return override_portrait
	var new_portrait = self
	var pos = position
	var can_wrap = true
	for portrait in get_tree().get_nodes_in_group("ui_select"):
		if abs(pos.x - portrait.position.x) < abs(pos.y - portrait.position.y):
			if pos.y - portrait.position.y > 0 and \
			   (pos.distance_to(portrait.position) <= pos.distance_to(new_portrait.position) or new_portrait == self):
				new_portrait = portrait
				can_wrap = false
			if can_wrap and pos.y - portrait.position.y < 0 and \
			   (abs(pos.x - portrait.position.x) < abs(pos.x - new_portrait.position.x) or
			   (abs(pos.x - portrait.position.x) <= abs(pos.x - new_portrait.position.x) and
			   abs(pos.y - portrait.position.y) >= abs(pos.y - new_portrait.position.y)) or new_portrait == self):
				new_portrait = portrait
	return new_portrait

func select_down():
	var override_portrait = select_down_override()
	if override_portrait != null:
		return override_portrait
	var new_portrait = self
	var pos = position
	var can_wrap = true
	for portrait in get_tree().get_nodes_in_group("ui_select"):
		if abs(pos.x - portrait.position.x) < abs(pos.y - portrait.position.y):
			if pos.y - portrait.position.y < 0 and \
			   (pos.distance_to(portrait.position) <= pos.distance_to(new_portrait.position) or new_portrait == self):
				new_portrait = portrait
				can_wrap = false
			if can_wrap and pos.y - portrait.position.y > 0 and \
			   (abs(pos.x - portrait.position.x) < abs(pos.x - new_portrait.position.x) or
			   (abs(pos.x - portrait.position.x) <= abs(pos.x - new_portrait.position.x) and
			   abs(pos.y - portrait.position.y) >= abs(pos.y - new_portrait.position.y)) or new_portrait == self):
				new_portrait = portrait
	return new_portrait

func select_left_override():
	return null

func select_right_override():
	return null

func select_up_override():
	return null

func select_down_override():
	return null

func select_confirm():
	select_timer = max_select_timer
