-- Bird without feet, spread your wings and fly high!
name = "Birds Painting Scroll · Hidden Ice 󰀜"
version = "4.8_00"


description =
	" 󰀃 current version: Hidden Ice Chapter " .. version .. "󰀃\n\n" ..
	[[


	Hidden Ice Chapter is the first part of the scroll, which contains the basic runtime library.
	Other mods in the scroll series must also have this to run.




	󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚󰀚
	󰀒：If you encounter any problems, please read the settings carefully
	󰀬：QQ group Q&A: 941438122
																					󰀍
]]

author = "呼吸"
forumthread = ""
api_version = 10
-- Mod icon
-- Authorized to the author: https: //space.bilibili.com/360207186
-- Icon source: https://www.bilibili.com/video/BV1Xf4y1N7p1/
icon_atlas = "modicon.xml"
icon = "modicon.tex"
all_clients_require_mod = false
client_only_mod = true
dst_compatible = true
priority = 1000

local function addTitle(title)
	return {
		name = "huxi",
		label = title,
		options = {
			{ description = "", data = 0 },
		},
		default = 0,
	}
end

local function AddOpt(desc, data, hover)
	return { description = desc, data = data, hover = hover }
end

-- VanCa: Add more key to bind
local theKeys = {
	AddOpt("Off", false),
	AddOpt("A", 97),
	AddOpt("B", 98),
	AddOpt("C", 99),
	AddOpt("D", 100),
	AddOpt("E", 101),
	AddOpt("F", 102),
	AddOpt("G", 103),
	AddOpt("H", 104),
	AddOpt("I", 105, "This is the default button for checking your own skin\nYou can select it if you're not afraid of conflicts"),
	AddOpt("J", 106),
	AddOpt("K", 107),
	AddOpt("L", 108),
	AddOpt("M", 109),
	AddOpt("N", 110),
	AddOpt("O", 111),
	AddOpt("P", 112),
	AddOpt("Q", 113),
	AddOpt("R", 114),
	AddOpt("S", 115),
	AddOpt("T", 116),
	AddOpt("U", 117),
	AddOpt("V", 118),
	AddOpt("W", 119),
	AddOpt("X", 120),
	AddOpt("Y", 121),
	AddOpt("Z", 122),
	AddOpt("Minus sign -", 45),
	AddOpt("Plus sign +", 61),
	AddOpt("Mouse side key A", 1005, "It may not work with some mouse"),
	AddOpt("Mouse side key B", 1006, "It may not work with some mouse"),
	AddOpt("Off", false, "↑↑↑ Isn't there an Off above ↑↑↑\nWhy do you have to select it here?"),
	AddOpt("<", 44, "Less-than sign or comma button"),
	AddOpt(">", 46, "Greater-than sign or decimal point button"),
	AddOpt(":", 59, "Colon or semicolon button"),
	AddOpt("'", 39, "Single or double quotation button"),
	AddOpt("[", 91, "Left bracket"),
	AddOpt("]", 93, "Right bracket"),
	AddOpt("\\", 92, "Right slope"),
	AddOpt("F1", 282),
	AddOpt("F2", 283),
	AddOpt("F3", 284),
	AddOpt("F4", 285),
	AddOpt("F5", 286),
	AddOpt("F6", 287),
	AddOpt("F7", 288),
	AddOpt("F8", 289),
	AddOpt("F9", 290),
	AddOpt("F10", 291),
	AddOpt("F11", 292),
	AddOpt("Direction key (↑)", 273),
	AddOpt("Direction key (↓)", 274),
	AddOpt("Direction key (←)", 276),
	AddOpt("Direction key (→)", 275),
	AddOpt("Off", false, "↑↑↑ Isn't there an Off above ↑↑↑\nWhy do you have to select it here?"),
	AddOpt("PageUp", 280, "PageUp"),
	AddOpt("PageDown", 281, "PageDown"),
	AddOpt("Home", 278, "Home"),
	AddOpt("Insert", 277, "Insert"),
	AddOpt("Delete", 127, "Delete"),
	AddOpt("End", 279, "End"),
	AddOpt("Pause", 19, "Pause"),
	AddOpt("Scroll Lock", 145, "Scroll Lock"),
	AddOpt("Caps Lock", 301, "Caps Lock"),
	AddOpt("Left alt", 308, "The game's default Inspect key, please make sure there is no conflict before using this key"),
	AddOpt("Right alt", 307, "The game's default Inspect key, please make sure there is no conflict before using this key"),
	AddOpt("Left ctrl", 306, "Left ctrl"),
	AddOpt("Right ctrl", 305, "Right ctrl"),
	AddOpt("Right shift", 303, "Right shift"),
	AddOpt("Small keyboard 0", 256, "Small keyboard 0"),
	AddOpt("Small keyboard 1", 257, "Small keyboard 1"),
	AddOpt("Small keyboard 2", 258, "Small keyboard 2"),
	AddOpt("Small keyboard 3", 259, "Small keyboard 3"),
	AddOpt("Small keyboard 4", 260, "Small keyboard 4"),
	AddOpt("Small keyboard 5", 261, "Small keyboard 5"),
	AddOpt("Small keyboard 6", 262, "Small keyboard 6"),
	AddOpt("Small keyboard 7", 263, "Small keyboard 7"),
	AddOpt("Small keyboard 8", 264, "Small keyboard 8"),
	AddOpt("Small keyboard 9", 265, "Small keyboard 9"),
	AddOpt("Small keyboard.", 266, "Small keyboard ."),
	AddOpt("Small keyboard /", 267, "Small keyboard /"),
	AddOpt("Small keyboard *", 268, "Small keyboard *"),
	AddOpt("Small keyboard-", 269, "Small keyboard -"),
	AddOpt("Small keyboard +", 270, "Small keyboard +"),
	AddOpt("Off", false, "↑↑↑ Isn't there an Off above ↑↑↑\nWhy do you have to select it here?"),
}
local theBoardKeys = { AddOpt("Panel", "biubiu", "This function will be displayed on the function panel") }
for i = 2, #theKeys + 1 do
	theBoardKeys[i] = theKeys[i - 1]
