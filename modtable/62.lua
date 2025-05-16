local save_id, stat_name, boss_str = "huxi_warn", "warndata", "Monster warning"
local default_data = {
    sw = true,
    way = "ann",
    color = "Red",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local way_default = m_util:IsTurnOn("pos_say")

i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    saver:RegStat(stat_name, boss_str, "Monster warning - Advanced settings", function()return save_data.sw end, fn_save("sw"), {
        periodic = function(data, id, worldtime)
            local time = data.value - worldtime
            return time > 0 and {}
        end,
        fn_left = function(data)
            if data.announce then
                u_util:Say(STRINGS.LMB.." "..data.announce, nil, "net", nil, true)
            end
        end
    }, {
        screen_data = {
            {
                id = "way",
                label = "Type:",
                hover = "The location of the warning message when the monster attacks",
                default = fn_get,
                fn = fn_save("way"),
                type = "radio",
                data = {
                    {data = "idea", description = "Default"},
                    {data = "ann", description = "Annoucement"},
                    {data = "head", description = "My head"},
                    {data = "self", description = "My chat"},
                    {data = "null", description = "Off"},
                }
            },
            {
                id = "color",
                label = "Color:",
                hover = "The color of the warning message when the monster attacks",
                default = fn_get,
                fn = fn_save("color"),
                type = "radio",
                data = (require("data/valuetable")).RGB_datatable,
            },
        },
        priority = 100,
        color = h_util:GetRGB(save_data.color),
    })
end)

local DataBoss = {
    warg = {
        text = "Hound",
        announce = "Hound is about to attack! Please pay attention to defense!"
    },
    worm = {
        text = "Worm strike",
        announce = "Cave worms are coming! Please pay attention to defense!"
    },
    bat = {
        text = "Nitro-bats",
        announce = "Nitro-bats are coming! Please pay attention to defense!"
    },
    bearger = {
        text = "Bearger is coming",
        announce = "Bearger is about to spawn! Please leave the base!"
    },
    deerclops = {
        text = "Deerclops comes",
        announce = "Deerclops is about to spawn! Please leave the base!"
    },
    antlion = {
        text = "Antlion is angry",
        announce = "The Antlion was launched! Please leave the base!"
    },
    cavein_boulder = {
        text = "Boulder fall",
        announce = "Antlion was angry! Please pay attention to the falling stone!"
    },
    polly_rogershat = {
        text = "Pirate strike",
        announce = "The pirate monkey invaded! Please pay attention to defense!",
    }
}


local _last_say_time = 0
local function AddWarn(icon)
    return function()
        if (GetTime() - _last_say_time < 20) then
            return
        end
        _last_say_time = GetTime()
        local saver = TheWorld and TheWorld.components and TheWorld.components.hx_saver
        if saver then
            local info = DataBoss[icon]
            local xml, tex = h_util:GetPrefabAsset(icon)
            if info and xml then
                local cd = info.cd or 30
                saver:AddStat(stat_name, icon, {
                    xml = xml,
                    tex = tex,
                    describe = info.text or "",
                    text = info.text or "",
                    value = saver:GetWorldTime() + cd,
                    announce = info.announce
                })
                local way = save_data.way
                if info.announce and way~="null" then
                    i_util:DoTaskInTime(1, function()
                        if way == "ann" then
                            u_util:Say(STRINGS.LMB.." "..info.announce, nil, "net", nil, true)
                        elseif way == "self" then
                            u_util:Say(boss_str, info.announce, "self", save_data.color, true)
                        elseif way == "head" then
                            u_util:Say(info.announce, nil, "head", save_data.color, true)
                        else
                            u_util:Say(boss_str, info.announce, nil, save_data.color, true)
                        end
                    end)
                end
            end
            if not saver:HasStatUI(stat_name, icon) then
                saver:SetTimerConfig()
            end
        end
    end
end


local function QuickAdd(sound, num, icon)
    for i = 1,num do
        AddPrefabPostInit(sound.."warning_lvl"..i, AddWarn(icon))
    end
end
QuickAdd("hound", 4, "warg")
QuickAdd("worm", 4, "worm")
QuickAdd("acidbatwave", 1, "bat")
QuickAdd("bearger", 4, "bearger")
QuickAdd("deerclops", 4, "deerclops")

for i = 1,3 do
    AddPrefabPostInit("sinkhole_warn_fx_"..i, AddWarn("antlion"))
end
AddPrefabPostInit("cavein_debris", AddWarn("cavein_boulder"))
AddPrefabPostInit("piratewarningsound", AddWarn("polly_rogershat"))