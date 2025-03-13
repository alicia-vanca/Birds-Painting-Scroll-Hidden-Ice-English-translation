local save_id, stat_name, boss_str = "huxi_boss", "bossdata", "Boss timing"
local default_data = {
    sw = true,
    way = "ann",
    color = "Red",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

-- Anyway, a countdown corresponds to a icon, simply icon+description is directly constructed.
local DataBoss = {
    shadowrift_portal = "Despair",
    lunarrift_portal = "Brilliant crack",
}
local color_red,color_white = h_util:GetRGB("Red"), h_util:GetRGB("White")
i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    saver:RegStat(stat_name, boss_str, "Boss countdown advanced settings", function()return save_data.sw end, fn_save("sw"), {
        periodic = function(data, id, worldtime)
            local time = data.value - worldtime
            if time > 0 then
                return {
                    text = {
                        color = time < 60 and color_red or color_white,
                        text = saver:FormatSecond(time)
                    }
                }
            else
                local str_say = string.format(" %s has respawned", data.describe)
                local way = save_data.way
                if way~="null" then
                    i_util:DoTaskInTime(1, function()
                        if way == "ann" then
                            u_util:Say(STRINGS.LMB.." "..str_say, nil, "net", nil, true)
                        elseif way == "self" then
                            u_util:Say(boss_str, str_say, "self", save_data.color, true)
                        elseif way == "head" then
                            u_util:Say(str_say, nil,  "head", save_data.color, true)
                        else
                            u_util:Say(boss_str, str_say, nil, save_data.color, true)
                        end
                    end)
                end
            end
        end,
        fn_left = function(data)
            local time_str = c_util:FormatSecond_dos(data.value - saver:GetWorldTime())
            local str_say = string.format("%s will respawn after %s", data.describe, time_str)
            u_util:Say(STRINGS.LMB..str_say.."。", nil, "net", nil, true)
        end,
        addstat = function(data, icon)
            -- Image, value (value is world time)
            local name = DataBoss[icon] or e_util:GetPrefabName(icon)
            if data.value and name then
                local xml, tex = h_util:GetPrefabAsset(icon)
                if xml then
                    data.xml = xml
                    data.tex = tex
                    data.describe = name
                    data.text = data.text or c_util:FormatSecond_dms(data.value-saver:GetWorldTime())
                    return true
                end
            end
        end,
        sort = function(a, b)
            return a.value < b.value
        end,
    }, {
        screen_data = {
            {
                id = "way",
                label = "Warning prompt:",
                hover = "The location of the prompt when the monster attacks",
                default = fn_get,
                fn = fn_save("way"),
                type = "radio",
                data = {
                    {data = "idea", description = "Follow system"},
                    {data = "ann", description = "Announce"},
                    {data = "head", description = "Player's head"},
                    {data = "self", description = "My chat"},
                    {data = "null", description = "Off"},
                }
            },
            {
                id = "color",
                label = "Warning color:",
                hover = "The color of the prompt when the monster attacks",
                default = fn_get,
                fn = fn_save("color"),
                type = "radio",
                data = (require("data/valuetable")).RGB_datatable,
            },
        }
    })

    -- Entrusted boss data
    local save_boss = saver:GetLine(stat_name) -- Save the remaining time
    local time_inagame = saver:GetWorldTime()
    t_util:Pairs(save_boss, function(icon_name, save_time)
        local time = save_time - time_inagame
        if time > 0 then
            saver:AddStat(stat_name, icon_name, {
                value = save_time,
                text = c_util:FormatSecond_dms(time-time_inagame)
            })
        end
    end)

    -- Synchronize boss data when leaving the game
    saver:RegSaveFunc(function()
        t_util:Pairs(save_boss, function(key)
            save_boss[key] = nil
        end)
        local data = saver:GetStatData(stat_name) or {}
        t_util:Pairs(data, function(icon_name, boss_data)
            save_boss[icon_name] = math.floor(boss_data.value) -- Save only icons and corresponding time
        end)
    end)
end)


