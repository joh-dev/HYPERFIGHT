extends UiMenuButton

var game

func setting_slide_left():
	var reset_pos = game.get_reset_pos()
	if reset_pos > 0:
		game.set_reset_pos(reset_pos - 1)
	check_slide_edges()

func setting_slide_right():
	var reset_pos = game.get_reset_pos()
	if reset_pos < 5:
		game.set_reset_pos(reset_pos + 1)
	check_slide_edges()

func check_slide_edges():
	set_label_text()
	var reset_pos = game.get_reset_pos()
	if reset_pos == 5:
		frame = 3
	elif reset_pos == 0:
		frame = 2
	else:
		frame = 1

func set_label_text():
	if game == null:
		game = get_parent().get_parent().get_parent()
	label.text = "Rst Pos.: "
	var reset_pos = game.get_reset_pos()
	match reset_pos:
		global.RESET_POS.middle:
			label.text += "Mid"
		global.RESET_POS.middleL:
			label.text += "MidL"
		global.RESET_POS.left:
			label.text += "Left"
		global.RESET_POS.leftR:
			label.text += "LeftR"
		global.RESET_POS.right:
			label.text += "Right"
		global.RESET_POS.rightL:
			label.text += "RightL"