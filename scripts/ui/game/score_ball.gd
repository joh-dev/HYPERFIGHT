extends Node2D

var score = 0
var temp_score = 0
export var reversed = false

func _ready():
	if reversed:
		scale.x = -1

func update_ball(ball, frame_num):
	match ball:
		1:
			$ball_1.frame = frame_num
		2:
			$ball_2.frame = frame_num
		3:
			$ball_3.frame = frame_num
		4:
			$ball_4.frame = frame_num
		5:
			$ball_5.frame = frame_num

func use_ball():
	if temp_score > 0:
		temp_score -= 1
		var count = score
		while count > temp_score:
			update_ball(count, 1)
			count -= 1

func inc_score():
	score += 1
	if score > 5:
		score = 5
	temp_score = score
	var count = 5
	while count > 0:
		if count <= score:
			update_ball(count, 2)
		else:
			update_ball(count, 0)
		count -= 1
	return score
	
func win_score():
	score = 5
	temp_score = score
	var count = 5
	while count > 0:
		update_ball(count, 2)
		count -= 1
	return score

func reset_score():
	score = 0
	temp_score = score
	var count = 5
	while count > 0:
		update_ball(count, 0)
		count -= 1
	return score

func set_score(new_score):
	reset_score()
	for i in range(new_score):
		inc_score()

func remove_temps():
	score = temp_score
	var count = 5
	while count > 0:
		if count <= score:
			update_ball(count, 2)
		else:
			update_ball(count, 0)
		count -= 1
