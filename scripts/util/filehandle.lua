local t_util = require "util/tableutil"
local FileHandle = {}


function FileHandle:DataFromJsonLine(path)
    return self:FuckDataFromJsonList(self:LineTableFromFile(path))
end
local MAP_ID_PREFIX,List_ID_PREFIX,Line_ID_PREFIX = "m_","l_","s_"
local uid,id = "hx","id"

function FileHandle:GetPrefix()
    return MAP_ID_PREFIX, List_ID_PREFIX, Line_ID_PREFIX
end
-- The lists of various items are json to map or list based on huxi
function FileHandle:FuckDataFromJsonList(t)
    local data = { }
    for _,line_data in pairs(t or {})do
        local long_id = tostring(line_data[uid])
        if long_id then
            local start = string.sub(long_id, 1, 2)
            local finish = string.sub(long_id, 3)
            if finish ~= "" then
                if type(data[long_id])~="table" then
                    data[long_id] = {}
                end
                if start == MAP_ID_PREFIX then
                    local key = line_data[id]
                    if key then
                        data[long_id][key] = t_util:MergeMap(line_data)
                        data[long_id][key][id] = nil
                        data[long_id][key][uid] = nil
                    end
                elseif start == List_ID_PREFIX then
                    table.insert(data[long_id], line_data)
                elseif start == Line_ID_PREFIX then
                    line_data[uid] = nil
                    data[long_id] = line_data
                end
            end
        end
    end
    return data
end
-- The reversal of the above function is used for data storage
function FileHandle:FuckTableToDataFile(path, t)
    local data = {}
    for long_id,uid_data in pairs(t)do
        local start = string.sub(long_id, 1, 2)
        local finish = string.sub(long_id, 3)
        if finish ~= "" then
            if start == MAP_ID_PREFIX then
                for key, l in pairs(uid_data)do
                    if type(l) == "table" then
                        l[id] = key
                        l[uid] = long_id
                        table.insert(data, l)
                    end
                end
            elseif start == List_ID_PREFIX then
                for _, l in pairs(uid_data)do
                    if type(l) == "table" then
                        l[uid] = long_id
                        table.insert(data, l)
                    end
                end
            elseif start == Line_ID_PREFIX then
                uid_data[uid] = long_id
                table.insert(data, uid_data)
            end
        end
    end
    TheSim:SetPersistentString(path, DataDumper(data, nil, true), true)
end
function FileHandle:LineTableFromFile(path)
    local t, flag = {}
    TheSim:GetPersistentString(path, function(success, data)
        if success and string.len(data) > 0 then
			success, data = RunInSandbox(data)
			if success and data ~= nil then
                flag = true
				t = t_util:PairToIPair(data, function(_, line)
                    return line
                end)
			end
		end
    end)
    if not flag then
        print("LineTableFromFile", path, " error!")
    end
    return t
end



local log_path = "ShroomMilkFileSysLog.txt"
function FileHandle:LogAddFile(...)
    local str = table.concat({...}, " ")
    local data = self:LineTableFromFile(log_path)
    table.insert(data, os.date().."  "..str)
    TheSim:SetPersistentString(log_path, DataDumper(data, nil, true), true)
    print(str)
end

return FileHandle
