-- Mainboard mainboard

-- Note breathing
-- Because there is a problem with the underlying design, huxiwindow must first be at huxiicon require
local HWindow = require "widgets/huxi/huxi_window"
local HIcon = require "widgets/huxi/huxi_icon"

local function BuildIcon(self)
    if self.mboard then self.mboard:Kill() end
    self.mboard = self:AddChild(HWindow())
    if self.hicon then self.hicon:Kill() end
    self.hicon = self:AddChild(HIcon())
end

AddClassPostConstruct("widgets/controls", BuildIcon)

if m_util:IsHuxi() then
    AddClassPostConstruct("screens/redux/multiplayermainscreen", BuildIcon)
end

m_util:AddBindConf("sw_mainboard", h_util.CtrlBoard)
local function getIcon()
    return h_util:GetControls().hicon or h_util:GetActiveScreen().hicon
end
local function func_r()
    local icon = getIcon()
    if icon then
        icon:GetResetFn()()
    end
end
local function func_l()
    local icon = getIcon()
    if icon then
        icon:GetSettingFn()()
    end
end
local xml, tex = h_util:GetRandomSkin(true)
m_util:AddBindIcon("General", { xml = xml, tex = tex }, STRINGS.LMB .. "Advanced settings" .. STRINGS.RMB .. "Reset the small icon", true, func_l, func_r, 99999)
m_util:AddBindIcon("Hotkeys", "butterflymuffin", "Modify the binding settings of the mod function", true, function()
    m_util:AddBindShowScreen({
        title = "Function binding",
        id = "funcsbind",
        data = m_util:LoadReBindData()
    })()
end, nil, 99998)
