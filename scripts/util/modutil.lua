local m_util = {
    keybinds = {},
    enable_showme = false,
    enable_insight = false,
    f_datas = {},
    screen_data = {
        ids = {},
        titles = {},
    }
}
local t_util = require "util/tableutil"
local c_util = require "util/calcutil"
local h_util = require "util/hudutil"
local s_mana = require "util/settingmanager"
local i_util = require "util/inpututil"
local e_util = require "util/entutil"
local ismodder = s_mana:GetSettingLine("i_am_modder", true).ismodder
local MID_CONF = "biubiu"
local function NullFunction()
end
local names_loadmod = {}
local _print = print
function m_util:ClosePrint()
    print = NullFunction
end
function m_util:OpenPrint()
    print = _print
end

m_util:ClosePrint()
local modname_table = t_util:PairFilter(KnownModIndex:GetModsToLoad(), function(_, modname)
    local mod = KnownModIndex:GetModInfo(modname)
    table.insert(names_loadmod, modname)
    return mod and mod.name and mod.version and mod.name .. mod.version
end)
m_util:OpenPrint()

function m_util:HasModName(modname)
    return t_util:GetElement(modname_table, function(_, name)
        return c_util:IsStrContains(name, modname)
    end)
end

-- Maybe i will check the validity of mod after
local function getModName(modname)
    return type(modname) == "string" and modname or (Mod_ShroomMilk and Mod_ShroomMilk.Mod["藏冰"].path)
end
function m_util:IsTurnOn(conf, modname)
    modname = getModName(modname)
    if not modname then
        return print("The mod does not exist!")
    end
    if type(conf) == "table" then
        return not t_util:IGetElement(conf, function(config)
            return not GetModConfigData(config, modname, true)
        end)
    else
        return GetModConfigData(conf, modname, true)
    end
end

function m_util:IsInBan(list)
    if type(list) == "table" then
        return t_util:IGetElement(list, function(modname)
            return self:HasModName(modname)
        end)
    else
        return self:HasModName(list)
    end
end

-- Real -time binding through a unified interface
-- Registration: only record conf (as id) at the time of registration, function fn (binds this execution), no need to lift down (default to lift the response),
-- Other data meta (adapted panel),
-- Modname (provides this interface to modify other mods settings [this interface must be other mod to set the options and modify it to the data corresponding key code!]))

function m_util:AddBindConf(conf, fn, down, meta, modname)
    modname = getModName(modname)
    if not modname then
        return print("Can't bind!the mod does not exist!")
    end
    local key = GetModConfigData(conf, modname, true)
    local tp = type(key)
    local func = fn
    if tp == "number" then
        -- A bug is buried here. multiple changes will be binded by ingame suit, but it does not affect performance, so don't care about it.
        func = function()
            if m_util:InGame() then
                fn()
            end
        end
        local press = down and "onkeydown" or "onkeyup"
        TheInput[press]:AddEventHandler(key, func)
        if down == "both" then
            TheInput.onkeyup:AddEventHandler(key, func)
        end
    elseif tp == "string" then
        -- Biubiu haha, this is this, the commemorative commemorative from meng
        if key == MID_CONF then
            m_util:AddBindIcon(unpack(meta))
        end
    else
        -- The other key is also added to the situation of false
    end
    local a_set = {
        conf = conf,
        modname = modname,
        fn = func,
        down = down,
        meta = meta,
        key = key
    }
    table.insert(m_util.keybinds, a_set)
    return function(presskey)
        return presskey == a_set.key
    end
end

