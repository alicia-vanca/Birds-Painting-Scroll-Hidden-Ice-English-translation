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


local toys =
{
    "lost_toy_1",
    "lost_toy_2",
    "lost_toy_7",
    "lost_toy_10",
    "lost_toy_11",
    "lost_toy_14",
    "lost_toy_18",
    "lost_toy_19",
    "lost_toy_42",
    "lost_toy_43",
}
if m_util:IsTurnOn("sw_ghost") and m_util:IsTurnOn("sw_wendy") then
    t_util:IPairs(toys, function (prefab)
        AddPrefabPostInit(prefab, function (inst)
            inst:DoTaskInTime(1, function ()
                core_tasks[inst] = true
            end)
        end)
        apply(prefab, 'Thistle', 2, true)
    end)
end