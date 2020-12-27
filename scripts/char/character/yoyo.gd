extends Character

export var yoyo_pos = Vector2()

var curr_proj = null
var proj_move = 120
var holding = false
var hold_frames = -1
var max_hold_frames = 30
var hold_speed = 0
var min_hold_speed = 5
var max_hold_speed = 30
var hold_speed_factor = 2
var yoyo_return_dist = 8
var created_attack = true
var stun_vel = 180

onready var audio2 = get_node("AudioStreamPlayer2")

onready var proj_attack = preload("res://scenes/proj/yoyo/attack.tscn")
onready var proj_super = preload("res://scenes/proj/yoyo/super.tscn")
onready var effect_hit = preload("res://scenes/effect/yoyo/proj/attack_hit.tscn")

onready var sfx_attack = preload("res://audio/sfx/game/char/yoyo/attack.ogg")
onready var sfx_special = preload("res://audio/sfx/game/char/yoyo/special.ogg")
onready var sfx_special_boom = preload("res://audio/sfx/game/char/yoyo/special_boom.ogg")
onready var sfx_super = preload("res://audio/sfx/game/char/yoyo/super.ogg")
onready var sfx_hit = preload("res://audio/sfx/game/char/yoyo/hit.ogg")

func _ready():
	size = Vector2(12, 39)
	effect_y_offset = 8
	h_dash_speed = 135
	walk_speed = 70

func attack_condition():
	return curr_proj == null or holding

func special_condition():
	return curr_proj == null or (curr_proj != null and score > 0)

func super_condition():
	return curr_proj == null and score >= 2

func attack():
	attacked = false
	play_anim_this_frame("attack")
	if not holding:
		play_audio(sfx_attack)

func special():
	if curr_proj == null:
		if position.x >= left_bound and position.x <= right_bound and \
		   position.y >= up_bound and position.y <= down_bound:
			attacked = true
			var p = create_projectile(proj_attack, Vector2(0, 7))
			p.speed *= sprite.scale.x * 0.1
			created_attack = true
			curr_proj = p
			curr_proj.holding = true
			curr_proj.create_hold_effect()
			holding = true
			hold_speed = min_hold_speed
		attacking = false
	elif holding:
		.special()
		curr_proj.create_special()
		curr_proj = null
		holding = false
		linear_vel.x *= 0.25
		linear_vel.y = 0
		play_anim_this_frame("special")
		play_audio(sfx_special)
		play_audio_custom(audio2, sfx_special_boom)

func super():
	.super()
	attacked = false
	play_anim_this_frame("super")
	play_audio(sfx_super)
	create_super_flash(Vector2(10 * sprite.scale.x, 7))

func kill(knockback):
	.kill(knockback)
	play_audio(sfx_hit)
	holding = false
	hold_frames = -1
	if curr_proj != null:
		curr_proj.disable_collision()
		curr_proj.returning = true
		if created_attack:
			curr_proj.holding = false

func process_attack_anim():
	if anim_player.current_animation != "stun" and anim_player.current_animation != "super" and \
	   anim_player.current_animation != "special":
		if holding:
			return "attack_hold"
		else:
			return "attack"
	return .process_attack_anim()

func process_idle_anim():
	if holding or curr_proj != null:
		return "idle_hold"
	return .process_idle_anim()

func process_attack():
	invincible = anim_player.current_animation == "special"
	can_zero_special = attacking
	special_pos_relevant = curr_proj != null and not attacking
	
	if anim_player.current_animation != "special" and anim_player.current_animation != "super" and \
		check_player_just_input(global.INPUT_ACTION_SPECIAL) and curr_proj != null and not holding and curr_proj.can_hold() and \
		curr_proj.can_collide_with_char():
		curr_proj.holding = true
		curr_proj.create_hold_effect()
		holding = true
		attacking = false
		hold_speed = min_hold_speed
	if attacking:
		if anim_player.current_animation == "stun":
			if not anim_player.is_playing():
				attacking = false
			linear_vel.x *= 0.9
			if on_floor:
				linear_vel.y = 0
			else:
				linear_vel.y += gravity
		elif anim_player.current_animation == "special":
			if not anim_player.is_playing():
				attacking = false
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else:
				linear_vel.y = attack_gravity
		else:
			if not holding:
				if on_floor:
					linear_vel.x = 0
					linear_vel.y = 0
				else:
					linear_vel.y += gravity
			if not attacked:
				if not holding:
					if sprite.frame >= 1:
						attacked = true
						var p
						if anim_player.current_animation == "super":
							p = create_projectile(proj_super, position + yoyo_pos)
							p.speed *= sprite.scale.x
							p.set_init_vel()
							created_attack = false
						else:
							p = create_projectile(proj_attack, Vector2(0, 7))
							p.speed *= sprite.scale.x
							created_attack = true
						curr_proj = p
						hold_frames = 0
				else:
					attacked = true
					on_floor = false
			elif attacked and curr_proj != null:
				curr_proj.add_move = Vector2(0, 0)
				if check_player_input(global.INPUT_ACTION_LEFT):
					curr_proj.add_move.x -= proj_move
				if check_player_input(global.INPUT_ACTION_RIGHT):
					curr_proj.add_move.x += proj_move
				if check_player_input(global.INPUT_ACTION_UP):
					curr_proj.add_move.y -= proj_move
				if check_player_input(global.INPUT_ACTION_DOWN):
					curr_proj.add_move.y += proj_move
				curr_proj.add_move = curr_proj.add_move.clamped(proj_move)
				if created_attack:
					if hold_frames >= 0 and not holding:
						if not check_player_input(global.INPUT_ACTION_ATTACK):
							hold_frames = -1
						else:
							hold_frames += 1
					elif holding:
						hold_speed *= hold_speed_factor
						if hold_speed > max_hold_speed:
							hold_speed = max_hold_speed
						linear_vel += (curr_proj.position - position).normalized() * hold_speed
						if position.distance_to(curr_proj.position) <= yoyo_return_dist * 2:
							holding = false
							attacking = false
							curr_proj.destroy_no_effect()
							curr_proj = null
						elif check_player_just_input(global.INPUT_ACTION_ATTACK):
							holding = false
							hold_frames = -1
							curr_proj.holding = false
							curr_proj.returning = true
							play_anim_this_frame("attack", 33)
				else:
					if curr_proj != null and (anim_player.current_animation_position >= 156 or not can_act):
						curr_proj.returning = true

func stun():
	if attacking and anim_player.current_animation != "stun" and anim_player.current_animation != "attack_hold":
		linear_vel.x = stun_vel * -sprite.scale.x
		play_anim_this_frame("stun")
		audio.stop()
		play_audio_custom(audio2, sfx_parry)
		return true
	return false

func stop_attacking():
	if anim_player.current_animation != "stun":
		attacking = false

func get_yoyo_pos():
	return position + Vector2(yoyo_pos.x * sprite.scale.x, yoyo_pos.y)

func get_special_position():
	if curr_proj != null:
		return get_yoyo_pos()
	else:
		return position

func reset_pos(new_pos):
	.reset_pos(new_pos)
	curr_proj = null
	holding = false
	created_attack = true
