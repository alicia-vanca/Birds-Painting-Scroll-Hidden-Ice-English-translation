local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local h_util = require "util/hudutil"
local f_util = require "util/fn_hxcb"
local hxcb_tabs = require "data/hx_cb/tabs"
local ID_TAB_DEFAULT = "console"
local save_data = f_util.save_data
local m_util = require "util/modutil"


local CB = Class(Widget, function(self)
    Widget._ctor(self, "huxi_console_board")
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.width_bg, self.height_bg = 750, 500
    self.width_tab, self.height_tab = self.width_bg / 3.1, 55
    self.size_font = 22


    self:BuildUI()
end)

function CB:BuildUI(width_bg, height_bg)
    if h_util:IsValid(self.root) then
        self.root:Kill()
    end
    width_bg, height_bg = width_bg or self.width_bg, height_bg or self.height_bg
    self.width_bg, self.height_bg = width_bg, height_bg

    
    self:SetPosition(save_data.lright and 0 or -.09*h_util.screen_w, 0)
    self.root = self:AddChild(Widget("root"))

    self:BuildTabs()
    
    self.bg = self.root:AddChild(TEMPLATES.RectangleWindow(width_bg, height_bg))
    self.bg.top:Hide()
    
    

    
    self.tab_selected = f_util.load_data.id_tab and self.tabs[f_util.load_data.id_tab] or self.tabs[ID_TAB_DEFAULT]
    self.tab_selected:Select()
end


function CB:BuildTabs()
    self.dir_ul = self.root:AddChild(Widget("tabs"))
    self.dir_ul:SetPosition(-self.width_bg * .5 + self.width_tab * 0.5, self.height_bg * .5 + self.height_tab * 0.5 + 2)
    self.tabs = {}
    for i, data_tab in ipairs(hxcb_tabs) do
        local tab = self.dir_ul:AddChild(self:BuildTab(data_tab))
        self.tabs[data_tab.id] = tab
        tab:SetPosition((i - 1) * self.width_tab * .65, 0)
        tab:MoveToBack()
    end
end
function CB:BuildTab(data)
    local tab = ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex", nil, nil, nil,
        "quagmire_recipe_tab_active.tex")
    tab:ForceImageSize(self.width_tab, self.height_tab)
    tab.scale_on_focus = false
    tab:SetText(data.name or data.id)
    tab:SetTextSize(self.size_font + 5)
    tab:SetFont(HEADERFONT)
    tab:SetTextColour(UICOLOURS.GOLD)
    tab:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
    tab:SetTextSelectedColour(UICOLOURS.GOLD_SELECTED)
    tab.text:SetPosition(0, -2)
    tab.clickoffset = Vector3(0, -2, 0)
    tab:SetOnClick(function()
        self.tab_selected:Unselect()
        self.tab_selected = tab
        tab:Select()
        tab:MoveToFront()
    end)
    tab:SetOnSelect(function()
        tab:MoveToFront()
        f_util.load_data.id_tab = data.id
        if h_util:IsValid(self.tab_box) then
            self.tab_box:Kill()
        end
        local state, tab = pcall(require, "widgets/hx_cb/tabs/"..data.id)
        if state then
            self.tab_box = self.root:AddChild(tab(self))
        end
    end)
    return tab
end



function CB:OnControl(control, down)
    if down and h_util:IsValid(self.right_menu) and not self.right_menu.focus and table.contains({CONTROL_ACCEPT, CONTROL_SECONDARY}, control)then
        self.right_menu:Kill()
    end
	if CB._base.OnControl(self, control, down) then return true end
end


function CB:Show(...)
    self._base.Show(self, ...)
    
    f_util:FingerStop()
    
    if save_data.id_tag == "fav" and f_util:LoadCate("fav") == "all" then
        if h_util:IsValid(self.grid_cells) then
            self.grid_cells.SetPrefabs(require "util/fn_gallery".fav_all())
        end
    end
    
    if h_util:IsValid(self.right_menu) then
        self.right_menu:Kill()
    end
end

return CB
