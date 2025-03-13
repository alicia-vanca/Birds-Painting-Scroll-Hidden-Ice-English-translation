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
        hover = "Fork number: disable noise number: enable noise \nthis needs to restart the game to take effect!",
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



m_util:AddBindShowScreen("sw_shutup", "Mute noise", "puppy_winter", "This feature takes effect after restarting the game!", {
    title = "Mute noise",
    id = save_id,
    data = screen_data,
    default = function (id)
        return save_data[id] and true or false
    end
}, nil, -9998)
