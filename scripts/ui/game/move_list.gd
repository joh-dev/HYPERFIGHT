extends Sprite

export var player1 = true

var max_pages = 4
var curr_page = 1

onready var char_spr = get_node("char_spr")
onready var label_char = get_node("label_char")
onready var label_move = get_node("label_move")
onready var label_desc = get_node("label_desc")
onready var label_command = get_node("label_command")
onready var label_page = get_node("label_page")
onready var arrow_left = get_node("arrow_left")
onready var arrow_right = get_node("arrow_right")
onready var game = get_parent().get_parent().get_parent()

onready var p2_texture = preload("res://graphics/ui/game/move_list/border_p2.png")

onready var goto_attack = preload("res://graphics/ui/game/move_list/goto/attack.png")
onready var goto_attack_down = preload("res://graphics/ui/game/move_list/goto/attack_down.png")
onready var goto_special = preload("res://graphics/ui/game/move_list/goto/special.png")
onready var goto_super = preload("res://graphics/ui/game/move_list/goto/super.png")

onready var yoyo_attack = preload("res://graphics/ui/game/move_list/yoyo/attack.png")
onready var yoyo_attack_hold = preload("res://graphics/ui/game/move_list/yoyo/attack_hold.png")
onready var yoyo_special = preload("res://graphics/ui/game/move_list/yoyo/special.png")
onready var yoyo_special_hold = preload("res://graphics/ui/game/move_list/yoyo/special_hold.png")
onready var yoyo_super = preload("res://graphics/ui/game/move_list/yoyo/super.png")

onready var kero_attack = preload("res://graphics/ui/game/move_list/kero/attack.png")
onready var kero_attack_air = preload("res://graphics/ui/game/move_list/kero/attack_air.png")
onready var kero_attack_down = preload("res://graphics/ui/game/move_list/kero/attack_down.png")
onready var kero_special = preload("res://graphics/ui/game/move_list/kero/special.png")
onready var kero_special_spit = preload("res://graphics/ui/game/move_list/kero/special_spit.png")
onready var kero_special_swallow = preload("res://graphics/ui/game/move_list/kero/special_swallow.png")
onready var kero_super = preload("res://graphics/ui/game/move_list/kero/super.png")

onready var time_attack_short = preload("res://graphics/ui/game/move_list/time/attack_short.png")
onready var time_attack = preload("res://graphics/ui/game/move_list/time/attack.png")
onready var time_attack_down = preload("res://graphics/ui/game/move_list/time/attack_down.png")
onready var time_special = preload("res://graphics/ui/game/move_list/time/special.png")
onready var time_super = preload("res://graphics/ui/game/move_list/time/super.png")

onready var sword_attack = preload("res://graphics/ui/game/move_list/sword/attack.png")
onready var sword_attack_buffed = preload("res://graphics/ui/game/move_list/sword/attack_buffed.png")
onready var sword_teleport = preload("res://graphics/ui/game/move_list/sword/teleport.png")
onready var sword_attack_down = preload("res://graphics/ui/game/move_list/sword/attack_down.png")
onready var sword_attack_down_buffed = preload("res://graphics/ui/game/move_list/sword/attack_down_buffed.png")
onready var sword_special = preload("res://graphics/ui/game/move_list/sword/special.png")
onready var sword_super = preload("res://graphics/ui/game/move_list/sword/super.png")
onready var sword_super_buffed = preload("res://graphics/ui/game/move_list/sword/super_buffed.png")

onready var slime_attack = preload("res://graphics/ui/game/move_list/slime/attack.png")
onready var slime_attack_down = preload("res://graphics/ui/game/move_list/slime/attack_down.png")
onready var slime_blue_attack_down = preload("res://graphics/ui/game/move_list/slime/blue_attack_down.png")
onready var slime_special = preload("res://graphics/ui/game/move_list/slime/special.png")
onready var slime_special_switch = preload("res://graphics/ui/game/move_list/slime/special_switch.png")
onready var slime_special_revive = preload("res://graphics/ui/game/move_list/slime/special_revive.png")
onready var slime_super = preload("res://graphics/ui/game/move_list/slime/super.png")

