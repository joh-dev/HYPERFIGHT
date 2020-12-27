class_name Projectile
extends Node2D

var player
var player_num = 1
var palette_player_num = -1
var left_bound = -250
var right_bound = 250
var top_bound = -250
var bottom_bound = 250
var curr_frame_delay = 0
var effect_hit_timer = 0
var max_effect_hit_timer = 6
var default_shadow_x_offset = 0
var default_shadow_size = 1
var linear_vel = Vector2()
var knockback = Vector2()
var effect_hit = null
var first_frame_played = false
var changed_players = false
var can_parry = true
var can_reflect = true
var destroy_on_char_hit = true
var force_destroy_on_char_other_hit = false
var destroy_on_char_parry = true
var destroy_on_proj_hit = true
var destroy_on_superproj_hit = true
var rotate_effect = true
var effect_on_player = false
var effect_on_proj = false
var knockback_depend_on_player_pos = false
var knockback_flip_with_scale = true
var destroy_out_of_bounds = true
var keep_in_bounds = false
var collide_with_proj = true
var collide_with_char = true
var sucked = false
var can_suck = true
var anim_disabled = false
var proj_shadow = null
var effect_offset = Vector2()
var collided_nodes = []

onready var game = get_parent().get_parent()
onready var sprite = get_node("Sprite")
onready var anim_player = get_node("AnimationPlayer")
onready var hitbox = get_node("hitbox")

onready var shadow = preload("res://scenes/effect/shadow.tscn")
onready var afterimage = preload("res://scenes/effect/afterimage.tscn")

func _ready():
	add_to_group(global.GROUP_PROJECTILE)
	hitbox.add_to_group(global.GROUP_HITBOX)
	hitbox.set_attacking(true)
	anim_player.playback_speed = 0
	create_shadow(default_shadow_x_offset, default_shadow_size)
	set_palette()

func _enter_tree():
	if shadow != null:
		create_shadow(default_shadow_x_offset, default_shadow_size)

func _exit_tree():
	if proj_shadow != null:
		proj_shadow.call_deferred("free")
		proj_shadow = null

func destroy():
	create_effect_hit()
	destroy_no_effect()

func destroy_no_effect():
	call_deferred("free")
	if hitbox.is_in_group(global.GROUP_HITBOX):
		hitbox.remove_from_group(global.GROUP_HITBOX)

func change_players(new_player):
	player_num = new_player.player_num
	set_player(new_player)
	changed_players = true

func reflect(hitbox_owner):
	sprite.scale.x *= -1
	change_players(hitbox_owner)

func flip():
	sprite.scale.x *= -1

func suck():
	if can_suck and not sucked:
		sucked = true
		anim_disabled = true
		return true
	elif not sucked:
		suck_action()
	return false

func suck_action():
	pass

func unsuck():
	sucked = false
	anim_disabled = false

func can_collide_with_proj():
	return collide_with_proj

func can_collide_with_char():
	return collide_with_char

func can_destroy_on_char_hit():
	return destroy_on_char_hit

func can_destroy_on_proj_hit():
	return destroy_on_proj_hit

func process_move():
	move_and_collide(linear_vel)

func move_and_collide(linear_vel):
	if linear_vel == Vector2.ZERO:
		process_collisions()
		return
	var move = abs(linear_vel.x) / global.fps
	while move > 0:
		var move_amount = sign(linear_vel.x)
		if move < 1:
			move_amount = move * sign(linear_vel.x)
		move -= 1
		position.x += move_amount
		if process_collisions():
			position.x -= move_amount
			break
	move = abs(linear_vel.y) / global.fps
	while move > 0:
		var move_amount = sign(linear_vel.y)
		if move < 1:
			move_amount = move * sign(linear_vel.y)
		move -= 1
		position.y += move_amount
		if process_collisions():
			position.y -= move_amount
			break

func process_collisions():
	var hitboxes = get_tree().get_nodes_in_group(global.GROUP_HITBOX)
	for other_hitbox in hitboxes:
		if hitbox != other_hitbox and hitbox.intersects(other_hitbox):
			process_hitbox_collision(other_hitbox, true)

func process_hitbox_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group(global.GROUP_CHARACTER) and collide_with_char:
		process_hitbox_char_collision(hitbox, call_other)
	elif hitbox_owner.is_in_group(global.GROUP_PROJECTILE) and not hitbox_owner.is_in_group(global.GROUP_CHARACTER) and \
		 player_num != hitbox_owner.player_num and collide_with_proj and hitbox_owner.can_collide_with_proj():
		process_hitbox_proj_collision(hitbox, call_other)

