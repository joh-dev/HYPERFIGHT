extends Projectile

var consumed_projs = []

onready var effect_hit_custom = preload("res://scenes/effect/scythe/proj/special_hit.tscn")
onready var effect_hit_meter_custom = preload("res://scenes/effect/scythe/proj/special_hit_meter.tscn")

func _ready():
	create_shadow(0, 0)
	collide_with_char = false
	destroy_on_proj_hit = false
	can_suck = false

func destroy_no_effect():
	if player.is_in_group(global.GROUP_CHAR_SCYTHE):
		player.curr_proj = null
	.destroy_no_effect()

func process_hitbox_proj_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if not consumed_projs.has(hitbox_owner.get_instance_id()):
		if hitbox_owner.is_in_group(global.GROUP_SUPERPROJ):
			create_effect(effect_hit_custom)
		else:
			player.inc_soul_meter()
			create_effect(effect_hit_meter_custom)
		consumed_projs.append(hitbox_owner.get_instance_id())
	
	.process_hitbox_proj_collision(hitbox, call_other)
