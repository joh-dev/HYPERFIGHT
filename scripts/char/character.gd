class_name Character
extends Node2D

class OnlineInput:
	var map = { \
	  global.INPUT_ACTION_LEFT: false, \
	  global.INPUT_ACTION_RIGHT: false, \
	  global.INPUT_ACTION_UP: false, \
	  global.INPUT_ACTION_DOWN: false, \
	  global.INPUT_ACTION_ATTACK: false, \
	  global.INPUT_ACTION_SPECIAL: false, \
	  global.INPUT_ACTION_SUPER: false, \
	  global.INPUT_ACTION_DASH: false }
	var frame = 0
	var input_delay = 0
	var read = false

class CpuAction:
	var action = ""
	var time = 0
	
	func _init(a, t):
		action = a
		time = t

var frame_inputs = []
var buffer_inputs = []
var online_inputs = []
var input_map = { \
  global.INPUT_ACTION_LEFT: false, \
  global.INPUT_ACTION_RIGHT: false, \
  global.INPUT_ACTION_UP: false, \
  global.INPUT_ACTION_DOWN: false, \
  global.INPUT_ACTION_ATTACK: false, \
  global.INPUT_ACTION_SPECIAL: false, \
  global.INPUT_ACTION_SUPER: false, \
  global.INPUT_ACTION_DASH: false }
var online_input_map = { \
  global.INPUT_ACTION_LEFT: false, \
  global.INPUT_ACTION_RIGHT: false, \
  global.INPUT_ACTION_UP: false, \
  global.INPUT_ACTION_DOWN: false, \
  global.INPUT_ACTION_ATTACK: false, \
  global.INPUT_ACTION_SPECIAL: false, \
  global.INPUT_ACTION_SUPER: false, \
  global.INPUT_ACTION_DASH: false }

var player_num = 1
var cpu = false
var size = Vector2(12, 46)
var online_control = false
var dtdash = true
var assuper = true
var init_xoffset = 70
var init_yoffset = global.floor_y - 32
var score = 0
var score_balls
var cpu_mode = "idle"
var cpu_type = global.CPU_TYPE.normal
var cpu_timer = 0
var cpu_acted = false
var orig_pos = Vector2()
var linear_vel = Vector2()
var kill_knockback = Vector2()
var shadow_offset = 0
var walk_speed = 65
var air_speed = 90
var h_dash_speed = 125
var v_dash_speed = 300
var jump = 350
var h_dash_jump = 150
var gravity = 18
var attack_gravity = 10
var special_move = 70
var special_jump = 150
var left_bound = -125
var right_bound = 125
var up_bound = -75
var down_bound = 75
var other_player
var last_input = global.INPUT_ACTION_NONE
var last_input_frames = 0
var max_input_buffer = 15
var disable_buffer = false
var hold_buffer = false
var on_floor = false
var attacking = false
var attacked = false
var can_dash = true
var can_inv_dash = true
var can_attack = true
var dead = false
var killed = false
var can_act = true
var win = false
var move_while_attacking = false
var dash_while_attacking = false
var attack_while_attacking = false
var attack_while_ready = false
var attack_while_dashing = false
var set_attacking_on_attack = true
var set_attacking_on_special = true
var set_attacking_on_super = true
var adjust_facing_on_attack = true
var adjust_facing_on_special = true
var adjust_facing_on_super = true
var h_airdashing = false
var v_airdashing = false
var alpha = 1
var dash_alpha = 0.5
var curr_frame = 0
var no_act_frames = 0
var prev_frame_delay = 0
var curr_frame_delay = 0
var ignore_frame_delay = false
var send_delay = 0
var online_active = false
var dash_frames = 10
var curr_dash_frames = 0
var no_dash_frames = 0
var max_no_dash_frames = 10
var dash_inv_frames = 0
var max_dash_inv_frames = 30
var max_airdash_inv_frames = 10
var effect_y_offset = 0
var inv_white_amount = 0.5
var parry_blue_amount = 0.4
var invincible = false
var parrying = false
var can_zero_special = false
var special_pos_relevant = true
var own_collisions = []
var own_hitboxes = []
var own_hitboxes_perm = []
var is_christmas = false
var is_april_fools = false
var own_shadow = null

