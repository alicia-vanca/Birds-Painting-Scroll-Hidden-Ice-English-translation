local save_id, stat_name, buff_str = "huxi_nightmare", "nightmare", "Nightmare phase"
local Data = {}
local xml1, tex1 = h_util:GetPrefabAsset("nightmare_timepiece")
local xml2, tex2 = h_util:GetPrefabAsset("nightmare_timepiece_warn")
local xml3, tex3 = h_util:GetPrefabAsset("nightmare_timepiece_nightmare")
local default_data = {
    sw = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local phase_data = {
    calm = {
        xml = xml1,
        tex = tex1,
        describe = "Calm",
        color = h_util:GetRGB("White")
    },
    warn = {
        xml = xml2,
        tex = tex2,
        describe = "Warn",
        color = h_util:GetRGB("Yellow")
    },
    dawn = {
        xml = xml2,
        tex = tex2,
        describe = "Transition",
        color = h_util:GetRGB("Pink")
    },
    wild = {
        xml = xml3,
        tex = tex3,
        describe = "Riot",
        color = h_util:GetRGB("Red"),
    },
    default = {
        describe = "Unknown",
        text = "--:--",
        xml = xml1,
        tex = tex1,
    }
}
local ti_last = 1
local meta = {
    text = {
        text = "--:--",
        color = h_util:GetRGB("White"),
    },
    img = {
        xml = xml1,
        tex = tex1,
    },
    describe = "Unknown"
}
i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    if not world:HasTag("cave") then return end
    saver:RegStat(stat_name, buff_str, "The countdown of nightmare phase in cave", function()return save_data.sw end, fn_save("sw"), {
        periodic = function(data)
            local phase, ti = Data.phase, Data.timeinphase
            local info = type(ti)=="number" and phase and phase_data[phase]
            if info then
                local info = phase_data[phase]
                -- Current distance ti, last second, ti_last
                -- (total distance-current journey) / speed
                local left_time = (1-ti)/(ti-ti_last)
                data.value = left_time
                data.stat = info.describe
                if left_time > 0 then
                    meta.text.text = saver:FormatSecond(left_time)
                    meta.img.xml = info.xml
                    meta.img.tex = info.tex
                    meta.describe = info.describe
                    meta.text.color = info.color
                else
                    meta.text.text = "State change"
                    meta.describe = "Unknown"
                end
                if ti == 1 and phase == "wild" then
                    data.stat = "Riot lock"
                    meta = {
                        text = {
                            text = "Riot lock",
                        },
                        img = {
                            xml = xml3,
                            tex = tex3,
                        },
                        describe = "Riot lock"
                    }
                end
                ti_last = ti
            end
            local describe
            return meta
        end,
        fn_left = function(data)
            local time = tonumber(data.value)
            local phase = data.stat
            if time and phase then
                local str_say = string.format("The %s stage will end after %s.", phase, c_util:FormatSecond_ms(time))
                if phase == "Riot lock" then
                    str_say = "The riot state has been locked!ready to kill the shadow weaver!"
                end
                if time < 0 then
                    str_say = "It is changing the riots ..."
                end
                u_util:Say(STRINGS.LMB..str_say, nil, "net", nil, true)
            end
        end
    })
    
    saver:AddStat(stat_name, "fuckdata", phase_data.default)
    e_util:SetBindEvent(world, "nightmareclocktick", function(world, data)
        Data = data or {}
    end)
end)