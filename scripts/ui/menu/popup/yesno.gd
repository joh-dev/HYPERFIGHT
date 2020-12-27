extends Sprite

var select_timer = -1
var max_select_timer = 30
var inactive_y = 150
var move_factor = 4
var orig_pos
var active_label = label_yes
var active = false
var curr_anim = "yes"

onready var menu_parent = get_parent()
onready var label_yes = get_node("label_yes")
onready var label_no = get_node("label_no")
onready var label_text = get_node("label_text")
onready var anim_player = get_node("AnimationPlayer")

func _ready():
	visible = true
	orig_pos = position
	position = Vector2(orig_pos.x, orig_pos.y + inactive_y)
	anim_player.play(curr_anim)

func _process(delta):
	if active:
		position = Vector2(orig_pos.x, position.y + (orig_pos.y - position.y) / move_factor * (global.fps * delta))
		if curr_anim == "none":
			curr_anim = "yes"
			anim_player.play(curr_anim)
		
		if select_timer > 0:
			select_timer -= 1 * (global.fps * delta)
			if select_timer <= 0:
				active = false
				if frame <= 2:
					menu_parent.back()
			var temp = int(select_timer / 3)
			if temp % 2 == 0:
				active_label.visible = true
			else:
				active_label.visible = false
		else:
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_LEFT) or Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_RIGHT):
				if curr_anim == "yes":
					curr_anim = "no"
				else:
					curr_anim = "yes"
				anim_player.play(curr_anim)
			if frame <= 2:
				active_label = label_yes
				label_yes.add_color_override("font_color", Color(0.5, 1, 0.5))
				label_no.add_color_override("font_color", Color(1, 1, 1))
			else:
				active_label = label_no
				label_no.add_color_override("font_color", Color(0.5, 1, 0.5))
				label_yes.add_color_override("font_color", Color(1, 1, 1))
				
			if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_ATTACK):
				select_timer = max_select_timer
				menu_parent.play_audio(menu_parent.snd_select2)
	else:
		position = Vector2(orig_pos.x, position.y + (orig_pos.y + inactive_y - position.y) / move_factor * (global.fps * delta))
		curr_anim = "none"