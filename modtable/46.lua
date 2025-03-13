local save_id, string_name = "sw_nickname", "Nickname"
local default_data = {
    mine = false,
    fontsize = 19,
    offset = 2.3,
    font = "stint-ucr",
    color = "White",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

AddPlayerPostInit(function(player)
    player:DoTaskInTime(0, function(inst)
        local label = inst.entity:AddLabel()
        label:SetFontSize(save_data.fontsize)         
        label:SetFont(save_data.font)
        label:SetWorldOffset(0, save_data.offset, 0)
        label:SetText(inst.name)
        if player == ThePlayer then
            label:Enable(save_data.mine and true or false)
        else
            label:Enable(true)
        end
        label:SetColour(unpack(h_util:GetRGB(save_data.color)))
    end)
end)

local V_data = require("data/valuetable")
local colors = V_data.RGB_datatable
m_util:AddBindShowScreen(save_id, string_name, "punchingbag_lunar", STRINGS.LMB .. "Advanced settings", {
    id = save_id,
    title = "Show my nickname",
    data = {
        {
            id = "mine",
            label = "Personal nickname",
            fn = function(v)
                fn_save("mine")(v)
                local l = ThePlayer and ThePlayer.entity:AddLabel()
                if l then
                    l:Enable(v and true or false)
                end
            end,
            hover = "Whether to show the player's own nickname",
            default = fn_get,
        },
        {
            id = "fontsize",
            label = "Size:",
            fn = function(v)
                fn_save("fontsize")(v)
                t_util:IPairs(e_util:FindEnts(nil, nil, nil, "player", {}), function(player)
                    local l = player and player.entity:AddLabel()
                    if l then
                        l:SetFontSize(v)
                    end
                end)
            end,
            hover = "The font size of the nickname",
            default = fn_get,
            type = "radio",
            data = t_util:BuildNumInsert(1, 40, 1, function(i)
                return {data = i, description = i}
            end)
        },{
            id = "offset",
            label = "Height:",
            fn = function(v)
                fn_save("offset")(v)
                t_util:IPairs(e_util:FindEnts(nil, nil, nil, "player", {}), function(player)
                    local l = player and player.entity:AddLabel()
                    if l then
                        l:SetWorldOffset(0, v, 0)
                    end
                end)
            end,
            hover = "The nickname is relatively high inside",
            default = fn_get,
            type = "radio",
            data = t_util:BuildNumInsert(0.1, 4, 0.1, function(i)
                return {data = i, description = i}
            end)
        },{
            id = "font",
            label = "Font:",
            fn = function(v)
                fn_save("font")(v)
                t_util:IPairs(e_util:FindEnts(nil, nil, nil, "player", {}), function(player)
                    local l = player and player.entity:AddLabel()
                    if l then
                        l:SetFont(v)
                    end
                end)
            end,
            hover = "Choose the font you like",
            default = fn_get,
            type = "radio",
            data = V_data.font_datatable
        },{
            id = "color",
            label = "Color:",
            fn = function(v)
                fn_save("color")(v)
                t_util:IPairs(e_util:FindEnts(nil, nil, nil, "player", {}), function(player)
                    local l = player and player.entity:AddLabel()
                    if l then
                        l:SetColour(unpack(h_util:GetRGB(v)))
                    end
                end)
            end,
            hover = "Choose your favorite nickname color",
            default = fn_get,
            type = "radio",
            data = colors,
        },
    }
}, nil, -9997)