function m_util:ReBindConf(key, conf, modname)
    local bdata = t_util:IGetElement(m_util.keybinds, function(setting)
        return setting.conf == conf and setting.modname == modname and setting
    end)
    if not bdata then
        return print("An abnormal change!")
    end

    local function RemoveEp(ep)
        local handler = t_util:GetElement(TheInput[ep]:GetHandlersForEvent(bdata.key), function(handler)
            return handler.fn == bdata.fn and handler
        end)
        if handler then
            TheInput[ep]:RemoveHandler(handler)
        else
            print("No binding action is found")
        end
    end
    -- Unbind
    if bdata.key == MID_CONF then
        m_util:RemoveIcon(bdata.meta[1])
    elseif type(bdata.key) == "number" then
        RemoveEp(bdata.down and "onkeydown" or "onkeyup")
        if bdata.down == "both" then
            RemoveEp("onkeyup")
        end
    end
    if key == MID_CONF then
        m_util:AddBindIcon(unpack(bdata.meta))
    elseif type(key) == "number" then
        local press = bdata.down and "onkeydown" or "onkeyup"
        TheInput[press]:AddEventHandler(key, bdata.fn)
        if bdata.down == "both" then
            TheInput.onkeyup:AddEventHandler(key, bdata.fn)
        end
    end
    bdata.key = key
end

-- Front-end data
function m_util:LoadReBindData()
    local modsdata = {}
    return t_util:IPairFilter(m_util.keybinds, function(setting)
        local modname = getModName(setting.modname)
        if not modname then
            return
        end
        m_util:ClosePrint()
        modsdata[modname] = modsdata[modname] or KnownModIndex:LoadModConfigurationOptions(modname, true)
        m_util:OpenPrint()
        local moddata = modsdata[modname]
        return moddata and t_util:IGetElement(moddata, function(data)
            if data.name == setting.conf then
                local default = data.default
                local save = (type(data.saved) ~= "nil" and {data.saved} or {default})[1]
                local opts = type(data.options) == "table" and data.options or {}
                local data_default = t_util:IGetElement(opts, function(option)
                    return option.data == default and option.description
                end)
                local data_set = save == default and data_default or t_util:IGetElement(opts, function(option)
                    return option.data == save and option.description
                end)
                local allow_biubiu = t_util:IGetElement(opts, function(option)
                    return option.data == MID_CONF
                end)
                if data_set and data_default then
                    local id = setting.conf .. getModName(setting.modname)
                    return {
                        id = id,
                        label = data.label .. "：",
                        hover = data.hover,
                        default = tostring(data_set),
                        type = "textbtn",
                        fn = function(text, btns)
                            h_util:CreatePressScreen(data.label, text, data_default, allow_biubiu, opts,
                                function(value, text)
                                    local function SaveAndLoad()
                                        -- Storage mod settings
                                        local ret = m_util:SaveModOneConfig(setting.conf, value, modname)
                                        -- Re -bound mod settings
                                        m_util:ReBindConf(ret, setting.conf, setting.modname)
                                        -- Panel ui synchronization
                                        return ret
                                    end
                                    -- Repeat button reminder
                                    local rep_label = type(value) == "number" and
                                                          t_util:IGetElement(m_util.keybinds, function(set_data)
                                            if set_data.key == value and
                                                not (set_data.conf == setting.conf and set_data.modname ==
                                                    setting.modname) then
                                                local modname = getModName(set_data.modname)
                                                if not modname then
                                                    return
                                                end
                                                local moddata = modsdata[modname] or {}
                                                return t_util:IGetElement(moddata, function(data)
                                                    return data.name == set_data.conf and data.label
                                                end)
                                            end
                                        end)
                                    local ret = SaveAndLoad()

                                    if rep_label then
                                        if value == ret then
                                            i_util:DoTaskInTime(0.3, function()
                                                h_util:CreatePopupWithClose("Late tips",
                                                    "The keys and functions you set [" .. rep_label ..
                                                        "] the conflict is, but it is still successfully set up", {{
                                                        text = "I see"
                                                    }})
                                            end)
                                        end
                                        btns[id].uiSwitch("Button conflict " .. text)
                                    else
                                        btns[id].uiSwitch(text)
                                    end
                                end)
                        end
                    }
                end
            end
        end)
    end)
end

