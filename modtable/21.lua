if m_util:IsServer() then
    return
end
local save_id, string_build = "sw_shadowheart", "Create statue"

-- Hook last statue
local _DoRecipeClick = _G.DoRecipeClick
local last_cp = "chesspiece_knight_builder"
local last_skin -- In case kre and the statue of the statue is out later
_G.DoRecipeClick = function(owner, recipe, skin, ...)
    local str = recipe and recipe.product or ""
    if string.sub(str, 1, 11) == "chesspiece_" then
        last_cp = str
        last_skin = skin
    end
    return _DoRecipeClick(owner, recipe, skin, ...)
end
local stones = {"marble", "cutstone", "moonglass"}
local function Say(who, what, where, color)
    u_util:Say(who, what, where, color, true)
end
local function fn()
    local pusher = ThePlayer and ThePlayer.components.hx_pusher
    if not pusher then return end
    if pusher:GetNowTask() then
        pusher:StopNowTask()
        return
    end

    Say(string_build, "Start up")
    pusher:RegNowTask(function(player, pc)
        d_util:Wait()
        local item_heavy = p_util:GetItemFromAll(nil, "heavy", nil, "equip")
        if item_heavy then
            return p_util:DropItemFromInvTile(item_heavy)
        end
        local ent_sculp = e_util:FindEnt(nil, "sculptingtable", 40, nil,
            {'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player', 'fire', 'burnt'})
        local anim = ent_sculp and ent_sculp.AnimState
        if not anim then
            Say("No pottery wheel was found")
            return true
        end
        if not p_util:IsNear(ent_sculp) then
            p_util:Click(ent_sculp:GetPosition())
            return
        end
        local has_heavy = anim:GetSymbolOverride("swap_body")
        if has_heavy then
            -- I didn't expect me to collect it with the left button
            if p_util:GetActiveItem() then
                return p_util:ReturnActiveItem()
            end
            local act = p_util:GetAction("scene", "PICK", false, ent_sculp) or p_util:GetAction("scene", "PICK", true, ent_sculp)
            if act then
                return p_util:DoAction(act, RPC.ControllerActionButton, act.action.code, ent_sculp, true, false)
            else
                return m_util:print("Unable to collect")
            end
        end
        local has_stone = anim:GetSymbolOverride("cutstone01")
        if has_stone then
            if p_util:CanBuild(last_cp)then 
                return p_util:MakeSth(last_cp, last_skin)
            else
                Say(string_build, "Unable to continue making")
                return true
            end
        end
        local stone = p_util:GetItemFromAll(stones, nil, nil, "mouse")
        if stone then
            local act = p_util:GetAction("useitem", "GIVE", false, stone, ent_sculp) or p_util:GetAction("useitem", "GIVE", true, stone, ent_sculp)
            if act then
                if d_util:TakeActiveItem(stone) then
                    return p_util:DoAction(act, RPC.ControllerUseItemOnSceneFromInvTile, act.action.code, stone, ent_sculp)
                else
                    return p_util:DoAction(act, RPC.ControllerActionButton, act.action.code, ent_sculp, true, false)
                end
            else
                return m_util:print("Unable to give")
            end
        else
            stone = t_util:IGetElement(stones, function(stone)
                return p_util:CanBuild(stone) and stone
            end)
            if d_util:MakeItem(stone) then
                Say(string_build, "Unable to continue making")
                return true
            end
        end
    end, function()
        u_util:Say(string_build, "Finish")
    end)
end

m_util:AddBindConf(save_id, fn, nil,
    {string_build, "chesspiece_knight", STRINGS.LMB .. "Click to make a statue", true, fn, nil, 2999})
