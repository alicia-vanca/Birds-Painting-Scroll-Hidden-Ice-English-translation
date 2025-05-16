if m_util:IsServer() then
    return
end

local animals = require "data/starfishes"
local hxname, hxprefab = "_starfish", "_hxprefab"


local save_id, string_show = "sw_starfish", "Ruin anenemy"
local default_data = {
    show = m_util:IsHuxi(),
    scale = 0.4
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local icons,hxnames = {}, {}
local radius = 1.24

local directions = {  
    {0, 1}, -- Upper    
    {1, 1}, -- Upper right  
    {1, 0}, -- Right   
    {-1, 1}, -- Lower right 
    {0, -1}, -- Lower  
    {-1, -1}, -- Lower left  
    {-1, 0}, -- Left 
    {1, -1}, -- Upper left 
}  

t_util:Pairs(animals, function(prefab, animal)
    AddPrefabPostInit(prefab, function(inst)
        inst:DoTaskInTime(0.5, function()
            if e_util:IsAnim(function(anim)
                return anim:match("idle") or anim:match("sleep")
            end, inst) then
                local pusher = m_util:GetPusher()
                if pusher then
                    pusher:RegNearStart(inst, function(x, z)
                        if not inst[hxname] then
                            local an = e_util:SpawnFx(hxname, animal.build, animal.bank, animal.anim, {0, 1, 0, 1}, save_data.scale)
                            if an then
                                inst[hxname] = an
                                an.Transform:SetPosition(x, 0, z)
                                table.insert(icons, an)
                                if not save_data.show then
                                    an:Hide()
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end)
end)


local function fn()
    local pusher = m_util:GetPusher()
    if not pusher then
        return
    end


    local prefab_star = "dug_trap_starfish"
    local star = p_util:GetItemFromAll(prefab_star, nil, nil, "mouse")
    
    local fx = e_util:FindEnt(nil, nil, nil, {"huxi", "fx"}, {}, nil, nil, function(ent)
        return ent.hxname == hxname
    end)
    if not (star and fx) then
        h_util:CreatePopupWithClose(string_show.." · hint",
                "Please move closer to the spawn point and bring a starfish before trying this function")
        return u_util:Say("No starfish or spawn point mark")
    end

    local SetGeoCTRL = Mod_ShroomMilk.Func.SetGeoCTRL
    if SetGeoCTRL then
        SetGeoCTRL(not TheInput:IsKeyDown(KEY_CTRL))
    else
        u_util:Say("Unable to determine whether geometry is enabled. It is recommended to disable geometry manually or use the geometry of the painting mod")
    end

    pusher:RegNowTask(function(player, pc)
        if d_util:TakeActiveItem(star) then
            u_util:Say("Can't pick up starfish")
        else
            local item_active = p_util:GetActiveItem()
            local invitem = t_util:GetRecur(item_active, "replica.inventoryitem")
            if invitem then
                local pos_fx = fx:GetPosition()
                local xp, _, yp = pos_fx:Get()
                local pos = t_util:IGetElement(directions, function(dir)
                    local x, y = xp + dir[1], yp + dir[2]
                    local pos_new = c_util:GetIntersectPotRadiusPot(pos_fx, radius, Vector3(x, 0, y))
                    return invitem:CanDeploy(pos_new, nil, player) and pos_new
                end)
                if pos then
                    p_util:Click(pos, true)
                else
                    u_util:Say("The spawn point cannot be placed, please clean up the surroundings")
                end
            else
                u_util:Say("Function is abnormal, please contact the developer to repair")
            end
        end
        return true
    end)
end

local screen_data = {
    {
        id = "readme",
        label = "󰀍󰀍󰀍󰀍",
        fn = function()
            h_util:CreatePopupWithClose("󰀍"..string_show.." · special thanks",
                "This feature is specially customized by player Moonlight\n\nMessage: I hope everyone can meet the one who can accompany you to play Don't Starve for a long time~")
        end,
        hover = "Thank you very much",
        default = true
    },{
        id = "show",
        label = "Respawn point display",
        hover = "Whether to display respawn points by default",
        default = fn_get,
        fn = function(show)
            fn_save("show")(show)
            t_util:IPairs(icons, function(an)
                if an:IsValid() then
                    if show then
                        an:Show()
                    else
                        an:Hide()
                    end
                end
            end)
        end,
    },{
        id = "scale",
        label = "Tag size:",
        hover = "Refresh the size of the mark",
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(0.1, 2, 0.05, function(i)
            return {data = i, description = i}
        end),
        fn = function(scale)
            fn_save("scale")(scale)
            t_util:IPairs(icons, function(an)
                if an:IsValid() then
                    an.AnimState:SetScale(scale, scale, scale)
                end
            end)
        end
    }
}


local func_right = m_util:AddBindShowScreen({
    title = string_show,
    id = "hx_" .. save_id,
    data = screen_data,
})


m_util:AddBindConf(save_id, fn, nil,
    {string_show, "dug_trap_starfish", STRINGS.LMB .. "Planting a starfish" .. STRINGS.RMB .. "Advanced settings", true, fn,
     func_right, 7991})