onready var game = get_parent().get_parent()
onready var sprite = get_node("Sprite")
onready var hurtbox = get_node("hurtbox")
onready var anim_player = get_node("AnimationPlayer")
onready var audio = get_node("AudioStreamPlayer")
onready var dash_player = get_node("dash_player")

onready var effect_dash = preload("res://scenes/effect/dash.tscn")
onready var effect_super_flash = preload("res://scenes/effect/super.tscn")
onready var effect_parry_flash = preload("res://scenes/effect/parry.tscn")
onready var afterimage = preload("res://scenes/effect/afterimage.tscn")
onready var shadow = preload("res://scenes/effect/shadow.tscn")

onready var sfx_dash = preload("res://audio/sfx/game/char/dash.ogg")
onready var sfx_parry = preload("res://audio/sfx/game/char/parry.ogg")

func _ready():
	add_to_group(global.GROUP_CHARACTER)
	hurtbox.add_to_group(global.GROUP_HITBOX)
	hurtbox.set_monitoring(true)
	anim_player.playback_speed = 0
	play_anim_this_frame("idle")
	
	own_shadow = shadow.instance()
	own_shadow.init(self, shadow_offset, 0)
	get_parent().add_child(own_shadow)

func init(player_num, other_player):
	self.player_num = player_num
	self.other_player = other_player
	if player_num == 1:
		position = Vector2(-init_xoffset, init_yoffset)
		cpu = global.player1_cpu
		dtdash = global.player1_dtdash
		assuper = global.player1_assuper
		score_balls = get_node("../../GUILayer/label_player1/score_balls")
	else:
		position = Vector2(init_xoffset, init_yoffset)
		cpu = global.player2_cpu
		dtdash = global.player2_dtdash
		assuper = global.player2_assuper
		score_balls = get_node("../../GUILayer/label_player2/score_balls")
		sprite.scale.x = -1
	orig_pos = position
	set_palette()
	check_events()
	reset()

func check_events():
	is_christmas = global.is_christmas(player_num)
	is_april_fools = global.is_april_fools()

func add_buffer_inputs():
	add_buffer_input_action(global.INPUT_ACTION_LEFT, hold_buffer)
	add_buffer_input_action(global.INPUT_ACTION_RIGHT, hold_buffer)
	add_buffer_input_action(global.INPUT_ACTION_UP, hold_buffer)
	add_buffer_input_action(global.INPUT_ACTION_DOWN, hold_buffer)
	add_buffer_input_action(global.INPUT_ACTION_ATTACK, hold_buffer)
	add_buffer_input_action(global.INPUT_ACTION_SPECIAL, hold_buffer)
	add_buffer_input_action(global.INPUT_ACTION_SUPER, hold_buffer)
	add_buffer_input_action(global.INPUT_ACTION_DASH, hold_buffer)

func add_attack_buffer_inputs():
	add_buffer_input_action(global.INPUT_ACTION_ATTACK, true)
	add_buffer_input_action(global.INPUT_ACTION_SPECIAL, true)
	add_buffer_input_action(global.INPUT_ACTION_SUPER, true)

func add_buffer_input_action(input, hold):
	if ((input_map[input] and hold) or frame_inputs.has(input)) and not buffer_inputs.has(input):
		buffer_inputs.append(input)

func add_online_input(input_player_num, copy_map, copy_frame, copy_delay, send_packet):
	if player_num == input_player_num:
		var oinput = OnlineInput.new()
		oinput.map = copy_map.duplicate()
		oinput.frame = copy_frame
		oinput.input_delay = copy_delay
		online_inputs.append(oinput)
		if global.save_inputs:
			if player_num == 1:
				global.save_player1_input(copy_frame + copy_delay, copy_map)
			else:
				global.save_player2_input(copy_frame + copy_delay, copy_map)
	if not online_control:
		if global.lobby_state == global.LOBBY_STATE.spectate:
			if player_num == input_player_num:
				if player_num == 1:
					game.player1_frame = copy_frame + copy_delay
				else:
					game.player2_frame = copy_frame + copy_delay
		else:
			game.last_other_frame = copy_frame
			game.last_other_delay = copy_delay
	if send_packet:
		game.broadcast_packet_input(input_player_num, copy_map, copy_frame, copy_delay)

