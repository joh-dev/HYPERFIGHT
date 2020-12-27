extends Sprite

var follow_object
var x_offset = 0
var y_offset = 59

func init(new_follow_object, new_x_offset, size):
	follow_object = new_follow_object
	x_offset = new_x_offset
	frame = size
	position = Vector2(follow_object.position.x + x_offset * follow_object.sprite.scale.x, y_offset)

func process(curr_frame, frame_delay):
	position = Vector2(follow_object.position.x + x_offset * follow_object.sprite.scale.x, y_offset)
	visible = follow_object.position.y < y_offset
