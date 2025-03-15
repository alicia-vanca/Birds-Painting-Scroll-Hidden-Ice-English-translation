local save_id, stat_name, buff_str = "huxi_rain", "rain", "Rain/snow countdown"
local default_data = {
    sw = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local Data = {}
local data_w = {
    rain = {
        describe = "Rainfall",
        png = "icon_wetness",
    },
    snow = {
        describe = "Snowfall",
        png = "icon_cold",
    },
    sun = {
        describe = "Sunny",
        png = "icon_heat",
    },
    hail = {
        describe = "Moon Hail",
        png = "icon_moonaligned",
    },
    cave = {
        describe = "Dry",
        png = "icon_lightbattery",
    },
    acid = {
        describe = "Acid Rain",
        png = "icon_acid",
    }
}
t_util:Pairs(data_w, function(stat, data)
    local xml, tex = h_util:GetPrefabAsset(data.png)
    data.xml = xml
    data.tex = tex
    data.text = data.describe
end)

i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    local state = world.state
    local iscave, isforest = world:HasTag("cave"), world:HasTag("forest")
    if not (state and (iscave or isforest)) then return end
    local function GetWeatherData()
        local data = data_w.sun
        if state.islunarhailing then
            data = data_w.hail
        elseif state.isacidraining then
            data = data_w.acid
        elseif state.israining then
            data = data_w.rain
        elseif state.issnowing then
            data = data_w.snow
        elseif iscave then
            data = data_w.cave
        end
        return data
    end


    saver:RegStat(stat_name, buff_str, "Predict when the rain or snow will stop", function()return save_data.sw end, fn_save("sw"), {
        periodic = function(data)
            local info = GetWeatherData()
            local time
            if state.pop == 1 then
                time = saver:GetRainStop()
            else
                time = saver:GetRainStart()
            end
            info.text = time and c_util:FormatSecond_dms(time) or info.describe
            t_util:Pairs(info, function(k, v)
                data[k] = v
            end)
            data.time = time
            return {
                text = {
                    text = info.text,
                },
                img = {
                    xml = info.xml,
                    tex = info.tex,
                },
                describe = info.describe,
            }
        end,
        fn_left = function()
            u_util:Say(STRINGS.LMB.." "..saver:GetRainPredict(), nil, "net", nil, true)
        end
    }, {
        priority = -1,
    })
    
    local default = {
        describe = "Weather",
        text = "Weather",
    }
    default.xml, default.tex = h_util:GetPrefabAsset("icon_clothing")
    saver:AddStat(stat_name, "fuckdata", default)
end)