func process_online_input_action(oinput_map, input):
	if oinput_map[input] and not input_map[input]:
		if not frame_inputs.has(input):
			frame_inputs.append(input)
		input_map[input] = true
	elif not oinput_map[input] and input_map[input]:
		input_map[input] = false

func press_input_action(input):
	if global.online:
		online_input_map[input] = true
	elif not input_map[input]:
		if not frame_inputs.has(input):
			frame_inputs.append(input)
		input_map[input] = true

func release_input_action(input):
	if global.online:
		online_input_map[input] = false
	elif input_map[input]:
		input_map[input] = false

func release_all_actions():
	release_input_action(global.INPUT_ACTION_LEFT)
	release_input_action(global.INPUT_ACTION_RIGHT)
	release_input_action(global.INPUT_ACTION_UP)
	release_input_action(global.INPUT_ACTION_DOWN)
	release_input_action(global.INPUT_ACTION_ATTACK)
	release_input_action(global.INPUT_ACTION_SPECIAL)
	release_input_action(global.INPUT_ACTION_SUPER)
	release_input_action(global.INPUT_ACTION_DASH)

func process_input_action(input):
	if not global.online or (global.online and online_control):
		var player_prefix = global.INPUT_PLAYER1
		if player_num != 1 and not global.online:
			player_prefix = global.INPUT_PLAYER2
		
		if Input.is_action_pressed(player_prefix + input):
			press_input_action(input)
		elif (online_active or not global.online):
			release_input_action(input)

func process_online_input(oinput_map):
	process_online_input_action(oinput_map, global.INPUT_ACTION_LEFT)
	process_online_input_action(oinput_map, global.INPUT_ACTION_RIGHT)
	process_online_input_action(oinput_map, global.INPUT_ACTION_UP)
	process_online_input_action(oinput_map, global.INPUT_ACTION_DOWN)
	process_online_input_action(oinput_map, global.INPUT_ACTION_ATTACK)
	process_online_input_action(oinput_map, global.INPUT_ACTION_SPECIAL)
	process_online_input_action(oinput_map, global.INPUT_ACTION_SUPER)
	process_online_input_action(oinput_map, global.INPUT_ACTION_DASH)

func process_input():
	process_input_action(global.INPUT_ACTION_LEFT)
	process_input_action(global.INPUT_ACTION_RIGHT)
	process_input_action(global.INPUT_ACTION_UP)
	process_input_action(global.INPUT_ACTION_DOWN)
	process_input_action(global.INPUT_ACTION_ATTACK)
	process_input_action(global.INPUT_ACTION_SPECIAL)
	process_input_action(global.INPUT_ACTION_SUPER)
	process_input_action(global.INPUT_ACTION_DASH)

