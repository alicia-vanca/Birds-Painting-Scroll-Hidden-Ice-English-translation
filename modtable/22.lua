if m_util:IsServer() then
    return
end
local save_id, string_dag = "sw_DAG", "Archive task"
local default_data = {
    size_font = 40,
    color_small = "Spring green",
    color_box = "Yellow",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local anim_all = {"one", "two", "three", "four", "five", "six", "seven"}
local labels_small, labels_box = {}, {}
local point
local function ClearAll()
    t_util:IPairs(labels_small, function(label)
        label:SetText("")
    end)
end
AddPrefabPostInit("archive_orchestrina_small", function(inst)
    inst:DoTaskInTime(0, function()
        local label = h_util:CreateLabel(inst, nil, {x=0, y=40}, nil, save_data.size_font, save_data.color_small)
        if not label then
            return
        end
        table.insert(labels_small, label)
        local pusher = t_util:GetRecur(ThePlayer or {}, "components.hx_pusher")
        if pusher then
            pusher:RegPeriodic(function()
                if not e_util:IsValid(inst) then
                    return true
                end
                t_util:Pairs(anim_all, function(order, anim)
                    if e_util:IsAnim(anim .. "_pre", inst) then
                        if order == 1 and point ~= inst.GUID then
                            ClearAll()
                            point = inst.GUID
                        end
                        label:SetText(order)
                    end
                end)
                if e_util:IsAnim("eight_activation", inst) then
                    ClearAll()
                end
            end)
        end
    end)
end)

AddPrefabPostInit("archive_lockbox_dispencer", function(inst)
    inst:DoTaskInTime(0.5, function()
        local label = h_util:CreateLabel(inst, nil, { x = 0, y = 0 }, nil, save_data.size_font, save_data.color_box)
        if not label then
            return
        end
        table.insert(labels_box, label)
        local sym = inst.AnimState:GetSymbolOverride("parts")
        if not sym then
            label:SetText(STRINGS.NAMES.TURF_ARCHIVE .. "\n" .. STRINGS.NAMES.TURFCRAFTINGSTATION)
        elseif sym == hash("archive_knowledge_dispensary_b") then
            label:SetText(STRINGS.NAMES.ARCHIVE_RESONATOR)
        elseif sym == hash("archive_knowledge_dispensary_c") then
            label:SetText(STRINGS.NAMES.REFINED_DUST)
        else
            label:SetText("Unknown")
        end
    end)
end)

local function marktarget(target, anim_target)
    if not target or not anim_target then return end
    if not target.false_check then
        target.false_check = {[anim_target] = true}
    elseif not target.false_check[anim_target] then
        target.false_check[anim_target] = true
    end
end
local loc_small,loc_base = "archive_orchestrina_small","archive_orchestrina_base"
local prefabs = {"archive_lockbox", "blank_certificate",}
local function fn()
    local base = e_util:FindEnt(nil, loc_base, nil, nil, {})
    local mode = "Check mode"
    local the_anim, the_target, last_pos, last_last_pos
    if not base then
        return
    end
    local pusher = ThePlayer.components.hx_pusher
    if not pusher then return end
    if pusher:GetNowTask() then
        return pusher:StopNowTask()
    end
    u_util:Say(string_dag, "Start up")
    pusher:RegNowTask(function(player, pc)
        if not (base and base:IsValid()) then return true end
        if mode == "Check mode" then
            repeat d_util:Wait() until not p_util:IsInBusy()
            if e_util:FindEnt(base, prefabs, 3) then
                mode = "Mission mode"
            else
                local item = p_util:GetItemFromAll(prefabs)
                if item then
                    local dist = e_util:GetDist(base)
                    if dist then
                        if dist < 3 then
                            p_util:DropItemFromInvTile(item)
                        else
                            p_util:Click(base)
                        end
                    else
                        return true
                    end
                else
                    return true
                end
            end
        elseif mode == "Mission mode" then
            d_util:Wait()
            -- Get the biggest animation mark in real time as [target mark]
            local max_anim = 0
            local smalls = e_util:FindEnts(base, loc_small, 8, nil, {}, nil, nil, function(small)
                local id = t_util:GetElement(anim_all, function(id, anim_str)
                    return e_util:IsAnim({anim_str, anim_str.."_pre"}, small) and id
                end)
                if id and id > max_anim then
                    max_anim = id
                end
                return true
            end)
            -- Read the label with [target mark]
            max_anim = max_anim + 1
            local target = t_util:GetElement(smalls, function(_, small)
                local label_num = small._hx_label and tonumber(small._hx_label:GetText())
                if label_num == max_anim then
                    return small
                end
            end)
            -- If there is no label, find the nearest [target mark]
            if not target then
                local min_dist = 10000
                t_util:IPairs(smalls, function(small)
                    -- 1. the distance is closest
                    -- 2. there must be no labels (because those who have labels have gone)
                    -- 3. no error can reach the bidding
                    local label_num = small._hx_label and tonumber(small._hx_label:GetText())
                    if not label_num and not (small.false_check and small.false_check[max_anim]) then
                        local dist = e_util:GetDist(small)
                        if dist and dist < min_dist then
                            min_dist = dist
                            target = small
                        end
                    end
                end)
            end
            if target then
                if the_target ~= target then
                    marktarget(e_util:FindEnt(nil, loc_small, 4, nil, {}), the_anim)
                end
                the_target,the_anim = target, max_anim

                local t_pos,c_pos,p_pos = target:GetPosition(), base:GetPosition(), player:GetPosition()
                if last_last_pos == last_pos and last_pos == p_pos then
                    repeat
                        p_util:Click(base)
                        d_util:Wait()
                    until not e_util:FindEnt(nil, loc_small, 2.5, nil, {})
                else
                    p_util:Click(t_pos - (t_pos-c_pos) / t_pos:Dist(c_pos))
                end
                last_last_pos,last_pos = last_pos, p_pos

                if max_anim == 8 then return true end
                local dist = e_util:GetDist(target)
                if dist < 1.5 then
                    marktarget(target, max_anim)
                end
            else
                e_util:FindEnts(nil, loc_small, nil, nil, {}, nil, nil, function(small)
                    if small.false_check then
                        small.false_check[max_anim] = false
                    end 
                end)
            end
        end
    end, function()
        u_util:Say(string_dag, "Finish", nil, nil, true)
    end)
end
local v_data = require("data/valuetable")
local data_rgb, data_frame,data_range = v_data.RGB_datatable, v_data.frame_datatable, v_data.range_datatable
local screen_data = {{
    id = "color_small",
    label = "Task mark:",
    fn = function(c)
        fn_save("color_small")(c)
        t_util:IPairs(labels_small, function(label)
            label:SetColor(c)
        end)
    end,
    hover = "The color of the task mark",
    default = fn_get,
    type = "radio",
    data = data_rgb
}, {
    id = "color_box",
    label = "Toilet mark:",
    fn = function(c)
        fn_save("color_box")(c)
        t_util:IPairs(labels_box, function(label)
            label:SetColor(c)
        end)
    end,
    hover = "The color of the 'toilet' \nthe knowledge of water dispenser",
    default = fn_get,
    type = "radio",
    data = data_rgb
}, 
{
    id = "size_font",
    label = "Font size:",
    fn = function(c)
        fn_save("size_font")(c)
        t_util:IPairs(labels_small, function(label)
            label:SetSize(c)
        end)
        t_util:IPairs(labels_box, function(label)
            label:SetSize(c)
        end)
    end,
    hover = "The font size of the prompt",
    default = fn_get,
    type = "radio",
    data = data_range
},
}
local func_right = m_util:AddBindShowScreen({
    title = string_dag,
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, fn, nil, {string_dag, "archive_lockbox",
                                      STRINGS.LMB .. "Start " .. STRINGS.RMB .. "Advanced settings", true, fn,
                                      func_right, 5996})
