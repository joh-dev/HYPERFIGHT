extends Sprite

onready var label_news = get_node("label_news")
onready var label_page = get_node("label_page")
onready var arrow_left = get_node("arrow_left")
onready var arrow_right = get_node("arrow_right")
onready var button_steam = get_node("button_steam")
onready var button_discord = get_node("button_discord")

var max_pages = 9
var curr_page = 1

func _process(delta):
	if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_LEFT):
		curr_page -= 1
		if curr_page < 1:
			curr_page = 1
	if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_RIGHT):
		curr_page += 1
		if curr_page > max_pages:
			curr_page = max_pages
	set_page()

func set_page():
	var news_text = ""
	arrow_left.visible = true
	arrow_right.visible = true
	if curr_page == 1:
		arrow_left.visible = false
	elif curr_page == max_pages:
		arrow_right.visible = false
	match curr_page:
		1:
			news_text = "(12/25/20) v3.1 \"One More Final\" now available!\n\n" + \
						"Features:\n\n" + \
						"- New Reaper Angel super + more abilities\n" + \
						"- Option to disable Attack + Special shortcut\n" + \
						"- Timer on online char/stage select\n" + \
						"- Many bugfixes + small balance changes\n\n" + \
						"More details on Steam and Discord!"
		2:
			news_text = "(8/21/20) v3.0 \"Finale\" is now available!\n\n" + \
						"Features:\n\n" + \
						"- Two new characters: Slime Bros. and\n" + \
						"  Reaper Angel\n" + \
						"- Two new stages + music: Factory 51 and\n" + \
						"  Celestial Lake\n" + \
						"- Training Mode added to Solo Modes\n" + \
						"(Continued...)"
		3:
			news_text = "- Expanded custom color support, including\n" + \
						"  ability to recolor projectiles\n" + \
						"- Shoto Goto: Parry now works on supers\n" + \
						"- Yo-Yona: Can now Anchor without yo-yo out\n" + \
						"- Dr. Kero: Can now use Gravity Ball even\n" + \
						"  with a sucked projectile\n" + \
						"- Hitbox fixes and minor rebalancing\n" + \
						"- Plenty of bugfixes!\n\n" + \
						"More details on Steam and Discord!"
		4:
			news_text = "(2/26/20) v2.3 \"Party Time\" is now available!\n\n" + \
						"Features:\n\n" + \
						"- 8 player lobbies!!\n" + \
						"- Lobby rematch and rotation settings\n" + \
						"- Find Lobby feature (replacing Quick Match)\n" + \
						"- Keyword for finding private lobbies\n\n" + \
						"More details on Steam and Discord!"
		5:
			news_text = "(1/27/20) v2.2 \"Ignition\" is now available!\n\n" + \
						"Features:\n\n" + \
						"- Auto delay setting for Quick Match and\n" + \
						"  Friend Lobby\n" + \
						"- Millisecond counter for Arcade Mode times\n" + \
						"- Slight rebalancing and more bugfixes\n\n" + \
						"More details on Steam and Discord!"
		6:
			news_text = "(12/23/19) v2.1 \"Infinite\" is now available!\n\n" + \
						"Features:\n\n" + \
						"- Reworked collision system and hitboxes\n" + \
						"  (should eliminate network desyncs)\n" + \
						"- Shorter time between rounds\n" + \
						"- Increased dash recovery time\n" + \
						"- Rebalanced all characters\n" + \
						"(Continued...)"
		7:
			news_text = "- New moves for Dr. Kero: Tongue Shot,\n" + \
						"  Spit Back, Swallow, and Super Swallow\n" + \
						"- A Christmas secret! (lasts until Dec. 31st)\n" + \
						"- Plenty of bugfixes!\n\n" + \
						"More details on Steam and Discord!"
		8:
			news_text = "(9/14/19) v2.0 \"Unlimited\" is now available!\n\n" + \
						"Features:\n\n" + \
						"- Renamed to simply HYPERFIGHT\n" + \
						"  (v1.x codenamed \"Max Battle\")\n" + \
						"- Added online multiplayer\n" + \
						"- New character: Vince Volt\n" + \
						"- New stage + music: Sunset Bridge\n" + \
						"(Continued...)"
		9:
			news_text = "- Major UI rehaul\n" + \
						"- New moves for Shoto Goto, Dark Goto,\n" + \
						"  and Don McRon\n" + \
						"- Rebalanced physics and all characters\n" + \
						"- Move lists in pause menu\n" + \
						"- CPU vs CPU mode\n" + \
						"- CPU difficulty option (Normal by default)\n" + \
						"- Vsync option (On by default)\n\n" + \
						"More details on Steam and Discord!"
	
	label_page.text = str(curr_page) + "/" + str(max_pages)
	label_news.text = news_text

func set_active(active):
	button_steam.activated = active
	button_discord.activated = active
