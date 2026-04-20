local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TextBtn = require "widgets/textbutton"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local f_util = require "util/fn_hxcb"
local save_data = f_util.save_data
local g_util = require "util/fn_gallery"

local c_util, e_util, h_util, m_util, t_util, p_util = require "util/calcutil", require "util/entutil",
    require "util/hudutil", require "util/modutil", require "util/tableutil", require "util/playerutil"

local opt_enable = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local auth_enable = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = "Authorize", data = true } }
local LMB, RMB = STRINGS.LMB, STRINGS.RMB
local function UI_Reset()
    local ui = h_util:GetCB()
    if ui then
        ui:BuildUI()
    end
end
local scale_table = t_util:BuildNumInsert(.1, 2, .05, function(i)
    return {data = i, text = string.format("%.2f x", i)}
end)
local hxcb_settings = {
    {
        id = "lright",
        label = "Page layout:",
        data = {{ text = "Left align", data = false }, { text = "Right align", data = true }},
        hover = "Align the search grid left or right\nRight align is closer to the old T-console layout",
        type = "radio",
        fn = UI_Reset,
    },
    {
        id = "tip_pos",
        label = "Tip message:",
        data = { { text = "Remote, visible to others", data = "whisper" },  { text = "Remote, visible nearby", data = "mine" }, { text = "Simple, visible to self", data = "only" }, { text = "Chat, visible to self", data = "self" }, { text = "Announcement, server-wide", data = "ann"}, { text = STRINGS.UI.OPTIONS.DISABLED, data = "shutup"}},
        hover = "In [Simple/Remote] modes, tip info appears above players, while [Announcement] sends a system broadcast.\nRecommended setting: [Remote, visible to others] to match the old T-console.",
        type = "radio",
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    },{
        id = "code_hover",
        label = "Floating code:",
        data = opt_enable,
        hover = "Show code when hovering over the grid",
        type = "radio",
    },{
        id = "ui_waves",
        label = "Bottom flags:",
        data = opt_enable,
        hover = "Add extra flag buttons at the bottom of the console page\nfor quick save or reload",
        type = "radio",
    },
    {
        id = "pop_ensure",
        label = "Command confirmation:",
        data = opt_enable,
        hover = "Require second confirmation for dangerous commands\nsuch as killing players, clearing items, reloading the game, etc.",
        type = "radio",
    },
    {
        id = "spawn_ensure",
        label = "Spawn confirmation:",
        data = opt_enable,
        hover = "A highlighted grid must be selected to spawn entities\nThis makes it easier to generate items via the bottom extension unit",
        type = "radio",
    },
    {
        id = "spawn_anchor",
        label = "Finger alignment:",
        data = opt_enable,
        hover = "Automatically snap to the geometric grid when using the right-click menu's [Gold Finger] or [Silver Finger]",
        type = "radio",
    },
    {
        id = "skin_enable",
        label = "Skin mode:",
        data = opt_enable,
        hover = "Spawn items with skins?\nNote: this uses the skin from the player's last crafted item and may not grant skins you don't own.",
        type = "radio",
    },
    {
        id = "midbind",
        label = "Quick middle button:",
        data = {
            {data = "R_SpawnMany", text = "Spawn many"},
            {data = "R_FindNext", text = "Teleport now"},
            {data = "R_GetRecipe", text = "Get materials"},
            {data = "R_AddRecipe", text = "Unlock prototype"},
            {data = "R_SpawnRunning", text = "Gold Finger"},
            {data = "R_CountPrefab", text = "Announce quantity"},
        },
        hover = "Function triggered directly by middle mouse click "..(h_util:GetStringKeyBoardMouse(MOUSEBUTTON_MIDDLE) or "").."",
        type = "radio",
    },
    {
        id = "equipmem",
        label = "Equip memory:",
        data = opt_enable,
        hover = "When the player equips an item not in the [Equipment] tag, it will automatically save it to that tag",
        type = "radio",
        reset = true,
    },
    {
        id = "modfilter",
        label = "Mod filter:",
        data = opt_enable,
        hover = "Show only server mod items under the [Mod] tag",
        type = "radio",
        fn = function()
            g_util.prefabs.mod = nil
            package.loaded["data/hx_cb/cates/mod"] = nil
        end
    },{
        id = "num_spawn",
        label = "Batch spawn:",
        hover = "Quantity spawned per action in the right-click menu or middle-button shortcut\n"..LMB.."customize "..RMB.."restore default",
        type = "numbtn",
        fnstr = function(str)
            return str.." per batch"
        end,
        title = "Please set the number of items spawned per right-click action:",
        default = 10,
    },{
        id = "range_delete",
        label = "Delete radius:",
        hover = "Range for the console's nearby delete function, where 4 wall points equal one turf length\n"..LMB.."customize "..RMB.."restore default",
        type = "numbtn",
        fnstr = function(str)
            return str.." wall points"
        end,
        title = "Please set the scan radius for the [Nearby Delete] function:",
        default = 3,
    },{
        id = "range_kill",
        label = "Kill radius:",
        hover = "Range for the console's nearby kill function, where 4 wall points equal one turf length\n"..LMB.."customize "..RMB.."restore default",
        type = "numbtn",
        fnstr = function(str)
            return str.." wall points"
        end,
        title = "Please set the scan radius for the [Nearby Kill] function:",
        default = m_util:IsHuxi() and 64 or 20,
    }
}

