local save_id, str_show = "rt_take", "Recipe pickup"
local default_data = {
    sw = true,
    btn_conf = MOUSEBUTTON_RIGHT,
    range = 60,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local bantags = {'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player', 'stewer', 'backpack', 'trader', 'lamp'}
-- Get the position that can be taken on the body or backpack
local function GetCanTake(item)
    local can_cont
    local can_slot = e_util:CanPutInItem(ThePlayer, item)
    if can_slot then
        can_cont = ThePlayer
    else
        local backpack = p_util:GetBackpack()
        can_slot = e_util:CanPutInItem(backpack, item)
        if can_slot then
            can_cont = backpack
        end
    end
    return can_cont, can_slot
end

local function SearchAndTakePrefab(prefab, amount_has, amount_need)
    local func_has = Mod_ShroomMilk.Func.HasPrefabWithBox
    local func_refresh = Mod_ShroomMilk.Func.RefreshBoxMemory
    local pusher = m_util:GetPusher()
    if not (func_has and pusher and prefab) then return end
    local name = e_util:GetPrefabName(prefab)
    pusher:RegNowTask(function(player, pc)
        d_util:Wait()
        if amount_need <= 0 then
            if GetCanTake(p_util:GetActiveItem()) then
                p_util:ReturnActiveItem()
            end
            u_util:Say("Picked up "..name.." complete")
            return true
        end
        local item_active = p_util:GetActiveItem()
        if item_active then
            if item_active.prefab == prefab then
                local can_cont, can_slot = GetCanTake(item_active)
                if can_cont then
                    if d_util:PutOneOfActiveItemInSlot(can_cont, can_slot) then
                        return true
                    elseif amount_need > 0 then
                        amount_need = amount_need - 1
                        return
                    end
                else
                    u_util:Say("No space left")
                    return true
                end
            else
                p_util:ReturnActiveItem()
            end
        else
            u_util:Say("Searching for "..name)
            local box = e_util:FindEnt(nil, nil, save_data.range_search, {"_container"}, bantags, nil, nil, function(cont)
                return func_has(cont, prefab, true) and p_util:GetMouseActionSoft({"RUMMAGE"}, cont)
            end)
            if not box then
                u_util:Say("I can't find "..name)
                return true
            end
            d_util:OpenContainer(box, 0.5)
            func_refresh(box)
            local item_box = p_util:GetSlotFromAll(prefab, nil, function(item,cont,slot)
                return cont == box
            end, {"container"})
            if item_box then
                if d_util:TakeActiveItem(item_box.item) then
                    return true
                end
            end
        end
    end)
end


-- Recipe
AddClassPostConstruct("widgets/ingredientui", function(self, ...)
    local _OnMouseButton = self.OnMouseButton
    function self.OnMouseButton(self, button, down, ...)
        if save_data.sw and button == save_data.btn_conf and down then
            local str = self.quant and self.quant:GetString() or ""
            local amount_has, amount_need = str:match('(%d+)/(%d+)')
            amount_has, amount_need = tonumber(amount_has), tonumber(amount_need)
            if amount_has and amount_need then
                SearchAndTakePrefab(self.recipe_type, amount_has, amount_need)
            end
        end
        return _OnMouseButton(self, button, down, ...)
    end
end)


-- Register to menu
m_util:AddRightMouseData(save_id, str_show, "Enable "..str_show, function()
    return save_data.sw
end, fn_save("sw"), {
    screen_data = {
        {
            id = "readme",
            label = "Usage Guide",
            fn = function()
                h_util:CreatePopupWithClose(str_show.." · Usage Guide",
                    "Right-click (default) on the item recipe,\nautomatically pick up the specified quantity of items from the box", {{
                        text = h_util.ok
                    }})
            end,
            hover = "Click to view tutorial",
            default = true
        },
        {
            id = "btn_conf",
            label = "Bind Key:",
            fn = fn_save("btn_conf"),
            type = "radio",
            hover = "Set trigger key",
            default = fn_get,
            data = h_util:SetMouseSecond(),
        },
        {
            id = "range",
            label = "Search Range:",
            fn = fn_save("range"),
            type = "radio",
            hover = "Search range for boxes:",
            default = fn_get,
            data = require("data/valuetable").range_datatable,
        },
        {
            id = "readme",
            label = "What is this?",
            fn = function()
                h_util:CreatePopupWithClose("󰀍"..str_show.." · Special Thanks󰀍",
                    "Don't Starve is really fun.\n                           —Only willing to sink into eternal sleep in dreams")
            end,
            hover = "Special Thanks",
            default = true
        },
    },
    priority = 99,
})
