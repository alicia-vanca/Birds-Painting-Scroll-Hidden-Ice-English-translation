local t_util = require "util/tableutil"
local h_util = require "util/hudutil"
local f_util = require "util/fn_hxcb"
local e_util = require "util/entutil"
local save_data = f_util.save_data
local load_data = f_util.load_data
local m_util = require "util/modutil"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TextBtn = require "widgets/textbutton"
local role_stats = require "data/hx_cb/stats/role"
local lmb, rmb = STRINGS.LMB, "\n"..STRINGS.RMB
local code_range_delete = 'local pos=_U_:GetPosition()for _,o in ipairs(TheSim:FindEntities(pos.x,pos.y,pos.z,{range_delete},nil,{"FX","DECOR","INLIMBO","NOCLICK","multiplayer_portal"}))do if not o:HasTag("player")or o.userid==""then print(o.prefab)o:Remove()end end '
local c_util = require "util/calcutil"


local LS = {
    size_label = 25,
    size_text = 24,
    space_text = 10,
}

function LS:ALabel(str)
    str = str .. ": "
    local text = Text(DEFAULTFONT, self.size_label, str)
    local w, h = text:GetRegionSize()
    return {
        ui = text,
        shift = w,
        height = self.size_label,
    }
end

function LS:ATextBtn(str)
    local btn = TextBtn()
    btn:SetTextSize(self.size_text)
    btn:SetText(str)
    btn:SetTextFocusColour({0,1,1,1})
    local w, h = btn:GetSize()
    return {
        ui = btn,
        shift = w + self.space_text,
        height = h,
    }
end



function LS:AStat(data, size_stat)
    size_stat = size_stat or 38
    local xml, tex = h_util:GetPrefabAsset(data.icon, true)
    local w
    if xml:find("scrapbook_icons") or (xml:find("hx_icons2") and tex:find("icon_badge_")) then
        w = Image(xml, tex)
    else
        w = Image("images/hx_icons2.xml", "icon_badge_pure.tex")
        local icon = w:AddChild(Image(xml, tex))
        icon:ScaleToSize(size_stat, size_stat)
    end
    w:ScaleToSize(size_stat, size_stat)
    w:SetHoverText(data.hover, { offset_y = 2*size_stat })
    h_util:BindMouseClick(w, {
        [MOUSEBUTTON_LEFT] = function(ui)
            if data.left then
                data.left()
            end
        end,
        [MOUSEBUTTON_RIGHT] = function(ui)
            if data.right then
                data.right()
            end
        end,
    }, {sound = "double"})
    return w
end


function LS:LineTextBtn(label_str, btns)
    local ps = {}
    local plabel = self:ALabel(label_str)
    table.insert(ps, plabel)
    t_util:IPairs(btns, function(btn)
        if btn.tagnot and TheWorld and TheWorld:HasTag(btn.tagnot) then
            return
        end
        if btn.text then
            local meta = btn.meta or {}
            local pbtn = self:ATextBtn(subfmt(btn.text, meta))
            if btn.hover then
                local hover = subfmt(btn.hover, meta)
                pbtn.ui.image:SetHoverText(hover, {offset_y = hover:find("\n") and 3*self.size_text or 2*self.size_text})
            end
            h_util:BindMouseClick(pbtn.ui, {
                [MOUSEBUTTON_LEFT] = btn.left,
                [MOUSEBUTTON_RIGHT] = btn.right,
            }, {sound = "double"})
            table.insert(ps, pbtn)
        end
    end)

    local w = Widget("line_textbtns")
    local pos_x, h_max = 0, 0
    t_util:IPairs(ps, function(p)
        w:AddChild(p.ui)
        local half = (p.shift or 0) / 2
        pos_x = pos_x + half
        h_max = math.max(h_max, p.height or 0)
        p.ui:SetPosition(pos_x, 0)
        pos_x = pos_x + half
    end)
    return {
        ui = w,
        height = h_max,
    }
end

function LS:PackLines(...)
    local w = Widget("lines")
    local h = 0
    t_util:Pairs({...}, function(_, line)
        if line and line.ui then
            
            local half = (line.height or 0)/2
            h = h - half
            line.ui:SetPosition(0, h)
            w:AddChild(line.ui)
            h = h - half
        end
    end)
    return w
end

function LS:PackRoleStats()
    local w = Widget("role_stats")
    local datas = {}
    t_util:Pairs(role_stats, function(prefab, stats)
        t_util:IPairs(stats, function(stat)
            if stat.icon:find("icon_badge_") then
                table.insert(datas, stat)
            end
        end)
    end)
    local col_stat,size_stat = 7, 38
    local space = size_stat + 2
    local pos_x, pos_y = save_data.lright and 20 or 10, -20
    for i, data_stat in ipairs(datas) do
        local stat = w:AddChild(self:AStat(data_stat, size_stat))
        local col, line = i%col_stat, math.ceil(i / col_stat)
        col = col == 0 and col_stat or col
        stat:SetPosition((col - 1) * space + pos_x, (line-1)*-space + pos_y)
    end
    return w
end


function LS:world_season()
    local seasons = {
        {"Spring", "spring"},
        {"Summer", "summer"},
        {"Autumn", "autumn"},
        {"Winter", "winter"},
    }
    return self:LineTextBtn("Season", t_util:IPairToIPair(seasons, function(s)
        local meta = {chs = s[1], season = s[2]}
        return {
            text = "{chs}",
            hover = "Switch to {chs}!",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_setseason", "{season}")', "Switch season to {chs}", meta),
            meta = meta,
        }
    end))
end

