-- Reserve
m_util:AddBindConf("wax_hat", function()
    if m_util:InGame() ~= "waxwell" then return end
    local data = p_util:GetSlotFromAll("tophat", "shadowlevel", nil, "mouse")
    if not data then return end
    local act = p_util:GetAction("inv", "USEMAGICTOOL", true, data.item)
    if act then
        local rpc = data.slot == "head" and RPC.UseItemFromInvTile or RPC.ControllerUseItemOnSelfFromInvTile
        p_util:DoAction(act, rpc, act.action.code, data.item)
    end
end)

local function getbook()
    local book = p_util:GetItemFromAll("waxwelljournal", nil, function(item)
        return e_util:GetPercent(item) > 0
    end)
    local spell = t_util:GetRecur(book or {}, "components.spellbook")
    local hud = ThePlayer.HUD
    if not (spell and hud) then return end
    return book, spell, hud
end
m_util:AddBindConf("wax_book", function()
    if m_util:InGame() ~= "waxwell" then return end
    local book, spell, hud = getbook()
    if not hud then return end
    if hud:IsSpellWheelOpen() then
        hud:CloseSpellWheel()
    else
        spell:OpenSpellBook(ThePlayer)
    end
end)


local quick = m_util:IsTurnOn("wax_quick")
for i = 1,4 do
    m_util:AddBindConf("wax_bind"..i, function()
        if m_util:InGame() ~= "waxwell" then return end
        local book, spell, hud = getbook()
        if not hud then return end
        spell:SelectSpell(i)
        if quick then
            local pos = TheInput:GetWorldPosition()
            local act = BufferedAction(ThePlayer, nil, ACTIONS.CASTAOE, book, pos)
            p_util:DoAction(act, RPC.LeftClick, act.action.code, pos.x, pos.z, nil, true, 10, nil, nil, nil, nil, book, i)
        else
            local power = spell.items[i]
            if power and power.onselect and power.execute then
                power.onselect(book)
                power.execute(book)
            end
        end
    end, true)
end