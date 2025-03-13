if m_util:IsServer() then return end

local save_id, string_say = "sw_autosort", "Sorting"
local default_data = {
    merge = true,   -- Similar merger
    delay = 2,      -- Timeout

    st_chest = true, -- Whether to sort the box
    st_bp = true,
    st_inv = true,

    pl_chest = false,
    pl_box = false,
}

-- local state, data_ingre = pcall(require, "TMIP/list/itemlist_material")
local data_ingre = require("data/itemlist_material")

local configdata = {
    ingre = {
        label = "Basic material",
        hover = "[T key console] the items in the [material] directory are calculated",
        pos = "inv",
        we = 2,
        func = function (item)
            local prefab = item.prefab
            return t_util:IGetElement(data_ingre, function (ingre)
                return prefab == ingre
            end)
        end
    },
    food = {
        label = "Food",
        hover = "All Right-click items are [eat]",
        pos = "bp",
        we = 2,
        func = function (item)
            return p_util:GetAction("inv", "eat", true, item)
        end
    },
    equip = {
        label = "Equipment", 
        hover = "All items that can be equipped",
        pos = "inv",
        we = -1,
        func = function (item)
            return e_util:GetItemEquipSlot(item)
        end
    },
    mod ={
        label = "Mod", 
        hover = "Not the content of the famine version",
        pos = "bp",
        we = -1,
        func = function (item)
            return m_util:IsModPrefab(item.prefab)
        end
    },
    cont = {
        label = "Box",
        hover = "A container that can install other items",
        pos = "inv",
        we = 1,
        func = function (item)
            return e_util:GetContainer(item)
        end
    },
    other = {
        label = "Besides",
        pos = "bp",
        we = 0,
        hover = "All items that are not in the above classification",
        func = function ()end
    }
}
local function GetWeID(id) return "we_"..id end
local function GetPlID(id) return "pos_"..id end
local cates_we = t_util:PairToIPair(configdata, function (id)return id end)
t_util:Pairs(configdata, function (id, data)
    default_data[GetWeID(id)] = data.we
    default_data[GetPlID(id)] = data.pos
end)
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local function fn_merge(slots_data)
    slots_data = slots_data or {}
    local slots_len = #slots_data
    if slots_len == 0 then return true end
    for i, slot_data in ipairs(slots_data) do
        local item = slot_data.item
        local size_max, size_stack = e_util:GetMaxSize(item), e_util:GetStackSize(item)
        if size_stack < size_max then
            local item_active = p_util:GetActiveItem()
            if item_active and item_active.prefab == item.prefab then
                if d_util:PutActiveItemInSlot(slot_data.cont, slot_data.slot, FRAMES, save_data.delay) then
                    u_util:Say(string_say, "Put item "..item_active.name.." Time out", nil, "Red", true)
                    return true
                end
                return
            else
                for j = i+1, slots_len do
                    local item_get = slots_data[j].item
                    if item_get.prefab == item.prefab then
                        if d_util:TakeActiveItem(item_get, FRAMES, save_data.delay) then
                            u_util:Say(string_say, "Pick up the item "..item_get.name.." Time out", nil, "Red", true)
                            return true
                        end
                        return
                    end
                end
            end
        end
        if i >= slots_len then
            return true
        end
    end
end

local function GetSlotsData(order)
    return p_util:GetSlotsFromAll(nil, nil, function(_, cont)
        local buildname = cont.AnimState and cont.AnimState:GetBuild()
        return not cont:HasTag("structure") or (not buildname or not buildname:match("_upgraded_"))
    end, order) or {}
end

_G.TB = GetSlotsData

local function fn_tidy()
    local Cates = {}
    t_util:IPairs(cates_we, function(cate)
        Cates[cate] = {}
    end)
    -- Sorted according to different categories according to weight
    table.sort(cates_we, function (a, b)
        return (save_data[GetWeID(a)] or 0) > (save_data[GetWeID(b)] or 0)
    end)
    -- No items on the mouse
    d_util:ReturnActiveItem(FRAMES, save_data.delay)
    -- Divide the items into different categories
    local data_slots = GetSlotsData({"body", "backpack","container"})
    local function AddCatesData(data_slot)
        if not data_slot then return end
        local item = data_slot.item
        local cate = t_util:IGetElement(cates_we, function(cate)
            return configdata[cate].func(item) and cate
        end) or "other"
        table.insert(Cates[cate], data_slot)
    end
    -- Source
    t_util:IPairs(data_slots, function(data_slot)
        if data_slot.cont == ThePlayer then
            AddCatesData(save_data.st_inv and data_slot)
        elseif data_slot.cont:HasTag("backpack") then
            AddCatesData(save_data.st_bp and data_slot)
        else
            AddCatesData(save_data.st_chest and data_slot)
        end
    end)
    -- Start placing items for different categories
    local backpack = p_util:GetBackpack()
    local data_put = {}
    local function PlanPut(data_slot, weigh, cont)
        local container = e_util:GetContainer(cont)
        local capacity = container and container:GetNumSlots() or 0
        if capacity == 0 then return data_slot end
        if not data_put[cont] then
            data_put[cont] = {}
        end

        local data_put_cont = data_put[cont]
        
        -- The first empty position and the last empty position
        local nullpos_pre, nullpos_last
        local itemcount = 0
        for pos = 1, capacity do
            if data_put_cont[pos] then
                itemcount = itemcount + 1
            else
                if not nullpos_pre then
                    nullpos_pre = pos
                end
                nullpos_last = pos
            end
        end
        local slot = weigh<0 and nullpos_last or nullpos_pre
        -- If the container is full or there is no room for it, don't put it in
        if itemcount < capacity and container:CanTakeItemInSlot(data_slot.item, slot) then
            -- If the weight is negative, put it at the end, otherwise put it at the front
            -- m_util:print("Place", data_slot.item.name, cont, slot)
            data_put_cont[slot] = data_slot
        else
            return data_slot
        end
    end
    local error_slot = t_util:IGetElement(cates_we, function(cate)
        table.sort(Cates[cate], function(data_a, data_b)
            local ia, ib = data_a.item, data_b.item
            return ia.prefab > ib.prefab
        end)

        -- Item
        return t_util:IGetElement(Cates[cate], function(data_slot)
            local we_cate = save_data[GetWeID(cate)] or 0
            if data_slot.cont == ThePlayer or data_slot.cont==backpack then
                local pos_cate = save_data[GetPlID(cate)]
                -- m_util:print(data_slot.item.name, pos_cate)
                -- Backpack or item bar as a container
                -- Pos_cate == 1 is to compatible with old versions of players, inv is to increase readability
                if pos_cate == "inv" or pos_cate == 1 then
                    return PlanPut(data_slot, we_cate, save_data.st_inv and ThePlayer) and PlanPut(data_slot, we_cate, save_data.st_bp and backpack)
                else
                    return PlanPut(data_slot, we_cate, save_data.st_bp and backpack) and PlanPut(data_slot, we_cate, save_data.st_inv and ThePlayer)
                end
            else
                return PlanPut(data_slot, we_cate, save_data.st_chest and data_slot.cont)
            end
        end)
    end)
    if error_slot then
        u_util:Say(string_say, "Sorting item "..error_slot.item.name.." Fail", nil, "Red", true)
    else
        local result =  t_util:GetElement(data_put, function(cont, data_put_cont)
            return t_util:GetElement(data_put_cont, function(slot, data_slot)
                -- Getele is repeatedly executed until the end or return true
                return d_util:MoveItemInSlot(data_slot.item, cont, slot, FRAMES, save_data.delay) and data_slot
            end)
        end)
        if result then
            u_util:Say(string_say, "Migrant "..result.item.name.." Time out", nil, "Red", true)
        else
            u_util:Say(string_say, "Complete completion", nil, nil, true)
        end
    end
    return true
