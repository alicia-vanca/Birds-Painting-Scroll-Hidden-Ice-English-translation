local save_id, stat_name, boss_str = "huxi_clock", "clock_time", "Current time"
local default_data = {
    sw = m_util:IsHuxi(),
    format = "%H:%M",
    color = "Khaki",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local v_data = require "data/valuetable"

local function GetOSTime()
    return os.date(save_data.format)
end


i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    saver:RegStat(stat_name, boss_str, "Clock settings", function()return save_data.sw end, fn_save("sw"), {
        periodic = function(data)
            data.text = GetOSTime()
            return {
                text = {
                    text = data.text,
                    color = h_util:GetRGB(save_data.color)
                }
            }
        end,
        fn_left = function(data)
            u_util:Say(STRINGS.LMB..os.date("Today is %Y/%m/%d, current time %H:%M:%S "), nil, "net", nil, true)
        end
    }, {
        screen_data = {
            {
                id = "format",
                label = "Time format:",
                fn = fn_save("format"),
                hover = "Select the time format of the display",
                default = fn_get,
                type = "radio",
                data = {
                    {
                        data = "%H:%M:%S", description = "Time: simon",
                    },
                    {
                        data = "%H:%M", description = "Time: divide",
                    },
                }
            },
            {
                id = "color",
                label = "Font color:",
                fn = fn_save("color"),
                hover = "Select the displayed font color",
                default = fn_get,
                type = "radio",
                data = v_data.RGB_datatable,
            }
        },
        priority = -3,
    })

    local default_data = {
        describe = "Current time",
        text = GetOSTime(),
        color = h_util:GetRGB(save_data.color)
    }
    default_data.xml, default_data.tex = h_util:GetPrefabAsset("icon_shadowaligned")
    saver:AddStat(stat_name, "time", default_data)
end)
