extends Node

enum SCREEN { window, window2x, window3x, window4x, full }
enum INPUT_TYPE { key, pad, stick }
enum MODE { versus_player, versus_cpu, online_lobby, online_quickmatch, arcade, training, tutorial }
enum CHAR { goto, yoyo, kero, time, sword, slime, scythe, darkgoto, random, locked }
enum STAGE { dojo, rooftop, lab, company, bridge, factory, sanctuary, blackhole, training, random, locked }
enum STAGE_SELECT { random, choose }
enum CPU_TYPE { normal, dummy, dummy_standing, dummy_jumping, dummy_jump_attack }
enum CPU_DIFF { normal, hard }
enum RESET_POS { middle, middleL, left, leftR, right, rightL }
enum LOBBY_READY { not_ready, ready, playing }
enum LOBBY_STATE { player1, player2, spectate }
enum LOBBY_ROTATE { none, player1, player2, both }
enum LOBBY_REMATCH { none, bo3, bo5, inf }
enum LOBBY_ROTATION { win, lose, none }
enum LOBBY_OPEN { invite, friends, public }
enum P_TYPE { menu_lobby_owner, menu_lobby_joiner, \
			  lobby_init, lobby_ready, lobby_ready_start, lobby_ready_reset, lobby_start, lobby_return, \
			  timer_timeout_start, timer_timeout_stop, \
			  timer_player1_ready_start, timer_player1_ready_stop, \
			  timer_player2_ready_start, timer_player2_ready_stop, \
			  cs_highlight, cs_select, cs_back, cs_palette, cs_select_palette, cs_confirmed_player1, cs_confirmed_player2, \
			  ss_highlight, ss_select, ss_confirmed, \
			  game_input, game_menu, game_ping }

const VERSION = "v3.1.1"

const CONFIG_FILE = "user://config.cfg"
const PALETTE_FILE = "user://palette.cfg"
const CFG_P1S = "player1_setting"
const CFG_P2S = "player2_setting"
const CFG_PS_DTDASH = "dtdash"
const CFG_PS_ASSUPER = "assuper"
const CFG_OPTIONS = "options"
const CFG_OPTIONS_CPUDIFF = "cpu_diff"
const CFG_OPTIONS_SCREEN = "screen_type"
const CFG_OPTIONS_VSYNC = "vsync"
const CFG_OPTIONS_MUSVOL = "music_volume"
const CFG_OPTIONS_SFXVOL = "sfx_volume"
const CFG_UNLOCK = "unlock"
const CFG_UNLOCK_COLOR4 = "color4"
const CFG_UNLOCK_CHAR_DARKGOTO = "char_darkgoto"
const CFG_UNLOCK_STAGE_BLACKHOLE = "stage_blackhole"
const CFG_RECORD = "record"
const CFG_RECORD_ARCADE = "arcade"
const PAL_OPTIONS = "options"
const PAL_OPTIONS_ENABLED = "enabled"
const PAL_OPTIONS_NUM = "num"
const PAL_CUSTOM = "custom"

const INPUT_PLAYER1 = "player1_"
const INPUT_PLAYER2 = "player2_"
const INPUT_ACTION_LEFT = "left"
const INPUT_ACTION_RIGHT = "right"
const INPUT_ACTION_UP = "up"
const INPUT_ACTION_DOWN = "down"
const INPUT_ACTION_ATTACK = "attack"
const INPUT_ACTION_SPECIAL = "special"
const INPUT_ACTION_SUPER = "super"
const INPUT_ACTION_DASH = "dash"
const INPUT_ACTION_START = "start"
const INPUT_ACTION_UPLEFT = "upleft"
const INPUT_ACTION_UPRIGHT = "upright"
const INPUT_ACTION_NONE = "none"
const INPUT_MAP = [ INPUT_ACTION_LEFT, \
					INPUT_ACTION_RIGHT, \
					INPUT_ACTION_UP, \
					INPUT_ACTION_DOWN, \
					INPUT_ACTION_ATTACK, \
					INPUT_ACTION_SPECIAL, \
					INPUT_ACTION_SUPER, \
					INPUT_ACTION_DASH, \
					INPUT_ACTION_START ]

const LOBBY_VERSION = "LOBBY_VERSION"
const LOBBY_NAME = "LOBBY_NAME"
const LOBBY_PASSWORD = "LOBBY_PASSWORD"
const LOBBY_REMATCH_STYLE = "LOBBY_REMATCH_STYLE"
const LOBBY_ROTATION_STYLE = "LOBBY_ROTATION_STYLE"
const LOBBY_MATCH_LIMIT = "LOBBY_MATCH_LIMIT"
const LOBBY_DELAY = "LOBBY_DELAY"
const LOBBY_STAGE_SELECT = "LOBBY_STAGE_SELECT"
const LOBBY_STAGE = "LOBBY_STAGE"
const LOBBY_CHAT = "LOBBY_CHAT"
const LOBBY_PLAYER_ID = "LOBBY_PLAYER_ID"
const LOBBY_PLAYER_READY = "LOBBY_PLAYER_READY"
const MEMBER_LOBBY_DTDASH = "LOBBY_DTDASH"
const MEMBER_LOBBY_ASSUPER = "LOBBY_ASSUPER"
const MEMBER_LOBBY_WINS = "LOBBY_WINS"
const MEMBER_LOBBY_MATCHES = "LOBBY_MATCHES"
const MEMBER_LOBBY_SKIP = "LOBBY_SKIP"
const MEMBER_LOBBY_CONSEC_MATCHES = "LOBBY_CONSEC_MATCHES"

const LOBBY_MSG_SEP_CHAR = "$"
const LOBBY_MSG_TIMEOUT = "timeout"
const LOBBY_MSG_CHAT = "chat"

const GROUP_CHARACTER = "char"
const GROUP_CHAR_KERO = "char_kero"
const GROUP_CHAR_SLIME = "char_slime"
const GROUP_CHAR_SCYTHE = "char_scythe"
const GROUP_PROJECTILE = "proj"
const GROUP_PROJ_KERO = "proj_kero"
const GROUP_SUPERPROJ = "superproj"
const GROUP_HITBOX = "hitbox"
const GROUP_CAN_REFLECT = "can_reflect"

const SHADERPARAM_COLOR_ORIG = "color_o"
const SHADERPARAM_COLOR_NEW = "color_n"
const SHADERPARAM_THRESHOLD = "threshold"
const SHADERPARAM_WHITEAMOUNT = "white_amount"
const SHADERPARAM_BLUEAMOUNT = "blue_amount"

const SCENE_MENU = "res://scenes/screen/menu.tscn"
const SCENE_CHARSELECT = "res://scenes/screen/charselect.tscn"
const SCENE_STAGESELECT = "res://scenes/screen/stageselect.tscn"
const SCENE_VSSCREEN = "res://scenes/screen/vsscreen.tscn"
const SCENE_GAME = "res://scenes/screen/game.tscn"
const SCENE_ARCADEWIN = "res://scenes/screen/arcadewin.tscn"
const SCENE_ONLINE_LOBBY = "res://scenes/screen/online_lobby.tscn"

onready var debug_text = preload("res://scenes/ui/menu/debug_text.tscn")

onready var char_goto = preload("res://scenes/char/goto.tscn")
onready var char_yoyo = preload("res://scenes/char/yoyo.tscn")
onready var char_kero = preload("res://scenes/char/kero.tscn")
onready var char_time = preload("res://scenes/char/time.tscn")
onready var char_sword = preload("res://scenes/char/sword.tscn")
onready var char_slime = preload("res://scenes/char/slime.tscn")
onready var char_scythe = preload("res://scenes/char/scythe.tscn")
onready var char_darkgoto = preload("res://scenes/char/darkgoto.tscn")

