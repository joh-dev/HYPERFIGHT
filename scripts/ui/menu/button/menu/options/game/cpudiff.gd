extends UiMenuButton

func setting_slide_left():
	if global.cpu_diff > global.CPU_DIFF.normal:
		global.cpu_diff -= 1
	global.set_cpu_diff()
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if global.cpu_diff < global.CPU_DIFF.hard:
		global.cpu_diff += 1
	global.set_cpu_diff()
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.cpu_diff == global.CPU_DIFF.hard:
		frame = 3
	elif global.cpu_diff == global.CPU_DIFF.normal:
		frame = 2
	else:
		frame = 1

func set_label_text():
	match global.cpu_diff:
		global.CPU_DIFF.normal:
			label.text = "CPU: Normal"
		global.CPU_DIFF.hard:
			label.text = "CPU: Hard"