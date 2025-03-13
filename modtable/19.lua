if m_util:IsServer() then
    return
end
local save_id, string_warning = "sw_wildfires", "Wildfire"
local default_data = {
    sw = "All"
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local data_warn = {"Off", "All", "Self-ignition only"}
AddPrefabPostInit("smoke_plant", function(inst)
    if save_data.sw == "Off" then
        return
    end
    inst:DoTaskInTime(0.1, function(inst)
        local ent = e_util:FindEnt(inst, nil, 0.0001, nil, {'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player'}, nil, nil,
            function(ent)
                return ent:HasTag("smolder")
            end)
        if not ent then
            return
        end
        if e_util:FindEnt(ent, "firesuppressor", TUNING.FIRE_DETECTOR_RANGE or 15, nil,
            {'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player', 'fueldepleted'}, nil, {"idle_off"}) then
            return
        end
        local name = e_util:GetPrefabName(ent.prefab)
        if not (name and TheWorld and TheWorld.state) then
            return
        end
        local threshold = TUNING.WILDFIRE_THRESHOLD or 80
        local content = " ignited!"
        local iswild
        if TheWorld.state.issummer and TheWorld.state.isday and type(TheWorld.state.temperature) == "number" and
            TheWorld.state.temperature >= threshold then
            content = " Spontaneous combustion!"
            iswild = true
        end
        if save_data.sw == "All" or (save_data.sw == "Self-ignition only" and iswild) then
            u_util:Say(string_warning, name..content, "self", "Red")
        end
    end)
end)

local fn = m_util:AddBindShowScreen({
    title = string_warning,
    id = "hx_" .. save_id,
    data = {
        {
            id = "sw",
            label = "Prompt type:",
            fn = fn_save("sw"),
            hover = "Target type of wild fire warning",
            default = fn_get,
            type = "radio",
            data = t_util:IPairToIPair(data_warn, function(i)
                return {data = i, description = i}
            end)
        }
    }
})
m_util:AddBindConf(save_id, fn, nil,
    {string_warning, "firestaff_flamelash", STRINGS.LMB .. "Advanced settings", true, fn, nil, -9996})
