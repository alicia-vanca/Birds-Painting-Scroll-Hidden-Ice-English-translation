local m_util, t_util, w_mana, h_util, c_util, e_util = require "util/modutil", require "util/tableutil",
    require "util/worldmanager", require "util/hudutil", require "util/calcutil", require "util/entutil"
local total_day_time = TUNING.TOTAL_DAY_TIME
-- weather.lua caveweather.lua
local MOISTURE_RATES = {
    MIN = {
        autumn = .25,
        winter = .25,
        spring = 3,
        summer = .1
    },
    MAX = {
        autumn = 1.0,
        winter = 1.0,
        spring = 3.75,
        summer = .5
    }
}
local MIN_PRECIP_RATE = .1
local PRECIP_RATE_SCALE = 10
local LUNAR_HAIL_FLOOR = 0
local LUNAR_HAIL_CEIL = 100
local lunar_hail_rate_duration = LUNAR_HAIL_CEIL / TUNING.LUNARHAIL_EVENT_TIME
local MOONPHASE_DAY = {
    new = {
        [true] = 1,
        [false] = 1,
    },
    quarter = {
        [true] = 2,
        [false] = 18,
    },
    half = {
        [true] = 5,
        [false] = 15,
    },
    threequarter = {
        [true] = 8,
        [false] = 10, -- It could also be 12
    },
    full = {
        [true] = 11,
        [false] = 11,
    }
}

---@class Saver
---@field seed_world string Save/World Seed
---@field seed_player string Player Seed
---@field info table Save Information
---@field data table Save Data
---@field world any World Object
---@field func_leave table Leave Event Function
---@field func_save table Save Event Function
---@field stat_cate table Status Category
---@field stat_data table Status Data
---@field stat_conf table Status Configuration
---@field map_cate table Map Category
---@field map_data table Map Data
---@field map_conf table Map Configuration
---@field net_data table Network Data
---@field env_weather table Weather Data
local Saver = Class(function(self, world)
    local shardstate = t_util:GetRecur(world, "net.components.shardstate")
    self.seed_world = t_util:GetRecur(world, "meta.session_identifier") or "defaultworldseed"
    self.seed_player = shardstate and shardstate:GetMasterSessionId() or self.seed_world
    -- Inco = {set = archive/player seed, id = archive serial number, time_entry = inlet time, time_play = play time}
    self.info = w_mana:GetSessionData(self.seed_player, true)
    -- Set inlet time
    self.info.time_entry = os.time()
    -- All data
    self.data = w_mana:OpenID(self.info.id)
    assert(self.data, "Memory components are abnormal!")

    self.world = world
    self.func_leave = {}
    self.func_save = {}

    self.stat_cate = {}
    self.stat_data = {}
    self.stat_conf = {}
    self.map_cate = {}
    self.map_data = {}
    self.map_conf = {}

    self.net_data = nil


    self.func_sec_player = {}

    -- Triggered when re -election
    -- In fact, you can also extract the function when regstat, so that the execution efficiency will be a bit higher
    e_util:SetBindEvent(world, "entercharacterselect", function()
        if ThePlayer then
            return
        end
        t_util:Pairs(self.stat_cate, function(stat_name, cate_data)
            local entercharacterselect = cate_data.funcs.entercharacterselect
            if entercharacterselect then
                entercharacterselect(self.stat_data[stat_name], self:GetStatSW(stat_name))
            end
        end)
    end)

    -- Used for refreshing of the info tray
    world:DoPeriodicTask(1, function()
        t_util:Pairs(self.stat_cate, function(stat_name, cate_data)
            local periodic = cate_data.funcs.periodic
            if periodic then
                local worldtime = self:GetWorldTime()
                local now = GetTime()
                t_util:Pairs(self.stat_data[stat_name], function(id, data)
                    local ret = periodic(data, id, worldtime, now)
                    if ret then
                        if self:GetStatSW(stat_name) then
                            self:ChanTimerUI(self:GetStatID(stat_name, id), ret)
                        end
                    else
                        self:RemoveStat(stat_name, id)
                    end
                end)
            end
        end)
    end)


    -- Initialize some repeated amounts
    self.env_weather = self:LoadWeatherEnv()
    -- self.env_world = self:LoadWorldEnv()
    total_day_time = TUNING.TOTAL_DAY_TIME
    lunar_hail_rate_duration = LUNAR_HAIL_CEIL / TUNING.LUNARHAIL_EVENT_TIME


    -- Moon Phase Statistics
    self.moonstyle = "default" -- "default","alter_active", "glassed_default", "glassed_alter_active"
    self.moonphase = "new"
    self.moonwaxing = true
    self.moon_new = 1
    self.moonright = self:GetWorldDays() < 3 -- Is it valid data?

    e_util:SetBindEvent(world, "moonphasestylechanged", function(_, data)
        self.moonstyle = data and data.style or self.moonstyle
    end)
    
    -- 新月 (New) → 娥眉月 (Waxing Crescent) → 上弦月 (First Quarter) → 盈凸月 (Waxing Gibbous) → 满月 (Full)  
    -- 满月 (Full) → 亏凸月 (Waning Gibbous) → 下弦月 (Last Quarter) → 残月 (Waning Crescent) → 新月 (New)

    e_util:SetBindEvent(world, "moonphasechanged2", function(_, data)
        if not data then return end
        self.moonwaxing = data.waxing
        self.moonphase = data.moonphase or self.moonphase
        local moonphase_day = MOONPHASE_DAY[self.moonphase] and MOONPHASE_DAY[self.moonphase][self.moonwaxing] or 1     -- Standard Moon
        moonphase_day = moonphase_day == 10 and (self.moonphase_last=="full" and 12 or 10) or moonphase_day
        self.moon_new = (self:GetWorldDays() - moonphase_day)%20+1                                                      -- Standard Crescent
        if (not self.moonright and table.contains({"new", "full"}, self.moonphase)) or (self.moonphase_last and self.moonphase_last~=self.moonphase) then
            self.moonright = true
        end
        self.moonphase_last = self.moonphase
    end)
end)
----------------------- Initialization -----------------------
-- World settings
-- Get better with TheWorld.topology.overrides
function Saver:LoadWorldEnv()
    if self.net_data then
        return self.net_data
    end
    local netdata = TheNet:GetServerListing()
    local world_gen_data = netdata and netdata.world_gen_data
    if world_gen_data then
        local _, loaddata = RunInSandboxSafeCatchInfiniteLoops(world_gen_data)
        if loaddata and loaddata.str then
            loaddata = TheSim:DecodeAndUnzipString(loaddata.str)
            if loaddata then
                local _, worldsdata = RunInSandboxSafeCatchInfiniteLoops(loaddata)
                return t_util:GetElement(worldsdata or {}, function(_, data)
                    self.net_data = data.location and data.location == self.world.worldprefab and data
                    return self.net_data
                end)
            end
        end
    end
