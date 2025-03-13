local save_id, string_seed = "sw_nutrients", "Nutrients"
local HxNut = require "widgets/huxi/hx_nut"
local default_data = {
    color_weed = "Refractory brick color",
    color_pick = "Primary color/black",
    color_mois = "Blue",
    color_tend = "Coral",
    color_fer = "Green",
    scale = 1,
    x = 0,
    y = 0,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS

local function GetNut(crop)
    return e_util:TileEnts(crop, "nutrients_overlay", nil, {})[1]
end
local function GetMoisture(nut)
    local wet = nut and nut.AnimState and nut.AnimState:GetCurrentAnimationTime() or 1
    return wet < 0 and 0 or (wet > 1 and 1 or wet)
end
local function GetFertilities(nut)
    local nutrientlevels = nut and nut.nutrientlevels and nut.nutrientlevels:value()
    -- Prefabs \nutrients_overlay.lua 17 lines
    -- 4：100% 3：50% 2:25% 1:%1 0:0%
    return nutrientlevels and {
        bit.band(nutrientlevels, 7),                    -- Long agent
        bit.band(bit.rshift(nutrientlevels, 3), 7),     -- Compost
        bit.band(bit.rshift(nutrientlevels, 6), 7),     -- Poop
    }
end
local function GetCropColor(crop)
    if crop:HasTag("weed") then
        return save_data.color_weed
    elseif crop:HasTag("pickable") then
        return save_data.color_pick
    elseif crop:HasTag("tendable_farmplant") then
        return save_data.color_tend
    end
    local nut = GetNut(crop)
    if GetMoisture(nut) <= 0 then
        return save_data.color_mois
    end
    local fertility = GetFertilities(nut) or {}
    if t_util:IGetElement(fertility, function(num)
        return num == 0
    end) then
        return save_data.color_fer
    end
end
local function GetCropPreafb(crop)
    local prefab = crop.prefab
    local farm_plant = prefab:match("^farm_plant_(.*)")
    return farm_plant or prefab
end
local function GetCropsData(core)
    local farm_plants = e_util:TileEnts(core, nil, {"farm_plant"})
    local crops = {}
    for i = 0, 3 do
        crops[i] = 0
    end
    t_util:IPairs(farm_plants, function(crop)
        local prefab = GetCropPreafb(crop)
        local data = WEED_DEFS[prefab] or PLANT_DEFS[prefab]
        -- m_util:print(prefab, data)
        data = data or {
            moisture = {drink_rate = -0.02},
            nutrient_consumption = {1, 1, 1}
        }
        local moisture = t_util:GetRecur(data, "moisture.drink_rate")
        moisture = tonumber(moisture)
        if moisture then
            crops[0] = crops[0] + moisture*10
        end
        local nuts_con = data.nutrient_consumption
        if nuts_con then
            local sum, null = 0, 0
            for i = 1,3 do
                local con = tonumber(nuts_con[i])
                if con then
                    if con == 0 then
                        null = null + 1
                    else
                        sum = sum + con -- 正数为2
                    end
                end
            end
            for i = 1, 3 do
                local con = tonumber(nuts_con[i])
                if con then
                    if con == 0 and null~=0 then
                        crops[i] = crops[i] + sum/null/10
                    else
                        crops[i] = crops[i] - con/10
                    end
                end
            end
        end
    end)
    return crops
end

local data_fer = {
    [0] = {0, "0"},
    [1] = {0.1, "1%+"},
    [2] = {0.3, "25%+"},
    [3] = {0.55, "50%+"},
    [4] = {1, "100%"}
}
local function RreshNut(player)
    local hud = player.HUD
    if hud then
        local nut = hud.hx_nut
        if nut then
            local soil = GetNut(player)
            if soil then
                local wet = GetMoisture(soil)
                if wet then
                    nut.f0.SetText(string.format("%d%%", wet*100))
                    nut.f0.SetPercent(wet)
                end
                local fer = GetFertilities(soil)
                if fer then
                    for i = 1,3 do
                        if fer[i] then
                            local bd = nut["f"..i]
                            bd.SetText(data_fer[fer[i]][2])
                            bd.SetPercent(data_fer[fer[i]][1])
                        end
                    end
                end
                local crops = GetCropsData(player)
                if crops then
                    for i = 0, 3 do
                        local bd = nut["f"..i]
                        if c_util:NumIn(crops[i], -0.01, 0.01) then
                            bd.SetStr(0)
                        else
                            bd.SetStr(string.format("%.2f", crops[i]))
                        end
                    end
                end
            else
                for i = 0,3 do
                    local bd = nut["f"..i]
                    bd.SetText()
                    bd.SetStr()
                    bd.SetPercent()
                end
            end
        else
            hud.hx_nut = hud:AddChild(HxNut(save_data.scale))
            hud.hx_nut:SetPosition(save_data.x or 0, save_data.y or 0, 0)
            h_util:ActivateUIDraggable(hud.hx_nut, function(pos)
                s_mana:SaveSettingLine(save_id, save_data, {x = pos.x, y = pos.y})
            end)
        end
    end
end
local function fn()
    -- Filter switch
    local pusher = ThePlayer and ThePlayer.components.hx_pusher
    local n_over = t_util:GetRecur(ThePlayer or {}, "HUD.nutrientsover")
    if not (n_over and pusher) then return end
    if pusher:GetNowTask() then
        return pusher:StopNowTask()
    end
    local enabled = not n_over.shown
    m_util:ClosePrint()
    TheWorld:PushEvent("nutrientsvision", {enabled = enabled})
    m_util:OpenPrint()
    -- Analyze the soil
    if not enabled then return end
    u_util:Say(string_seed, "On", nil, nil, true)
    pusher:RegPeriodic(RreshNut)
    pusher:RegNowTask(function(player, pc)
        local farm_plants = e_util:FindEnts(nil, nil, 40, {"farm_plant"})
        t_util:IPairs(farm_plants, function(crop)
            h_util.SetAddColor(crop, GetCropColor(crop))
        end)
        d_util:Wait(1)
    end, function()
        if TheWorld then
            m_util:ClosePrint()
            TheWorld:PushEvent("nutrientsvision", {enabled = false})
            m_util:OpenPrint()
            t_util:IPairs(e_util:FindEnts(nil, nil, 40, {"farm_plant"}), function(crop)
                h_util.SetAddColor(crop)
            end)
            pusher:RemovePeriodic(RreshNut)
            if h_util:GetHUD().hx_nut then
                h_util:GetHUD().hx_nut:Kill()
                h_util:GetHUD().hx_nut = nil
            end
            u_util:Say(string_seed, "Off", nil, nil, true)
        end
    end, "null")
end

local data_rgb = require("data/valuetable").RGB_datatable
local function addColor(id, label)
    return {
        id = id,
        label = label.."：",
        fn = fn_save(id),
        hover = label.."\n set up to [primary/black] will not change color when",
        default = fn_get,
        type = "radio",
        data = data_rgb,
    }
end
local screen_data = {
    {
        id = "reset",
        label = "Reset",
        fn = function(_, a, datas)
            t_util:IPairs(datas, function(data)
                local ui = data.id
                local sw = ui and a[ui] and a[ui].switch
                if sw and ui ~= "reset" then
                    sw(default_data[ui])
                end
            end)
        end,
        hover = "One -click restore pioneer default settings \n [please do not click continuously!]",
        default = true,
    },
    {
        id = "reset_pos",
        label = "Reset the ui position",
        fn = function()
            local nut = h_util:GetHUD().hx_nut
            if not nut then return end
            nut:SetPosition(0, 0, 0)
            s_mana:SaveSettingLine(save_id, save_data, {x = 0, y = 0})
        end,
        hover = "If you drag the ui, please click this button",
        default = true,
    },
    addColor("color_weed", "Weed color"),
    addColor("color_pick", "Pick color"),
    addColor("color_tend", "Need to take care"),
    addColor("color_mois", "Lack of water"),
    addColor("color_fer", "Lack of color"),
    {
        id = "scale",
        label = "Set icon size",
        fn = function(value)
            fn_save("scale")(value)
            if h_util:GetHUD().hx_nut then
                h_util:GetHUD().hx_nut:SetUIScale(value)
            end
        end,
        type = "radio",
        hover = "Lavigating the icon",
        default = fn_get,
        data = t_util:BuildNumInsert(0.1, 2, 0.1, function(i)
            return {data = i, description = i}
        end)
    },
}

m_util:AddBindConf(save_id, fn, nil, {string_seed, "nutrientsgoggleshat", STRINGS.LMB .. "On/Off "..STRINGS.RMB .. "Advanced settings", true, fn, m_util:AddBindShowScreen({
    title = string_seed,
    id = save_id,
    data = screen_data,
}), 7997})