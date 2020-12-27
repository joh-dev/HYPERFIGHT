extends SuperProjectile

var speed = 5
var vert_speed = 0

onready var afterimage_spr = preload("res://graphics/effect/scythe/proj/super_afterimage.png")

func _ready():
	create_shadow(3, 1)
	knockback = Vector2(100, -300)
	effect_hit = preload("res://scenes/effect/scythe/hit.tscn")
	effect_on_player = true
	effect_on_proj = true
	destroy_on_char_hit = false
	destroy_on_superproj_hit = false

func process_move():
	if not sucked:
		linear_vel = Vector2(speed * sprite.scale.x, vert_speed)
		speed *= 1.1
		var a = create_afterimage(0.5)
		a.texture = afterimage_spr
	
	
	.process_move()