func process_cpu():
	if cpu_type == global.CPU_TYPE.dummy_standing:
		if not cpu_acted:
			release_all_actions()
			cpu_mode = "custom"
			cpu_acted = true
	elif cpu_type == global.CPU_TYPE.dummy_jumping:
		if not cpu_acted:
			release_all_actions()
			press_input_action(global.INPUT_ACTION_UP)
			cpu_mode = "custom"
			cpu_acted = true
	else:
		match(cpu_mode):
			"idle":
				release_all_actions()
			"left":
				if not cpu_acted:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_LEFT)
					cpu_acted = true
			"right":
				if not cpu_acted:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_RIGHT)
					cpu_acted = true
			"up":
				if not cpu_acted:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_UP)
					cpu_acted = true
			"down":
				if not cpu_acted:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_DOWN)
					cpu_acted = true
			"move_forward":
				if not cpu_acted:
					release_all_actions()
					cpu_acted = true
				if position.x < other_player.position.x:
					release_input_action(global.INPUT_ACTION_LEFT)
					press_input_action(global.INPUT_ACTION_RIGHT)
				else:
					release_input_action(global.INPUT_ACTION_RIGHT)
					press_input_action(global.INPUT_ACTION_LEFT)
			"move_backward":
				if not cpu_acted:
					release_all_actions()
					cpu_acted = true
				if position.x < other_player.position.x:
					release_input_action(global.INPUT_ACTION_RIGHT)
					press_input_action(global.INPUT_ACTION_LEFT)
				else:
					release_input_action(global.INPUT_ACTION_LEFT)
					press_input_action(global.INPUT_ACTION_RIGHT)
			"dash_forward":
				if not cpu_acted:
					release_all_actions()
					cpu_acted = true
				if position.x < other_player.position.x:
					release_input_action(global.INPUT_ACTION_LEFT)
					release_input_action(global.INPUT_ACTION_RIGHT)
					press_input_action(global.INPUT_ACTION_RIGHT)
				else:
					release_input_action(global.INPUT_ACTION_LEFT)
					release_input_action(global.INPUT_ACTION_RIGHT)
					press_input_action(global.INPUT_ACTION_LEFT)
			"dash_backward":
				if not cpu_acted:
					release_all_actions()
					cpu_acted = true
				if position.x < other_player.position.x:
					release_input_action(global.INPUT_ACTION_LEFT)
					release_input_action(global.INPUT_ACTION_RIGHT)
					press_input_action(global.INPUT_ACTION_LEFT)
				else:
					release_input_action(global.INPUT_ACTION_LEFT)
					release_input_action(global.INPUT_ACTION_RIGHT)
					press_input_action(global.INPUT_ACTION_RIGHT)
			"jump":
				if not cpu_acted:
					press_input_action(global.INPUT_ACTION_UP)
				if not on_floor:
					cpu_acted = true
					release_input_action(global.INPUT_ACTION_UP)
			"attack":
				if not cpu_acted:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_ATTACK)
					cpu_acted = true
			"down_attack":
				if not cpu_acted and on_floor:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_DOWN)
					press_input_action(global.INPUT_ACTION_ATTACK)
					cpu_acted = true
			"special":
				if not cpu_acted:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_SPECIAL)
					cpu_acted = true
			"super":
				if not cpu_acted:
					release_all_actions()
					press_input_action(global.INPUT_ACTION_SUPER)
					cpu_acted = true
		
		if cpu_timer <= 0:
			if cpu_type == global.CPU_TYPE.normal:
				cpu_acted = false
				var cpu_actions = []
				match(cpu_mode):
					"idle", "move_forward", "move_backward", "jump":
						if score >= 1 and (abs(get_special_position().x - other_player.position.x) < 32 or not special_pos_relevant) \
						   and other_player.can_kill(player_num):
							cpu_actions.append(CpuAction.new("special", 60))
							cpu_actions.append(CpuAction.new("dash_forward", 10))
						if global.cpu_diff == global.CPU_DIFF.normal:
							cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
							cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
							cpu_actions.append(CpuAction.new("attack", rand_range(0, 10)))
						else:
							cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
							cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
							cpu_actions.append(CpuAction.new("dash_forward", 5))
							cpu_actions.append(CpuAction.new("dash_backward", 5))
							cpu_actions.append(CpuAction.new("attack", rand_range(10, 20)))
						cpu_actions.append(CpuAction.new("jump", rand_range(5, 10)))
						cpu_actions.append(CpuAction.new("jump", rand_range(5, 10)))
						cpu_actions.append(CpuAction.new("down_attack", rand_range(10, 20)))
						if score >= 2:
							if global.get_curr_char(player_num) == global.CHAR.time:
								cpu_actions.append(CpuAction.new("super", 90))
							else:
								cpu_actions.append(CpuAction.new("super", 30))
					"attack":
						if can_zero_special:
							cpu_actions.append(CpuAction.new("left", 5))
							cpu_actions.append(CpuAction.new("right", 5))
							cpu_actions.append(CpuAction.new("up", 5))
							cpu_actions.append(CpuAction.new("down", 5))
							cpu_actions.append(CpuAction.new("special", 30))
						else:
							cpu_actions.append(CpuAction.new("attack", 30))
							cpu_actions.append(CpuAction.new("attack", 30))
							cpu_actions.append(CpuAction.new("dash_forward", 10))
							cpu_actions.append(CpuAction.new("dash_backward", 10))
				if cpu_actions.size() > 0:
					var rand = randi() % cpu_actions.size()
					var cpu_action = cpu_actions[rand]
					cpu_mode = cpu_action.action
					if global.cpu_diff == global.CPU_DIFF.normal:
						cpu_timer = cpu_action.time + 10
					else:
						cpu_timer = cpu_action.time
				else:
					cpu_mode = "idle"
					cpu_timer = 0
			elif cpu_type == global.CPU_TYPE.dummy:
				if position.x > 70:
					if sprite.scale.x < 0:
						cpu_mode = "move_forward"
					else:
						cpu_mode = "move_backward"
				else:
					cpu_mode = "idle"
			elif cpu_type == global.CPU_TYPE.dummy_jump_attack:
				if position.x > 70:
					if sprite.scale.x < 0:
						cpu_mode = "move_forward"
					else:
						cpu_mode = "move_backward"
				else:
					if cpu_mode == "jump":
						if on_floor and cpu_acted:
							cpu_acted = false
							cpu_mode = "attack"
					elif cpu_mode == "attack":
						if cpu_acted:
							cpu_acted = false
							cpu_mode = "idle"
							cpu_timer = 180
					else:
						release_all_actions()
						cpu_mode = "jump"
						cpu_acted = false
	
	process_online_inputs()

