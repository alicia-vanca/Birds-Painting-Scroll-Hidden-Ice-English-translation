local save_id, string_timer = "sw_timer", "Info tray"
local default_data = {
    posx = nil,
    posy = nil,
    num_col = 10,
    btn_size = 50,
    penetrate = false,
    font_posy = 10,
    font_size = 10,
    space_x = 15,
    space_y = 18,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)


local funcs = {
    SavePos = function(pos)
        fn_save("posx")(pos.x)
        fn_save("posy")(pos.y)
    end
}


local function fn_set(conf)
    return function (value)
        fn_save(conf)(value)
        local saver = m_util:GetSaver()
        if saver then
            saver:SetTimerConfig()
        end
    end
end

-- Info tray
local Timer = require "widgets/huxi/huxi_timer"
i_util:AddPlayerActivatedFunc(function(player, world, pusher, saver)
    local ctrl = t_util:GetRecur(player, "HUD.controls")
    if not ctrl then return end
    if ctrl.hx_timer then
        ctrl.hx_timer:Kill()
    end
    ctrl.hx_timer = ctrl:AddChild(Timer(funcs))
    saver:SetTimerConfig(save_data)
end)


local function GetScreenData()
    local screen_data = {
        title = "Super easy to use " .. string_timer,
        id = save_id,
        data = {
            {
                id = "reset_pos",
                label = "Reset",
                fn = function()
                    local timer = h_util:GetTimer()
                    if timer then
                        timer:SetUIPos(true)
                    end
                end,
                hover = "If your ui is not controlled, click this button to reset the ui position",
                default = true,
            },
            {
                id = "penetrate",
                label = "Ui penetration",
                fn = fn_set("penetrate"),
                hover = "After opening this option, click the info tray to penetrate '\n and lose ui drag and drag and click announcement at the same time",
                default = fn_get,
            },
            {
                id = "btn_size",
                label = "Icon size:",
                fn = fn_set("btn_size"),
                hover = "Each icon scaling size",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(2, 200, 2, function(i)
                    return {
                        data = i,
                        description = i .. " Pixel"
                    }
                end)
            },
            {
                id = "num_col",
                label = "Maximum number:",
                fn = fn_set("num_col"),
                hover = "Change the line when you exceed how many attributes",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(1, 40, 1, function(i)
                    return {
                        data = i,
                        description = i .. " Indivual"
                    }
                end)
            },
            {
                id = "font_size",
                label = "Font size:",
                fn = fn_set("font_size"),
                hover = "Display font size",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(0, 100, 2, function(i)
                    return {
                        data = i,
                        description = i .. " Font"
                    }
                end)
            },
            {
                id = "font_posy",
                label = "Font offset:",
                fn = fn_set("font_posy"),
                hover = "Show the offset distance of the font",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(-50, 50, 1, function(i)
                    return {
                        data = i,
                        description = i .. " Distance"
                    }
                end)
            },
            {
                id = "space_x",
                label = "Horizontal distance:",
                fn = fn_set("space_x"),
                hover = "Display the horizontal distance between the icon",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(-50, 50, 1, function(i)
                    return {
                        data = i,
                        description = i .. " Distance"
                    }
                end)
            },
            {
                id = "space_y",
                label = "Vertical distance:",
                fn = fn_set("space_y"),
                hover = "Display the vertical distance between the icons",
                default = fn_get,
                type = "radio",
                data = t_util:BuildNumInsert(-50, 50, 1, function(i)
                    return {
                        data = i,
                        description = i .. " Distance"
                    }
                end)
            },},
    }
    local ui_data = screen_data.data
    local saver = m_util:GetSaver()
    if not saver then return screen_data end
    local data_ss = saver:GetStatShowScreenData()
    t_util:IPairs(data_ss, function(data)
        table.insert(ui_data, {
            id = data.id,
            label = data.label,
            hover = "Whether to enable "..data.hover,
            default = data.default,
            fn = function(value)
                data.fn(value)
                -- Set whether this category is displayed
                fn_save(data.id)(value)
                saver:SetTimerConfig()
            end,
        })
        if data.screen_data then
            table.insert(ui_data, {
                id = data.id.."_setting",
                label = "Settings:",
                hover = "Click to enter "..data.label.." advanced settings",
                default = data.label,
                type = "textbtn",
                fn = function()
                    m_util:PopShowScreen()
                    m_util:AddBindShowScreen({
                        title = data.hover,
                        id = data.id.."_showscreen",
                        data = type(data.screen_data) == "function" and data.screen_data() or data.screen_data,
                    })()
                end
            })
        end
    end)
    return screen_data
end


m_util:AddBindShowScreen(save_id, string_timer, "chesspiece_beefalo_moonglass", "Various countdown related settings", function()
    m_util:AddBindShowScreen(GetScreenData())()
end, nil, 9999)

