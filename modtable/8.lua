local cp = require "screens/cookbookpopupscreen"
local function fn()
    TheFrontEnd:PushScreen(cp(ThePlayer))
end
m_util:AddBindConf("sw_cookbook", fn, nil, {"Cookbook", "cookbook", "Menu", true, fn, nil, 7999})

if not m_util:IsMilker() then return end
local Sb = require "screens/redux/scrapbookscreen"
local _PopulateInfoPanel = Sb.PopulateInfoPanel
Sb.PopulateInfoPanel = function(...)
    if ThePlayer then
        return _PopulateInfoPanel(...)
    else
        _G.ThePlayer = {userid = ""}
        local ret = _PopulateInfoPanel(...)
        _G.ThePlayer = nil
        return ret
    end
end

local _OnBecomeActive = Sb.OnBecomeActive
Sb.OnBecomeActive = function(...)
    if ThePlayer then
        return _OnBecomeActive(...)
    else
        _G.ThePlayer = {PushEvent = function() end}
        local ret = _OnBecomeActive(...)
        _G.ThePlayer = nil
        return ret
    end
end


-- ...existing code...
m_util:AddBindIcon("Scrapbook", {xml = HUD_ATLAS, tex = "tab_book.tex"}, "View Game Scrapbook", true, function()
    TheFrontEnd:PushScreen(Sb())
end, false, 7998)