function LS:world_phase()
    local opts = {
        {
            text = "Next phase",
            hover = lmb.."Jump to the next time phase!"..rmb.."Players also jump!",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_nextphase")', "Jump to the next phase!"),
            right = function()
                local saver = m_util:GetSaver()
                if not saver then return end
                local fb_db = t_util:GetRecur(TheWorld, "net.components.clock.GetDebugString")
                if not fb_db then return end
                local fn_env = c_util:GetFnEnv(fb_db)
                local TIME_PHASE = fn_env._remainingtimeinphase and fn_env._remainingtimeinphase:value() or 0
                f_util:ExRemote('LongUpdate({left})', 'Players jump to the next phase', {left = TIME_PHASE})
            end
        }
    }
    t_util:IPairs({1, 2, 5, 10, 20}, function(day)
        local meta = {day = day}
        table.insert(opts, {
            meta = meta,
            text = "{day} days",
            hover = lmb.."Skip {day} days!"..rmb.."Players also skip!",
            left = f_util:FuncConfirmRemote("Skip time", "Are you sure you want to skip {day} days? (Player status will not follow)", 'LongUpdate(TUNING.TOTAL_DAY_TIME*{day}, true)', "Skip {day} days", meta),
            right = f_util:FuncConfirmRemote("Skip time", "Are you sure you want to skip {day} days? (Player status will follow)", 'LongUpdate(TUNING.TOTAL_DAY_TIME*{day})', "Players skip {day} days", meta),
        })
    end)
    return self:LineTextBtn("Time", opts)
end

function LS:world_weather()
    return self:LineTextBtn("Weather", {
        {
            text = "Rain/Snow",
            hover = lmb.."Start rain or snow"..rmb.."Stop rain or snow",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_forceprecipitation", true)', "Start rain or snow"),
            right = f_util:FuncExRemote('TheWorld:PushEvent("ms_forceprecipitation", false)', "Stop rain or snow")
        },{
            text = "Lightning",
            hover = "Call lightning!",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_sendlightningstrike", _U_:GetPosition())', "Summon lightning!"),
            tagnot = "cave",
        },{
            text = "Wetness",
            hover = lmb.."World wetness: 100%"..rmb.."World wetness: 0",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_deltawetness", 1000)', "World wetness: 100%"),
            right = f_util:FuncExRemote('TheWorld:PushEvent("ms_deltawetness", -1000)', "World wetness: 0"),
        },{
            text = "Lunar hail",
            hover = lmb.."Start lunar hail!"..rmb.."Stop lunar hail!",
            left = function()
                if TheWorld and not TheWorld.state.islunarhailing then
                    f_util:ExRemote('TheWorld:PushEvent("ms_startlunarhail")', 'Lunar hail starts falling!')
                end
            end,
            right = function()
                if TheWorld and TheWorld.state.islunarhailing then
                    f_util:ExRemote('local w = TheWorld.net and TheWorld.net.components.weather if w then w:LongUpdate(TUNING.LUNARHAIL_EVENT_TIME) end', 'Lunar hail has stopped.')
                end
            end,
            tagnot = "cave",
        }
    })
end

function LS:world_star()
    if not TheWorld or TheWorld:HasTag("cave") then return end
    return self:LineTextBtn("Astronomy", {
        {
            text = "Moon phase",
            hover = lmb.."Set today's moon phase to full"..rmb.."Set today's moon phase to new moon",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_setmoonphase",{moonphase = "full"})', "Moon phase: full"),
            right = f_util:FuncExRemote('TheWorld:PushEvent("ms_setmoonphase",{moonphase="new",iswaxing=true})', "Moon phase: new"),
        },{
            text = "Eclipse",
            hover = lmb.."Set today's world to full daytime"..rmb.."Set today's world to full nighttime",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_setclocksegs",{day=16,dusk=0,night=0})', "Eclipse: daytime"),
            right = f_util:FuncExRemote('TheWorld:PushEvent("ms_setclocksegs",{day=0,dusk=0,night=16})', "Eclipse: nighttime"),
        },{
            text = "Meteor",
            hover = "Spawn a meteor!",
            left = f_util:FuncExRemote('local met=SpawnPrefab("shadowmeteor") local pos=_U_:GetPosition() met.Transform:SetPosition(pos.x, pos.y, pos.z)', "Summon meteor!"),
        },{
            text = "Moon storm",
            hover = lmb.."Start moon storm"..rmb.."Stop moon storm",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_startthemoonstorms")', "Moon storm: start"),
            right = f_util:FuncExRemote('TheWorld:PushEvent("ms_stopthemoonstorms")', "Moon storm: stop"),
        },
    })
end

function LS:cave_npc()
    if not TheWorld or not TheWorld:HasTag("cave") then return end
    local data = {
        {id = "calm", chs = "Calm"},
        {id = "warn", chs = "Warning"},
        {id = "wild", chs = "Nightmare"},
        {id = "dawn", chs = "Dawn"},
    }
    return self:LineTextBtn("Ancient phase", t_util:IPairToIPair(data, function(meta)
        return {
            meta = meta,
            text = "{chs}",
            hover = "Change the ancient nightmare phase to: {chs}",
            left = f_util:FuncExRemote('TheWorld:PushEvent("nightmarephasechanged","{id}")', "Ancient state: {chs}", meta)
        }
    end))
end


function LS:server_speed()
    local opts = t_util:IPairToIPair({0.5, 1, 2, 4}, function(speed)
        local meta = {speed = speed}
        return {
            meta = meta,
            text = speed == 1 and "Default" or "{speed}x",
            hover = speed == 1 and "Restore default world speed!" or "Set world speed to {speed}x!",
            left = function()
                if speed == 1 then
                    f_util:ExRemote('TheSim:SetTimeScale({speed})', "World speed: default", meta)
                else
                    f_util:ConfirmRemote("Speed up world", "Confirm set world speed to {speed}x?", 'TheSim:SetTimeScale({speed})', "World speed set to {speed}x", meta)
                end
            end
        }
    end)
    table.insert(opts, {
        text = "Custom",
        hover = "Custom world speed!",
        left = function()
            h_util:CreateWriteWithClose("Enter world speed:", {
                text = "Confirm",
                cb = function(str)
                    local speed = tonumber(str)
                    if speed and speed > 0 then
                        f_util:ExRemote('TheSim:SetTimeScale({speed})', "Custom world speed: {speed}x", {speed = speed})
                    else
                        h_util:CreatePopupWithClose("Invalid", "Please enter a positive number.")
                    end
                end
            })
        end
    })
    return self:LineTextBtn("World speed", opts)
