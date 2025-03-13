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
        fn_left = function(data)
            local time = data.time
            local str_say
            local iscave = TheWorld:HasTag("cave")
            local str_pos = iscave and "Cave" or "Surface"
            if time then
                local str_time = c_util:FormatSecond_ms(time)
                local str_weather = state.season == "winter" and not iscave and "Snowfall" or "Rainfall"
                if state.pop == 1 then
                    if state.islunarhailing then
                        str_say = "This moon hail will end in "..string.format("%d", data.time).." seconds"
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
            u_util:Say(STRINGS.LMB..str_say.."。", nil, "net", nil, true)
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