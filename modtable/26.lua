local function fn() TheNet:SendSlashCmdToServer("rescue") end
m_util:AddBindConf("sw_rescue", fn, true, {"Send rescue", "atrium_key", "After pressing, send /rescue or /help", true, fn, nil, 7995})