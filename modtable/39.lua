local pr = require "screens/plantregistrypopupscreen"
local function fn()
    TheFrontEnd:PushScreen(pr(ThePlayer))
end
m_util:AddBindConf("sw_planthant", fn, nil, {"Plant registry", "plantregistryhat", "Click to open Plant Registry", true, fn, nil, 7998})