end

local function fn_sort()
    local pusher = m_util:GetPusher()
    if not pusher then return end
    local lock_merge_bb, lock_merge_cont         -- The writing here is more complicated. the role of the two locks is to prevent repetitive mergers
    pusher:RegNowTask(function()
        -- Merge stack
        if save_data.merge and not lock_merge_bb then
            if lock_merge_cont then
                lock_merge_bb = fn_merge(GetSlotsData({"body", "backpack"}))
            else
                lock_merge_cont = fn_merge(GetSlotsData({"container"}))
            end
        else
            return fn_tidy()
        end
        d_util:Wait(FRAMES)
    end, function()
        -- M_util: print ('organization')
    end, "mouse")
end



local screendata_fix = {
    {
        id = "merge",
        label = "Merge stack",
        fn = fn_save("merge"),
        hover = "Whether to stack it up first to reach the upper limit item",
        default = fn_get,
    },
    {
        id = "st_inv",
        label = "Sort inventory",
        fn = fn_save("st_inv"),
        hover = "Whether to sort out the items of the item bar",
        default = fn_get,
    },
    {
        id = "st_bp",
        label = "Sort backpack",
        fn = fn_save("st_bp"),
        hover = "Whether to sort out the items in the backpack",
        default = fn_get,
    },
    {
        id = "st_chest",
        label = "Sort chest",
        fn = fn_save("st_chest"),
        hover = "Whether to automatically organize the box",
        default = fn_get,
    },{
        id = "delay",
        label = "Maximum delay:",
        fn = fn_save("delay"),
        hover = "The movement exceeds this time as the finishing failure",
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(1, 20, 1, function(i)
            return {data = i*0.5, description = (i*0.5).." sec(s)"}
        end)
    }
}
local to_20 = t_util:BuildNumInsert(-20, 20, 1, function (i)
    local str
    if i > 0.5 or i < -0.5 then
        if i > 0 then
            str = "+ "..i
        else
            str = "- "..(-i)
        end
    else
        i = 0
        str = "No weight"
    end
    return {data = i, description = str}
end)
local function AddPos(id, label, hover)
    return {
        id = id,
        label = label.."：",
        fn = fn_save(id),
        hover = hover,
        default = fn_get,
        type = "radio",
        data = {
            {data = "inv", description = "Priority"},
            {data = "bp", description = "Prioritize backpack"},
        }
    }
end
local function AddWe(id)
    return {
        id = id,
        label = "Weight:",
        fn = fn_save(id),
        hover = "The greater the items, the more the items are the previous \n negative weight will be placed at the end of the container!",
        default = fn_get,
        type = "radio",
        data = to_20,
    }
end
local screendata = {}
local function AddCate(id, ...)
    table.insert(screendata, AddPos(GetPlID(id), ...))
    table.insert(screendata, AddWe(GetWeID(id)))
end
t_util:IPairs({"ingre", "food", "equip", "mod", "cont", "other"}, function (cate)
    AddCate(cate, configdata[cate].label, configdata[cate].hover)
end)


m_util:AddBindConf(save_id, fn_sort)
m_util:AddBindIcon(string_say, "greenamulet", "Advanced settings for items", true, function()
    local idata = t_util:IGetElement(m_util:LoadReBindData(), function(idata)
        return idata.id == save_id..modname and idata
    end)
    if idata then
        idata = t_util:MergeMap(idata)
        idata.label = "Hotkey:"
        idata.hover = "Click to set the binding button"
    end
    m_util:AddBindShowScreen({
        title = "Item organization rules",
        id = save_id,
        data = t_util:MergeList({idata}, screendata_fix, screendata),
    })()
end, nil, 8000)
