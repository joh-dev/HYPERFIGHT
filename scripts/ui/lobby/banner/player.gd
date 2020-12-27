extends Sprite

var active = false

onready var label_name = get_node("label_name")
onready var label_skip = get_node("label_skip_node/label_skip")
onready var label_wins = get_node("label_wins_node/label_wins")
onready var avatar = get_node("avatar")

func set_name(new_name):
	label_name.text = new_name
	active = true

func set_win_ratio(wins, matches):
	if wins.empty() or matches.empty():
		label_wins.text = "0W/0"
	else:
		label_wins.text = wins + "W/" + matches

func set_skip(skip):
	label_skip.visible = bool(int(skip))

func set_avatar(img):
	var size = Steam.getImageSize(img)['width']
	var img_data = Steam.getImageRGBA(img)
	var avatar_img = Image.new()
	var avatar_tex = ImageTexture.new()
	
	avatar_img.create(size, size, false, Image.FORMAT_RGBAF)
	avatar_img.lock()
	for y in range(0, size):
		for x in range(0, size):
			var pixel = 4 * (x + y * size)
			var r = float(img_data['buffer'][pixel]) / 255
			var g = float(img_data['buffer'][pixel + 1]) / 255
			var b = float(img_data['buffer'][pixel + 2]) / 255
			var a = float(img_data['buffer'][pixel + 3]) / 255
			avatar_img.set_pixel(x, y, Color(r, g, b, a))
	avatar_img.unlock()

	avatar_tex.create_from_image(avatar_img)
	avatar.set_texture(avatar_tex)

func clear():
	label_name.text = ""
	label_wins.text = ""
	set_skip(false)
	avatar.set_texture(null)
	active = false

func disable():
	visible = false

func is_active():
	return active
