extends UiMenuButton

func setting_slide_left():
	if global.player1_assuper:
		global.player1_assuper = false
		global.save_config_value(global.CFG_P1S, global.CFG_PS_ASSUPER, global.player1_assuper)
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if not global.player1_assuper:
		global.player1_assuper = true
		global.save_config_value(global.CFG_P1S, global.CFG_PS_ASSUPER, global.player1_assuper)
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.player1_assuper:
		frame = 3
	else:
		frame = 2

func set_label_text():
	if global.player1_assuper:
		label.text = "A+S Super: On"
	else:
		label.text = "A+S Super: Off"