local function AddBoss(icon, cd)
    local saver = m_util:GetSaver()
    if saver and cd then
        saver:AddStat(stat_name, icon, {
            value = saver:GetWorldTime() + cd,
        })
        saver:SetTimerConfig()
    end
end

local function RemoveBoss(icon)
    local saver = m_util:GetSaver()
    if saver then
        saver:RemoveStat(stat_name, icon)
    end
end

local function InitPrefab(prefab, func)
    AddPrefabPostInit(prefab, function(boss)
        RemoveBoss(prefab)
        boss:DoTaskInTime(0.2, function(inst)
            func(inst)
        end)
    end)
end

local function InitAndRemove(prefab, icon)
    AddPrefabPostInit(prefab, function()
        RemoveBoss(icon or prefab)
    end)
end

--------------- the above is the pavement, the following is the business logic --------------
-- Stubborn bag: it is a winter feast and a gift coming out
InitPrefab("klaus_sack", function(inst)
    inst:ListenForEvent("onremove", function(inst)
        if e_util:FindEnt(inst, nil, 4, "bundle") then
            if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                AddBoss("klaus_sack", TUNING.KLAUSSACK_EVENT_RESPAWN_TIME)
            elseif TheWorld and TheWorld.state and TheWorld.state.iswinter then
                -- Tuning.klaussack_respawn_delay + 1 ~ 3 days
            end
        end
    end)
end)
-- Crispy shark: shouting surrender
InitPrefab("sharkboi", function(inst)
    e_util:Hook_Say(inst, function(str_say)
        if t_util:GetElement(STRINGS.SHARKBOI_TALK_GIVEUP or {}, function(_, str)
            return str == str_say
        end) then
            AddBoss("sharkboi", TUNING.SHARKBOI_ARENA_COOLDOWN_DAYS)
        end
    end)
end)
-- Monitor death
local function HookDeath(prefab, func)
    InitPrefab(prefab, function(inst)
        inst:ListenForEvent("onremove", function(inst)
            if e_util:IsAnim(function(anim)
                return anim:find("death")
            end, inst) then
                func(inst, prefab)
            end
        end)
    end)
