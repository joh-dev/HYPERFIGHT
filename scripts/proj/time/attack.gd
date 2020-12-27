extends Projectile

var speed = 720
var vert_speed = 0

var effect_hit_chr = preload("res://scenes/effect/time/proj/chr/attack_hit.tscn")

func _ready():
	knockback = Vector2(100, -150)
	effect_hit = preload("res://scenes/effect/time/proj/attack_hit.tscn")

func set_christmas():
	play_anim_this_frame("attack_chr")
	effect_hit = effect_hit_chr

func set_rot():
	var angle = Vector2(speed, vert_speed).angle()
	sprite.rotation = angle * sprite.scale.x

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