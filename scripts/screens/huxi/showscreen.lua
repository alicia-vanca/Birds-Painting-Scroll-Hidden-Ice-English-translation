local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Text = require "widgets/text"
local t_util = require "util/tableutil"
local h_util = require "util/hudutil"
local TextBtn = require "widgets/textbutton"

-- Id, explain text, prompt text, callback function
local ScreenScreen = Class(Screen, function(self, screen_data)
    Screen._ctor(self, "ShowScreen")

    
    self.data = screen_data.data
    self.default = screen_data.default
    self.value = {} -- widget_cache_data

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black:SetOnClick(function() TheFrontEnd:PopScreen() end)
    local bg = black.image
    bg:SetVAnchor(ANCHOR_MIDDLE) -- The default is in the lower left corner of the screen
    bg:SetHAnchor(ANCHOR_MIDDLE)
    bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    bg:SetTint(0, 0, 0, 0) -- Set transparency

    local book = self:AddChild(Widget("root"))
    self.book = book
    book:SetVAnchor(ANCHOR_MIDDLE)
    book:SetHAnchor(ANCHOR_MIDDLE)
    self.w, self.h = 1000, 625
    book.bg = book:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
    book.bg:SetSize(self.w, self.h)
    book.title = book:AddChild(Text(HEADERFONT, 45, screen_data.title, UICOLOURS.BLACK))
    book.title:SetPosition(0, self.h / 2 - 45)
    book.title_line = book.title:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_line_break.tex"))
    book.title_line:SetPosition(0, -40)

    self.arr_l = book:AddChild(ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil,
        nil, nil, { 1, 1 }, { 0, 0 }))
    self.arr_r = book:AddChild(ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil,
        nil, nil, { 1, 1 }, { 0, 0 }))
    local arrow_size = self.arr_l:GetSize()
    local arrow_scale = 60 / arrow_size
    self.arr_r:SetNormalScale(arrow_scale)
    self.arr_r:SetFocusScale(arrow_scale * 1.2)
    self.arr_l:SetNormalScale(arrow_scale)
    self.arr_l:SetFocusScale(arrow_scale * 1.2)
    self.arr_l:SetPosition(-self.w / 6, self.h / 2 - 45)
    self.arr_l:SetScale(1, .5, 1)
    self.arr_r:SetPosition(self.w / 6, self.h / 2 - 45)
    self.arr_r:SetScale(-1, .5, 1)
    self.arr_r:SetHoverText("Next page")
    self.arr_l:SetHoverText("Last page")
    self.arr_l:SetOnClick(function()
        self.page = self.page - 1
        self:Paint()
    end)
    self.arr_r:SetOnClick(function()
        self.page = self.page + 1
        self:Paint()
    end)

    if screen_data.type == "log" then
        self.num = 1
        self.Paint = self.PaintLog
    else
        book.bar = book:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex"))
        book.bar:SetSize(5, self.h - 240)
        book.bar:SetPosition(0, -40)
        self.num = 10
        self.Paint = self.PaintTen
    end
    
    self.page = 1
    self:Paint()
end)

function ScreenScreen:UpdatePage()
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
    if self.lines then self.lines:Kill() end
    self.lines = self.book:AddChild(Widget("lines"))
    self.lines:SetPosition(-self.w / 2 + 120, self.h / 2 - 200)
end
function ScreenScreen:PaintLog()
    self:UpdatePage()
    local b_data = self.data[self.page]
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


function ScreenScreen:Paint()
    -- do nothing
    -- It's going to be replaced anyway
end


function ScreenScreen:PaintTen()
    self:UpdatePage()

    for i = 1, self.num do
        local nodot = (self.page - 1) * self.num + i
        local b_data = self.data[nodot]
        if not b_data then break end
        self:LoadDefault(b_data)
        local tp = b_data.type
        local widget
        if tp == "radio" then
            widget = self:MakeRadio(b_data)
        elseif tp == "textbtn" then
            widget = self:MakeText(b_data)
        elseif tp == "imgstr" then
            widget = self:MakeImgStr(b_data)
        else
            widget = self:MakeBox(b_data)
        end
        self.lines[b_data.id] = self.lines:AddChild(widget)
        widget:SetHoverText(b_data.hover, { font = NEWFONT_OUTLINE, offset_y = 90 })
        widget:SetPosition((i - 1) % 2 * (self.w / 2 - 60), -math.floor((i - 1) / 2) * 70)
    end
end
function ScreenScreen:LoadDefault(b_data, value)
    if self.value[b_data] and not b_data.notload then
        return self.value[b_data]
    end
    if type(b_data.default) == "function" then
        value = b_data.default(b_data.id)
    elseif type(b_data.default) ~= "nil" then
        value = b_data.default
    elseif type(self.default) == "function" then
        value = self.default(b_data.id)
    elseif type(self.default) ~= "nil" then
        value = self.default
    end
    self.value[b_data] = value
    return value
end



