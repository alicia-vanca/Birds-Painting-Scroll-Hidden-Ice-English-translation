AddClassPostConstruct("screens/redux/playersummaryscreen", function(self)
    local TEMPLATES = require "widgets/redux/templates"
	self.bottom_root:AddChild(TEMPLATES.StandardButton(function()
        if m_util:IsOffline() then
            return h_util:CreatePopupWithClose("Notice", "This feature is unavailable in offline mode.")
        end
        local screen = require("screens/huxi/skinqueue_plus")
        if screen then
            TheFrontEnd:PushScreen(screen())
        end
    end, "Duplicate skin info (new!)", {225, 40})):SetPosition(300, 10)
end)
