if m_util:IsServer() then
    return
end
local save_id, string_drop = "sw_lantern", "Quick drop"
local default_data = {
    birdtrap = true,
    seed = true,
    rock = true,
    range = 4,
    trap = true,
    lantern = true,
    sculp = true,
    lightbulb = true,
    canary = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local lantern_list = {"lantern", "myth_redlantern", "pumpkin_lantern", "redlantern", "miniboatlantern", "bottlelantern"}
local fireSource_list = {"dragonflyfurnace", "stafflight", "staffcoldlight","moonbase"}
local rock_list = {"heatrock", "icire_rock"}
local stalker_list = {"stalker_atrium", "stalker_forest", "stalker"}

m_util:AddBindConf(save_id, function()
    local items = p_util:GetItemsFromAll()
    if not items then return end
    local function getitem(list)
        return t_util:IGetElement(items, function(it)
            return table.contains(list, it.prefab) and it
        end)
    end
    local function getsculp()
        return t_util:GetElement(p_util:GetEquips() or {}, function(_, it)
            return it and it:HasTag("heavy") and it
        end)
    end
    local item = 
    (save_data.sculp and getsculp())
    or (save_data.canary and e_util:FindEnt(nil, "toadstool_cap", save_data.range) and getitem({"canary_poisoned"}))
    or (save_data.birdtrap and getitem({"birdtrap"}))
    or (save_data.seed and e_util:FindEnt(nil, "birdtrap", save_data.range) and getitem({"seeds"}))
    or (save_data.rock and (e_util:FindEnt(nil, fireSource_list, save_data.range) or e_util:FindEnt(nil, nil, save_data.range, {"plant", "fire"},  {"INLIMBO", "FX", "player"}) or e_util:FindEnt(nil, nil, save_data.range, {"campfire", "fire"}, {"INLIMBO", "FX", "player"})) and getitem(rock_list))
    or (save_data.trap and e_util:FindEnt(nil, "rabbithole", save_data.range) and getitem({"trap"}))
    or (save_data.lantern and getitem(lantern_list))
    or (save_data.lightbulb and getitem({"lightbulb"}))
    or (save_data.thurible and e_util:FindEnt(nil, stalker_list, save_data.range) and getitem({"thurible"}))

    if item then
        p_util:DropItemFromInvTile(item, true)
    end
end, true)
m_util:AddBindIcon(string_drop, "lantern_tesla", "Quickly drop the lantern, then start working immediately!", true, function()
    local ui_data = {}
    local idata = t_util:IGetElement(m_util:LoadReBindData(), function(idata)
        return idata.id == save_id..modname and idata
    end)
    if idata then
        idata = t_util:MergeMap(idata)
        idata.label = "Hotkey:"
        idata.hover = "Click to set the binding button"
        table.insert(ui_data, idata)
    end
    table.insert(ui_data, {
        id = "range",
        label = "Judgment scope:",
        hover = "Discarding the judgment range of warm stone, etc.",
        default = fn_get,
        fn = fn_save("range"),
        type = "radio",
        data = t_util:BuildNumInsert(1, 20, 1, function(i)
            return {data = i, description = i}
        end)
    })
    table.insert(ui_data, {
        id = "sculp",
        label = "Statue",
        hover = "Do you discard the statue when bearing weight?",
        default = fn_get,
        fn = fn_save("sculp"),
    })
    table.insert(ui_data, {
        id = "canary",
        label = "Canary",
        hover = "Sick canary dropped near toad",
        default = fn_get,
        fn = fn_save("canary"),
    })
    table.insert(ui_data, {
        id = "birdtrap",
        label = "Bird catch trap",
        hover = "Discard the bird catching trap",
        default = fn_get,
        fn = fn_save("birdtrap"),
    })
    table.insert(ui_data, {
        id = "seed",
        label = "Seed",
        hover = "Discard seeds near the bird catcher",
        default = fn_get,
        fn = fn_save("seed"),
    })
    table.insert(ui_data, {
        id = "rock",
        label = "Warm stone",
        hover = "Discard the warm stone near the heat source or cold source",
        default = fn_get,
        fn = fn_save("rock"),
    })
    table.insert(ui_data, {
        id = "trap",
        label = "Trap",
        hover = "Discard the trap next to the rabbit hole",
        default = fn_get,
        fn = fn_save("trap"),
    })
    table.insert(ui_data, {
        id = "lantern",
        label = "Lamp",
        hover = "The lamp here also includes red lanterns, pumpkin lamps, etc.",
        default = fn_get,
        fn = fn_save("lantern"),
    })
    table.insert(ui_data, {
        id = "lightbulb",
        label = "Fluorescent fruit",
        hover = "Whether the fluorescence fruit is discarded when there is no lamp",
        default = fn_get,
        fn = fn_save("lightbulb"),
    })
    table.insert(ui_data, {
        id = "thurible",
        label = "Shadow furnace",
        hover = "There are only causes or forest guardians or guardians of the cave nearby,",
        default = fn_get,
        fn = fn_save("thurible"),
    })
    m_util:AddBindShowScreen({
        title = string_drop,
        id = save_id,
        data = ui_data,
    })()
end)
