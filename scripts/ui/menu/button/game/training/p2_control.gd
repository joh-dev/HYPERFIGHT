extends UiMenuButton

var game

func setting_slide_left():
	var p2_cpu = game.is_p2_cpu()
	var p2_cpu_type = game.get_p2_cpu_type()
	if p2_cpu:
		match p2_cpu_type:
			global.CPU_TYPE.dummy_jumping:
				game.set_p2_cpu_type(global.CPU_TYPE.dummy_standing)
			global.CPU_TYPE.normal:
				game.set_p2_cpu_type(global.CPU_TYPE.dummy_jumping)
	else:
		game.set_p2_cpu(true)
		game.set_p2_cpu_type(global.CPU_TYPE.normal)
	check_slide_edges()

func setting_slide_right():
	var p2_cpu = game.is_p2_cpu()
	var p2_cpu_type = game.get_p2_cpu_type()
	if p2_cpu:
		match p2_cpu_type:
			global.CPU_TYPE.dummy_standing:
				game.set_p2_cpu_type(global.CPU_TYPE.dummy_jumping)
			global.CPU_TYPE.dummy_jumping:
				game.set_p2_cpu_type(global.CPU_TYPE.normal)
			global.CPU_TYPE.normal:
				game.set_p2_cpu(false)
	check_slide_edges()

func check_slide_edges():
	set_label_text()
	var p2_cpu = game.is_p2_cpu()
	var p2_cpu_type = game.get_p2_cpu_type()
	if not p2_cpu:
		frame = 3
	elif p2_cpu_type == global.CPU_TYPE.dummy_standing:
		frame = 2
	else:
		frame = 1

func set_label_text():
	if game == null:
		game = get_parent().get_parent().get_parent()
	var p2_cpu = game.is_p2_cpu()
	var p2_cpu_type = game.get_p2_cpu_type()
	label.text = "P2 Ctrl: "
	if p2_cpu:
		match p2_cpu_type:
			global.CPU_TYPE.dummy_standing:
				label.text += "Stand"
			global.CPU_TYPE.dummy_jumping:
				label.text += "Jump"
			global.CPU_TYPE.normal:
				label.text += "CPU"
	else:
		label.text += "P2"