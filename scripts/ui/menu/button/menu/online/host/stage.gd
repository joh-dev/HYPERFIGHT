extends UiMenuButton

func setting_slide_left():
	if global.host_stage_select > global.STAGE_SELECT.random:
		global.host_stage_select -= 1
	set_label_text()

func setting_slide_right():
	if global.host_stage_select < global.STAGE_SELECT.choose:
		global.host_stage_select += 1
	set_label_text()

func check_slide_edges():
	if global.host_stage_select == global.STAGE_SELECT.choose:
		frame = 3
	elif global.host_stage_select == global.STAGE_SELECT.random:
		frame = 2
	else:
		frame = 1

func set_label_text():
	match global.host_stage_select:
		global.STAGE_SELECT.random:
			label.text = "Stage: Random"
		global.STAGE_SELECT.choose:
			label.text = "Stage: Choose"

func check_page():
	return page == global.host_page