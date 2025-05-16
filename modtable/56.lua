local save_id, string_mid = "mid_search", "Mid-click"
local default_data = {
    btn_conf = MOUSEBUTTON_MIDDLE, -- 1002 key
    onground = true,
    onocean = false,
    range_search = 80,
    order_search = 1,
    force_memory = false
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

-- prefab:Code, num:The number of times the current iteration searches for the recipe(Recommended to leave empty, maximum 4 times), onground: Whether to search only on the ground, onocean: Search only in the ocean
local function SearchAndClickPrefabDetail(prefab, num, onground, onocean)
    if type(prefab) ~= "string" then
        return
    end
    -- Adaptation wilson
    local _prefab
    if prefab:sub(1, 10) == "transmute_" then
        _prefab = prefab
        prefab = prefab:sub(11)
    end
    local ents = e_util:FindEnts(nil, nil, save_data.range_search, nil, nil, nil, nil, function(ent)
        return onocean or not ent:IsOnOcean(false)
    end)

    local function GetMouseAct(ent)
        return p_util:GetMouseActionClick(ent)
    end
    local function CheckGround(ent)
        if not onground or ent.prefab ~= prefab then
            return
        end
        return GetMouseAct(ent)
    end
    local function CheckBoxShowme(ent)
        local has = ent.ShowMe_chest_table and t_util:GetElement(ent.ShowMe_chest_table, function(_prefab)
            return _prefab:gsub(" ", "") == prefab
        end)
        return has and GetMouseAct(ent)
    end
    local function CheckBoxInsight(ent)
        if e_util:IsContainer(ent) then
            local ins = t_util:GetRecur(ThePlayer, "replica.insight")
            return ins and ins:ContainerHas(ent, prefab, false) and GetMouseAct(ent)
        end
    end
    local function CheckBoxMemory(ent)
        return Mod_ShroomMilk.Func.HasPrefabWithBox and Mod_ShroomMilk.Func.HasPrefabWithBox(ent, prefab) and
                   GetMouseAct(ent)
    end

    local function FindGround()
        return t_util:IGetElement(ents, CheckGround)
    end
    local function FindBox()
        if m_util:EnableShowme() and not save_data.force_memory then
            return t_util:IGetElement(ents, CheckBoxShowme)
        elseif m_util:EnableInsight() and not save_data.force_memory then
            return t_util:IGetElement(ents, CheckBoxInsight)
        else
            return t_util:IGetElement(ents, CheckBoxMemory)
        end
    end
    local data
    if save_data.order_search == 1 then
        data = FindGround() or FindBox()
    elseif save_data.order_search == 2 then
        data = FindBox() or FindGround()
    else
        data = t_util:IGetElement(ents, function(ent)
            if ent.prefab == prefab then
                return GetMouseAct(ent)
            else
                if m_util:EnableShowme() and not save_data.force_memory then
                    return CheckBoxShowme(ent)
                elseif m_util:EnableInsight() and not save_data.force_memory then
                    return CheckBoxInsight(ent)
                else
                    return CheckBoxMemory(ent)
                end
            end
        end)
    end
    if data then
        local act_str = data.act:GetActionString() or ""
        local name = e_util:GetPrefabName(data.target.prefab, data.target) or ""
        u_util:Say(act_str .. " " .. name, nil, "head", nil, true)
        
        d_util:RemoteClick(data)
        return true
    else
        local ings = t_util:GetRecur(AllRecipes[prefab], "ingredients")
        local _prefab = ings and #ings == 1 and type(ings[1]) == "table" and ings[1].type
        num = num or 0
        if _prefab and num < 4 then
            return SearchAndClickPrefabDetail(_prefab, num + 1, onground, onocean)
        else
            local name = e_util:GetPrefabName(prefab) or ""
            u_util:Say("I can't find it " .. name, nil, "head", nil, true)
        end
    end
end

local function SearchAndClickPrefab(prefab, num)
    return SearchAndClickPrefabDetail(prefab, num, save_data.onground, save_data.onocean)
end

-- Formula
AddClassPostConstruct("widgets/ingredientui", function(self, ...)
    local _OnMouseButton = self.OnMouseButton
    function self.OnMouseButton(self, button, down, ...)
        if button == save_data.btn_conf and down then
            SearchAndClickPrefab(self.recipe_type)
        end
        return _OnMouseButton(self, button, down, ...)
    end
end)
-- Sidebar
AddClassPostConstruct("widgets/redux/craftingmenu_pinslot", function(self, ...)
    local _OnMouseButton = self.OnMouseButton
    function self.OnMouseButton(self, button, down, ...)
        if button == save_data.btn_conf and down then
            if not t_util:GetRecur(self, "recipe_popup.ingredients.focus") then
                SearchAndClickPrefab(self.recipe_name)
            end
        end
        return _OnMouseButton(self, button, down, ...)
    end
end)
-- Production column
AddClassPostConstruct("widgets/redux/craftingmenu_widget", function(self, ...)
    local _OnMouseButton = self.OnMouseButton

    function self.OnMouseButton(self, button, down, ...)
        if button == tonumber(save_data.btn_conf) and down then
            local grid = self.recipe_grid
            local skin = self.details_root and self.details_root.skins_spinner
            local prefab
            if grid and grid.focus and grid.shown then
                local index = grid.focused_widget_index + grid.displayed_start_index
                local items = grid.items
                if index and items and items[index] then
                    local recipe = items[index].recipe
                    prefab = recipe and recipe.product
                end
            elseif skin and skin.focus and skin.enabled and skin.shown then
                prefab = skin.recipe and skin.recipe.product
            end
            SearchAndClickPrefab(prefab)
        end
        return _OnMouseButton(self, button, down, ...)
    end
end)

------------------- Middle button storage ---------------------
local items_task = {}
local id_task = "_hx_image_tint"
-- Increase color
local function AddTint(item, togreen)
    local img = item[id_task]
    if togreen then
        if item:HasTag("fresh") then
            img:SetTint(1, 0, 0, 1)
        else
            img:SetTint(0, 1, 0, 1)
        end
    else
        img:SetTint(1, 1, 1, 1)
    end
end
-- Clean up the color
local function ClearTint()
    t_util:IPairs(items_task, AddTint)
    items_task = {}
end
local bantags = {'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player', 'stewer', 'backpack', 'trader', 'lamp'}
local func_has, func_get
local function AutoSort(player, pc)
    d_util:Wait()
    local _, item = next(items_task)
    if item then
        local slot_data = e_util:IsValid(item) and p_util:GetSlotFromAll(item.prefab, nil, function(ent)
            return item == ent
        end, {"body", "backpack"})
        if slot_data then
            local conts = e_util:FindEnts(nil, nil, save_data.range_search, {"_container"}, bantags)
            -- There is this item but not full
            local conts_not_has = {}
            local cont = t_util:IGetElement(conts, function(cont)
                local container = e_util:GetContainer(cont)
                if not (container and cont:HasOneOfTags({"hutch", "chester", "structure"})) then
                    return
                end
                local cont_slots = container:GetNumSlots()
                if cont_slots < 5 then
                    return
                end
                local data_cont = func_has and func_has(cont, item.prefab) -- There is this item
                if data_cont then
                    for i = 1, cont_slots do
                        local line = data_cont[tostring(i)]
                        if line then
                            if line.prefab == item.prefab then
                                local stack, max = tonumber(line.stack), tonumber(line.max)
                                if stack and max and stack < max then
                                    return cont
                                end 
                            end
                        else
                            return cont
                        end
                    end
                else
                    -- No item
                    data_cont = func_get(cont)
                    if data_cont then
                        for i = 1, cont_slots do
                            local line = data_cont[tostring(i)]
                            if not line then
                                -- Together
                                table.insert(conts_not_has, cont)
                                return
                            end
                        end
                    else
                        -- The box that has not been opened
                        table.insert(conts_not_has, cont)
                        return
                    end
                end
            end)
            if not cont then
                local cont_book, cont_salt, cont_cool, cont_else = {}, {}, {}, {}
                t_util:IPairs(conts_not_has, function(container_ent)
                    if container_ent.prefab == "bookstation" then
                        table.insert(cont_book, container_ent)
                    elseif container_ent:HasTag("saltbox") then
                        table.insert(cont_salt, container_ent)
                    elseif container_ent:HasTag("fridge") then
                        table.insert(cont_cool, container_ent)
                    else
                        table.insert(cont_else, container_ent)
                    end
                end)
                local function CanPutIn(conts)
                    return t_util:IGetElement(conts, function(cont)
                        return e_util:CanPutInItem(cont, item) and cont
                    end)
                end
                cont = CanPutIn(cont_book) or CanPutIn(cont_salt) or CanPutIn(cont_cool) or CanPutIn(cont_else)
            end
            local container = e_util:GetContainer(cont)
            if container then
                while not container:IsOpenedBy(player) do
                    local act, right = p_util:GetMouseActionSoft({"RUMMAGE"}, cont)
                    if not act then
                        break
                    end
                    p_util:DoMouseAction(act, right)
                    -- local dist = e_util:GetDist(cont) or 
                    d_util:Wait(0.5)
                end
                if container:IsOpenedBy(player) then
                    -- Can the actual survey be put?
                    local num = container:GetNumSlots()
                    local canput
                    for i = 1, num do
                        local _item = container:GetItemInSlot(i)
                        if not _item or e_util:GetStackSize(_item) < e_util:GetMaxSize(_item) then
                            canput = true
                            break
                        end
                    end
                    if canput then
                        p_util:MoveItemFromAllOfSlot(slot_data.slot, slot_data.cont, cont)
                    end
                else
                    AddTint(item)
                    table.removearrayvalue(items_task, item)
                end
            else
                AddTint(item)
                table.removearrayvalue(items_task, item)
            end
        else
            AddTint(item)
            table.removearrayvalue(items_task, item)
        end
    else
        -- No items to be placed, the queue is over
        return true
    end
end

i_util:AddWorldActivatedFunc(function()
    func_has = Mod_ShroomMilk.Func.HasPrefabWithBox
    func_get = Mod_ShroomMilk.Func.GetMemoryBoxData
end)

AddClassPostConstruct("widgets/invslot", function(self, ...)
    local _OnMouseButton = self.OnMouseButton

    function self.OnMouseButton(self, button, down, ...)
        if button == tonumber(save_data.btn_conf) and down and self.tile then
            local image = self.tile.image
            local item = self.tile.item
            local cont = self.container and self.container.inst
            local pusher = ThePlayer and ThePlayer.components.hx_pusher
            if func_has and image and item and cont and pusher and cont:HasOneOfTags({"player", "backpack"}) then
                item[id_task] = image
                if not pusher then
                    return
                end
                if table.contains(items_task, item) then
                    AddTint(item)
                    table.removearrayvalue(items_task, item)
                else
                    AddTint(item, true)
                    table.insert(items_task, item)
                end
                if #items_task > 0 then
                    if not pusher:GetNowTask() then
                        pusher:RegNowTask(AutoSort, function()
                            ClearTint()
                            u_util:Say("End")
                        end)
                    end
                else
                    pusher:StopNowTask()
                end
            end
        end
        return _OnMouseButton(self, button, down, ...)
    end
end)

local str_default, str_null, str_fuzzy = "Oops, why did you click me?", "Exact match failed to match any results, try fuzzy match?", "No results found"
local str_highlight = "You have not enabled [Storage Highlight]\nPlease enable this feature in [Memory] first!"

local function GetPrefabPrecise(text)
    text = text:lower()
    return t_util:GetElement(STRINGS.NAMES, function(prefab, name)
        return type(prefab) == "string" and type(name) == "string" and (
            prefab:lower() == text or name:lower() == text
        ) and {prefab = prefab:lower(), name = name}
    end)
end
local function GetPrefabsFuzzy(text)
    local ret = {
        count = 0,
        prefab_table = {},
        name_table = {},
    }
    t_util:Pairs(STRINGS.NAMES, function(prefab, name)
        if type(prefab) == "string" and type(name) == "string" and (c_util:IsStrContains(prefab, text) or c_util:IsStrContains(name, text)) then
            ret.count = ret.count + 1
            table.insert(ret.prefab_table, prefab:lower())
            table.insert(ret.name_table, name)
        end
    end)
    return ret
end

local function IsNullCheck(text, value)
    if string.len(text) == 0 then
        return true, str_default
    end
    if value then
        local ret = GetPrefabPrecise(text)
        if ret then
            return false, ret
        else
            return true, str_null
        end
    else
        local ret = GetPrefabsFuzzy(text)
        if ret.count == 0 then
            return true, str_fuzzy
        else
            return false, ret
        end
    end
end

local function GetStr(ret, value)
    if value then
        return "Exact search "..ret.name.." ("..ret.prefab..")"..":\n"
    else
        local count = #ret.name_table
        if count > 9 then
            local name_table = t_util:BuildNumInsert(1, 9, 1, function(i)
                return ret.name_table[i]
            end)
            table.insert(name_table, "...")
            table.insert(name_table, "...")
            return "Fuzzy search found "..count.." items:\n"..table.concat(name_table, "\n")
        else
            return "Fuzzy search found "..count.." items:\n"..table.concat(ret.name_table, "\n")
        end
    end
end


local funcs = {
    SavePos = function(pos)
        fn_save("posx")(pos.x)
        fn_save("posy")(pos.y)
    end,
    Highlight = function(text, value)
        local HighlightPrefabs = Mod_ShroomMilk.Func.HighlightPrefabs
        if not m_util:IsTurnOn("brain_chester") or not HighlightPrefabs then
            return str_highlight
        end
        local isnull, ret = IsNullCheck(text, value)
        if isnull then return ret end
        local str = GetStr(ret, value)
        local count = HighlightPrefabs(value and ret.prefab or ret.prefab_table)
        return str.."\nHighlighted "..count.." items"
    end,
    Click = function(text, value)
        local isnull, ret = IsNullCheck(text, value)
        if isnull then return ret end
        local str = GetStr(ret, value)
        if t_util:IGetElement(value and {ret.prefab} or ret.prefab_table, function(prefab)
            return SearchAndClickPrefabDetail(prefab, nil, true, true)
        end) then
            return str.."\nSearch successful!"
        else
            return str.."\nThe item you are looking for is not found nearby"
        end
    end,
    Close = function()
        local ClearHighlight = Mod_ShroomMilk.Func.ClearHighlight
        if ClearHighlight then
            ClearHighlight()
        end
        local ui = t_util:GetRecur(ThePlayer, "HUD.controls.hx_search")
        if ui then
            ui:Kill()
        end
    end
}

local Sch = require "widgets/huxi/huxi_search"
local function fn_left()
    local ctrl = t_util:GetRecur(ThePlayer, "HUD.controls")
    if not ctrl then return end
    if h_util:IsValid(ctrl.hx_search) then
        ctrl.hx_search:Kill()
    else
        ctrl.hx_search = ctrl:AddChild(Sch(funcs, save_data))
    end
end

local fn_right = m_util:AddBindShowScreen({
    title = string_mid .. " - Advanced settings",
    id = save_id,
    data = {{
        id = "readme",
        label = "Use guide",
        fn = function()
            h_util:CreatePopupWithClose("Mid-key enhancement · use guide",
                "Try middle-clicking the crafting bar, sidebar, or inventory item")
        end,
        hover = "Click to view the tutorial",
        default = true
    }, {
        id = "force_memory",
        label = "Force local memory",
        hover = "Enable with caution, you will no longer communicate with showme or insight after enabling!\nThis function will be completely controlled locally!",
        fn = fn_save("force_memory"),
        default = fn_get
    }, {
        id = "onground",
        label = "Ground search",
        fn = fn_save("onground"),
        hover = "Whether to pick up related items from the ground",
        default = fn_get
    }, {
        id = "onocean",
        label = "Ocean search",
        fn = fn_save("onocean"),
        hover = "Whether to pick up related items from the sea",
        default = fn_get
    }, {
        id = "order_search",
        label = "Priority:",
        fn = fn_save("order_search"),
        hover = "Should I prioritize picking it up from the ground or from the box?",
        default = fn_get,
        type = "radio",
        data = {{
            data = 1,
            description = "Ground first"
        }, {
            data = 2,
            description = "Storage first"
        }, {
            data = 3,
            description = "Closest first"
        }}
    }, {
        id = "range_search",
        label = "Range:",
        fn = fn_save("range_search"),
        hover = "The range of searching items, 20 has reached full screen",
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
        label = "Hotkey:",
        fn = fn_save("btn_conf"),
        hover = "Set related binding buttons",
        default = fn_get,
        type = "radio",
        data = h_util:SetMouseSecond()
    }, {
        id = "reset_ui",
        label = "Reset location",
        fn = function()
            local ui = t_util:GetRecur(ThePlayer, "HUD.controls.hx_search")
            if h_util:IsValid(ui) then
                ui:SetUIPos(true)
            else
                h_util:CreatePopupWithClose(nil, "The search panel is not display yet!")
            end
        end,
        hover = "Reset UI position",
        default = true
    }, }
})

m_util:AddBindConf(save_id, fn_left, nil, {string_mid, "book_horticulture_upgraded", STRINGS.LMB .. 'Search panel' .. STRINGS.RMB .. 'Advanced settings', true, fn_left, fn_right, 9994})
Mod_ShroomMilk.Func.OpenMidSearchUI = fn_left


-- 呼吸个人补充
AddClassPostConstruct("widgets/redux/craftingmenu_pinbar", function(self, ...)
    local _OnMouseButton = self.OnMouseButton
    function self.OnMouseButton(self, button, down, ...)
        if button == save_data.btn_conf and down then
            if t_util:GetRecur(self, "open_menu_button.focus") then
                SearchAndClickPrefabDetail("seeds", nil, true)
            end
        end
        return _OnMouseButton(self, button, down, ...)
    end
end)