extends SuperProjectile

var speed = 60
var max_speed = 180
var gravity = 6
var player_collided = false
var collide_with_own_player = true
var knockback_factor = 2
var left_edge = -125
var right_edge = 125
var top_edge = -72
var bounces = 8
var collide_timer = 0
var max_collide_timer = 30

func _ready():
	add_to_group(global.GROUP_PROJ_KERO)
	knockback = Vector2(50, -250)
	knockback_flip_with_scale = false
	linear_vel.x = speed * sprite.scale.x
	effect_hit = preload("res://scenes/effect/kero/proj/super_hit.tscn")

func set_uncollidable():
	collide_timer = max_collide_timer
	collide_with_own_player = false

func set_player(player):
	.set_player(player)
	set_uncollidable()

func reflect(hitbox_owner):
	linear_vel.x *= -1
	linear_vel.y *= -1
	change_players(hitbox_owner)

func flip():
	pass

func can_collide_with_own_player():
	return collide_with_own_player

func process_move():
	if collide_timer > 0:
		collide_timer -= 1
	else:
		collide_with_own_player = true
	
	if position.x < left_edge:
		position.x = left_edge
		linear_vel.x *= -1
		play_anim_this_frame("bounce_hor")
		bounces -= 1
		create_effect_hit()
	if position.x > right_edge:
		position.x = right_edge
		linear_vel.x *= -1
		play_anim_this_frame("bounce_hor")
		bounces -= 1
		create_effect_hit()
	if position.y < top_edge:
		position.y = top_edge
		linear_vel.y *= -1
		play_anim_this_frame("bounce_vert")
		bounces -= 1
		create_effect_hit()
	if hitbox.get_global_rect().position.y + hitbox.rect_size.y >= global.floor_y:
		position.y = global.floor_y - hitbox.rect_size.y - hitbox.rect_position.y
		linear_vel.y *= -1
		play_anim_this_frame("bounce_vert")
		bounces -= 1
		create_effect_hit()
	
	if linear_vel.length() > max_speed:
		linear_vel = linear_vel.clamped(max_speed)
	
	if not anim_player.is_playing():
		if bounces <= 0:
			destroy_no_effect()
		else:
			play_anim_this_frame("attack")
	elif bounces <= 0:
		linear_vel = Vector2(0, 0)
		destroy()
	
	if not player.can_act:
		destroy()
	
	.process_move()

func process_hitbox_collision(hitbox, call_other):
	knockback.x = linear_vel.x * knockback_factor
	var hitbox_owner = hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group(global.GROUP_CHAR_KERO) and player_num == hitbox_owner.player_num:
		if collide_with_own_player:
			bounces -= 1
			create_effect_hit()
		if call_other:
			hitbox_owner.process_hitbox_collision(self.hitbox, false)
	elif player_num != hitbox_owner.player_num:
		.process_hitbox_collision(hitbox, call_other)
