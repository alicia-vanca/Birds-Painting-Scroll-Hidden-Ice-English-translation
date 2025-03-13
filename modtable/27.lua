m_util:AddBindConf("wendy_summonkey", function()
    if m_util:InGame() == "wendy" then
        local flower = p_util:GetItemFromAll("abigail_flower", nil, nil, "mouse")
        local act = p_util:GetAction("inv", "CASTSUMMON", true, flower)
        if act then
            p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act.action.code, flower)
        else
            local abigail = e_util:FindEnt(nil, "abigail", nil, nil, nil, nil, nil, function(ent)
                return e_util:GetLeaderTarget(ent) == ThePlayer
            end)
            if abigail then
                act = p_util:GetAction("useitem", "CASTUNSUMMON", false, flower, abigail)
                if act then
                    p_util:DoAction(act, RPC.ControllerUseItemOnSceneFromInvTile, act.action.code, flower, abigail)
                end
            end
        end
    end
end)

m_util:AddBindConf("wendy_commandkey", function()
    if m_util:InGame() == "wendy" then
        local flower = p_util:GetItemFromAll("abigail_flower", nil, nil, "mouse")
        local act = p_util:GetAction("inv", "COMMUNEWITHSUMMONED", true, flower)
        if act then
            p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act.action.code, flower)
        end
    end
end)