end

-- Climate data
function Saver:LoadWeatherEnv()
    local fn_weather = t_util:GetElement(self.world.net and self.world.net.components or {}, function(name, comp)
        return name:find("weather") and comp.GetDebugString
    end)
    return fn_weather and c_util:GetFnEnv(fn_weather)
end


----------------------- Operations about this world ----------------------
-- Get rainfall time
-- The core is (the upper limit required for rainfall -current moisture)/water rising rate
-- The rising rate of water changes every day, but this is fixed, so it can be calculated at any time
function Saver:GetRainStart()
    local state = self.world.state

    local moisture, moistureceil, season, elapseddaysinseason, progress, seasonlength, todaypct = state.moisture, -- Humidity,
    state.moistureceil, -- Humid upper limit
    state.season, -- Season
    state.elapseddaysinseason, -- The number of days that has passed
    state.seasonprogress, -- Season progress
    state[state.season.."length"], -- Season days,
    state.time      -- The percentage passed today

    local seasonlength_fix = seasonlength
    if season == "autumn" or season == "spring" then
        -- Seasons.lua line 209: spring and autumn period adjustment
        seasonlength_fix = seasonlength*2
    end

    -- Wet rising rate
    local function GetMoisRate()
        if self.world:HasTag("forest") and season == "winter" and elapseddaysinseason == 2 then
            -- Weather line 487: corele hopes to snow early in winter, so that the ground is covered with snow, and the speed is directly like the avalanche.
            return 50
        else
            local p = 1 - math.sin(PI * progress)
            return MOISTURE_RATES.MIN[season] + p * (MOISTURE_RATES.MAX[season] - MOISTURE_RATES.MIN[season])
        end
    end


    local time_cost = (1-todaypct) * total_day_time
    local mois_rate = GetMoisRate()
    moisture = moisture + mois_rate*time_cost

    while elapseddaysinseason < seasonlength do
        -- When the target moisture is greater than the threshold, it pops up
        if moisture > moistureceil then
            return time_cost - (moisture - moistureceil)/mois_rate
        end
        -- Add water by day
        elapseddaysinseason = elapseddaysinseason + 1
        progress = 1 - (seasonlength - elapseddaysinseason)/seasonlength_fix
        time_cost = time_cost + total_day_time
        mois_rate = GetMoisRate()
        moisture = moisture + mois_rate*total_day_time
    end
