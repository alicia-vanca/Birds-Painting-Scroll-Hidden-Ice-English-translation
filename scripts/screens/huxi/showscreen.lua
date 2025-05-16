local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TextBtn = require "widgets/textbutton"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local xml_quag = "images/quagmire_recipebook.xml"
local t_util = require "util/tableutil"
local h_util = require "util/hudutil"
local m_util = require "util/modutil"
local c_util = require "util/calcutil"


-- See the parameter usage in the interface.md of the bird scroll_function panel and advanced settings page
local ScreenScreen = Class(Screen, function(self, screen_data)
    Screen._ctor(self, "ShowScreen")
    self.w, self.h = 1000, 625
    self.font_size = 45
    -- Draw background: always include click return background, book page
    -- Construct self.root
    self:PaintRoot()
    self:PaintScreen(screen_data)
end)

-- fn_line: Draw line data
-- fn_active: Whether to listen to screen activation
function ScreenScreen:PaintScreen(screen_data)
    self.screen_data = m_util:HookShowScreenData(c_util:FormatDefault(screen_data, "table"))
    self.value = {} -- widget_cache_data
    self.page = 1
    self:PaintIcon()
    self:PaintTop() -- Draw title and title underline, and double arrow
    
    local function fn_linebuilt()
        local fn = self.screen_data.fn_line or function()end
        fn(self.lines, self)
    end
    local fn_data = self["Make_"..(self.screen_data.type or "ten")] 
    self.PaintData = type(fn_data) == "function" and function()
        fn_data(self)
        fn_linebuilt()
    end or fn_linebuilt
    
    if not self.screen_data.fn_active then
        self:PaintData() -- Draw data items
    end
end

function ScreenScreen:PaintTop()
    if self.title then self.title:Kill() end
    if not self.screen_data.title then return end
    self.title = self.root:AddChild(Text(HEADERFONT, self.font_size, self.screen_data.title, UICOLOURS.BLACK))
    self.title:SetPosition(0, self.h / 2 - self.font_size)
    self.title_line = self.title:AddChild(Image(xml_quag, "quagmire_recipe_line_break.tex"))
    self.title_line:SetPosition(0, -self.font_size+5)
    self.arr_l = self.title:AddChild(ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil,
        nil, nil, { 1, 1 }, { 0, 0 }))
    self.arr_r = self.title:AddChild(ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil,
        nil, nil, { 1, 1 }, { 0, 0 }))
    self.arr_l:SetPosition(-self.w / 6, 0)
    self.arr_l:SetScale(1, .5, .6)
    self.arr_r:SetPosition(self.w / 6, 0)
    self.arr_r:SetScale(-1, .5, .6)
    self.arr_r:SetHoverText("Next page")
    self.arr_l:SetHoverText("Previous page")
    self.arr_l:SetOnClick(function()
        self.page = self.page - 1
        self:PaintData()
    end)
    self.arr_r:SetOnClick(function()
        self.page = self.page + 1
        self:PaintData()
    end)
    self.arr_l:Hide()
    self.arr_r:Hide()
end

function ScreenScreen:PaintRoot()
    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black:SetOnClick(function() TheFrontEnd:PopScreen() end)
    local bg = black.image
    bg:SetVAnchor(ANCHOR_MIDDLE) -- Default at the bottom left of the screen
    bg:SetHAnchor(ANCHOR_MIDDLE)
    bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    bg:SetTint(0, 0, 0, 0) -- Set transparent
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.book = self.root:AddChild(Image(xml_quag, "quagmire_recipe_menu_bg.tex"))
    self.book:SetSize(self.w, self.h)
end