end
HookDeath("crabking", function(inst, prefab)
    AddBoss(prefab, TUNING.CRABKING_RESPAWN_TIME)
end)
-- Boxing tailla
local eyes_prefab = {"eyeofterror", "twinofterror1", "twinofterror2"}
t_util:IPairs(eyes_prefab, function(prefab)
    AddPrefabPostInit(prefab, function(boss)
        boss:DoTaskInTime(0.2, function(inst)
            RemoveBoss("terrarium")
            inst:ListenForEvent("onremove", function(inst)
                if e_util:IsAnim(function(anim)
                    return anim:find("death")
                end, inst) then
                    if not e_util:FindEnt(nil, eyes_prefab) then
                        AddBoss("terrarium", TUNING.EYEOFTERROR_SPAWNDELAY)
                    end
                end
            end)
        end)
    end)
end)
-- Crazy pig
-- Refresh when dawn
t_util:IPairs({"daywalker", "daywalker2"}, function(prefab)
    AddPrefabPostInit(prefab, function(boss)
        boss:DoTaskInTime(0.2, function(inst)
            RemoveBoss("daywalker")
            RemoveBoss("daywalker2")
            e_util:Hook_Say(inst, function(str_say)
                if t_util:GetElement(STRINGS.DAYWALKER_POWERDOWN or {}, function(_, str)
                    return str == str_say
                end) then
                    local saver = m_util:GetSaver()
                    if saver then
                        local name = inst.prefab == "daywalker" and "daywalker2" or "daywalker"
                        AddBoss(name, (TUNING.DAYWALKER_RESPAWN_DAYS_COUNT+1)*saver:GetTotalDayTime()-saver:GetTodayTime())
                    end
                end
            end)
        end)
    end)
end)
-- Special
InitAndRemove("beequeenhivegrown", "beequeen")
t_util:IPairs({"toadstool", "toadstool_dark"}, function(prefab)
    AddPrefabPostInit(prefab, function(boss)
        RemoveBoss("toadstool_cap")
        boss:ListenForEvent("onremove", function(inst)
            if e_util:IsAnim(function(anim)
                return anim:find("death")
            end, inst) then
                AddBoss("toadstool_cap", TUNING.TOADSTOOL_RESPAWN_TIME)
            end
        end)
    end)
end)
AddPrefabPostInit("toadstool_cap", function(inst)
    inst:DoTaskInTime(0.2, function(inst)
        if e_util:IsAnim(function(anim)
            return anim:find("idle")
        end) then
            RemoveBoss("toadstool_cap")
        end
    end)
end)
InitAndRemove("minotaur")
AddPrefabPostInit("atrium_gate", function(inst)
    inst:DoTaskInTime(0.2, function(inst)
        if e_util:IsAnim(function(anim)
            return anim:find("idle")
        end) then
            RemoveBoss("stalker_atrium")
        end
    end)
end)
-- Other
HookDeath("beequeen", function(inst, prefab)
    AddBoss(prefab, TUNING.BEEQUEEN_RESPAWN_TIME)
end)
HookDeath("dragonfly", function(inst, prefab)
    AddBoss(prefab, TUNING.DRAGONFLY_RESPAWN_TIME)
end)
HookDeath("malbatross", function(inst, prefab)
    AddBoss(prefab, TUNING.MALBATROSS_SPAWNDELAY_BASE)
end)
HookDeath("walrus", function(inst, prefab)
    local saver = m_util:GetSaver()
    if not saver then return end
    local time_f = TUNING.WALRUS_REGEN_PERIOD
    if saver:GetTotalSeasonTime() - saver:GetSeasonTime() > time_f then
        AddBoss(prefab, time_f)
    end
end)
HookDeath("stalker_atrium", function(inst, prefab)
    AddBoss(prefab, TUNING.ATRIUM_GATE_COOLDOWN + TUNING.ATRIUM_GATE_DESTABILIZE_DELAY + TUNING.ATRIUM_GATE_DESTABILIZE_TIME + TUNING.ATRIUM_GATE_DESTABILIZE_WARNING_TIME)
    AddBoss("minotaur", TUNING.ATRIUM_GATE_DESTABILIZE_TIME + TUNING.ATRIUM_GATE_DESTABILIZE_WARNING_TIME)
end)

-- Crack
AddPrefabPostInit("wagstaff_npc_pstboss", function(inst)
    inst:DoTaskInTime(0.2, function(inst)
        e_util:Hook_Say(inst, function(str_say)
            if table.contains({STRINGS.WAGSTAFF_NPC_CAPTURESTOP1, STRINGS.WAGSTAFF_NPC_CAPTURESTOP3}, str_say) then
                AddBoss("lunarrift_portal", TUNING.RIFTS_SPAWNDELAY)
            end
        end)
    end)
end)
InitAndRemove("lunarrift_portal")

AddPrefabPostInit("charlie_hand", function(inst)
    inst:DoTaskInTime(0.2, function(inst)
        inst:ListenForEvent("onremove", function(inst)
            if e_util:IsAnim(function(anim)
                return anim:find("grab_pst")
            end, inst) then
                AddBoss("shadowrift_portal", TUNING.RIFTS_SPAWNDELAY)
            end
        end)
    end)
end)
InitAndRemove("shadowrift_portal")

-- Rabbit King
-- Terra in a Box
local rabbits = {"rabbitking_aggressive", "rabbitking_passive","rabbitking_lucky",}
t_util:IPairs(rabbits, function(prefab)
    AddPrefabPostInit(prefab, function(boss)
        boss:DoTaskInTime(0.2, function(inst)
            RemoveBoss("rabbitking_lucky")
            if prefab == "rabbitking_aggressive" then
                inst:ListenForEvent("onremove", function(inst)
                    if e_util:IsAnim(function(anim)
                        return anim:find("death")
                    end, inst) then
                        AddBoss("rabbitking_lucky", TUNING.RABBITKING_COOLDOWN)
                    end
                end)
            end
        end)
    end)
end)