func process_online_inputs():
	if global.online and not game.game_over:
		if online_control:
			add_online_input(player_num, online_input_map, curr_frame, send_delay, !game.game_over)

func process_curr_online_inputs():
	if global.online and not game.game_over:
		var i = 0
		while i < online_inputs.size():
			var oinput = online_inputs[i]
			var oframe = oinput.frame + oinput.input_delay
			if curr_frame > oframe:
				online_inputs.remove(i)
				i -= 1
			elif curr_frame == oframe:
				process_online_input(oinput.map)
				oinput.read = true
				online_inputs.remove(i)
				i -= 1
			i += 1

func set_cpu_type(cpu_type):
	self.cpu_type = cpu_type
	if cpu_type == global.CPU_TYPE.dummy_jump_attack:
		cpu_mode = "idle"
	release_all_actions()

func input_condition(input):
	return can_act

func check_player_input(input):
	if input_condition(input):
		return input_map[input] or buffer_inputs.has(input)
	return false
		
func check_player_just_input(input):
	if input_condition(input):
		var inputted
		inputted = (input_map[input] and frame_inputs.has(input)) or buffer_inputs.has(input)
		if inputted:
			last_input = input
			last_input_frames = 0
			return inputted
	return false

func stop_act():
	can_act = false
	can_attack = false

func start_act():
	can_act = true
	dead = false
	killed = false
	no_act_frames = 0

func start_attack():
	can_attack = true
	add_attack_buffer_inputs()

func is_dashing():
	return alpha < 1

func is_killed():
	return killed

func can_kill(other_num):
	return (can_act or no_act_frames <= 0) and not is_dashing() and not invincible and player_num != other_num and not killed

func can_kill_self():
	return (can_act or no_act_frames <= 0) and not is_dashing() and not invincible and not killed

func can_parry(other_num):
	if player_num != other_num and parrying:
		parry()
		return true
	return false

func can_destroy_other(other_num):
	return false

func kill(knockback):
	killed = true
	kill_knockback = knockback

func kill_effect():
	position = Vector2(position.x, position.y - size.y / 2)
	linear_vel = kill_knockback
	on_floor = false
	attacking = false
	dead = true
	stop_act()
	play_anim_this_frame("fall")

func parry(parry_effect_pos = Vector2()):
	inc_temp_score_back()
	create_parry_flash(parry_effect_pos)

func check_dead():
	if killed and not dead:
		kill_effect()
	if not can_act:
		no_act_frames += 1

func inc_score():
	if score <= 5:
		score = score_balls.inc_score()

func win_score():
	if score <= 5:
		score = score_balls.win_score()

func dec_score():
	if score <= 5:
		score -= 1
		if score < 0:
			score = 0
		score_balls.use_ball()

func update_score():
	if score <= 5:
		score_balls.remove_temps()
		score = score_balls.score

func set_score(new_score):
	score = new_score
	score_balls.set_score(new_score)

func inc_temp_score_back():
	if score <= 5:
		var orig_temp = score_balls.temp_score
		inc_score()
		while score_balls.temp_score > orig_temp + 1:
			score_balls.use_ball()
		score = score_balls.temp_score

