local save_id, str_staff = "sw_castspell", "Accurate casting"
local default_data = {
    sw = true,
    staffs = {"yellowstaff", "opalstaff", "trident"}
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)


local function GetSpellAct(ent)
    local item = p_util:GetActiveItem() or p_util:GetEquip("hands")
    if item and table.contains(save_data.staffs, item.prefab) then
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
            if act_str and str:rfind_plain(act_str) then
                return str:gsub(act_str, h_util:GetStringKeyBoardMouse(MOUSEBUTTON_RIGHT) .. str_staff)
            end
        end
    end
end)


local fn_show, fn_text = r_util:InitPack(save_data, fn_get, fn_save, function()
    fn_save("sw")(not save_data.sw)
    u_util:Say(str_staff, save_data.sw,  nil, nil, true)
end, "sw_key")

-- Register to the menu
m_util:AddRightMouseData(save_id, str_staff, "Whether to enable "..str_staff, function()
    return save_data.sw
end, function(value)
    fn_save("sw")(value)
end, {
    screen_data = {{
        id = "sw_key",
        label = "Toggle key:",
        hover = "Quick toggle hotkey for Accurate Casting",
        type = "textbtn",
        default = fn_show,
        fn = fn_text("sw_key", str_staff),
    },{
        id = "list_self",
        label = "Custom staff list",
        hover = "Staffs in the list will use automatic casting",
        prefab = default_data.staffs[1],
        type = "imgstr",
        fn = m_util:AddBindShowScreen{
            title = "Custom staff list",
            id = "list_self",
            data = m_util:FuncListRemove(save_data, "staffs", fn_save, function(name)
                return "Staff: "..name
            end, "Are you sure you want to remove this staff?", function(name, prefab)
                return "Staff code: " .. prefab .. "\nClick to remove from the list!"
            end, "This staff is from a mod and cannot display an icon\nClick to remove from the list!"),
            fn_active = true,
            dontpop = true,
            icon = {{
                id = "add",
                prefab = "mods",
                hover = "Click to add a staff for accurate casting",
                fn = m_util:FuncListAdd(save_data, fn_save, "staffs", "Accurate Casting", "staff"),
            },{
                id = "reset_repair",
                prefab = "revert2",
                hover = "Click to reset the accurate casting staff list",
                fn = m_util:FuncListReset(save_data, default_data, fn_save, "Are you sure you want to reset the accurate casting staff list?", "staffs"),
            }}
    },}
    },
})