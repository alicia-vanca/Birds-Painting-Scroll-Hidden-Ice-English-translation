local save_id, map_str = "sw_map", "Map icon"
local default_data = {
    sw = true,
    icon_size = 15,
    map_show = true,
    hud_show = true,
    hud_mouse = m_util:IsHuxi(),
    map_mouse = m_util:IsHuxi(),
    btn_conf = 1002,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

-- Map icon
local Hmap = require "widgets/huxi/huxi_map"
i_util:AddPlayerActivatedFunc(function(player, world, pusher, saver)
    local hud = player.HUD
    if hud.hx_map then
        hud.hx_map:Kill()
    end
    hud.hx_map = hud:AddChild(Hmap(hud))
    hud.hx_map:BuildHMap(save_data, saver:GetHMapUIData())
    saver:SetHMapConf(save_data)
end)


local function fn_set(conf)
    return function (value)
        fn_save(conf)(value)
        local saver = m_util:GetSaver()
        if saver then
            saver:RefreshHMap()
        end
    end
end
AddClassPostConstruct("widgets/mapcontrols", function(self)
    local _OnMouseButton = self.OnMouseButton
    function self.OnMouseButton(self, btn, down, ...)
        if self.focus and down and btn == save_data.btn_conf then
            if save_data.hud_mouse then
                fn_set("hud_show")(not save_data.hud_show)
            end
            -- I remember that if you open a global positioning before, it will be invalid here
            if save_data.map_mouse then
                fn_set("map_show")(not save_data.map_show)
            end
        end
        return _OnMouseButton(self, btn, down, ...)
    end
end)
AddClassPostConstruct("screens/mapscreen", function(self)
    if self.hx_map then
        self.hx_map:Kill()
    end
    self.hx_map = self:AddChild(Hmap(self))
    local saver = m_util:GetSaver()
    if saver then
        self.hx_map:BuildHMap(save_data, saver:GetHMapUIData())
    end
    
    -- local _OnMouseButton = self.OnMouseButton
    -- self.OnMouseButton = function(self, btn, down, ...)
    --     if btn == MOUSEBUTTON_RIGHT and down and save_data.map_mouse then
    --         local mapbtn = t_util:GetChild(t_util:GetChild(t_util:GetChild(self, "br_root"), "br_scale_root"),
    --                                           "Map Controls")
    --         if mapbtn and mapbtn.focus then
    --             fn_set("map_show")(not save_data.map_show)
    --         end
    --     end
    --     return _OnMouseButton(self, btn, down, ...)
    -- end
end)

local function GetScreenData()
    local screen_data = {
        title = "Super powerful " .. map_str,
        id = save_id,
        data = {},
    }
    local ui_data = screen_data.data
    local saver = m_util:GetSaver()
    if not saver then return screen_data end
    local data_ss = saver:GetHMapShowScreenData()
    t_util:IPairs(data_ss, function(data)
        table.insert(ui_data, {
            id = data.id,
            label = data.label,
            hover = data.hover,
            default = data.default,
            fn = function(value)
                data.fn(value)
                -- Set whether this category is displayed
                fn_save(data.id)(value)
                saver:RefreshHMap()
            end,
        })
        if data.screen_data then
            table.insert(ui_data, {
                id = data.id.."_setting",
                label = "Advanced settings:",
                hover = "Click to enter"..data.label.."Advanced settings",
                default = data.label,
                type = "textbtn",
                fn = function()
                    m_util:PopShowScreen()
                    m_util:AddBindShowScreen({
                        title = data.label .. " Advanced settings",
                        id = data.id.."_showscreen",
                        data = type(data.screen_data) == "function" and data.screen_data() or data.screen_data,
                    })()
                end
            })
        end
    end)
    screen_data.data = t_util:MergeList(ui_data, {
        {
            id = "map_show",
            label = "Total switch: map icon display",
            fn = fn_set("map_show"),
            hover = "After turning on the map \n whether the icon is displayed",
            default = fn_get,
        },
        {
            id = "map_mouse",
            label = "Icon map fast cut",
            fn = fn_set("map_mouse"),
            hover = "Click the [map button] switch icon display",
            default = fn_get,
        },
        {
            id = "hud_show",
            label = "Total switch: hawkye icon display",
            fn = fn_set("hud_show"),
            hover = "After opening the eagle eye \n, do you display the icon?",
            default = fn_get,
        },
        {
            id = "hud_mouse",
            label = "Icon eagle eye cut",
            fn = fn_set("hud_mouse"),
            hover = "Click the [map button] switch icon display",
            default = fn_get,
        }, {
            id = "btn_conf",
            label = "Fast-cut binding:",
            fn = fn_save("btn_conf"),
            hover = "Set fast-cut binding button",
            default = fn_get,
            type = "radio",
            data = h_util:SetMouseSecond()
        },
        {
            id = "icon_size",
            label = "All icon size:",
            fn = fn_set("icon_size"),
            hover = "Each icon scaling size",
            default = fn_get,
            type = "radio",
            data = t_util:BuildNumInsert(1, 50, 1, function(i)
                return {
                    data = i,
                    description = i .. " Pixel"
            }
            end)
        }})
    return screen_data
end

m_util:AddBindShowScreen(save_id, map_str, "stash_map", "Related settings of various map icons", function()
    m_util:AddBindShowScreen(GetScreenData())()
end, nil, 9998)
