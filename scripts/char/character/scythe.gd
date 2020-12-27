extends Character

var attack_move = 800
var attack_move_factor = 0.8
var attack_down_move = 50
var attack_down_jump = 350
var attack_down_gravity = 23
var soul_meter = 0
var max_soul_meter = 5
var inf_soul_meter = false
var curr_proj = null

onready var audio2 = get_node("AudioStreamPlayer2")
onready var hitbox_attack = get_node("hitbox_attack")

onready var proj_special = preload("res://scenes/proj/scythe/special.tscn")
onready var proj_super = preload("res://scenes/proj/scythe/super.tscn")
onready var effect_hit = preload("res://scenes/effect/scythe/hit.tscn")
onready var effect_hit_meter = preload("res://scenes/effect/scythe/proj/special_hit_meter.tscn")
onready var effect_special = preload("res://scenes/effect/scythe/char/special.tscn")
onready var effect_cancel = preload("res://scenes/effect/scythe/char/cancel.tscn")
onready var illusion = preload("res://scenes/effect/scythe/char/illusion.tscn")

onready var sfx_attack = preload("res://audio/sfx/game/char/scythe/attack.ogg")
onready var sfx_attack_down = preload("res://audio/sfx/game/char/scythe/attack_down.ogg")
onready var sfx_attack_down_start = preload("res://audio/sfx/game/char/scythe/attack_down_start.ogg")
onready var sfx_attack_down_end = preload("res://audio/sfx/game/char/scythe/attack_down_end.ogg")
onready var sfx_attack_back = preload("res://audio/sfx/game/char/scythe/attack_back.ogg")
onready var sfx_special = preload("res://audio/sfx/game/char/scythe/special.ogg")
onready var sfx_special_teleport = preload("res://audio/sfx/game/char/scythe/special_teleport.ogg")
onready var sfx_super = preload("res://audio/sfx/game/char/scythe/super.ogg")
onready var sfx_super_charged = preload("res://audio/sfx/game/char/scythe/super_charged.ogg")
onready var sfx_hit = preload("res://audio/sfx/game/char/scythe/hit.ogg")

func _ready():
	add_to_group(global.GROUP_CHAR_SCYTHE)
	shadow_offset = -1
	set_attacking_on_attack = false
	set_attacking_on_special = false
	set_attacking_on_super = false
	adjust_facing_on_special = false
	h_dash_speed = 135

func inc_score():
	.inc_score()
	inc_soul_meter()

func inc_soul_meter():
	if soul_meter < max_soul_meter:
		soul_meter += 1
	game.update_meter_scythe(soul_meter, player_num)

func get_soul_meter():
	return soul_meter

func set_inf_soul_meter(is_inf_meter):
	inf_soul_meter = is_inf_meter
	if inf_soul_meter:
		soul_meter = max_soul_meter
		game.update_meter_scythe(soul_meter, player_num)

func reset_pos(new_pos):
	.reset_pos(new_pos)
	curr_proj = null

func special_condition():
	return score > 0 or curr_proj != null

func attack():
	if attacking:
		if not inf_soul_meter:
			soul_meter -= 1
			game.update_meter_scythe(soul_meter, player_num)
		if soul_meter <= 0:
			attack_while_attacking = false
		var old_scale_x = sprite.scale.x
		adjust_facing()
		if sign(old_scale_x) != sign(sprite.scale.x):
			linear_vel.x *= -1
		create_effect(effect_cancel)
	attacking = true
	attacked = false
	if check_player_input(global.INPUT_ACTION_DOWN):
		if linear_vel.x == 0:
			linear_vel.x = attack_down_move * sprite.scale.x
		linear_vel.y = 0
		play_anim_this_frame("attack_down")
		play_audio(sfx_attack_down_start)
	elif (check_player_input(global.INPUT_ACTION_LEFT) and sprite.scale.x > 0) or \
	   (check_player_input(global.INPUT_ACTION_RIGHT) and sprite.scale.x < 0):
		linear_vel.x = -attack_move * sprite.scale.x
		linear_vel.y = 0
		attacked = true
		play_anim_this_frame("attack_back")
		play_audio(sfx_attack_back)
	else:
		linear_vel.x = attack_move * sprite.scale.x
		linear_vel.y = 0
		attacked = true
		play_anim_this_frame("attack")
		play_audio(sfx_attack)

func special():
	if attacking:
		if not inf_soul_meter:
			soul_meter -= 1
			game.update_meter_scythe(soul_meter, player_num)
		if soul_meter <= 0:
			attack_while_attacking = false
		create_effect(effect_cancel)
	if curr_proj == null:
		adjust_facing()
		.special()
		attacking = true
		attacked = false
		linear_vel.x = 0
		linear_vel.y = 0
		play_anim_this_frame("special")
		play_audio(sfx_special)
	else:
		create_illusion()
		position = curr_proj.position
		var old_scale_x = sprite.scale.x
		adjust_facing()
		create_illusion()
		if sign(old_scale_x) != sign(sprite.scale.x):
			linear_vel.x *= -1
		curr_proj.queue_free()
		curr_proj = null
		if not attacking:
			play_audio(sfx_special_teleport)
		elif hurtbox.get_global_rect().position.y + hurtbox.rect_size.y >= global.floor_y:
			if anim_player.current_animation == "attack_down":
				position.y = global.floor_y - hurtbox.rect_size.y - hurtbox.rect_position.y - 1
			elif anim_player.current_animation == "attack_down_end":
				attacking = false