var window_size = Vector2(1024, 600)
var viewport_size = Vector2(256, 150)

var fps = 60
var floor_y = 59
var invalid_chars = 2
var invalid_stages = 2
var char_count = len(CHAR) - invalid_chars
var stage_count = len(STAGE) - invalid_stages
var vsync = true
var beta = false
var save_inputs = false
var turbo_mode = false
var online_cpu = false
var debug_texts = false
var show_hitboxes = false
var infinite_rounds = false
var auto_rematch = false
var print_round_end_frame = false
var print_texts = false
var steam_enabled = true
var html5_ver = false
var custom_palettes_enabled = false

var online = false
var steam_id = 0
var lobby_join = false
var lobby_found = false
var lobby_chat = true
var lobby_rotate = LOBBY_ROTATE.none
var lobby_state = LOBBY_STATE.spectate
var lobby_player1_wins = 0
var lobby_player2_wins = 0
var lobby_chat_msg = ""
var curr_lobby_id = 0
var host_member_id = 0
var other_member_id = 0
var spectator_member_ids = []
var lobby_member_ids = []
var lobby_member_ready = [LOBBY_READY.not_ready, LOBBY_READY.not_ready]
var find_password = ""
var find_page = 1
var find_max_page = 1
var host_name = ""
var host_password = ""
var host_max_players = 8
var host_rematch = LOBBY_REMATCH.none
var host_rotation = LOBBY_ROTATION.win
var host_match_limit = 0
var host_delay = 0
var host_stage_select = STAGE_SELECT.random
var host_open = LOBBY_OPEN.public
var host_chat = true
var host_page = 1
var host_max_page = 4
var input_delay = 0
var prev_input_delay = 0
var stage_select = STAGE_SELECT.random

var menu_init = false
var menu_option = 1
var player1_char = CHAR.goto
var player1_palette = -1
var player1_cpu = false
var player1_dtdash = true
var player1_assuper = true
var player2_char = CHAR.goto
var player2_palette = 0
var player2_cpu = false
var player2_dtdash = true
var player2_assuper = true
var stage = STAGE.dojo
var mode = MODE.versus_player
var online_char = CHAR.goto
var online_palette = -1
var online_stage = STAGE.dojo
var arcade_stage = 0
var arcade_continues = 0
var arcade_time = 0
var max_arcade_stage = char_count - 1
var cpu_diff = CPU_DIFF.normal
var music_volume = 7
var music_volume_db = 0
var sfx_volume = 8
var sfx_volume_db = 0
var screen_type = SCREEN.window4x

var unlock_color4 = []
var unlock_char_darkgoto = false
var unlock_stage_blackhole = false

var record_arcade = []

var num_default_palettes = 4
var num_custom_palettes = []
var palette_custom = []

var arcade_chars = []

func create_debug_text(text):
	if debug_texts:
		create_text(text)

func create_info_text(text):
	create_text(text)

func create_text(text):
	var highest_y = 145
	var debug_texts = get_tree().get_nodes_in_group("debug")
	for t in debug_texts:
		if t.get_position().y < highest_y:
			highest_y = t.get_position().y
	
	var t = debug_text.instance()
	get_parent().add_child(t)
	t.set_position(Vector2(4, highest_y - 10))
	t.set_text(text)
	
	if print_texts:
		print(text)

func load_config():
	if steam_enabled:
		var init = Steam.steamInit()
		if !init:
			print("Failed to init Steam, quitting game")
			get_tree().quit()
		else:
			Steam.connect("join_requested", self, "join_requested")
			Steam.connect("lobby_created", self, "lobby_created")
			Steam.connect("lobby_joined", self, "lobby_joined")
			Steam.connect("lobby_chat_update", self, "lobby_chat_update")
			Steam.connect("lobby_data_update", self, "lobby_data_update")
			Steam.connect("lobby_message", self, "lobby_message")
			Steam.connect("p2p_session_request", self, "p2p_session_request")
			Steam.connect("p2p_session_connect_fail", self, "p2p_session_connect_fail")
			steam_id = Steam.getSteamID()
			host_name = (Steam.getPersonaName() + "'s lobby").substr(0, 24)
	
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	
	cpu_diff = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_CPUDIFF, cpu_diff)
	screen_type = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_SCREEN, screen_type)
	vsync = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_VSYNC, vsync)
	
	unlock_color4.resize(char_count)
	if html5_ver:
		music_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_MUSVOL, 0)
		sfx_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_SFXVOL, 0)
		for i in range(char_count):
			var save_str = CFG_UNLOCK_COLOR4 + "_" + get_char_debug_name(i)
			unlock_color4[i] = get_config_value(config, CFG_UNLOCK, save_str, true)
		unlock_char_darkgoto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_CHAR_DARKGOTO, true)
		unlock_stage_blackhole = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_STAGE_BLACKHOLE, true)
	else:
		music_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_MUSVOL, music_volume)
		sfx_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_SFXVOL, sfx_volume)
		for i in range(char_count):
			var save_str = CFG_UNLOCK_COLOR4 + "_" + get_char_debug_name(i)
			unlock_color4[i] = get_config_value(config, CFG_UNLOCK, save_str, false)
		unlock_char_darkgoto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_CHAR_DARKGOTO, unlock_char_darkgoto)
		unlock_stage_blackhole = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_STAGE_BLACKHOLE, unlock_stage_blackhole)
	
	record_arcade.resize(char_count)
	for i in range(char_count):
		var save_str = CFG_RECORD_ARCADE + "_" + get_char_debug_name(i)
		record_arcade[i] = get_config_value(config, CFG_RECORD, save_str, -1)
	
	config.save(CONFIG_FILE)
	load_input(config)
	
	set_music_volume()
	set_sfx_volume()
	set_screen_type()
	set_vsync()
	
	config = ConfigFile.new()
	config.load(PALETTE_FILE)
	
	custom_palettes_enabled = get_config_value(config, PAL_OPTIONS, PAL_OPTIONS_ENABLED, custom_palettes_enabled)
	
	num_custom_palettes.resize(char_count)
	palette_custom.resize(char_count)
	for i in range(char_count):
		var save_str = PAL_OPTIONS_NUM + "_" + get_char_debug_name(i)
		num_custom_palettes[i] = get_config_value(config, PAL_OPTIONS, save_str, 3)
		
		palette_custom[i] = []
		palette_custom[i].resize(num_custom_palettes[i])
		for j in range(num_custom_palettes[i]):
			var palette_num = j + 1
			palette_custom[i][j] = get_config_value(config, PAL_CUSTOM + str(palette_num), \
													get_char_debug_name(i), get_char_default_palette(i))
	
	config.save(PALETTE_FILE)