end

-- Get in rainstorm
-- This calculation quantity is more than start, and the calculation time of frame accumulation
function Saver:GetRainStop()
    local state = self.world.state
    if state.islunarhailing then
		return state.lunarhaillevel / lunar_hail_rate_duration
	end


    local env = self.env_weather
    if not env then return end

    -- Numeric load
    local moisture = env._moisture:value()
    local moisturefloor = env._moisturefloor:value()
    local moistureceil = env._moistureceil:value()
    local peakprecipitationrate = env._peakprecipitationrate:value()

    local diff = moistureceil - moisturefloor
    local precip_rate = 1 - MIN_PRECIP_RATE

    -- Rainfall
    local function GetPreciprate()
        local p = math.max(0, math.min(1, (moisture - moisturefloor) / diff))
        local rate = MIN_PRECIP_RATE + precip_rate * math.sin(p * PI)
        return math.min(rate, peakprecipitationrate)
    end

    -- Statistics
    local time_cost = 0
    while moisture > moisturefloor do
        -- When the water is lower than the threshold, it pops up
        local preciprate = GetPreciprate()
        time_cost = time_cost + FRAMES
        if preciprate < 0 then
            break
            -- There is a probability that frog rain, otherwise i wrote here here
            -- frograin.lua line 137
        end
        moisture = moisture - preciprate * FRAMES * PRECIP_RATE_SCALE
    end
    return time_cost
end

-- Get rainfall statement
-- 250314 VanCa: Edit str_say structure for more nature English
function Saver:GetRainPredict()
    local state = self.world.state
    local time = state.pop == 1 and self:GetRainStop() or self:GetRainStart()
    local str_say
    local iscave = self.world:HasTag("cave")
    local str_pos = iscave and "Cave" or "Surface"
    if time then
        local str_time = c_util:FormatSecond_ms(time)
        local str_weather = state.season == "winter" and not iscave and "Snowfall" or "Rainfall"
        if state.pop == 1 then
            if state.islunarhailing then
                str_say = "This moon hail will end in "..string.format("%d", time).." seconds"
            else
                str_weather = state.isacidraining and "Acid Rain" or str_weather
                str_say = str_pos..": "..str_weather.." will end in "..str_time
            end
        else
            str_say = str_pos.." will experience "..str_weather.." in "..str_time
        end
    else
        if iscave then
            str_say = "This season, there will be no more rain or snow in "..str_pos
        else
            str_say = "This season, there will be no more rain or snow on "..str_pos
        end
    end
    return str_say.."。"
end

-- Get the world time
local Last_time = 88888888
-- Total world time
function Saver:GetWorldTime()
    local world = self.world
    local state_time = world.state.time
    local state_cycles = world.state.cycles
    local sys_time = (state_cycles + state_time) * total_day_time
    local diff_time = sys_time - Last_time -- Normally, diff should be between 0-2
    if state_time < 0.98 or diff_time > total_day_time + 5 or diff_time < total_day_time - 5 then
        -- Time lock, the client will also check whether the server sends the error time
        Last_time = sys_time
    end
    return Last_time
end
-- Today's time
function Saver:GetTodayTime()
    return self.world.state.time*total_day_time
end
-- The time this season lasts
function Saver:GetSeasonTime()
    return self.world.state.elapseddaysinseason*total_day_time+self:GetTodayTime()
end
-- Times of Day
function Saver:GetTotalDayTime()
    return total_day_time
end
-- A season of time
function Saver:GetTotalSeasonTime()
    return (self.world.state.remainingdaysinseason+self.world.state.elapseddaysinseason)*total_day_time
end
-- World Days
function Saver:GetWorldDays()
    return math.ceil(self:GetWorldTime()/total_day_time)
end
-- World settings
function Saver:GetFile()
    return w_mana:GetTheFileName()
