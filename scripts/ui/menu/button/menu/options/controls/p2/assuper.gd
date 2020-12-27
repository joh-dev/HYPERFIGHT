extends UiMenuButton

func setting_slide_left():
	if global.player2_assuper:
		global.player2_assuper = false
		global.save_config_value(global.CFG_P2S, global.CFG_PS_ASSUPER, global.player2_assuper)
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if not global.player2_assuper:
		global.player2_assuper = true
		global.save_config_value(global.CFG_P2S, global.CFG_PS_ASSUPER, global.player2_assuper)
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.player2_assuper:
		frame = 3
	else:
		frame = 2

func set_label_text():
	if global.player2_assuper:
		label.text = "A+S Super: On"
	else:
		label.text = "A+S Super: Off"