func load_input(config):
	for i in range(6):
		var prefix = INPUT_PLAYER1
		var suffix = "key"
		var type = INPUT_TYPE.key
		match i:
			1:
				suffix = "pad"
				type = INPUT_TYPE.pad
			2:
				suffix = "stick"
				type = INPUT_TYPE.stick
			3:
				prefix = INPUT_PLAYER2
				suffix = "key"
			4:
				prefix = INPUT_PLAYER2
				suffix = "pad"
				type = INPUT_TYPE.pad
			5:
				prefix = INPUT_PLAYER2
				suffix = "stick"
				type = INPUT_TYPE.stick
		if config.has_section(prefix + suffix):
			for input in config.get_section_keys(prefix + suffix):
				var event
				match type:
					INPUT_TYPE.key:
						event = InputEventKey.new()
						event.scancode = OS.find_scancode_from_string(config.get_value(prefix + suffix, input))
					INPUT_TYPE.pad:
						event = InputEventJoypadButton.new()
						var input_str = config.get_value(prefix + suffix, input)
						var split = input_str.find(",")
						event.device = int(input_str.left(split))
						event.button_index = int(input_str.right(split + 1))
					INPUT_TYPE.stick:
						event = InputEventJoypadMotion.new()
						var input_str = config.get_value(prefix + suffix, input)
						var split = input_str.find(",")
						event.device = int(input_str.left(split))
						input_str = input_str.right(split + 1)
						split = input_str.find(",")
						event.axis = int(input_str.left(split))
						event.axis_value = int(input_str.right(split + 1))
				for old_event in InputMap.get_action_list(prefix + input):
					match type:
						INPUT_TYPE.key:
							if old_event is InputEventKey:
								InputMap.action_erase_event(prefix + input, old_event)
						INPUT_TYPE.pad:
							if old_event is InputEventJoypadButton:
								InputMap.action_erase_event(prefix + input, old_event)
						INPUT_TYPE.stick:
							if old_event is InputEventJoypadMotion:
								InputMap.action_erase_event(prefix + input, old_event)
				InputMap.action_add_event(prefix + input, event)
		else:
			set_input_default_p1()
			set_input_default_p2()
	
	player1_dtdash = config.get_value(CFG_P1S, CFG_PS_DTDASH, true)
	player1_assuper = config.get_value(CFG_P1S, CFG_PS_ASSUPER, true)
	player2_dtdash = config.get_value(CFG_P2S, CFG_PS_DTDASH, true)
	player2_assuper = config.get_value(CFG_P2S, CFG_PS_ASSUPER, true)

func save_config_value(section, key, value):
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	config.set_value(section, key, value)
	config.save(CONFIG_FILE)

func get_config_value(config, section, key, value):
	if not config.has_section(section) or not config.has_section_key(section, key):
		config.set_value(section, key, value)
		return value
	return config.get_value(section, key, value)

func set_cpu_diff():
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_CPUDIFF, cpu_diff)

func set_music_volume():
	if music_volume > 0:
		music_volume_db = -4 * (10 - music_volume)
	else:
		music_volume_db = -100
	global_audio.volume_db = music_volume_db
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_MUSVOL, music_volume)

func set_sfx_volume():
	if sfx_volume > 0:
		sfx_volume_db = -4 * (10 - sfx_volume)
	else:
		sfx_volume_db = -100
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_SFXVOL, sfx_volume)

func set_screen_type():
	OS.window_fullscreen = (screen_type == SCREEN.full)
	match screen_type:
		SCREEN.window:
			window_size = viewport_size
		SCREEN.window2x:
			window_size = viewport_size * 2
		SCREEN.window3x:
			window_size = viewport_size * 3
		SCREEN.window4x:
			window_size = viewport_size * 4
	if screen_type != SCREEN.full:
		OS.set_window_size(window_size)
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_SCREEN, screen_type)

func set_vsync():
	OS.set_use_vsync(vsync)
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_VSYNC, vsync)

func set_input(player1, event, input):
	var input_valid = true
	var prefixes = [INPUT_PLAYER1, INPUT_PLAYER2]
	var prefix = INPUT_PLAYER1
	var suffix = "key"
	var input_str
	if not player1:
		prefix = INPUT_PLAYER2
	if event is InputEventJoypadMotion:
		suffix = "stick"
		input_str = str(event.device) + "," + str(event.axis) + "," + str(event.axis_value)
		var swap_event = null
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventJoypadMotion:
				InputMap.action_erase_event(prefix + input, old_event)
				swap_event = old_event
		for other_input in INPUT_MAP:
			var input_found = false
			for other_prefix in prefixes:
				if other_prefix == prefix and other_input == input:
					continue
				for other_event in InputMap.get_action_list(other_prefix + other_input):
					if other_event is InputEventJoypadMotion and \
					   other_event.device == event.device and other_event.axis == event.axis and \
					   other_event.axis_value == event.axis_value:
						InputMap.action_erase_event(other_prefix + other_input, other_event)
						if swap_event != null:
							InputMap.action_add_event(other_prefix + other_input, swap_event)
							var swap_input_str = str(swap_event.device) + "," + str(swap_event.axis) + "," + str(swap_event.axis_value)
							save_config_value(other_prefix + suffix, other_input, swap_input_str)
						input_found = true
						break
				if input_found:
					break
			if input_found:
				break
	elif event is InputEventJoypadButton:
		suffix = "pad"
		input_str = str(event.device) + "," + str(event.button_index)
		var swap_event = null
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventJoypadButton:
				InputMap.action_erase_event(prefix + input, old_event)
				swap_event = old_event
		for other_input in INPUT_MAP:
			var input_found = false
			for other_prefix in prefixes:
				if other_prefix == prefix and other_input == input:
					continue
				for other_event in InputMap.get_action_list(other_prefix + other_input):
					if other_event is InputEventJoypadButton and \
					   other_event.device == event.device and other_event.button_index == event.button_index:
						InputMap.action_erase_event(other_prefix + other_input, other_event)
						if swap_event != null:
							InputMap.action_add_event(other_prefix + other_input, swap_event)
							var swap_input_str = str(swap_event.device) + "," + str(swap_event.button_index)
							save_config_value(other_prefix + suffix, other_input, swap_input_str)
						input_found = true
						break
				if input_found:
					break
			if input_found:
				break
	elif event is InputEventKey:
		input_str = OS.get_scancode_string(event.scancode)
		var swap_event = null
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventKey:
				InputMap.action_erase_event(prefix + input, old_event)
				swap_event = old_event
		for other_input in INPUT_MAP:
			var input_found = false
			for other_prefix in prefixes:
				if other_prefix == prefix and other_input == input:
					continue
				for other_event in InputMap.get_action_list(other_prefix + other_input):
					if other_event is InputEventKey and other_event.scancode == event.scancode:
						InputMap.action_erase_event(other_prefix + other_input, other_event)
						if swap_event != null:
							InputMap.action_add_event(other_prefix + other_input, swap_event)
							var swap_input_str = OS.get_scancode_string(swap_event.scancode)
							save_config_value(other_prefix + suffix, other_input, swap_input_str)
						input_found = true
						break
				if input_found:
					break
			if input_found:
				break
	else:
		input_valid = false
	if input_valid:
		InputMap.action_add_event(prefix + input, event)
		save_config_value(prefix + suffix, input, input_str)

func set_input_from_scancode(player1, scancode, input):
	var event = InputEventKey.new()
	event.scancode = scancode
	set_input(player1, event, input)

func set_input_from_button(player1, device, button_index, input):
	var event = InputEventJoypadButton.new()
	event.device = device
	event.button_index = button_index
	set_input(player1, event, input)

func set_input_from_axis(player1, device, axis, axis_value, input):
	var event = InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = axis_value
	set_input(player1, event, input)

func erase_axis_inputs(player1):
	var prefix = INPUT_PLAYER1
	if not player1:
		prefix = INPUT_PLAYER2
	for input in INPUT_MAP:
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventJoypadMotion:
				InputMap.action_erase_event(prefix + input, old_event)
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	config.erase_section(prefix + "stick")
	config.save(CONFIG_FILE)

