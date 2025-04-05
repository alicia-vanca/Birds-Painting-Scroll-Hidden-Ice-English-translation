local Intor = require "widgets/huxi/huxi_indicator"
local V = require "data/valuetable"
local list_boss = require "data/itemlist_boss"
list_boss = t_util:MergeList(list_boss)
t_util:Sub(list_boss, "deciduoustree")      -- The T key does not spawn birch spirits normally
t_util:Add(list_boss, "beequeenhivegrown")
local list_dirtpile = {"dirtpile"}
local list_wormhole = require("data/mapicons").wormhole_data
local list_item = require "data/itemlist_indicator"
local list_inbox = {"inspectaclesbox","inspectaclesbox2",}
local toy_trinket_nums = {1,2,7,10,11,14,18,19,42,43,}
local toys =
{
    "lost_toy_1",
    "lost_toy_2",
    "lost_toy_7",
    "lost_toy_10",
    "lost_toy_11",
    "lost_toy_14",
    "lost_toy_18",
    "lost_toy_19",
    "lost_toy_42",
    "lost_toy_43",
}
local list_sea = t_util:MergeList(toys, {"underwater_salvageable", "pirate_stash", "messagebottle"})
local list_prefab = t_util:MergeList(list_boss, list_dirtpile, list_sea, list_item, list_wormhole, list_inbox)


