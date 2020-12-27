extends Projectile

const default_size = Vector2(12, 22)
const dead_size = Vector2(12, 8)

var size = default_size
var special_control = true

var frame_inputs = []
var buffer_inputs = []
var input_map = { \
  global.INPUT_ACTION_LEFT: false, \
  global.INPUT_ACTION_RIGHT: false, \
  global.INPUT_ACTION_UP: false, \
  global.INPUT_ACTION_DOWN: false, \
  global.INPUT_ACTION_ATTACK: false, \
  global.INPUT_ACTION_SPECIAL: false, \
  global.INPUT_ACTION_SUPER: false, \
  global.INPUT_ACTION_DASH: false }

var dtdash = true
var assuper = true
var cpu = false
var win = false
var invincible = false
var attacking = false
var attacked = false
var first_attack = false
var can_dash = true
var move_while_attacking = false
var dash_while_attacking = false
var on_floor = false
var h_airdashing = false
var v_airdashing = false
var can_act = true
var can_self_act = true
var dead = false
var other_player
var walk_speed = 90
var air_speed = 90
var h_dash_speed = 190
var v_dash_speed = 300
var jump = 375
var h_dash_jump = 150
var gravity = 18
var last_input = global.INPUT_ACTION_NONE
var last_input_frames = 0
var alpha = 1
var dash_alpha = 0.5
var dash_frames = 10
var curr_dash_frames = 0
var no_dash_frames = 0
var max_no_dash_frames = 10
var dash_inv_frames = 0
var max_dash_inv_frames = 30
var max_airdash_inv_frames = 10
var effect_y_offset = 0

var attack_down_jump = 250

onready var audio = get_node("AudioStreamPlayer")
onready var audio2 = get_node("AudioStreamPlayer2")
onready var dash_player = get_node("dash_player")

onready var proj_attack_down = preload("res://scenes/proj/slime/blue/attack_down.tscn")
onready var proj_super = preload("res://scenes/proj/slime/blue/super.tscn")
onready var effect_special = get_node("effect_special")

onready var effect_dash = preload("res://scenes/effect/dash.tscn")
onready var snd_dash = preload("res://audio/sfx/game/char/dash.ogg")
onready var snd_attack = preload("res://audio/sfx/game/char/slime/blue/attack.ogg")
onready var snd_attack_down = preload("res://audio/sfx/game/char/slime/blue/attack_down.ogg")
onready var snd_special = preload("res://audio/sfx/game/char/slime/blue/special.ogg")
onready var snd_special_revive = preload("res://audio/sfx/game/char/slime/blue/special_revive.ogg")
onready var snd_super = preload("res://audio/sfx/game/char/slime/blue/super.ogg")
onready var snd_hit = preload("res://audio/sfx/game/char/slime/blue/hit.ogg")

func _ready():
	add_to_group(global.GROUP_CHARACTER)
	create_shadow(0, 0)
	left_bound = -125
	right_bound = 125
	destroy_on_char_hit = false
	destroy_on_proj_hit = false
	destroy_on_superproj_hit = false
	destroy_on_char_parry = false
	destroy_out_of_bounds = false
	keep_in_bounds = true
	anim_disabled = true
	effect_offset = Vector2(16, 20)
	effect_hit = preload("res://scenes/effect/slime/blue/attack_hit.tscn")

func copy_player_vars(copy_player):
	other_player = copy_player.other_player
	dtdash = copy_player.dtdash
	assuper = copy_player.assuper
	effect_y_offset = copy_player.effect_y_offset

func copy_player_inputs(copy_player):
	input_map = copy_player.input_map
	frame_inputs = copy_player.frame_inputs
	buffer_inputs = copy_player.buffer_inputs
	special_control = copy_player.special_control
	can_act = copy_player.can_act
	win = copy_player.win
	cpu = copy_player.cpu

func input_condition(input):
	return can_act and can_self_act and special_control

