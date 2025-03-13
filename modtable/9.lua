local fov_min, fov_max = 20, 179
local isbigger = m_util:IsTurnOn("c_init") or m_util:IsHuxi()

local function c_fov(delta)
    local fov = TheCamera.fov + delta
    fov = fov < fov_min and fov_min or fov
    fov = fov > fov_max and fov_max or fov
    TheCamera.fov = fov
    u_util:Say("FOV", fov, "head", nil, true)
end


m_util:AddBindConf("c_add", function ()
    c_fov(1)
end, true)
m_util:AddBindConf("c_minus", function ()
    c_fov(-1)
end, true)
m_util:AddBindConf("c_hidehud", function()
    if ThePlayer.HUD:IsVisible()then
        ThePlayer.HUD:Hide()
        ThePlayer.HUD.under_root:Hide()
        u_util:Say("Screenshot mode", "Hidden hud", "head", "Thistle color", true)
    else
        ThePlayer.HUD:Show()
        ThePlayer.HUD.under_root:Show() -- Direction indication adaptation
        u_util:Say("Screenshot mode", "Display hud", "head", "Thistle color", true)
    end
end)
m_util:AddBindConf("c_hideself", function()
    if ThePlayer.entity:IsVisible()then
        ThePlayer:Hide()
        ThePlayer.DynamicShadow:Enable(false)
        u_util:Say("Screenshot mode", "Hidden player", "head", "Thistle color", true)
    else
        ThePlayer:Show()
        ThePlayer.DynamicShadow:Enable(true)
        u_util:Say("Screenshot mode", "Display player", "head", "Thistle color", true)
    end
end)
local c_follow_ent, null_target
m_util:AddBindConf("c_track", function ()
    local ent = TheInput:GetWorldEntityUnderMouse()
    if e_util:IsValid(ent) then
    else
        local pos = TheInput:GetWorldPosition()
        if not null_target then
            null_target = e_util:SpawnNull()
            null_target.entity:AddTransform()
        end
        null_target.Transform:SetPosition(pos:Get())
        null_target.name = tostring(pos)
        ent = null_target
    end
    TheCamera:SetTarget(ent)
    c_follow_ent = ent
    u_util:Say("Perspective", ent.name, "self", "Thistle color", true)
end)
m_util:AddBindConf("c_back", function ()
    if TheCamera.target ~= ThePlayer then
        TheCamera:SetTarget(ThePlayer)
        u_util:Say("Perspective", ThePlayer.name, "self", "Thistle color", true)
    elseif c_follow_ent then
        if c_follow_ent == null_target then
            TheCamera:SetTarget(c_follow_ent)
            u_util:Say("Tracking position", c_follow_ent:GetPosition(), "self", "Thistle color", true)
        elseif e_util:IsValid(c_follow_ent) then
            TheCamera:SetTarget(c_follow_ent)
            u_util:Say("Perspective", c_follow_ent.name, "self", "Thistle color", true)
        else
            u_util:Say("Perspective", "Target invalid", "self", "Red", true)
        end
    end
end)

-- Small steps. minimal distance. the maximum distance. the minimum leaning distance. the maximum leaning distance, the current distance, the target distance
local argu = {"zoomstep","mindist","maxdist","mindistpitch","maxdistpitch","distance","distancetarget", "fov"}
-- Store the default data
local args_default = {}
-- Great perspective
local value_bigger_forest = {10, 10, 180, 30, 60, 80, 80, 35}
local value_bigger_cave = {10, 10, 180, 25, 40, 80, 80, 35}
-- Look down
local value_overlook = {10, 10, 180, 90, 90, 80, 80, 35}
-- Eagle eye
local value_eagle = {10, 10, 180, 90, 90, 80, 80, 165}

local function SetView(vt)
    if not TheCamera then return end
    if vt == args_default then
        t_util:Pairs(vt, function (k, v)
            if k == "distance" then
                if TheCamera.distancetarget then
                    TheCamera[k] = TheCamera.distancetarget
                end
            else
                TheCamera[k] = v
            end
        end)
        return
    end
    for k,v in ipairs(argu)do
        TheCamera[v] = vt[k]
    end
end

AddClassPostConstruct('cameras/followcamera', function (self)
    local _Update = self.Update
    self.Update = function (...)
        if self.target then
            local x, y, z = self.target.Transform:GetWorldPosition()
            if not (x and y and z) then
                self:SetTarget(ThePlayer)
            end
        else
            self:SetTarget(ThePlayer)
        end
        return _Update(...)
    end

    local _SetDefault = self.SetDefault
    self.SetDefault = function (...)
        local ret = _SetDefault(...)
        t_util:IPairs(argu, function (id)
            local value = self[id]
            if type(value) == "number" then
                args_default[id] = value
            end
        end)
        if isbigger then
            if TheWorld then
                if TheWorld:HasTag("cave") then
                    SetView(value_bigger_cave)
                else
                    SetView(value_bigger_forest)
                end
            end
        end
        return ret
    end
end)

local hanzify = {"Default", "Great perspective", "Look down", "Eagle eye"}
local loca_mode = isbigger and 2 or 1
local change_mode = m_util:IsTurnOn("change_mode") or 1
local modetable = {
    {1,2,3},
    {1,2},
    {1,3},
    {2,3},
}

local function SetMode(mode)
    if not TheWorld then return end
    if mode ~= 4 then
        u_util:Say(hanzify[mode])
    end
    if ThePlayer._hx_label then
        ThePlayer._hx_label:Kill()
        ThePlayer._hx_label = nil
    end
    if mode == 1 then
        SetView(args_default)
    elseif mode == 2 then
        if TheWorld:HasTag("cave") then
            SetView(value_bigger_cave)
        else
            SetView(value_bigger_forest)
        end
    elseif mode == 3 then
        SetView(value_overlook)
    elseif mode == 4 then
        h_util:CreateLabel(ThePlayer, hanzify[mode], {x=0, y=0})
        SetView(value_eagle)
    end
end

local function ChangeView(mt, mode)
    local st = mt[mode] or mt[1]
    loca_mode = st[t_util:GetNextLoopKey(st, t_util:GetElement(st, function (k, v)
        return v == loca_mode and k
    end))]
    SetMode(loca_mode)
end

m_util:AddBindConf("c_change", function ()
    ChangeView(modetable, change_mode)
end, true)

Mod_ShroomMilk.Func.ChangeMetaView = ChangeView