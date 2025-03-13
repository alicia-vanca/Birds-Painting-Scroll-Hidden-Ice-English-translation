local save_id, str_staff = "sw_castspell", "Accurate casting"
local default_data = {
    sw = true
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)


local staffs = {"yellowstaff", "opalstaff", "trident"}

local function GetSpellAct(ent)
    local item = p_util:GetActiveItem() or p_util:GetEquip("hands")
    if item and table.contains(staffs, item.prefab) then
        local pos = e_util:IsValid(ent) and ent:GetPosition() or TheInput:GetWorldPosition()
        local act = pos and p_util:GetAction("pos", "CASTSPELL", true, item, nil, pos)
        return act, pos
    end
end

-- Main logic
i_util:AddRightClickFunc(function(pc, player, down, act, ent)
    if not (down and ent and save_data.sw) then return end
    local act, pos = GetSpellAct(ent)
    if act then
        p_util:DoAction(act, RPC.RightClick, act.action.code, pos.x, pos.z)
    end
end)

-- Change the right button display
i_util:AddHoverOverFunc(function(str, player, item_inv, item_world)
    if item_world and save_data.sw then
        local act, pos = GetSpellAct(item_world)
        if act then
            local act_str = t_util:GetRecur(STRINGS, "ACTIONS.LOOKAT.GENERIC")
            if act_str and str:find(act_str) then
                return str:gsub(act_str, h_util:GetStringKeyBoardMouse(MOUSEBUTTON_RIGHT) .. str_staff)
            end
        end
    end
end)



-- Register to the menu
m_util:AddRightMouseData(save_id, str_staff, "Whether to enable "..str_staff, function()
    return save_data.sw
end, function(value)
    fn_save("sw")(value)
end)