func check_player_input(input):
	if input_condition(input):
		return input_map[input] or buffer_inputs.find(input) >= 0
	return false

func check_player_just_input(input):
	if input_condition(input):
		var inputted
		inputted = (input_map[input] and frame_inputs.find(input) >= 0) or buffer_inputs.find(input) >= 0
		if inputted:
			last_input = input
			last_input_frames = 0
			return inputted
	return false

func is_dashing():
	return alpha < 1

func can_destroy_other(other_num):
	return false

func can_act():
	return can_self_act

func can_attack():
	return not attacking and not is_dashing()

func can_kill(other_num):
	return can_act and can_self_act and not is_dashing() and not invincible and player_num != other_num

func can_parry(other_num):
	return false

func destroy_no_effect():
	player.remove_special_proj()
	.destroy_no_effect()

func reflect(hitbox_owner):
	linear_vel.x *= -1
	sprite.scale.x *= -1

func kill(knockback):
	position = Vector2(position.x, position.y - size.y / 2)
	linear_vel = knockback
	can_self_act = false
	on_floor = false
	attacking = false
	dead = true
	player.special_control = false
	play_anim_this_frame("fall")
	play_audio(snd_hit)

func revive():
	can_self_act = true
	dead = false
	attacking = true
	play_anim_this_frame("special_revive")
	play_audio(snd_special_revive)

func attack():
	attacked = false
	attacking = true
	if check_player_input(global.INPUT_ACTION_DOWN):
		linear_vel.y = -attack_down_jump
		play_anim_this_frame("attack_down")
		play_audio(snd_attack_down)
	else:
		play_anim_this_frame("attack")
		play_audio(snd_attack)

func first_attack():
	attack()
	linear_vel.x = 250 * sprite.scale.x
	linear_vel.y = -150
	on_floor = false
	attacked = true
	first_attack = true
	play_anim_this_frame("special", 15)

func super():
	attacked = false
	attacking = true
	play_anim_this_frame("super")
	play_audio(snd_super)