func set_input_default_p1():
	set_input_from_scancode(true, OS.find_scancode_from_string("A"), INPUT_ACTION_LEFT)
	set_input_from_scancode(true, OS.find_scancode_from_string("D"), INPUT_ACTION_RIGHT)
	set_input_from_scancode(true, OS.find_scancode_from_string("W"), INPUT_ACTION_UP)
	set_input_from_scancode(true, OS.find_scancode_from_string("S"), INPUT_ACTION_DOWN)
	set_input_from_scancode(true, OS.find_scancode_from_string("G"), INPUT_ACTION_ATTACK)
	set_input_from_scancode(true, OS.find_scancode_from_string("H"), INPUT_ACTION_SPECIAL)
	set_input_from_scancode(true, OS.find_scancode_from_string("J"), INPUT_ACTION_SUPER)
	set_input_from_scancode(true, OS.find_scancode_from_string("K"), INPUT_ACTION_DASH)
	set_input_from_scancode(true, OS.find_scancode_from_string("Enter"), INPUT_ACTION_START)
	
	set_input_from_button(true, 0, 14, INPUT_ACTION_LEFT)
	set_input_from_button(true, 0, 15, INPUT_ACTION_RIGHT)
	set_input_from_button(true, 0, 12, INPUT_ACTION_UP)
	set_input_from_button(true, 0, 13, INPUT_ACTION_DOWN)
	set_input_from_button(true, 0, 0, INPUT_ACTION_ATTACK)
	set_input_from_button(true, 0, 1, INPUT_ACTION_SPECIAL)
	set_input_from_button(true, 0, 2, INPUT_ACTION_SUPER)
	set_input_from_button(true, 0, 7, INPUT_ACTION_DASH)
	set_input_from_button(true, 0, 11, INPUT_ACTION_START)
	
	set_input_from_axis(true, 0, 0, -1, INPUT_ACTION_LEFT)
	set_input_from_axis(true, 0, 0, 1, INPUT_ACTION_RIGHT)
	set_input_from_axis(true, 0, 1, -1, INPUT_ACTION_UP)
	set_input_from_axis(true, 0, 1, 1, INPUT_ACTION_DOWN)
	
	player1_dtdash = true
	save_config_value(CFG_P1S, CFG_PS_DTDASH, true)
	
	player1_assuper = true
	save_config_value(CFG_P1S, CFG_PS_ASSUPER, true)

func set_input_default_p2():
	set_input_from_scancode(false, OS.find_scancode_from_string("Left"), INPUT_ACTION_LEFT)
	set_input_from_scancode(false, OS.find_scancode_from_string("Right"), INPUT_ACTION_RIGHT)
	set_input_from_scancode(false, OS.find_scancode_from_string("Up"), INPUT_ACTION_UP)
	set_input_from_scancode(false, OS.find_scancode_from_string("Down"), INPUT_ACTION_DOWN)
	set_input_from_scancode(false, OS.find_scancode_from_string("End"), INPUT_ACTION_ATTACK)
	set_input_from_scancode(false, OS.find_scancode_from_string("PageDown"), INPUT_ACTION_SPECIAL)
	set_input_from_scancode(false, OS.find_scancode_from_string("Delete"), INPUT_ACTION_SUPER)
	set_input_from_scancode(false, OS.find_scancode_from_string("Insert"), INPUT_ACTION_DASH)
	set_input_from_scancode(false, OS.find_scancode_from_string("Kp Enter"), INPUT_ACTION_START)
	
	set_input_from_button(false, 1, 14, INPUT_ACTION_LEFT)
	set_input_from_button(false, 1, 15, INPUT_ACTION_RIGHT)
	set_input_from_button(false, 1, 12, INPUT_ACTION_UP)
	set_input_from_button(false, 1, 13, INPUT_ACTION_DOWN)
	set_input_from_button(false, 1, 0, INPUT_ACTION_ATTACK)
	set_input_from_button(false, 1, 1, INPUT_ACTION_SPECIAL)
	set_input_from_button(false, 1, 2, INPUT_ACTION_SUPER)
	set_input_from_button(false, 1, 7, INPUT_ACTION_DASH)
	set_input_from_button(false, 1, 11, INPUT_ACTION_START)
	
	set_input_from_axis(false, 1, 0, -1, INPUT_ACTION_LEFT)
	set_input_from_axis(false, 1, 0, 1, INPUT_ACTION_RIGHT)
	set_input_from_axis(false, 1, 1, -1, INPUT_ACTION_UP)
	set_input_from_axis(false, 1, 1, 1, INPUT_ACTION_DOWN)
	
	player2_dtdash = true
	save_config_value(CFG_P2S, CFG_PS_DTDASH, true)
	
	player2_assuper = true
	save_config_value(CFG_P2S, CFG_PS_ASSUPER, true)

func save_unlocks():
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	for i in range(char_count):
		var save_str = CFG_UNLOCK_COLOR4 + "_" + get_char_debug_name(i)
		config.set_value(CFG_UNLOCK, save_str, unlock_color4[i])
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_CHAR_DARKGOTO, unlock_char_darkgoto)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_STAGE_BLACKHOLE, unlock_stage_blackhole)
	config.save(CONFIG_FILE)

func save_records():
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	for i in range(char_count):
		var save_str = CFG_RECORD_ARCADE + "_" + get_char_debug_name(i)
		config.set_value(CFG_RECORD, save_str, record_arcade[i])
	config.save(CONFIG_FILE)

func get_char_instance(char_name):
	match char_name:
		global.CHAR.goto:
			return char_goto.instance()
		global.CHAR.yoyo:
			return char_yoyo.instance()
		global.CHAR.kero:
			return char_kero.instance()
		global.CHAR.time:
			return char_time.instance()
		global.CHAR.sword:
			return char_sword.instance()
		global.CHAR.slime:
			return char_slime.instance()
		global.CHAR.scythe:
			return char_scythe.instance()
		global.CHAR.darkgoto:
			return char_darkgoto.instance()
		_:
			return char_goto.instance()

func get_color_array_from_string_array(str_array):
	var color_array = []
	for i in range(str_array.size()):
		color_array.append(Color(str_array[i]))
	return color_array

func get_char_palette(char_name, palette_num):
	return get_color_array_from_string_array(get_char_palette_raw(char_name, palette_num))