-- Write to mod settings
-- Value is written by default when it is empty
function m_util:SaveModOneConfig(c_name, c_value, modname)
    modname = getModName(modname)
    if not modname then
        return print("The mod does not exist! can't write!")
    end
    local ret
    m_util:ClosePrint()
    local config = KnownModIndex:LoadModConfigurationOptions(modname, true) or {}
    local settings = t_util:IPairFilter(config, function(conf_data)
        local name, value, default = conf_data.name, conf_data.saved, conf_data.default
        if name then
            if name == c_name then
                local opts = type(conf_data.options) == "table" and conf_data.options or {}

                if type(c_value) == "nil" then
                    value = default
                elseif t_util:IGetElement(opts, function(opt)
                    return opt.data == c_value
                end) then
                    value = c_value
                end
                ret = value
            end
            return {
                name = name,
                saved = value
            }
        end
    end)
    KnownModIndex:SaveConfigurationOptions(function()
    end, modname, settings, true)
    m_util:OpenPrint()
    return ret
end

-- Return to prefab in the game
local screen_names = {"ShowScreen"}
function m_util:RegisterScreenInGame(screen_name)
    t_util:Add(screen_names, screen_name)
end
function m_util:InGame()
    return ThePlayer and ThePlayer.HUD and
               (not ThePlayer.HUD:HasInputFocus() or table.contains(screen_names, h_util:GetActiveScreen().name)) and
               ThePlayer.components.hx_pusher and ThePlayer.prefab
end
-- Delay compensation
function m_util:GetMovementPrediction()
    return Profile:GetMovementPredictionEnabled()
end
function m_util:SetMovementPrediction(enable)
    enable = enable and true or false
    if ThePlayer then
        ThePlayer:EnableMovementPrediction(enable)
    end
    Profile:SetMovementPredictionEnabled(enable)
end

local is_lava, is_quag = TheNet:GetServerGameMode() == "lavaarena", TheNet:GetServerGameMode() == "quagmire"
function m_util:IsLava()
    return is_lava
end
function m_util:IsQuag()
    return is_quag
end

local is_server = TheNet:IsDedicated() or is_lava or (TheNet:GetIsServer() and TheNet:GetServerIsDedicated())
function m_util:IsServer()
    return is_server
end

function m_util:isHost()
    return TheWorld and TheWorld.ismastersim
end
-- Is this a test server?
function m_util:IsBata()
    return BRANCH ~= "release" and APP_VERSION;
end
function m_util:IsAdmin()
    return TheNet and TheNet:GetIsServerAdmin()
end

-- That's right, it's me
local ishuxi = TheSim:GetUsersName() == "466540397@steam"
function m_util:IsHuxi()
    return ishuxi or ismodder -- Interface to others
end
function m_util:IsMilker()
    return ishuxi
end

local icons = {}
local needrefresh
-- The interface here is provided outside, allowing other mods to register but also registered to mousse
-- Icondata can fill in {xml, tex} or only fill in prefab
-- Name default string is not allowed to be named, but it can be covered with {name}
-- This interface provides a way to right-click to bind a function. The test is perfect and it can be left blank
function m_util:AddBindIcon(name, icondata, hover, closewindow, func_left, func_right, priority)
    if type(name) == "string" and icons[name] then
        return print(name, "Button registration failed! Already registered")
    else
        if type(hover) == "string" and type(func_left) == "function" then
            local icon = {
                text = hover,
                func_left = func_left,
                close = closewindow and true,
                func_right = type(func_right) == "function" and func_right,
                priority = type(priority) == "number" and priority or 0,
                imgdata = icondata
            }
            local name = type(name) == "table" and name.name or name
            if type(name) ~= "string" then
                return print("The icon name is illegal!")
            else
                icon.name = name
                icons[name] = icon
                self:RefreshIcon(true)
            end
        else
            return print("The icon prompt or binding operation is illegal!")
        end
    end
end

