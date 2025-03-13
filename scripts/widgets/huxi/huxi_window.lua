local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TextBtn = require "widgets/textbutton"
local Text = require "widgets/text"
local c_util, e_util, h_util, m_util, t_util, s_mana  = 
require "util/calcutil",
require "util/entutil",
require "util/hudutil",
require "util/modutil",
require "util/tableutil",
require "util/settingmanager"


local save_id, str_title = "mainboard", "Icon or panel settings"
local size_default, cate_default = 55, "icon"
local default_data = {
    size = size_default,
    cate = m_util:IsHuxi() and "charlie" or cate_default,
    hide = false,
    text_color = "Sand tan",
    num_col = 6,
    text_size = 10,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

-------------------------------------------------------------------------------------------------------
local HuxiWindow = Class(Widget, function(self)
    Widget._ctor(self, "HuxiWindow")
    self.root = self:AddChild(Widget("root"))
    

    self.height = h_util.screen_y*0.82
    self.width = self.height * 0.78
    self.spacing_y = self.width / 5.8
    self.split_height = 35
    self.margin_x = self.width / 66
    self.margin_y = self.width / 14

    self.num_line = math.floor((self.height - self.split_height)/self.spacing_y)+1
    self.btn_size = self.width / 10.1

    self.page = 1

    self.root:SetPosition(h_util.screen_x*0.77, h_util.screen_y*0.528)
    self._base.Hide(self)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)
end)


function HuxiWindow:MakeFrame()
    local w = Widget("huxi_menu_frame")

    local width, height = self.width, self.height
    local atlas = resolvefilepath(CRAFTING_ATLAS)

    -- Title
    self.title_panel = w:AddChild(TextBtn())
    self.title_panel:SetFont(UIFONT)
    self.title_panel:SetText(Mod_ShroomMilk.Mod["藏冰"].name)
    self.title_panel:SetTextSize(28)
    self.title_panel:SetColour(UICOLOURS.WHITE)
    -- self.title_panel:SetOnClick(function()
    --     -- self:CloseIt()
    --     self.title_panel:SetText(self.GetQuotation())
    -- end)
    self.title_panel:SetPosition(0, height / 2 - 13)

    -- Background
    local fill = w:AddChild(Image(atlas, "backing.tex"))
    fill:ScaleToSize(width + 10, height + 18)
    fill:SetTint(1, 1, 1, 0.3)

    -- Four edges up and down, left, left, left and right
    local left = w:AddChild(Image(atlas, "side.tex"))
    local right = w:AddChild(Image(atlas, "side.tex"))
    local top = w:AddChild(Image(atlas, "top.tex"))
    local bottom = w:AddChild(Image(atlas, "bottom.tex"))
    -- Split
    local itemlist_split = w:AddChild(Image(atlas, "horizontal_bar.tex"))

    left:SetPosition(-width / 2 - 8, 1)
    right:SetPosition(width / 2 + 8, 1)
    top:SetPosition(0, height / 2 + 10)
    bottom:SetPosition(0, -height / 2 - 8)

    left:ScaleToSize(-26, -(height - 20))
    right:ScaleToSize(26, height - 20)
    top:ScaleToSize(width+33, 38)
    bottom:ScaleToSize(width+33, 38)

    local splitline_y = height / 2 - self.split_height
    itemlist_split:SetPosition(0, splitline_y)
    itemlist_split:ScaleToSize(width, 15)

    -- Arrow
    self.arr_l = w:AddChild(ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil,
        nil, nil, { 1, 1 }, { 0, 0 }))
    self.arr_r = w:AddChild(ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil,
        nil, nil, { 1, 1 }, { 0, 0 }))
    local arrow_size = self.arr_l:GetSize()
    local arrow_scale = 40 / arrow_size
    self.arr_r:SetNormalScale(arrow_scale)
    self.arr_r:SetFocusScale(arrow_scale * 1.2)
    self.arr_l:SetNormalScale(arrow_scale)
    self.arr_l:SetFocusScale(arrow_scale * 1.2)
    self.arr_r:SetHoverText("Next page")
    self.arr_l:SetHoverText("Last page")

    local move_x, move_y = self.width/2.5, self.split_height/2+splitline_y+3
    self.arr_l:SetPosition(-move_x, move_y)
    self.arr_l:SetScale(1, .5, 1)
    self.arr_r:SetPosition(move_x, move_y)
    self.arr_r:SetScale(-1, .5, 1)


    self.arr_l:SetOnClick(function()
        self.page = self.page - 1
        self:MakeButtons()
    end)
    self.arr_r:SetOnClick(function()
        self.page = self.page + 1
        self:MakeButtons()
    end)

    self.title_panel:MoveToFront()
    return w
end


