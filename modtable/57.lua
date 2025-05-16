local save_id, string_cook = "sw_autocook", "Auto cooking"
local default_data = {
    btn_conf = 1002, -- 1002 key
    onground = true,
    onchester = true,
    range_search = 80,
    force_memory = not m_util:IsHuxi(),
    showui = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
-- The function of starting cooking
local StewerFn = {}

-- Tag
local tags = {"structure", "_container", "stewer"}


-- Is the cooking pot -. fn cooking function -. validfn judgment function
local function IsStewer(ent)
    if e_util:IsValid(ent) and ent:HasTags(tags) then    
        local container = e_util:GetContainer(ent)
        local btn = container and container:GetWidget() and container:GetWidget().buttoninfo
        return btn and btn.fn and btn.validfn and btn
    end
end

-- Cooking or cooking pots
local function IsCookinged(ent)
    local ids = p_util:GetActionsID(ent)
    if table.contains(ids, "HARVEST") then
        return true
    elseif table.contains(ids, "RUMMAGE") then
        return false
    end
    return e_util:IsAnim(function(anim)
        return (not anim:match("pre")) and (anim:match("loop") or anim:match("pst"))
    end, ent)
end

local function Say(what, dontfresh)
    u_util:Say(string_cook, what, nil, nil, not dontfresh)
    return true
end

-- Data from the storage cooker
local function SaveStewerData(cont)
    local container = e_util:GetContainer(cont)
    if not container then return end
    local data = {
        prefab = cont.prefab,
        num = container:GetNumSlots(),
        foods = {}
    }
    local null
    for i = 1, data.num do
        local item = container:GetItemInSlot(i)
        local prefab = item and item.prefab
        if prefab then
            data.foods[tostring(i)] = prefab
        else
            null = true
            break
        end
    end
    if not null then
        s_mana:SaveSettingLine(save_id, save_data, {
            data = data
        })
    end
end

-- Find the pot and harvest
local function Harvest()
    if p_util:GetActiveItem() then
        return Say("The items are full")
    end
    local stewers = e_util:FindEnts(nil, nil, save_data.range_search, tags, nil, nil, nil, IsCookinged)
    if stewers[1] then
        local act, right
        local stewer = t_util:IGetElement(stewers, function(ent)
            act, right = p_util:GetActionWithID(ent, {"HARVEST"})
            return act and ent
        end)
        if stewer then
            p_util:DoMouseAction(act, right)
        end
    else
        return true
    end
    d_util:Wait()
end

-- Sort the cooking data to fill in the pan
local function FillSlots(data, mine)
    local foods, num = data.foods, tonumber(data.num)
    local slots_data = p_util:GetSlotsFromAll(nil, nil, nil, mine and {"backpack", "body",} or nil) or {}
    local ings, slots = {}, {}
    -- Ings stores a few of each prefab
    -- Slots stores the step information of food, each step is slot_data {slot, cont, item}
    for i = 1, num do
        local prefab = foods[tostring(i)]
        if ings[prefab] then
            ings[prefab] = ings[prefab] + 1
        else
            ings[prefab] = 1
        end
    end
    local needprefab = t_util:GetElement(ings, function(prefab, count)
        local slot_count = 0
        if t_util:IGetElement(slots_data, function(data)
            if data.item.prefab == prefab then
                local size = e_util:GetStackSize(data.item)
                for i = 1, size do
                    table.insert(slots, data)
                    slot_count = slot_count + 1
                    if slot_count >= count then
                        return true
                    end
                end
            end
        end) then
            -- Gathering enough ingredients
            -- Continue to collect the next
        else
            -- The end of the traversal indicates that it has not been collected enough this prefab
            return prefab
        end
    end)
    return {
        slots = slots,
        need = needprefab
    }
end


local flag
local function Cook()
    local data = save_data.data
    local stewers = e_util:FindEnts(nil, data.prefab, save_data.range_search, tags, nil, nil, nil, IsStewer)
    if stewers[1] then
        if flag == "Cooking mode" then
            local cookinfo = FillSlots(data)
            if p_util:GetActiveItem() then
               flag = "Cooking end"
            elseif cookinfo.need then
                flag = "Collect ingredients"
            else
                local data_act = t_util:IGetElement(stewers, function(ent)
                    local act, right = p_util:GetMouseActionSoft({"RUMMAGE", "HARVEST"}, ent)
                    return act and {ent = ent, act = act, right = right}
                end)
                if data_act then
                    local id = data_act.act.action.id
                    if id == "RUMMAGE" then
                        local container -- Open container
                        if data_act.act:GetActionString() == STRINGS.ACTIONS.RUMMAGE.GENERIC then
                            p_util:DoMouseAction(data_act.act, data_act.right)
                            local time_start = GetTime() -- Open delay card action timeout judgment
                            while not container and GetTime() - time_start < 2 do
                                d_util:Wait()
                                container = p_util:IsOpenContainer(data_act.ent)
                            end
                        else
                            container = p_util:IsOpenContainer(data_act.ent)
                        end
                        if container then
                            for slot, item in pairs(container:GetItems() or {}) do
                                if item then
                                    local cont_cantake = p_util:CanTakeItem(item)
                                    if cont_cantake then
                                        p_util:MoveItemFromAllOfSlot(slot, data_act.ent, cont_cantake)
                                    else
                                        return Say("Oblocking items, interruption of cooking")
                                    end
                                end
                            end
                            t_util:IPairs(cookinfo.slots, function(slot_data)
                                p_util:MoveItemFromAllOfSlot(slot_data.slot, slot_data.cont, data_act.ent)
                            end)
                            StewerFn[data_act.ent.prefab](data_act.ent, ThePlayer)
                        end
                    elseif id == "HARVEST" then
                        p_util:DoMouseAction(data_act.act, data_act.right)
                    end
                end
            end
        elseif flag == "Collect ingredients" then
            local data_fill = FillSlots(data, true)
            local prefab = data_fill.need
            if prefab then
                local ents = e_util:FindEnts(nil, nil, save_data.range_search)
                local ent
                -- Pick up items from the ground
                if save_data.onground then
                    local act, right
                    if t_util:IGetElement(ents, function(ent)
                        if ent.prefab == prefab then
                            act, right = p_util:GetMouseActionSoft({"PICKUP"}, ent)
                            return act
                        end
                    end) then
                        ent = true
                        p_util:DoMouseAction(act, right)
                    end
                end
                -- Take items from the box
                if not ent and save_data.onchester then
                    if m_util:EnableShowme() and not save_data.force_memory then
                        ent = t_util:IGetElement(ents, function(ent)
                            return e_util:Mod_Showme_Has(ent, prefab)
                        end)
                    elseif m_util:EnableInsight() and not save_data.force_memory then
                        ent = t_util:IGetElement(ents, function(ent)
                            return e_util:Mod_Insight_Has(ent, prefab)
                        end)
                    else
                        ent = t_util:IGetElement(ents, function(ent)
                            return Mod_ShroomMilk.Func.HasPrefabWithBox and Mod_ShroomMilk.Func.HasPrefabWithBox(ent, prefab, true) and ent
                        end)
                    end
                    if ent then
                        local act, right = p_util:GetMouseActionSoft({"RUMMAGE"}, ent)
                        if act then
                            local container -- Open container
                            if act:GetActionString() == STRINGS.ACTIONS.RUMMAGE.GENERIC then
                                p_util:DoMouseAction(act, right)
                                local time_start = GetTime() -- Open delay card action timeout judgment
                                while not container and GetTime() - time_start < 2 do
                                    d_util:Wait()
                                    container = p_util:IsOpenContainer(ent)
                                end
                            else
                                container = p_util:IsOpenContainer(ent)
                            end
                            if container then
                                local slot_data = t_util:GetElement(container:GetItems(), function(slot, item)
                                    return item.prefab == prefab and p_util:CanTakeItem(item) and tonumber(slot) and {
                                        cont = p_util:CanTakeItem(item),
                                        slot = tonumber(slot),
                                    }
                                end)
                                if slot_data then
                                    p_util:MoveItemFromAllOfSlot(slot_data.slot, ent, slot_data.cont)
                                else
                                    container:Close() -- The gate is to refresh memory
                                end
                            end
                        else
                            Say("If an exception occurs, the box cannot be opened")
                        end
                    else
                        flag = "Harvest mode"
                    end
                end
                if ent then
                    Say("Search "..e_util:GetPrefabName(prefab), true)
                else
                    flag = "Harvest mode"
                end
            else
                flag = "Cooking mode"
            end
        elseif flag == "Cooking end" then
            return Say("Cooking end")
        elseif flag == "Harvest mode" then
            return Harvest()
        end
        d_util:Wait()
    else 
        return Say("No crock pot found")
    end
end


local Widget = require "widgets/widget"
local Image = require "widgets/image"
local function ShowUI(close)
    local menu = h_util:GetControls().craftingmenu
    local icon = t_util:GetRecur(menu, "pinbar.open_menu_button.icon")
    if icon and icon.acui then icon.acui:Kill() end
    if not (icon and save_data.showui and not close) then return end
    
    local ox,oy = icon:GetSize()
    icon.acui = icon:AddChild(Widget("autocook"))
    icon.acui:SetPosition(save_data.posx or 2*ox, save_data.posy or 0)
    local space = 5
    local width = ox+space
    local data = save_data.data
    for slot = 1, tonumber(data.num)do
        local sui = icon.acui:AddChild(Widget("autocook_slot"..slot))
        sui:SetPosition((slot-1)*(ox + space*2), 0)
        -- sui.bg = sui:AddChild(Image("images/hud.xml", "inv_slot.tex"))
        sui.bg = sui:AddChild(Image("images/quagmire_recipebook.xml", "cookbook_known.tex"))
        sui.bg:SetSize(width, width)
        local prefab = data.foods[tostring(slot)]
        local xml, tex = h_util:GetPrefabAsset(prefab)
        if xml and tex then
            sui.img = sui:AddChild(Image(xml, tex))
            sui.img:SetSize(width, width)
        end
    end
    h_util:ActivateUIDraggable(icon.acui, function(pos)
        s_mana:SaveSettingLine(save_id, save_data, {posx = pos.x, posy = pos.y})
    end)
end


local function AutoCook(ent)
    local player = ThePlayer
    local pusher = player and player.components.hx_pusher
    if not pusher then return end
    -- If this pot has been opened, record its data
    local btn_pot = IsStewer(ent)
    if btn_pot then
        if btn_pot.validfn(ent) then
            btn_pot.fn(ent, player)
        end
    end
    if p_util:GetActiveItem() then
        p_util:ReturnActiveItem()
    end
    if TheInput:IsControlPressed(CONTROL_FORCE_ATTACK) then
        Say("Harvest mode")
        pusher:RegNowTask(Harvest, function()
            Say("End")
        end)
    else
        local data = save_data.data
        if data then
            if ent and IsStewer(ent) then
                if ent.prefab ~= data.prefab then
                    return Say("Please use this pot to cook a dish first")
                end
            end
            flag = "Cooking mode"
            Say("Start cooking")
            ShowUI()
            local mv = Profile:GetMovementPredictionEnabled()
            -- In fact, delay compensation can be ignored, because there is timeout repair, but it is still added, so that it can be smoother
            if mv then
                ThePlayer:EnableMovementPrediction(false)
            end
            pusher:RegNowTask(Cook, function()
                ShowUI(true)
                Say("Cooking end")
                if mv then
                    ThePlayer:EnableMovementPrediction(mv)
                end
            end)
        else
            Say("Please cook a dish first")
        end
    end
end


AddClassPostConstruct("screens/playerhud", function(self)
    -- Binding
    local _OnMouseButton = self.OnMouseButton
    self.OnMouseButton = function(self, button, down, ...)
        if button == save_data.btn_conf and down and not TheInput:GetHUDEntityUnderMouse() then
            local ent = TheInput:GetWorldEntityUnderMouse()
            if IsStewer(ent) then
                AutoCook(ent)
            end
        end
        return _OnMouseButton(self, button, down, ...)
    end
    -- Store cooking functions, record cooking data
    local _OpenContainer = self.OpenContainer
    self.OpenContainer = function(self, ent, ...)
        local ret = _OpenContainer(self, ent, ...)
        local btn_pot = IsStewer(ent)
        if btn_pot and not StewerFn[ent.prefab] then
            local _fn = btn_pot.fn
            StewerFn[ent.prefab] = _fn
            btn_pot.fn = function(ent, ...)
                SaveStewerData(ent)
                return _fn(ent, ...)
            end
        end
        return ret
    end
end)

m_util:AddBindConf(save_id, AutoCook, nil, {string_cook, "cookpot_tureen", STRINGS.LMB .. string_cook .. STRINGS.RMB .. "Advanced settings", true, AutoCook, m_util:AddBindShowScreen({
    title = string_cook,
    id = save_id,
    data = {{
        id = "readme",
        label = "Use guide",
        fn = function()
            h_util:CreatePopupWithClose("Auto cooking · use guide",
                "[Start cooking] Fill a pot with ingredients, then middle-click it\n[Harvest] Hold down CTRL and middle-click the pot")
        end,
        hover = "Click to view the tutorial",
        default = true
    }, {
        id = "force_memory",
        label = "Forced local memory",
        hover = "Open it carefully. after opening, you will no longer communicate with showme or ins! \nthis will be completely controlled by local control!",
        fn = fn_save("force_memory"),
        default = fn_get
    }, {
        id = "onground",
        label = "Ground search",
        fn = fn_save("onground"),
        hover = "Whether to allow picking ingredients from the ground",
        default = fn_get
    }, {
        id = "onchester",
        label = "Storage search",
        fn = fn_save("onchester"),
        hover = "Whether to allow the ingredients from the box",
        default = fn_get
    },{
        id = "showui",
        label = "Ingredient UI",
        fn = fn_save("showui"),
        hover = "Whether to display ingredients ui during cooking",
        default = fn_get
    }, {
        id = "resetui",
        label = "Reset UI position",
        fn = function()
            s_mana:SaveSettingLine(save_id, save_data, {posx = false, posy = false})
        end,
        hover = "When the UI position is not satisfied, it is used to drag it again",
        default = true
    }, {
        id = "range_search",
        label = "Search range:",
        fn = fn_save("range_search"),
        hover = "The range of searching items, 20 is already full screen",
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(1, 20, 1, function(i)
            return {
                data = i * 4,
                description = i .. " Grid"
            }
        end)
    }, {
        id = "btn_conf",
        label = "Binding:",
        fn = fn_save("btn_conf"),
        hover = "Set related binding buttons",
        default = fn_get,
        type = "radio",
        data = h_util:SetMouseSecond()
    }}
})})