func process_actual_move():
	var jumped = false
	if not attacking or move_while_attacking:
		if on_floor:
			can_dash = true
			if not dead or linear_vel.y == 0:
				linear_vel.x = 0
			if check_player_input(global.INPUT_ACTION_LEFT):
				linear_vel.x -= walk_speed
			if check_player_input(global.INPUT_ACTION_RIGHT):
				linear_vel.x += walk_speed
		if check_player_input(global.INPUT_ACTION_UP) and on_floor:
			linear_vel.x = 0
			last_input = global.INPUT_ACTION_UP
			last_input_frames = 0
			if check_player_input(global.INPUT_ACTION_LEFT):
				linear_vel.x -= air_speed
				last_input = global.INPUT_ACTION_UPLEFT
			if check_player_input(global.INPUT_ACTION_RIGHT):
				linear_vel.x += air_speed
				last_input = global.INPUT_ACTION_UPRIGHT
			linear_vel.y = -jump
			on_floor = false
			jumped = true
	
	if not attacking or move_while_attacking or dash_while_attacking:
		var previous_input = last_input
		var past_input_frames = last_input_frames
		if can_dash:
			alpha = 1
			if no_dash_frames > 0:
				no_dash_frames -= 1
		else:
			if dash_inv_frames > 0:
				dash_inv_frames -= 1
			else:
				alpha = 1
		if not jumped:
			if ((check_player_just_input(global.INPUT_ACTION_LEFT) and \
				(previous_input == global.INPUT_ACTION_LEFT or previous_input == global.INPUT_ACTION_UPLEFT) and \
				 past_input_frames <= 12 and (dtdash or cpu)) or \
				(check_player_input(global.INPUT_ACTION_LEFT) and check_player_input(global.INPUT_ACTION_DASH))) and \
				 can_dash and no_dash_frames <= 0:
				last_input = global.INPUT_ACTION_NONE
				linear_vel.x = -h_dash_speed
				linear_vel.y = -h_dash_jump
				if on_floor:
					dash_inv_frames = max_dash_inv_frames
				else:
					h_airdashing = true
					curr_dash_frames = 0
					dash_inv_frames = max_airdash_inv_frames
				no_dash_frames = max_no_dash_frames
				on_floor = false
				can_dash = false
				attacking = false
				alpha = dash_alpha
				create_dash_effect(Vector2.ZERO, -1, 0)
			if ((check_player_just_input(global.INPUT_ACTION_RIGHT) and \
				(previous_input == global.INPUT_ACTION_RIGHT or previous_input == global.INPUT_ACTION_UPRIGHT) and \
				 past_input_frames <= 12 and (dtdash or cpu)) or \
				(check_player_input(global.INPUT_ACTION_RIGHT) and check_player_input(global.INPUT_ACTION_DASH))) and \
				 can_dash and no_dash_frames <= 0:
				last_input = global.INPUT_ACTION_NONE
				linear_vel.x = h_dash_speed
				linear_vel.y = -h_dash_jump
				if on_floor:
					dash_inv_frames = max_dash_inv_frames
				else:
					h_airdashing = true
					curr_dash_frames = 0
					dash_inv_frames = max_airdash_inv_frames
				no_dash_frames = max_no_dash_frames
				on_floor = false
				can_dash = false
				attacking = false
				alpha = dash_alpha
				create_dash_effect(Vector2.ZERO, 1, 0)
			if not on_floor:
				if ((check_player_just_input(global.INPUT_ACTION_UP) and \
					(previous_input == global.INPUT_ACTION_UP or previous_input == global.INPUT_ACTION_UPLEFT or previous_input == global.INPUT_ACTION_UPRIGHT) and \
					 past_input_frames <= 12 and (dtdash or cpu)) or \
					(check_player_input(global.INPUT_ACTION_UP) and check_player_input(global.INPUT_ACTION_DASH))) and \
					 can_dash and no_dash_frames <= 0:
					last_input = global.INPUT_ACTION_NONE
					linear_vel.x = 0
					linear_vel.y = 0
					v_airdashing = true
					no_dash_frames = max_no_dash_frames
					dash_inv_frames = max_airdash_inv_frames
					curr_dash_frames = 0
					can_dash = false
					attacking = false
					alpha = dash_alpha
					create_dash_effect(Vector2(0, 24), 1, -90)
				if ((check_player_just_input(global.INPUT_ACTION_DOWN) and \
					 previous_input == global.INPUT_ACTION_DOWN and \
					 past_input_frames <= 12 and (dtdash or cpu)) or \
					(check_player_input(global.INPUT_ACTION_DOWN) and check_player_input(global.INPUT_ACTION_DASH))) and \
					 can_dash and no_dash_frames <= 0:
					last_input = global.INPUT_ACTION_NONE
					linear_vel.x = 0
					linear_vel.y = v_dash_speed
					v_airdashing = true
					no_dash_frames = max_no_dash_frames
					dash_inv_frames = max_airdash_inv_frames
					curr_dash_frames = 0
					can_dash = false
					attacking = false
					alpha = dash_alpha
					create_dash_effect(Vector2.ZERO, 1, 90)
		if h_airdashing or v_airdashing:
			if curr_dash_frames >= dash_frames:
				h_airdashing = false
				v_airdashing = false
			else:
				curr_dash_frames += 1
		set_modulate(Color(1, 1, 1, alpha))

	if not attacking or move_while_attacking:
		if on_floor:
			if dead and linear_vel.y > 0:
				if linear_vel.y >= 100:
					linear_vel.y *= -0.5
					on_floor = false
				else:
					linear_vel.y = 0
			else:
				linear_vel.y = 0
		elif not v_airdashing:
			if h_airdashing:
				linear_vel.y = 0
			else:
				linear_vel.y += gravity

