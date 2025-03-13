local total_day_time = TUNING.TOTAL_DAY_TIME--One day, 16 grid, 8 minutes
-- Ordinary buff
local buffs_data = {
    -- Fruity jelly
    electricattack = {
        image = "voltgoatjelly",
        duration = TUNING.BUFF_ELECTRICATTACK_DURATION,
        judge = {"voltgoatjelly"},
        describe = "Attack band",
    },
    -- Blue belt fish steak
    moistureimmunity = {
        image = "frogfishbowl",
        duration = TUNING.BUFF_MOISTUREIMMUNITY_DURATION,
        judge = {"frogfishbowl"},
        describe = "Immune humidity",
    },
    light = {
        image = "glowberrymousse",
        duration = TUNING.WORMLIGHT_DURATION * 4,
        judge = {
            "_spice_phosphor",
            "glowberrymousse", 
            "dish_fleshnapoleon", 
            wormlight = TUNING.WORMLIGHT_DURATION, 
            wormlight_lesser = TUNING.WORMLIGHT_DURATION * .25,
        },
        describe = "Light",
    },
    -- Mushroom cake
    sleepresistance = {
        image = "shroomcake",
        duration = TUNING.SLEEPRESISTBUFF_TIME,
        judge = {"shroomcake"},
        describe = "Mushroom mousse",
    },
    -- Jelly bean
    healthregen = { 
        image = "jellybean", 
        duration = TUNING.JELLYBEAN_DURATION,
        judge = {"jellybean"},
        describe = "Rainbow sugar",
    },
    sweettea = {
        image = "sweettea",
        duration = TUNING.SWEETTEA_DURATION,
        judge = {"sweettea"},
        describe = "Increased knowledge",
    },
    -- Coffee
    coffee = {
        image = "cane", 
        duration = total_day_time / 2,
        judge = {"coffee"},
        describe = "Coffee acceleration",
    },

    -- Updated 2024.9.9
    -- Nightberry
    nightvision = {
        image = "ancientfruit_nightvision",
        duration = TUNING.ANCIENTTREE_NIGHTVISION_FRUIT_BUFF_DURATION,
        judge = {"ancientfruit_nightvision"},
        describe = "Night vision",
    }
}
-- Seasoning
local spices_data = {
    -- Hot
    SPICE_CHILI = {
        image = "pepper",
        duration = TUNING.BUFF_ATTACK_DURATION,
        judge = {"_spice_chili"},
        describe = "Hot damage",
    },
    -- Garlic
    SPICE_GARLIC = {
        image = "garlic",
        duration = TUNING.BUFF_PLAYERABSORPTION_DURATION,
        judge = {"_spice_garlic"},
        describe = "Rough skin",
    },
    -- Sweet
    SPICE_SUGAR = {
        image = "multitool_axe_pickaxe_pickaxeaxe",
        duration = TUNING.BUFF_WORKEFFECTIVENESS_DURATION,
        judge = {"_spice_sugar"},
        describe = "Efficient work",
    },
}
-- Extraordinary attributes (seasonings and hot and cold)
local function GetEdible(prefab)
    local food = e_util:ClonePrefab(prefab)
    local edible = food.components.edible
    if not edible then return end
    local buffs = {}
    local spice = edible.spice
    if spice and type(spices_data[spice]) == "table" then
        buffs[spice] = t_util:MergeMap(spices_data[spice])
    end
    local temp = edible.temperaturedelta
    local dur = edible.temperatureduration
    if type(temp) == "number" and type(dur) == "number" and temp~=0 and dur~=0 then
        if temp > 0 then
            buffs.HOT = {
                duration = dur,
                describe = "Heating up"..temp.."Spend",
                image = "heatrock_fire5",
            }
        else
            buffs.COLD = {
                duration = dur,
                describe = "Cool down"..-temp.."Spend",
                image = "icehat",
            }
        end
    end
    return buffs
end


-- Get all prefab all buffs
-- Map table
-- Buff_id = {image = 'picture', duration = 'duration', description = 'description'}
local BuffCache = {}
local function GetBuffs(prefab)
    if BuffCache[prefab] then return BuffCache[prefab] end
    local buffs = GetEdible(prefab) or {}
    t_util:Pairs(buffs_data, function(buffname, buffdata)
        t_util:Pairs(buffdata.judge, function(j_id, buffstr)
            if type(j_id) == "number" then
                if c_util:IsStrContains(prefab, buffstr)then
                    buffs[buffname] = t_util:MergeMap(buffdata)
                end
            elseif j_id == prefab and type(buffstr)=="number" then
                buffs[buffname] = t_util:MergeMap(buffdata)
                buffs[buffname].duration = buffstr
            end 
        end)
    end)

    BuffCache[prefab] = buffs
    return buffs