local sizes_default = {80, 70, 65}
local btn_pos_data = {
    right11 = {300, 240},
    right21 = {260, 240},
    right22 = {340, 240},
    right31 = {250, 240},
    right32 = {320, 240},
    right33 = {390, 240},
}
-- id, size, pos
function ScreenScreen:PaintIcon()
    if self.icons then self.icons:Kill() end
    self.icons = self.root:AddChild(Widget("icons"))
    local icons = c_util:FormatDefault(self.screen_data.icon, "table")
    local num_icons = #icons
    local size_default = sizes_default[num_icons] or 60

    local text_help = self.screen_data.help
    if type(text_help) == "string" then
        self.icons.btn_help = self.icons:AddChild(h_util:CreateImageButton({
            prefab = "cookbook_missing",
            fn = function()
                h_util:CreatePopupWithClose(self.screen_data.title and self.screen_data.title.."·Hint" or "Function Hint", text_help)
            end,
            hover = "Function Hint",
            pos = {-btn_pos_data.right11[1], btn_pos_data.right11[2]}
        }))
    end

    t_util:Pairs(icons, function(num, info)
        if not (info.id and type(num) == "number") then return end
        info.size = info.size or size_default
        local pos_default = btn_pos_data["right"..num_icons..num] or btn_pos_data.right11
        if type(info.pos) == "string" and btn_pos_data[info.pos] or not info.pos then
            info.pos = pos_default
        end
        self.icons[info.id] = self.icons:AddChild(h_util:CreateImageButton(info, self.icons))
    end)
end