func process_attack():
	invincible = anim_player.current_animation == "special" or anim_player.current_animation == "special_revive"
	hitbox.set_attacking(false)
	
	if attacking:
		if anim_player.current_animation == "attack" or anim_player.current_animation == "special":
			if sprite.frame >= 1 and sprite.frame <= 2:
				hitbox.set_attacking(true)
			if on_floor:
				linear_vel.x = 0
			else:
				linear_vel.y += gravity
			if attacked:
				if on_floor:
					attacking = false
			else:
				if sprite.frame >= 1:
					linear_vel.x = 250 * sprite.scale.x
					linear_vel.y = -150
					on_floor = false
					attacked = true
		elif anim_player.current_animation == "attack_down":
			if on_floor:
				linear_vel.x = 0
				if attacked and sprite.frame <= 5:
					anim_player.seek(291, true)
			else:
				linear_vel.y += gravity
			if not attacked and sprite.frame >= 3:
				var p = create_projectile(proj_attack_down, Vector2(0, 16))
				p.sprite.scale.x = sprite.scale.x
				attacked = true
		elif anim_player.current_animation == "special_revive":
			linear_vel.x = 0
			linear_vel.y = 0
		elif anim_player.current_animation == "super":
			if sprite.frame >= 3 and not attacked:
				var p = create_projectile(proj_super, Vector2(0, 24))
				attacked = true
				if not player.dead:
					player.attacking = true
					player.attacked = true
					player.refuse()
				destroy_no_effect()
			if on_floor:
				linear_vel.x = 0
			else:
				linear_vel.y += gravity

func process_anim():
	var new_anim = "idle"
	if win:
		new_anim = "win"
	elif dead:
		if on_floor:
			new_anim = "dead"
		else:
			new_anim = "fall"
	elif attacking:
		new_anim = anim_player.current_animation
	elif not on_floor:
		new_anim = "jump"
	elif linear_vel.x != 0:
		new_anim = "walk_forwards"
		if sign(sprite.scale.x) != sign(linear_vel.x):
			new_anim = "walk_backwards"
	if anim_player.current_animation != new_anim:
		play_anim_this_frame(new_anim)

func adjust_facing():
	if position.x < other_player.position.x:
		sprite.scale.x = 1
	elif position.x > other_player.position.x:
		sprite.scale.x = -1

func correct_player_collisions():
	correct_player_collisions_custom(other_player)
	if other_player.is_in_group(global.GROUP_CHAR_SLIME):
		var other_proj = other_player.get_proj()
		if other_proj != null:
			correct_player_collisions_custom(other_proj)
	other_player.correct_player_collisions_custom(self)

func correct_player_collisions_custom(custom_player):
	if (linear_vel.x >= 0 or position.x >= right_bound or custom_player.position.x >= right_bound) and \
	   position.x + size.x / 2 > custom_player.position.x - custom_player.size.x / 2 and \
	   position.x + size.x / 2 <= custom_player.position.x + custom_player.size.x / 2:
		if on_floor and custom_player.on_floor and linear_vel.x > 0 and custom_player.linear_vel.x == 0:
			custom_player.position.x += linear_vel.x / 200
		if (custom_player.on_floor and custom_player.position.x > left_bound and \
		   (linear_vel.x != 0 or (linear_vel.x == 0 and custom_player.linear_vel.x == 0) or custom_player.position.x >= right_bound)) or \
		   (not on_floor and linear_vel.x != 0):
			position.x = custom_player.position.x - custom_player.size.x / 2 - size.x / 2
	if (linear_vel.x <= 0 or position.x <= left_bound or custom_player.position.x <= left_bound) and \
	   position.x - size.x / 2 < custom_player.position.x + custom_player.size.x / 2 and \
	   position.x - size.x / 2 >= custom_player.position.x - custom_player.size.x / 2:
		if on_floor and custom_player.on_floor and linear_vel.x < 0 and custom_player.linear_vel.x == 0:
			custom_player.position.x += linear_vel.x / 200
		if (custom_player.on_floor and custom_player.position.x < right_bound and \
		   (linear_vel.x != 0 or (linear_vel.x == 0 and custom_player.linear_vel.x == 0) or custom_player.position.x <= left_bound)) or \
		   (not on_floor and linear_vel.x != 0):
			position.x = custom_player.position.x + custom_player.size.x / 2 + size.x / 2