end

-- Get moon phase data
function Saver:GetNewMoonDay()
    return {
        right = self.moonright, -- Is it accurate?
        waxing = self.moonwaxing, -- Whether to wind or not
        day = self.moon_new,   -- New Moon Night
        phase = self.moonphase, -- Current moon phase
        alter = self.moonstyle == "alter_active" or self.moonstyle == "glassed_alter_active", -- Is it an enlightenment night?
        glass = self.moonstyle == "glassed_default" or self.moonstyle == "glassed_alter_active", -- Have you killed a celestial being?
    }
end

----------------------- Data interaction related ----------------------------

-- Obtain table
-- Id: table name 
-- Single: single world watch or the entire archive table
-- Single world table can be used for map icons, the entire archive table is used to cross caves or multi -layer record data
function Saver:GetMap(id, single)
    return self.data:GetSettingMap(self:GetKey(id, single), true)
end
function Saver:GetList(id, single)
    return self.data:GetSettingList(self:GetKey(id, single), true)
end
function Saver:GetLine(id, single)
    return self.data:GetSettingLine(self:GetKey(id, single), true)
end

-- Storage file data
function Saver:Save()
    -- Data processing before saving
    local now = GetTime()
    t_util:IGetElement(self.func_save, function(func)
        func(now, self.world)
    end)
    self.data:Save()
end
-- Get archive seeds
function Saver:GetSeed(single)
    return single and self.seed_world or self.seed_player
end

-- Func (world) executed before exiting
function Saver:RegLeaveFunc(func)
    if type(func) == "function" then
        table.insert(self.func_leave, func)
    end
end

-- Func (world) executed before saving
function Saver:RegSaveFunc(func)
    if type(func) == "function" then
        table.insert(self.func_save, func)
    end
end
---------------------- Map icon related --------------------------
-- Related usage to see the following [info tray related], the following method i copied all below
function Saver:RegHMap(stat_name, label, hover, default, fn, meta)
    assert(not self.map_cate[stat_name] and not self.map_data[stat_name] and type(stat_name) == "string",
        "Illegal registration map icon!")
    meta = meta or {}
    self.map_cate[stat_name] = {
        label = label,
        hover = hover,
        default = default,
        fn = fn,
        meta = meta,
        scale = meta.scale,
        nothud = meta.nothud,
        notmap = meta.notmap,
    }
    self.map_data[stat_name] = {}
    self.map_conf[stat_name] = (type(default) == "function" and {default()} or {default})[1]
end
function Saver:GetHMapShowScreenData()
    return t_util:PairToIPair(self.map_cate, function(stat_name, data)
        return {
            id = stat_name,
            label = data.label,
            hover = data.hover,
            default = data.default,
            fn = data.fn,
            screen_data = data.meta.screen_data,
        }
    end)
end
local function DoHMap(func)
    t_util:IPairs(h_util:GetHMaps(), func)
end
function Saver:SetHMapConf(save_data)
    if save_data then
        t_util:Pairs(self.map_conf, function(k, v)
            save_data[k] = v
        end)
        self.map_conf = save_data
    end
end
function Saver:RefreshHMap()
    DoHMap(function(hmap)
        hmap:BuildHMap(self.map_conf, self:GetHMapUIData())
    end)
end

function Saver:GetHMapData(stat_name)
    return self.map_data[stat_name]
end
-- Some things can be preset, such as scale, nothud, notmap, etc. in meta
-- When converting info to icon, we need to obtain these data, so we package info twice
function Saver:PackInfo(stat_name, info)
    local cate_data = self.map_cate[stat_name]
    if cate_data then
        if h_util:GetPrefabAsset(info.icon) then -- In fact, this is not a good way to write it, because hx_map will judge it again
            local stat_id = self:GetHMapID(stat_name, info)
            if stat_id then
                return stat_id, {
                    id = stat_id,
                    icon = info.icon,
                    x = info.x,
                    z = info.z,
                    scale = cate_data.scale,
                    notmap = cate_data.notmap,
                    nothud = cate_data.nothud,
                }
            end
        end
    end
end
function Saver:GetHMapUIData()
    local cates = t_util:PairToIPair(self.map_cate, function(stat_name)
        return self:GetHMapSW(stat_name) and stat_name
    end)
    local timer_data = {}
    t_util:IPairs(cates, function(stat_name)
        t_util:Pairs(self.map_data[stat_name], function(stat_id, p_info)
            table.insert(timer_data, p_info)
        end)
    end)
    return timer_data
