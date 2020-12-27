class_name Hitbox
extends ReferenceRect

export var monitoring = false
export var flip_with_scale = true

var hitbox_owner
var transform_owner
var attacking = false

func _ready():
	monitoring = false

func _physics_process(delta):
	update()

func get_hitbox():
	var global_origin = rect_global_position - rect_position
	var hitbox = get_rect()
	if flip_with_scale:
		var owner_scale_x = get_transform_owner().get_scale().x
		if owner_scale_x < 0:
			hitbox.position.x *= -1
			hitbox.position.x -= hitbox.size.x
	hitbox.position += global_origin
	return hitbox

func get_all_hitboxes():
	var hitboxes = []
	if monitoring:
		hitboxes.append(get_hitbox())
	for child in get_children():
		if child.is_monitoring():
			hitboxes.append(child.get_hitbox())
	return hitboxes

func intersects(other_hitbox):
	var hitboxes = get_all_hitboxes()
	for other_box in other_hitbox.get_all_hitboxes():
		for box in hitboxes:
			if box.intersects(other_box):
				return true
	return false

func get_hitbox_owner():
	if hitbox_owner == null:
		set_hitbox_owner(get_parent())
	return hitbox_owner

func get_transform_owner():
	if transform_owner == null:
		set_transform_owner(get_parent().sprite)
	return transform_owner

func is_monitoring():
	return monitoring

func set_hitbox_owner(hitbox_owner):
	self.hitbox_owner = hitbox_owner
	for child in get_children():
		child.set_hitbox_owner(hitbox_owner)

func set_transform_owner(transform_owner):
	self.transform_owner = transform_owner
	for child in get_children():
		child.set_transform_owner(transform_owner)

func set_monitoring(monitoring):
	self.monitoring = monitoring
	for child in get_children():
		child.set_monitoring(monitoring)

func set_attacking(attacking):
	self.attacking = attacking
	for child in get_children():
		child.set_attacking(attacking)

func _draw():
	if global.show_hitboxes and monitoring:
		var hitbox = get_hitbox()
		hitbox.position -= rect_global_position
		if attacking:
			draw_rect(hitbox, Color.red, false)
		else:
			draw_rect(hitbox, Color.blue, false)