func process_hitbox_char_collision(hitbox, call_other):
	if attacking and (anim_player.current_animation == "attack" or anim_player.current_animation == "special") and \
	   sprite.frame >= 1 and sprite.frame <= 2:
		.process_hitbox_char_collision(hitbox, call_other)

func process_hitbox_proj_collision(hitbox, call_other):
	pass

func preprocess_frame():
	last_input_frames += 1
	
	var last_anim = anim_player.current_animation
	anim_player.seek(anim_player.current_animation_position + 1, true)
	if anim_player.is_playing() and \
	   anim_player.current_animation_position >= anim_player.current_animation_length and \
	   anim_player.get_animation(anim_player.current_animation).loop:
		anim_player.seek(0, true)
	elif not anim_player.is_playing() or \
	  (anim_player.current_animation_position >= anim_player.current_animation_length and \
	  not anim_player.get_animation(anim_player.current_animation).loop):
		on_anim_finished(last_anim)
	
	if not attacking or move_while_attacking or dash_while_attacking:
		process_actual_move()
	
	if first_attack:
		first_attack = false
	else:
		on_floor = hitbox.get_global_rect().position.y + hitbox.rect_size.y >= global.floor_y
	process_attack()
	
	if linear_vel != Vector2.ZERO:
		var move = abs(linear_vel.x) / global.fps
		while move > 0:
			var move_amount = sign(linear_vel.x)
			if move < 1:
				move_amount = move * sign(linear_vel.x)
			move -= 1
			position.x += move_amount
		move = abs(linear_vel.y) / global.fps
		while move > 0:
			var move_amount = sign(linear_vel.y)
			if move < 1:
				move_amount = move * sign(linear_vel.y)
			move -= 1
			position.y += move_amount
	on_floor = hitbox.get_global_rect().position.y + hitbox.rect_size.y >= global.floor_y
	if on_floor:
		position.y = global.floor_y - hitbox.rect_size.y - hitbox.rect_position.y
	
	if position.x < left_bound:
		position = Vector2(left_bound, position.y)
	if position.x > right_bound:
		position = Vector2(right_bound, position.y)
	
	if (not attacking or move_while_attacking) and can_self_act:
		adjust_facing()
	
	if anim_player.current_animation == "dead":
		size = dead_size
	else:
		size = default_size
	if not attacking or move_while_attacking:
		if can_dash and other_player.can_dash and \
		   not ((position.x <= left_bound and sprite.scale.x > 0) or (position.x >= right_bound and sprite.scale.x < 0)) and \
		   position.y - size.y + 32 <= other_player.position.y + 32 and \
		   position.y + 32 >= other_player.position.y - other_player.size.y + 32:
			correct_player_collisions()
	
	effect_special.visible = special_control

# mimics process_frame() in character.gd
func process_move():
	process_collisions()
	
	process_anim()
	
	if invincible:
		sprite.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 0.5)
	else:
		sprite.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 0)

func play_audio(sfx):
	play_audio_custom(audio, sfx)

func play_audio_custom(player, sfx):
	player.volume_db = global.sfx_volume_db
	player.stream = sfx
	player.play(0)

func create_dash_effect(effect_pos, scale_x, rot_deg):
	var e = create_effect(effect_dash, effect_pos + Vector2(0, effect_y_offset))
	e.scale.x = scale_x
	e.rotation_degrees = rot_deg
	play_audio_custom(dash_player, snd_dash)
	return e

func refuse():
	create_projectile(proj_super, Vector2(0, 24))
	destroy_no_effect()

func on_anim_finished(anim_name):
	if attacking:
		attacking = false
		play_anim_this_frame("idle")
