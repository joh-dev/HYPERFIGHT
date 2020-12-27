extends Projectile

var curr_frame = 0

func _ready():
	hitbox.set_monitoring(true)
	knockback = Vector2(50, -250)
	effect_hit = preload("res://scenes/effect/sword/hit.tscn")
	destroy_on_char_hit = false
	destroy_on_proj_hit = false
	destroy_on_superproj_hit = false
	can_suck = false
	effect_on_player = true
	effect_on_proj = true

func set_length(length):
	sprite.region_rect.size.x = abs(length)
	hitbox.rect_size.x = abs(length)
	sprite.scale.x = sign(length)

func reflect(hitbox_owner):
	change_players(hitbox_owner)

func process_move():
	curr_frame += 0.4
	sprite.region_rect.position.x = 256 * floor(curr_frame)
	if self.curr_frame > 4:
		destroy_no_effect()
	
	.process_move()
