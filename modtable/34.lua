-- Log System
local default_data = {
    startshow = m_util:IsHuxi(),
}
local save_id, str_show = "sw_log", "Update Log"
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local function GetLog()
    local logtxt = require "data/lastlog"
    local log = {}
    local time
    local content = ""
    
    for line in string.gmatch(logtxt, "[^\n]+") do
        if string.find(line, "^%s*(20%d%d)[%.%-%/](%d%d?)") then
            if content ~= "" then
                table.insert(log, {time = time, content = content})
                content = ""
            end
            time = line
        elseif time then
            if string.find(line, "^%-%-") then
                -- content = content.."------------".."\n"
            elseif (string.len (line) == 0 or string.match (line, "^%s+$")) then
            else
                content = content..line.."\n"
            end
        end
    end
    if time and content~="" then
        table.insert(log, {time = time, content = content})
    end
    return log
end


local function ShowLog()
    local screen_data = {
        id = save_id,
        title = str_show,
        data = GetLog(),
        type = "log",
    }
    TheFrontEnd:PushScreen(require("screens/huxi/showscreen")(screen_data))
end


AddClassPostConstruct("screens/redux/multiplayermainscreen", function(self)
    if not save_data.startshow then return end
    self.inst:DoTaskInTime(1, function()
        local modinfo = KnownModIndex:GetModInfo(modname) or {}
        local version = modinfo.version
        if tostring(version) ~= tostring(save_data.version) then
            fn_save("version")(version)
            ShowLog()
        end
    end)
end)

local screen_data = {
    {
        id = "startshow",
        label = "Popup Reminder",
        hover = "Popup reminder on the home page after each update",
        default = fn_get,
        fn = fn_save("startshow"),
    },
}


local fn_right = m_util:AddBindShowScreen({
    title = str_show,
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, ShowLog, nil, {str_show, "book_research_station_howto",
                                           STRINGS.LMB .. 'View Log' .. STRINGS.RMB .. 'Advanced Settings', true, ShowLog,
                                           fn_right})
