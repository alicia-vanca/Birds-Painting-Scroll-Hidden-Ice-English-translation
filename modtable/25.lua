local save_id, string_skin = "sw_skinQueue", "Skin queue"
local QSkin = require "screens/huxi/skinqueue"
-- Require ('widgets/huxi/huxi_gift') ('playerportrait_bg_wardrobeyule') preview skin
local function fn()
    TheFrontEnd:PushScreen(QSkin())
end
AddClassPostConstruct("screens/redux/playersummaryscreen", function(self)
    local TEMPLATES = require "widgets/redux/templates"
	self.bottom_root:AddChild(TEMPLATES.StandardButton(fn, "Duplicate skin info", {225, 40})):SetPosition(300, 10)
end)
m_util:AddBindConf(save_id, fn, false, {string_skin, "weave_filter_on", STRINGS.LMB .. "Duplicate skin info", true, fn, nil, 5999})
