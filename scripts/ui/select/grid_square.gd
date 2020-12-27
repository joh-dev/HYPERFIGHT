extends Sprite

var up = false
var alpha = 0.35

onready var timer = get_node("Timer")

func _ready():
	set_modulate(Color(1, 1, 1, alpha))
	timer.wait_time = 0.1 + (randi() % 5) * 0.01

func _process(delta):
	alpha -= 0.01 * (global.fps * delta)
	set_modulate(Color(1, 1, 1, alpha))
	if alpha <= 0:
		queue_free()

func _on_Timer_timeout():
	if up:
		position.y -= 16
	else:
		position.y += 16
