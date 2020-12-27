extends Character

var attack_down_jump = 350
var attack_down_gravity = 16
var extra_dash = true

onready var audio2 = get_node("AudioStreamPlayer2")
onready var hitbox_attack_down = get_node("hitbox_attack_down")

onready var proj_attack = preload("res://scenes/proj/darkgoto/attack.tscn")
onready var proj_super = preload("res://scenes/proj/darkgoto/super.tscn")
onready var effect_hit = preload("res://scenes/effect/darkgoto/attack_hit.tscn")
onready var effect_attack = preload("res://scenes/effect/darkgoto/char/attack.tscn")
onready var effect_super = preload("res://scenes/effect/darkgoto/char/super.tscn")

onready var sfx_attack = preload("res://audio/sfx/game/char/darkgoto/attack.ogg")
onready var sfx_attack_down = preload("res://audio/sfx/game/char/darkgoto/attack_down.ogg")
onready var sfx_special = preload("res://audio/sfx/game/char/darkgoto/special.ogg")
onready var sfx_special_reflect = preload("res://audio/sfx/game/char/darkgoto/special_reflect.ogg")
onready var sfx_super = preload("res://audio/sfx/game/char/darkgoto/super.ogg")
onready var sfx_hit = preload("res://audio/sfx/game/char/darkgoto/hit.ogg")

onready var sfx_attack_old = preload("res://audio/sfx/game/char/darkgoto/old/attack.ogg")
onready var sfx_attack_down_old = preload("res://audio/sfx/game/char/darkgoto/old/attack_down.ogg")
onready var sfx_super_old = preload("res://audio/sfx/game/char/darkgoto/old/super.ogg")
onready var sfx_hit_old = preload("res://audio/sfx/game/char/darkgoto/old/hit.ogg")

func _ready():
	add_to_group(global.GROUP_CAN_REFLECT)
	shadow_offset = 1
	if global.mode == global.MODE.arcade and global.arcade_stage == global.max_arcade_stage and player_num == 2:
		walk_speed = 90
		air_speed = 160
	else:
		walk_speed = 70
		air_speed = 100
	jump = 350
	gravity = 16
	special_move = 120
	h_dash_speed = 150

func attack():
	attacked = false
	if check_player_input(global.INPUT_ACTION_DOWN):
		linear_vel.x = special_move * sprite.scale.x
		linear_vel.y = 0
		play_anim_this_frame("attack_down")
		if is_april_fools:
			play_audio(sfx_attack_down_old)
		else:
			play_audio(sfx_attack_down)
	else:
		linear_vel.x *= 0.25
		linear_vel.y = 0
		if on_floor:
			play_anim_this_frame("attack_upwards")
		else:
			play_anim_this_frame("attack_downwards")
		if is_april_fools:
			play_audio(sfx_attack_old)
		else:
			play_audio(sfx_attack)
	sprite.frame = 0

func special():
	.special()
	if on_floor:
		linear_vel.x = 0
		linear_vel.y = 0
	else:
		linear_vel.x *= 0.25
		linear_vel.y *= 0.25
	play_anim_this_frame("special")
	play_audio(sfx_special)

func super():
	.super()
	attacked = false
	linear_vel.x *= 0.25
	linear_vel.y = 0
	if on_floor:
		play_anim_this_frame("super_upwards")
	else:
		play_anim_this_frame("super_downwards")
	if is_april_fools:
		play_audio(sfx_super_old)
	else:
		play_audio(sfx_super)
	create_super_flash(Vector2(-10 * sprite.scale.x, 0))
	
func kill(knockback):
	.kill(knockback)
	if is_april_fools:
		play_audio(sfx_hit_old)
	else:
		play_audio(sfx_hit)

func process_attack():
	parrying = (anim_player.current_animation == "special")
	invincible = (anim_player.current_animation == "special_reflect")
	
	if on_floor:
		extra_dash = true
	else:
		if not can_dash and not is_dashing() and extra_dash:
			can_dash = true
			extra_dash = false
	
	if attacking:
		if anim_player.current_animation == "special" or anim_player.current_animation == "special_reflect":
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else:
				linear_vel.y += attack_gravity
		else:
			if anim_player.current_animation == "attack_down":
				if not attacked:
					if sprite.frame >= 1:
						linear_vel.y = -attack_down_jump
						on_floor = false
						attacked = true
					else:
						linear_vel.y = 0
				else:
					if on_floor:
						linear_vel.x = 0
						linear_vel.y = 0
						if anim_player.current_animation_position < 296:
							anim_player.seek(296, true)
					else:
						linear_vel.y += attack_down_gravity
				
				process_own_hitbox(hitbox_attack_down, Vector2(80 * sprite.scale.x, -350), effect_hit)
			else:
				if on_floor:
					linear_vel.x = 0
					linear_vel.y = 0
				else:
					linear_vel.y = attack_gravity
				if not attacked and sprite.frame >= 1:
					var p
					var e
					var up = anim_player.current_animation == "attack_upwards" or anim_player.current_animation == "super_upwards"
					var y_offset = 10
					if anim_player.current_animation == "super_upwards" or anim_player.current_animation == "super_downwards":
						p = proj_super
						e = effect_super
					else:
						p = proj_attack
						e = effect_attack
					if up:
						y_offset = -y_offset
					
					p = create_projectile(p, Vector2(16 * sprite.scale.x, y_offset))
					p.set_up(sprite.scale.x, up)
					
					e = create_effect(e, Vector2(18 * sprite.scale.x, y_offset))
					e.scale.x = sprite.scale.x
					e.rotation = p.sprite.rotation
					
					attacked = true

func process_anim():
	dash_while_attacking = false
	.process_anim()

func process_attack_anim():
	if (anim_player.current_animation == "super_upwards" or anim_player.current_animation == "super_downwards") and \
	   sprite.frame >= 1:
		dash_while_attacking = true
	return .process_attack_anim()

func parry(parry_effect_pos = Vector2()):
	.parry(Vector2(20 * sprite.scale.x, 0))
	parrying = false
	invincible = true
	play_anim_this_frame("special_reflect")
	play_audio_custom(audio2, sfx_parry)
	if is_april_fools:
		play_audio(sfx_attack_down_old)
	else:
		play_audio(sfx_special_reflect)

func can_kill(other_num):
	return .can_kill(other_num) and anim_player.current_animation != "special"