onready var scythe_ability_meter = preload("res://graphics/ui/game/move_list/scythe/ability_meter.png")
onready var scythe_ability_cancel = preload("res://graphics/ui/game/move_list/scythe/ability_cancel.png")
onready var scythe_attack = preload("res://graphics/ui/game/move_list/scythe/attack.png")
onready var scythe_attack_down = preload("res://graphics/ui/game/move_list/scythe/attack_down.png")
onready var scythe_attack_back = preload("res://graphics/ui/game/move_list/scythe/attack_back.png")
onready var scythe_special = preload("res://graphics/ui/game/move_list/scythe/special.png")
onready var scythe_special_teleport = preload("res://graphics/ui/game/move_list/scythe/special_teleport.png")
onready var scythe_super = preload("res://graphics/ui/game/move_list/scythe/super.png")
onready var scythe_super_charged = preload("res://graphics/ui/game/move_list/scythe/super_charged.png")

onready var darkgoto_ability = preload("res://graphics/ui/game/move_list/darkgoto/ability.png")
onready var darkgoto_attack = preload("res://graphics/ui/game/move_list/darkgoto/attack.png")
onready var darkgoto_attack_down = preload("res://graphics/ui/game/move_list/darkgoto/attack_down.png")
onready var darkgoto_special = preload("res://graphics/ui/game/move_list/darkgoto/special.png")
onready var darkgoto_super = preload("res://graphics/ui/game/move_list/darkgoto/super.png")

func _ready():
	var player_char = global.player1_char
	if not player1:
		player_char = global.player2_char
		texture = p2_texture
		label_char.add_color_override("font_color", Color(0, 0.5, 1))
		label_move.add_color_override("font_color", Color(0.5, 0.75, 1))
		label_command.add_color_override("font_color", Color(0.5, 0.75, 1))
		arrow_left.set_modulate(Color(0.5, 0.75, 1))
		arrow_right.set_modulate(Color(0.5, 0.75, 1))
		if global.player2_cpu:
			visible = false
	match player_char:
		global.CHAR.yoyo:
			max_pages = 5
		global.CHAR.kero:
			max_pages = 8
		global.CHAR.time:
			max_pages = 5
		global.CHAR.sword:
			max_pages = 8
		global.CHAR.slime:
			max_pages = 7
		global.CHAR.scythe:
			max_pages = 9
		global.CHAR.darkgoto:
			max_pages = 5
		_:
			max_pages = 4
	set_page()

func _process(delta):
	if game.show_move_lists():
		if player1:
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_LEFT):
				curr_page -= 1
				if curr_page < 1:
					curr_page = 1
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_RIGHT):
				curr_page += 1
				if curr_page > max_pages:
					curr_page = max_pages
		else:
			if Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_LEFT):
				curr_page -= 1
				if curr_page < 1:
					curr_page = 1
			if Input.is_action_just_pressed(global.INPUT_PLAYER2 + global.INPUT_ACTION_RIGHT):
				curr_page += 1
				if curr_page > max_pages:
					curr_page = max_pages
		set_page()