func inc_temp_score():
	if score <= 5:
		var orig_temp = score_balls.temp_score
		inc_score()
		while score_balls.temp_score > orig_temp:
			score_balls.use_ball()
		score = score_balls.temp_score

func get_red_score():
	return score_balls.score

func win():
	win = true

func set_online_control(is_control):
	if not global.online_cpu:
		cpu = false
	online_control = is_control
	
func reset():
	reset_pos(orig_pos)
	can_attack = false
	win = false
	score = score_balls.reset_score()

func reset_pos(new_pos):
	position = new_pos
	can_dash = true
	attacking = false
	dead = false
	killed = false
	alpha = 1
	set_modulate(Color(1, 1, 1, alpha))
	invincible = false
	sprite.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 0)
	sprite.get_material().set_shader_param(global.SHADERPARAM_BLUEAMOUNT, 0)
	set_zero_delay()

func reset_training():
	linear_vel = Vector2()
	can_act = true
	can_attack = true
	play_idle()
	own_shadow.process(0, 0)

func play_idle():
	play_anim_this_frame("idle")

func attack():
	pass

func special():
	dec_score()
	can_inv_dash = false

func super():
	for i in range(2):
		dec_score()

func attack_condition():
	return true

func special_condition():
	return score > 0

func super_condition():
	return score >= 2

func get_special_position():
	return position

func process_move():
	var jumped = false
	if on_floor:
		can_inv_dash = true
	
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
				if can_inv_dash:
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
				if can_inv_dash:
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
					if can_inv_dash:
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
					if can_inv_dash:
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
	pass

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
		new_anim = process_attack_anim()
	elif not on_floor:
		new_anim = "jump"
	elif linear_vel.x != 0:
		new_anim = "walk_forwards"
		if sign(sprite.scale.x) != sign(linear_vel.x):
			new_anim = "walk_backwards"
	else:
		new_anim = process_idle_anim()
	new_anim = postprocess_anim(new_anim)
	if anim_player.current_animation != new_anim:
		play_anim_this_frame(new_anim)

func process_attack_anim():
	return anim_player.current_animation

func process_idle_anim():
	return "idle"

func postprocess_anim(new_anim):
	return new_anim

func adjust_facing():
	if position.x < other_player.position.x:
		sprite.scale.x = 1
	elif position.x > other_player.position.x:
		sprite.scale.x = -1

func turn_attack_hitboxes_off():
	for hitbox in own_hitboxes_perm:
		hitbox.set_monitoring(false)

func process_edge_hit():
	if anim_player.current_animation == "special":
		linear_vel.x *= -0.1
	if (position.x <= left_bound and sprite.scale.x < 0) or \
	   (position.x >= right_bound and sprite.scale.x > 0):
		linear_vel.x = 0

func correct_player_collisions():
	correct_player_collisions_custom(other_player)

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

func process_collisions():
	var hitboxes = get_tree().get_nodes_in_group(global.GROUP_HITBOX)
	for other_hitbox in hitboxes:
		if hurtbox == other_hitbox:
			continue
		for own_hitbox_arr in own_hitboxes:
			var coll_func = own_hitbox_arr[0]
			var own_hitbox = own_hitbox_arr[1]
			var knockback = own_hitbox_arr[2]
			var effect = own_hitbox_arr[3]
			var effect_pos = own_hitbox_arr[4]
			if own_hitbox != other_hitbox and own_hitbox.intersects(other_hitbox):
				if effect_pos == null:
					if effect == null:
						if knockback == null:
							call(coll_func, other_hitbox)
						else:
							call(coll_func, other_hitbox, knockback)
					else:
						call(coll_func, other_hitbox, knockback, effect)
				else:
					call(coll_func, other_hitbox, knockback, effect, effect_pos)

func process_own_hitbox(hitbox, knockback, effect, effect_pos = null):
	process_own_hitbox_custom("on_hitbox_collided", hitbox, knockback, effect, effect_pos)

