-- Micon is just responsible for the ui display. the specific data interaction should be in the saver
-- Ui machine without emotion
-- Remember: don't clutter info, don't share the same info for hud and mapscreen!
-- Remember that you are an emotionless UI machine, don't just clutter it with whatever table you receive!
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local h_util, t_util, c_util = require "util/hudutil", require "util/tableutil", require "util/calcutil"

local HMap = Class(Widget, function(self, screen)
    Widget._ctor(self, "huxiMicon")

    self.screen_parent = screen
    self.parent_name  = screen and screen.name
    if self.parent_name == "MapScreen" then
        self.OnUpdate = function(self, ...)
            if self.setting.map_show then
                t_util:Pairs(self.icons, function(_, info)
                    self:SetMapImage(info)
                end)
                self.root:Show()
            else
                self.root:Hide()
            end
        end
    elseif self.parent_name == "HUD" then
        self.OnUpdate = function(self, ...)
            -- Fighting and viewing distance
            if TheCamera and TheCamera.mindistpitch == 90 and TheCamera.distance > 10 and self.setting.hud_show then
                t_util:Pairs(self.icons, function(_, info)
                    self:SetHUDImage(info)
                end)
                self.root:Show()
            else
                self.root:Hide()
            end
        end
    end
end)

local function UpdateImage(image, scale, x, z, rate)
    if not image then return end
    image:SetPosition(x, z)
    local w, h = image:GetSize()
    if w then
        image:SetScale(rate*30/w*(scale or 1))
    end
end

function HMap:SetHUDImage(info)
    local x, z = h_util:WorldPosToScreenPos(info.x, info.z)
    UpdateImage(info.IMG, info.scale, x, z, c_util:GetScaleValue(TheCamera.distance, 30, 180, self.setting.icon_size*0.15, 0.02))
end

function HMap:SetMapImage(info)
    local x, z = h_util:WorldPosToMinimapPos(info.x, info.z)
    UpdateImage(info.IMG, info.scale, x, z, c_util:GetScaleValue(self.screen_parent.zoom_target, 1, 20, self.setting.icon_size*0.1, 0.02))
end

function HMap:BuildHMap(setting, data)
    self:StopUpdating()
    self.setting = setting or self.setting or {}
    self.data = data or self.data or {}
    if self.root then self.root:Kill() end
    self.root = self:AddChild(Widget("root"))
    self.icons = {}
    t_util:IPairs(self.data, function(info)
        self:AddHMap(info.id, info)
    end)
    self:StartUpdating()
end

function HMap:RemoveHMap(id)
    if id and self.icons[id] then
        self.icons[id].IMG:Kill()
        self.icons[id] = nil
    end 
end
-- It's not to remove the original icon, but the update
-- In fact, you can also remove the original icon, and then add's new icon. that method will be killed and creating resources. it is not recommended
-- info Required: x,z Optional: icon, scale
function HMap:ChanHMap(id_old, id_new, info)
    local icondata = self.icons[id_old]
    if icondata then
        self.icons[id_old] = nil
        self.icons[id_new] = t_util:MergeMap(info)
        self.icons[id_new].IMG = icondata.IMG
        -- Only update the icon, the position and scale will be updated automatically, nothing else will not be updated automatically
        if info.icon ~= icondata.icon then
            local xml, tex = h_util:GetPrefabAsset(info.icon)
            if xml then
                icondata.IMG:SetTexture(xml, tex)
            end
        end
    end
end

-- print(h_util:GetPrefabAsset("oasis"))
-- {icon, x, z, IMG, id, nothud, notmap}
function HMap:AddHMap(id, info)
    local xml, tex = h_util:GetPrefabAsset(info.icon)
    if xml then
        if info.nothud and self.parent_name == "HUD" then
            return
        elseif info.notmap and self.parent_name == "MapScreen" then
            return
        end
        self:RemoveHMap(id)
        self.icons[id] = t_util:MergeMap(info)
        self.icons[id].IMG = self.root:AddChild(Image(xml, tex))
    end
end




return HMap
