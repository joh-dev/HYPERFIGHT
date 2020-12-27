extends Character

var attack_down_move = 100
var attack_down_jump = 250
var attack_down_gravity = 28

var curr_proj = null
var special_control = false
var can_double_jump = true

onready var audio2 = get_node("AudioStreamPlayer2")
onready var hitbox_attack = get_node("hitbox_attack")
onready var hitbox_attack_down = get_node("hitbox_attack_down")
onready var effect_special = get_node("effect_special")

onready var proj_special = preload("res://scenes/proj/slime/special.tscn")
onready var proj_super = preload("res://scenes/proj/slime/super.tscn")
onready var proj_pink_super = preload("res://scenes/proj/slime/pink/super.tscn")
onready var effect_hit = preload("res://scenes/effect/slime/char/attack_hit.tscn")
onready var effect_pink_hit = preload("res://scenes/effect/slime/pink/char/attack_hit.tscn")

onready var sfx_attack = preload("res://audio/sfx/game/char/slime/pink/attack.ogg")
onready var sfx_blue_attack = preload("res://audio/sfx/game/char/slime/blue/attack.ogg")
onready var sfx_attack_down = preload("res://audio/sfx/game/char/slime/pink/attack_down.ogg")
onready var sfx_blue_attack_down = preload("res://audio/sfx/game/char/slime/blue/attack_down_fused.ogg")
onready var sfx_special = preload("res://audio/sfx/game/char/slime/pink/special.ogg")
onready var sfx_special_revive = preload("res://audio/sfx/game/char/slime/pink/special_revive.ogg")
onready var sfx_super = preload("res://audio/sfx/game/char/slime/pink/super.ogg")
onready var sfx_blue_super = preload("res://audio/sfx/game/char/slime/blue/super.ogg")
onready var sfx_hit = preload("res://audio/sfx/game/char/slime/pink/hit.ogg")
onready var sfx_blue_hit = preload("res://audio/sfx/game/char/slime/blue/hit.ogg")

func _ready():
	add_to_group(global.GROUP_CHAR_SLIME)
	size = Vector2(12, 22)
	walk_speed = 90
	jump = 375
	h_dash_speed = 190
	effect_y_offset = 20
	attack_while_attacking = true
	attack_while_ready = true
	attack_while_dashing = true

func add_attack_buffer_inputs():
	add_buffer_input_action(global.INPUT_ACTION_ATTACK, true)
	if curr_proj == null or not curr_proj.can_act():
		add_buffer_input_action(global.INPUT_ACTION_SPECIAL, true)
	add_buffer_input_action(global.INPUT_ACTION_SUPER, true)

func input_condition(input):
	return (.input_condition(input) and (not special_control or input == global.INPUT_ACTION_ATTACK or input == global.INPUT_ACTION_SPECIAL or input == global.INPUT_ACTION_SUPER)) or \
		   (curr_frame_delay <= 0 and input == global.INPUT_ACTION_SPECIAL)

func attack_condition():
	return can_attack and \
		   ((special_control and curr_proj != null and curr_proj.can_attack()) or \
		   (not special_control and not attacking and not is_dashing()))

func special_condition():
	set_attacking_on_special = (curr_proj == null or not curr_proj.can_act())
	return (curr_proj != null and curr_proj.can_act()) or (not attacking and can_attack and not is_dashing() and score > 0)

func super_condition():
	return attack_condition() and .super_condition()

func attack():
	if curr_proj == null or not special_control:
		attacked = false
		if check_player_input(global.INPUT_ACTION_DOWN):
			linear_vel.y = -attack_down_jump
			on_floor = false
			play_anim_this_frame("attack_down")
			play_audio(sfx_attack_down)
			if curr_proj == null:
				play_audio_custom(audio2, sfx_blue_attack_down)
		else:
			play_anim_this_frame("attack")
			play_audio(sfx_attack)
			if curr_proj == null:
				play_audio_custom(audio2, sfx_blue_attack)
	else:
		curr_proj.attack()

func special():
	if curr_proj == null:
		.special()
		attacked = false
		special_control = true
		play_anim_this_frame("special")
		play_audio(sfx_special)
	elif not curr_proj.can_act():
		.special()
		curr_proj.revive()
		play_anim_this_frame("special_revive")
		play_audio(sfx_special_revive)
	else:
		special_control = !special_control