end

function LS:server_rollback()
    local opts = t_util:BuildNumInsert(1, 6, function(num)
        local meta = {num = num}
        return {
            meta = meta,
            text = "[{num}]",
            hover = "Rollback {num} snapshots",
            left = f_util:FuncConfirmRemote("Rollback", "Are you sure you want to rollback {num} snapshots?", 'c_rollback({num})', "Rolling back {num} snapshots...", meta)
        }
    end)
    table.insert(opts, {
        text = "Custom",
        hover = "Custom rollback count",
        left = function()
            h_util:CreateWriteWithClose("Enter rollback count:", {
                text = "Confirm",
                cb = function(str)
                    local num = tonumber(str)
                    if num and num >= 0 and num % 1 == 0 then
                        f_util:ExRemote('c_rollback({num})', "Custom rollback {num} snapshots...", {num = num})
                    else
                        h_util:CreatePopupWithClose("Invalid", "Please enter zero or a positive integer.")
                    end
                end
            })
        end
    })
    return self:LineTextBtn("Rollback", opts)
end

function LS:server_common()
    return self:LineTextBtn("Server", {
        {
            text = "Reload game",
            hover = lmb.."Reload world!"..rmb.."Save and reload game!",
            left = f_util:FuncConfirmRemote("Reload game", "Are you sure you want to reload the game? All unsaved progress will be lost.", 'c_reset()', "Reloading game..."),
            right = f_util:FuncConfirmRemote("Save and reload", "Confirm save and reload game?", "c_save() if TheWorld then TheWorld:DoTaskInTime(5, function() c_reset() end) end", "Saving game... Reloading in 5 seconds...")
        },{
            text = "Regenerate world",
            hover = "Destroy the save and generate a new world!",
            left = f_util:FuncConfirmRemote("Regenerate world", "Are you sure you want to generate a new world? The current world's save data will be destroyed!", 'c_regenerateworld()', "Regenerating world...")
        },{
            text = "Save game",
            hover = "Save game progress!",
            left = f_util:FuncExRemote("c_save()", "Saving game...")
        }
    })
end

function LS:server_advance()
    local opts = {{
        text = "Event modify",
        hover = "Modify the server event",
        left = function()
            local events = t_util:MergeList({{"default", "Auto"}, {"none", "None"}}, t_util:PairToIPair(SPECIAL_EVENTS or {}, function(upper, key)
                local name = type(key)=="string" and t_util:GetRecur(STRINGS, "UI.CUSTOMIZATIONSCREEN."..key:upper())
                return name and {key, name}
            end))
            m_util:AddBindShowScreen({
                title = "Server event modify",
                id = "server_event_modify",
                data = t_util:IPairToIPair(events, function(data)
                    return {
                        id = data[1],
                        label = data[2],
                        hover = "Modify the server event to "..data[2],
                        type = "box",
                        fn = f_util:FuncConfirmRemote("Server event modify", "Confirm change server event to {chs}?", 'ApplySpecialEvent("{event}")TheWorld.topology.overrides.specialevent="{event}" c_save() if TheWorld then TheWorld:DoTaskInTime(5, function() c_reset() end) end', "Server event changed to {chs}, reloading world in five seconds...", {event = data[1], chs = data[2]}, function()
                                m_util:PopShowScreen()
                            end)
                    }
                end)
            })()
        end
    }}
    if TheWorld then
        if TheWorld:HasTag("cave") then
            table.insert(opts, 1, {
                text = "Reset ruins",
                hover = "Refresh all ancient creatures immediately",
                left = f_util:FuncConfirmRemote("Reset ruins", "Are you sure you want to reset the ruins? Shadows awaken... spirits revive...", 'TheWorld:PushEvent("resetruins")')
            })
        else
            table.insert(opts, 1, {
                text = "Remove roads",
                hover = "Remove native roads such as cobblestone paths\nfor cleaner base building",
                left  = f_util:FuncConfirmRemote("Warning · Remove roads", "Confirm remove roads? This action cannot be undone!", 'Roads={}c_save()if TheWorld then TheWorld:DoTaskInTime(5, function() c_reset() end) end')
            })
        end
    end
    return self:LineTextBtn("Advanced", opts)
end