function ScreenScreen:MakeRadio(b_data)
    local btn = Widget("radio")

    btn.text = btn:AddChild(Text(HEADERFONT, 40, b_data.label, UICOLOURS.BLACK))
    local width = btn.text:GetRegionSize()
    btn.text:SetPosition(width/2-15, 0)
    
    btn.arr_l = btn:AddChild(ImageButton("images/quagmire_recipebook.xml", "arrow2_left.tex", "arrow2_left_over.tex", "arrow_left_disabled.tex", "arrow2_left_down.tex", nil,{1,1}, {0,0}) )
    btn.arr_r = btn:AddChild(ImageButton("images/quagmire_recipebook.xml", "arrow2_right.tex", "arrow2_right_over.tex", "arrow_right_disabled.tex", "arrow2_right_down.tex", nil,{1,1}, {0,0}) )
    
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
                    b_data.fn(self.value[b_data], self.lines, self.data)
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

-- xml, tex or prefab
-- label
-- fn
function ScreenScreen:MakeImgStr(b_data)
    local w = Widget("imgstr")
    local btn = w:AddChild(TextBtn())
    w.ui_text = btn
    btn:SetText(b_data.label)
    btn:SetTextColour(UICOLOURS.BLACK)
    btn:SetFont(HEADERFONT)
    btn:SetTextSize(40)
    local _width = 280

    local line = btn:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex"))
    line:SetSize(5, _width)
    line:SetRotation(90)
    line:SetPosition(0, -25)
    function btn.uiSwitch()
    end
    function btn.switch(value)
        btn.uiSwitch(value)
        if type(b_data.fn) == "function" then
            b_data.fn(self.value[b_data], self.lines, self.data)
        end
    end
    btn:SetOnClick(function()
        btn.switch()
    end)
    btn:SetPosition(200, 0)

    local xml, tex = b_data.xml, b_data.tex
    if b_data.prefab then
        xml, tex = h_util:GetPrefabAsset(b_data.prefab)
    end
    local img = btn:AddChild(Image(xml, tex))
    w.ui_img = img
    -- img:SetScale(65 / btn:GetSize())
    h_util:ActivateBtnScale(img, 65)
    img:SetPosition(-200, 0)
    return w
end

function ScreenScreen:MakeBox(b_data)
    local btn = ImageButton("images/quagmire_recipebook.xml", "cookbook_known.tex")
    local btn_size = btn:GetSize()
    local btn_scale = 60 / btn_size
    btn:SetNormalScale(btn_scale)
    btn:SetFocusScale(btn_scale * 1.2)
    btn.img_or = btn:AddChild(Image("images/hx_or.xml", self.value[b_data] and "right.tex" or "wrong.tex"))
    btn.img_or:SetSize(45, 45)
    function btn.uiSwitch(value)
        self.value[b_data] = value
        btn.img_or:SetTexture("images/hx_or.xml", value and "right.tex" or "wrong.tex")
        btn.img_or:SetSize(45, 45)
    end
    function btn.switch(value)
        btn.uiSwitch(value)
        if type(b_data.fn) == "function" then
            b_data.fn(self.value[b_data], self.lines, self.data)
        end
    end
    btn:SetOnClick(function()
        btn.switch(not self.value[b_data])
    end)
    btn.labeltext = btn:AddChild(Text(HEADERFONT, 40, b_data.label, UICOLOURS.BLACK))
    btn.labeltext:SetPosition(200, 0)
    return btn
end

function ScreenScreen:MakeText(b_data)
    local w = Widget("textbtn")

    w.text = w:AddChild(Text(HEADERFONT, 40, b_data.label, UICOLOURS.BLACK))
    local width = w.text:GetRegionSize()
    w.text:SetPosition(width/2-15, 0)

    local ttn = TextBtn()
    w.showtext = w:AddChild(ttn)
    ttn:SetText(self.value[b_data] or "Not set")
    ttn:SetFont(HEADERFONT)
    ttn:SetTextSize(42)
    ttn:SetColour(UICOLOURS.BLACK)
    function w.uiSwitch(value)
        self.value[b_data] = value
        ttn:SetText(self.value[b_data] or "Not set")
    end
    function w.switch()
        if type(b_data.fn) == "function" then
            b_data.fn(self.value[b_data], self.lines, self.data)
        end
    end
    ttn:SetOnClick(function()
        w.switch()
    end)

    local _width = 230
    ttn:SetPosition(_width, 0)

    -- Just a background map
    local bgimage = ttn:AddChild(Image("images/quagmire_recipebook.xml", "cookbook_known.tex"))
    bgimage:SetSize(_width, 40)
    bgimage:SetTint(0, 0, 0, 0)

    local line = ttn:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex"))
    line:SetSize(5, _width)
    line:SetRotation(90)
    line:SetPosition(0, -25)


    return w
end


function ScreenScreen:OnControl(control, down)
    if ScreenScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end
end

return ScreenScreen