if m_util:IsMilker() then
    table.insert(hxcb_settings,
        {
            id = "code_pri",
            label = "Print commands:",
            data = opt_enable,
            hover = "Whether operation commands are printed in the local console\nPress CTRL+L to see what commands were sent to the server",
            type = "radio",
        }
    )
    table.insert(hxcb_settings,
        {
            id = "__authorize",
            label = "Extended permissions:",
            data = auth_enable,
            hover = "Enabling this adds more item and creature categories to the console\nbut may slow loading or even crash!",
            type = "radio",
            reset = true,
        }
    )
end
if m_util:IsHuxi() then
    table.insert(hxcb_settings,
        {
            id = "immodder",
            label = "Developer mode:",
            data = opt_enable,
            hover = "Automatically enable the following modes when entering the game:\nCreative mode, God mode, constant eclipse",
            type = "radio",
        }
    )
end

local ST = Class(Widget, function(self, CB)
    Widget._ctor(self, "huxi_console_board_console")

    local data_str = {"width_bg", "height_bg", "size_font"}
    t_util:IPairs(data_str, function(str) self[str] = CB[str] end)

    self.label_width = self.width_bg/4.5
    self.radio_width = self.width_bg/3.5
    self.space_between = 5
    self.radio_height = 36
    self.radio_offset = -10

    self.itembg_width = self.label_width + self.radio_width + self.space_between + 15
    self.itembg_height = self.radio_height + self.space_between

    
    self.tool_tip = self:AddChild(self:MakeTooltip())
    self:LoadAndPaint()


end)

function ST:MakeTooltip()
    local w = Widget("tooltip")
    local text = w:AddChild(Text(CHATFONT, self.size_font+3, ""))
	text:SetHAlign(ANCHOR_LEFT)
	text:SetVAlign(ANCHOR_TOP)
	text:SetRegionSize(self.width_bg, self.height_bg)
	text:EnableWordWrap(true)
    local posy_text = -self.height_bg * 5/6
    text:SetPosition(self.size_font, posy_text)
    w.ui_text = text

    local divider = w:AddChild(Image("images/hx_ui.xml", "quagmire_recipe_line.tex"))
    divider:ScaleToSize(self.width_bg, self.size_font)
    divider:SetPosition(0, self.height_bg/2 + posy_text + self.size_font)
    w:Hide()
	return w
end

function ST:AddListItemBackground(w)
	w.bg = w:AddChild(TEMPLATES.ListItemBackground(self.itembg_width, self.itembg_height))
	w.bg:MoveToBack()
end

function ST:Paint_radio(data)
    local function fn_radio(sel, old)
        f_util.fn_save(data.id)(sel)
        if data.fn then
            data.fn(sel, old)
        end
        if data.reset then
            h_util:CreatePopupWithClose("Notice", "This setting change requires restarting the game to take full effect.")
        end
    end
    local w = TEMPLATES.LabelSpinner(data.label, data.data, self.label_width, self.radio_width, self.radio_height, self.space_between, nil, self.size_font, self.radio_offset, fn_radio, nil, data.hover)
    self:AddListItemBackground(w)
    local default = save_data[data.id]
    local index = t_util:ForIGet(w.spinner.options, function(k, v)
        return v.data == default and k
    end)
    if index then
        w.spinner:SetSelectedIndex(index)
    end
    return w
end

function ST:Paint_numbtn(data)
    local w = Widget(data.id)
    
    local w = TEMPLATES.LabelSpinner(data.label, {}, self.label_width, self.radio_width, self.radio_height, self.space_between, nil, self.size_font, self.radio_offset, function()end, nil, data.hover)
    self:AddListItemBackground(w)
    local sp = w.spinner
    sp.leftimage:Hide()
    sp.rightimage:Hide()
    w.flush = function()
        local str = save_data[data.id] or ""
        str = data.fnstr and data.fnstr(str) or str
        sp.text:SetString(str)
    end
    w.flush()

    h_util:BindMouseClick(sp.background, {
        [MOUSEBUTTON_LEFT] = function()
            h_util:CreateWriteWithClose(data.title, {
                text = "Confirm",
                cb = function(str)
                    local num = tonumber(str)
                    if num and num >= 1 and num % 1 == 0 then
                        f_util.fn_save(data.id)(num)
                        w.flush()
                    else
                        h_util:CreatePopupWithClose("Invalid", "Please enter a positive integer.")
                    end
                end
            })
        end,
        [MOUSEBUTTON_RIGHT] = function()
            f_util.fn_save(data.id)(data.default)
            w.flush()
        end
    })
    return w
end



function ST:LoadAndPaint()
    local w = self:AddChild(Widget("items"))
    local num_tip = 0
    for i, data in ipairs(hxcb_settings) do
        local fn = self["Paint_" .. data.type]
        if fn then
            local ui = w:AddChild(fn(self, data))
            local offset_x = i % 2 == 0 and self.itembg_width + self.space_between or 0
            local offset_y = math.ceil(i/2)-1
            ui:SetPosition(offset_x, -offset_y * self.itembg_height)
            ui:SetOnGainFocus(function()
                self.tool_tip.ui_text:SetString(data.hover)
                self.tool_tip:Show()
                num_tip = num_tip + 1
            end)
            ui:SetOnLoseFocus(function()
                if num_tip <= 1 then
                    self.tool_tip:Hide()
                end
                num_tip = num_tip - 1
            end)
        end
    end

    w:SetPosition(self.width_bg * -.5 + self.itembg_width * .5 - 25, self.height_bg * .5 - self.itembg_height * .5)
    self.items = self:AddChild(w)
end


return ST