func process_own_hitbox_custom(coll_func, hitbox, knockback = null, effect = null, effect_pos = null):
	hitbox.set_monitoring(hitbox.is_monitoring())
	if hitbox.is_monitoring():
		hitbox.set_attacking(true)
		own_hitboxes.append([coll_func, hitbox, knockback, effect, effect_pos])
		if not own_hitboxes_perm.has(hitbox):
			own_hitboxes_perm.append(hitbox)

func process_hitbox_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group(global.GROUP_PROJECTILE) and hitbox_owner.can_collide_with_char() and call_other:
		hitbox_owner.process_hitbox_collision(hurtbox, false)

func on_hitbox_collided(other_hitbox, knockback, effect, effect_pos = null):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if effect_pos == null:
		effect_pos = lerp(position, hitbox_owner.position, 0.75) - position
	if hitbox_owner.is_in_group(global.GROUP_CHARACTER):
		if hitbox_owner.can_kill(player_num):
			if not hitbox_owner.is_in_group(global.GROUP_PROJECTILE):
				stop_act()
				game.inc_score(player_num)
			hitbox_owner.kill(Vector2(knockback.x, knockback.y))
			return hitbox_kill_effect(hitbox_owner, effect, effect_pos)
		elif hitbox_owner.can_parry(player_num):
			if hitbox_owner.is_in_group(global.GROUP_CAN_REFLECT):
				linear_vel.x *= -1
				sprite.scale.x *= -1
			return hitbox_parry_effect(hitbox_owner, effect, effect_pos)
		else:
			return hitbox_hit_effect(hitbox_owner, effect, effect_pos)
	return null

func hitbox_kill_effect(hitbox_owner, effect, effect_pos):
	return create_effect(effect, effect_pos)

func hitbox_parry_effect(hitbox_owner, effect, effect_pos):
	return create_effect(effect, effect_pos)

func hitbox_hit_effect(hitbox_owner, effect, effect_pos):
	return null

func preprocess_input(online_active):
	self.online_active = online_active
	if other_player != null and not cpu:
		process_input()

func preprocess_frame():
	last_input_frames += 1
	
	turn_attack_hitboxes_off()
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
	
	if (not attacking or attack_while_attacking) and (can_attack or attack_while_ready) and (alpha == 1 or attack_while_dashing):
		if ((assuper and check_player_just_input(global.INPUT_ACTION_ATTACK) and check_player_just_input(global.INPUT_ACTION_SPECIAL)) or check_player_just_input(global.INPUT_ACTION_SUPER)) and super_condition():
			if set_attacking_on_super:
				attacking = true
			if adjust_facing_on_super:
				adjust_facing()
			super()
		elif check_player_just_input(global.INPUT_ACTION_SPECIAL) and special_condition():
			if set_attacking_on_special:
				attacking = true
			if adjust_facing_on_special:
				adjust_facing()
			special()
		elif check_player_just_input(global.INPUT_ACTION_ATTACK) and attack_condition():
			if set_attacking_on_attack:
				attacking = true
			if adjust_facing_on_attack:
				adjust_facing()
			attack()
	
	if not attacking or move_while_attacking or dash_while_attacking:
		process_move()
	
	on_floor = hurtbox.get_global_rect().position.y + hurtbox.rect_size.y >= global.floor_y
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
	on_floor = hurtbox.get_global_rect().position.y + hurtbox.rect_size.y >= global.floor_y
	if on_floor:
		position.y = global.floor_y - hurtbox.rect_size.y - hurtbox.rect_position.y
	
	if position.x < left_bound:
		position = Vector2(left_bound, position.y)
		process_edge_hit()
	if position.x > right_bound:
		position = Vector2(right_bound, position.y)
		process_edge_hit()
	
	if not attacking or move_while_attacking:
		adjust_facing()
	
	if not attacking or move_while_attacking:
		if can_dash and other_player.can_dash and \
		   not ((position.x <= left_bound and sprite.scale.x > 0) or (position.x >= right_bound and sprite.scale.x < 0)) and \
		   position.y - size.y + 32 <= other_player.position.y + 32 and \
		   position.y + 32 >= other_player.position.y - other_player.size.y + 32:
			correct_player_collisions()

