class_name ChildHitbox
extends Hitbox

func get_hitbox_owner():
	if hitbox_owner == null:
		set_hitbox_owner(get_parent().get_hitbox_owner())
	return hitbox_owner

func get_transform_owner():
	if transform_owner == null:
		set_transform_owner(get_parent().get_transform_owner())
	return transform_owner