function LS:player_telepos()
    local opts = t_util:BuildNumInsert(1, 6, function(num)
        local meta = {num = num}
        return {
            meta = meta,
            text = '[{num}]',
            hover = lmb.."Teleport to slot [{num}]"..rmb.."Save player position to slot [{num}]",
            left = function()
                local saver = m_util:GetSaver()
                if not saver then return end
                local pos_line = saver:GetLine("sw_T_mine", true)
                local pos = pos_line[num]
                if not pos then return end
                local x, y, z = tonumber(pos.x), tonumber(pos.y), tonumber(pos.z)
                if x and y and z then
                    f_util:ExRemote("if not _U_.Transform then return end _U_.Transform:SetPosition({x}, {y}, {z})", "Teleport to saved world slot [{num}] at ({x}, {y}, {z})", {num = num, x = x, y = y, z = z})
                end
            end,
            right = function()
                local saver = m_util:GetSaver()
                if not saver then return end
                local pos_line = saver:GetLine("sw_T_mine", true)
                if ThePlayer then
                    local pos_player = ThePlayer:GetPosition()
                    local x,y,z = string.format("%.2f", pos_player.x), string.format("%.2f", pos_player.y), string.format("%.2f", pos_player.z)
                    pos_line[num] = {x = x, y = y, z = z}
                    saver:Save()
                    f_util:ExRemote("", "Recorded current world slot [{num}] position: ({x}, {y}, {z})", {x = x, y = y, z = z, num = num})
                end
            end
        }
    end)
    table.insert(opts, {
        text = "Map center",
        hover = lmb.."Teleport to map (0, 0, 0)"..rmb.."Custom coordinates",
        left = f_util:FuncExRemote("if not _U_.Transform then return end _U_.Transform:SetPosition(0, 0, 0)", "Teleport to map center"),
        right = function()
            h_util:CreateWriteWithClose("Enter x,y,z coordinates separated by commas:", {
                text = "Confirm",
                cb = function(str)
                    local cleaned = str:gsub("%s+", "")
                    local ns = {}
                    for n in cleaned:gmatch("([^,，、;；]+)") do
                        table.insert(ns, tonumber(n))
                    end
                    local l = #ns
                    if l>1 then
                        f_util:ExRemote("_U_.Transform:SetPosition({x},{y},{z})", "Teleport to ({x},{y},{z})", {x = ns[1], y = l==2 and 0 or ns[2], z = l==2 and ns[2]or ns[3]})
                    else
                        h_util:CreatePopupWithClose("Invalid", "Enter at least two numbers, separated by commas.")
                    end
                end
            })
        end
    })
    return self:LineTextBtn("Position", opts)
end

function LS:player_speed()
    local code_speed = 'local h=_U_.components.locomotor if h then h:SetExternalSpeedMultiplier(_U_,"c_speedmult",{speed})end'
    local opts = t_util:IPairToIPair({0.5, 1, 2, 4, 6}, function(speed)
        local meta = {speed = speed}
        return {
            meta = meta,
            text = speed == 1 and "Normal" or "{speed}x",
            hover = speed == 1 and "Restore default player speed" or "Set player speed to {speed}x normal",
            left = f_util:FuncExRemote(code_speed, speed == 1 and "Restore default speed" or "Player speed: {speed}x", meta)
        }
    end)
    table.insert(opts, {
        text = "Custom",
        hover = "Custom player speed!",
        left = function()
            h_util:CreateWriteWithClose("Enter player speed multiplier:", {
                text = "Confirm",
                cb = function(str)
                    local speed = tonumber(str)
                    if speed then
                        f_util:ExRemote(code_speed, "Custom player speed: {speed}x", {speed = speed})
                    else
                        h_util:CreatePopupWithClose("Invalid", "Please enter a number.")
                    end
                end
            })
        end
    })

    return self:LineTextBtn("Move speed", opts)
    local opts = t_util:IPairToIPair({.5, 1, 2, 4}, function(speed)
        local meta = {speed = speed}
        return {
            meta = meta,
            text = speed == 1 and "Normal" or "{speed}x",
            hover = speed == 1 and "Restore default hunger rate" or "Set player hunger rate to {speed}x normal",
            left = f_util:FuncExRemote(code_speed, speed == 1 and "Restore default hunger rate" or "Player hunger rate: {speed}x", meta),
        }
    end)
    table.insert(opts, {
        text = "Custom",
        hover = "Custom player hunger rate!",
        left = function()
            h_util:CreateWriteWithClose("Enter player hunger rate:", {
                text = "Confirm",
                cb = function(str)
                    local speed = tonumber(str)
                    if speed then
                        f_util:ExRemote(code_speed, "Custom player hunger rate: {speed}x", {speed = speed})
                    else
                        h_util:CreatePopupWithClose("Invalid", "Please enter a number.")
                    end
                end
            })
        end
    })

    return self:LineTextBtn("Hunger rate", opts)
end

function LS:player_all()
    return self:LineTextBtn("All players", {
        {
            text = "Gather",
            hover = "Gather all players!",
            left = f_util:FuncConfirmRemote("Notice", "Are you sure you want to gather all players here? This may be impolite!", 'local p=_U_:GetPosition()for _,v in pairs(AllPlayers)do v.Transform:SetPosition(p.x, p.y, p.z)end', "Gather all players!")
        },
        {
            text = "Kill",
            hover = "Kill all players!",
            left = f_util:FuncConfirmRemote("Notice", "Are you sure you want to turn all players into ghosts? This may be impolite!", 'for _,v in pairs(AllPlayers)do if not v:HasTag("playerghost")then v:PushEvent("death") v.deathpkname="[Remote Panel]"end end', "All players killed")
        },
        {
            text = "Revive",
            hover = "Revive all dead players!",
            left = f_util:FuncExRemote('for _,v in pairs(AllPlayers)do if v:HasTag("playerghost")then v:PushEvent("respawnfromghost")v.rezsource="[Remote Panel]"end end', "Revive all players")
        },
        {
            text = "Restore",
            hover = "Restore all player stats!",
            left = f_util:FuncExRemote(f_util:CodeFull()..'for _,v in pairs(AllPlayers)do Full(v)end', "Restore all players"),
        },
    })
end

