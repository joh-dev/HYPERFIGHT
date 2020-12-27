extends UiMenuButton

var game

func setting_slide_left():
	var p2_score = game.get_p2_score()
	if p2_score > 0:
		game.set_p2_score(p2_score - 1)
	check_slide_edges()

func setting_slide_right():
	var p2_score = game.get_p2_score()
	if p2_score < 6:
		game.set_p2_score(p2_score + 1)
	check_slide_edges()

func check_slide_edges():
	set_label_text()
	var p2_score = game.get_p2_score()
	if p2_score == 6:
		frame = 3
	elif p2_score == 0:
		frame = 2
	else:
		frame = 1

func set_label_text():
	if game == null:
		game = get_parent().get_parent().get_parent()
	var p2_score = game.get_p2_score()
	label.text = "P2 Points: "
	if p2_score < 6:
		label.text += str(p2_score)
	else:
		label.text += "Inf"