func process_hitbox_char_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	var owner_can_kill = hitbox_owner.can_kill(player_num)
	var owner_can_parry = hitbox_owner.can_parry(player_num)
	if hitbox_owner.can_destroy_other(player_num) and \
	  (destroy_on_char_hit or force_destroy_on_char_other_hit) and \
	   not is_in_group(global.GROUP_SUPERPROJ):
		destroy()
	elif (owner_can_parry and not can_parry) or \
		(owner_can_parry and not can_reflect and hitbox_owner.is_in_group(global.GROUP_CAN_REFLECT)) or \
		owner_can_kill:
		if not hitbox_owner.is_in_group(global.GROUP_PROJECTILE):
			player.stop_act()
			if is_in_group(global.GROUP_SUPERPROJ):
				game.win(player_num)
			else:
				game.inc_score(player_num)
		var knockback_x = knockback.x
		if knockback_flip_with_scale:
			knockback_x *= sprite.scale.x
		if knockback_depend_on_player_pos:
			knockback_x = knockback.x * sign(hitbox_owner.position.x - position.x)
		hitbox_owner.kill(Vector2(knockback_x, knockback.y))
		if effect_on_player:
			create_effect_hit_at(hitbox_owner.position)
		else:
			create_effect_hit()
		if destroy_on_char_hit or (hitbox_owner.is_in_group(global.GROUP_PROJECTILE) and destroy_on_proj_hit):
			destroy()
	elif owner_can_parry:
		if effect_on_player:
			create_effect_hit_at(hitbox_owner.position)
		else:
			create_effect_hit()
		if hitbox_owner.is_in_group(global.GROUP_CAN_REFLECT):
			reflect(hitbox_owner)
		elif destroy_on_char_parry:
			destroy_no_effect()
		parry_effect()

func process_hitbox_proj_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if call_other:
		hitbox_owner.process_hitbox_collision(self.hitbox, false)
	if not collided_nodes.has(hitbox_owner.get_instance_id()):
		if effect_on_proj:
			create_effect_hit_at(hitbox_owner.position)
		else:
			create_effect_hit()
		if destroy_on_proj_hit or (destroy_on_superproj_hit and hitbox_owner.is_in_group(global.GROUP_SUPERPROJ)):
			destroy()
		collided_nodes.append(hitbox_owner.get_instance_id())

func parry_effect():
	pass

func process(curr_frame, frame_delay):
	if not is_inside_tree():
		return
	
	if curr_frame_delay <= 0:
		if not anim_disabled and anim_player.is_playing():
			if first_frame_played:
				hitbox.set_monitoring(false)
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
			else:
				first_frame_played = true
		
		process_move()
		
		collided_nodes.clear()
		if destroy_out_of_bounds:
			if position.x < left_bound:
				destroy_no_effect()
			if position.x > right_bound:
				destroy_no_effect()
			if position.y < top_bound:
				destroy_no_effect()
			if position.y > bottom_bound:
				destroy_no_effect()
		if keep_in_bounds:
			if position.x < left_bound:
				position = Vector2(left_bound, position.y)
			if position.x > right_bound:
				position = Vector2(right_bound, position.y)
		
		if effect_hit_timer > 0:
			effect_hit_timer -= 1
		
		curr_frame_delay = frame_delay
	else:
		curr_frame_delay -= 1

func play_anim_this_frame(anim, frame = 0, custom_anim_player = null):
	hitbox.set_monitoring(false)
	if custom_anim_player == null:
		custom_anim_player = anim_player
	custom_anim_player.play(anim)
	custom_anim_player.seek(frame, true)

func create_shadow(x_offset, shadow_size):
	if proj_shadow != null:
		proj_shadow.call_deferred("free")
	proj_shadow = shadow.instance()
	proj_shadow.init(self, x_offset, shadow_size)
	game.add_object(proj_shadow)
	default_shadow_x_offset = x_offset
	default_shadow_size = shadow_size

func create_projectile(proj, proj_pos = Vector2.ZERO):
	if proj == null:
		return null
	var p = proj.instance()
	p.position = position + proj_pos
	p.set_player(player)
	p.set_palette_player_num(palette_player_num)
	get_parent().add_child(p)
	return p

func create_effect(effect, effect_pos = Vector2.ZERO):
	if effect == null:
		return null
	var e = effect.instance()
	e.position = position + effect_pos
	get_parent().add_child(e)
	e.set_palette(palette_player_num)
	return e

func create_effect_at(effect, effect_pos):
	var e = create_effect(effect, effect_pos)
	if e != null:
		e.position -= position
	return e

func create_effect_hit(effect_pos = Vector2(effect_offset.x * sprite.scale.x, effect_offset.y)):
	if effect_hit != null and effect_hit_timer <= 0:
		var e = create_effect(effect_hit, effect_pos)
		if rotate_effect:
			e.rotation = rotation
		effect_hit_timer = max_effect_hit_timer
		return e
	return null

func create_effect_hit_at(effect_pos):
	var e = create_effect_hit(effect_pos)
	if e != null:
		e.position -= position
	return e

func create_afterimage(alpha = 0.5):
	var a = afterimage.instance()
	a.position = position
	a.texture = sprite.texture
	a.hframes = sprite.hframes
	a.frame = sprite.frame
	a.scale = sprite.scale
	a.alpha = alpha
	get_parent().add_child(a)
	a.set_palette(palette_player_num)
	return a

func set_player(player):
	self.player = player
	player_num = player.player_num

func set_palette_player_num(palette_player_num):
	self.palette_player_num = palette_player_num

func set_palette():
	if palette_player_num <= 0:
		palette_player_num = player_num
	set_palette_sprite(sprite)

func set_palette_sprite(palette_sprite):
	global.set_material_palette(palette_sprite.material, player_num)

func on_anim_finished(last_anim):
	pass