-- The button must be created after makeframe
function HuxiWindow:MakeButtons()
    if self.btns then
        self.btns:Kill()
    end
    self.btns = self.root:AddChild(Widget("huxi_menu_buttons"))
    local num_col = save_data.num_col
    local spacing_x = (self.width - 2 * self.margin_x) / num_col
    local x_init = self.margin_x + spacing_x / 2
    local y_init = -self.margin_y

    -- Data load
    local icons_data = t_util:PairToIPair(m_util:GetIcons(), function(_, icondata)
        return icondata
    end)
    table.sort(icons_data, function(a, b)
        if a.priority == b.priority then
            return a.name > b.name      -- No name sorting in the chinese environment
        else
            return a.priority > b.priority
        end
    end)
    local num_icon = self.num_line*save_data.num_col -- Number of single -page icons

    -- Arrow configuration
    self.arr_l:Show()
    self.arr_r:Show()
    local page = self.page
    if page <= 1 then
        self.arr_l:Hide()
    end
    if page*num_icon >= #icons_data then
        self.arr_r:Hide()
    end

    -- Construct icons
    for i = 1, num_icon do
        local nodot = (page - 1) * num_icon + i
        local icon = icons_data[nodot]
        if not icon then break end
        local x_pos = x_init + ((i - 1) % num_col) * spacing_x
        local y_pos = y_init - math.floor((i - 1) / num_col) * self.spacing_y
        local cus_btn = self.btns:AddChild(self:CustomButton(icon))
        cus_btn:SetPosition(x_pos, y_pos)
    end
    self.btns:SetPosition(-self.width / 2, self.height / 2 - 30)
end

function HuxiWindow:SetButtonSize(img)
    local sizeX, sizeY = img:GetSize()
    local trans_scale = math.min(self.btn_size / sizeX, self.btn_size / sizeY)
    img:SetNormalScale(trans_scale)
    img:SetFocusScale(trans_scale * 1.2)
end

function HuxiWindow:CustomButton(icon)
    local w = Widget("huxi_dear_btn")
    
    -- Because there is a default icon, the icon is queried when it is needed, rather than when it is originally registered
    icon.xml, icon.tex = h_util:GetPrefabAsset("unknown")
    local icondata = icon.imgdata
    if type(icondata) == "table" then
        local xml, tex = icondata.xml, icondata.tex
        if type(xml) == "string" and type(tex) == "string" and TheSim:AtlasContains(xml, tex) then
            icon.xml, icon.tex = xml, tex
        end
    elseif type(icondata) == "string" then
        local xml, tex = h_util:GetPrefabAsset(icondata)
        if xml then
            icon.xml, icon.tex = xml, tex
        end
    end
    
    w.img = w:AddChild(ImageButton(icon.xml, icon.tex))
    self:SetButtonSize(w.img)
    w.destxt = w:AddChild(Text(UIFONT, self.btn_size / 2 * save_data.text_size * 0.1, icon.name, h_util:GetRGB("White")))
    w.destxt:SetPosition(0, -self.btn_size*0.85)
    
    local _OnMouseButton = w.img.OnMouseButton
    w.img.OnMouseButton = function(ui, press, down, ...)
        local result = _OnMouseButton(ui, press, down, ...)
        if not down then
            if press == MOUSEBUTTON_LEFT and type(icon.func_left)=="function" then
                icon.func_left()
                if icon.close then self:Hide() end
            elseif press == MOUSEBUTTON_RIGHT and type(icon.func_right)=="function" then
                icon.func_right()
                if icon.close then self:Hide() end
            end
        end
        return result
    end
    local _OnGainFocus = w.img.OnGainFocus
    w.img.OnGainFocus = function(...)
        _OnGainFocus(w.img, ...)
        w.destxt:SetColour(unpack(h_util:GetRGB(save_data.text_color)))
        self.title_panel:SetText(icon.text)
    end
    local _OnLoseFocus = w.img.OnLoseFocus
    w.img.OnLoseFocus = function(...)
        _OnLoseFocus(w.img, ...)
        w.destxt:SetColour(unpack(h_util:GetRGB("White")))
    end

    return w
end

local function get_shadeds()
    local ctrl = ThePlayer and ThePlayer.HUD and ThePlayer.HUD.controls
    return ctrl and t_util:IPairFilter({"minimap_small", "clock", "status", "seasonclock", "season"}, function(uiname)
        return ctrl[uiname]
    end)
end

function HuxiWindow:Hide(...)
    t_util:IPairs(get_shadeds() or {}, function(ui)
        ui:Show()
    end)
    self._base.Hide(self, ...)
    TheCamera:PushScreenHOffset(self, 0)
end

function HuxiWindow:Show(...)
    t_util:IPairs(get_shadeds() or {}, function(ui)
        ui:Hide()
    end)
    
    if m_util:GetRefresh() or not self.frame then
        if self.frame then
            self.frame:Kill()
        end
        self.frame = self.root:AddChild(self:MakeFrame())
        self:MakeButtons()
    end
    m_util:RefreshIcon(false)
    self.title_panel:SetText(Mod_ShroomMilk.Mod["藏冰"].name)
    self:ChanStyle()
    self._base.Show(self, ...)
    TheCamera:PushScreenHOffset(self, 0.17 * RESOLUTION_X)
end

function HuxiWindow:ChanStyle()
    local rate = math.random()
    local iswinters_feast = IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST)
    if iswinters_feast and rate < 0.002 then
        local hats = t_util:IPairFilter({"winterhat", "winterhat_black_davys", "winterhat_fancy_puppy", "winterhat_pink_hibiscus", "winterhat_plum_pudding", "winterhat_rooster", "winterhat_stocking_cap_green_forest"}, function(hat)
            local xml, tex = h_util:GetPrefabAsset(hat)
            return xml and {xml, tex}
        end)
        t_util:Pairs(self.btns:GetChildren(), function(btn)
            if t_util:GetRecur(btn, "img.SetTextures") then
                local _, skin = t_util:GetRandomItem(hats)
                btn.img:SetTextures(skin[1], skin[2])
                self:SetButtonSize(btn.img)
            end
        end)
        self.title_panel:SetText("󰀜  Happy holidays!  󰀜")
        m_util:RefreshIcon(true)
    end
end

return HuxiWindow
