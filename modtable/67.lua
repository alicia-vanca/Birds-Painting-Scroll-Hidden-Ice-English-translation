local save_id, map_str = "map_wormhole", "Wormhole mark"
local default_data = {
    sw = true,
    addcolor = true,
    addtext = true,
    scale = 35,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local prefabs = require("data/mapicons").wormhole_data
local map_data = {}
local iscave
local function GetIcon(num)
    return iscave and "tentacle_pillar_"..num or "wormhole_"..num
end

local Colors = { "Red", "Breathing orange", "Golden", "Green", "Breathing blue", "Bright blue", "Breathing purple","Blue", "Breathing"}
local function ChanWormhole(inst)
    local id = e_util:GetPosID(inst)
    if not id then return end
    local num = map_data[id] and map_data[id].num
    if num then
        -- Dyeing
        h_util.SetAddColor(inst, save_data.sw and save_data.addcolor and Colors[num])
        -- Numeral
        h_util:AddText(inst, save_data.sw and save_data.addtext and num, nil, nil, nil, Colors[num])
    end
end


Mod_ShroomMilk.Func.GetWormholeData = function(inst)
    local id = e_util:GetPosID(inst)
    local num = id and map_data[id] and map_data[id].num
    if num then
        return save_data.sw and {
            num = num,
            icon = GetIcon(num),
            rgb =  save_data.addcolor and Colors[num]
        }
    end
end

t_util:IPairs(prefabs, function(prefab)
    AddPrefabPostInit(prefab, function(inst)
        inst:DoTaskInTime(0.5, ChanWormhole)
    end)
end)
local function ChanWormholes()
    t_util:IPairs(e_util:FindEnts(nil, prefabs), ChanWormhole)
end
local function ClearWormholes()
    -- Delete memory
    t_util:Pairs(map_data, function(k)
        map_data[k] = nil
    end)
    -- Clean the ground
    local color, text = save_data.addcolor, save_data.text
    save_data.addcolor = false
    save_data.addtext = false
    ChanWormholes()
    save_data.addcolor, save_data.addtext = color, text
    -- Clean up a map
    local saver = m_util:GetSaver()
    if saver then
        saver:ClearHMap(save_id)
    end
end
i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    iscave = world:HasTag("cave")
    saver:RegHMap(save_id, map_str, "Whether to display "..map_str.." Icon", function()return save_data.sw end, function(show)
        fn_save("sw")(show)
        if world.ismastersim then
            t_util:Pairs(Ents, function(id, ent)
                if table.contains(prefabs, ent.prefab) then
                    ChanWormhole(ent)
                end
            end)
        else
            ChanWormholes()
        end
    end, {
        screen_data = {
            {
                id = "addcolor",
                label = "Highlight wormhole",
                fn = function(v)
                    fn_save("addcolor")(v)
                    ChanWormholes()
                end,
                hover = "Whether to highlight the wormhole on the ground",
                default = fn_get,
            },
            {
                id = "addtext",
                label = "Numbering wormhole",
                fn = function(v)
                    fn_save("addtext")(v)
                    ChanWormholes()
                end,
                hover = "Whether to numbering the wormhole on the ground",
                default = fn_get,
            },
            {
                id = "delete",
                label = "Clean up",
                fn = function()
                    h_util:CreatePopupWithClose("Warn", "Are you sure you want to clear all the wormhole marks?", {{text = "Cancel"}, {text = "Confirm", cb = ClearWormholes}})
                end,
                hover = "Dangerous operation",
                type = "textbtn",
                default = "Clear marks",
            },
            {
                id = "scale",
                label = "Icon size:",
                fn = fn_save("scale"),
                hover = "The size of the wormhole icon in the map\n[Restart the game] to take effect\nIt's recommended to go to [Map Icon] and set [All Icon Size], instead of modifying this",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(1, 50, 1, function(i)
                    return {
                        data = i,
                        description = i .. " Pixel"
                    }
                end)
            },
        },
        scale = save_data.scale*0.1,      -- Byd found that the icon size is not right
    })
    -- Inlet load
    map_data = saver:GetMap(save_id, true)
    -- {x, z, num}
    t_util:Pairs(map_data, function(_, info)
        saver:AddHMap(save_id, {
            x = info.x,
            z = info.z,
            icon = GetIcon(info.num) 
        })
    end)
end)
local function GetNearWormhole()
    return e_util:FindEnt(nil, prefabs, 4)
end
AddPrefabPostInit("player_classified", function(pc)
    pc:ListenForEvent("wormholetraveldirty", function(pc)
        -- Only marked the insect hole that has not been marked
        local wormhole_in = GetNearWormhole()
        local id_in = e_util:GetPosID(wormhole_in)
        if not id_in or map_data[id_in] then return end
        local x_in, _, z_in = wormhole_in.Transform:GetWorldPosition()
        -- The upper limit of the mark is the upper limit of color (9)
        local num = 1
        t_util:Pairs(map_data, function(_, info)
            if info.num >= num then
                num = info.num+1
            end
        end)
        if num > #Colors then return end
        -- 5s detection
        e_util:WaitToDo(pc, 0.5, 10, function()
            local wormhole = GetNearWormhole()
            return wormhole and wormhole ~= wormhole_in and wormhole
        end, function(wormhole_out)
            local id_out = e_util:GetPosID(wormhole_out)
            if not id_out or map_data[id_out] then return end
            local x_out, _, z_out = wormhole_out.Transform:GetWorldPosition()
            -- Save data
            map_data[id_in] = {
                x = x_in,
                z = z_in,
                num = num,
            }
            map_data[id_out] = {
                x = x_out,
                z = z_out,
                num = num,
            }
            -- Dyeing标记
            ChanWormhole(wormhole_in)
            ChanWormhole(wormhole_out)
            -- Increase icon
            local saver = m_util:GetSaver()
            if saver then
                saver:AddHMap(save_id, {
                    x = x_in,
                    z = z_in,
                    icon = GetIcon(num) 
                }, true)
                saver:AddHMap(save_id, {
                    x = x_out,
                    z = z_out,
                    icon = GetIcon(num) 
                }, true)
            end
        end)
    end)
end)