func super():
	.super()
	if soul_meter >= max_soul_meter:
		play_anim_this_frame("super_charged")
		create_super_flash(Vector2(-17 * sprite.scale.x, 9))
		play_audio(sfx_super_charged)
	else:
		play_anim_this_frame("super")
		create_super_flash(Vector2(-1 * sprite.scale.x, 0))
		play_audio(sfx_super)
	if attacking:
		if not inf_soul_meter:
			soul_meter -= 1
			game.update_meter_scythe(soul_meter, player_num)
		if soul_meter <= 0:
			attack_while_attacking = false
		adjust_facing()
		create_effect(effect_cancel)
	attacking = true
	attacked = false
	linear_vel.x = 0
	linear_vel.y = 0

func kill(knockback):
	.kill(knockback)
	play_audio(sfx_hit)

func process_attack():
	invincible = anim_player.current_animation == "special"
	attack_while_attacking = (soul_meter > 0)
	
	if attacking:
		if anim_player.current_animation == "super_charged":
			if sprite.frame >= 4 and not attacked:
				var p = create_projectile(proj_super, Vector2(22 * sprite.scale.x, 0))
				p.sprite.scale.x = sprite.scale.x
				attacked = true
		elif anim_player.current_animation == "super":
			if sprite.frame >= 4 and not attacked:
				soul_meter = max_soul_meter
				game.update_meter_scythe(soul_meter, player_num)
				attacked = true
		elif anim_player.current_animation == "special":
			if sprite.frame >= 1 and not attacked:
				curr_proj = create_projectile(proj_special, Vector2(16 * sprite.scale.x, 2))
				create_effect(effect_special, Vector2(16 * sprite.scale.x, 2))
				attacked = true
		else:
			if anim_player.current_animation == "attack_down":
				if sprite.frame >= 1 and not attacked:
					linear_vel.y = -attack_down_jump
					attacked = true
				elif attacked:
					linear_vel.y += attack_down_gravity
					if anim_player.current_animation_position >= 15 and not check_player_input(global.INPUT_ACTION_ATTACK):
						play_anim_this_frame("attack_down_end")
						attacked = false
					if on_floor:
						attacking = false
			elif anim_player.current_animation == "attack_down_end":
				linear_vel.y += attack_down_gravity
				if sprite.frame == 4 and not audio.playing and not attacked:
					play_audio(sfx_attack_down_end)
					attacked = true
				elif on_floor:
					play_anim_this_frame("attack_down_fall")
				
				process_own_hitbox_custom("on_hitbox_attack_collided", hitbox_attack, Vector2(75 * sprite.scale.x, -325), effect_hit)
			elif anim_player.current_animation == "attack_down_fall":
				linear_vel.x = 0
			elif anim_player.current_animation == "attack_back":
				linear_vel.x *= attack_move_factor
				if not on_floor and sprite.frame >= 2:
					linear_vel.y += attack_gravity
			elif anim_player.current_animation == "attack":
				linear_vel.x *= attack_move_factor
				if not on_floor and sprite.frame >= 6:
					linear_vel.y += attack_gravity
				
				process_own_hitbox_custom("on_hitbox_attack_collided", hitbox_attack, Vector2(75 * sprite.scale.x, -325), effect_hit)

func create_illusion():
	var e = create_effect(illusion)
	e.texture = sprite.texture
	e.hframes = sprite.hframes
	e.frame = sprite.frame
	e.scale.x = sprite.scale.x
	e.alpha = 1

func on_hitbox_attack_collided(other_hitbox, knockback, effect):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	var e = on_hitbox_collided(other_hitbox, knockback, effect, null)
	if e != null:
		e.position = Vector2(hitbox_owner.position.x, lerp(position.y, hitbox_owner.position.y, 0.5))
	elif hitbox_owner.is_in_group(global.GROUP_PROJECTILE) and player_num != hitbox_owner.player_num and \
		 hitbox_owner.can_collide_with_char():
		if hitbox_owner.is_in_group(global.GROUP_SUPERPROJ):
			hitbox_owner.create_effect_hit()
		elif hitbox_owner.can_destroy_on_proj_hit():
			create_effect(effect_hit_meter, hitbox_owner.position - position)
			hitbox_owner.destroy()
			inc_soul_meter()

func _on_AudioStreamPlayer_finished():
	if audio.stream == sfx_attack_down_start and anim_player.current_animation == "attack_down_end":
		play_audio(sfx_attack_down_end)