func super():
	.super()
	if curr_proj == null or not special_control:
		attacked = false
		play_anim_this_frame("super")
		play_audio(sfx_super)
		if curr_proj == null:
			play_audio_custom(audio2, sfx_blue_super)
		create_super_flash(Vector2(0, 24))
	else:
		curr_proj.super()
		create_super_flash(Vector2(curr_proj.position.x, curr_proj.position.y + 24) - position)

func kill(knockback):
	.kill(knockback)
	play_audio(sfx_hit)
	if curr_proj == null:
		play_audio_custom(audio2, sfx_blue_hit)

func preprocess_frame():
	.preprocess_frame()
	
	if curr_proj == null:
		effect_special.visible = false
	else:
		curr_proj.copy_player_inputs(self)
		curr_proj.preprocess_frame()
		effect_special.visible = !special_control

func process_attack():
	invincible = anim_player.current_animation == "special" or anim_player.current_animation == "special_revive"
	set_attacking_on_attack = curr_proj == null or not special_control
	set_attacking_on_super = curr_proj == null or not special_control
	adjust_facing_on_special = curr_proj == null
	
	if attacking:
		if anim_player.current_animation == "attack_down" or anim_player.current_animation == "pink_attack_down":
			if on_floor:
				if not attacked:
					attacked = true
				elif sprite.frame <= 5:
					linear_vel.x = 0
					anim_player.seek(291, true)
			else:
				linear_vel.y += attack_down_gravity
			
			var e = effect_pink_hit
			if curr_proj == null:
				e = effect_hit
			process_own_hitbox(hitbox_attack_down, Vector2(75 * sprite.scale.x, -325), e)
		elif anim_player.current_animation == "attack" or anim_player.current_animation == "pink_attack" or \
		   anim_player.current_animation == "special":
			if on_floor:
				linear_vel.x = 0
			else:
				linear_vel.y += gravity
			if attacked:
				if on_floor:
					attacking = false
			elif sprite.frame >= 1:
				if anim_player.current_animation == "special":
					var p = create_projectile(proj_special)
					curr_proj = p
					curr_proj.sprite.scale.x = sprite.scale.x
					curr_proj.copy_player_vars(self)
					curr_proj.first_attack()
					sprite.scale.x *= -1
				linear_vel.x = 250 * sprite.scale.x
				linear_vel.y = -150
				on_floor = false
				attacked = true
			
			var e = effect_pink_hit
			if curr_proj == null:
				e = effect_hit
			process_own_hitbox(hitbox_attack, Vector2(50 * sprite.scale.x, -250), e, Vector2(16 * sprite.scale.x, 20))
		elif anim_player.current_animation == "special_revive":
			linear_vel.x = 0
			linear_vel.y = 0
		elif anim_player.current_animation == "super" or anim_player.current_animation == "pink_super" or \
			 anim_player.current_animation == "refuse":
			if sprite.frame >= 3 and not attacked:
				var p
				if anim_player.current_animation == "pink_super":
					p = proj_pink_super
				else:
					p = proj_super
				p = create_projectile(p, Vector2(0, 24))
				attacked = true
				if anim_player.current_animation == "pink_super":
					position = curr_proj.position
					adjust_facing()
					curr_proj.refuse()
					play_anim_this_frame("refuse")
			if on_floor:
				linear_vel.x = 0
			else:
				linear_vel.y += gravity

func postprocess_anim(new_anim):
	if curr_proj != null and new_anim != "special" and new_anim != "special_revive":
		return "pink_" + new_anim
	return .postprocess_anim(new_anim)

func process_attack_anim():
	if anim_player.current_animation == "super" or anim_player.current_animation == "pink_super":
		return "super"
	elif anim_player.current_animation == "attack_down" or anim_player.current_animation == "pink_attack_down":
		return "attack_down"
	elif anim_player.current_animation == "attack" or anim_player.current_animation == "pink_attack":
		return "attack"
	else:
		return anim_player.current_animation

func remove_special_proj():
	curr_proj = null
	special_control = false

func refuse():
	create_projectile(proj_pink_super, Vector2(0, 24))
	play_anim_this_frame("refuse")

func get_proj():
	return curr_proj
