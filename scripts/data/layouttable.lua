-- path: File path string table
-- Replaced with path: layout name
-- icon: Icon string table
-- *only: Unique, query whether to terminate bool
-- *roomicon: Identifier, used for node check
-- *alone: Applicable to symmetrical, but not only
local forest_terr = {
    {
        path = "DefaultPigking",
        room = "DefaultPigking",
        icon = "pigking",
        only = true,
        roomicon = "pigking"
    },
    {
        path = "DragonflyArena",
        icon = {"dragonfly_spawner", "lava_pond"},
        only = true,
        roomicon = "dragonfly",
        room = "DragonflyArena",
    }, 
    {
        path = {"Charlie1", "Charlie2"},
        icon = {"charlie_stage_post","statueharp_hedgespawner"},
        only = true,
    }, 
    {
        -- w_util:d_spawnlayout("Dev Graveyard")
        path = {"Dev Graveyard"},
        icon = {"marblepillar", "statuemaxwell", },
        only = true,
    }, 
    {
        path = {"Balatro"},
        icon = {"balatro_machine", },
        only = true,
    }, 
    {
        path = {"Chessy_1", "Chessy_2", "Chessy_3", "Chessy_4", "Chessy_5", "Chessy_6", },
        icon = {"marbletree", "knight", "bishop", "gears", "statuemaxwell", "rook", "backpack", "marblepillar", 
               "statueharp", "sculpture_rook", "statue_marble_muse", "statue_marble_pawn", "sculpture_bishop",
               "sculpture_knight"},
        only = true,
        deny = {WORLD_TILES.CARPET, WORLD_TILES.CHECKER},
    }, 
    {
        path = {"Maxwell1", "Maxwell2", "Maxwell3", "Maxwell4", "Maxwell5", "Maxwell6", "Maxwell7", },
        icon = {"statuemaxwell", "marbletree", "knight", "bishop", "gears", "statuemaxwell", "rook", "backpack", "marblepillar", 
               "statueharp", "sculpture_rook", "statue_marble_muse", "statue_marble_pawn", "sculpture_bishop",
               "sculpture_knight"},
        only = true,
        deny = {WORLD_TILES.CARPET, WORLD_TILES.CHECKER},
    }, 
    {
        path = {"Sculptures_1", "Sculptures_2", "Sculptures_3", "Sculptures_4", "Sculptures_5", },
        icon = {"sculpture_rook", "marbletree", "knight", "bishop", "gears", "rook", "backpack", "marblepillar", 
               "statueharp",  "statue_marble_muse", "statue_marble_pawn", "sculpture_bishop",
               "sculpture_knight"},
        only = true,
        deny = {WORLD_TILES.CARPET, WORLD_TILES.CHECKER},
    }, 
    {
        path = "HermitcrabIsland",
        room = "HermitcrabIsland",
        icon = "hermithouse_construction1",
        only = true,
        roomicon = "hermithouse_construction1"
    },
    {
        path = "AntlionSpawningGround",
        room = "LightningBluffAntlion",
        icon = "antlion_spawner",
        only = true,
        roomicon = "antlion"
    },
    {
        path = "CaveEntrance",
        icon = "cave_entrance",
        deny = {WORLD_TILES.DIRT}, -- This tag will exclude these tiles
        layer = 1,
        alone = true,
    },
    {
        path = "ResurrectionStone",
        icon = "resurrectionstone",
        deny = {WORLD_TILES.WOODFLOOR},
        layer = 1,
        alone = true,
    },
    -- {
    --     path = "MonkeyIsland",
    --     room = "MonkeyIsland",
    --     icon = "monkeyqueen",
    --     only = true,
    --     roomicon = "monkeyqueen",
    --     layer = -10,
    -- },
    {
        path = "junk_yard",
        icon = {"junk_pile_big", "junk_pile"},
        only = true,
        deny = {WORLD_TILES.DIRT},

    },
    {
        path = "MoonbaseOne",
        room = "MoonbaseOne",
        icon = "moonbase",
        only = true,
        roomicon = "moonbase"
    },
    {
        path = "Oasis",
        room = "LightningBluffOasis",
        icon = "oasislake",
        only = true,
        roomicon = "oasis"
    },
}
local cave_terr = {
    {
        path = "ResurrectionStone",
        icon = "resurrectionstone",
        deny = {WORLD_TILES.WOODFLOOR},
        layer = 1,
        alone = true,
    },
    {
        path = "TentaclePillar",
        icon = "wormhole_MARKER",
        deny = {WORLD_TILES.MARSH},
        layer = 1
    },
    {
        path = {"RabbitCity", "RabbitHermit", "RabbitTown"},
        icon = "rabbithouse",
        alone = true,
    },
    {
        path = "WalledGarden",
        icon = {"minotaur_spawner", "ruins_statue_mage_spawner"},
        only = true,
        room = "RuinedGuarden",
        room_icon = "minotaur",
    },
    {
        path = {"AltarRoom", "BrokenAltar", "Barracks2", "SacredBarracks", "Spiral", "MilitaryEntrance"},
        icon = {"chessjunk_spawner", "ancient_altar_spawner", "sacred_chest","ruins_statue_head_spawner", 
            "ruins_statue_head_nogem_spawner","ruins_statue_mage_nogem_spawner", "ruins_statue_mage_spawner", "ancient_altar_broken_spawner",
            "bishop_nightmare_spawner", "rook_nightmare_spawner", "knight_nightmare_spawner"},
        alone = true,
    },
    {
        path = "map/static_layouts/rooms/atrium_end/atrium_end",
        icon = "atrium_gate",
        only = true,
    },
    {
        path = {"TentaclePillarToAtrium", "TentaclePillarToAtriumOuter"},
        icon = {"tentacle_pillar_atrium", "bishop_nightmare"},
        only = true,
    },
    -- 
}
-- room/all
-- icon: Icon string
local forest_node ={
    {
        room = "Waspnests",
        icon = "wasphive",
    },
    {
        all = "WalrusHut_",
        icon = "walrus_camp",
    },
    {
        room = "SpiderVillage",
        icon = "spidereggsack",
    },
    {
        room = "PigVillage",
        icon = "pighouse",
    },
    {
        room = "BeefalowPlain",
        icon = "beefalo",
    },
    {
        room = "MandrakeHome",
        icon = "mandrake",
    },
    {
        room = "HoundyBadlands",
        icon = "houndmound",
    },
    {
        room = "Graveyard",
        icon = "gravestone",
    },
    {
        room = "LightningBluffLightning",
        icon = "lightninggoat",
    },
    {
        room = "LightningBluffOasis",
        icon = "oasis",
    },
    {
        room = "LightningBluffAntlion",
        icon = "antlion",
    },
    {
        room = "MoonIsland_Forest",
        icon = "moon_tree",
    },
    {
        room = "MoonIsland_Baths",
        icon = "hotspring",
    },
    {
        room = "MoonIsland_Meadows",
        icon = "moonglass_rock",
    },
    {
        room = "MoonIsland_Mine",
        icon = "rock_moon",
    },
    {
        room = "MoonIsland_Beach",
        icon = "bullkelp_plant",
    },
    {
        room = "MoonIsland_IslandShard",
        icon = "driftwood_log",
    },
    {
        room = "Pondopolis",
        icon = "frog",
    },
    {
        room = "BeeQueenBee",
        icon = "beequeenhivegrown",
    },
    {
        room = "MooseGooseBreedingGrounds",
        icon = "mooseegg",
    },
    {
        room = "PigKingdom",
        icon = "pigking",
    },
    {
        room = "MagicalDeciduous",
        icon = "glommer",
    },
    {
        room = "ForestMole",
        icon = "mole",
    },
    {
        room = "MoonbaseOne",
        icon = "moonbase",
    },
    {
        room = "DragonflyArena",
        icon = "dragonfly",
    },
    {
        room = "MonkeyIsland",
        icon = "monkey_queen",
    },
    {
        room = "HermitcrabIsland",
        icon = "hermithouse_construction1",
    },
    {
        all = "Squeltch:BG_",
        icon = "tentacle",
    },
-- Marsh:沼泽？但BGMarsh不是
}