end

local tof = {
	{ description = "On", data = true, },
	{ description = "Off", data = false, },
}
local wortox_opt = {}
for i = 0,30 do
	if (i == 12) then
		wortox_opt[i] = {hover = "12 can prevent the soul from exploding when killing a large boss",data = i,description=i}
	elseif (i > 20)  then
		wortox_opt[i] = {hover = "Exceeds the limit, but supports some mods", data = i,description=i}
	else
		wortox_opt[i] = {data = i,description=i,}
	end
end
configuration_options =
{
	addTitle("Universal settings"),
	{
		name = "pos_say",
		label = "Screen prompt",
		hover = "Various messages or statements prompts in the game",
		options = {
			{ description = "Default", data = "head", hover = "The sentence will appear above the character's head (only visible to yourself)" },
			{ description = "Your own chat bar", data = "self", hover = "Location of the chat bar (only visible by yourself)" },
			{ description = "Proclaim", data = "ann", hover = "Warning: everyone can see your prompt message!" },
			{ description = "Off", data = false },
		},
		default = "head",
	},
	addTitle("Function panel"),
	{
		name = "sw_mainboard",
		label = "Panel binding",
		hover = "You can open this panel by clicking on this key or clicking the lower right icon at the bottom right of the screen",
		options = theKeys,
		default = 283,
	},
	{
		name = "sw_beauti",
		label = "Game filter",
		hover = "You can switch all filters at any time!",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_shutup",
		label = "Mute noise",
		hover = "Including various sound effects such as equipment, pets, buildings, stools, bird catchers, waves and land, etc.",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_unlock",
		label = "Developer",
		hover = "Unlocked illustrations, skill trees, etc.",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_cookbook",
		label = "Cookbook",
		hover = "A recipe book",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_planthant",
		label = "Plant registry",
		hover = "Open the pioneer of farming",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_nutrients",
		label = "Nutrients",
		hover = "Click to display soil fertilizer, etc.",
		options = theBoardKeys,
		default = "biubiu",
	},
	-- Vanca: Preserve the [Night vision] function
	{
		name = "sw_nightsight",
		label = "Smart night vision",
		hover = "Charlie still attack you if you have no other light source (right click to open adv. settings)",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_autorow",
		label = "Auto rowing",
		hover = "Right-click to open the adv. settings to adjust the speed by yourself",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_autoreel",
		label = "Auto pond fishing",
		hover = "Auto fishing. Right-click to open the adv. settings",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_fishname",
		label = "Auto sea fishing",
		hover = "Auto fishing + display fish name. Right-click to open the adv. settings",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_wagstaff",
		label = "Storm mission",
		hover = "Help Wagstaff to do some tasks",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_wildfires",
		label = "Wildfire warning",
		hover = "Warning about the smoking creatures or entities",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_shadowheart",
		label = "Create statue",
		hover = "Automatically make and discard the statue",
		options = theBoardKeys,
		default = "biubiu",
	}, 
	{
		name = "sw_hideshell",
		label = "Hidden shell",
		hover = "Used to help Hermit crabs salvage shell piles",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_nickname",
		label = "Nickname",
		hover = "The game usernames of other players in the room will be displayed above their heads",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_double",
		label = "Double-click",
		hover = "Double-click to batch batch discard and batch transfer",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw__keytweak",
		label = "Key hints",
		hover = "Tips Key",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_log",
		label = "Changelog",
		hover = "View the change log of this mod",
		options = theBoardKeys,
		default = "biubiu",
	},
	-- {
	-- 	name = "sw_roll",
	-- 	label = "Precise picking",
	-- 	hover = "[Applicable to the test server] Use the mouse wheel to scroll on the inventory to quickly pick up and put items",
	-- 	options = theBoardKeys,
	-- 	default = "biubiu",
	-- },
	{
		name = "sw_DAG",
		label = "Archive assistance",
		hover = "Carry [distillation knowledge] or [blank medal] automatically do tasks, and display task progress",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_cane",
		label = "Auto tools switch",
		hover = "Oh? Go to the panel and activate it manually",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_rescue",
		label = "Send rescue",
		hover = "When pressed, /rescue or /help will be sent\nThis function is used for underground jamming",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_skinHistory",
		label = "Gift records",
		hover = "No technology is required to open gifts, and a [Gift Records] button is added to record the gifts received",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_skinQueue",
		label = "Skin queue",
		hover = "Added a [Disassemble Duplicate Skin] button to help obtain spools",
		options = theBoardKeys,
		default = "biubiu",
	},

	addTitle("Customized function"),
	{
		name = "sw_compass",
		label = "Compass",
		hover = "There is direction, but no location",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_mynote",
		label = "My notes",
		hover = "Simple manual, easy to check",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_winch",
		label = "Salvage positioning",
		hover = "Correct position highlight clamp capstan",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_indicator",
		label = "Directions",
		hover = "Add arrows to important things",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_starfish",
		label = "Ruin anenemy",
		hover = "Player customization function: used to locate ruin creature respawn points",
		options = theBoardKeys,
		default = "biubiu",
	},



	addTitle("Memory+"),
	{
		name = "mid_search",
		label = "Mid-click",
		hover = "Middle-click on the item recipe to search for related materials,\n and click on the inventory to store the item",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "sw_autocook",
		label = "Auto cook",
		hover = "Middle-click the pot or press the button to start. If you hold down CTRL at the same time, it is [collect mode]",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "brain_save",
		label = "Save at dawn",
		hover = "Do you want to save the data every day at dawn?",
		options = tof,
		default = true,
	},
	{
		name = "brain_sign",
		label = "Smart mini sign",
		hover = "The opened box will have a small wooden sign to indicate what is inside",
		options = tof,
		default = true,
	},
	{
		name = "brain_bundle",
		label = "Bundle wrap memory",
		hover = "If you pack something yourself, you will remember what is inside",
		options = tof,
		default = true,
	},
	{
		name = "brain_chester",
		label = "Storage item highlight",
		hover = "When the mouse picks up something or hovers over a recipe, items and chests are highlighted",
		options = tof,
		default = true,
	},

	addTitle("Info tray"),
	{
		name = "sw_timer",
		label = "Functional settings",
		hover = "Set the function of the info tray quickly",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "huxi_warn",
		label = "Monster warning",
		hover = "Deerclops, Bearger, Hounds wave, etc. have a countdown with warning sound prompts",
		options = tof,
		default = true,
	},
	{
		name = "huxi_clock",
		label = "Current time",
		hover = "Display the current time [this function needs to be set activated in settings]",
		options = tof,
		default = true,
	},
	{
		name = "huxi_pos",
		label = "Current coordinates",
		hover = "Display the current coordinates [this function needs to be set activated]",
		options = tof,
		default = true,
	},
	{
		name = "huxi_nightmare",
		label = "Nightmare phase",
		hover = "Underground nightmare phase countdown",
		options = tof,
		default = true,
	},
	{
		name = "huxi_rain",
		label = "Rain/snow countdown",
		hover = "Countdown countdown",
		options = tof,
		default = true,
	},
	{
		name = "huxi_buff",
		label = "Buff countdown",
		hover = "Countdown to the attributes of various foods",
		options = tof,
		default = true,
	},
	{
		name = "huxi_boss",
		label = "Boss countdown",
		hover = "Refreshing time display of various creatures",
		options = tof,
		default = true,
	},

	addTitle("Map icon"),
	{
		name = "sw_map",
		label = "Functional settings",
		hover = "Set the function of the map icon quickly",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "map_alter",
		label = "Positioning celestial body",
		hover = "Looking for celestial body altars",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "map_preview",
		label = "Terrain preview",
		hover = "Check some important resource points on the character selection page and in the game",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "map_wormhole",
		label = "Wormhole mark",
		hover = "Add wormhole labels after jumping wormhole",
		options = tof,
		default = true,
	},
	{
		name = "map_gogo",
		label = "Auto walking",
		hover = "Click the map to arrive automatically",
		options = tof,
		default = true,
	},
	{
		name = "map_animal",
		label = "More creature icons",
		hover = "Add map icons to common boss and biology",
		options = tof,
		default = true,
	},

	
	addTitle("Right-click to enhance"),
	{
		name = "sw_right",
		label = "Right-click binding",
		hover = "Right-click more operations",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = 'sw_castspell',
		label = "Accurate casting",
		hover = "Calling the stars and calling the moon can be on the buttocks of the pig king",
		options = tof,
		default = true,
	},
	{
		name = 'rt_take',
		label = "Recipe pickup",
		hover = "Right click on the recipe bar to take the specified amount of items",
		options = tof,
		default = true,
	},
	{
		name = "rt_double",
		label = "Double-click transmission",
		hover = "When equipped with equipment such as the Lazy Explorer Staff, you need to right-click twice to teleport with right click",
		options = tof,
		default = true,
	},
	{
		name = "sw_autoread",
		label = "Auto reading",
		hover = "Hold down CTRL + right click to automatically read the book (retain one durability)",
		options = tof,
		default = true,
	},
	{
		name = "sw_autopush",
		label = "Auto push",
		hover = "Hold SHIFT + right click to push living entities",
		options = tof,
		default = true,
	},
	{
		name = "rt_dirtpile",
		label = "Auto track footprint",
		hover = "Right-click the footprint to hunt automatically",
		options = tof,
		default = true,
	},

	addTitle("Single function"),
	{
		name = "sw_cave",
		label = "Cave clock",
		hover = "The clock is displayed in the place where there is no light in the cave",
		options = tof,
		default = true,
	},
	{
		name = "sw_error",
		label = "Smart mod",
		hover = "Process error and provide log help",
		options = tof,
		default = true,
	},
	{
		name = "sw_mapseed",
		label = "Map seed",
		hover = "The location of the creation of the world will prompt map seeds",
		options = tof,
		default = true,
	},
	{
		name = "sw_multiscreen",
		label = "Wallpaper mode",
		hover = "Right-click on the homepage of the game to view the wallpaper animation",
		options = tof,
		default = true,
	},
	{
		name = "sw_mySeedTex",
		label = "Seed map",
		hover = "Restore the old version of the seeds",
		options = tof,
		default = true,
	},
	{
		name = "sw_stat",
		label = "State change",
		hover = "There will be numbers in all the attribute columns.",
		options = tof,
		default = true,
	},
	{
		name = "sw_wall",
		label = "Don't hit the wall",
		hover = "Forced attacks will not hit the wall and pumpkin lamp, unless pressing the ctrl to click on",
		options = {
			{description = "On", data = true, hover = "It also includes wigmen who do not attack invincible state"},
			{description = "Off", data = false},
		},
		default = true,
	},
	{
		name = "sw_tele",
		label = "Transmit",
		hover = "Leave a position mark in place after transmitting the organism",
		options = tof,
		default = true,
	},
	{
		name = "sw_folder",
		label = "Mod directory",
		hover = "Direct mod storage directory below the mod name",
		options = tof,
		default = true,
	},
	{
		name = "sw_info",
		label = "Production bar information",
		hover = "Add additional information display in the production bar",
		options = {
			{description = "On", data = true, hover = "If the fenghua chapter is enabled, there will be more display"},
			{description = "No item code", data = "code", hover = "The production bar will not display the item code"},
			{description = "Off", data = false},
		},
		default = true,
	},
	{
		name = 'sw_peopleNum',
		label = "Change the max player",
		hover = "The maximum number of people you can choose when creating a world. Click Apply to take effect.",
		options = {
			{description = "Default", data = 6, hover = "The default is 6 players."},
			{description = "Off", data = false, hover = "Even if it is turned off, it still uses the default 6 players without any changes."},
			{description = "8 players", data = 8, hover = "Remember to modify the number of people where to create the world"},
			{description = "12 players", data = 12, hover = "Remember to modify the number of people where to create the world"},
			{description = "16 players", data = 16, hover = "Remember to modify the number of people where to create the world"},
			{description = "24 players", data = 24, hover = "Remember to modify the number of people where to create the world"},
			{description = "36 players", data = 36, hover = "Remember to modify the number of people where to create the world"},
			{description = "50 players", data = 50, hover = "Alas, how much is your configuration a pound?"},
			{description = "100 players", data = 100, hover = "You are here to cause trouble on purpose!"},
		},
		default = 6,
	},
	{
		name = 'sw_hidecrown',
		label = "Bone helmet display switch",
		hover = "Add a switch to show/hide the shadow monsters when wearing a bone helmet",
		options = tof,
		default = true,
	},
	{
		name = 'sw_modplayer',
		label = "Mod character avatar",
		hover = "Whether to display the avatar of the mod character you are playing on the Host Game page",
		options = tof,
		default = true,
	},

	
	addTitle("Single binding"),
	{
		name = "sw_toggle",
        label = "Lag compensation toggle",
        hover = "One-click switch lag compensation On/Off",
        options = theKeys,
        default = 110,
	},
	{
		name = "sw_lantern",
        label = "Quick drop",
        hover = "One-click drop lamp, bird catcher, thermal stone (to heat source), trap (to rabbit hole)",
        options = theKeys,
        default = 122,
	},

	addTitle("My world"),
	{
		name = "sw_server",
		label = "Ingame reconnect",
		hover = "Quickly re-connected while playing in a server",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "server_login",
		label = "Ensure login",
		hover = "It is guaranteed that there will be no instances of missing skins in the game.\nThe trade-off is that reconnect speed will be slower...",
		options = tof,
		default = false,
	},
	{
		name = "server_reco",
		label = "Connect method",
		hover = "Note: wegame does not support IP direct connection",
		options = {
			{description = "Normal", data = "sim", hover = "The speed is a little slower than the following option, but it is more stable"},
			{description = "IP", data = "ip", hover = "If you often play on cloud servers or dedicated servers, please select this option"},
		},
		default = "sim",
	},
	{
		name = "server_server",
		label = "Main menu - Servers",
		hover = "Add [Servers] button to the main menu",
		options = tof,
		default = true,
	},
	{
		name = "server_quick",
		label = "Main menu - Reconnect",
		hover = "Add the [Reconnect] button on the main menu",
		options = tof,
		default = true,
	},
	{
		name = "server_popup",
		label = "Login page - Reconnect",
		hover = "Add the [Reconnect] button on the login page",
		options = tof,
		default = true,
	},



	addTitle("Range display"),
	{
		name = "range_board",
		label = "Range display",
		hover = "The binding settings of the range display",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "range_attack",
		label = "Mob attack range",
		hover = "Whether the attack range is displayed",
		options = tof,
		default = true,
	},
	{
		name = "range_player",
		label = "Weapon/tool range",
		hover = "When the player is holding a ranged weapon or fishing rod, the corresponding range is displayed",
		options = tof,
		default = true,
	},
	{
		name = "range_hover",
		label = "Hover show range",
		hover = "Move the mouse over some entities such as books and gunpowder to display the range",
		options = tof,
		default = true,
	},
	{
		name = "range_click",
		label = "Click show range",
		hover = "Display range when the mouse clicks on the entity such as wood and casting machines in the water",
		options = tof,
		default = true,
	},
	{
		name = "range_placer",
		label = "Placement range",
		hover = "Whether to display the range when placing buildings such as Lightning Rod and Eye Turret",
		options = tof,
		default = true,
	},
	{
		name = "animal_track",
		label = "Footprint guidance",
		hover = "Suspicious footprints will have moving arrows to indicate the hunting direction",
		options = tof,
		default = true,
	},
	{
		name = "range_search",
		label = "Treasure indicator",
		hover = "Add an arrow under your feet point to a variety of gems or other 'treasures'",
		options = tof,
		default = true,
	},


	addTitle("Item manager"),
	{
		name = "ex_board",
		label = "Item management",
		hover = "Determine how to open the manager's settings",
		options = theBoardKeys,
		default = "biubiu",
	},
	{
		name = "ex_re_equip",
		label = "Auto re-equip",
		hover = "When the durability of weapons, wands, etc. is exhausted, the next one will be automatically equipped",
		options = tof,
		default = true,
	},
	{
		name = "ex_re_ammo",
		label = "Auto reload",
		hover = "Slingshots, Turf-Raiser Helm, etc. are automatically replenished",
		options = tof,
		default = true,
	},
	{
		name = "auto_unequip",
		label = "Auto unequip",
		hover = "Magiluminescence and other equipment automatically unequips when durability is low",
		options = tof,
		default = true,
	},
	{
		name = "auto_repair",
		label = "Auto repair/refuel",
		hover = "Automatically repair/refuel equipment such as Magiluminescence when its durability is low",
		options = tof,
		default = true,
	},
	{
		name = "cd_skeleton",
		label = "Bone Armor cooldown",
		hover = "Add a blue circle to display the cooldown of Bone Armor",
		options = tof,
		default = true,
	},
	{
		name = "sw_skeleton",
		label = "Bone Armor switch",
		hover = "After the Bone armor is hit, automatically switch to the next one with the shortest cooldown",
		options = tof,
		default = true,
	},
	{
		name = "text_cd",
		label = "Cooldown timer",
		hover = "For Wanda’s watches, bone armor, and other items with cooldowns, display the cooldown timer",
		options = tof,
		default = true,
	},
	{
		name = "sw_manualAdd",
        label = "Repair button",
        hover = "Press this key to automatically add lamp fuel and repair equipment",
        options = theKeys,
        default = 118,
	},
	{
		name = "sw_autosort",
        label = "Item Arrangement",
        hover = "Press this key to automatically classify and organize all items\n【Please enable the function panel to view advanced settings!】",
        options = theKeys,
        default = 127,
	},

	addTitle("Perspective change"),
	{
		name = "sw_C",
		label = "Main switch",
		hover = "Main switch for perspective change",
		options = tof,
		default = true,
	},
	{
		name = "c_add",
		label = "FoV+",
		hover = "Set point of view farther",
		options = theKeys,
		default = 61,
	},
	{
		name = "c_minus",
		label = "FoV-",
		hover = "Set point of view closer",
		options = theKeys,
		default = 45,
	},
	{
		name = "c_hidehud",
		label = "Hide HUD",
		hover = "Hide HUD shortcut keys",
		options = theKeys,
		default = 291,
	},
	{
		name = "c_hideself",
		label = "Hide player",
		hover = "Hide player shortcut key",
		options = theKeys,
		default = false,
	},
	{
		name = "c_track",
		label = "Choose FoV",
		hover = "Place the perspective to the entity or position under the mouse",
		options = theKeys,
		default = 111,
	},
	{
		name = "c_back",
		label = "Switch FoV",
		hover = "The shortcut key to switch camera between the entity/position that it is recently selected",
		options = theKeys,
		default = 104,
	},
	{
		name = "c_change",
		label = "Perspective change",
		hover = "Default/Wide View/Overview shortcut keys",
		options = theKeys,
		default = false,
	},
	{
		name = "change_mode",
		label = "Change mode",
		hover = "The model of the perspective of the above perspective",
		options = {
			{ description = "Default - Wide View - Overlooking", data = 1 },
			{ description = "Default - Wide View", data = 2, },
			{ description = "Default - Overlooking", data = 3, },
			{ description = "Wide View - Overlooking", data = 4, },
		},
		default = 1,
	},
	{
		name = "c_init",
		label = "Default perspective",
		hover = "The perspective when entering the game",
		options = {
			{ description = "Default", data = false, hover = "By the way to enter the game" },
			{ description = "Wide View", data = true, hover = "Start a big horizon when entering the game" },
		},
		default = false,
	},
	addTitle("Wendy auxiliary"),
	{
		name = "sw_wendy",
		label = "Switch",
		hover = "Wendy -assisted general switch",
		options = tof,
		default = true,
	},
	{
		name = "wendy_summonkey",
		label = "Summon and retract",
		hover = "Summon or retract the shortcut key for Abigail...",
		options = theKeys,
		default = 120,
	},
	{
		name = "wendy_commandkey",
		label = "Angry or comfort",
		hover = "This button can anger or comfort Abigail...",
		options = theKeys,
		default = 114,
	},
	{
		name = "sw_ghost",
		label = "Help Pipspooks",
		hover = "When you are close to the lost toys, there will be an arrow instruction under your feet",
		options = {
			{description = "On", data = true, hover = "This feature requires turning on the [Treasure Indicator]!"},
			{description = "Off", data = false},
		},
		default = true,
	},

	addTitle("Wanda auxiliary"),
	{
		name = "sw_wanda",
		label = "Switch",
		hover = "Wanda auxiliary master switch",
		options = tof,
		default = true,
	},
	{
		name = "pocketwatch_heal",
		label = "Activate ageless watch",
		hover = "Eternal Diamond: Activate an available [Ageless Watch]",
		options = theKeys,
		default = 120,
	},
	{
		name = "pocketwatch_warp",
		label = "Activate rewind watch",
		hover = "Platinum star: activate a available [Reverse Watch]",
		options = theKeys,
		default = 114,
	},
	{
		name = "pocketwatch_recall",
		label = "Activation traceable table",
		hover = "Gold experience: activate a available [traceable form]",
		options = theKeys,
		default = false,
	},
}
