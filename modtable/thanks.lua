if m_util:IsServer() then
    return
end
local save_id, string_thank = "thanks", "Thank you"
local default_data = {
    mine = false,           -- Do not show personal effects
    fix = "Lightning attach",
    move = "Snowflake",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local UserTable = {
    ["76561198426806125"] = {
        fix = "Lightning attach",
        move = "Snowflake",
        label = "呼吸",
        desc = "Author of bird painting roll",
        hover = "It's the author!",
    },
    ["76561198993383229"] = {
        fix = "The arrival of the moon god",
        move = "Snowflake",
        label = "呼啦啦",
        desc = "Good morning, to prevent me from seeing you, so in the afternoon, good evening, good night!",
        hover = "Found many bugs, contributed to the scroll!",
    },
    ["76561199134213846"] = {
        fix = "Lightning attach",
        move = "Snowflake",
        label = "初心桑麻",
        desc = "Rem is so cute, I will always love Rem",
        hover = "Found many bugs, contributed to the scroll!",
    },
    ['76561199211743561'] = {
        fix = "Swirl",
        move = "Ice",
        label = "咬一口星星奶酪",
        desc = "Star cheese, delicious star cheese, hey",
        hover = "Improve the t key console",
    },
    ['76561198309975624'] = {
        fix = "The arrival of the moon god",
        move = "Ice",
        label = "超级Joker",
        desc = "Believe that you have the ability, then you really have it.",
        hover = "T key control table perfect sticker",
    },
    ['76561199182167353'] = {
        fix = "Lightning attach",
        move = "Trace",
        label = "八雪",
        desc = "Alas, i found wild meatballs.",
        hover = "T key control table perfect sticker",
    },
    ['76561198297714368'] = {
        fix = "Rainy cloud",
        move = "Snowflake",
        label = "青雨",
        desc = "Blue color and rain",
        hover = "T key control table perfect sticker",
    },
    ['76561199118545368'] = {
        fix = "Lightning attach",
        move = "Crack",
        label = "糖炒栗子星人",
        desc = "It's not that the ending of the story is not good enough, but that we have too much requirements for the story",
        hover = "T key control table perfect sticker",
    },
    ["76561198163711010"] = {
        fix = "Lightning attach",
        move = "Snowflake",
        label = "晓佳乐",
        desc = " Qunbird painting spokesperson xiaojiale will serve you online",
        hover = "Bug tester",
    },
    ["76561199088296896"] = {
        fix = "The arrival of the moon god",
        move = "Note",
        label = "抹茶麻薯糯米糍",
        desc = " The daily academic progress is 5%, and the famine progress is 100%",
        hover = "T key control table perfect sticker",
    },
    ["76561198306201750"] = {
        fix = "Lightning attach",
        move = "Crack",
        label = "❀Luka❀",
        desc = "Fireworks are easy to pass and have a long -lasting relationship.",
        hover = "T key control table perfect sticker",
    },
    ["76561198443435603"] = {
        fix = "Rainy cloud",
        move = "Snowflake",
        label = "sudatime",
        desc = "Come and play with the hungry guy ~",
        hover = "I found a lot of bugs, add bricks to the paintings!",
    },
    ["76561198373125486"] = {
        fix = "Lightning attach",
        move = "Petal",
        label = "󰀍西瓜@󰀍",
        desc = "Don’t put me in the fridge, I won’t turn into watermelon ice!",
        hover = "Improve function [monster warning]",
    },
    ['76561198205451564'] = {
        fix = "The arrival of the moon god",
        move = "Snowflake",
        label = "JKstring",
        desc = "This requirement is fine, but I need a 16-year-old beautiful girl to test the function",
        hover = "Difficulties in Restoring Scrolls",
    },
    ["76561199471728571"] = {
        fix = "The arrival of the moon god",
        move = "Snowflake",
        label = "Mumu the Devil",
        desc = "Being in a daze and doing nothing seriously is already working hard",
        hover = "T key console item classification",
    },
}
t_util:Pairs(UserTable, function(id, data)
    data.id = id
end)

i_util:AddLeftClickFunc(function(pc, player, down, act_left, ent_mouse)
    if not (ent_mouse and ent_mouse:HasTag("player") and act_left and act_left.action and act_left.action.id == "LOOKAT") then return end
    local id_klei = ent_mouse.userid
    local data = id_klei and TheNet:GetClientTableForUser(id_klei)
    local id_net = data and data.netid
    if not id_net then return end
    local data_fx = UserTable[id_klei] or UserTable[id_net]
    if not data_fx then return end
    if data_fx.desc then
        u_util:Say("󰀍 thank you very much 别", data_fx.desc, "self", "Red")
    end
    if save_data[data_fx.id] then return end
    local pos = ent_mouse:GetPosition()
    local fx = SpawnPrefab("boatrace_fireworks")
    fx.Transform:SetPosition(pos.x, 0, pos.z)
    fx:DoTaskInTime(3, function(fx)
        fx:Remove()
    end)
    local _fx = SpawnPrefab("moonpulse")
    _fx.Transform:SetPosition(pos.x, 0, pos.z)
    _fx:DoTaskInTime(3, function(fx)
        _fx:Remove()
    end)
end)
local FixTable = {
    ["Lightning attach"] = function()
        local inst = e_util:SpawnNull()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
        inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(1)
        inst.AnimState:SetScale(1.5, 1.5)
        inst.AnimState:PlayAnimation("crackle_loop", true)
        return inst
    end,
    ["Flame attached"] = function()
        local inst = e_util:SpawnNull()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("bernie_fire_fx")
        inst.AnimState:SetBuild("bernie_fire_fx")
        inst.AnimState:PlayAnimation("bernie_fire_reg", true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetScale(0.8, 0.7)
        inst.AnimState:SetMultColour(1,0.7,0,0.3)
        return inst
    end,
    ["The arrival of the moon god"] = function()
        local inst = e_util:SpawnNull()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("fx_book_moon")
        inst.AnimState:SetBuild("fx_book_moon")
        inst.AnimState:PushAnimation("play_fx")
        inst.AnimState:SetScale(4, 4)
        inst.AnimState:SetDeltaTimeMultiplier(0.5)
        inst.Transform:SetPosition(0, -6, 0)
        return inst
    end,
    ["Rainy cloud"] = function()
        local inst = e_util:SpawnNull()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("fx_book_rain")
        inst.AnimState:SetBuild("fx_book_rain")
        inst.AnimState:PushAnimation("play_fx")
        inst.AnimState:SetScale(2, 2)
        inst.Transform:SetPosition(-2, 0, -2)
        return inst
    end,
    ["Swirl"] = function()
        local inst = e_util:SpawnNull()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("atrium_gate_overload_fx")
        inst.AnimState:SetBuild("atrium_gate_overload_fx")
        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(1)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround) 
        inst.AnimState:SetLayer(LAYER_BACKGROUND) 
        inst.AnimState:SetScale(2.3, 2.3)
        inst.Transform:SetPosition(0, 0, 7.2)
        inst.AnimState:SetAddColour(unpack(h_util:GetWRGB("Breathing purple")))
        return inst
    end
}
local MoveTable = {
    ["Petal"] = "attackfx_handpillow_petals",
    ["Celestial body"] = "alterguardian_laserscorch",
    ["Trace"] = "deerclops_laserscorch",
    ["Note"] = "battlesong_attach",
    ["Water stain"] = "bile_puddle_land",
    ["Fart"] = "cavein_dust_low",
    ["Bubble"] = "crab_king_bubble1",
    ["Snowflake"] = "crab_king_icefx",
    ["Ice"] = "deer_ice_flakes",
    ["Spore"] = "farm_plant_unhappy",
    ["Crack"] = "fossilspike2_base",
}
local id_thread = "fix_move_threand"
local function AddFix(player, name)
    if player._fix_fx then
        player._fix_fx:Remove()
        player._fix_fx = nil
    end
    local fx_func = name and FixTable[name]
    if not fx_func then return end
    player._fix_fx = fx_func()
    player._fix_fx.entity:SetParent(player.entity)
end
local function AddMove(player, name)
    local function stop()
        if player._move_fx then
            KillThreadsWithID(id_thread)
            player._move_fx:SetList(nil)
            player._move_fx = nil
        end
    end
    stop()
    local move_func = name and MoveTable[name]
    if not move_func then return end
    player._move_fx = StartThread(function()
        local anim = e_util:GetAnim(player)
        while player._move_fx do
            if anim=="run_loop" then
                local move_fx
                if type(move_func) == "string" then
                    move_fx = SpawnPrefab(move_func)
                else
                    move_fx = move_func()
                end
                local pos = player:GetPosition()
                move_fx.Transform:SetPosition(pos.x, 0, pos.z)
                move_fx.persists = false
                move_fx:DoTaskInTime(2, function(fx)
                    fx:Remove()
                end)
            end
            d_util:Wait(0.5)
            anim = e_util:GetAnim(player)
        end
        stop()
    end, id_thread)
end

local function SetMyFx(player, show)
    if not e_util:IsValid(player) then
        return
    end
    AddFix(player, show and save_data.fix)
    AddMove(player, show and save_data.move)
end

AddPlayerPostInit(function(player)
    player:DoTaskInTime(0, function()
        if player == ThePlayer and m_util:IsHuxi() then
            if save_data.mine then
                SetMyFx(player, true)
            end
        else
            local id_klei = player.userid
            local data = id_klei and TheNet:GetClientTableForUser(id_klei)
            local id_net = data and data.netid
            if not id_net then return end
            local data_fx = UserTable[id_klei] or UserTable[id_net]
            if data_fx then
                if not save_data[data_fx.id] then
                    AddFix(player, data_fx.fix)
                    AddMove(player, data_fx.move)
                end
            end
        end
    end)
end)


local screendata = t_util:PairToIPair(UserTable, function(id, data)
    return {
        id = id,
        label = data.label,
        fn = function(value)
            local players = e_util:FindEnts(ThePlayer, nil, nil, "player", {})
            t_util:IGetElement(players, function(player)
                local id_klei = player.userid
                local data = id_klei and TheNet:GetClientTableForUser(id_klei)
                local id_net = data and data.netid
                if not id_net then return end
                if (id_net == id or id_klei == id) then
                    local data_fx = UserTable[id]
                    if not data_fx then return end
                    if value then
                        AddFix(player)
                        AddMove(player)
                    else
                        AddFix(player, data_fx.fix)
                        AddMove(player, data_fx.move)
                    end
                    return true
                end
            end)
            fn_save(id)(value)
        end,
        hover = "Contribute: "..data.hover.."\nCheck this option to turn off the player's special effects",
        default = fn_get,
    }
end)

if m_util:IsHuxi() then
    local screendata_start = {
        {
            id = "mine",
            label = "Personal effect",
            fn = function(value)
                fn_save("mine")(value)
                SetMyFx(ThePlayer, value)
            end,
            hover = "Whether to show personal effects",
            default = fn_get,
        },
        {
            id = "fix",
            label = "Skyfall magical power:",
            fn = function(value)
                fn_save("fix")(value)
                if ThePlayer then
                    AddFix(ThePlayer, value)
                end
            end,
            hover = "Bind the magical power of the player",
            default = fn_get,
            type = "radio",
            data = t_util:PairToIPair(FixTable, function(name)
                return {data = name, description = name}
            end)
        },
        {
            id = "move",
            label = "Step by step:",
            fn = function(value)
                fn_save("move")(value)
                if ThePlayer then
                    AddMove(ThePlayer, value)
                end
            end,
            hover = "The special effects generated by the player's feet",
            default = fn_get,
            type = "radio",
            data = t_util:PairToIPair(MoveTable, function(name)
                return {data = name, description = name}
            end)
        }
    }
    screendata = t_util:MergeList(screendata_start, screendata)
end

local function Fn()
    m_util:AddBindShowScreen({
        title = "󰀍 thank you very much 󰀍",
        id = "thanks",
        data = screendata,
    })()
    h_util:CreatePopupWithClose("󰀍 Thank you very much 󰀍",  "󰀍 Thank you for your help in the development of this mod 󰀍", {{text="󰀍", cb = function()end}})
end
m_util:AddBindIcon(string_thank, "icon_health", "󰀍 Thank these players/authors for their help with this mod 󰀍", true, Fn, nil, -9999)