extends Node2D

var bg_move = 750
var bg_grid_edge = 128
var max_timer = 4
var timer = 10
var inc = 0.2
var index = 0

onready var bg_grid = get_node("bg_grid")

func _ready():
	$text.text = "FREE TO PLAY"

func _process(delta):
	if bg_move != 0:
		bg_grid.position = Vector2(bg_grid.position.x + bg_move * delta, bg_grid.position.y)
		if bg_grid.position.x > bg_grid_edge + bg_grid_edge:
			bg_grid.position = Vector2(-bg_grid_edge + bg_grid_edge, bg_grid.position.y)
		elif bg_grid.position.x < -bg_grid_edge + bg_grid_edge:
			bg_grid.position = Vector2(bg_grid_edge + bg_grid_edge, bg_grid.position.y)
	if timer > 0:
		timer -= 1 * delta
	else:
		match index:
			0:
				$text.text = "ON STEAM AND ITCH"
			1:
				$text.rect_position.y += 20
				$text.text = "HYPERSNOW GAMES"
				$logo.visible = true
			2:
				$text.visible = false
				$logo.visible = false
		index += 1
		timer = max_timer
