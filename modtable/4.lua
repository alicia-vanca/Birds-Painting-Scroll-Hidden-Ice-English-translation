local silent = "hx_shutup/shroomcake_shutup/silent" 
local save_id = "silent"
local save_data = s_mana:GetSettingLine(save_id, true)
local screen_data = {}
local noises = require("data/noisetable")
local function shutup_pets()
    t_util:Pairs(noises.pets, function(pet, pet_sounds)
        t_util:IPairs(pet_sounds, function(pet_sound)
            RemapSoundEvent(pet..pet_sound , silent)
        end)
    end)
end

local function addfn(name, fn)
    table.insert(screen_data, {
        id = name,
        label = name,
        hover = "X: Disable noise  Check: Enable noise\nThis feature requires a game restart to take effect!",
        default = function ()
            return save_data[name]
        end,
        fn = function (right)
            save_data[name] = right and true or nil
            s_mana:SaveSettingLine(save_id, save_data)
        end
    })
    if not save_data[name] then
        fn()
    end
end

addfn("Pet", shutup_pets)

t_util:Pairs(noises.only, function(name, noises)
    local function fn()
        if type(noises) == "string" then
            RemapSoundEvent(noises, silent)
        else
            t_util:IPairs(noises, function(noise)
                RemapSoundEvent(noise, silent)
            end)
        end
    end
    addfn(name, fn)
end)



m_util:AddBindShowScreen("sw_shutup", "Mute Noise", "phonograph", "This feature requires a game restart to take effect!", {
    title = "Mute Noise",
    id = save_id,
    data = screen_data,
    default = function (id)
        return save_data[id] and true or false
    end,
    icon = 
    {{
        id = "add",
        prefab = "mods",
        hover = "Click to add an entity to remove its noise!",
        fn = function()
            h_util:CreatePopupWithClose("Mute Noise", "This feature is not customized yet; custom entity additions are not supported!")
        end,
    }}
}, nil, -9998)
