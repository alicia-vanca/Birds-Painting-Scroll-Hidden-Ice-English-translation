local t_util = require "util/tableutil"


-- Attack
local attack_range = {
	{
		prefabs = {"ghost",},
		rotary = {1.5},
	}, 
	{
		prefabs = {
					"lightninggoat", 
					"krampus",
					"crawlingnightmare", 
					"nightmarebeak", 
					"deer_blue", 
					"deer_red", 
					"birchnutdrake", 
					"moonpig", "pigguard", "mermguard","pigman", "bunnyman", "merm",
					"koalefant_summer", "koalefant_winter", "grassgator", "beefalo", 
					"fruitdragon", "gnarwail","spat",
					-- The following is a breathing verification, which is worthy of trust
					"frog", "knight","knight_nightmare",
					"powder_monkey",
					"prime_mate",
					"monkey",
					"houndcorpse", "hound", "icehound", "firehound", "mutatedhound", "clayhound", "hedgehound",
					"spider_healer", "spider_moon", "spider_dropper", "spider", "spider_warrior", "spider_hider", "spider_spitter",
					-- Replenish
					"terrorbeak","crawlinghorror","otter",
				},
		rotary = {3},
	},
	{
		prefabs = {"leif","leif_sparse",},
		rotary = {[3] = function (circle, ent, scale)
			circle:SetFixedRadius(3*scale+0.5)
		end},
	},
	{
		prefabs = {"koalefant_summer", "koalefant_winter",},
		rotary = {5},
	}, 
	{
		prefabs = {"rocky","eyeofterror_mini"},
		rotary = {4},
	}, 
	{
		prefabs = {"shark"},
		rotary = {4},
	}, 
	{
		prefabs = {"tentacle","flup"},
		rotary = {[4] = "Green"},
		always = true,
	},
    {
		prefabs = {"lunarthrall_plant"},	--Bright eggplant fly
		rotary = {4},
	},
	{
		prefabs = {"lunarthrall_plant_vine_end"},	--Bright eggplant diamond vine
		rotary = {3},
		quick = true,
	},
	{
		prefabs = {"deerclopseyeball_sentryward"},	--Ice -eye tower frozen range
		rotary = {3},
	},
	-- BOSS
	{
		prefabs = {"daywalker"},
		rotary = {6},
	}, 
	{
		prefabs = {"deerclops"},
		rotary = {12},
	}, 
	{
		prefabs = {"warglet"},
		rotary = {3},
	}, 
	{
		prefabs = {"klaus"},
		rotary = {[TUNING.KLAUS_HIT_RANGE] = function (circle, ent, scale)
			circle:SetFixedRadius(TUNING.KLAUS_HIT_RANGE * scale / 1.2 +0.5)
		end,
		-- Here you can add another scope, but i'm too lazy, forget it
	}
	},
	{
		prefabs = {"minotaur"},
		rotary = {4.1-0.5,4.1+0.5},
	},
	{
		prefabs = {"stalker","stalker_forest","stalker_atrium"},
		rotary = {2.9,10},
	},
	{
		prefabs = {"shadow_knight"},
		rotary = {[TUNING.SHADOW_KNIGHT.ATTACK_RANGE_LONG] = function (circle, ent, scale)
			if scale == 2.5 then
				circle:SetFixedRadius(6 + 0.5)
			else
				circle:SetFixedRadius(TUNING.SHADOW_KNIGHT.ATTACK_RANGE_LONG*scale + 0.5)
			end
		end},
	},
	{
		prefabs = {"shadow_rook"},
		rotary = {[TUNING.SHADOW_ROOK.HIT_RANGE] = function (circle, ent, scale)
			circle:SetFixedRadius(TUNING.SHADOW_ROOK.HIT_RANGE * scale+0.5)
		end},
	},
	{
		prefabs = {"shadow_bishop"},
		rotary = {[TUNING.SHADOW_BISHOP.HIT_RANGE] = function(circle, ent, scale)
			circle:SetFixedRadius(TUNING.SHADOW_BISHOP.HIT_RANGE * scale+0.5)
		end, [0] = function (circle, ent, scale)
			local level = t_util:GetElement(TUNING.SHADOW_BISHOP.LEVELUP_SCALE, function (level, lsc)
				return lsc > (scale - 0.2) and level
			end)
			if level then
				circle:SetFixedRadius(TUNING.SHADOW_BISHOP.ATTACK_RANGE[level]+0.5)
			end
		end}
	},
	{
		prefabs = {"alterguardian_phase2",},
		rotary = {4.5,}
	}, 
	{
		prefabs = {"alterguardian_phase3",},
		rotary = {TUNING.ALTERGUARDIAN_PHASE3_STAB_RANGE},
	}, 
	-- Shadow bishop: emmmm, divided into three stages, in turn is 4,6,8, you need to write an additional function. 
	-- Emperor crab: emmmm, you need to write an additional function, let's not show it for the time being 
	{
		prefabs = {"dirtpile"},
		rotary = {[2] = "Thistle color"},
		always = true,
	},
	-- "shadowthrall_hands","shadowthrall_horns","shadowthrall_wings",
	{
		prefabs = {"bearger"},
		rotary = {TUNING.BEARGER_MELEE_RANGE+1},		-- Refer to doarcattack (stategraphs \ sgbearger.lua)
	},
	{
		prefabs = {"mutatedbearger"},
		rotary = {TUNING.BEARGER_MELEE_RANGE+3},		--Players compensate 0.5 compensation, so no+1, aoe_range_paddding = 3
	},
	{
		prefabs = {"mutatedwarg"},
		rotary = {1.7+3+3, TUNING.WARG_ATTACKRANGE},
	},
	{
		prefabs = {"blackbear",},	--Black wind king
		rotary = {6},
	},
	{
		prefabs = {"rhino3_red",},	--Summer king
		rotary = {4.2},
	},
	{
		prefabs = {"rhino3_blue",},	--King of cold avil
		rotary = {4.2},
	},
	{
		prefabs = {"rhino3_yellow",},	--King of dust
		rotary = {4.2},
	},
	{
		prefabs = {"myth_goldfrog",},	--Jubao jin chan
		rotary = {7},
	},
	{
		prefabs = {"myth_small_goldfrog",},	--Xiao jin chan
		rotary = {3},
	},
	{
		prefabs = {"myth_nian",},	--Beast
		rotary = {4},
	},
	{
		prefabs = {"siving_thetree",},	--Ziyi kimantan
		rotary = {25},
		always = true,
	},
	{
		prefabs = {"siving_foenix",},	--Zigui xuan bird
		rotary = {3.5},
	},
	{
		prefabs = {"siving_moenix",},	--Ziyi xuan birdgong
		rotary = {3.5},
	},
	{
		prefabs = {"elecarmet",},	--Rick amtit
		rotary = {6, 20},
	}, 
	--Never compromise biology and boss
	{
		prefabs = {	--Never compromise creatures
					"snowmong",--Snow monster
					"knook",--Strip carriage beast
					"bight",--Jiaojiao beast
					"shockworm",--Abyss electric eel
					"viperworm",--Abyssic eel
					"glacialhound",--Glacier hunting dog
					"lightninghound",--Lightning hound
					"magmahound",--Lava
					"sporehound",--Spore hunting dog
					"scorpion",--Scorpion
					"spider_trapdoor",--Cavity spider
					"ancient_trepidation",--Horror giant spider
					"bushcrab",--Shrub spider
					},
		rotary = {3},
	},
	{
		prefabs = {"hoodedwidow",},	--Black widow
		rotary = {5},
	}, 
	{
		prefabs = {"moonmaw_dragonfly",},	--Moonlight dragon fly
		rotary = {5},
	}, 
	{
		prefabs = {"moonmaw_lavae",},	--Glass lava worm
		rotary = {2},
	}, 
	{
		prefabs = {"mothergoose",},	--Goose mother
		rotary = {5.5},
	}, 
	{
		prefabs = {"mock_dragonfly",},	--Show dragon fly
		rotary = {4},
	}, 
	{
		prefabs = {"Roship",},	--Straight car
		rotary = {12},
	}, 
	{
		prefabs = {"viperling",},	--Shadow worm
		rotary = {1.5},
	},
	{
		prefabs = {"creepingfear",},	--Horror tongs
		rotary = {4},
	}, 
	{
		prefabs = {"dreadeye",},	--Horror
		rotary = {2},
	}, 
	{
		prefabs = {"ancient_trepidation_arm",},	--Giant spider claw
		rotary = {4},
	}, 
	{
		prefabs = {"toadstool_dark",}, -- Toadstool
		rotary = {8},
	}, 
	{
		prefabs = {"crabking_claw",}, -- Crab King claws
		rotary = {TUNING.CRABKING_CLAW_ATTACKRANGE},
	}, 
	
}
local attack_auto = {
	"TALLBIRD", "BUZZARD", "TEENBIRD", "SQUID","SLURTLE",
	"SPIDER_WATER", "TENTACLE_PILLAR_ARM","WORM",
	"CATCOON","SLURPER","WALRUS",
	-- BOSS
	"MOSSLING","BEEGUARD","MOOSE",--"BEARGER",
	"BEEQUEEN",
	"DEERCLOPS","LORDFRUITFLY","WARG","SPIDERQUEEN","MALBATROSS",
	"DRAGONFLY",

	-- Deviny distance / stop attack distance
	"EYEPLANT",
	"shadowthrall_hands","shadowthrall_horns","shadowthrall_wings",
}
local format_auto = {"%s_ATTACK_DIST", "%s_HIT_RANGE", "%s_ATTACK_RANGE", "%s_ATTACKRANGE"}