local cave_node = {
    {
        all = "START",
        icon = "multiplayer_portal",
    },
    {
        task = {"ToadStoolTask1", "ToadStoolTask2", "ToadStoolTask3"},
        icon = "toadstool_cap",
    },
    {
        room = {"SlurtlePlains", "SlurtleCanyon", "BatsAndSlurtles"},
        icon = "slurtlehole",
    },
    {
        room = "CaveExitRoom",
        icon = "cave_open2",
    },
    {
        room = "BrokenAltar",
        icon = "ancient_altar_broken",
    },
    {
        room = "Altar",
        icon = "ancient_altar",
    },
    {
        room = "Bishops",
        icon = "bishop_nightmare",
    },
    {
        room = "SacredBarracks",
        icon = "rook_nightmare",
    },
    {
        room = "Barracks",
        icon = "knight_nightmare",
    },
    {
        room = {"MudWithRabbit", "RabbitTown", "RabbitCity", "RabbitArea", "GreenMushRabbits"},
        icon = "rabbithouse",
    },
    {
        room = "WormPlantField",
        icon = "flower_cave_double",
    },
    {
        room = "LightPlantField",
        icon = "flower_cave_triple",
    },
    {
        room = {"RedMushPillars", "RedMushForest", "BGRedMush"},
        icon = "mushtree_medium",
    },
    {
        room = {"BGBlueMush", "BlueMushForest", "BlueMushMeadow", "BlueSpiderForest"},
        icon = "mushtree_tall",
    },
    {
        room = {"GreenMushForest", "GreenMushSinkhole", "GreenMushMeadow", "GreenMushPonds", "BGGreenMush"},
        icon = "mushtree_small",
    },
    {
        room = {"MoonCaveForest", "MoonMushForest_entrance", "MoonMushForest",},
        icon = "mushtree_moon",
    },
    {
        room = "FernyBatCave",
        icon = "batcave",
    },
    {
        room = {"SpillagmiteMeadow", "SpillagmiteForest"},
        icon = "stalagmite",
    },
    {
        room = {"DropperDesolation", "DropperCanyon"},
        icon = "spider_dropper",
    },
    {
        room = {"RockyHatchingGrounds", "RockyPlains"},
        icon = "rocky",
    },
    {
        room = "Vacant",
        icon = "monkeybarrel",
    },
    {
        room = "SinkholeOasis",
        icon = "pond",
    },
    {
        room = {"SpidersAndBats", "BGSpillagmiteRoom", "SpillagmiteForest"},
        icon = "spiderhole",
    },
    {
        room = "WetWilds",
        icon = "pond_cave",
    },
    {
        room = "LichenLand",
        icon = "lichen",
    },
    {
        room = "LichenMeadow",
        icon = "worm",
    },
    {
        room = "RuinedGuarden",
        icon = "minotaur_spawner",
    },
    -- Entrance does not need to be displayed, see Fenghua Chapter tile scan
    -- {
    --     room = "ArchiveMazeEntrance",
    --     icon = "archive_moon_statue",
    -- },
}