local save_id, str_show = "sw_indicator", "Directions"
local default_data = {
    sw = true,
    min_scale = 0.5,
    max_scale = 1,
    clickable = true,
    color_boss = "Tomato",
    color_dirtpile = "Lavender",
    color_sea = "Breathing blue",
    color_item = "White",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local Intors = {}

local function KillIndicator(inst)
    if t_util:GetRecur(Intors[inst], "Kill") then
        Intors[inst]:Kill()
    end
    Intors[inst] = nil
end

-- Click to run
local dist_click = 60
local function fn_walk(inst)
    return function()
        local data = p_util:GetMouseActionClick(inst)
        if not data then return end
        local act_str = data.act:GetActionString() or ""
        local name = e_util:GetPrefabName(data.target.prefab, data.target) or ""
        u_util:Say(act_str .. " " .. name, nil, "head", nil, true)
        d_util:RemoteClick(data)
    end
end

-- Management indicator: If it is off, no regulation is performed, but the entity is marked as true so that it can be adjusted at any time
local function AddIndicator(inst)
    KillIndicator(inst)
    if save_data.sw then
        local root = ThePlayer and ThePlayer.HUD and ThePlayer.HUD.under_root
        if not root then return end
        local xml, tex, name = h_util:GetPrefabAsset(inst.prefab)
        local fn_left = save_data.clickable and fn_walk(inst)
        local meta = {min_scale = save_data.min_scale, max_scale = save_data.max_scale, color = save_data.color_item}
        local prefab = inst.prefab

        if table.contains(list_boss, prefab) then
            meta.color = save_data.color_boss
        elseif table.contains(list_dirtpile, prefab) then
            meta.color = save_data.color_dirtpile
            if prefab == "dirtpile" then
                local func = Mod_ShroomMilk.Func.ACTIVATE_ANIMAL_TRACK
                if func and fn_left then
                    fn_left = func
                end
            end
        elseif table.contains(list_sea, prefab) then
            meta.color = save_data.color_sea
            if prefab == "underwater_salvageable" then
                xml, tex, name = h_util:GetPrefabAsset("sunkenchest")
            end
        elseif table.contains(list_inbox, prefab) then
            xml, tex, name = h_util:GetPrefabAsset("inspectacleshat")
            name = e_util:GetPrefabName(prefab)
        elseif table.contains(list_wormhole, prefab) then
            local func = Mod_ShroomMilk.Func.GetWormholeData
            if func then
                local data = func(inst)
                if data then
                    meta.color = data.rgb
                    xml, tex = h_util:GetPrefabAsset(data.icon)
                    name = inst.name.." "..data.num
                else
                    local skin_bd = inst.AnimState and inst.AnimState:GetSkinBuild()
                    if skin_bd and skin_bd ~= "" then
                        xml, tex = h_util:GetPrefabAsset(skin_bd)
                    end
                end
            else
                local skin_bd = inst.AnimState and inst.AnimState:GetSkinBuild()
                if skin_bd and skin_bd ~= "" then
                    xml, tex = h_util:GetPrefabAsset(skin_bd)
                end
            end
        elseif prefab == "mandrake_planted" then
            xml, tex, name = h_util:GetPrefabAsset("mandrake")
        end
        Intors[inst] = root:AddChild(Intor(inst, xml, tex, name, {fn_left = fn_left}, meta))
    else
        Intors[inst] = true
    end
end


local function AddModIndicator(inst, xml, tex, name, funcs, meta)
    if save_data.sw then
        local root = ThePlayer and ThePlayer.HUD and ThePlayer.HUD.under_root
        if not root then return end
        local meta_fill = {min_scale = save_data.min_scale, max_scale = save_data.max_scale, color = save_data.color_item}
        local funcs_fill = {fn_left = save_data.clickable and fn_walk(inst)}
        root:AddChild(Intor(inst, xml, tex, name, t_util:MergeMap(funcs_fill, funcs or {}), t_util:MergeMap(meta_fill, meta or {})))
    end
end

-- pos{x, z}
local function AddIconIndicator(icon, pos, funcs, meta)
    local xml, tex, name = h_util:GetPrefabAsset(icon)
    if xml then
        local funcs_fill = {fn_left = function(ui, target) ui:Kill() end}
        local inst = e_util:SpawnNull()
        inst.entity:AddTransform()
        inst:AddTag("FX")
        inst.Transform:SetPosition(pos.x, 0, pos.z)
        AddModIndicator(inst, xml, tex, name, t_util:MergeMap(funcs_fill, funcs or {}), meta)
    end
end

Mod_ShroomMilk.Func.AddModIndicator = AddModIndicator
Mod_ShroomMilk.Func.AddIconIndicator = AddIconIndicator

local function fn_set(id)
    return function(val)
        fn_save(id)(val)
        t_util:Pairs(Intors, AddIndicator)
    end
end

-- Listening Entity
local function ListenForInst(inst)
    local pusher = m_util:GetPusher()
    if not pusher then return end
    pusher:RegNearStart(inst, function()
        AddIndicator(inst)
    end, function()
        KillIndicator(inst)
    end)
end

t_util:IPairs(list_prefab, function(prefab)
    AddPrefabPostInit(prefab, function(inst)
        inst:DoTaskInTime(0, ListenForInst)
    end)
end)

local function fn_left()
    save_data.sw = not save_data.sw
    u_util:Say(str_show, save_data.sw)
    t_util:Pairs(Intors, AddIndicator)
    fn_set("sw")(save_data.sw)
end

local scale_data = t_util:BuildNumInsert(0.1, 4, 0.1, function(i)
    return {data = i, description = i}
end)
local screen_data = {
    {
        id = "sw",
        label = "Main switch",
        hover = "Whether to display the indicator",
        default = fn_get,
        fn = fn_set("sw")
    },
    {
        id = "clickable",
        label = "Support click",
        hover = "Click the indicator to automatically reach",
        default = fn_get,
        fn = fn_set("clickable")
    },
    {
        id = "min_scale",
        label = "Minimum zoom：",
        hover = "The minimum size of the direction mark, default: " .. default_data.min_scale,
        default = fn_get,
        type = "radio",
        data = scale_data,
        fn = fn_set("min_scale")
    },
    {
        id = "max_scale",
        label = "Maximum zoom：",
        hover = "The maximum size of the direction mark, default: " .. default_data.max_scale,
        default = fn_get,
        type = "radio",
        data = scale_data,
        fn = fn_set("max_scale")
    },{
        id = "color_boss",
        label = "Boss：",
        hover = "Boss indicator color, default: " .. default_data.color_boss,
        default = fn_get,
        type = "radio",
        data = V.RGB_datatable,
        fn = fn_set("color_boss"),
    },{
        id = "color_dirtpile",
        label = "Footprint：",
        hover = "Footstep indicator color， default: " .. default_data.color_dirtpile,
        default = fn_get,
        type = "radio",
        data = V.RGB_datatable,
        fn = fn_set("color_dirtpile"),
    },{
        id = "color_sea",
        label = "Ocean props：",
        hover = "Indicator color of ocean treasures， default: " .. default_data.color_sea,
        default = fn_get,
        type = "radio",
        data = V.RGB_datatable,
        fn = fn_set("color_sea"),
    },{
        id = "color_item",
        label = "Other：",
        hover = "Other indicator color， default: " .. default_data.color_item,
        default = fn_get,
        type = "radio",
        data = V.RGB_datatable,
        fn = fn_set("color_item"),
    },
    {
        id = "readme",
        label = "Special thanks!",
        fn = function()
            h_util:CreatePopupWithClose("󰀍"..str_show.." · Special Thanks󰀍",
                "This feature is specially customized by the player 虾远山\n\nMessage: Haha, had a great time. 远山 was here!", {{
                    text = h_util.ok
                }})
        end,
        hover = "Special Thanks",
        default = true
    },
}
local fn_right = m_util:AddBindShowScreen({
    title = str_show,
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, fn_left, nil, {str_show, "arrowsign_post_factory",
                                           STRINGS.LMB .. 'Quick switch' .. STRINGS.RMB .. 'Advanced settings', true, fn_left,
                                           fn_right})
