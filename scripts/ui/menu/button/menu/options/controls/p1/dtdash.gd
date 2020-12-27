extends UiMenuButton

func setting_slide_left():
	if global.player1_dtdash:
		global.player1_dtdash = false
		global.save_config_value(global.CFG_P1S, global.CFG_PS_DTDASH, global.player1_dtdash)
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if not global.player1_dtdash:
		global.player1_dtdash = true
		global.save_config_value(global.CFG_P1S, global.CFG_PS_DTDASH, global.player1_dtdash)
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.player1_dtdash:
		frame = 3
	else:
		frame = 2

func set_label_text():
	if global.player1_dtdash:
		label.text = "DTap Dash: On"
	else:
		label.text = "DTap Dash: Off"