func set_page():
	var curr_char = global.player1_char
	if not player1:
		curr_char = global.player2_char
	var move_text = ""
	var desc_text = ""
	var command_text = ""
	arrow_left.visible = true
	arrow_right.visible = true
	if curr_page == 1:
		arrow_left.visible = false
	elif curr_page == max_pages:
		arrow_right.visible = false
	
	match curr_char:
		global.CHAR.goto:
			match curr_page:
				1:
					char_spr.texture = goto_attack
					move_text = "Blazing Sun"
					desc_text = "Can be angled by holding UP/DOWN before shot."
					command_text = "ATTACK"
				2:
					char_spr.texture = goto_attack_down
					move_text = "Rising Fist"
					desc_text = "Close uppercut. Can perform in air."
					command_text = "DOWN + ATK"
				3:
					char_spr.texture = goto_special
					move_text = "Parry"
					desc_text = "Gain point back and red point if landed."
					command_text = "SPECIAL"
				4:
					char_spr.texture = goto_super
					move_text = "Super Shoto Attack"
					desc_text = "Large fireball.\nCan be angled UP/DOWN."
					command_text = "SUPER"
		global.CHAR.yoyo:
			match curr_page:
				1:
					char_spr.texture = yoyo_attack
					move_text = "Yo-yo Attack"
					desc_text = "Can angle in any dir. Stuns you on contact with proj."
					command_text = "ATTACK"
				2:
					char_spr.texture = yoyo_attack_hold
					move_text = "Yo-yo Reel"
					desc_text = "When anchored: reel in towards yo-yo."
					command_text = "ATTACK"
				3:
					char_spr.texture = yoyo_special
					move_text = "Yo-yo Anchor"
					desc_text = "No points needed. Anchor yo-yo in place."
					command_text = "SPECIAL"
				4:
					char_spr.texture = yoyo_special_hold
					move_text = "Remote Blast"
					desc_text = "When anchored: explodes yo-yo in small blast."
					command_text = "SPECIAL"
				5:
					char_spr.texture = yoyo_super
					move_text = "Super Yo-yo"
					desc_text = "Large yo-yo. Can be angled\nin any direction."
					command_text = "SUPER"
		global.CHAR.kero:
			match curr_page:
				1:
					char_spr.texture = kero_attack
					move_text = "Flying Kick (Grnd)"
					desc_text = "Kick forward til object or edge of stage is hit."
					command_text = "ATTACK"
				2:
					char_spr.texture = kero_attack_air
					move_text = "Flying Kick (Air)"
					desc_text = "Kick diagonally downward til object or floor is hit."
					command_text = "ATTACK"
				3:
					char_spr.texture = kero_attack_down
					move_text = "Gravity Ball"
					desc_text = "Stays btwn rounds, can kick. Re-\ncharge 1/sec."
					command_text = "DOWN + ATK"
				4:
					char_spr.texture = kero_special
					move_text = "Tongue Shot"
					desc_text = "No hitbox. Sucks in most proj. including supers."
					command_text = "SPECIAL"
				5:
					char_spr.texture = kero_special_swallow
					move_text = "Swallow"
					desc_text = "W/ suck: gain 1 red pt. (2 for supers). No pts needed."
					command_text = "SPECIAL"
				6:
					char_spr.texture = kero_special_spit
					move_text = "Spit Back"
					desc_text = "W/ suck: spit out proj. at opposite velocity."
					command_text = "DOWN + SPC"
				7:
					char_spr.texture = kero_super
					move_text = "Trap Ball"
					desc_text = "No gravity, bounces along walls. Can be kicked."
					command_text = "SUPER"
				8:
					char_spr.texture = kero_special_swallow
					move_text = "Super Swallow"
					desc_text = "W/ suck: gain 2 red pts. (3 for supers). 1 pt. used."
					command_text = "SUPER"
		global.CHAR.time:
			match curr_page:
				1:
					char_spr.texture = time_attack_short
					move_text = "Taste Ketchup"
					desc_text = "Change trajectory with LEFT/RIGHT."
					command_text = "ATTACK"
				2:
					char_spr.texture = time_attack
					move_text = "Taste Fries"
					desc_text = "Fast projectile. Angle with UP/DOWN."
					command_text = "ATK (HOLD)"
				3:
					char_spr.texture = time_attack_down
					move_text = "Slider"
					desc_text = "Only works grounded. Forward slide\nattack."
					command_text = "DOWN + ATK"
				4:
					char_spr.texture = time_special
					move_text = "Slamburger"
					desc_text = "Teleports up, slams down. Keeps horiz. momentum."
					command_text = "SPECIAL"
				5:
					char_spr.texture = time_super
					move_text = "Clock Out"
					desc_text = "Stop time (hold for longer).\nNot an instant win."
					command_text = "SUPER"
		global.CHAR.sword:
			match curr_page:
				1:
					char_spr.texture = sword_attack
					move_text = "Piercing Stab"
					desc_text = "Time button release to extend distance."
					command_text = "ATTACK"
				2:
					char_spr.texture = sword_attack_buffed
					move_text = "Piercing Stab+"
					desc_text = "When buffed: teleports and creates trail hitbox."
					command_text = "ATTACK"
				3:
					char_spr.texture = sword_teleport
					move_text = "Teleport"
					desc_text = "Can do\nonce while charging Piercing Stab."
					command_text = "ANY DIR."
				4:
					char_spr.texture = sword_attack_down
					move_text = "Rolling Slice"
					desc_text = "Only works grounded. LEFT/RIGHT changes momentum."
					command_text = "DOWN + ATK"
				5:
					char_spr.texture = sword_attack_down_buffed
					move_text = "Rolling Slice+"
					desc_text = "When buffed: move further, destroy projectiles."
					command_text = "DOWN + ATK"
				6:
					char_spr.texture = sword_special
					move_text = "Volt Charge"
					desc_text = "Buffs Piercing Stab or Rolling Slice once."
					command_text = "SPECIAL"
				7:
					char_spr.texture = sword_super
					move_text = "Thunderbolt-V"
					desc_text = "Three fast vertical bolts that span stage height."
					command_text = "SUPER"
				8:
					char_spr.texture = sword_super_buffed
					move_text = "Thunderbolt-H"
					desc_text = "When buffed: horizontal bolt that spans stage width."
					command_text = "SUPER"
		global.CHAR.slime:
			match curr_page:
				1:
					char_spr.texture = slime_attack
					move_text = "Tackle"
					desc_text = "Lunge forward with a full-body attack."
					command_text = "ATTACK"
				2:
					char_spr.texture = slime_attack_down
					move_text = "Hammer Fist"
					desc_text = "Fused/Pink only. Hitbox lasts until landing."
					command_text = "DOWN + ATK"
				3:
					char_spr.texture = slime_blue_attack_down
					move_text = "Jelly Cannon"
					desc_text = "Blue only. Throw a slow arcing projectile."
					command_text = "DOWN + ATK"
				4:
					char_spr.texture = slime_special
					move_text = "Split Shot"
					desc_text = "Fused only. Split into Pink/Blue with a tackle."
					command_text = "SPECIAL"
				5:
					char_spr.texture = slime_special_switch
					move_text = "Control Switch"
					desc_text = "Pink/Blue only if Blue is alive. No pts needed."
					command_text = "SPECIAL"
				6:
					char_spr.texture = slime_special_revive
					move_text = "Revive"
					desc_text = "Pink only if Blue is dead. Revives Blue."
					command_text = "SPECIAL"
				7:
					char_spr.texture = slime_super
					move_text = "Fuse Crash"
					desc_text = "Creates explosion. If split, create on both and refuse."
					command_text = "SUPER"
		global.CHAR.scythe:
			match curr_page:
				1:
					char_spr.texture = scythe_ability_meter
					move_text = "Soul Meter"
					desc_text = "Gain meter from KOs, destroying projs., or Overdrive."
					command_text = "ABILITY"
				2:
					char_spr.texture = scythe_ability_cancel
					move_text = "Force Cancel"
					desc_text = "Use 1 meter to cancel into any attack."
					command_text = "ABILITY"
				3:
					char_spr.texture = scythe_attack
					move_text = "Soul Slice"
					desc_text = "Forward slash. Can destroy normal prjs. for meter."
					command_text = "ATTACK"
				4:
					char_spr.texture = scythe_attack_down
					move_text = "Crescent Moon"
					desc_text = "Hold ATK to delay. Can destroy normal prjs. for meter."
					command_text = "DOWN + ATK"
				5:
					char_spr.texture = scythe_attack_back
					move_text = "Backstep"
					desc_text = "Quickly move backwards."
					command_text = "BACK + ATK"
				6:
					char_spr.texture = scythe_special
					move_text = "Place Portal"
					desc_text = "Can consume normal prjs. for meter and remain."
					command_text = "SPECIAL"
				7:
					char_spr.texture = scythe_special_teleport
					move_text = "Vanish"
					desc_text = "W/ portal: teleport to portal. No pts needed."
					command_text = "SPECIAL"
				8:
					char_spr.texture = scythe_super
					move_text = "Overdrive"
					desc_text = "Completely fill Soul Meter if not full."
					command_text = "SUPER"
				9:
					char_spr.texture = scythe_super_charged
					move_text = "Heavenrend"
					desc_text = "When Soul Meter full: create slash with inc. speed."
					command_text = "SUPER"
		global.CHAR.darkgoto:
			match curr_page:
				1:
					char_spr.texture = darkgoto_ability
					move_text = "Double Air Dash"
					desc_text = "Can dash twice in the air."
					command_text = "ABILITY"
				2:
					char_spr.texture = darkgoto_attack
					move_text = "Dark Sun"
					desc_text = "Diagonally upwards on ground, downwards in air."
					command_text = "ATTACK"
				3:
					char_spr.texture = darkgoto_attack_down
					move_text = "Vengeful Fist"
					desc_text = "Can perform in air. Further than Rising Fist."
					command_text = "DOWN + ATK"
				4:
					char_spr.texture = darkgoto_special
					move_text = "Reflect"
					desc_text = "Reflect non-super atks, gain point back + red point."
					command_text = "SPECIAL"
				5:
					char_spr.texture = darkgoto_super
					move_text = "Super Evil Attack"
					desc_text = "Trajectory like Dark Sun. Can dash cancel recovery."
					command_text = "SUPER"
	
	label_char.text = global.get_char_short_name(curr_char)
	label_move.text = move_text
	label_desc.text = desc_text
	label_command.text = command_text
	label_page.text = str(curr_page)
