extends Projectile

var speed = 120
var vert_speed = -200
var gravity = 8

func _ready():
	knockback = Vector2(100, -150)
	rotate_effect = false
	effect_hit = preload("res://scenes/effect/slime/blue/attack_hit.tscn")

func reflect(hitbox_owner):
	vert_speed *= -1
	.reflect(hitbox_owner)

func process_move():
	if not sucked:
		vert_speed += gravity
		linear_vel = Vector2(speed * sprite.scale.x, vert_speed)
	
	.process_move()