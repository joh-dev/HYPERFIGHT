extends Projectile

var speed = 600
var min_speed = speed
var knockback_factor = 0.75
var add_move = Vector2()
var returning = false
var holding = false
var can_collide = true
var exceptions = []
var left_hold_bound = -125
var right_hold_bound = 125
var up_hold_bound = -75
var down_hold_bound = 75
var last_player_pos = Vector2()

onready var effect_hold = preload("res://scenes/effect/yoyo/proj/attack_hold.tscn")
onready var proj_special = preload("res://scenes/proj/yoyo/special.tscn")

func _ready():
	knockback = Vector2(0, -150)
	effect_hit = preload("res://scenes/effect/yoyo/proj/attack_hit.tscn")
	destroy_on_char_hit = false
	force_destroy_on_char_other_hit = true
	destroy_on_char_parry = false
	destroy_out_of_bounds = false
	can_suck = false

func _draw():
	draw_line(Vector2(0, 0), player.get_yoyo_pos() - position, Color(1, 1, 1))

func can_hold():
	return position.x >= left_hold_bound and position.x <= right_hold_bound and \
		   position.y >= up_hold_bound and position.y <= down_hold_bound

func destroy():
	disable_collision()
	if player.stun():
		create_effect_hit()

func reflect(body):
	returning = !returning
	if not returning:
		speed *= player.sprite.scale.x
	destroy()

func suck_action():
	destroy()

func process_move():
	update()
	
	var player_pos = player.get_yoyo_pos()
	if holding:
		can_collide = true
		linear_vel = Vector2(0, 0)
		if player.holding and player.attacking:
			if anim_player.current_animation != "drag":
				play_anim_this_frame("drag")
		elif anim_player.current_animation != "hold":
			play_anim_this_frame("hold")
	else:
		if anim_player.current_animation != "attack" and can_collide:
			play_anim_this_frame("attack")
		
		if not returning:
			speed *= 0.775
			if abs(speed) < 6 or player.dead:
				speed = abs(speed)
				returning = true
			linear_vel = Vector2(speed, 0) + add_move
			knockback.x = linear_vel.x * knockback_factor
		else:
			speed = abs(speed)
			if speed < min_speed:
				speed *= 1.3
			else:
				speed = min_speed
			linear_vel = ((player_pos - position) / 10 * speed) + add_move
			knockback.x = linear_vel.x * knockback_factor
			if abs(position.distance_to(player_pos)) <= player.yoyo_return_dist:
				player.stop_attacking()
				player.curr_proj = null
				destroy_no_effect()
	last_player_pos = player.position
	collide_with_char = !holding and can_collide
	
	.process_move()

func parry_effect():
	disable_collision()
	player.stun()

func disable_collision():
	can_collide = false
	collide_with_char = !holding and can_collide
	if anim_player.current_animation != "hold":
		play_anim_this_frame("hold")

func create_hold_effect():
	create_effect(effect_hold)

func create_special():
	create_projectile(proj_special)
	destroy_no_effect()
