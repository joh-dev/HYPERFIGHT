extends Projectile

func _ready():
	knockback = Vector2(100, -250)
	effect_hit = preload("res://scenes/effect/yoyo/proj/special_hit.tscn")
	destroy_on_char_hit = false
	destroy_on_char_parry = false
	destroy_on_proj_hit = false
	destroy_on_superproj_hit = false
	knockback_depend_on_player_pos = true
	effect_on_player = true
	can_suck = false

func reflect(hitbox_owner):
	change_players(hitbox_owner)

func on_anim_finished(anim_name):
	destroy_no_effect()
