local t_util = {}

-- Get the first items of the container items
function t_util:GetMinValue(t)
    if type(t) ~= "table" then
        return
    end
    local min,_ = next(t)
    if min then
        for num,_ in pairs(t)do
            min = num < min and num or min
        end
        return t[min]
    end
end

-- The list of each is json to map according to id
function t_util:MapAndArrayFromJsonList(t)
    local map,array = {},{}
    for _,line in pairs(t) do
        local re, data = xpcall(
            function() return json.decode(line) end, 
            function() end
        )
        if re then
            local key = data.id
            if key then
                map[key] = t_util:MergeMap(data)
                map[key].id = nil
            else
                table.insert(array, data)
            end
        end
    end
    return map,array
end


-- List to map according to id
function t_util:MapFromList(t, num)
    local m = {}
    for i, data in ipairs(t)do
        if type(num)=="number" and i > num then
            break
        end
        local key = data.id
        m[key] = self:MergeMap(data)
        m[key].id = nil
    end
    return m
end

-- Merceable multiple map, or for deep copy
function t_util:MergeMap(...)
    local m = {}
    for _, map in ipairs({...})do
        for key, value in pairs(map)do
            m[key] = value
        end
    end
    return m
end
function t_util:MergeList(...)
    local mTable = {}
    for _, v in ipairs({...}) do
        if type(v) == "table" then
            for _, k in pairs(v) do
                table.insert(mTable, k)
            end
        end
    end
    return mTable
end
-- Copy the data from table t2 to t1
function t_util:EasyCopy(t1, t2)
    t_util:Pairs(t2, function(k, v)
        if type(v) == "table" then
            if not t1[k] then
                t1[k] = {}
            end
            self:EasyCopy(t1[k], v)
        else
            t1[k] = v
        end
    end)
end

function t_util:GetChild(parent, childname)
    if type(parent) == "table" and type(parent.children) == "table" then
        for w in pairs(parent.children)do
            if tostring(w) == childname then
                return w
            end
        end
    end
end


function t_util:GetNextLoopKey(t, key, reverse)
    local _t = self:PairToIPair(t, function(k)
        return k
    end)
    table.sort(_t, function(a, b)
        if reverse then
            return a > b
        else
            return a < b
        end
    end)
    local num = 0
    for k,v in ipairs(_t)do
        if v == key then
            num = k
            break
        end
    end
    num = num+1> #_t and 1 or num+1
    return _t[num]
end

-- Return to the processing value of a certain element that meets conditions
function t_util:GetElement(t, func)
    for k,v in pairs(t)do
        local result = func(k,v)
        if result then return result end
    end
end

function t_util:IGetElement(t, func)
    for _,v in ipairs(t)do
        local result = func(v)
        if result then return result end
    end
end

function t_util:Pairs(t, func)
    for k,v in pairs(t)do
        func(k,v)
    end
end
function t_util:IPairs(t, func)
    for _,v in ipairs(t)do
        func(v)
    end
end
function t_util:SortIPair(t)
    table.sort(t, function (a, b)
        return (type(a.priority)=="number" and a.priority or 0) > (type(b.priority)=="number" and b.priority or 0)
    end)
end
function t_util:NumElement(num, t, func)
    for i = 1, num do
        local result = func(i, t[i])
        if result then return result end
    end
end

function t_util:NumIElement(num, func)
    for i = 1, num do
        local result = func(i)
        if result then return result end
    end
end

function t_util:PairToIPair(t, func)
    local _t = {}
    self:Pairs(t, function(k,v)
        local re = func(k, v)
        if re then
            table.insert(_t, re)
        end
    end)
    return _t
end
function t_util:IPairToPair(t, func)
    local _t = {}
    self:IPairs(t, function(v)
        local key, value = func(v)
        if key then
            _t[key] = value
        end
    end)
    return _t
end
function t_util:IPairToIPair(t, func)
    local _t = {}
    self:IPairs(t, function(v)
        table.insert(_t, func(v))
    end)
    return _t
end
function t_util:PairToPair(t, func)
    local _t = {}
    self:Pairs(t, function(k, v)
        local key, value = func(k, v)
        if key then
            _t[key] = value
        end
    end)
    return _t
end

function t_util:PairFilter(t, func)
    local _t = {}
    self:Pairs(t, function(k,v)
        local re = func(k, v)
        if re then
            _t[k]=re
        end
    end)
    return _t
end

function t_util:IPairFilter(t, func)
    local _t = {}
    self:IPairs(t, function(v)
        local re = func(v)
        if re then
            table.insert(_t, re)
        end
    end)
    return _t
end

function t_util:BuildNumInsert(first, last, skip, func)
    local t = {}
    skip = skip or 1
    for i = first, last, skip do
        local ret = func(i)
        if ret then
            table.insert(t, ret)
        end
    end
    return t
end

function t_util:Add(t, element)
    if not self:GetElement(t, function(_, ele)
        return ele == element
    end) then
        table.insert(t, element)
    end
end
function t_util:Sub(t, element)
    for i = #t, 1, -1 do
        if t[i] == element then
            table.remove(t, i)
            return i
        end
    end
end

local test_count = 0
function t_util:FEP(t, tp)
    if type(t) ~= "table" then
        print("This is not a table, data type:",type(t), "Print directly:",t)
    else      
        print("********************", test_count, "***************************") 
        local count = 0   
        for k, v in pairs(t) do
            if not tp or type(v) == tp then
                count = count+1
                print(k, v)
            end
        end
        print("********************FEP", count, "Finish*********************")
        test_count = test_count + 1
    end
end
-- Equivalent to table.count
function t_util:GetSize(t)
    local i = 0
    for _ in pairs(t)do
        i=i+1
    end
    return i
end

function t_util:GetMaxNumSize(t)
    local num = 0
    for k,v in pairs(t)do
        local n = tonumber(k)
        if n and n > num then
            num = n
        end
    end
    return num
end

function t_util:GetRandomItem(t)
    if type(t) ~= "table" then
        return 1, t
    end
    local size = self:GetSize(t)
    if size == 0 then return end
    local r = math.random(size)
    local i = 1
    for k,v in pairs(t)do
        if i == r then
            return k,v
        end
        i=i+1
    end
end
-- Get recursive element
function t_util:GetRecur(t, ipt)
    if type(t) ~= "table"then
        return
    end
    local tp = type(ipt)
    if tp == "table" then
        local pt = t
        local function getrecur(num)
            if num > #ipt then
                return pt
            end
            pt = pt[ipt[num]]
            if pt then
                return getrecur(num+1)
            end
        end
        return getrecur(1)
    elseif tp == "string" then
        local ret = {}
        for w in ipt:gmatch("[^%.]+") do
            table.insert(ret, w)
        end
        return t_util:GetRecur(t, ret)
    end
end

function t_util:GetMetaIndex(t)
    return getmetatable(t).__index
end


-- Provide to developers
function t_util:JoinDebug(t, id)
    t_util[id] = t
end


return t_util