end

-- Get buff data through the buff name
-- Buff_id = {image = 'picture', description = 'description'}
local function GetBuffData(buffname)
    if buffname == "HOT" then
        return {
            describe = "Heating up",
            image = "heatrock_fire5",
        }
    elseif buffname == "COLD" then
        return {
            describe = "Cool down",
            image = "icehat",
        }
    else
        return t_util:GetElement(buffs_data, function(name, data)
            return name == buffname and t_util:MergeMap(data)
        end) or t_util:GetElement(spices_data, function(name, data)
            return name == buffname and t_util:MergeMap(data)
        end)
    end
end

-- Time buff name -to store
-- To show
-- Xml, tex, describe, click to announce, Right-click the modified function, fixed display time countdown, text, category, id, id, id, id, id, id, id, id, id, id, id
-- Registering the info tray type
local save_id, stat_name, buff_str = "huxi_buff", "buffdata", "Buff timing"
local default_data = {
    sw = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local color_red,color_white = h_util:GetRGB("Red"), h_util:GetRGB("White")
i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    -- Register buff
    saver:RegStat(stat_name, buff_str, "Countdown to the attributes of various foods", function()return save_data.sw end, fn_save("sw"), {
        periodic = function(data, id)
            -- Calculation method (although it can be continuously implemented -1, that method should be inaccurate, i am not sure if it is accurate)
            -- Buff total detaire -buff has taken effect time 
            -- Buff total time- (current time -buff start time)
            -- Because the game can be suspended, the current time cannot be used in os.time but gettime
            data.value = data.duration - (GetTime() - data.time_start)
            if data.value > 0 then
                return {
                    text = {
                        color = data.value < 60 and color_red or color_white,
                        text = saver:FormatSecond(data.value)
                    }
                }
            end
        end,
        addstat = function(data, buff_id)
            local xml, tex = h_util:GetPrefabAsset(data.image)
            if xml then
                data.time_start = GetTime()
                data.xml = xml
                data.tex = tex
                data.value = data.duration
                -- M_util: print ('add buff', buff_id)
                return true
            end
        end,
        sort = function(a, b)
            return a.value < b.value
        end,
        fn_left = function(data)
            local str_time = c_util:FormatSecond_ms(data.value)
            local str_say = string.format("I have [%s] buff, remaining effective time: %s", data.describe, str_time)
            u_util:Say(STRINGS.LMB..str_say, nil, "net", nil, true)
        end,
        entercharacterselect = function(data)
            t_util:Pairs(data, function(k)
                data[k] = nil
            end)
        end,
    })

    -- Entrusted buff data
    local save_buff = saver:GetLine(stat_name) -- Save the remaining time
    t_util:Pairs(save_buff, function(buff_name, save_time)
        local data = GetBuffData(buff_name)
        if data then
            saver:AddStat(stat_name, buff_name, {
                duration = save_time,
                describe = data.describe,
                image = data.image,
            })
        end
    end)
    
    -- Eat food to increase the corresponding buff
    i_util:AddFoodDeactivatedFunc(function(prefab)
        local buffs = GetBuffs(prefab)
        t_util:Pairs(buffs, function(buff_name, data)
            saver:AddStat(stat_name, buff_name, {
                duration = data.duration,
                describe = data.describe,
                image = data.image,
            })
        end)
        if t_util:GetSize(buffs) > 0 then
            saver:SetTimerConfig()
        end
    end)

    -- Synchronous buff data
    saver:RegSaveFunc(function()
        t_util:Pairs(save_buff, function(key)
            save_buff[key] = nil
        end)
        local data = saver:GetStatData(stat_name) or {}
        t_util:Pairs(data, function(buff_name, buff_data)
            save_buff[buff_name] = math.floor(buff_data.duration - (GetTime() - buff_data.time_start))
        end)
    end)
end)

i_util:AddPlayerActivatedFunc(function(player, world, pusher, saver)
    p_util:SetBindEvent("isghostmodedirty", function(pc)
        if p_util:IsDead() then
            saver:ClearStat(stat_name)
        end
    end)
end)
