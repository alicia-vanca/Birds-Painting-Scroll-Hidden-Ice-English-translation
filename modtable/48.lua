if m_util:IsServer() then return end
local HxOne = require "widgets/huxi/hx_one"
local Show = true
i_util:AddPlayerActivatedFunc(function(player, world)
    local pusher = player.components.hx_pusher
    pusher:RegEquip(function(slot, equip)
        if not (equip and equip.prefab == "skeletonhat") then return end
        -- Display ui
        local head = t_util:GetRecur(player, "HUD.controls.inv.equip.head")
        local img = head and head.bgimage
        if not img then return end
        local size = img:GetScaledSize()
        if head.hx_one then
            head.hx_one:Kill()
        end
        Show = true
        head.hx_one = head:AddChild(HxOne("nightmarefuel", size, function(show)
            Show = show
        end))
        local _OnControl = head.OnControl
        head.OnControl = function(self, ...)
            return self.hx_one and self.hx_one.focus and self.hx_one:OnControl(...) or _OnControl(self, ...)
        end
    end)
    pusher:RegUnequip(function(slot, equip)
        if not (equip and equip.prefab == "skeletonhat") then return end
        -- Disable ui
        local UI = t_util:GetRecur(player, "HUD.controls.inv.equip.head.hx_one")
        if UI then
            UI:Kill()
            UI = nil
        end
        -- Show a monster
        Show = true
    end)
end)


local prefabs = {"crawlinghorror","terrorbeak","crawlingnightmare","nightmarebeak", "oceanhorror"}
t_util:IPairs(prefabs, function(prefab)
    AddPrefabPostInit(prefab, function(inst)
        inst:DoPeriodicTask(1, function(inst)
            if Show then
                inst:Show()
            else
                inst:Hide()
            end
        end)
    end)
end)