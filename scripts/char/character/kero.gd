extends Character

export var tongue_pos = Vector2()

var attack_speed = 400
var min_attack_speed = attack_speed
var attack_speed_inc = 10
var attack_knockback = Vector2(0, -250)
var suck_proj
var suck_proj_path
var suck_vel = Vector2()
var sucked = false
var attack_down_timer = 0
var attack_down_timer_max = 60

onready var audio2 = get_node("AudioStreamPlayer2")
onready var hitbox_attack = get_node("hitbox_attack")
onready var hitbox_special = get_node("hitbox_special")
onready var attack_down_recharge_player = get_node("attack_down_recharge_player")

onready var proj_attack_down = preload("res://scenes/proj/kero/attack_down.tscn")
onready var proj_super = preload("res://scenes/proj/kero/super.tscn")
onready var effect_hit = preload("res://scenes/effect/kero/char/attack_hit.tscn")

onready var sfx_attack = preload("res://audio/sfx/game/char/kero/attack.ogg")
onready var sfx_attack_down = preload("res://audio/sfx/game/char/kero/attack_down.ogg")
onready var sfx_special = preload("res://audio/sfx/game/char/kero/special.ogg")
onready var sfx_special_swallow = preload("res://audio/sfx/game/char/kero/special_swallow.ogg")
onready var sfx_super_swallow = preload("res://audio/sfx/game/char/kero/super_swallow.ogg")
onready var sfx_super = preload("res://audio/sfx/game/char/kero/super.ogg")
onready var sfx_hit = preload("res://audio/sfx/game/char/kero/hit.ogg")

func _ready():
	add_to_group(global.GROUP_CHAR_KERO)
	size = Vector2(12, 22)
	shadow_offset = -1
	walk_speed = 80
	jump = 400
	h_dash_speed = 250
	effect_y_offset = 16
	special_pos_relevant = false

func reset_pos(new_pos):
	.reset_pos(new_pos)
	if suck_proj != null:
		suck_proj.queue_free()
		suck_proj = null
	sucked = false

func special_condition():
	return score > 0 or sucked

func super_condition():
	return score >= 2 or (score >= 1 and sucked)

func attack():
	attacked = false
	linear_vel.x = 0
	linear_vel.y = 0
	if check_player_input(global.INPUT_ACTION_DOWN):
		if sucked:
			if attack_down_timer <= 0:
				play_anim_this_frame("attack_down_sucked")
			else:
				play_anim_this_frame("attack_down_fail_sucked")
		else:
			if attack_down_timer <= 0:
				play_anim_this_frame("attack_down")
			else:
				play_anim_this_frame("attack_down_fail")
	else:
		if not on_floor:
			if sucked:
				play_anim_this_frame("attack_air_sucked")
			else:
				play_anim_this_frame("attack_air")
		else:
			if sucked:
				play_anim_this_frame("attack_sucked")
			else:
				play_anim_this_frame("attack")

func special():
	attacked = false
	linear_vel.x = 0
	linear_vel.y = 0
	if sucked:
		if check_player_input(global.INPUT_ACTION_DOWN):
			play_anim_this_frame("special_spit")
		else:
			inc_temp_score()
			if suck_proj.is_in_group(global.GROUP_SUPERPROJ):
				inc_temp_score()
			suck_proj.queue_free()
			suck_proj = null
			sucked = false
			play_anim_this_frame("special_swallow")
			play_audio(sfx_special_swallow)
	else:
		.special()
		play_anim_this_frame("special")
		play_audio(sfx_special)

func super():
	attacked = false
	linear_vel.x = 0
	linear_vel.y = 0
	if sucked:
		inc_temp_score()
		inc_temp_score()
		if suck_proj.is_in_group(global.GROUP_SUPERPROJ):
			inc_temp_score()
		suck_proj.queue_free()
		suck_proj = null
		sucked = false
		play_anim_this_frame("special_swallow")
		dec_score()
		play_audio(sfx_super_swallow)
	else:
		.super()
		play_anim_this_frame("super")
	create_super_flash(Vector2(10 * sprite.scale.x, 12))

func kill(knockback):
	.kill(knockback)
	play_audio(sfx_hit)

