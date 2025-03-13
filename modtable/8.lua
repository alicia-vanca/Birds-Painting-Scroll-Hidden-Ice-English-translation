local cp = require "screens/cookbookpopupscreen"
local function fn()
    TheFrontEnd:PushScreen(cp(ThePlayer))
end
m_util:AddBindConf("sw_cookbook", fn, nil, {"Cookbook", "cookbook", "Menu", true, fn, nil, 7999})