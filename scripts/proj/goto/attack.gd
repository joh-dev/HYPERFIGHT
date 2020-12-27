extends Projectile

var speed = 180
var vert_speed = 0

func _ready():
	create_shadow(3, 1)
	knockback = Vector2(50, -250)
	effect_hit = preload("res://scenes/effect/goto/attack_hit.tscn")
	effect_offset = Vector2(8, 0)

func set_vert_speed(vert_speed):
	self.vert_speed = vert_speed
	position.y += sign(vert_speed)

func set_rot():
	var angle = Vector2(speed, vert_speed).angle()
	sprite.rotation = angle * sprite.scale.x * 1.2

func reflect(hitbox_owner):
	sprite.scale.x *= -1
	vert_speed *= -1
	change_players(hitbox_owner)

func flip():
	sprite.scale.x *= -1
	set_rot()

func process_move():
	linear_vel = Vector2(speed * sprite.scale.x, vert_speed)
	
	.process_move()
