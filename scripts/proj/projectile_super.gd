class_name SuperProjectile
extends Projectile

func _ready():
	add_to_group(global.GROUP_SUPERPROJ)
	destroy_on_proj_hit = false
	destroy_on_char_parry = false
	can_reflect = false