-- This interface will construct showscreen
--[[
{
    title 弹窗标题
    id (不自动存储) 用于区分不同的screen并对接外界访问
    data 每个按钮的数据
    default 默认值
}

conf 模组配置, 为表时将赋予screen_data并直接返回构造函数
title 面板标题
icon 面板按钮
hover 面板提示
]]
--
local screen
function m_util:AddBindShowScreen(conf, title, icon, hover, screen_data, modname, priority)
    local function ScreenFn()
        if "ShowScreen" == h_util:GetActiveScreen().name then
            TheFrontEnd:PopScreen(screen)
        else
            screen = require("screens/huxi/showscreen")(screen_data)
            TheFrontEnd:PushScreen(screen)
        end
    end
    local tp_conf, tp_screen = type(conf), type(screen_data)
    if tp_conf == "table" then
        screen_data = conf
        return ScreenFn
    elseif tp_conf == "string" then
        if tp_screen == "table" then
            m_util:AddBindConf(conf, ScreenFn, nil, {title, icon, hover, true, ScreenFn, nil, priority}, modname)
        elseif tp_screen == "function" then
            return m_util:AddBindConf(conf, screen_data, nil, {title, icon, hover, true, screen_data, nil, priority},
                modname)
        end
    end
    self:RefreshIcon(true)
end

-- This method should not be called by mod authors, it is automatically called by showscreen
function m_util:HookShowScreenData(screen_data)
    local id, title = screen_data.id, screen_data.title
    local fns_id = id and self.screen_data.ids[id]
    local fns_title = title and self.screen_data.titles[title]
    if fns_id then
        t_util:IPairs(fns_id, function(fn)
            fn(screen_data.data, screen_data)
        end)
    end
    if fns_title then
        t_util:IPairs(fns_title, function(fn)
            fn(screen_data.data, screen_data)
        end)
    end
end

function m_util:BindShowScreenID(id, fn)
    if id and type(fn) == "function" then
        if self.screen_data.ids[id] then
            table.insert(self.screen_data.ids[id], fn)
        else
            self.screen_data.ids[id] = {fn}
        end
    end
end
function m_util:BindShowScreenTitle(title, fn)
    if title and type(fn) == "function" then
        if self.screen_data.titles[title] then
            table.insert(self.screen_data.titles[title], fn)
        else
            self.screen_data.titles[title] = {fn}
        end
    end
end


function m_util:PopShowScreen()
    if "ShowScreen" == h_util:GetActiveScreen().name then
        TheFrontEnd:PopScreen(screen)
    end
end

function m_util:RefreshIcon(state)
    needrefresh = state
end

function m_util:GetRefresh()
    return needrefresh
end

function m_util:RemoveIcon(name)
    if icons[name] then
        icons[name] = nil
        self:RefreshIcon(true)
        return true
    end
end

function m_util:GetIcons()
    return icons
end

-- Developer mode re-export
function m_util:print(...)
    if not m_util:IsHuxi() then
        return
    end
    local args = {}
    for _, v in ipairs({...}) do
        table.insert(args, tonumber(v) and math.floor(v) ~= v and string.format("%.2f", v) or v)
    end
    print(os.date("%I:%M:%S %p", os.time()), unpack(args))
end

-- Mod items
local ModPrefabs, LoadPrefabs = {}, {}
function m_util:IsModPrefab(prefab)
    if not LoadPrefabs[prefab] then
        ModPrefabs[prefab] = t_util:IGetElement(names_loadmod, function(name)
            local mod = ModManager:GetMod(name)
            local prefabs = mod and mod.Prefabs or {}
            return prefabs[prefab] and mod -- GetModFancyName(mod.modname)
        end)
        LoadPrefabs[prefab] = true
    end
    return ModPrefabs[prefab]
end

function m_util:EnableShowme()
    return m_util.enable_showme
end
function m_util:EnableInsight()
    return m_util.enable_insight
end