t_util:IPairs(attack_auto, function (prefab)
    prefab = prefab:upper()
    local range = t_util:IGetElement(format_auto, function (str)
        return TUNING[str:format(prefab)]
    end)
    if type(range)=="number" then
        table.insert(attack_range, {prefabs = {prefab}, rotary = {range}})
    end
end)
-- Hate
local target_range = {
	{
		prefabs = {"spore_moon"},
		rotary = {3},
	},{
		prefabs = {"lightninggoat"},
		rotary = {8},
	},
	{
		prefabs = {"bishop_nightmare", "rook_nightmare"},
		rotary = {12},
	},{
		prefabs = {"knight_nightmare", "slurtle",},
		rotary = {10},
	},{
		prefabs = {"wasphive"},
		rotary = {[10] = "Brown"},
	},{
		prefabs = {"pigtorch"},
		rotary = {[8] = "Brown"},
	},
	-- BOSS
	{
		prefabs = {"klaus", "dragonfly", "shadow_rook", "shadow_knight", "shadow_bishop"},
		rotary = {15},
	},
	{
		prefabs = {"malbatross"},
		rotary = {[3] = "Green"},
	},
	{
		prefabs = {"claywarg", "gingerbreadwarg"},
		rotary = {[4] = "Green"},
	},
	{
		prefabs = {"archive_centipede"},
		rotary = {5},
	},
	{
		prefabs = {"mushroombomb", "mushroombomb_dark"},
		rotary = {3.5},
		quick = true,
	},
	{
		prefabs = {"alterguardian_phase3trap",},
		rotary = {[TUNING.ALTERGUARDIAN_PHASE3_TRAP_AOERANGE]='Red'},
		quick = true,
	}, 
	{
		prefabs = {"eyeofterror", "twinofterror1","twinofterror2"},
		rotary = {3},
	}, 
	-- Bun
	-- {
	-- 	prefabs = {"deer_blue",	"deer_red",},
	-- 	rotary = {{"blue", 12}},
	-- },  
	{
		prefabs = {"alterguardian_phase1",},
		rotary = {4.25},
	}, {
		prefabs = {"bigshadowtentacle"},
		rotary = {[4]= "Breathing yellow"},				-- The 4 here is the actual attack distance, but the writing is the hate distance here (there is a deep meaning here)
		quick = true,
		always = true,
	},{
		prefabs = {"mutatedbearger"},
		rotary = {TUNING.MUTATED_BEARGER_TARGET_RANGE},
	},
	{
		prefabs = {"mutatedwarg"},
		rotary = {TUNING.WARG_TARGETRANGE},
	},
	{
		prefabs = {"mutateddeerclops"},
		rotary = {5.5},		-- Aoe frozen range, the range of hatred is not written
	},

	-- åƒãzÅF November 2024 supplement
	{
		prefabs = {"daywalker2"},
		rotary = {TUNING.DAYWALKER2_TACKLE_RANGE},
	}, {
		prefabs = {"rabbitking_aggressive"},
		rotary = {TUNING.RABBITKING_ABILITY_DROPKICK_SPEED * TUNING.RABBITKING_ABILITY_DROPKICK_MAXAIRTIME},
	}
}
local target_auto = {
	"WALRUS", "KNIGHT", "BISHOP", "ROOK", "SLURTLE",
	"SPAT", "WORM", "TALLBIRD",
	-- "ALTERGUARDIAN_PHASE1",
	-- "ALTERGUARDIAN_PHASE2",
	"ALTERGUARDIAN_PHASE3",
	-- BOSS
	"MINOTAUR", --"WARG"
}

