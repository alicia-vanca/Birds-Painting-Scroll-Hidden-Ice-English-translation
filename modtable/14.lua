local save_id, str_show, logo = "sw_small", "Small func", "glassblock"
local default_data = {
    tommp = m_util:IsHuxi(),
    tommp_key = 110,
    exit_time = 0,
    exit_en = false,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local function fn_mmp()
    local mv = not m_util:GetMovementPrediction()
    m_util:SetMovementPrediction(mv)
    u_util:Say(mv and "Lag compensation" or "Lag compensation", mv and "On" or "Off", nil, mv and "SpringGreen" or "Red", true)
end
local function fn_back()
    DoRestart(true)
end
local function fn_exit()
    
    local time = os.time()
    if type(time) == "number" then
        save_data.exit_time = time
        save_data.exit_en = true
        fn_save()
        DoRestart(true)
    end
end
AddClassPostConstruct("screens/redux/networkloginpopup", function(self)
    if save_data.exit_en then
        local time = os.time()
        if type(time) == "number" and type(save_data.exit_time) == "number" then
            if save_data.exit_time - time < 120 then
                fn_save("exit_en")(false)
                RequestShutdown()
            end
        end
    end
end)


local datatable = {
    {
        id = "tommp",
        fn = fn_mmp,
        name = "Toggle lag compensation",
        hover = "One-click toggle lag compensation",
    },{
        id = "toback",
        fn = fn_back,
        name = "Exit to main screen",
        hover = "One-click disconnect and return to the main screen",
    },{
        id = "toexit",
        fn = fn_exit,
        name = "Exit to desktop",
        hover = "One-click disconnect, return to the game main screen, then exit to desktop",
    }
}

local function fn_refresh(player)
    t_util:IPairs(datatable, function(data)
        r_util:BindKeyFunc(data.fn)
    end)
    t_util:IPairs(datatable, function(data)
        r_util:BindKeyFunc(data.fn, save_data[data.id] and save_data[data.id.."_key"])
    end)
end
i_util:AddSessionLoadFunc(function()
    
    fn_refresh()
end)
local function fn_set(id)
    return function(val)
        fn_save(id)(val)
        fn_refresh(ThePlayer)
    end
end
local fn_show = r_util:GetLabelShow(fn_get)
local fn_text = r_util:GetLabelSet(fn_set)

local screen_data = {}
t_util:IPairs(datatable, function(data)
    local ID, NAME = data.id, data.name
    local KEY = ID.."_key"
    table.insert(screen_data, {
        id = ID,
        label = NAME,
        hover = data.hover,
        default = fn_get,
        fn = fn_set(ID),
    })
    table.insert(screen_data, {
        id =  KEY,
        label = "Hotkey:",
        hover = subfmt("Binding key for [{name}]", {name=NAME}),
        type = "textbtn",
        default = fn_show,
        fn = fn_text(KEY, NAME),
    })
end)
m_util:AddBindShowScreen(save_id, str_show, logo, "Key binding settings for multiple small functions", {
    title = str_show,
    id = save_id,
    data = screen_data,
})