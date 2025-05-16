if m_util:IsServer() then
    return
end
local save_id = "sw_wagstaff"
local default_data = {
    tool_tip = true,
    textsize = 35,
    color_need = "Fresh meat",
    color_ori = "White",
    bird_warn = 12,
    range_pick = 30,
    range_catch = 30,
    sw_f = true,
    sw_g = true,
    sw_p = true,
    sw_m = true,
    sw_n = true
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local function Say(who, what)
    u_util:Say(who, what, nil, nil, true)
end
local string_task = "Storm mission"

local prefabs = {"wagstaff_tool_1", "wagstaff_tool_2", "wagstaff_tool_3", "wagstaff_tool_4", "wagstaff_tool_5"}
local needprefab, done
local function getName(i)
    return t_util:GetRecur(STRINGS, "NAMES.WAGSTAFF_TOOL_" .. i)
end
for i, prefab in ipairs(prefabs) do
    AddPrefabPostInit(prefab, function(inst)
        inst:DoPeriodicTask(.5, function(inst)
            local label = inst._hx_label
            if label then
                if save_data.tool_tip then
                    if prefab == needprefab then
                        label:SetSize(save_data.textsize + 5):SetColor(save_data.color_need):SetText(getName(i) or "")
                    else
                        label:SetSize(save_data.textsize):SetColor(save_data.color_ori):SetText(getName(i) or "")
                    end
                else
                    label:SetText("")
                end
            else
                local name = getName(i)
                if name then
                    STRINGS.NAMES["WAGSTAFF_TOOL_" .. i .. "_LAYMAN"] = name
                    h_util:CreateLabel(inst, save_data.tool_tip and name or "", nil, nil, save_data.textsize)
                end
            end
        end)
    end)
end
AddPrefabPostInit("wagstaff_npc", function(inst)
    inst:DoTaskInTime(0.25, function(inst)
        needprefab = nil
        e_util:Hook_Say(inst, function(str_say)
            for i, prefab in ipairs(prefabs) do
                if str_say == STRINGS["WAGSTAFF_NPC_WANT_TOOL_" .. i] then
                    needprefab = prefab
                    break
                end
            end
            for i = 1, 2 do
                if str_say == STRINGS["WAGSTAFF_NPC_EXPERIMENT_DONE_" .. i] or str_say ==
                    STRINGS["WAGSTAFF_NPC_EXPERIMENT_FAIL_" .. i] then
                    done = true
                    break
                end
            end
            if needprefab then
                for i = 1, 2 do
                    if str_say == STRINGS.WAGSTAFF_NPC_YES_THIS_TOOL[i] then
                        needprefab = nil
                        break
                    end
                end
            end
        end)
    end)
end)

local prefab_birds = {"bird_mutant", "bird_mutant_spitter"}
local prefab_npc = "wagstaff_npc"
local function fn()
    local npc = e_util:FindEnt(nil, prefab_npc)
    if not npc then
        Say("Didn't find Wagstaff")
        return
    end
    local pusher = ThePlayer.components.hx_pusher
    if not pusher then
        return
    end
    if pusher:GetNowTask() then
        pusher:StopNowTask()
        return
    end

    local weapon = p_util:GetEquip("hands") -- Arms
    if weapon then
        Say(string_task, "Start, determine the weapon to be" .. weapon.name)
    else
        Say(string_task, "Start up")
    end
    local mode = "Waiting mode" -- Default mode
    local bird_core, need_item, need_equip
    done = false
    -- Key points: each mode needs to complete the corresponding task to enter another mode
    -- The core of all modes can only be waiting mode, and the attachment manages all modes
    -- Can't get food due to sorrow, such as the submitted mode and found that the birds enter the site, and the birds are used to fight birds
    local function SetMode(M)
        Say(M)
        mode = M
    end
    local function EquipAndClick(str_act)
        if e_util:IsValid(need_equip) and e_util:IsValid(need_item) then
            if p_util:GetEquip("hands") ~= need_equip then
                p_util:Equip(need_equip)
                d_util:Wait()
            end
            if p_util:GetEquip("hands") == need_equip then
                if not p_util:TryClick(need_item, str_act) then
                    m_util:print("No action!")
                    SetMode("Waiting mode")
                end
            else
                SetMode("Waiting mode")
            end
        else
            SetMode("Waiting mode")
        end
    end
    local function Can_Get_Glass()
        need_item = e_util:FindEnt(nil, "moonglass_charged", 6)
        return need_item and save_data.sw_p
    end
    local function Can_Attack_Bird()
        local bird = e_util:FindEnt(npc, prefab_birds, save_data.bird_warn)
        if bird and save_data.sw_f then
            bird_core = bird:GetPosition()
            return true
        end
    end
    local function Can_Give_NPC()
        if needprefab then
            need_item = p_util:GetItemFromAll(needprefab, nil, nil, "mouse")
            return need_item and save_data.sw_g
        end
    end
    local function Can_Pick_Tool()
        if needprefab then
            need_item = e_util:FindEnt(npc, needprefab, save_data.range_pick) -- In fact, the highest is 26
            return need_item and save_data.sw_p
        end
    end
    local function Can_Mine_Glass()
        need_item = e_util:FindEnt(npc, "moonstorm_glass", save_data.range_catch, nil, nil, nil, nil, function(ent)
            return not e_util:FindEnt(ent, prefab_birds, 8)
        end)
        if need_item then
            need_equip = p_util:GetItemFromAll(nil, nil, function(equip)
                return p_util:GetAction("useitem", "MINE", false, equip, need_item)
            end, {"equip", "mouse", "container", "backpack", "body"})
            return need_equip and save_data.sw_m
        end
    end
    local function Can_Net_Spark()
        need_item = e_util:FindEnt(npc, "moonstorm_spark", save_data.range_catch, nil, nil, nil, nil, function(ent)
            return not e_util:FindEnt(ent, prefab_birds, 2)
        end)
        if need_item then
            need_equip = p_util:GetItemFromAll(nil, nil, function(equip)
                return p_util:GetAction("useitem", "NET", false, equip, need_item)
            end, {"equip", "mouse", "container", "backpack", "body"})
            return need_equip and save_data.sw_n
        end
    end
    pusher:RegNowTask(function(player, pc)
        if not e_util:IsValid(npc) or done then
            return true
        end
        if mode == "Waiting mode" then
            if Can_Get_Glass() then
                SetMode("Pick mode")
            elseif Can_Attack_Bird() then
                SetMode("Combat mode")
            elseif Can_Give_NPC() then
                SetMode("Submit mode")
            elseif Can_Pick_Tool() then
                SetMode("Pick mode")
            elseif Can_Mine_Glass() then
                SetMode("Mining mode")
            elseif Can_Net_Spark() then
                SetMode("Capture mode")
            else
                local pos = c_util:GetIntersectPotRadiusPot(npc:GetPosition(), 3.5, player:GetPosition())
                p_util:Click(pos)
            end
        elseif mode == "Combat mode" then
            local bird = e_util:FindEnt(bird_core, prefab_birds, 9)
            if bird then
                -- Equipment
                if e_util:IsValid(weapon) and p_util:GetEquip("hands") ~= weapon then
                    p_util:Equip(weapon)
                    d_util:Wait()
                end
                -- Fighting, cool!
                if p_util:AttackInRange(bird) then
                    pc:DoAttackButton(bird)
                else
                    p_util:Click(bird)
                end
            else
                SetMode("Waiting mode")
            end
        elseif mode == "Submit mode" then
            if e_util:IsValid(need_item) and need_item:HasTag("inlimbo") then
                if d_util:TakeActiveItem(need_item) then
                    m_util:print("Failure to get items!")
                    SetMode("Waiting mode")
                else
                    if not p_util:TryClick(npc, "GIVE") then
                        SetMode("Waiting mode")
                    end
                end
            else
                SetMode("Waiting mode")
            end
        elseif mode == "Pick mode" then
            p_util:ReturnActiveItem()
            if e_util:IsValid(need_item) and not need_item:HasTag("inlimbo") then
                if not p_util:TryClick(need_item, "PICKUP") then
                    m_util:print("No picking action!")
                    SetMode("Waiting mode")
                end
            else
                SetMode("Waiting mode")
            end
        elseif mode == "Mining mode" then
            EquipAndClick("MINE")
        elseif mode == "Capture mode" then
            EquipAndClick("NET")
            d_util:Wait(2)
        end
        -- m_util:print(mode)
        d_util:Wait()
    end, function(player)
        Say(string_task, "Finish")
        if e_util:IsValid(player) then
            player:DoTaskInTime(3, function()
                local item = e_util:FindEnt(nil, "moonstorm_static_item")
                if item then
                    p_util:TryClick(item, "PICKUP")
                end
            end)
        end
    end)
end

------------------ 我是可爱的分界线 ----------------------
local font_color = require("data/valuetable").RGB_datatable
local range_table = t_util:BuildNumInsert(5, 80, 5, function(i)
    return {
        data = i,
        description = i
    }
end)
local screen_data = {{
    id = "sw_f",
    label = "Combat mode",
    fn = fn_save("sw_f"),
    hover = "Whether to play automatically",
    default = fn_get
}, {
    id = "sw_g",
    label = "Submit mode",
    fn = fn_save("sw_g"),
    hover = "Whether to submit small tools automatically",
    default = fn_get
}, {
    id = "sw_p",
    label = "Pick mode",
    fn = fn_save("sw_p"),
    hover = "Whether to automatically pick up small tools and glassstones",
    default = fn_get
}, {
    id = "sw_m",
    label = "Mining mode",
    fn = fn_save("sw_m"),
    hover = "Whether to automatically dig a glass stone",
    default = fn_get
}, {
    id = "sw_n",
    label = "Capture mode",
    fn = fn_save("sw_n"),
    hover = "Whether to automatically capture the moonlight",
    default = fn_get
}, {
    id = "tool_tip",
    label = "Show tool name",
    fn = fn_save("tool_tip"),
    hover = "Whether to display the name of the auxiliary tool",
    default = fn_get
}, {
    id = "textsize",
    label = "Font size:",
    fn = fn_save("textsize"),
    hover = "[Tool name] the size of the text",
    default = fn_get,
    type = "radio",
    data = range_table
}, {
    id = "color_ori",
    label = "Default:",
    fn = fn_save("color_ori"),
    hover = "[Tool name] the name color of all small tools",
    default = fn_get,
    type = "radio",
    data = font_color
}, {
    id = "color_need",
    label = "Highlight:",
    fn = fn_save("color_need"),
    hover = "[Tool name] the name color of the tool needed by Wagstaff",
    default = fn_get,
    type = "radio",
    data = font_color
}, {
    id = "bird_warn",
    label = "Combat range:",
    fn = fn_save("bird_warn"),
    hover = "Moonblind Crow enters this range from Wagstaff will trigger the character combat mode",
    default = fn_get,
    type = "radio",
    data = t_util:BuildNumInsert(6, 60, 2, function(i)
        return {
            data = i,
            description = i
        }
    end)
}, {
    id = "range_pick",
    label = "Pickup range:",
    fn = fn_save("range_pick"),
    hover = "The range of helping Wagstaff picking tools",
    default = fn_get,
    type = "radio",
    data = range_table
}, {
    id = "range_catch",
    label = "Collect range:",
    fn = fn_save("range_catch"),
    hover = "The range of catching Moongleams or digging Infused Moon Shards.",
    default = fn_get,
    type = "radio",
    data = range_table
}}
local func_right = m_util:AddBindShowScreen({
    title = string_task,
    id = "hx_" .. save_id,
    data = screen_data
})

m_util:AddBindConf(save_id, fn, nil,
    {string_task, "moonstorm_static_item", STRINGS.LMB .. "On/Off " .. STRINGS.RMB .. "Advanced settings", true, fn,
     func_right, 5994})