t_util:IPairs(target_auto, function (prefab)
    prefab = prefab:upper()
    local range = t_util:IGetElement({"%s_TARGET_DIST", "%s_TARGETRANGE"}, function (str)
        return TUNING[str:format(prefab)]
    end)
    if type(range)=="number" then
        table.insert(target_range, {prefabs = {prefab}, rotary = {range}})
    end
end)

-- Treasure tracking
local track = {
	klaus_sack = "Red",
	malbatross = "Red",
	beequeenhivegrown = "Golden",
	antlion = "Red",
	greengem = "Green",
	yellowgem = "Golden",
	livingtree = "Brown",
	livingtree_halloween = "Brown",
	terrariumchest = "Purple",

	-- Island adventure
	ia_messagebottle = "Red",
	coral_brain_rock = "Red",
	whale_bubbles = "Red",
	dubloon = "Golden",
	
	-- musha
	musha_treasure2 = "Purple",

	-- 2023.6.6 supplement
	rock_moon_shell = "Blue",
	mushgnome = "Brown",

	-- Seed indicator
	seeds = "Green",
}

local hover = {
	
	panflute = TUNING.PANFLUTE_SLEEPRANGE,
	eyeturret = TUNING.EYETURRET_RANGE+3,
	wortox_soul = TUNING.WORTOX_SOULHEAL_RANGE,
	-- Book
	book_tentacles = 8, 		-- 3,8
	book_birds = 10,
	book_brimstone = 15,		-- 3,15
	book_sleep = 30,			-- This range is outrageous
	book_gardening = 30,
	book_horticulture = 30,
	book_horticulture_upgraded = 30,
	book_silviculture = 30,
	book_fish = 10,				-- In fact, there are offset
	book_fire = TUNING.BOOK_FIRE_RADIUS,
	book_web = TUNING.BOOK_WEB_GROUND_RADIUS,
	book_temperature = TUNING.BOOK_TEMPERATURE_RADIUS,
	book_light = 3,
	book_light_upgraded = 3,
	book_rain = 4,
	book_research_station = TUNING.BOOK_RESEARCH_STATION_RADIUS,
	-- Gunpowder
	gunpowder = TUNING.GUNPOWDER_RANGE,
	moon_altar = TUNING.MOON_ALTAR_ESTABLISH_LINK_RADIUS,
	-- Tree essence statue
	leif_idol = TUNING.LEIF_IDOL_SPAWN_RADIUS,
	deerclopseyeball_sentryward =  TUNING.DEERCLOPSEYEBALL_SENTRYWARD_RADIUS,
    voidcloth_umbrella = 16,	--Shadow umbrella
	phonograph = 8,	--The scope of the vocal machine care for the plant
	singingshell_octave3 = 2,	--Shell clock care of the plant range
	singingshell_octave4 = 2,	--Shell clock care of the plant range
	singingshell_octave5 = 2,	--Shell clock care of the plant range
	firesuppressor = TUNING.FIRE_DETECTOR_RANGE,
	lighter = 2.5,

	spider_whistle = TUNING.SPIDER_WHISTLE_RANGE,
}

