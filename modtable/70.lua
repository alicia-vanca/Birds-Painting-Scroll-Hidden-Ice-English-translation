
local save_id, string_r = "sw_right", "Right-click"



local function GetScreenData()
    local screen_data = {
        title = "Convenient " .. string_r,
        id = save_id,
        data = {},
    }
    local ui_data = screen_data.data
    t_util:IPairs(m_util:GetData("RIGHT"), function(data)
        table.insert(ui_data, {
            id = data.id,
            label = data.label,
            hover = data.hover,
            default = data.default,
            fn = data.fn,
        })
        if data.screen_data then
            table.insert(ui_data, {
                id = data.id.."_setting",
                label = "Config:",
                hover = "Click to enter "..data.label.."'s advanced settings",
                default = data.label,
                type = "textbtn",
                fn = function()
                    m_util:PopShowScreen()
                    m_util:AddBindShowScreen({
                        title = data.label .. " - Advanced settings",
                        id = data.id.."_showscreen",
                        data = type(data.screen_data) == "function" and data.screen_data() or data.screen_data,
                    })()
                end
            })
        end
    end)

    return screen_data
end

m_util:AddBindShowScreen(save_id, string_r, "book_fossil", "Right button ".. h_util:GetStringKeyBoardMouse(MOUSEBUTTON_RIGHT) .. " Click to perform more operations", function()
    m_util:AddBindShowScreen(GetScreenData())()
end, nil, 9993)