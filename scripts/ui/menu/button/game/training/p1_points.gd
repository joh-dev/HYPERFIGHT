extends UiMenuButton

var game

func setting_slide_left():
	var p1_score = game.get_p1_score()
	if p1_score > 0:
		game.set_p1_score(p1_score - 1)
	check_slide_edges()

func setting_slide_right():
	var p1_score = game.get_p1_score()
	if p1_score < 6:
		game.set_p1_score(p1_score + 1)
	check_slide_edges()

func check_slide_edges():
	set_label_text()
	var p1_score = game.get_p1_score()
	if p1_score == 6:
		frame = 3
	elif p1_score == 0:
		frame = 2
	else:
		frame = 1

func set_label_text():
	if game == null:
		game = get_parent().get_parent().get_parent()
	var p1_score = game.get_p1_score()
	label.text = "P1 Points: "
	if p1_score != 6:
		label.text += str(p1_score)
	else:
		label.text += "Inf"
