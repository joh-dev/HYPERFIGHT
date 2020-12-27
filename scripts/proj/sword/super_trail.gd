extends SuperProjectile

var curr_frame = 0
var can_create = false
var created = false
var proj_super_trail

func _ready():
	hitbox.set_monitoring(true)
	knockback = Vector2(100, -250)
	effect_hit = preload("res://scenes/effect/sword/hit.tscn")
	destroy_on_char_hit = false
	destroy_on_superproj_hit = false
	can_suck = false
	effect_on_player = true
	effect_on_proj = true

func set_length(length):
	sprite.region_rect.size.x = abs(length)
	if hitbox.rect_size.x > hitbox.rect_size.y:
		hitbox.rect_size.x = abs(length)
	else:
		hitbox.rect_size.y = abs(length)
	sprite.scale.x = sign(length)

func set_vertical(more, new_inst):
	position.y -= 128
	if sprite.scale.x > 0:
		sprite.rotation_degrees = 90
	else:
		sprite.rotation_degrees = 270
	hitbox.rect_position = Vector2(-10, 0)
	hitbox.rect_size = Vector2(20, 256)
	if more:
		can_create = true
		proj_super_trail = new_inst

func reflect(hitbox_owner):
	change_players(hitbox_owner)

func process_move():
	curr_frame += 0.5
	sprite.region_rect.position.x = 256 * floor(curr_frame)
	if self.curr_frame > 2 and can_create and not created:
		created = true
		var x_offset = 24
		for i in range(2):
			var p = create_projectile(proj_super_trail, Vector2(-x_offset + x_offset * i * 2, 128))
			p.set_length(256 * sprite.scale.x)
			p.set_vertical(false, null)
	if self.curr_frame > 4:
		destroy_no_effect()
	
	.process_move()