local click = {
	firesuppressor = TUNING.FIRE_DETECTOR_RANGE,
	winona_catapult =  TUNING.WINONA_CATAPULT_MAX_RANGE,
	lightning_rod = 40,
	oceantree = TUNING.SHADE_CANOPY_RANGE_SMALL,
	oceantreenut = TUNING.SHADE_CANOPY_RANGE_SMALL,
	oceantree_pillar = TUNING.SHADE_CANOPY_RANGE_SMALL,
	winch = TUNING.SHADE_CANOPY_RANGE_SMALL,
	watertree_pillar = TUNING.SHADE_CANOPY_RANGE,
	eyeturret = TUNING.EYETURRET_RANGE+3,
	winona_spotlight = TUNING.WINONA_SPOTLIGHT_MAX_RANGE + TUNING.WINONA_SPOTLIGHT_MIN_RANGE,
	moon_fissure = TUNING.MOON_ALTAR_ESTABLISH_LINK_RADIUS,
	moon_altar = TUNING.MOON_ALTAR_ESTABLISH_LINK_RADIUS,
	mushroom_light = 11,		-- Not allowed, manually measured
	mushroom_light2 = 11,		-- Not allowed, manually measured
	support_pillar = TUNING.QUAKE_BLOCKER_RANGE,
	support_pillar_scaffold = TUNING.QUAKE_BLOCKER_RANGE,
	support_pillar_dreadstone = TUNING.QUAKE_BLOCKER_RANGE,
	support_pillar_dreadstone_scaffold = TUNING.QUAKE_BLOCKER_RANGE,
	leif_idol = TUNING.LEIF_IDOL_SPAWN_RADIUS,
	deerclopseyeball_sentryward = TUNING.DEERCLOPSEYEBALL_SENTRYWARD_RADIUS,
    -- dragonflyfurnace = 9.5,	--Dragon scale furnace
	lunarthrall_plant = {30, 12,	--Bright eggplant parasitic range
	},
    -- sapling_moon = 30,	--Moon saplings predict the range of bright eggplant parasites
	voidcloth_umbrella = 16,	--Shadow umbrella
	-- phonograph = 8,	--The scope of the vocal machine care for the plant
	moonbase = 8,	--Platform refrigeration range
	lava_pond = 10,	--Magma pool fever
	lighter = 2.5,

	-- The distance to the Pigman must be greater than 12, the distance between the Pigman and the Chicken is 4.8, and the range of the Eye Turret is 18
	junk_pile_big = {16.8, 22.8},
	daywalker2 = 12,
	toadstool_cap = {TUNING.TOADSTOOL_AGGRO_DIST, 28},
}
-- Placement
local placer = {
	lightning_rod_placer = 40,
	eyeturret_item_placer = TUNING.EYETURRET_RANGE+3,
}

return {
    attack_range = attack_range,
	target_range = target_range,
	track_range = track,
	hover_range = hover,
	click_range = click,
	placer_range = placer,
}