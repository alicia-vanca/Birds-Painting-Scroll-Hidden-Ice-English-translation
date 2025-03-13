-- Reserve
local function getbook()
    local book = p_util:GetItemFromAll("willow_ember", nil, nil, "mouse")
    local spell = t_util:GetRecur(book or {}, "components.spellbook")
    local hud = ThePlayer.HUD
    if not (spell and hud) then return end
    return book, spell, hud
end

-- Copy lao mai directly
local quick = m_util:IsTurnOn("wllw_quick")
for i = 1,5 do
    m_util:AddBindConf("wllw_bind"..i, function()
        if m_util:InGame() ~= "willow" then return end
        local book, spell, hud = getbook()
        if not hud then return end
        spell:SelectSpell(i)
        if quick then
            local pos = TheInput:GetWorldPosition()
            local act = BufferedAction(ThePlayer, nil, ACTIONS.CASTAOE, book, pos)
            p_util:DoAction(act, RPC.LeftClick, act.action.code, pos.x, pos.z, nil, true, 10, nil, nil, nil, nil, book, i)
        else
            local power = spell.SelectSpell and spell.items[i]
            if power and power.onselect and power.execute then
                power.onselect(book)
                power.execute(book)
            end
        end
    end, true)
end

m_util:AddBindConf("wllw_ember", function()
    if m_util:InGame() ~= "willow" then return end
    local book, spell, hud = getbook()
    if not hud then return end
    if hud:IsSpellWheelOpen() then
        hud:CloseSpellWheel()
    else
        spell:OpenSpellBook(ThePlayer)
    end
end)

-- One -click lighter
m_util:AddBindConf("wllw_take", function()
    if m_util:InGame() ~= "willow" then return end
    local data = p_util:GetSlotFromAll("lighter", nil, function(item)
        return e_util:GetItemEquipSlot(item)=="hands" and e_util:GetPercent(item)>0
    end, {"equip", "mouse", "container", "backpack", "body"})
    local lighter = data and data.item
    if not lighter then return end
    if data.slot == "hands" then
        p_util:UnEquip(lighter)
    else
        p_util:Equip(lighter)
        if e_util:FindEnt(nil, {"willow_ember", "fire"}, 20, nil, {"player", "inlimbo", "DECOR"}) then
            e_util:WaitToDo(ThePlayer, 3*FRAMES, 10, function()
                return p_util:GetAction("inv", "START_CHANNELCAST", true, lighter)
            end, function(act)
                p_util:DoAction(act, RPC.UseItemFromInvTile, act.action.code, lighter)
            end)
        end
    end
end)