end

function Saver:GetHMapID(stat_name, info)
    if stat_name and info.icon and info.x and info.z then
        return string.format("%s:%s:%.2f:%.2f", stat_name, info.icon, info.x, info.z)
    end
end
-- {icon, x, z, nothud, notmap}
-- This is not a very good code. If the icon cannot be indexed by hutil, it will not be displayed.
function Saver:AddHMap(stat_name, info, tobuild)
    local stat_id, p_info = self:PackInfo(stat_name, info)
    if not stat_id then return end
    self.map_data[stat_name][stat_id] = p_info
    if tobuild then
        DoHMap(function(hmap)
            hmap:AddHMap(stat_id, p_info)
        end)
    end
    return true
end

function Saver:RemoveHMap(stat_name, info)
    local data = self.map_data[stat_name]
    if data then
        local stat_id = self:GetHMapID(stat_name, info)
        data[stat_id] = nil
        DoHMap(function(hmap)
            hmap:RemoveHMap(stat_id)
        end)
    end
end
function Saver:ClearHMap(stat_name)
    self.map_data[stat_name] = {}
    self:RefreshHMap()
end

-- Please do not change the order of the code here, it is quite messy.
function Saver:ChanHMap(stat_name, info_old, info_new)
    local data = self.map_data[stat_name]
    if data then
        local id_old, info_old = self:PackInfo(stat_name, info_old)
        info_new.id = self:GetHMapID(stat_name, info_new)
        t_util:Pairs(info_old, function(k, v)
            if type(info_new[k])=="nil" then
                info_new[k] = v
            end
        end)
        DoHMap(function(hmap)
            -- Currently, chan only supports modifying x, z, and icon. It does not support modifying nothud, scale, etc. It will be added later if there is demand
            hmap:ChanHMap(id_old, info_new.id, info_new)
        end)
        data[id_old] = nil
        data[info_new.id] = info_new
    end
end

function Saver:GetHMapSW(stat_name)
    return c_util:NilIsTrue(self.map_conf[stat_name])
end

--------------------- related to the info tray --------------------------------------------------------------------------
-- Register a state of a category, for a certain category of rules
--[[
{
    periodic(data, id, sw) 每秒执行一次，参数是该类别的每一条数据，不管开关都会执行,  为真时ChanUI，为假时移除数据
    addstat(data, id) 调用AddStat前执行 (其实你也可以AddStat的时候自己执行完), 返回true时成功添加
    sort(a, b) 执行table.sort()用, 用于同类别比较
    entercharacterselect(data, sw) 重新选角色时触发, data是该类别的所有数据，sw是开关
}
]] --

function Saver:RegStat(stat_name, label, hover, default, fn, funcs, meta)
    assert(not self.stat_cate[stat_name] and not self.stat_data[stat_name] and type(stat_name) == "string",
        "Illegal registration of the respiratory bar!")
    self.stat_cate[stat_name] = {
        label = label,
        hover = hover,
        default = default,
        fn = fn,
        funcs = funcs or {},
        meta = meta or {}
    }
    self.stat_data[stat_name] = {}
    self.stat_conf[stat_name] = (type(default) == "function" and {default()} or {default})[1]
end

-- Get the data of the display panel and realize the increase of cross -file increase to [info tray]
function Saver:GetStatShowScreenData()
    return t_util:PairToIPair(self.stat_cate, function(stat_name, data)
        return {
            id = stat_name,
            label = data.label,
            hover = data.hover,
            default = data.default,
            fn = data.fn,
            screen_data = data.meta.screen_data,
        }
    end)
end

-- Add data from a certain state
function Saver:AddStat(stat_name, stat_id, data)
    local info = self.stat_data[stat_name]
    if info then
        -- Interface call
        local addstat = self.stat_cate[stat_name].funcs.addstat
        if addstat then
            -- M_util: print ('try to add registered buff', stat_name, stat_id)
            if addstat(data, stat_id) then
                info[stat_id] = data
            end
        else
            info[stat_id] = data
        end
    end
end
-- Remove data from a certain state
function Saver:RemoveStat(stat_name, stat_id)
    local data = self.stat_data[stat_name]
    if data then
        local rebuild = data[stat_id] and self:HasStatUI(stat_name, stat_id)
        data[stat_id] = nil
        if rebuild then
            self:SetTimerConfig()
        end
    end
