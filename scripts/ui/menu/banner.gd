extends Sprite

var active = false
var move = 30

func _ready():
	position.y = 150

func _process(delta):
	if active:
		if position.y > 0:
			position.y -= move * (global.fps * delta)
		else:
			position.y = 0
	else:
		if position.y < 150:
			position.y += move * (global.fps * delta)
		else:
			position.y = 150

func activate():
	active = true

func deactivate():
	active = false