function LS:player_single()
    return self:LineTextBtn("Single player", {
        {
            text = "Restore",
            hover = "Restore player status!",
            left = f_util:FuncExRemote(f_util:CodeFull()..'Full(_U_)', "Restore player status")
        },
        {
            text = "Map",
            hover = lmb.."Show full map"..rmb.."Temporarily clear map data",
            left = f_util:FuncConfirmRemote("Prompt", "Are you sure you want to unlock the map?\nThis may take some time, and the data will be permanently revealed!", 'local m = _U_.player_classified and _U_.player_classified.MapExplorer if not m then return end local size=TheWorld.Map:GetSize()*4.1 for x=-size,size,35 do for y=-size,size,35 do m:RevealArea(x, 0, y) end end', "Show full map"),
            right = function()
                if t_util:GetRecur(TheWorld, "minimap.MiniMap") then
                    TheWorld.minimap.MiniMap:ClearRevealedAreas()
                    f_util:ExRemote("", "Temporary map hide")
                end 
            end
        },{
            text = "Cursed monkey",
            hover = lmb.."Transform into cursed monkey!"..rmb.."Transform back to human!",
            left = function()
                local info = f_util:GetUserInfo()
                local code_wonkey = 'if _U_.prefab=="wonkey"then return end '..f_util:CodePrefab({cursed_monkey_token=10})
                local tip_wonkey = '{name} transformed into a cursed monkey!'
                if table.contains(DST_CHARACTERLIST, info and info.prefab) then
                    f_util:ExRemote(code_wonkey, tip_wonkey)
                else
                    f_util:ConfirmRemote("Warning", "Are you sure you want to transform into a cursed monkey? Some mod characters may crash!", code_wonkey, tip_wonkey)
                end
            end,
            right = f_util:FuncExRemote('local c=_U_.components.cursable if c then c:RemoveCurse("MONKEY",999)end', '{name} broke the cursed monkey spell.')
        },{
            text = "Migrate",
            hover = "Cross-world teleport!",
            left = f_util:FuncExRemote('TheWorld:PushEvent("ms_playerdespawnandmigrate",{player=_U_,worldid=next(Shard_GetConnectedShards())})', "{name} has been teleported across worlds")
        },{
            text = "Reselect",
            hover = lmb.."Reselect character (keep tech)"..rmb.."Reselect character (no tech)",
            left = f_util.DespawnSave,
            right = f_util.DespawnDrop,
        }
    })
end

function LS:player_unlock()
    return self:LineTextBtn("Skill tree", {
        {
            text = "Gain insight points",
            hover = "Max out insight points!",
            left = f_util:FuncExRemote('local com_s=_U_.components.skilltreeupdater if not com_s then return end com_s:AddSkillXP(TheSkillTree:GetMaximumExperiencePoints())', "Gain insight points")
        },
        {
            text = "Reset skill tree",
            hover = "Reset spent skill points\nMay require pressing multiple times",
            left = f_util:FuncExRemote('local com_s=_U_.components.skilltreeupdater if not com_s then return end local sf=require("prefabs/skilltree_defs").SKILLTREE_DEFS[_U_.prefab]for s in pairs(sf or{})do com_s:DeactivateSkill(s)end', "Reset skill tree")
        },{
            text = "Popup fix",
            hover = "If a character without a skill tree gained insight points, click here to fix it!",
            left = function()
                if not (ThePlayer and TheSkillTree) then return end
                local p = ThePlayer.prefab
                h_util:CreatePopupWithClose("Warning", "Are you sure you want to repair the skill tree popup for "..e_util:GetPrefabName(p).."?\nThis will clear insight points, so only use it for characters without a skill tree!", {{text = h_util.yes, cb = function()
                    TheSkillTree.skillxp[p]=0 
                    TheSkillTree:UpdateSaveState(p)
                    ThePlayer.new_skill_available_popup = nil
                    local t = t_util:GetRecur(ThePlayer, "HUD.controls.skilltree_notification")
                    if t then
                     t:UpdateElements()
                    end
                end}, {text = h_util.no}})
            end
        }
    })
end



