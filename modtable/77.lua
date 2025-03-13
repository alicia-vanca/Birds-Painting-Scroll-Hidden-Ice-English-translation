if (m_util:IsServer() and not m_util:IsLava())or (TheNet:GetIsClient() and not TheNet:GetIsServerAdmin()) then return end
local save_id,str_unlock = "sw_tolock", "Spawn"
local default_data = {
    hover = false
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local function fn_end()
    m_util:PopShowScreen()
    h_util:PlaySound("learn_map")
end
local function do_fn(str)
    str = 'require "debugcommands" '..str
    return function()
        i_util:ExRemote(str)
        fn_end()
    end
end



local screen_data = {{
    id = "1",
    label = "Nightmare Werepig",
    fn = do_fn('d_daywalker(true)'),
    hover = "Spawn Nightmare Werepig (With chain)",
    default = true
},{
    id = "1_1",
    label = "Nightmare Werepig Set",
    fn = do_fn([[
        c_give("hambat", 1)
        c_give("yellowstaff", 1)
        c_give("green_cap", 4)
        c_give("green_cap_cooked", 20)
        c_give("footballhat", 2)
        c_give("multitool_axe_pickaxe", 1)
        c_give("yellowamulet", 1)
    ]]),
    hover = "Spawn Nightmare Werepig item set",
    default = true
},{
    id = "2",
    label = "C.C altars",
    hover = "Spawn the 3 altars to summon Celestial Champion",
    default = true,
    fn = do_fn([[
	local offset = 7
	local pos = ConsoleWorldPosition()
	local altar 
    
    altar = SpawnPrefab("moon_altar")
	altar.Transform:SetPosition(pos.x, 0, pos.z - offset)
	altar:set_stage_fn(2)
    
	SpawnPrefab("moon_altar_idol").Transform:SetPosition(pos.x, 0, pos.z - offset - 2)

	altar = SpawnPrefab("moon_altar_astral")
	altar.Transform:SetPosition(pos.x - offset, 0, pos.z + offset / 3)
	altar:set_stage_fn(2)

	altar = SpawnPrefab("moon_altar_cosmic")
	altar.Transform:SetPosition(pos.x + offset, 0, pos.z + offset / 3)

    c_give("wagpunk_bits", 4)
    c_give("moonstorm_spark", 10)
    c_give("moonglass_charged", 30)
    c_give("moonstorm_static_item", 1)
    c_give("moonrockseed", 1)
    ]])
},{
    id = "2_1",
    label = "Celestial Champion Set",
    fn = do_fn([[
    c_give("hambat", 1)
    c_give("armorwood", 2)
    c_give("skeletonhat", 1)
    c_give("cane", 1)
    ]]),
    hover = "Spawn Celestial Champion item set",
    default = true
},{
    id = "3",
    label = "Crazy Pig Refresh",
    fn = do_fn([[
    local fws = TheWorld and TheWorld.components.forestdaywalkerspawner
    local sds = TheWorld and TheWorld.shard and TheWorld.shard.components.shard_daywalkerspawner
    if fws and sds then
        sds:SetLocation("forestjunkpile")
        fws.days_to_spawn = 0
    end
    ]]),
    hover = "Refresh the Scrappy Werepig immediately\nLimited Forest",
    default = true
},{
    id = "4",
    label = "Toadstool Set",
    fn = do_fn([[
    c_give("hambat", 1)
    c_give("goldenaxe", 2)
    c_give("yellowstaff", 1)
    c_give("canary_poisoned", 1)
    c_give("lantern", 1)
    c_give("icestaff", 1)
    c_give("eyeturret_item", 2)
    c_give("green_cap_cooked", 10)
    ]]),
    hover = "Spawn Toadstool item set",
    default = true
},{
    id = "5",
    label = "Crab King Set",
    fn = do_fn([[
    c_give("hambat", 1)
    c_give("hermit_pearl", 1)
    c_give("purplegem", 8)
    c_give("boat_item", 1)
    c_give("ocean_trawler_kit", 2)
    c_give("oar", 1)
    c_give("armorwood", 1)
    c_give("walrushat", 1)
    c_give("blowdart_pipe", 6)
    ]]),
    hover = "Spawn Crab King item set",
    default = true
},}

-- c_give("icestaff", 1)                    Ice Staff
-- c_give("footballhat", 2)                 Pigskin Helmet
-- c_give("panflute", 1)                    Pan Flute
-- c_give("multitool_axe_pickaxe", 1)       Thulecite Axe
-- c_give("goldenshovel", 1)                Golden Shovel
-- c_give("cane", 1)                        Cane
-- c_give("armormarble", 1)                 Marble Armor
-- c_give("perogies", 10)                   Pierogies
-- c_give("wall_stone_item", 60)            Stone Wall
-- c_give("lantern", 1)                     Lantern
-- c_give("eyeturret_item", 2)              Eye Turret


local fn_left = m_util:AddBindShowScreen({
    title = str_unlock,
    id = "hx_" .. save_id,
    data = screen_data
})

m_util:AddBindIcon(str_unlock, "blueprint_craftingset_ruins_builder", "Some console commands, for administrators only", true, fn_left, nil, 9996)