func process_attack():
	invincible = anim_player.current_animation == "special"
	
	if attack_down_timer > 0:
		attack_down_timer -= 1
		if attack_down_timer <= 0:
			attack_down_recharge_player.play("recharge")
	
	if attacking:
		if anim_player.current_animation == "special":
			if suck_proj != null:
				if get_parent().has_node(suck_proj_path):
					suck_proj.position = position + Vector2(tongue_pos.x * sprite.scale.x, tongue_pos.y)
				else:
					suck_proj = null
			process_own_hitbox_custom("on_hitbox_special_collided", hitbox_special)
		elif anim_player.current_animation == "special_swallow" or anim_player.current_animation == "attack_down_fail" or \
			 anim_player.current_animation == "attack_down_fail_sucked":
			pass
		elif anim_player.current_animation == "special_spit":
			if not attacked and sprite.frame >= 3:
				get_parent().add_child(suck_proj)
				suck_proj.unsuck()
				suck_proj.position = position + Vector2(16 * sprite.scale.x, 12)
				suck_proj.linear_vel = suck_vel
				if sign(suck_proj.linear_vel.x) != sprite.scale.x:
					suck_proj.linear_vel.x *= -1
				if suck_proj.sprite.scale.x != sprite.scale.x:
					suck_proj.flip()
				suck_proj.set_player(self)
				suck_proj = null
				sucked = false
				attacked = true
				play_audio(sfx_attack_down)
		elif anim_player.current_animation == "attack_down" or anim_player.current_animation == "attack_down_sucked" or \
			 anim_player.current_animation == "super":
			if not attacked and sprite.frame >= 3:
				var p
				if anim_player.current_animation == "attack_down" or anim_player.current_animation == "attack_down_sucked":
					p = proj_attack_down
					play_audio(sfx_attack_down)
					attack_down_timer = attack_down_timer_max
				else:
					p = proj_super
					play_audio(sfx_super)
				p = create_projectile(p, Vector2(16 * sprite.scale.x, 12))
				p.linear_vel.x = p.speed * sprite.scale.x
				attacked = true
		else:
			if anim_player.current_animation == "attack" or anim_player.current_animation == "attack_air" or \
			   anim_player.current_animation == "attack_sucked" or anim_player.current_animation == "attack_air_sucked":
				if sprite.frame >= 4 and not attacked:
					attack_speed = min_attack_speed
					linear_vel.y = 0
					if on_floor:
						linear_vel.x = attack_speed * sprite.scale.x
						linear_vel.y = 0
					else:
						linear_vel.y = attack_speed * 0.6
					attacked = true
					play_audio(sfx_attack)
				elif attacked:
					attack_speed += attack_speed_inc
					if on_floor:
						linear_vel.x = attack_speed * sprite.scale.x
					else:
						linear_vel.x = (attack_speed * 0.6) * sprite.scale.x
				else:
					linear_vel.x = 0
					linear_vel.y = 0
				if (anim_player.current_animation == "attack_air" or \
					anim_player.current_animation == "attack_air_sucked") and on_floor:
					if sucked:
						play_anim_this_frame("attack_hit_sucked")
					else:
						play_anim_this_frame("attack_hit")
					linear_vel = Vector2(linear_vel.x * -0.1, attack_knockback.y)
					on_floor = false
					create_effect(effect_hit, Vector2(sprite.scale.x * 16, 24))
				
				process_own_hitbox(hitbox_attack, Vector2(75 * sprite.scale.x, -325), effect_hit, Vector2(sprite.scale.x * 20, 22))
			elif not on_floor:
				linear_vel.y += gravity
			if curr_frame % 6 == 0:
				create_afterimage()
			if (anim_player.current_animation == "attack_hit" or anim_player.current_animation == "attack_hit_sucked") and \
				on_floor and sprite.frame >= 2:
				play_anim_this_frame("idle")
				attacking = false

func process_anim():
	var new_anim = "idle"
	if sucked:
		new_anim = "idle_sucked"
	if win:
		if sucked:
			new_anim = "win_sucked"
		else:
			new_anim = "win"
	elif sucked:
		if dead:
			if on_floor:
				new_anim = "dead_sucked"
			else:
				new_anim = "fall_sucked"
		elif attacking:
			if anim_player.current_animation == "special_spit":
				new_anim = "special_spit"
			elif anim_player.current_animation == "attack_down_sucked":
				new_anim = "attack_down_sucked"
			elif anim_player.current_animation == "attack_down_fail_sucked":
				new_anim = "attack_down_fail_sucked"
			elif anim_player.current_animation == "attack_air_sucked":
				new_anim = "attack_air_sucked"
			elif anim_player.current_animation == "attack_hit_sucked":
				new_anim = "attack_hit_sucked"
			else:
				new_anim = "attack_sucked"
		else:
			if not on_floor:
				new_anim = "jump_sucked"
			elif linear_vel.x != 0:
				new_anim = "walk_forwards_sucked"
				if sign(sprite.scale.x) != sign(linear_vel.x):
					new_anim = "walk_backwards_sucked"
	elif dead:
		if on_floor:
			new_anim = "dead"
		else:
			new_anim = "fall"
	elif attacking:
		new_anim = process_attack_anim()
	else:
		if not on_floor:
			new_anim = "jump"
		elif linear_vel.x != 0:
			new_anim = "walk_forwards"
			if sign(sprite.scale.x) != sign(linear_vel.x):
				new_anim = "walk_backwards"
	if anim_player.current_animation != new_anim:
		play_anim_this_frame(new_anim)

