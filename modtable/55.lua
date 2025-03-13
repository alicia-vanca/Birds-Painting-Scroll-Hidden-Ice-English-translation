
local save_id, string_quick, string_ip, string_sim = "sw_server", "Reconnect", "IP Reconnect", "Reconnect"
local default_data = {
    connect = false,
    -- time = os.time()
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local last_id = save_id.."last"
local last_list = s_mana:GetSettingList(last_id, true)
local max = 40
local sl_data = {}
local m_data = {
    server_quick = m_util:IsTurnOn("server_quick"),
    server_server = m_util:IsTurnOn("server_server"),
    server_reco = m_util:IsTurnOn("server_reco"),
    server_login = m_util:IsTurnOn("server_login"),
    server_popup = m_util:IsTurnOn("server_popup"),
}
local fn_moddata = function(id) return m_data[id] end
local function ModSave(conf)
    return function(value)
        m_data[conf] = m_util:SaveModOneConfig(conf, value)
    end
end

local screen_ss_url = "screens/redux/serverlistingscreen"

local task_quick
local function TaskCancel()
    if task_quick then
        task_quick:Cancel()
        task_quick = nil
    end
end

local loaddata
local function QuickJoin(data)
    if data.type == "ip" and data.ip and data.port then
        local start_worked = TheNet:StartClient(data.ip, data.port, 0, data.pwd)
        if start_worked then
            DisableAllDLC()
        end
    elseif data.guid then
        if TheNet:JoinServerResponse(false, data.guid, data.pwd) then
            DisableAllDLC()
        end
    end
    i_util:DoTaskInTime(0.5, function()
        local screen = h_util:GetActiveScreen("ConnectingToGamePopup")
        if screen then
            screen.dialog.title:SetString("Reconnecting" .. 
			((data.type == "ip" and ": "..data.ip..":"..data.port) or ""))
        end
    end)
end

Mod_ShroomMilk.Func.QuickJoin = QuickJoin

local function GetQuickData()
    table.sort(last_list, function(a, b)
        return a.time > b.time
    end)
    return t_util:IGetElement(last_list, function(idata)
        return idata.ip and idata.port and idata.session and idata.name and idata
    end)
end

local function Quick()
    local data = GetQuickData()
    if data then
        if TheWorld then
            if (TheWorld.meta and TheWorld.meta.session_identifier == data.session) or (TheWorld.components.hx_saver:GetSeed(true) == TheWorld.components.hx_saver:GetSeed(false)) then
                s_mana:SaveSettingLine(save_id, save_data, {connect = true, time = os.time()})
                DoRestart(true)
            else
                QuickJoin(data)
            end
        else
            if m_data.server_reco == "ip" then
                data.type = "ip"
                QuickJoin(data)
            else
                if task_quick then
                    TaskCancel()
                else
                    task_quick = i_util:DoPeriodicTask(1, function()
                        local screen_ss = h_util:GetActiveScreen("ServerListingScreen")
                        if screen_ss then
                            local function JoinItem()
                                local items = t_util:GetRecur(screen_ss, "servers_scroll_list.items") or {}
                                local item = t_util:IGetElement(items, function(item)
                                    return item.session and item.ip == data.ip and item.port == data.port and item.actualindex and item
                                end)
                                if item then
                                    local netdata = TheNet:GetServerListingFromActualIndex(item.actualindex) or {}
                                    TaskCancel()
                                    QuickJoin({pwd = data.pwd, guid = netdata.guid})
                                    return true
                                end
                            end
                            if not JoinItem() then
                                i_util:DoTaskInTime(1, function()
                                    if not JoinItem() and not TheNet:IsSearchingServers() then
                                        screen_ss = h_util:GetActiveScreen("ServerListingScreen")
                                        if screen_ss then
                                            local textbox = screen_ss.searchbox and screen_ss.searchbox.textbox
                                            if textbox then
                                                textbox:SetString(data.name)
                                                screen_ss:DoFiltering()
                                            end
                                            screen_ss:SearchForServers()
                                        end
                                    end
                                end)
                            end
                        else
                            TheNet:DeserializeAllLocalUserSessions(function(data) loaddata = data end)
                            screen_ss = require(screen_ss_url)(nil, {{name = "HASCHARACTER", data = true}}, function()end, false, loaddata)
                            TheFrontEnd:PushScreen(screen_ss)
                        end
                    end)  
                end
            end
        end
    else
        h_util:CreatePopupWithClose("No server found", "Please enter a server through [browse game] first", {{text="I know"}})
    end
end

-- In fact, this ui interface has no effect to write. it can be changed in the game settings.
-- But this is just the strength and convenience of showing the scroll interface
local ui_data = {
    {
        id = "server_quick",
        label = "Home [Reconnect]",
        hover = "Do you add the [quick reconnect] button on the homepage?",
        fn = ModSave("server_quick"),
        default = fn_moddata,
    },
    {
        id = "server_server",
        label = "Home [Server]",
        hover = "Do you add the [Server] button on the homepage?",
        fn = ModSave("server_server"),
        default = fn_moddata,
    },
    {
        id = "server_popup",
        label = "Login page [Reconnect]",
        hover = "Are you adding the [quick reconnect] button on the login page?",
        fn = ModSave("server_popup"),
        default = fn_moddata,
    },
    {
        id = "server_login",
        label = "Ensure login",
        hover = "It is guaranteed that there will be no skin problem in the game.\nThe cost is that the speed of fast reconnection will be slower...",
        fn = ModSave("server_login"),
        default = fn_moddata,
    },
    {
        id = "server_reco",
        label = "Method",
        hover = "Note: wegame does not support IP direct connection",
        fn = ModSave("server_reco"),
        type = "radio",
        data = {
			{description = "Normal", data = "sim"},
			{description = "IP reconnect", data = "ip"},
		},
        default = fn_moddata,
    },
}

local RightClick = m_util:AddBindShowScreen({
    title = string_quick,
    id = save_id,
    data = ui_data,
})

local function Fn()
    last_list = t_util:IPairFilter(last_list, function(data)
        return data.ip and data.port and data
    end)
    local l_screen = require("screens/huxi/serverlist")(last_list, function()
        s_mana:SaveSettingList(last_id, last_list)
    end, RightClick)
    TheFrontEnd:PushScreen(l_screen)
end
local multi_screen = require "screens/redux/multiplayermainscreen"
local TEMPLATES = require "widgets/redux/templates"
local _MakeSubMenu = multi_screen.MakeSubMenu
multi_screen.MakeSubMenu = function(self, ...)
    local ret = _MakeSubMenu(self, ...)
    if self.submenu and m_data.server_server then
        local count = table.count(self.submenu.children)
        local xml, tex = h_util:GetPrefabAsset("survivor_filter_off")
        self.submenu:AddChild(TEMPLATES.IconButton(xml, tex, "Servers", false, true, Fn, {font=NEWFONT_OUTLINE})):SetPosition(count*75, 0, 0)
    end
    return ret
end
local _MakeMainMenu = multi_screen.MakeMainMenu
multi_screen.MakeMainMenu = function(self, ...)
    local ret = _MakeMainMenu(self, ...)
    if self.menu and m_data.server_quick then
        local count = table.count(self.menu.children)
        local str = m_data.server_reco == "ip" and string_ip or string_sim
        self.menu:AddChild(TEMPLATES.MenuButton(str, Quick, str, self.tooltip)):SetPosition(0, count*38, 0)
    end
    return ret
end

AddClassPostConstruct(m_data.server_login and "screens/redux/multiplayermainscreen" or "screens/redux/mainscreen", function(self)
    if save_data.connect then
        local time = tonumber(save_data.time)
        if time and (time+60) > os.time() then
            Quick()
        end
        s_mana:SaveSettingLine(save_id, save_data, {connect = false, time = 0})
    end
end)


-- Player manually close the task
AddClassPostConstruct(screen_ss_url, function(self, prev_screen, filters, ...)
    local btn = self.cancel_button
    if btn then
        local _onclick = btn.onclick
        btn:SetOnClick(function(...)
            TaskCancel()
            _onclick(...)
        end)
    end
end)

-- Login page
if m_data.server_popup and not m_data.server_login then
    local data = GetQuickData()
    if data then
        local loginpopup = require "screens/redux/networkloginpopup"
        local ___BuildButtons = loginpopup._BuildButtons
        loginpopup._BuildButtons = function(self, ...)
            local btns = ___BuildButtons(self, ...)
            table.insert(btns, {
                text = m_data.server_reco == "ip" and string_ip or string_sim,
                cb = Quick,
            })
            return btns
        end
    end
end

local _JoinServer = _G.JoinServer
_G.JoinServer = function(sls,...)
    if sls and h_util:GetActiveScreen("ServerListingScreen") then
        sl_data = {
            ip = sls.ip,
            port = sls.port,
            guid = sls.guid,
            name = sls.name,
            style = sls.playstyle,
            session = sls.session
        }
    end
    return _JoinServer(sls,...)
end
local function SaveServerData()
    -- Forbidden to change the lines, the storage system of the painting roll depends on the change of the line
    sl_data.des = tostring(sl_data.des or ""):gsub("\n", "")
    sl_data.name = tostring(sl_data.name or ""):gsub("\n", "")
    local idata = t_util:IGetElement(last_list, function(data)
        return data.ip == sl_data.ip and data.port == sl_data.port and data
    end)
    if idata then
        t_util:Pairs(sl_data, function(k, v)
            idata[k] = v
        end)
    else
        table.insert(last_list, sl_data)
    end
    table.sort(last_list, function(a, b)
        return a.time > b.time
    end)
    local server_data_last = {} 
    for i, data in ipairs(last_list)do
        if i > max then
            break
        else
            table.insert(server_data_last, data)
        end
    end
    last_list = server_data_last
    s_mana:SaveSettingList(last_id, server_data_last)
end

local net = t_util:GetMetaIndex(TheNet)
local _JoinServerResponse = net and net.JoinServerResponse
if _JoinServerResponse then
    net.JoinServerResponse = function(self, cancel, guid, pwd, ...)
        if sl_data.guid == guid then
            sl_data.pwd = pwd
            sl_data.time = os.time()
            SaveServerData()
        end
        return _JoinServerResponse(self, cancel, guid, pwd, ...)
    end
end

m_util:AddBindConf(save_id, Quick, nil, {string_quick, "preset_linked", STRINGS.LMB..string_quick.."  "..STRINGS.RMB.."Advanced settings", true, Quick, RightClick, 7994})


-- Code note
-- local _OnNetworkDisconnect = _G.OnNetworkDisconnect
-- _G.OnNetworkDisconnect = function(message, ...)
--     if message == "ID_CONNECTION_ATTEMPT_FAILED" then
--     elseif message == "ID_ALREADY_CONNECTED" then
--     end
--     return _OnNetworkDisconnect(message, ...)
-- end