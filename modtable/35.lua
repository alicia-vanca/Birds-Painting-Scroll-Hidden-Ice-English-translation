-- Reserve
local max_hop_dist = 6.5
local function GetMaxHopPos(player, pos)
    return c_util:GetIntersectPotRadiusPot(player:GetPosition(), max_hop_dist, pos or TheInput:GetWorldPosition())
end

local point, task
local function func(prefab)
    return table.contains({"spear_wathgrithr_lightning_charged", "spear_wathgrithr_lightning"}, prefab)
end
i_util:AddPlayerActivatedFunc(function(player, world, pusher)
    if player.prefab ~= "wathgrithr" then return end
    pusher:RegEquip(function(slot, equip)
        if func(equip.prefab) then
            if not task then
                task = player:DoPeriodicTask(FRAMES, function(player)
                    if e_util:IsValid(point) then
                        local pos = GetMaxHopPos(player)
                        point.Transform:SetPosition(pos.x, 0, pos.z)
                        local aoe = t_util:GetRecur(equip, "components.aoetargeting")
                        if e_util:InValidPos(point) and aoe and aoe:IsEnabled() then
                            point.AnimState:SetMultColour(0, 1, 0, 1)
                            point.aoe = true
                        else
                            point.AnimState:SetMultColour(1, 0, 0, 1)
                            point.aoe = false
                        end
                    else
                        -- point = player:SpawnChild("reticule")
                        point = SpawnPrefab("reticule")
                        e_util:SetHighlight(point, true)
                    end
                end)
            end
        end
    end)
    pusher:RegUnequip(function(slot, equip)
        if func(equip.prefab) then
            if task then
                point:Remove()
                point = nil
                task:Cancel()
                task = nil
            end
        end
    end)
end)


i_util:AddMiddleClickFunc(function(self)
    if e_util:InValidPos(point) then
        local pos = point:GetPosition()
        local hand = p_util:GetEquip("hands") or {}
        if func(hand.prefab) and point.aoe then
            p_util:DoAction(BufferedAction(ThePlayer, nil, ACTIONS.CASTAOE, hand, pos, nil, max_hop_dist), RPC.LeftClick, ACTIONS.CASTAOE.code, pos.x, pos.z)
        end
    end
end)