func process_edge_hit():
	if attacking and attacked and \
		 (anim_player.current_animation == "attack" or anim_player.current_animation == "attack_air" or \
		  anim_player.current_animation == "attack_sucked" or anim_player.current_animation == "attack_air_sucked") and \
		 (on_floor or linear_vel.y == 0):
		linear_vel = Vector2(linear_vel.x * -0.1, attack_knockback.y)
		on_floor = false
		if sucked:
			play_anim_this_frame("attack_hit_sucked")
		else:
			play_anim_this_frame("attack_hit")
		create_effect(effect_hit, Vector2(sprite.scale.x * 4, 16))

func process_hitbox_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group(global.GROUP_PROJECTILE) and hitbox_owner.can_collide_with_char():
		if not hitbox_owner.is_in_group(global.GROUP_CHARACTER) and not invincible and \
		   hitbox_owner.is_in_group(global.GROUP_PROJ_KERO) and player_num == hitbox_owner.player_num:
			if hitbox_owner.can_collide_with_own_player():
				if linear_vel == Vector2(0, 0):
					hitbox_owner.linear_vel *= -1
				else:
					if attacking and attacked:
						hitbox_owner.linear_vel = linear_vel.normalized() * 600
					else:
						hitbox_owner.linear_vel = linear_vel.normalized() * 300
					linear_vel *= -1
				hitbox_owner.player_collided = true
				hitbox_owner.set_uncollidable()
				if attacking and attacked:
					if linear_vel.y == 0:
						linear_vel.y = attack_knockback.y
					on_floor = false
					if sucked:
						play_anim_this_frame("attack_hit_sucked")
					else:
						play_anim_this_frame("attack_hit")
				create_effect(effect_hit, lerp(position + Vector2(0, 16), hitbox_owner.position, 0.75) - position)
		elif call_other:
			hitbox_owner.process_hitbox_collision(hurtbox, false)

func hitbox_kill_effect(hitbox_owner, effect, effect_pos):
	if attacking and attacked and \
		 (anim_player.current_animation == "attack" or anim_player.current_animation == "attack_air" or \
		  anim_player.current_animation == "attack_sucked" or anim_player.current_animation == "attack_air_sucked"):
		linear_vel = Vector2(linear_vel.x * -0.1, attack_knockback.y)
		on_floor = false
		if sucked:
			play_anim_this_frame("attack_hit_sucked")
		else:
			play_anim_this_frame("attack_hit")
	return .hitbox_kill_effect(hitbox_owner, effect, effect_pos)

func hitbox_parry_effect(hitbox_owner, effect, effect_pos):
	return hitbox_kill_effect(hitbox_owner, effect, effect_pos)

func hitbox_hit_effect(hitbox_owner, effect, effect_pos):
	if not hitbox_owner.is_dashing():
		linear_vel = Vector2(linear_vel.x * -0.1, attack_knockback.y)
		on_floor = false
		if sucked:
			play_anim_this_frame("attack_hit_sucked")
		else:
			play_anim_this_frame("attack_hit")
		return create_effect(effect, effect_pos)
	return null

func on_hitbox_special_collided(other_hitbox):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group(global.GROUP_PROJECTILE) and not hitbox_owner.is_in_group(global.GROUP_CHARACTER) and suck_proj == null and hitbox_owner.suck():
		suck_proj = hitbox_owner
		suck_proj_path = get_parent().get_path_to(suck_proj)
		suck_proj.reflect(self)
		suck_vel = suck_proj.linear_vel
		suck_proj.linear_vel = Vector2.ZERO

func on_anim_finished(anim_name):
	if attacking:
		attacking = false
		if anim_name == "special" and suck_proj != null:
			sucked = true
			get_parent().remove_child(suck_proj)
		play_anim_this_frame("idle")
