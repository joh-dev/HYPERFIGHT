extends Sprite

var curr_frame_delay = 0
var mask_textures = []

onready var bg_inverted = get_node("bg_inverted")
onready var anim_player = get_node("AnimationPlayer")

func _ready():
	anim_player.playback_speed = 0
	anim_player.play(global.get_stage_debug_name(global.stage))
	if global.is_april_fools() and global.get_stage_debug_name(global.stage) == "dojo":
		anim_player.play("training")
	
	bg_inverted.texture = texture
	bg_inverted.hframes = hframes
	bg_inverted.visible = false

func set_inverted(inverted):
	bg_inverted.visible = inverted

func process(curr_frame, frame_delay):
	if curr_frame_delay <= 0:
		anim_player.seek(anim_player.current_animation_position + 1, true)
		curr_frame_delay = frame_delay
	else:
		curr_frame_delay -= 1
	bg_inverted.texture = texture

func inc_anim():
	anim_player.seek(anim_player.current_animation_position + 1, true)

func get_stage():
	return anim_player.current_animation

func set_stage(stage):
	anim_player.play(stage)
