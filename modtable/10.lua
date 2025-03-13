if m_util:IsServer() and not m_util:IsLava() then return end
local r_data = require "data/rangetable"
local save_id = "range_key"
local default_data = {
    highlight = true,
    color_combat = "Red",
    color_ori = "Blue",
    color_track = "Purple",
    autoshow = true,
    search_seed = false,
    color_player = "Blue",
    color_hover = "Blue",
    color_click = "Magic",
    color_placer = "Yellow",
    time_click = 30,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local c_data = {
    range_attack = m_util:IsTurnOn("range_attack"),
    range_search = m_util:IsTurnOn("range_search"),
    animal_track = m_util:IsTurnOn("animal_track"),
    range_player = m_util:IsTurnOn("range_player"),
    range_hover = m_util:IsTurnOn("range_hover"),
    range_click = m_util:IsTurnOn("range_click"),
    range_placer = m_util:IsTurnOn("range_placer"),
}

local function apply(prefab, color, range, always, add, quick, callback)
    prefab = prefab:lower()
    add = add or 0
    range = range + add
    local rotary_name = "atkr_%s"..range
    local flushTime = quick and 0.1 or 1
    AddPrefabPostInit(prefab, function(inst)
        inst:DoPeriodicTask(flushTime, function()
            local rotary = inst[rotary_name]
            local tcolor = color or save_data.color_ori
            if not rotary then
                inst[rotary_name] = inst:SpawnChild("hrange"):SetVisable(false):SetFixedRadius(range):SetColor(tcolor)
                if prefab == "tallbird" then
                    inst[rotary_name]:AddTag(prefab)		-- Here is core's bug
                end
            else
                if callback then
                    local trans = e_util:IsValid(inst)
                    if trans then
                        callback(rotary, inst, trans:GetScale())
                    end
                end
                if not c_data.range_attack then             -- After turning off the function, you still need to cancel the highlight
                    e_util:SetHighlight(inst, false)
                    rotary:SetVisable(false)
                    return
                end
                if e_util:GetCombatTarget(inst) == ThePlayer then
                    e_util:SetHighlight(inst, save_data.highlight)
                    rotary:SetVisable(true):SetColor(save_data.color_combat)
                elseif always or not save_data.autoshow then
                    rotary:SetVisable(true):SetColor(tcolor)
                else
                    e_util:SetHighlight(inst, false)
                    local dist = e_util:GetDist(inst)
                    rotary:SetVisable(not (dist and dist > 3*range) and not e_util:GetLeaderTarget(inst)):SetColor(tcolor)
                end
            end
        end)
    end)
end
local function LoopAdd(datas, add)
    t_util:IPairs(datas, function (data)
        t_util:IPairs(data.prefabs, function (prefab)
            t_util:Pairs(data.rotary, function (key, value)
                local range, color, fn
    
                local tp_key, tp_value = type(key), type(value)
                if tp_key == "number" and tp_value == "string" then
                    range, color = key, value
                elseif tp_key == "number" and tp_value == "function" then
                    range, fn = key, value
                elseif tp_value == "number" then
                    range = value
                end
                if range then
                    apply(prefab, color, range, data.always, add, data.quick, fn)
                end
            end)
        end)
    end)
end
LoopAdd(r_data.attack_range, 0.5)
LoopAdd(r_data.target_range, 0)

-- Treasure indicator
local core_tasks = {}
local core
i_util:AddWorldActivatedFunc(function ()
    core = e_util:SpawnNull()
    core.entity:AddTransform()
    core.prefab = "huxinull"
    core:DoPeriodicTask(FRAMES, function (inst)
        if not c_data.range_search then
            inst:Hide()
        else
            inst:Show()
            local pt = e_util:IsValid(ThePlayer)
            if pt then
                inst.Transform:SetPosition(pt:GetWorldPosition())
            end
            t_util:Pairs(core_tasks, function (task, arrow)
                if e_util:IsValid(task) then
                    local visable
                    if arrow == true then
                        arrow = core:SpawnChild("harrow"):SetColor(r_data.track_range[task.prefab])
                        core_tasks[task] = arrow
                    else
                        local dist = e_util:GetDist(task)
                        if dist then
                            if not task:HasTag("inlimbo") and dist < 80 and dist > 4 then
                                visable = true
                                arrow:Link(core, task)
                            end
                        end
                        if not save_data.search_seed and task.prefab == "seeds" then
                            visable = false
                        end
                    end
                    if visable then
                        arrow:Show()
                    else
                        arrow:Hide()
                    end
                    e_util:SetHighlight(task, save_data.highlight and visable)
                else
                    if arrow ~= true then
                        arrow:Remove()
                        arrow = nil
                    end
                    core_tasks[task] = nil
                end
            end)
        end
    end)
end)
t_util:Pairs(r_data.track_range, function (prefab)
    AddPrefabPostInit(prefab, function (inst)
        inst:DoTaskInTime(1, function ()
            core_tasks[inst] = true
        end)
    end)
end)
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
if m_util:IsTurnOn("sw_ghost") and m_util:IsTurnOn("sw_wendy") then
    t_util:IPairs(toys, function (prefab)
        AddPrefabPostInit(prefab, function (inst)
            inst:DoTaskInTime(1, function ()
                core_tasks[inst] = true
            end)
        end)
        apply(prefab, "Thistle color", 2, true)
    end)
end

-- Footprint guidance
AddPrefabPostInit("animal_track", function (inst)
	local next_thing
	inst:DoPeriodicTask(0.5, function()
        if not c_data.animal_track or not e_util:IsAnim("idle", inst) or not e_util:IsValid(inst) then
            return
        end
        local x,y,z = inst.entity:LocalToWorldSpace(0,0,-40)
        next_thing = next_thing or e_util:FindEnt({x=x,y=y,z=z}, nil, 10, nil, nil, nil, nil, function(e)
            return e:HasOneOfTags({"dirtpile", "_health"})
        end)
        if e_util:IsValid(next_thing) then
            SpawnPrefab("harrow"):SetColor(save_data.color_track):GoTo(inst, next_thing)
        end
	end)
end)

-- Remote range
i_util:AddPlayerActivatedFunc(function (player, world, pusher)
    local hrange = player:SpawnChild("hrange"):SetVisable(false)
    local function ShowRange(range)
        hrange:SetFixedRadius(range):SetColor(save_data.color_player):SetVisable(true)
    end
    local function RefreshRod(equip)
        if not c_data.range_player then return end
        local rod = t_util:GetRecur(equip, "replica.oceanfishingrod")
        if rod then
            ShowRange(rod:GetMaxCastDist())
        end
    end
    pusher:RegEquip(function (slot, equip)
        if not c_data.range_player then return end
        if slot == "hands" then
            local range = p_util:GetAttackRange(equip)
            if range and range > 4 then
                ShowRange(range+0.5)
            else
                local rod = t_util:GetRecur(equip, "replica.oceanfishingrod")
                if rod then
                    e_util:SetBindEvent(equip, "itemget", RefreshRod)
                    e_util:SetBindEvent(equip, "itemlose", RefreshRod)
                    RefreshRod(equip)
                end
            end
        end
    end)
    pusher:RegUnequip(function (slot, equip)
        if slot == "hands" then
            hrange:SetVisable(false)
        end
    end)
end)


-- Suspended
local hover_range
local function RemoveHoverRange()
    if e_util:IsValid(hover_range)then
        hover_range:Remove()
    end
    hover_range = nil
end
i_util:AddHoverOverFunc(function (str, player, item_inv, item_world)
    local item = item_inv or item_world
    local parent = item_inv and player or item_world
    if not item or not parent then return end
    local range = item.prefab and r_data.hover_range[item.prefab]
    if range and not hover_range and c_data.range_hover then
        hover_range = parent:SpawnChild("hrange"):SetFixedRadius(range):SetColor(save_data.color_hover)
        return nil, RemoveHoverRange
    end
end)

_G.rrr = function()
    return hover_range
end

-- Click the range
i_util:AddLeftClickFunc(function (pc, player, down, act_left, ent_mouse)
    if down then return end
    if not c_data.range_click then return end
    local range = ent_mouse and ent_mouse.prefab and r_data.click_range[ent_mouse.prefab]
    if not range then return end
    local function add_hrange(num)
        if type(num) ~= "number" then return end
        local circle = ent_mouse:SpawnChild("hrange"):SetFixedRadius(num):SetColor(save_data.color_click)
        circle:DoTaskInTime(save_data.time_click, circle.Remove)
    end
    if type(range) == "table" then
        t_util:IPairs(range, add_hrange)
    else
        add_hrange(range)
        if ent_mouse.prefab == "eyeturret" and m_util:IsHuxi() then
            local junk = e_util:FindEnt(ent_mouse, "junk_pile_big")
            if junk then
                local length = e_util:GetDist(ent_mouse, junk)
                if length then
                    local str = string.format("%.2f, recommend 16.8~22.8", length)
                    u_util:Say("Distance from garbage", str, nil, nil, true)
                end
            end
        end
    end
end)

-- Placement
t_util:Pairs(r_data.placer_range, function(prefab, range)
    AddPrefabPostInit(prefab, function(inst)
        inst:DoTaskInTime(0.1, function(inst)
            if c_data.range_placer then
                inst:SpawnChild("hrange"):SetFixedRadius(range):SetColor(save_data.color_placer)
            end
        end)
    end)
end)

local color_data = require("data/valuetable").WRGB_datatable
local screen_data = {
    {
        id = "reset",
        label = "Reset settings",
        fn = function (_, a, datas)
            t_util:IPairs(datas, function (data)
                local ui = data.id
                local sw = a[ui] and a[ui].switch
                if sw and ui~="reset" then
                    sw(data.reset)
                end
            end)
        end,
        hover = "Click one click to restore the default settings \n [please do not click continuously!]",
        default = true,
    },
    {
        id = "range_attack",
        label = "Mobs attack range",
        fn = function(state)
            c_data.range_attack = m_util:SaveModOneConfig("range_attack", state)
        end,
        hover = "Do you want to show attack range?\nYour choice will be written into the module settings!",
        default = function ()
            return c_data.range_attack
        end,
        reset = true,
    },
    {
        id = "autoshow",
        label = "Only display near",
        fn = fn_save("autoshow"),
        hover = "Only highlight/display the range near the player (beautiful + save memory)",
        default = fn_get,
        reset = default_data.autoshow,
    },{
        id = "highlight",
        label = "Highlight hostile",
        fn = fn_save("highlight"),
        hover = "Mobs that have hatred towards the player are highlighted",
        default = fn_get,
        reset = default_data.highlight,
    },{
        id = "color_ori",
        label = "No hatred:",
        type = "radio",
        fn = fn_save("color_ori"),
        hover = "[Attack range] additional setting\nThe color of the attack range when the creature has no hatred",
        default = fn_get,
        data = color_data,
        reset = default_data.color_ori,
    },{
        id = "color_combat",
        label = "Hatred:",
        type = "radio",
        fn = fn_save("color_combat"),
        hover = "[Attack range] additional setting\nThe color of the hostile creature's attack range",
        default = fn_get,
        data = color_data,
        reset = default_data.color_combat,
    },
    {
        id = "animal_track",
        label = "Footprint guidance",
        fn = function(state)
            c_data.animal_track = m_util:SaveModOneConfig("animal_track", state)
        end,
        hover = "Suspicious footprints will have moving arrows to indicate the hunting direction\nYour choice will be written into the module settings!",
        default = function ()
            return c_data.animal_track
        end,
        reset = true,
    },{
        id = "color_track",
        label = "Arrows:",
        type = "radio",
        fn = fn_save("color_track"),
        hover = "[Footprint guidance] additional setting\nThe color of the moving arrows",
        default = function ()
           return save_data.color_track
        end,
        data = color_data,
        reset = default_data.color_track,
    },
    {
        id = "range_search",
        label = "Treasure indicator",
        fn = function(state)
            c_data.range_search = m_util:SaveModOneConfig("range_search", state)
        end,
        hover = "Adds an arrow under your feet for various gems or other 'treasures'\nYour choice will be written into the module settings!",
        default = function ()
            return c_data.range_search
        end,
        reset = true,
    },
    {
        id = "search_seed",
        label = "Seed indicator",
        fn = fn_save("search_seed"),
        hover = "[Treasure indicator] additional function\nAdds an arrow under your feet for the location of the seed",
        default = fn_get,
        reset = default_data.search_seed,
    },{
        id = "range_player",
        label = "Weapon/tool range",
        hover = "When a player holds a ranged weapon or a fishing rod, will the corresponding range be displayed?",
        fn = function(state)
            c_data.range_player = m_util:SaveModOneConfig("range_player", state)
        end,
        default = function ()
            return c_data.range_player
        end,
        reset = true,
    },{
        id = "color_player",
        label = "Color:",
        type = "radio",
        fn = fn_save("color_player"),
        hover = "[Weapon/tool range] additional setting\nThe color of the remote weapon range",
        default = fn_get,
        data = color_data,
        reset = default_data.color_player,
    },{
        id = "range_hover",
        label = "Hover show range",
        hover = "Display range when the mouse moves over entities such as books, pan flutes, etc.",
        fn = function(state)
            c_data.range_hover = m_util:SaveModOneConfig("range_hover", state)
        end,
        default = function ()
            return c_data.range_hover
        end,
        reset = true,
    },{
        id = "color_hover",
        label = "Color:",
        type = "radio",
        fn = fn_save("color_hover"),
        hover = "[Hover show range] additional setting\nThe range color when the mouse moves over entities such as gunpowder, books, etc.",
        default = fn_get,
        data = color_data,
        reset = default_data.color_hover,
    },{
        id = "range_placer",
        label = "Building range",
        hover = "Display range when placing buildings such as lightning rods and eye turrets",
        fn = function(state)
            c_data.range_placer = m_util:SaveModOneConfig("range_placer", state)
        end,
        default = function ()
            return c_data.range_placer
        end,
        reset = true,
    },{
        id = "color_placer",
        label = "Color:",
        type = "radio",
        fn = fn_save("color_placer"),
        hover = "[Building range] additional setting\nThe range color when placing buildings such as lightning rods and eye turrets",
        default = fn_get,
        data = color_data,
        reset = default_data.color_placer,
    },{
        id = "range_click",
        label = "Click show range",
        hover = "Click on entities such as fire extinguishers and lightning rods to display their ranges",
        fn = function(state)
            c_data.range_click = m_util:SaveModOneConfig("range_click", state)
        end,
        default = function ()
            return c_data.range_click
        end,
        reset = true,
    },{
        id = "color_click",
        label = "Color:",
        type = "radio",
        fn = fn_save("color_click"),
        hover = "[Click show range] additional setting\nThe range color when click on some entities such as fire extinguishers, lightning rods, etc.",
        default = fn_get,
        data = color_data,
        reset = default_data.color_click,
    },{
        id = "time_click",
        label = "Timer:",
        type = "radio",
        fn = fn_save("time_click"),
        hover = "[Click show range] additional setting\nThe time the click range exists, it will automatically hide after this time",
        default = fn_get,
        reset = default_data.time_click,
        data = t_util:BuildNumInsert(5, 120, 5, function (i)
            return {data = i, description = i.." sec(s)"}
        end),
    }
}


m_util:AddBindShowScreen("range_board", "Range tracking", "alterguardianhat_lastprism", "Click to open range related settings", {
    title = "Range tracking",
    id = save_id,
    data = screen_data
}, nil, 9997)
