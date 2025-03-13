local save_id, map_str = "map_animal", "More creature icons"
local default_data = {
    sw = true,
    range_merge = 8,
    check_time = 3,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local prefabs_data = require("data/mapicons").prefabs_data
local prefabs_map = {}



-- Determine the corresponding icon and its corresponding icon
t_util:Pairs(prefabs_data, function(k, v)
    if type(v) == "string" then
        if type(k) == "number" then
            prefabs_map[v] = v
        elseif type(k) == "string" then
            prefabs_map[k] = v
        end
    end
end)

i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    local function MapMoreScreenDataFn()
        local screen_data = {
            -- {
            --     id = "range_merge",
            --     label = "Scope of merger:",
            --     fn = fn_save("range_merge"),
            --     hover = "When multiple same icons focus, \n the range of automatic merger",
            --     default = fn_get,
            --     type = "radio",
            --     data = t_util:BuildNumInsert(1, 20, 1, function(i)
            --         return {
            --             data = i * 4,
            --             description = i .. " Grid"
            --         }
            --     end),
            -- },
            {
                id = "check_time",
                label = "Icon check:",
                fn = fn_save("check_time"),
                hover = "Time to check the authenticity of the icon icon \n the larger the setting of the settings, but the less accurate (default 5 seconds)",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(1, 10, 1, function(i)
                    return {
                        data = i,
                        description = i .. " sec(s)"
                    }
                end),
            },
        }
        t_util:Pairs(prefabs_map, function(prefab, icon)
            local xml, tex, name = h_util:GetPrefabAsset(icon)
            if xml then
                table.insert(screen_data, {
                    id = icon,
                    label = name,
                    hover = "Whether to display "..name.. " The icon icon \ncon the setting settings after the game needs to be restarted to take effect!",
                    fn = fn_save(icon),
                    default = function()
                        return c_util:NilIsTrue(save_data[icon])
                    end,
                })
            end
        end)
        return screen_data
    end
    -- Icon registration
    saver:RegHMap(save_id, map_str, "Whether to display "..map_str.." Icon", function()return save_data.sw end, fn_save("sw"), {
            screen_data = MapMoreScreenDataFn,
        }
    )
    -- Inlet load
    local map_data = saver:GetList(save_id, true)
    t_util:IPairs(map_data, function(info)
        if c_util:NilIsTrue(save_data[info.icon]) then
            saver:AddHMap(save_id, info)
        end
    end)
    
    -- Exit and save and save daily storage
    saver:RegSaveFunc(function()
        t_util:Pairs(map_data, function(k)
            map_data[k] = nil
        end)
        t_util:Pairs(saver:GetHMapData(save_id) or {}, function(_, info)
            table.insert(map_data,{
                x = tonumber(string.format("%.2f", info.x)),
                z = tonumber(string.format("%.2f", info.z)),
                icon = info.icon
            }) 
        end)
    end)
end)

-- Travel in query every 5 seconds
local Intors = {}
local check_range, time_count = 64, 0
local function InIntors(info)
    return t_util:GetElement(Intors, function(inst, info_i)
        return info_i.x == info.x and info_i.z == info.z and info_i.icon == info.icon
    end)
end
i_util:AddPlayerActivatedFunc(function(player, world, pusher, saver)
    pusher:RegPerPos(function(x, z)
        -- Timer
        time_count = time_count + 1
        if time_count < save_data.check_time then return end
        time_count = 0
        -- Clean up nearby icons that are not in intors
        t_util:Pairs(saver:GetHMapData(save_id) or {}, function(_, info)
            if c_util:GetDist(x, z, info.x, info.z) < check_range and not InIntors(info) then
                saver:RemoveHMap(save_id, info)
            end
        end)
        -- Update icon
        t_util:Pairs(Intors, function(inst, info)
            local trans = e_util:IsValid(inst)
            if not trans then return end
            local x,_,z = trans:GetWorldPosition()
            local info_new = {x = x,z = z,icon = info.icon}
            saver:ChanHMap(save_id, info, info_new)
            Intors[inst] = info_new
        end)
    end)
end)


-- Load icons in creatures and departure
t_util:Pairs(prefabs_map, function(prefab, icon)
    if c_util:NilIsTrue(save_data[icon]) then
        AddPrefabPostInit(prefab, function(inst)
            inst:DoTaskInTime(0, function()
                local pusher = m_util:GetPusher()
                if not pusher then return end
                pusher:RegNearStart(inst, function(x, z)
                    -- Mobs appear and immediately refresh icons
                    local info = {x = x, z = z, icon = icon}
                    local saver = m_util:GetSaver()
                    if saver and saver:AddHMap(save_id, info, true) then
                        -- Add to Watch
                        Intors[inst] = info
                    end
                end, function()
                    local info = Intors[inst]
                    if not info then return end
                    -- Remove monitoring
                    Intors[inst] = nil
                    -- Remove icon?
                    if e_util:IsAnim(function(anim) return anim:find("death") end, inst) or e_util:GetLeaderTarget(inst) then
                        local saver = m_util:GetSaver()
                        if saver then
                            saver:RemoveHMap(save_id, info)
                        end
                    end
                    -- No more cleaning, let the monitor handle it
                end, check_range)
            end)
        end)
    end
end)

