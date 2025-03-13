local f_mana = require "util/filemanager"
local t_util = require "util/tableutil"
local m_util = require "util/modutil"

local wm_max = 50 -- Maximum archive quantity
local wm_count = wm_max*2
local save_path = "ShroomMilkWorlds.txt"
local path_prefix, path_tail = "Saver_", ".txt"


local w_mana = f_mana(save_path)
local WM = {}

-- Inco = {set = archive/player seed, id = archive serial number, time_entry = inlet time, time_play = play time}
-- Loading world record
function WM:LoadData()
    return w_mana:GetSettingList("list", true)
end

-- Store world record
function WM:SaveData()
    w_mana:Save()
end

-- Get the archive serial number according to the seeds
-- Cannew: whether the corresponding archive is new or covered with a archive serial number
function WM:GetSessionData(seed_player, cannew)
    local data_worlds = WM:LoadData()
    -- Find it first, have you been registered
    table.sort(data_worlds, function(a,b)
        local ta = type(a.id) == "number" and a.id or 0
        local tb = type(b.id) == "number" and b.id or 0
        return ta < tb
    end)
    local idea = t_util:IGetElement(data_worlds, function(data_world)
        return data_world.seed == seed_player and data_world.id and data_world
    end)
    if not idea and cannew then
        local count = #data_worlds
        if count < wm_count then
            -- New
            idea = { id = count + 1, seed = seed_player}
            table.insert(data_worlds, idea)
        else
            print("Bird Scroll: Your save file is full, please contact the developer to clean it up!")
            -- Overwrite
            local data_copy = t_util:MergeList(data_worlds)
            -- Reserve the recent play
            table.sort(data_copy, function(a, b)
                local ta = type(a.time_entry) == "number" and a.time_entry or 0
                local tb = type(b.time_entry) == "number" and b.time_entry or 0
                return ta > tb
            end)
            local list_last = {}
            for i = 1, wm_max do
                table.insert(list_last, data_copy[i])
            end
            -- Reserve the longest
            table.sort(data_copy, function(a, b)
                local ta = type(a.time_play) == "number" and a.time_play or 0
                local tb = type(b.time_play) == "number" and b.time_play or 0
                return ta > tb
            end)
            local list_long = {}
            for i = 1, wm_max do
                table.insert(list_long, data_copy[i])
            end
            -- See which id is not in the above
            local num
            for i = 1, wm_count do
                -- BYD major BUG!
                if not (t_util:IGetElement(list_last, function(data_world)
                    return data_world.id == i
                end) or t_util:IGetElement(list_long, function(data_world)
                    return data_world.id == i
                end)) then
                    num = i
                    break
                end
            end
            idea = data_worlds[num]
            if idea then
                -- Destroy the original data
                local data_handle = self:OpenID(idea.id)
                data_handle:Destroy()
                idea.seed = seed_player
                print("Assigning you a new archive：", num, "Seed serial number：", seed_player)
            else
                -- In theory, it is impossible to reach this step, but it still adds to the security of code security
                idea = { id = num, seed = seed_player}
                table.insert(data_worlds, idea)
                print("The archive module is abnormal! Please contact the developer!", num, seed_player)
            end
        end
    end
    m_util:print("Archive serial number：", idea.id, "Seed：", seed_player)
    return idea
end

-- Get the archive file name
function WM:GetFileName(file_id)
    if file_id then
        return path_prefix..file_id..path_tail
    end
end

-- Open the archive
function WM:OpenID(file_id)
    local file_path = self:GetFileName(file_id)
    if file_path then
        return f_mana(file_path)
    end
end


---------------------------- 面向开发者---------------------------
-- The interface here will not be deleted, but it is not recommended to use it for testing

-- Get the current archive seed
function WM:GetTheSeed()
    local world = TheWorld
    local shardstate = t_util:GetRecur(world, "net.components.shardstate")
    local seed_world = t_util:GetRecur(world, "meta.session_identifier") or "defaultworldseed"
    local seed_player = shardstate and shardstate:GetMasterSessionId() or seed_world 
    return seed_player
end

-- Get the archive serial number of the current world (saver is recommended)
function WM:GetTheID()
    local session = self:GetSessionData(self:GetTheSeed())
    return session and session.id
end

-- Get the current world archive name
function WM:GetTheFileName()
    return self:GetFileName(self:GetTheID())
end

return WM