func get_char_palette_raw(char_name, palette_num):
	var max_default_num = get_char_max_palette(char_name)
	var p = palette_num - max_default_num - 1
	if custom_palettes_enabled:
		max_default_num -= num_custom_palettes[char_name]
	var char_palette
	match char_name:
		CHAR.goto:
			match palette_num:
				-1:
					char_palette = ["000000", "65b7d5", "2d4f7b", \
									"912323", "551515", "191533", \
									"05040d", "2f2116", "150e07", \
									"b7b7b7", "848484", "bb9d87", \
									"775338", "000001", "66b7d5", \
									"2e4f7b", "d5ac65", "bb714f", \
									"ffffff"]
				0:
					char_palette = ["1c0b00", "cf9942", "874a29", \
									"26a684", "124d48", "1b6b15", \
									"093813", "0f2b2e", "09151a", \
									"b7b7b7", "848484", "bb9d87", \
									"775338", "000001", "66b7d5", \
									"2e4f7b", "d5ac65", "bb714f", \
									"ffffff"]
				1:
					char_palette = ["290b0b", "e388b4", "914369", \
									"21b833", "226329", "962121", \
									"5c1f19", "7d4622", "40210d", \
									"b7b7b7", "848484", "bb9d87", \
									"775338", "000001", "66b7d5", \
									"2e4f7b", "d5ac65", "bb714f", \
									"ffffff"]
				max_default_num:
					char_palette = ["000000", "e6e6e6", "888888", \
									"ff80aa", "ba344f", "b39779", \
									"63472e", "421b0d", "210c05", \
									"b7b7b7", "848484", "bb9d87", \
									"775338", "000001", "66b7d5", \
									"2e4f7b", "d5ac65", "bb714f", \
									"ffffff"]
		CHAR.yoyo:
			match palette_num:
				-1:
					char_palette = ["cc6c40", "ae4b31", "94ead3", \
									"58c2c8", "7baad5", "697abb", \
									"ea94d3", "e079e6", "e0fff7", \
									"eaca94", "d5a17b", "330f0f", \
									"d5784e", "a65a46", "7caad5", \
									"6a7abb"]
				0:
					char_palette = ["333333", "1a1a1a", "9f95e5", \
									"7958c7", "999999", "737373", \
									"cc845e", "de6304", "fefbff", \
									"eaca94", "d5a17b", "330f0f", \
									"d5784e", "a65a46", "7caad5", \
									"6a7abb"]
				1:
					char_palette = ["fff28c", "dbbf1f", "f54949", \
									"e60000", "f0f0f0", "d9d9d9", \
									"c47695", "eb75a4", "ff8c8c", \
									"eaca94", "d5a17b", "330f0f", \
									"d5784e", "a65a46", "7caad5", \
									"6a7abb"]
				max_default_num:
					char_palette = ["bd7d1e", "945b25", "403a3a", \
									"332b2b", "7399de", "4277c7", \
									"faff70", "f26b6b", "666161", \
									"eaca94", "d5a17b", "330f0f", \
									"d5784e", "a65a46", "7caad5", \
									"6a7abb"]
		CHAR.kero:
			match palette_num:
				-1:
					char_palette = ["56bb27", "33621d", "d02a16", \
									"cbd51e", "ffffff", "b3b3b3", \
									"484848", "dce17b", "85d561", \
									"ff82c4", "923870", "913870", \
									"5c276f", "621f5e", "c8ea6b", \
									"76a22d", "3c6f17"]
				0:
					char_palette = ["a8291b", "660500", "068f81", \
									"86ebdf", "000000", "bfb600", \
									"6b5206", "e8a184", "e66722", \
									"ff82c4", "923870", "913870", \
									"5c276f", "621f5e", "c8ea6b", \
									"76a22d", "3c6f17"]
				1:
					char_palette = ["a8934d", "5e5115", "00d13f", \
									"affa8e", "abffff", "4bcbf2", \
									"3e9bc9", "c4c382", "fbffa8", \
									"ff82c4", "913870", "913870", \
									"5c276f", "621f5e", "c8ea6b", \
									"76a22d", "3c6f17"]
				max_default_num:
					char_palette = ["4667eb", "2e3e8f", "ff2942", \
									"cbffc7", "f556e0", "f00088", \
									"d41176", "399ef7", "40ff96", \
									"ff82c4", "913870", "913870", \
									"5c276f", "621f5e", "c8ea6b", \
									"76a22d", "3c6f17"]
		CHAR.time:
			match palette_num:
				-1:
					char_palette = ["c33929", "b32616", "594442", \
									"402d2b", "ffd700", "fbe8b4", \
									"eebd86", "262121", "ffc400", \
									"b38506", "b70606", "f2f2f2"]
				0:
					char_palette = ["d1c515", "bd9100", "20076e", \
									"0a0029", "31b07f", "fbe8b4", \
									"eebd86", "262121", "ffc400", \
									"b38506", "b70606", "f2f2f2"]
				1:
					char_palette = ["e36a00", "bd4b13", "fafafa", \
									"b8b8b8", "8fa5ff", "fbe8b4", \
									"eebd86", "262121", "ffc400", \
									"b38506", "b70606", "f2f2f2"]
				max_default_num:
					char_palette = ["88ff00", "47c234", "f02929", \
									"b81414", "ffffff", "fbe8b4", \
									"eebd86", "262121", "ffc400", \
									"b38506", "b70606", "f2f2f2"]
		CHAR.sword:
			match palette_num:
				-1:
					char_palette = ["eaeaea", "c8c8c8", "0d0d0d", \
									"000000", "043318", "021904", \
									"f2ba7b", "ee9e64", "f23737", \
									"bf1729", "9d9d9d", "c01729", \
									"dddddd", "4d280d", "ccff94", \
									"97c051"]
				0:
					char_palette = ["2b2932", "14131a", "5d5c5e", \
									"4b4552", "ebeaca", "d1d1b0", \
									"f2ba7b", "ee9e64", "f23737", \
									"bf1729", "9d9d9d", "c01729", \
									"eaeaea", "222222", "bdf9ff", \
									"effcff"]
				1:
					char_palette = ["0f4b75", "002843", "1d1c1b", \
									"0d0c0a", "dae4ea", "bec5c9", \
									"f2ba7b", "ee9e64", "f23737", \
									"bf1729", "9d9d9d", "c01729", \
									"d3e8ea", "bb9103", "42c8ff", \
									"03529d"]
				max_default_num:
					char_palette = ["e3c100", "c49700", "d9d9d9", \
									"b3b3b3", "262626", "1a1a1a", \
									"f2ba7b", "ee9e64", "f23737", \
									"bf1729", "9d9d9d", "c01729", \
									"cccccc", "2f2f2f", "e1200b", \
									"620517"]
		CHAR.slime:
			match palette_num:
				-1:
					char_palette = ["fb84a8", "ee2462", "93b8ff", \
									"5257dd", "ffa9cc", "0fe10f", \
									"059505", "004417", "00e6f2", \
									"007299", "c956ff", "a419b7", \
									"8c8c8c"]
				0:
					char_palette = ["64ed5f", "2a9e24", "e5ebb5", \
									"b2ae76", "a3ff78", "ffde24", \
									"e6b800", "b88a00", "ff924f", \
									"e85500", "ff4d6a", "e30b33", \
									"8c8c8c"]
				1:
					char_palette = ["c0c0d3", "69698a", "ffe169", \
									"ba922d", "e0e9ff", "2e96ff", \
									"3468d9", "0f46bd", "3ddbff", \
									"007cad", "70fff1", "00ad9c", \
									"8c8c8c"]
				max_default_num:
					char_palette = ["f2f2ed", "706f67", "303133", \
									"ff0000", "ff91bf", "ff3b76", \
									"de214a", "a10025", "f2f250", \
									"949422", "4aa4ff", "126fcc", \
									"8c8c8c"]
		CHAR.scythe:
			match palette_num:
				-1:
					char_palette = ["ff95a0", "e16d90", "c46565", \
									"8c3849", "214a55", "11232a", \
									"3b3535", "1e1e1e", "fbeaea", \
									"e1a5b1", "372f2f", "a2ddb4", \
									"ffccdb", "f2dac2", "d4a483", \
									"ee234c", "591d23", "191516"]
				0:
					char_palette = ["eedea9", "e6c659", "3faa69", \
									"206228", "215424", "112916", \
									"e6ffe7", "92dd59", "f3fbf3", \
									"9fe67a", "372f2f", "a63053", \
									"ffb8cd", "f7d7b7", "e1b295", \
									"ee234c", "591d23", "191516"]
				1:
					char_palette = ["554a4b", "261f22", "4c2caa", \
									"191462", "3d404a", "1a1d21", \
									"443120", "221915", "c6a1ee", \
									"8e62e1", "372f2f", "1a143b", \
									"e87b7b", "e5bd98", "bf7d63", \
									"ee234c", "591d23", "191516"]
				max_default_num:
					char_palette = ["c8c6a1", "aea984", "332e2e", \
									"111010", "841111", "4d0420", \
									"f0f2ee", "bec4ba", "cdddc4", \
									"527343", "372f2f", "c7d6f7", \
									"e6bdd8", "f2cdbc", "dda496", \
									"ee234c", "591d23", "191516"]
		CHAR.darkgoto:
			match palette_num:
				-1:
					char_palette = ["130b26", "020508", "718471", \
									"42513e", "2f2116", "150e07", \
									"912323", "551515", "feffff", \
									"b7b7b7", "848484", "111010", \
									"000000", "ff0000", "d18ed4", \
									"5e1c4d", "dd5151", "9d2973", \
									"ffffff"]
				0:
					char_palette = ["f0d526", "826a33", "9c7149", \
									"5e3f23", "664c49", "452a27", \
									"73ff00", "33ad11", "fbffcc", \
									"b7b7b7", "848484", "111010", \
									"000000", "ff0000", "d18ed4", \
									"5e1c4d", "dd5151", "9d2973", \
									"ffffff"]
				1:
					char_palette = ["00ff88", "16a85d", "fffeeb", \
									"c2c0a1", "868b9e", "3f434f", \
									"ff4f7b", "a81638", "feffff", \
									"b7b7b7", "848484", "111010", \
									"000000", "ff0000", "d18ed4", \
									"5e1c4d", "dd5151", "9d2973", \
									"ffffff"]
				max_default_num:
					char_palette = ["ff7700", "a14b00", "404040", \
									"262626", "826835", "59491f", \
									"a22fcc", "591d78", "ebccff", \
									"b7b7b7", "848484", "111010", \
									"000000", "ff0000", "d18ed4", \
									"5e1c4d", "dd5151", "9d2973", \
									"ffffff"]
		_:
			return []
	if char_palette == null:
		char_palette = palette_custom[char_name][p]
	return char_palette