function LS:ent_near()
    return self:LineTextBtn("Nearby", {
        {
            text = "Delete",
            hover = lmb.."Delete nearby entities!"..rmb.."Clean full-screen entities!",
            left = f_util:FuncExRemote(code_range_delete, "Delete within radius {range_delete}", {range_delete = save_data.range_delete or 3}),
            right = f_util:FuncConfirmRemote("Warning", "Are you sure you want to clear all entities in the loaded area? This is dangerous!", code_range_delete, "Clear full screen!", {range_delete = 64})
        },{
            text = "Kill",
            hover = lmb.."Kill nearby creatures!"..rmb.."Kill nearby players!",
            left = f_util:FuncExRemote('local pos=_U_:GetPosition() for _,v in ipairs(TheSim:FindEntities(pos.x,pos.y,pos.z,{range},{"_combat","_health"},{"player","inlimbo","wall","structure"}))do if v.components and v.components.health then v.components.health:Kill() end end', "Kill creatures within {range} radius", {range = save_data.range_kill or 20}),
            right = f_util:FuncExRemote('local pos=_U_:GetPosition() for _,v in ipairs(TheSim:FindEntities(pos.x,pos.y,pos.z,{range},{"player"}))do if v~=_U_ and v.components.health then v.components.health:Kill()end end', "Kill players within {range} radius", {range = save_data.range_kill or 20})
        },{
            text = "Extinguish",
            hover = "Extinguish nearby flames!",
            left = f_util:FuncExRemote('local pos=_U_:GetPosition()for _,o in ipairs(TheSim:FindEntities(pos.x,pos.y,pos.z,64))do local b = o.components and o.components.burnable if b then b:Extinguish(true, -1)end end', "Extinguish all nearby flames")
        },{
            text = "Repair",
            hover = "Repair nearby burnt structures",
            left = f_util:FuncExRemote('local p=_U_:GetPosition()for _,o in ipairs(TheSim:FindEntities(p.x,p.y,p.z,64,{"burnt", "structure"}, {"INLIMBO"}))do local op=o:GetPosition()o:Remove() local n=SpawnPrefab(tostring(o.prefab),tostring(o.skinname),nil,_P_.userid)if n then n.Transform:SetPosition(op:Get())end end', "Repair nearby burnt structures")
        },{
            text = "Freeze",
            hover = lmb.."Freeze nearby entities for 60 sec!"..rmb.."Freeze nearby players for 60 sec!",
            left = f_util:FuncExRemote('local p=_U_:GetPosition() for _,v in ipairs(TheSim:FindEntities(p.x,p.y,p.z,64,nil,{"player"}))do local f=v.components and v.components.freezable if f then f:AddColdness(100,60)end end', "Freeze nearby entities"),
            right = f_util:FuncExRemote('local p=_U_:GetPosition() for _,v in ipairs(TheSim:FindEntities(p.x,p.y,p.z,64,{"player"}))do local f=v~=_U_ and v.components and v.components.freezable if f then f:AddColdness(100,60)end end', "Freeze nearby players"),
        },{
            text = "Hypnosis",
            hover = lmb.."Hypnotize nearby entities for 60 sec!"..rmb.."Hypnotize nearby players for 60 sec!",
            left = f_util:FuncExRemote('local p=_U_:GetPosition() for _,v in ipairs(TheSim:FindEntities(p.x,p.y,p.z,64,{"sleeper"},{"player","playerghost", "FX", "DECOR", "INLIMBO"}))do local c=v.components if c then local i, m if c.rider then i = c.rider:IsRiding() m = c.rider:GetMount() end if m then m:PushEvent("ridersleep", { sleepiness = 10, sleeptime = 60 }) end if c.sleeper then c.sleeper:AddSleepiness(10, 60) elseif c.grogginess then c.grogginess:AddGrogginess(10, 60) else v:PushEvent("knockedout") end local fx = SpawnPrefab(i and "fx_book_sleep_mount" or "fx_book_sleep") fx.Transform:SetPosition(v.Transform:GetWorldPosition())fx.Transform:SetRotation(v.Transform:GetRotation())end end', "Hypnotize nearby entities"),
            right = f_util:FuncExRemote('local p=_U_:GetPosition() for _,v in ipairs(TheSim:FindEntities(p.x,p.y,p.z,64,{"player"},{"playerghost", "FX", "DECOR", "INLIMBO"}))do local c=v~=_U_ and v.components if c then local i, m if c.rider then i = c.rider:IsRiding() m = c.rider:GetMount() end if m then m:PushEvent("ridersleep", { sleepiness = 10, sleeptime = 60 }) end if c.sleeper then c.sleeper:AddSleepiness(10, 60) elseif c.grogginess then c.grogginess:AddGrogginess(10, 60) else v:PushEvent("knockedout") end local fx = SpawnPrefab(i and "fx_book_sleep_mount" or "fx_book_sleep") fx.Transform:SetPosition(v.Transform:GetWorldPosition()) fx.Transform:SetRotation(v.Transform:GetRotation()) end end', "Hypnotize nearby players"),
        }
    })
end

function LS:ent_plant()
    return self:LineTextBtn("Planting", {
        {
            text = "Fertilize",
            hover = "Fertilize nearby withered plants\nFarmland will also refill nutrients and moisture!",
            left = f_util:FuncExRemote('local pt=_U_:GetPosition() for _,o in ipairs(TheSim:FindEntities(pt.x,pt.y,pt.z,64,nil,{"inlimbo","player"}))do if o.UpdateOverlay then local wx,wy,wz=o.Transform:GetWorldPosition()local tx,ty=TheWorld.Map:GetTileCoordsAtPoint(wx,wy,wz) TheWorld.components.farming_manager:SetTileNutrients(tx, ty, 100, 100, 100)TheWorld.components.farming_manager:AddSoilMoistureAtPoint(wx, wy, wz, TUNING.SOIL_MAX_MOISTURE_VALUE)end local p=o.components and o.components.pickable if p and p:CanBeFertilized() then local f=SpawnPrefab("compostwrap") p:Fertilize(f) if f then f:Remove() end end end', "Fertilize nearby soil and crops"),
        },{
            text = "Mature",
            hover = "Force nearby plants to mature, farmland crops may become huge!",
            left = function()
                local code_str = 'local function Grow(o) local c=o.components if c then if c.witherable and c.witherable:IsWithered() then return end '..
                'local g=c.growable if g then if o:HasTag("farm_plant") and g.stages then o.is_oversized = true return g:SetStage(#g.stages-1) '..
                'elseif g.magicgrowable or((o:HasTag("tree") or o:HasTag("winter_tree")) and not o:HasTag("stump"))then if c.simplemagicgrower then return c.simplemagicgrower:StartGrowing() elseif c.domagicgrowthfn then return g:DoMagicGrowth() else return g:DoGrowth() end end end '..
                'if c.pickable then print(o)if c.pickable:CanBePicked()and c.pickable.caninteractwith then return end if c.pickable:FinishGrowing() then return c.pickable:ConsumeCycles(1) end end '..
                'if c.crop and (c.crop.rate or 0)>0 then return c.crop:DoGrow(1/c.crop.rate,true) end if c.harvestable and c.harvestable:CanBeHarvested() and o:HasTag("mushroom_farm")then if c.harvestable:IsMagicGrowable()then return c.harvestable:DoMagicGrowth() else return c.harvestable:Grow() end end end end '..
                'local pt=_U_:GetPosition() for _,o in ipairs(TheSim:FindEntities(pt.x,pt.y,pt.z,64,nil,{"inlimbo","player"}))do Grow(o)end'
                f_util:ExRemote(code_str, "Mature nearby plants")
            end
        },{
            text = "Harvest",
            hover = "Harvest all nearby crops!",
            left = f_util:FuncExRemote('local p=_U_ if p:HasTag("playerghost")then return end local pt=p:GetPosition()for _,o in ipairs(TheSim:FindEntities(pt.x,pt.y,pt.z,64,nil,{"player","flower","trap","mine","NOCLICK","DECOR","FX","cage","donotautopick","INLIMBO"}))do local c=o.components if c then for _,f in ipairs({"pickable","crop","harvestable","stewer","dryer"})do if c[f] then if c[f].Harvest then c[f]:Harvest(p)elseif c[f].Pick then c[f]:Pick(p)end end end end end', "Harvest nearby crops")
        },{
            text = "Pick up",
            hover = "Pick up nearby ground items!",
            left = f_util:FuncExRemote('local i=_U_.components.inventory if _U_:HasTag("playerghost")or not i then return end local pt=_U_:GetPosition() for _,v in ipairs(TheSim:FindEntities(pt.x,pt.y,pt.z,64,{"_inventoryitem"},{"player","flower","NOCLICK","DECOR","FX","donotautopick","INLIMBO"}))do i:GiveItem(v)end', "Pick up nearby items")
        }
    })