function m_util:QueryShowme(target)
    local guid = target and target.GUID
    if not guid then
        return
    end
    SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, guid, target)
    -- After the rpc is sent, you need to wait for the next round to receive the valid message.
    local data_hint = t_util:GetRecur(ThePlayer, "player_classified.showme_hint2")
    if not data_hint then
        return
    end

    -- Showme, copy!
    local function UnpackData(str, div)
        local pos, arr = 0, {}
        -- for each divider found
        for st, sp in function()
            return string.find(str, div, pos, true)
        end do
            table.insert(arr, string.sub(str, pos, st - 1))
            pos = sp + 1
        end
        table.insert(arr, string.sub(str, pos))
        return arr
    end

    local i = string.find(data_hint, ';', 1, true)
    if not i then
        return
    end
    local guid_get = tonumber(data_hint:sub(1, i - 1))
    if guid_get ~= guid then
        return
    end
    local str = data_hint:sub(i + 1)
    if not str or str == "" then
        return
    end
    str = UnpackData(str, "\2")
    local data_pack = {}
    for i, v in ipairs(str) do
        if v ~= "" then
            local param_str = v:sub(2)
            table.insert(data_pack, UnpackData(param_str, ","))
        end
    end
    local ret = {}
    t_util:IPairs(data_pack, function(data)
        if type(data) == "table" then
            t_util:IPairs(data, function(i)
                table.insert(ret, tonumber(i))
            end)
        end
    end)
    return ret
end

---Get saver
---@return Saver
function m_util:GetSaver()
    return TheWorld and TheWorld.components.hx_saver
end

---Get Player pusher
---@return Pusher
function m_util:GetPusher()
    return ThePlayer and ThePlayer.components.hx_pusher
end
---Install watcher (if used in AddPrefab, DoTaskIn0 is required)
---@param inst any
---@return Watcher
function m_util:AddWatcher(inst)
    local watcher = inst.components.hx_watcher
    return watcher or inst:AddComponent("hx_watcher")
end

local rightdata = {}
-- Registration function to Right-click enhancement
function m_util:AddRightMouseData(id, label, hover, default, fn, meta)
    meta = meta or {}
    rightdata[id] = {
        id = id,
        label = label,
        hover = hover,
        default = default,
        fn = fn,
        screen_data = meta.screen_data,
        priority = meta.priority or 0
    }
end
-- Press the mobile key
function m_util:IsMovePressing()
    for control = CONTROL_MOVE_UP, CONTROL_MOVE_RIGHT do
        if TheInput:IsControlPressed(control) then
            return true
        end
    end
end

local notedata = {}
-- Register a string to the note
function m_util:AddNoteData(id, title, width, height, content, meta)
    meta = meta or {}
    notedata[id] = {
        id = id,
        title = title,
        content = content,
        width = width,
        height = height,
        priority = meta.priority or 0
    }
end
-- Get data
function m_util:GetData(name)
    local Data = {}
    if name == "NOTE" then
        Data = notedata
    elseif name == "RIGHT" then
        Data = rightdata
    end
    local r_data = t_util:PairToIPair(Data, function(id, data)
        return data
    end)
    table.sort(r_data, function(a, b)
        return a.priority > b.priority
    end)
    return r_data
end

function m_util:RemoveHandler(ipt, eventname, func)
    local handler = ipt and eventname and t_util:GetElement(ipt:GetHandlersForEvent(eventname), function(handler)
        return handler.fn == func and handler
    end)
    if handler then
        ipt:RemoveHandler(handler)
    end
end

-- When using this interface, func must remain unchanged
function m_util:AddKeyBind(func, keycode, up)
    local press = up and "onkeyup" or "onkeydown"
    local ipt = TheInput[press]
    local id = self.f_datas[func]
    if id then
        self:RemoveHandler(ipt, id, func)
        m_util.f_datas[func] = nil
    end
    if not keycode then
        return
    end
    ipt:AddEventHandler(keycode, func)
    self.f_datas[func] = keycode
end

----------------------------------- Customized interface
function m_util:Load(path, default_data)
    local data = {}
    TheSim:GetPersistentString(path, function(success, data_load)
        if success and string.len(data_load) > 0 then
            success, data_load = RunInSandbox(data_load)
            data = success and data_load or {}
        end
    end)
    t_util:Pairs(default_data or {}, function(k, v)
        if data[k] == nil then
            data[k] = v
        end
    end)
    return data
end

function m_util:Save(path, save_data)
    TheSim:SetPersistentString(path, DataDumper(save_data, nil, false), false)
end

return m_util
