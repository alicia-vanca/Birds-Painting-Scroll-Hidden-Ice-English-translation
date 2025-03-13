local t_util = require("util/tableutil")
local i_util = {
    world_func_in = {},
    data_func_load = {},
    leftclick_func = {},
    rightclick_func = {},
    midclick_func = {},
    hoverer_func_in = {},
    server_rpc_func = {},
    player_func_in = {},
    player_func_out = {},
    ltor_push_func = {},
    prefabs_hook_end = {},
    food_func_in = {},
    food_func_out = {}
}

-- Execute remote instructions
function i_util:ExRemote(str)
    if not TheNet:GetIsServerAdmin() then
        return
    end
    local x, _, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
    TheNet:SendRemoteExecute(str, x, z)
end

-- Transmit to a certain place
function i_util:GoTo(x, z)
    if type(x) ~= "number" and type(z) ~= "number" then
        return print("The parameters are illegal!x =", x, "z =", z)
    end
    local fnstr = "ThePlayer.Transform:SetPosition(" .. x .. ", 0, " .. z .. ")"
    self:ExRemote(fnstr)
end

-- Player role enters 
-- player, world, pusher, saver
function i_util:AddPlayerActivatedFunc(func)
    if type(func) == "function" then
        table.insert(i_util.player_func_in, func)
    end
end
-- Player character exits 
-- player, world
function i_util:AddPlayerDeactivatedFunc(func)
    if type(func) == "function" then
        table.insert(i_util.player_func_out, func)
    end
end
-- Data load
-- saver, world, player, pusher
function i_util:AddSessionLoadFunc(func)
    if type(func) == "function" then
        table.insert(i_util.data_func_load, func)
    end
end

-- World loading is completed
-- world
function i_util:AddWorldActivatedFunc(func)
    if type(func) == "function" then
        table.insert(i_util.world_func_in, func)
    end
end

-- Delayed execution task (global)
function i_util:DoTaskInTime(time, ...)
    return TheGlobalInstance:DoTaskInTime(time, ...)
end
-- Cycle execution task (global)
-- Compared to the original, this task will be called once immediately
function i_util:DoPeriodicTask(time, func)
    func()
    return TheGlobalInstance:DoPeriodicTask(time, func)
end

-- Right-click (have been screened partially)
-- pc, player, down, act_right, ent_mouse
-- When returning to true, the original action will be canceled
function i_util:AddRightClickFunc(func)
    if type(func) == "function" then
        table.insert(i_util.rightclick_func, func)
    end
end
-- Left -click
-- pc, player, down, act_left, ent_mouse
function i_util:AddLeftClickFunc(func)
    if type(func) == "function" then
        table.insert(i_util.leftclick_func, func)
    end
end
-- Tap
-- hud, x, y
function i_util:AddMiddleClickFunc(func)
    if type(func) == "function" then
        table.insert(i_util.midclick_func, func)
    end
end

-- Mouse moves to the entity (this is synchronous text, if you want to use events in real time
-- If the first return value is valid, the string will be replaced. the second valid is the function executed when the mouse is moved.
-- str, player, item_inv, item_world
function i_util:AddHoverOverFunc(func)
    if type(func) == "function" then
        table.insert(i_util.hoverer_func_in, func)
    end
end

-- This method must be used in the addplayractivatedfunc!otherwise, changing the role will fail!
-- Open cave rpc monitoring, if you return true, cancel the original return
-- rpc, ...
function i_util:AddServerRPCFunc(func)
    if type(func) == "function" then
        table.insert(i_util.server_rpc_func, func)
    end
end
-- This method must be used in the addplayractivatedfunc!otherwise, changing the role will fail!
-- Guandong cave locomotor monitoring
-- buffact, run, try_instant
function i_util:AddPushActionFunc(func)
    if type(func) == "function" then
        table.insert(i_util.ltor_push_func, func)
    end
end

-- Prefabs = {}, the prefab table listened
-- Id, it will automatically add to item as an index to store its data
-- Info = 'the default data when getting new items' -prive data by changing this variable
-- Time = the data is effective time
-- This method will store the data of prefabs
function i_util:AddPrefabsHook(data)
    if type(data) == "table" then
        if data.prefabs and data.id and data.time then
            table.insert(i_util.prefabs_hook_end, data)
        end
    end
end

-- Prefab is bound to be provided, there is no need to judge
-- Prepare to eat
-- prefab, food
function i_util:AddFoodActivatedFunc(func)
    if type(func) == "function" then
        table.insert(i_util.food_func_in, func)
    end
end
-- Eat
-- prefab, food
function i_util:AddFoodDeactivatedFunc(func)
    if type(func) == "function" then
        table.insert(i_util.food_func_out, func)
    end
end

-- Loading layout files
function i_util:LoadLayout(path)
    if kleifileexists("scripts/" .. path .. ".lua") then
        local data = require("map/static_layout").Get(path)
        return data.ground and data
    end
end

-- Development and testing
-- i_util:ShowPath("map/static_layouts/abandonedwarf")
function i_util:ShowLData(ldata)
    local room_grounds, ground_types, room_layout = ldata.ground, ldata.ground_types, ldata.layout
    t_util:Pairs(room_grounds, function(_, room_line)
        local str = ""
        t_util:Pairs(room_line, function(_, tiledata)
            local tile = ground_types[tiledata]
            if tile then
                str = str .. tile .. ","
            else
                str = str .. "0" .. ","
            end
        end)
        -- str = str .. "\n"
        print(str)
    end)
end

function i_util:ShowPath(path)
    local ldata = self:LoadLayout(path)
    self:ShowLData(ldata)
end

-- i_util:ShowDefi("MonkeyIsland")
-- w_util:GetDefiResult("ResurrectionStone")
function i_util:ShowDefi(name)
    local ol = require("map/object_layout")
    local ldata = ol.LayoutForDefinition(name)
    self:ShowLData(ldata)
end

return i_util