end

function LS:ent_beef()
    local datas = {
        {
            chs = "Default",
            tendency = "DEFAULT",
        },{
            chs = "Rider",
            tendency = "RIDER",
        },{
            chs = "Ornery",
            tendency = "ORNERY",
        },{
            chs = "Pudgy",
            tendency = "PUDGY",
        }
    }
    local opts = t_util:IPairToIPair(datas, function(data)
        local meta = {saddle = f_util:fnSmark("saddle_shadow"), tendency = f_util:fnSmark(data.tendency), chs=data.chs}
        return {
            meta = meta,
            text = "{chs}",
            hover = lmb.."Spawn a {chs} tame beefalo"..rmb.."No saddle equipped",
            left = f_util:FuncExRemote('local b=SpawnPrefab("beefalo") if not b then return end local pt=_U_:GetPosition() local c=b.components local d=c.domesticatable d:DeltaTendency({tendency}, 1) d:DeltaObedience(1) d:DeltaDomestication(1) d:BecomeDomesticated() b:SetTendency() c.hunger:SetPercent(.5) c.rideable:SetSaddle(nil, SpawnPrefab({saddle})) b.Transform:SetPosition(pt.x,pt.y,pt.z) local bb=SpawnPrefab("shadow_beef_bell") if _U_.components.inventory and b then _U_.components.inventory:GiveItem(bb) bb.components.useabletargeteditem:StartUsingItem(b,_U_)end', "Spawn {chs} tame beefalo", meta),
            right = f_util:FuncExRemote('local b=SpawnPrefab("beefalo") if not b then return end local pt=_U_:GetPosition() local c=b.components local d=c.domesticatable d:DeltaTendency({tendency}, 1) d:DeltaObedience(1) d:DeltaDomestication(1) d:BecomeDomesticated() b:SetTendency() c.hunger:SetPercent(.5) b.Transform:SetPosition(pt.x,pt.y,pt.z)', "Spawn {chs} tame beefalo (no saddle)", meta)
        }
    end)
    return self:LineTextBtn(e_util:GetPrefabName("beefalo"), opts)
end

function LS:ent_all()
    return self:LineTextBtn("Entities", {
        {
            text = "Clear hate",
            hover = "Clear hate from nearby entities!",
            left = f_util:FuncExRemote(f_util:CodeEnts('local c=o.components if c then if c.combat then c.combat:SetTarget(nil)end end'), "Clear nearby hate")
        },{
            text = "Restore state",
            hover = "Restore health and hunger for nearby entities! (non-player)",
            left = f_util:FuncExRemote(f_util:CodeEnts('local h=o.components and o.components.health if h then h:SetPercent(1)end local u=o.components and o.components.hunger if u then u:SetPercent(1)end'), "Restore nearby creatures")
        },{
            text = "Control movement",
            hover = lmb.."Disable movement for nearby entities!"..rmb.."Allow movement for nearby entities!",
            left = f_util:FuncExRemote(f_util:CodeEnts('local l=o.components and o.components.locomotor if not l then return end l:SetExternalSpeedMultiplier(o,"c_speedmult",{speed})'), "Disable nearby entity movement",{speed = 0}),
            right = f_util:FuncExRemote(f_util:CodeEnts('local l=o.components and o.components.locomotor if not l then return end l:SetExternalSpeedMultiplier(o,"c_speedmult",{speed})'), "Allow nearby entity movement",{speed = 1}),
        }
    })
end

function LS:ent_spawn()
    return self:LineTextBtn("Spawn", {
        {
            text = "Attack speed dummy",
            hover = "Spawn an attack speed test dummy!\n(Expires after restarting the game)",
            left = f_util:FuncExRemote('local r = SpawnPrefab("sewing_mannequin") r.Transform:SetPosition(_U_:GetPosition():Get()) r:AddComponent("health") r.components.health:SetMaxHealth(TUNING.TOADSTOOL_DARK_HEALTH) r:AddComponent("combat") r._lasttime = 0 r._sumtime = 0 r._sumamout = 0 r:ListenForEvent("healthdelta", function(r, d) local function round(num) return tostring(math.floor(num * 1000 + 0.5) / 1000) end local am = -d.amount local str = "Single hit damage: " .. round(am) local now = GetTime() local pt = now - r._lasttime str = str .. string.char(10) .. "Attack interval: " .. round(pt) str = str .. string.char(10) .. "Real-time attack speed: " .. round(1 / pt) if pt > 3 or r._sumtime == 0 then r._sumtime = now r._sumamout = am str = str .. string.char(10) .. "Start timing (cooldown 3s)" else r._sumamout = r._sumamout + am str = str .. string.char(10) .. "DPS: " .. round((r._sumamout - am) / (now - r._sumtime)) end r.components.talker:Say(str) r._lasttime = now end)', "Spawn attack speed dummy")
        },{
            text = "Link wormhole",
            hover = "Spawn a wormhole and automatically link it to an unlinked one!",
            left = f_util:FuncExRemote('local x, y, z = _U_.Transform:GetWorldPosition() local ents = TheSim:FindEntities(x, y, z, 9001) local old_worm for _, v in pairs(ents) do if v.prefab == "wormhole" then if v.components and v.components.teleporter and v.components.teleporter.targetTeleporter == nil then old_worm = v end end end local new_worm = SpawnPrefab("wormhole") new_worm.Transform:SetPosition(x, y, z) if old_worm then old_worm.components.teleporter.targetTeleporter = new_worm new_worm.components.teleporter.targetTeleporter = old_worm end', "Spawn linked wormhole")
        }
    })
