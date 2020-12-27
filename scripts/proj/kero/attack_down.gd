extends Projectile

var speed = 60
var gravity = 6
var player_collided = false
var knockback_factor = 1
var collide_with_own_player = true
var collide_timer = 0
var max_collide_timer = 30

func _ready():
	add_to_group(global.GROUP_PROJ_KERO)
	create_shadow(0, 0)
	knockback = Vector2(50, -250)
	knockback_flip_with_scale = false
	effect_hit = preload("res://scenes/effect/kero/proj/attack_down_hit.tscn")
	left_bound = -139
	right_bound = 139

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
	linear_vel.y += gravity
	if hitbox.get_global_rect().position.y + hitbox.rect_size.y >= global.floor_y:
		position.y = global.floor_y - hitbox.rect_size.y - hitbox.rect_position.y
		linear_vel.y *= -1
		play_anim_this_frame("bounce")
		create_effect_hit()
	
	if collide_timer > 0:
		collide_timer -= 1
	else:
		collide_with_own_player = true
	
	if not anim_player.is_playing():
		play_anim_this_frame("attack")
	
	.process_move()

func process_hitbox_collision(hitbox, call_other):
	knockback.x = linear_vel.x * knockback_factor
	var hitbox_owner = hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group(global.GROUP_CHAR_KERO) and player_num == hitbox_owner.player_num:
		if call_other:
			hitbox_owner.process_hitbox_collision(self.hitbox, false)
	elif player_num != hitbox_owner.player_num:
		.process_hitbox_collision(hitbox, call_other)
