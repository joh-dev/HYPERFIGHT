extends Character

var super_timer = 0
var min_super_timer = 80
var max_super_timer = 210
var super_frame_delay = 240
var last_music_pos = 0
var attack_down_move = 550

onready var hitbox_attack_down = get_node("hitbox_attack_down")
onready var hitbox_special = get_node("hitbox_special")
onready var proj_attack = preload("res://scenes/proj/time/attack.tscn")
onready var proj_attack_short = preload("res://scenes/proj/time/attack_short.tscn")
onready var effect_hit = preload("res://scenes/effect/time/char/special_hit.tscn")
onready var effect_hit_down = preload("res://scenes/effect/time/char/attack_down_hit.tscn")
onready var effect_super = preload("res://scenes/effect/time/char/super.tscn")
onready var effect_super_end = preload("res://scenes/effect/time/char/super_end.tscn")

onready var sfx_attack = preload("res://audio/sfx/game/char/time/attack.ogg")
onready var sfx_attack_down = preload("res://audio/sfx/game/char/time/attack_down.ogg")
onready var sfx_special = preload("res://audio/sfx/game/char/time/special.ogg")
onready var sfx_super = preload("res://audio/sfx/game/char/time/super.ogg")
onready var sfx_super_boom = preload("res://audio/sfx/game/char/time/super_boom.ogg")
onready var sfx_super_boom_end = preload("res://audio/sfx/game/char/time/super_boom_end.ogg")
onready var sfx_hit = preload("res://audio/sfx/game/char/time/hit.ogg")

func _ready():
	size = Vector2(12, 50)
	walk_speed = 55
	h_dash_speed = 150

func reset_pos(new_pos):
	.reset_pos(new_pos)
	super_timer = 0
	game.set_inverted(false)

func attack():
	attacked = false
	linear_vel.x *= 0.25
	linear_vel.y = 0
	if check_player_input(global.INPUT_ACTION_DOWN) and on_floor:
		play_anim_this_frame("attack_down")
		play_audio(sfx_attack_down)
	else:
		if is_christmas:
			play_anim_this_frame("attack_chr")
		else:
			play_anim_this_frame("attack")
		play_audio(sfx_attack)

func special():
	.special()
	attacked = false
	if is_christmas:
		play_anim_this_frame("special_chr")
	else:
		play_anim_this_frame("special")
	linear_vel.x *= 0.5
	play_audio(sfx_special)

func super():
	.super()
	attacked = false
	linear_vel.x = 0
	linear_vel.y = 0
	play_anim_this_frame("super")
	play_audio(sfx_super)

func super_condition():
	return not ignore_frame_delay and score >= 2

func kill(knockback):
	.kill(knockback)
	play_audio(sfx_hit)

func can_kill(other_num):
	return .can_kill(other_num) and super_timer <= 0

func can_kill_self():
	return .can_kill_self() and super_timer <= 0

func create_dash_effect(effect_pos, scale_x, rot_deg):
	var e = .create_dash_effect(effect_pos, scale_x, rot_deg)
	if super_timer > 0:
		e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)