-- icon Icon string
-- *range Aggregation range int
-- *getnew Refresh every time
local foreset_tile = {
    OCEAN_BRINEPOOL = {
        range = 12,
        icon = "saltstack",
    },
    OCEAN_WATERLOG = {
        icon = "oceantree_pillar",
    },
    -- Klei official added icon
    -- RIFT_MOON = {
    --     icon = "lunarrift_portal",
    --     getnew = true,
    -- },
    OCEAN_ICE = {
        icon = "sharkboi",
        getnew = true,
    },
}
local cave_tile = {
    ARCHIVE = {
        range = 12,
        icon = "archive_orchestrina_main",
    }
}

local order_icon = {
    "lunarrift_portal", "wasphive", "walrus_camp", "spidereggsack", "toadstool_cap",
    "sharkboi", "oceantree_pillar", "saltstack",
}

local icon_chs = {
    wasphive = "Killer Bee Area",
    spidereggsack = "Spider Area",
    pighouse = "Pig Village",
    beefalo = "Beefalo Herd",
    gravestone = "Graveyard",
    lightninggoat = "Volt Goat Herd",
    oasis = "Oasis",
    antlion = "Antlion Spawn Point",
    moon_tree = "Moon Tree Cluster",
    rock_moon = "Moon Rock",
    driftwood_log = "Driftwood Island",
    frog = "Frog Pond",
    mooseegg = "Moose/Goose Nest",
    monkey_queen = "Monkey Island",
    hermithouse = "Hermit Crab's Home",
    toadstool_cap = "Toadstool Spawn Point",
    cave_open2 = "Stairs",
    bishop_nightmare = "Nightmare Bishop Cluster 1", 
    rook_nightmare = "Nightmare Rook Cluster 2", 
    knight_nightmare = "Nightmare Knight Cluster 3", 
    rabbithouse = "Rabbit Cluster", 
    flower_cave_double = "Double Light Flower",
    flower_cave_triple = "Triple Light Flower",
    mushtree_medium = "Red Mushroom Forest",
    mushtree_tall = "Blue Mushroom Forest",
    mushtree_small = "Green Mushroom Forest",
    mushtree_moon = "Moonlight Mushroom Forest",
    dragonfly_spawner = "Dragonfly",
    marblepillar = "Developer's Graveyard",
    marbletree = "Chess Piece Easter Egg",
    sculpture_rook = "Shadow Piece Easter Egg",
    statuemaxwell = "Maxwell Easter Egg",
    hermithouse_construction1 = "Hermit Crab's Home",
    antlion_spawner = "Antlion Spawn Point",
    cave_entrance = "Cave Entrance",
    resurrectionstone = "Resurrection Stone",
    junk_pile_big = "Junk Pile",
    oasislake = "Oasis",
    wormhole_MARKER = "Tentacle",
    minotaur_spawner = "Ancient Guardian",
    chessjunk_spawner = "Nightmare Clockwork",
    atrium_gate = "Atrium",
    tentacle_pillar_atrium = "Atrium Tentacle",
    saltstack = "Salt Mine",
    oceantree_pillar = "Waterlog Tree",
    lunarrift_portal = "Lunar Rift",
    archive_orchestrina_main = "Archive Orchestrina",
}

return {
    terr = {
        forest = forest_terr,
        cave = cave_terr,
    },
    node = {
        forest = forest_node,
        cave = cave_node,
    },
    tile = {
        forest = foreset_tile,
        cave = cave_tile,
    },
    order = order_icon,
    chs = icon_chs,
}