func get_char_default_palette(char_name):
	return get_char_palette_raw(char_name, -1)

func get_char_max_palette(char_name):
	var palette_count = -1
	if CHAR.has(get_char_debug_name(char_name)) and char_name < char_count and unlock_color4[char_name]:
		palette_count += num_default_palettes - 1
	else:
		palette_count += num_default_palettes - 2
	if custom_palettes_enabled and char_name < char_count:
		palette_count += num_custom_palettes[char_name]
	return palette_count

func get_char_debug_name(char_name):
	match char_name:
		CHAR.goto:
			return "goto"
		CHAR.yoyo:
			return "yoyo"
		CHAR.kero:
			return "kero"
		CHAR.time:
			return "time"
		CHAR.sword:
			return "sword"
		CHAR.slime:
			return "slime"
		CHAR.scythe:
			return "scythe"
		CHAR.darkgoto:
			return "darkgoto"
		CHAR.random:
			return "random"
		CHAR.locked:
			return "locked"
		_:
			return "goto"

func get_char_real_name(char_name):
	match char_name:
		CHAR.goto:
			return "Shoto Goto"
		CHAR.yoyo:
			return "Yo-Yona"
		CHAR.kero:
			return "Dr. Kero"
		CHAR.time:
			return "Don McRon"
		CHAR.sword:
			return "Vince Volt"
		CHAR.slime:
			return "Slime Bros."
		CHAR.scythe:
			return "Reaper Angel"
		CHAR.darkgoto:
			return "Dark Goto"
		CHAR.random:
			return "RANDOM"
		CHAR.locked, _:
			return "???"

func get_char_short_name(char_name):
	match char_name:
		CHAR.scythe:
			return "Rpr. Angel"
		_:
			return get_char_real_name(char_name)

func get_char_stage(char_name):
	match char_name:
		CHAR.goto:
			return STAGE.dojo
		CHAR.yoyo:
			return STAGE.rooftop
		CHAR.kero:
			return STAGE.lab
		CHAR.time:
			return STAGE.company
		CHAR.sword:
			return STAGE.bridge
		CHAR.slime:
			return STAGE.factory
		CHAR.scythe:
			return STAGE.sanctuary
		CHAR.darkgoto:
			return STAGE.blackhole
		_:
			return STAGE.dojo

func get_stage_debug_name(stage_name):
	match stage_name:
		STAGE.dojo:
			return "dojo"
		STAGE.rooftop:
			return "rooftop"
		STAGE.lab:
			return "lab"
		STAGE.company:
			return "company"
		STAGE.bridge:
			return "bridge"
		STAGE.factory:
			return "factory"
		STAGE.sanctuary:
			return "sanctuary"
		STAGE.blackhole:
			return "blackhole"
		STAGE.training:
			return "training"
		STAGE.random:
			return "random"
		STAGE.locked:
			return "locked"
		_:
			return "dojo"

func get_stage_real_name(stage_name):
	match stage_name:
		STAGE.dojo:
			return "Afternoon Dojo"
		STAGE.rooftop:
			return "School Rooftop"
		STAGE.lab:
			return "Underground Lab"
		STAGE.company:
			return "DonCorp"
		STAGE.bridge:
			return "Sunset Bridge"
		STAGE.factory:
			return "Factory 51"
		STAGE.sanctuary:
			return "Celestial Lake"
		STAGE.blackhole:
			return "The Singularity"
		STAGE.training:
			return "Training (Beta)"
		STAGE.random:
			return "RANDOM"
		STAGE.locked, _:
			return "???"

func get_curr_char(player_num):
	if player_num == 1:
		return player1_char
	else:
		return player2_char

func get_random_char():
	var chars = []
	for i in range(char_count):
		chars.append(i)
	if not unlock_char_darkgoto:
		chars.erase(CHAR.darkgoto)
	var r = randi() % chars.size()
	return chars[r]

func get_random_stage():
	var stages = []
	for i in range(stage_count):
		stages.append(i)
	if not unlock_stage_blackhole:
		stages.erase(STAGE.blackhole)
	stages.erase(STAGE.training)
	var r = randi() % stages.size()
	return stages[r]

func get_char_random_palette(char_name):
	var palettes = get_char_max_palette(char_name) + 2
	var r = randi() % palettes - 1
	return r

func set_char(char_name, palette_num, player_num):
	if palette_num > get_char_max_palette(char_name):
		palette_num = -1
	if player_num == 1:
		if char_name == CHAR.random:
			player1_char = get_random_char()
			player1_palette = get_char_random_palette(player1_char)
		else:
			player1_char = char_name
			player1_palette = palette_num
	else:
		if char_name == CHAR.random:
			player2_char = get_random_char()
			player2_palette = get_char_random_palette(player2_char)
		else:
			player2_char = char_name
			player2_palette = palette_num

func set_stage(stage_name):
	if stage_name == STAGE.random:
		stage = get_random_stage()
	else:
		stage = stage_name

func set_palette(palette_num, player_num):
	if player_num == 1:
		if palette_num > get_char_max_palette(player1_char):
			palette_num = -1
		player1_palette = palette_num
	else:
		if palette_num > get_char_max_palette(player2_char):
			palette_num = -1
		player2_palette = palette_num

func differ_palettes():
	if player1_char == player2_char and player1_palette == player2_palette:
		if player1_palette == -1:
			player2_palette = 0
		else:
			player2_palette = -1

func init_p1_vs_p2():
	mode = MODE.versus_player
	online = false
	player1_cpu = false
	player2_cpu = false

func init_p1_vs_cpu():
	mode = MODE.versus_cpu
	online = false
	player1_cpu = false
	player2_cpu = true

func init_cpu_vs_cpu():
	mode = MODE.versus_cpu
	online = false
	player1_cpu = true
	player2_cpu = true