func preprocess(curr_frame, frame_delay):
	self.curr_frame = curr_frame
	if other_player != null:
		if game.input_delay >= game.prev_delay:
			send_delay = game.prev_delay
			if cpu:
				process_cpu()
			else:
				process_online_inputs()
		if game.input_delay > game.prev_delay:
			send_delay = game.input_delay
			if cpu:
				process_cpu()
			else:
				process_online_inputs()
		process_curr_online_inputs()
		
		if curr_frame_delay <= 0 or ignore_frame_delay:
			cpu_timer -= 1
			preprocess_frame()

func process_frame():
	process_collisions()
	own_hitboxes.clear()
	
	process_anim()
	
	if parrying:
		sprite.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 0)
		sprite.get_material().set_shader_param(global.SHADERPARAM_BLUEAMOUNT, parry_blue_amount)
	elif invincible:
		sprite.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, inv_white_amount)
		sprite.get_material().set_shader_param(global.SHADERPARAM_BLUEAMOUNT, 0)
	else:
		sprite.get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, 0)
		sprite.get_material().set_shader_param(global.SHADERPARAM_BLUEAMOUNT, 0)

func process(curr_frame, frame_delay):
	if other_player != null:
		if curr_frame_delay <= 0 or ignore_frame_delay:
			if prev_frame_delay > 0:
				disable_buffer = false
				hold_buffer = false
			process_frame()
			buffer_inputs.clear()
			
			prev_frame_delay = curr_frame_delay
			if ignore_frame_delay or curr_frame_delay < 0:
				frame_delay = 0
				curr_frame_delay = 0
			else:
				curr_frame_delay = frame_delay
		else:
			prev_frame_delay = curr_frame_delay
			curr_frame_delay -= 1
			if curr_frame_delay > max_input_buffer:
				buffer_inputs.clear()
				disable_buffer = true
				hold_buffer = true
			elif not disable_buffer or (hold_buffer and curr_frame_delay == 0):
				add_buffer_inputs()
		
		frame_inputs.clear()
		
		if position.x < left_bound:
			position = Vector2(left_bound, position.y)
		if position.x > right_bound:
			position = Vector2(right_bound, position.y)

func create_projectile(proj, proj_pos = Vector2.ZERO):
	if proj == null:
		return null
	var p = proj.instance()
	p.position = position + proj_pos
	p.set_player(self)
	get_parent().add_child(p)
	return p

func create_effect(effect, effect_pos = Vector2.ZERO):
	if effect == null:
		return null
	var e = effect.instance()
	e.position = position + effect_pos
	get_parent().add_child(e)
	e.set_palette(player_num)
	return e

func create_dash_effect(effect_pos, scale_x, rot_deg):
	var e = create_effect(effect_dash, effect_pos + Vector2(0, effect_y_offset))
	e.scale.x = scale_x
	e.rotation_degrees = rot_deg
	play_audio_custom(dash_player, sfx_dash)
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
	a.set_palette(player_num)
	return a

func create_super_flash(offset):
	var e = effect_super_flash.instance()
	e.position = position + offset
	e.scale.x = sprite.scale.x
	get_parent().add_child(e)
	game.super_flash()
	disable_buffer = true

func create_parry_flash(offset):
	var e = effect_parry_flash.instance()
	e.position = position + offset
	get_parent().add_child(e)
	game.parry_flash()
	disable_buffer = true

func play_audio(sfx):
	play_audio_custom(audio, sfx)

func play_audio_custom(player, sfx):
	player.volume_db = global.sfx_volume_db
	player.stream = sfx
	player.play(0)

func play_anim_this_frame(anim, frame = 0, custom_anim_player = null):
	turn_attack_hitboxes_off()
	if custom_anim_player == null:
		custom_anim_player = anim_player
	custom_anim_player.play(anim)
	custom_anim_player.seek(frame, true)

func get_shadow():
	return own_shadow

func set_other_player(new_other_player):
	other_player = new_other_player

func set_zero_delay():
	prev_frame_delay = 0
	curr_frame_delay = 0
	ignore_frame_delay = false

func set_palette():
	set_palette_sprite(sprite)

func set_palette_sprite(palette_sprite):
	global.set_material_palette(palette_sprite.material, player_num)

func on_anim_finished(anim_name):
	if attacking:
		attacking = false
		play_anim_this_frame("idle")