function ScreenScreen:UpdatePage(num)
    self.data = c_util:FormatDefault(self.screen_data.data, "table")
    self.num = num or self.num
    if self.arr_l and self.arr_r and self.num then
        self.arr_l:Show()
        self.arr_r:Show()
        local page = self.page
        if page <= 1 then
            self.arr_l:Hide()
        end
        local page_max = math.ceil(#self.data / self.num)
        if page >= page_max then
            self.arr_r:Hide()
        end
    end
    if self.lines then self.lines:Kill() end
    self.lines = self.root:AddChild(Widget("lines"))
end

function ScreenScreen:PaintData()
    -- do nothing
    -- but no delete
end


function ScreenScreen:BuildGrid_PrefabDetail()
    local w = Widget("grid_detail")
    w.icon_show = w:AddChild(h_util:CretePrefabButton({
        scale = 0.75,
        bg = "ui",
        noclick = true,
    }))
    w.text_show = w:AddChild(Text(NEWFONT, 40, "", UICOLOURS.BLACK))
    w.text_show:SetPosition(0, -145)
    return w
end
-- data{prefab, hover}
-- ctor{context, fn_sel(prefab, lines, self)}
function ScreenScreen:BuildGrid_PrefabButton(c_tor)
    local cell_size = 90        -- Actual cell display size
    local cell_rate = 1.5  -- The smaller the cell, the larger it is
    local row_w = cell_size     -- Single column width
    local row_h = cell_size     -- Single row height
    local row_spacing = cell_rate*0.2       -- Cell spacing
	local boarder_scale = 1
    local line, col = 4, 6
    local c_tor = c_util:FormatDefault(c_tor, "table")
    local context = c_tor.context or {}

    local function ScrollWidgetsCtor(_, index)
        return h_util:CretePrefabButton({
            id = "grid_cell_"..index,
            scale = 1/cell_rate,
        })
    end
    local function fn_sel(prefab, w)
        return function()
            if prefab == context.prefab then
                context.prefab = nil
            else
                context.prefab = prefab
            end
            if c_tor.fn_sel then
                c_tor.fn_sel(context.prefab, self.lines, self)
            end
        end
    end
    local function ScrollWidgetSetData(context, w, data)
        if data then
            w.SetPrefabIcon({prefab = data.prefab})
            w:SetHoverText(data.hover, { offset_y = cell_size })
            if w.focus_icon then
                w.focus_icon:Kill()
            end
            if data.prefab == context.prefab then
                w.focus_icon = w.cell_root:AddChild(Image("images/global_redux.xml", "shop_sale_tag.tex"))
                local size = cell_size*0.8
                w.focus_icon:ScaleToSize(size, size)
                local shift = size/4
                w.focus_icon:SetPosition(shift, shift)
            end
            w.cell_root:SetOnClick(fn_sel(data.prefab, w))
            w:Show()
        else
            w:Hide()
        end
    end


    local grid = TEMPLATES.ScrollingGrid({}, {
        scroll_context = context,
        widget_width = row_w+row_spacing,  -- Total cell width
        widget_height = row_h+row_spacing, -- Total cell height
        num_visible_rows = line,              -- Number of visible rows
        num_columns = col,                   -- Number of columns
        item_ctor_fn = ScrollWidgetsCtor,  -- Item constructor
        apply_fn = ScrollWidgetSetData,     -- Data binding function
        scrollbar_offset = 20,
    })
    -- Construct scrollbar
    grid.up_button:SetTextures(xml_quag, "quagmire_recipe_scroll_arrow_hover.tex")
    grid.up_button:SetScale(0.5)
    grid.down_button:SetTextures(xml_quag, "quagmire_recipe_scroll_arrow_hover.tex")
    grid.down_button:SetScale(-0.5)
    grid.scroll_bar_line:SetTexture(xml_quag, "quagmire_recipe_scroll_bar.tex")
    grid.scroll_bar_line:SetScale(.8)
    grid.position_marker:SetTextures(xml_quag, "quagmire_recipe_scroll_handle.tex")
    grid.position_marker.image:SetTexture(xml_quag, "quagmire_recipe_scroll_handle.tex")
    grid.position_marker:SetScale(.6)
    -- Construct upper and lower beautification bar
	local grid_w, grid_h = grid:GetScrollRegionSize()
	local grid_boarder = grid:AddChild(Image(xml_quag, "quagmire_recipe_line.tex"))
	grid_boarder:SetScale(boarder_scale, boarder_scale)
    grid_boarder:SetPosition(-3, grid_h/2)
	grid_boarder = grid:AddChild(Image(xml_quag, "quagmire_recipe_line.tex"))
	grid_boarder:SetScale(boarder_scale, -boarder_scale)
    grid_boarder:SetPosition(-3, -grid_h/2-1)
    local grid_text = grid:AddChild(Text(HEADERFONT, cell_size/cell_rate, "", UICOLOURS.BROWN_DARK))
    -- Empty prompt
    local _SetItemsData = grid.SetItemsData
    grid.SetItemsData = function(ui, ...)
        _SetItemsData(ui, ...)
        grid_text:SetString(#ui.items == 0 and "Found 0 results" or "")
    end
    -- Default position
    grid:SetPosition(-145, -70)
    
    return grid
end

function ScreenScreen:LoadDefault(b_data, value)
    if self.value[b_data] and not b_data.notload then
        return self.value[b_data]
    end

    local screen_default = self.screen_data.default
    if type(b_data.default) == "function" then
        value = b_data.default(b_data.id)
    elseif type(b_data.default) ~= "nil" then
        value = b_data.default
    elseif type(screen_default) == "function" then
        value = screen_default(b_data.id)
    elseif type(screen_default) ~= "nil" then
        value = screen_default
    end
    self.value[b_data] = value
    return value
end


----------------------------------------------- Make_Type
function ScreenScreen:Make_log()
    self:UpdatePage(1)
    local shift_x = (-0.5+0.12)*self.w
    self.lines:SetPosition(shift_x, (0.5-0.32)*self.h)
    local b_data = self.data[self.page]
    if not b_data then return end
    local widget = self.lines:AddChild(Widget("log"))
    local time = widget:AddChild(Text(HEADERFONT, 38, b_data.time, UICOLOURS.BLACK))
    local content = widget:AddChild(Text(HEADERFONT, 40, b_data.content, UICOLOURS.BLACK))

    time:SetHAlign(ANCHOR_LEFT)
    content:SetRegionSize(850, self.h)
    content:EnableWordWrap(true)
    content:SetVAlign(ANCHOR_TOP)
    content:SetHAlign(ANCHOR_LEFT)

    time:SetPosition(50, 50)
    content:SetPosition(400, -300)
end

function ScreenScreen:Make_ten()
    self:UpdatePage(10)
    local shift_x = (-0.5+0.12)*self.w
    self.lines:SetPosition(shift_x, (0.5-0.32)*self.h)
    self.bar = self.lines:AddChild(Image(xml_quag, "quagmire_recipe_scroll_bar.tex"))
    self.bar:SetSize(5, 0.626*self.h)
    self.bar:SetPosition(-shift_x, -self.h/2+160)
    for i = 1, self.num do
        local nodot = (self.page - 1) * self.num + i
        local b_data = self.data[nodot]
        if not (b_data and b_data.id) then break end
        self:LoadDefault(b_data)
        local tp = b_data.type or "box"
        local ui_made = self["Ten_"..tp]
        local widget = type(ui_made) == "function" and ui_made(self, b_data)
        self.lines[b_data.id] = self.lines:AddChild(widget)
        widget:SetHoverText(b_data.hover, { font = NEWFONT_OUTLINE, offset_y = 90 })
        widget:SetPosition((i - 1) % 2 * (self.w / 2 - 60), -math.floor((i - 1) / 2) * 70)
    end
end
-- data_create:
--- meta: Parameters passed when generating ui
--- name: The function name in self, if this item exists, execute and generate ui 
--- fn: If there is no name above, execute this function to generate ui
--- id: The id of the ui
--- pid: If this item exists, the ui is attached to the id element, otherwise it is attached to lines
function ScreenScreen:Make_player()
    self:UpdatePage()
    local data = c_util:FormatDefault(self.screen_data.data_create, "table")
    t_util:IPairs(data, function(info)
        if not info.id then return end
        local fn_ui = info.name and self[info.name] or info.fn
        local ui = type(fn_ui)=="function" and fn_ui(self, info.meta) or Widget(info.id)
        local pui = info.pid and self.lines[info.pid] or self.lines
        pui[info.id] = pui:AddChild(ui)
    end)
end

----------------------------------------------- MakeTen_
-- id, label, hover, type, fn 通用
-- xml, tex or prefab
function ScreenScreen:Ten_imgstr(b_data)
    local w = Widget("imgstr")
    local btn = w:AddChild(TextBtn())
    w.ui_text = btn
    btn:SetText(b_data.label)
    btn:SetTextColour(UICOLOURS.BLACK)
    btn:SetFont(HEADERFONT)
    btn:SetTextSize(40)
    local _width = 280

    local line = btn:AddChild(Image(xml_quag, "quagmire_recipe_scroll_bar.tex"))
    line:SetSize(5, _width)
    line:SetRotation(90)
    line:SetPosition(0, -25)
    function btn.uiSwitch()
    end
    function btn.switch(value)
        btn.uiSwitch(value)
        if type(b_data.fn) == "function" then
            b_data.fn(self.value[b_data], self.lines, self.data, self)
        end
    end
    btn:SetOnClick(function()
        btn.switch()
    end)
    btn:SetPosition(200, 0)

    local xml, tex = b_data.xml, b_data.tex
    if h_util:GetPrefabAsset(b_data.prefab) then
        xml, tex = h_util:GetPrefabAsset(b_data.prefab)
    end
    local img = btn:AddChild(Image(xml, tex))
    w.ui_img = img
    -- img:SetScale(65 / btn:GetSize())
    h_util:ActivateBtnScale(img, 65)
    img:SetPosition(-200, 0)
    return w
end
-- default
function ScreenScreen:Ten_radio(b_data)
    local btn = Widget("radio")

    btn.text = btn:AddChild(Text(HEADERFONT, 40, b_data.label, UICOLOURS.BLACK))
    local width = btn.text:GetRegionSize()
    btn.text:SetPosition(width/2-15, 0)
    
    btn.arr_l = btn:AddChild(ImageButton(xml_quag, "arrow2_left.tex", "arrow2_left_over.tex", "arrow_left_disabled.tex", "arrow2_left_down.tex", nil,{1,1}, {0,0}) )
    btn.arr_r = btn:AddChild(ImageButton(xml_quag, "arrow2_right.tex", "arrow2_right_over.tex", "arrow_right_disabled.tex", "arrow2_right_down.tex", nil,{1,1}, {0,0}) )
    
    local arrow_size = btn.arr_l:GetSize()
    local arrow_scale = 60 / arrow_size
    btn.arr_r:SetNormalScale(arrow_scale)
    btn.arr_r:SetFocusScale(arrow_scale * 1.2)
    btn.arr_l:SetNormalScale(arrow_scale)
    btn.arr_l:SetFocusScale(arrow_scale * 1.2)

    btn.arr_l:SetPosition(150, 0)
    btn.arr_r:SetPosition(360, 0)

    
    local str_show = ""
    btn.showtext = btn:AddChild(Text(HEADERFONT, 40, str_show, UICOLOURS.BLACK))
    btn.showtext:SetPosition(255, 0)

    local function getid()
        self.value[b_data] = tostring(self.value[b_data])
        return t_util:GetElement(b_data.data, function(id, info)
            return self.value[b_data] == tostring(info.data) and id
        end) or 1
    end

    local function update_arr(id, onlyui)
        btn.arr_l:Show()
        btn.arr_r:Show()
        if id <= 1 then
            id = 1
            btn.arr_l:Hide()
        elseif id >= #b_data.data then
            id = #b_data.data
            btn.arr_r:Hide()
        end
        if b_data.data[id] then
            self.value[b_data] = b_data.data[id].data
            str_show = b_data.data[id].description
            if self.value[b_data] and str_show then
                btn.showtext:SetString(str_show)
                if not onlyui and type(b_data.fn)=="function" then
                    b_data.fn(self.value[b_data], self.lines, self.data, self)
                end
            end
        end
    end
    update_arr(getid(), true)
    btn.arr_l:SetOnClick(function()
        update_arr(getid() - 1)
    end)
    btn.arr_r:SetOnClick(function()
        update_arr(getid() + 1)
    end)
    function btn.switch(value)
        self.value[b_data] = value
        update_arr(getid())
    end
    function btn.uiSwitch(value)
        self.value[b_data] = value
        update_arr(getid(), true)
    end
    return btn
end
-- default
function ScreenScreen:Ten_box(b_data)
    local btn = ImageButton(xml_quag, "cookbook_known.tex")
    local btn_size = btn:GetSize()
    local btn_scale = 60 / btn_size
    btn:SetNormalScale(btn_scale)
    btn:SetFocusScale(btn_scale * 1.2)
    btn.img_or = btn.image:AddChild(Image("images/hx_or.xml", self.value[b_data] and "right.tex" or "wrong.tex"))
    btn.img_or:SetSize(100, 100)
    function btn.uiSwitch(value)
        self.value[b_data] = value
        btn.img_or:SetTexture("images/hx_or.xml", value and "right.tex" or "wrong.tex")
        btn.img_or:SetSize(100, 100)
    end
    function btn.switch(value)
        btn.uiSwitch(value)
        if type(b_data.fn) == "function" then
            b_data.fn(self.value[b_data], self.lines, self.data, self)
        end
    end
    btn:SetOnClick(function()
        btn.switch(not self.value[b_data])
    end)
    btn.labeltext = btn:AddChild(Text(HEADERFONT, 40, b_data.label, UICOLOURS.BLACK))
    btn.labeltext:SetPosition(200, 0)
    return btn
end
-- default
function ScreenScreen:Ten_textbtn(b_data)
    local w = Widget("textbtn")

    w.text = w:AddChild(Text(HEADERFONT, 40, b_data.label, UICOLOURS.BLACK))
    local width = w.text:GetRegionSize()
    w.text:SetPosition(width/2-15, 0)

    local ttn = TextBtn()
    w.showtext = w:AddChild(ttn)
    ttn:SetText(self.value[b_data] or "Not Set")
    ttn:SetFont(HEADERFONT)
    ttn:SetTextSize(42)
    ttn:SetColour(UICOLOURS.BLACK)
    function w.uiSwitch(value)
        self.value[b_data] = value
        ttn:SetText(self.value[b_data] or "Not Set")
    end
    function w.switch()
        if type(b_data.fn) == "function" then
            b_data.fn(self.value[b_data], self.lines, self.data, self)
        end
    end
    ttn:SetOnClick(function()
        w.switch()
    end)

    local _width = 230
    ttn:SetPosition(_width, 0)

    -- Just any background image
    local bgimage = ttn:AddChild(Image(xml_quag, "cookbook_known.tex"))
    bgimage:SetSize(_width, 40)
    bgimage:SetTint(0, 0, 0, 0)

    local line = ttn:AddChild(Image(xml_quag, "quagmire_recipe_scroll_bar.tex"))
    line:SetSize(5, _width)
    line:SetRotation(90)
    line:SetPosition(0, -25)


    return w
end

----------------------- Control -------------------------
function ScreenScreen:OnControl(control, down)
    if ScreenScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function ScreenScreen:OnBecomeActive()
    ScreenScreen._base.OnBecomeActive(self)
    local fn_active = self.screen_data.fn_active
    if fn_active then
        self:PaintData()
        if type(fn_active) == "function" then 
            fn_active(self)
        end
    end
end

return ScreenScreen