end
-- Whether there is statui
function Saver:HasStatUI(stat_name, stat_id)
    local timer = h_util:GetTimer()
    if timer then
        return timer:HasUI(self:GetStatID(stat_name, stat_id))
    end
end
-- Remove all data in a certain state and refresh
function Saver:ClearStat(stat_name)
    self.stat_data[stat_name] = {}
    self:SetTimerConfig()
end

function Saver:GetStatData(stat_name)
    return self.stat_data[stat_name]
end

-- Get a button id
function Saver:GetStatID(stat_name, stat_id)
    return stat_name .. "_" .. stat_id
end

-- Convert time to text
-- In fact, the interface can be introduced here, and the time is converted into other formats set. when others need to change it later, change it.
function Saver:FormatSecond(time)
    return c_util:FormatSecond_dms(time)
end

-- Refresh the info tray settings
function Saver:SetTimerConfig(save_data)
    if save_data then
        t_util:Pairs(self.stat_conf, function(k, v)
            save_data[k] = v
        end)
        self.stat_conf = save_data
    end
    local timer = h_util:GetTimer()
    if timer then
        timer:BuildTimer(self.stat_conf, self:GetTimerData())
    end
end


-- Input: {xml, text, value or text, descripide}
-- Output: {id, xml, text, fn_left, fn_right, text, descripie}
-- Value is used for additional comparison
function Saver:GetTimerData()
    local cates = t_util:PairToIPair(self.stat_cate, function(stat_name)
        return self:GetStatSW(stat_name) and stat_name
    end)
    -- Here
    table.sort(cates, function(c1, c2)
        local p1 = self.stat_cate[c1].meta.priority or 0
        local p2 = self.stat_cate[c2].meta.priority or 0
        return p1 > p2
    end)

    local timer_data = {}
    t_util:IPairs(cates, function(stat_name)
        local cate_data = self.stat_cate[stat_name]
        local funcs = cate_data.funcs
        local meta = cate_data.meta
        local cate_data = t_util:PairToIPair(self.stat_data[stat_name], function(stat_id, data)
            return {
                id = self:GetStatID(stat_name, stat_id),
                xml = data.xml,
                tex = data.tex,
                fn_left = funcs.fn_left and function()
                    funcs.fn_left(data, stat_id)
                end,
                fn_right = funcs.fn_right and function()
                    funcs.fn_right(data, stat_id)
                end,
                text = data.text or self:FormatSecond(data.value),
                describe = data.describe,
                value = data.value,
                color = data.color or meta.color,
            }
        end)
        if funcs.sort then
            table.sort(cate_data, funcs.sort)
        end
        timer_data = t_util:MergeList(timer_data, cate_data)
    end)
    return timer_data
end

function Saver:ChanTimerUI(id, meta)
    local timer = h_util:GetTimer()
    if timer then
        timer:ChanUI(id, meta)
    end
end

function Saver:ChanStatUI(stat_name, stat_id, info)
    local timer = h_util:GetTimer()
    if timer then
        timer:ChanUI(self:GetStatID(stat_name, stat_id), {
            text = {
                text = info.text,
                color = info.color
            },
            img = {
                xml = info.xml,
                tex = info.tex,
            },
            describe = info.describe,
        })
    end
end

-- Get the switch of an option
function Saver:GetStatSW(stat_name)
    return c_util:NilIsTrue(self.stat_conf[stat_name])
end

---------------------- Methods that developers are not recommended to call --------------------
-- When leaving the game, theworld is available, but theplayer is not available
-- This interface will be automatically called, and developers do not need to call
function Saver:Leave()
    -- Data processing before leaving
    t_util:IGetElement(self.func_leave, function(func)
        func(self.world)
    end)
    -- Set up time
    local time_start = self.info.time_entry
    local time_play_now = time_start and os.time() - time_start or 0
    local time_play_old = self.info.time_play or 0
    self.info.time_play = time_play_now + time_play_old
    -- Storage
    w_mana:SaveData()
    self:Save()
end
-- It seems that the outside world does not need this method
function Saver:GetKey(id, single)
    local key = self:GetSeed(single)
    local mark = single and "_1_" or "_0_"
    return key .. mark .. tostring(id)
end

return Saver
