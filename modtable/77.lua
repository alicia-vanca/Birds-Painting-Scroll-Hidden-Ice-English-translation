local save_id, str_show, logo = "sw_jh_repair", "Beefalo helper", "beefalo"
local default_data = {
    sw = false,
    torepair_key = 118,
    jh_mount = true,
    color_say = "Pink",
    jh_say = true,
    jh_bell = true,
    jh_feed = true,
    list_feed = {"lightbulb", "petals", "rock_avocado_fruit_ripe", "beefalofeed", "beefalotreat"}
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local function Say(str1, str2)
    if not save_data.jh_say then return end
    u_util:Say(str1, str2, "head", save_data.color_say, true)
end


local function fn_to_mount()
    return e_util:FindEnt(nil, "beefalo", nil, nil, nil, nil, nil, function(ent)
        local act, right = p_util:GetMouseActionSoft({"MOUNT"}, ent)
        if act then
            
            if p_util:GetMouseActionSoft({"TOSS"}, ent) and not TheWorld.ismastersim then
                p_util:UnEquip(p_util:GetEquip("hands"))
            end
            p_util:DoMouseAction(act, right)
            Say("Searching for mount", "󰀁")
            return true
        end
    end)
end
local function fn_to_unmount()
    local act, right = p_util:GetMouseActionSoft({"DISMOUNT"}, ThePlayer)
    if act then
        p_util:DoMouseAction(act, right)
        Say("Dismounted and walking", "󰀁")
    end
end

local function fn_to_bell()
    local bell = p_util:GetItemFromAll(nil, {"beefalo_targeter", "bell", "inlimbo"}, function(item)
        return not item:HasOneOfTags({"inuse_targeted", "nobundling"})
    end, "mouse")
    return bell and e_util:FindEnt(nil, "beefalo", nil, nil, nil, nil, nil, function(ent)
        local leader = e_util:GetLeaderTarget(ent)
        
        if not leader or not leader:HasTag("bell") then
            local act = p_util:GetAction("useitem", "USEITEMON", nil, bell, ent)
            if act then
                p_util:DoAction(act, RPC.ControllerUseItemOnSceneFromInvTile, act.action.code, bell, ent)
                Say("Bell binding", "󰀁")
                return true
            end
        end
    end)
end


local function fn_feed()
    local act = p_util:GetAction("inv", "FEED", nil, p_util:GetActiveItem())
    if act then
        local name = t_util:GetRecur(act, "invobject.name")
        if type(name)=="string" then
            p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act.action.code, act.invobject)
            Say(name, "󰀁")
            return true
        end
    end
end
local function fn_to_feed()
    if p_util:IsRider() then
        if p_util:GetActiveItem() then
            return fn_feed()
        else
            local data = p_util:GetSlotFromAll(save_data.list_feed)
            if data then
                p_util:TakeActiveItemFromCountOfSlot(data.cont, data.slot, 1)
                e_util:WaitToDo(ThePlayer, .1, 10, function() return p_util:GetActiveItem() end, fn_feed)
                return true
            end
        end
    end
end

local function fn_press()
    if not save_data.sw then return end
    
    if save_data.jh_mount and fn_to_mount() then
        return
    end
    
    if save_data.jh_bell and fn_to_bell() then
        return
    end
    
    if save_data.jh_feed then
        if save_data.jh_feed == "close" then
            return Say(str_show, "Completed")
        elseif save_data.jh_feed == "unmount" then
            return fn_to_unmount()
        elseif fn_to_feed() then
            return
        end
    end
    Say(str_show, "Completed")
end


local function fn_add_feed()
    m_util:PushPrefabScreen{
        text_title = "Select feed to use",
        text_btnok = "Add feed",
        hover_btnok = "Add this feed to the beefalo feed list",
        fn_btnok = function(prefab)
            if table.contains(save_data.list_feed, prefab) then
                h_util:CreatePopupWithClose("Duplicate add", "This item is already in the beefalo feed list.\nPlease add another item.")
            else
                t_util:Add(save_data.list_feed, prefab, true)
                fn_save()
            end
        end,
    }
end



local fn_set_feed = m_util:AddBindShowScreen{
    title = "󰀁 Feed List",
    id = "list_feed",
    data = m_util:FuncListRemove(save_data, "list_feed", fn_save, function(name)
        return "󰀁 Feed: "..name
    end, "Are you sure you no longer want to use this feed for the beefalo?", function(name, prefab)
        return "Item code: " .. prefab .. "\nClick to remove this feed!"
    end, "This item is from a mod and cannot display an icon\nClick to remove this feed!"),
    help = "While riding a beefalo, press the hotkey to feed it with the following feed.\nClick the wrench on the right to add feed, click a feed name below to remove it.",
    fn_active = true,
    dontpop = true,
    icon = {{
        id = "add_repair",
        prefab = "mods",
        hover = "Click to add beefalo feed to the hotkey!",
        fn = fn_add_feed,
    },{
        id = "reset_repair",
        prefab = "revert2",
        hover = "Click to reset beefalo feed hotkey!",
        fn = m_util:FuncListReset(save_data, default_data, fn_save, "Are you sure you want to reset the beefalo feed list?", "list_feed"),
    }}
}



local screen_data = {
    {
        id = "sw",
        label = "Master switch",
        hover = "[Beefalo helper] master switch for all functions",
        default = fn_get,
        fn = fn_save("sw"),
    },r_util:ScreenPack(save_data, fn_get, fn_save, fn_press, "torepair_key", str_show),{
        id = "jh_say",
        label = "Toggle: Text prompt",
        hover = "Display feature action above the character",
        default = fn_get,
        fn = fn_save("jh_say"),
    },{
        id = "color_say",
        label = "Text color:",
        default = fn_get,
        type = "radio",
        data = require("data/valuetable").RGB_datatable,
        fn = fn_save("color_say"),
    },{
        id = "jh_repair",
        label = "Toggle: Repair item",
        hover = "Toggle for Repair Item",
        default = fn_get,
        fn = fn_save("jh_repair"),
    },{
        id = "jh_mount",
        label = "Toggle: Find mount",
        hover = "Press hotkey to mount the nearest beefalo",
        default = fn_get,
        fn = fn_save("jh_mount"),
    },{
        id = "jh_bell",
        label = "Toggle: Bell binding",
        hover = "Press hotkey to bind the nearest beefalo with a bell",
        default = fn_get,
        fn = fn_save("jh_bell"),
    },{
        id = "jh_feed",
        label = "Ride action:",
        hover = "Action performed when riding a beefalo",
        default = fn_get,
        type = "radio",
        fn = fn_save("jh_feed"),
        data = {
            {data = "feed", description = "Feed"},
            {data = "unmount", description = "Dismount"},
            {data = "close", description = "Close"},
        }
    },{
        id = "list_feed",
        type = "imgstr",
        prefab = "beefalotreat",
        hover = "Requires Ride action to be set to Feed to take effect",
        label = "Settings: Feed Beefalo",
        fn = fn_set_feed,
    },
}

m_util:AddBindShowScreen(save_id, str_show, logo, str_show.." Settings", {
    title = str_show,
    id = save_id,
    data = screen_data,
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀁 Special Thanks 󰀁", "The Beefalo Helper feature was customized by player 'Ni Feng'.\n\nMessage: Please feed my beefalo.", {{text = "󰀁"}})
        end,
    }},
    help = "Includes the following functions executed in order:\n1. Press the hotkey to mount the nearest beefalo;\n2. Press the hotkey to bind the beefalo with a bell;\n3. Press the hotkey to feed the ridden beefalo."
}, nil, 8000.7)            