func init_online_lobby():
	mode = MODE.online_lobby
	online = true
	if online_cpu:
		player1_cpu = true
		player2_cpu = true
	else:
		player1_cpu = false
		player2_cpu = false
	lobby_join = false
	curr_lobby_id = 0
	stage = STAGE.dojo

func init_online_quickmatch(join):
	mode = MODE.online_quickmatch
	online = true
	player1_cpu = false
	player2_cpu = false
	lobby_join = join
	stage = STAGE.dojo

func init_online_lobby_join():
	mode = MODE.online_lobby
	online = true
	if online_cpu:
		player1_cpu = true
		player2_cpu = true
	else:
		player1_cpu = false
		player2_cpu = false
	lobby_join = true
	stage = STAGE.dojo

func init_arcade():
	mode = MODE.arcade
	online = false
	player1_cpu = false
	player2_cpu = true

func init_training():
	mode = MODE.training
	online = false
	player1_cpu = false
	player2_cpu = true

func init_tutorial():
	mode = MODE.tutorial
	online = false
	player1_cpu = false
	player2_cpu = true
	player1_char = CHAR.goto
	player1_palette = -1
	player2_char = CHAR.goto
	player2_palette = 0
	stage = STAGE.rooftop

func init_arcade_mode(char_name):
	arcade_stage = 0
	arcade_continues = 2
	arcade_time = 0
	arcade_chars = []
	for i in range(char_count):
		arcade_chars.append(i)
	var char_index = arcade_chars.find(char_name)
	if char_index >= 0:
		arcade_chars.remove(char_index)
	if player1_char == CHAR.darkgoto:
		arcade_chars.erase(CHAR.goto)
	else:
		arcade_chars.erase(CHAR.darkgoto)
	player2_palette = -1
	set_next_arcade_char()

func set_next_arcade_char():
	arcade_stage += 1
	if arcade_stage > max_arcade_stage:
		return false
	elif arcade_stage == max_arcade_stage or arcade_chars.size() < 0:
		if player1_char == CHAR.darkgoto:
			player2_char = CHAR.goto
		else:
			player2_char = CHAR.darkgoto
	else:
		var r = randi() % arcade_chars.size()
		player2_char = arcade_chars[r]
		arcade_chars.remove(r)
	stage = get_char_stage(player2_char)
	return true

func unlock_color4(char_name):
	if char_name < char_count:
		unlock_color4[char_name] = true
		save_unlocks()

func is_color4_unlocked(char_name):
	if char_name < char_count:
		return unlock_color4[char_name]
	else:
		return null

func unlock_char():
	var unlock_all_color4 = true
	for i in range(char_count):
		if not unlock_color4[i] and i != CHAR.darkgoto:
			unlock_all_color4 = false
			break
	if not unlock_char_darkgoto and unlock_all_color4:
		unlock_char_darkgoto = true
		save_unlocks()
		return CHAR.darkgoto
	return null

func unlock_stage():
	if player1_char == CHAR.darkgoto and not unlock_stage_blackhole:
		unlock_stage_blackhole = true
		save_unlocks()
		return STAGE.blackhole
	return null

func get_record_arcade(char_name):
	if char_name < char_count:
		return record_arcade[char_name]
	else:
		return null

func set_record_arcade(char_name, time):
	if char_name < char_count:
		record_arcade[char_name] = time
		save_records()

func set_material_palette(material, player_num):
	if material == null:
		return
	material.set_shader_param(SHADERPARAM_THRESHOLD, 0.001)
	
	var char_name = player1_char
	var palette_num = player1_palette
	if player_num != 1:
		char_name = player2_char
		palette_num = player2_palette
	if palette_num >= 0:
		var palette = get_char_palette(char_name, -1)
		if palette != null:
			for i in range(palette.size()):
				set_material_palette_color(material, palette[i], i, true)
		palette = get_char_palette(char_name, palette_num)
		if palette != null:
			for i in range(palette.size()):
				set_material_palette_color(material, palette[i], i, false)

func set_material_palette_color(material, palette_color, palette_num, default):
	if default:
		material.set_shader_param(SHADERPARAM_COLOR_ORIG + str(palette_num), palette_color)
	else:
		material.set_shader_param(SHADERPARAM_COLOR_NEW + str(palette_num), palette_color)

func send_lobby_chat_msg(msg):
	var name_msg = Steam.getPersonaName() + ": " + msg
	add_lobby_chat_msg(name_msg)
	var chat_str = global.LOBBY_MSG_CHAT + global.LOBBY_MSG_SEP_CHAR + name_msg
	Steam.sendLobbyChatMsg(curr_lobby_id, chat_str)

func add_lobby_chat_msg(msg):
	var time = OS.get_time()
	var time_str = "[%02d:%02d]" % [time["hour"], time["minute"]] + " "
	if not lobby_chat_msg.empty():
		lobby_chat_msg += "\n"
	lobby_chat_msg += time_str + msg

func join_requested(lobby_id, requester_id):
	lobby_found = false
	join_lobby(lobby_id, true)

func get_lobby_data(key):
	return Steam.getLobbyData(curr_lobby_id, key)

func get_lobby_member_data(user_id, key):
	return Steam.getLobbyMemberData(curr_lobby_id, user_id, key)

func set_lobby_data(key, value):
	if Steam.setLobbyData(curr_lobby_id, key, value):
		create_debug_text("Set lobby data " + key + " to " + value)

func set_lobby_member_data(key, value):
	Steam.setLobbyMemberData(curr_lobby_id, key, value)
	create_debug_text("Set lobby member data " + key + " to " + value)

func update_lobby_member_data():
	for i in range(8):
		if i < lobby_member_ids.size():
			set_lobby_data(LOBBY_PLAYER_ID + str(i + 1), str(lobby_member_ids[i]))
		else:
			set_lobby_data(LOBBY_PLAYER_ID + str(i + 1), "-1")
	update_lobby_ready_data()

func update_lobby_ready_data():
	for i in range(2):
		set_lobby_data(LOBBY_PLAYER_READY + str(i + 1), str(lobby_member_ready[i]))

func update_lobby_stage_data():
	if stage_select == STAGE_SELECT.random:
		stage = get_random_stage()
		set_lobby_data(LOBBY_STAGE, str(stage))

func get_lobby_stage_data():
	stage = int(get_lobby_data(LOBBY_STAGE))

func lobby_chat_update(lobby_id, user_id, change_user_id, chat_state):
	if lobby_join:
		match chat_state:
			0x0002, 0x0004:
				if user_id == host_member_id:
					create_info_text("Lobby was disbanded because host left.")
					leave_lobby(true)
	else:
		match chat_state:
			0x0001:
				create_debug_text("Lobby member joined.")
				if not lobby_member_ids.has(user_id):
					lobby_member_ids.append(user_id)
				update_lobby_member_data()
			0x0002, 0x0004:
				if chat_state == 0x0002:
					create_debug_text("Lobby member left.")
				else:
					create_debug_text("Lobby member disconnected.")
				var change_scene = false
				if (lobby_member_ids.size() >= 1 and user_id == lobby_member_ids[0]) or \
				   (lobby_member_ids.size() >= 2 and user_id == lobby_member_ids[1]):
					lobby_member_ready = [LOBBY_READY.not_ready, LOBBY_READY.not_ready]
					update_lobby_ready_data()
					change_scene = true
				lobby_member_ids.erase(user_id)
				spectator_member_ids.erase(user_id)
				update_lobby_member_data()
				if change_scene:
					broadcast_packet_lobby_return()
					if get_tree().get_current_scene().get_name() != "online_lobby":
						get_tree().change_scene(SCENE_ONLINE_LOBBY)