end


function LS:test_boss()
    local data_list = {
        {
            text = "Nightmare Pig",
            hover = "Spawn a Nightmare Pig\n(with chains)",
            left = f_util:FuncExRemote('require("debugcommands")d_daywalker(true)', "Spawn Nightmare Pig (with chains)")
        },{
            text = "Astral Hero",
            hover = "Spawn items needed for Astral Hero summon",
            left = f_util:FuncExRemote([[
	local offset = 7
	local pos = ConsoleWorldPosition()
	local altar 
    
    altar = SpawnPrefab("moon_altar")
	altar.Transform:SetPosition(pos.x, 0, pos.z - offset)
	altar:set_stage_fn(2)
    
	SpawnPrefab("moon_altar_idol").Transform:SetPosition(pos.x, 0, pos.z - offset - 2)

	altar = SpawnPrefab("moon_altar_astral")
	altar.Transform:SetPosition(pos.x - offset, 0, pos.z + offset / 3)
	altar:set_stage_fn(2)

	altar = SpawnPrefab("moon_altar_cosmic")
	altar.Transform:SetPosition(pos.x + offset, 0, pos.z + offset / 3)

    c_give("wagpunk_bits", 4)
    c_give("moonstorm_spark", 10)
    c_give("moonglass_charged", 30)
    c_give("moonstorm_static_item", 1)
    c_give("moonrockseed", 1)
    ]], "Spawn items for Astral Hero summon")
        }
    }
    if TheWorld and TheWorld:HasTag("forest") then
        t_util:Add(data_list, {
            text = "Forage refresh",
            hover = "Refresh the Forage Pig immediately\n(Forest only)",
            left = f_util:FuncExRemote([[
    local fws = TheWorld and TheWorld.components.forestdaywalkerspawner
    local sds = TheWorld and TheWorld.shard and TheWorld.shard.components.shard_daywalkerspawner
    if fws and sds then
        sds:SetLocation("forestjunkpile")
        fws.days_to_spawn = 0
    end
    ]], "Refresh Forage Pig immediately")
        }, true)
    end
    return self:LineTextBtn("Beasts", data_list)
end

function LS:test_show()
    return self:PackLines(self:LineTextBtn("Hint", {{
        text = "This page is for developer debugging",
        hover = "Authorization not yet granted",
    }}))
end

function LS:test_treerock()
    return self:LineTextBtn("Rock trees", {
        {
            text = "Array 1",
            hover = "Generate rock tree array 1",
            left = function()
                if not ThePlayer then return end
                local cx, _, cz = TheWorld.Map:GetTileCenterPoint(ThePlayer.Transform:GetWorldPosition())
                if cx then
                    f_util:ExRemote('local r={count}*4 for x={cx}-r,{cx}+r,4 do for z={cz}-r,{cz}+r,4 do SpawnPrefab("tree_rock1").Transform:SetPosition(x, 0, z) end end', "Generate rock tree array 1", {cx = cx, cz = cz, count = 3})
                end
            end
        },
        {
            text = "Array 2",
            hover = "Generate rock tree array 2",
            left = function()
                if not ThePlayer then return end
                local cx, _, cz = TheWorld.Map:GetTileCenterPoint(ThePlayer.Transform:GetWorldPosition())
                if cx then
                    f_util:ExRemote('local r={count}*4 for x={cx}-r,{cx}+r,4 do for z={cz}-r,{cz}+r,4 do SpawnPrefab("tree_rock").Transform:SetPosition(x, 0, z) end end', "Generate rock tree array 2", {cx = cx, cz = cz, count = 3})
                end
            end
        },
    })
end

function LS:test_beebox()
    return self:LineTextBtn("Panel 1", {
        {
            text = "Bee boxes",
            hover = "Generate a bee box array",
            left = function()
                f_util:ExRemote('local function G(p, r, c) local ps = {} local angleStep = 2 * math.pi / c for i = 0, c - 1 do local angle = i * angleStep table.insert(ps, Vector3(p.x + r * math.cos(angle), 0, p.z + r * math.sin(angle))) end return ps end local pt=_P_:GetPosition() for _,p in ipairs(G(pt, {range}, {count}))do local b=SpawnPrefab("beebox") b.Transform:SetPosition(p.x, 0, p.z) b.components.harvestable.produce=5 b.components.harvestable:Grow() end f=SpawnPrefab("firesuppressor")f.Transform:SetPosition(pt.x, 0, pt.z)', "Generate bee box array", {range = 10, count = 15})
            end
        },
        {
            text = "Ponds",
            hover = "Generate pond array",
            left = function()
                f_util:ExRemote('local function G(p, r, c) local ps = {} local angleStep = 2 * math.pi / c for i = 0, c - 1 do local angle = i * angleStep table.insert(ps, Vector3(p.x + r * math.cos(angle), 0, p.z + r * math.sin(angle))) end return ps end local pt=_P_:GetPosition() for _,p in ipairs(G(pt, {range}, {count}))do local b=SpawnPrefab("pond_cave") b.Transform:SetPosition(p.x, 0, p.z) end', "Generate pond array", {range = 15, count = 10})
            end
        },
    })
end

return LS