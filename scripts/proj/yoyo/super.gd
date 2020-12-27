extends SuperProjectile

var speed = 15
var max_speed = 600
var knockback_factor = 2
var add_move = Vector2()
var returning = false

func _ready():
	create_shadow(0, 0)
	knockback = Vector2(0, -150)
	effect_hit = preload("res://scenes/effect/yoyo/proj/attack_hit.tscn")
	destroy_on_char_hit = false
	destroy_on_superproj_hit = false
	destroy_out_of_bounds = false
	can_suck = false
	hitbox.set_monitoring(false)

func _draw():
	draw_line(Vector2(0, 0), player.get_yoyo_pos() - position, Color(1, 1, 1))

func can_hold():
	return false

func set_init_vel():
	linear_vel = Vector2(speed * 20, 0)

func process_move():
	update()
	
	var player_pos = player.get_yoyo_pos()
	if anim_player.current_animation == "start":
		position = player_pos
	else:
		if not returning:
			linear_vel += (player_pos - position).normalized() * abs(speed) + add_move / 16
			linear_vel = linear_vel.clamped(max_speed)
			knockback.x = linear_vel.x * knockback_factor
			if anim_player.current_animation != "attack" and not anim_player.is_playing():
				play_anim_this_frame("attack")
		else:
			linear_vel = ((player_pos - position) / 64 * max_speed)
			knockback.x = linear_vel.x * knockback_factor
			if anim_player.current_animation != "return":
				play_anim_this_frame("return")
			if abs(position.distance_to(player_pos)) <= player.yoyo_return_dist:
				player.curr_proj = null
				destroy_no_effect()
		
		.process_move()

func disable_collision():
	pass

func create_hold_effect():
	pass

func create_special():
	pass