func lobby_data_update(success, lobby_id, user_id, key):
	if lobby_join and curr_lobby_id == lobby_id and Steam.getLobbyData(lobby_id, LOBBY_VERSION) != VERSION:
		create_info_text("Could not join lobby! Reason: Version mismatch.")
		leave_lobby(true)
	lobby_member_ids.clear()
	for i in range(8):
		var player_id = int(get_lobby_data(LOBBY_PLAYER_ID + str(i + 1)))
		if player_id >= 0:
			lobby_member_ids.append(player_id)
		else:
			break
	for i in range(2):
		lobby_member_ready[i] = int(get_lobby_data(LOBBY_PLAYER_READY + str(i + 1)))

func lobby_message(result, user_id, msg, type):
	var char_idx = msg.find(LOBBY_MSG_SEP_CHAR)
	var msg_data = msg.right(char_idx + 1)
	match msg.left(char_idx):
		LOBBY_MSG_TIMEOUT:
			if steam_id == int(msg_data):
				leave_lobby(true)
				create_info_text("Kicked from lobby! Reason: Timed out.")
		LOBBY_MSG_CHAT:
			if steam_id != user_id:
				add_lobby_chat_msg(msg_data)

func p2p_session_request(user_id):
	Steam.acceptP2PSessionWithUser(user_id)
	create_debug_text("Accepted P2P session with ID: " + str(user_id))

func p2p_session_connect_fail(user_id, reason):
	create_debug_text("Failed P2P session with ID: " + str(user_id))
	if lobby_join and lobby_member_ids.has(user_id):
		leave_lobby(true)
		create_info_text("Lobby left! Reason: Failed P2P session with another lobby member.")

func lobby_created(result, lobby_id):
	create_debug_text("Lobby created! ID: " + str(lobby_id))
	curr_lobby_id = lobby_id
	lobby_rotate = LOBBY_ROTATE.none
	set_lobby_data(LOBBY_VERSION, VERSION)
	set_lobby_data(LOBBY_NAME, host_name)
	set_lobby_data(LOBBY_PASSWORD, host_password)
	set_lobby_data(LOBBY_REMATCH_STYLE, str(host_rematch))
	set_lobby_data(LOBBY_ROTATION_STYLE, str(host_rotation))
	set_lobby_data(LOBBY_MATCH_LIMIT, str(host_match_limit))
	set_lobby_data(LOBBY_DELAY, str(host_delay))
	set_lobby_data(LOBBY_STAGE_SELECT, str(host_stage_select))
	set_lobby_data(LOBBY_CHAT, str(int(host_chat)))
	update_lobby_member_data()
	update_lobby_stage_data()

func lobby_joined(lobby_id, perm, locked, response):
	if response == 1:
		create_debug_text("Lobby joined! ID: " + str(lobby_id))
		curr_lobby_id = lobby_id
		lobby_chat_msg = ""
		host_member_id = Steam.getLobbyOwner(curr_lobby_id)
		input_delay = int(get_lobby_data(LOBBY_DELAY))
		stage_select = int(get_lobby_data(LOBBY_STAGE_SELECT))
		lobby_chat = bool(int(get_lobby_data(LOBBY_CHAT)))
		set_lobby_member_data(MEMBER_LOBBY_DTDASH, str(int(player1_dtdash)))
		set_lobby_member_data(MEMBER_LOBBY_ASSUPER, str(int(player1_assuper)))
		set_lobby_member_data(MEMBER_LOBBY_WINS, str(0))
		set_lobby_member_data(MEMBER_LOBBY_MATCHES, str(0))
		set_lobby_member_data(MEMBER_LOBBY_SKIP, str(0))
		set_lobby_member_data(MEMBER_LOBBY_CONSEC_MATCHES, str(0))
		if lobby_join:
			get_tree().change_scene(SCENE_ONLINE_LOBBY)
	elif response == 4:
		create_info_text("Could not join lobby! Reason: Lobby is full.")
	else:
		create_info_text("Could not join lobby! Reason: Unexpected error.")

func join_lobby(lobby_id, mode_lobby):
	create_info_text("Attempting to join lobby...")
	if curr_lobby_id == lobby_id:
		create_info_text("Could not join lobby! Reason: Already in this lobby.")
	else:
		Steam.joinLobby(lobby_id)
		if mode_lobby:
			init_online_lobby_join()

func leave_lobby(change_scene):
	if other_member_id > 0:
		if Steam.closeP2PSessionWithUser(other_member_id):
			create_debug_text("Closed P2P session with user ID: " + str(other_member_id))
		other_member_id = 0
	if curr_lobby_id > 0:
		Steam.leaveLobby(curr_lobby_id)
		create_debug_text("Left lobby ID: " + str(curr_lobby_id))
		curr_lobby_id = 0
		if change_scene:
			get_tree().change_scene(SCENE_MENU)

func broadcast_packet_lobby_return():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.lobby_return)
		broadcast_packet_all(packet)

func broadcast_packet_all(packet):
	if not lobby_join:
		for i in range(len(lobby_member_ids)):
			var user_id = lobby_member_ids[i]
			if user_id != steam_id:
				Steam.sendP2PPacket(user_id, packet, 2, 0)

func broadcast_packet(packet):
	if lobby_join:
		Steam.sendP2PPacket(other_member_id, packet, 2, 0)
		if other_member_id != host_member_id:
			Steam.sendP2PPacket(host_member_id, packet, 2, 0)
	else:
		if not lobby_state == LOBBY_STATE.spectate:
			Steam.sendP2PPacket(other_member_id, packet, 2, 0)
		relay_packet(packet)

func relay_packet(packet):
	for i in range(len(spectator_member_ids)):
		var user_id = spectator_member_ids[i]
		if user_id != steam_id:
			Steam.sendP2PPacket(user_id, packet, 2, 0)

func empty_packet_stream():
	var packet_size = Steam.getAvailableP2PPacketSize(0)
	while packet_size > 0:
		var packet_dict = Steam.readP2PPacket(packet_size, 0)
		packet_size = Steam.getAvailableP2PPacketSize(0)

func clear_input_files():
	var dir = Directory.new()
	dir.remove("user://player1.txt")
	dir.remove("user://player2.txt")
	dir.remove("user://player12.txt")
	dir.remove("user://player22.txt")

func save_player1_input(frame, data):
	var file = File.new()
	var file_name = "user://player1.txt"
	if lobby_join:
		file_name = "user://player12.txt"
	if file.file_exists(file_name):
		file.open(file_name, File.READ_WRITE)
		file.seek_end()
	else:
		file.open(file_name, File.WRITE)
	file.store_line(str(frame) + to_json(data))
	file.close()

func save_player2_input(frame, data):
	var file = File.new()
	var file_name = "user://player2.txt"
	if lobby_join:
		file_name = "user://player22.txt"
	if file.file_exists(file_name):
		file.open(file_name, File.READ_WRITE)
		file.seek_end()
	else:
		file.open(file_name, File.WRITE)
	file.store_line(str(frame) + to_json(data))
	file.close()

func is_christmas(player_num):
	var date = OS.get_date()
	return date["month"] == 12 and date["day"] >= 18 and date["day"] <= 31 and unlock_color4[CHAR.time] and \
		   ((player_num == 1 and player1_char == CHAR.time and player1_palette == 2) or
			(player_num == 2 and player2_char == CHAR.time and player2_palette == 2))

func is_april_fools():
	var date = OS.get_date()
	return date["month"] == 4 and date["day"] == 1