func process_attack():
	invincible = false
	
	if super_timer > 0:
		invincible = true
		super_timer -= 1
		if super_timer <= 0:
			game.frame_delay = 0
			game.set_inverted(false)
			curr_frame_delay = -1
			ignore_frame_delay = false
			attacking = true
			play_anim_this_frame("super_end")
			var e = create_effect(effect_super_end, Vector2.ZERO)
			e.frame_delay_override = true
			play_audio(sfx_super_boom_end)
			global_audio.play(last_music_pos)
	if attacking:
		if anim_player.current_animation == "super":
			if not ignore_frame_delay and (anim_player.current_animation_position >= 90 or \
			   (anim_player.current_animation_position >= 45 and \
				not check_player_input(global.INPUT_ACTION_ATTACK) and \
				not check_player_input(global.INPUT_ACTION_SPECIAL) and \
				not check_player_input(global.INPUT_ACTION_SUPER) and \
				game.state != game.GAME_STATE.ko and game.state != game.GAME_STATE.ready)):
				ignore_frame_delay = true
				var minus_time = 210
				if anim_player.current_animation_position >= 90:
					minus_time = 0
				super_timer += min_super_timer + max_super_timer - minus_time
				game.frame_delay = min_super_timer + super_frame_delay - minus_time
				game.set_inverted(true)
				
				anim_player.seek(90, true)
				var e = create_effect(effect_super, Vector2.ZERO)
				e.frame_delay_override = true
				play_audio(sfx_super_boom)
				last_music_pos = global_audio.get_playback_position()
				global_audio.stop()
		elif anim_player.current_animation == "special" or anim_player.current_animation == "special_chr":
			invincible = true
			if attacked:
				if on_floor and sprite.frame <= 3:
					linear_vel.x = 0
					anim_player.seek(282)
			elif sprite.frame >= 2:
				position.y -= 256
				linear_vel.y = attack_gravity * 100
				on_floor = false
				attacked = true
			process_own_hitbox_custom("on_hitbox_special_collided", hitbox_special, Vector2(50 * sprite.scale.x, 500), effect_hit)
		elif anim_player.current_animation == "attack_down":
			if attacked:
				linear_vel.x *= 0.85
			else:
				linear_vel.x = 0
				if sprite.frame >= 2:
					linear_vel.x = attack_down_move * sprite.scale.x
					attacked = true
			linear_vel.y = 0
			process_own_hitbox_custom("on_hitbox_attack_down_collided", hitbox_attack_down, Vector2(100 * sprite.scale.x, -250), effect_hit_down, Vector2(sprite.scale.x * 20, 27))
		elif anim_player.current_animation == "attack" or anim_player.current_animation == "attack_chr":
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else:
				linear_vel.y = attack_gravity
			if not attacked:
				if not check_player_input(global.INPUT_ACTION_ATTACK) and sprite.frame <= 3:
					if is_christmas:
						play_anim_this_frame("attack_short_chr", 13)
					else:
						play_anim_this_frame("attack_short", 13)
				elif sprite.frame >= 5:
					var p = create_projectile(proj_attack, Vector2(8 * sprite.scale.x, 0))
					if super_timer > 0:
						p.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
					if check_player_input(global.INPUT_ACTION_UP):
						p.vert_speed -= 60
					if check_player_input(global.INPUT_ACTION_DOWN):
						p.vert_speed += 60
					p.sprite.scale.x = sprite.scale.x
					p.set_rot()
					if anim_player.current_animation == "attack_chr":
						p.set_christmas()
					attacked = true
		elif anim_player.current_animation == "attack_short" or anim_player.current_animation == "attack_short_chr":
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else:
				linear_vel.y = attack_gravity
			if not attacked:
				if sprite.frame >= 5:
					var p = create_projectile(proj_attack_short, Vector2(12 * sprite.scale.x, 0))
					if super_timer > 0:
						p.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
					if (check_player_input(global.INPUT_ACTION_LEFT) and sprite.scale.x > 0) or \
					   (check_player_input(global.INPUT_ACTION_RIGHT) and sprite.scale.x < 0):
						p.speed -= 60
					if (check_player_input(global.INPUT_ACTION_RIGHT) and sprite.scale.x > 0) or \
					   (check_player_input(global.INPUT_ACTION_LEFT) and sprite.scale.x < 0):
						p.speed += 60
					p.sprite.scale.x = sprite.scale.x
					if anim_player.current_animation == "attack_short_chr":
						p.set_christmas()
					attacked = true
		else:
			linear_vel.x = 0
			linear_vel.y = 0

func on_anim_finished(anim_name):
	if attacking:
		attacking = false
		if anim_name == "special" or anim_name == "special_chr":
			position.y -= 20
			linear_vel.x = -jump * sprite.scale.x / 2
			linear_vel.y = -jump
			on_floor = false
		elif anim_name == "attack_down":
			linear_vel.x = 0
			play_anim_this_frame("idle")
		else:
			play_anim_this_frame("idle")

func on_hitbox_attack_down_collided(other_hitbox, knockback, effect, effect_pos):
	var e = on_hitbox_collided(other_hitbox, knockback, effect, effect_pos)
	if e != null:
		e.scale.x = sprite.scale.x
		if super_timer > 0:
			e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)

func on_hitbox_special_collided(other_hitbox, knockback, effect):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	var e = on_hitbox_collided(other_hitbox, knockback, effect, null)
	if e != null:
		e.position = hitbox_owner.position + Vector2(0, 16)
		if super_timer > 0:
			e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
