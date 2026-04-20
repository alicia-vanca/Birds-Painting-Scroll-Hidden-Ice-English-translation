local save_id, str_auto = "sw_butterfly", "Catch butterfly"
local default_data = {
    time = 1,
    tool = false,
    prefabs = {"butterfly"},
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local prefab_tool = "bugnet"

local function func_left()
    local pusher = ThePlayer and ThePlayer.components.hx_pusher
    if not pusher then return end
    if pusher:GetNowTask() then
        pusher:StopNowTask()
        return
    end
    u_util:Say(str_auto, true)
    pusher:RegNowTask(function(player, pc)
        
        local fly = e_util:FindEnt(player, save_data.prefabs)
        if fly then
            
            local tool = p_util:GetItemFromAll(nil, nil, function(equip)
                return p_util:GetAction("useitem", "NET", false, equip, fly)
            end, {"equip", "mouse", "container", "backpack", "body"})
            if tool then
                if p_util:GetEquip("hands") ~= tool then
                    p_util:Equip(tool)
                else
                    p_util:TryClick(fly, "NET")
                    d_util:Wait(.7)
                end
            elseif save_data.tool and p_util:CanBuild(prefab_tool)  then
                u_util:Say(str_auto, "Craft bug net")
                if d_util:MakeItem(prefab_tool) then
                    return u_util:Say(str_auto, "Craft bug net failed")
                end
            else
                u_util:Say(str_auto, "No bug net", nil, nil, true)
                return true
            end
        end
        d_util:Wait()
    end, function()
        u_util:Say(str_auto, false)
    end)
end

local fn_show, fn_text = r_util:InitPack(save_data, fn_get, fn_save, func_left, "tostart_key")
local screen_data = {{
        id = "tostart_key",
        label = "Secondary key:",
        hover = "[Auto Butterfly Catch]'s extra bind key\nYou can also left-click the panel button to start",
        type = "textbtn",
        default = fn_show,
        fn = fn_text("tostart_key", str_auto),
    },
    {
        id = "tool",
        label = "Bug net crafting",
        hover = "Craft a bug net when none is available",
        default = fn_get,
        fn = fn_save("tool")
    },{
        id = "list_self",
        label = "Capture target list",
        hover = "Creatures on the list will be auto-caught",
        prefab = default_data.prefabs[1],
        type = "imgstr",
        fn = m_util:AddBindShowScreen{
            title = "Custom capture list",
            id = "list_self",
            data = m_util:FuncListRemove(save_data, "prefabs", fn_save, function(name)
                return "Catch: "..name
            end, "Are you sure you want to auto-catch this creature?", function(name, prefab)
                return "Creature code: " .. prefab .. "\nClick to remove from list!"
            end, "This creature is from a mod and cannot display an icon.\nClick to remove from list!"),
            fn_active = true,
            dontpop = true,
            icon = {{
                id = "add",
                prefab = "mods",
                hover = "Click to add a creature for auto-catch",
                fn = m_util:FuncListAdd(save_data, fn_save, "prefabs", "Auto-catch", "Creature"),
            },{
                id = "reset_repair",
                prefab = "revert2",
                hover = "Click to reset the auto-catch creature list",
                fn = m_util:FuncListReset(save_data, default_data, fn_save, "Are you sure you want to reset the auto-catch creature list?", "prefabs"),
            }}
    },}
}

local func_right = m_util:AddBindShowScreen({
    id = save_id,
    title = str_auto,
    data = screen_data,
    icon = {},
})
m_util:AddBindConf(save_id, func_left, nil, {str_auto, "butterfly" , STRINGS.LMB .. 'Start/End ' .. STRINGS.RMB .. 'Advanced Settings'
, true, func_left, func_right, -5001}, modname)