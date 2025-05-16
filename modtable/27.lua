-- Crafting Menu Information
if m_util:IsServer() then return end
local default_data = {
    size_img = 48,
    modfancy = true,
    showcode = true,
}
local save_id, str_show = "sw_craft", "Crafting Info"
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local id_craft, id_func_prefab = "CRAFT", "func_info"
local screen_data = {}

AddClassPostConstruct("widgets/redux/craftingmenu_details", function (self)
    local _PopulateRecipeDetailPanel = self.PopulateRecipeDetailPanel    
    self.PopulateRecipeDetailPanel = function(self, data, skin_name, ...)        
        local re = _PopulateRecipeDetailPanel(self, data, skin_name, ...)
        if self.crafting_hud and self.crafting_hud:IsCraftingOpen() then
            local prefab = data and data.recipe and data.recipe.name
            if type(prefab) == "string" and self.panel_width then
                local _prefab = prefab
                prefab = data.recipe.product or ""
                if self.i_p then
                    self.i_p:Kill()
                end
                self.i_p = self:AddChild(Widget("info_panel"))
                self.i_p:SetPosition(-self.panel_width / 4, -120)
                local width = self.panel_width/2
                local mod = m_util:IsModPrefab(prefab)
                local modname = mod and mod.modname
                local modfancy = modname and GetModFancyName(modname)
                local INFO = {}
                t_util:IPairs(m_util:GetData(id_craft) or {}, function(data)
                    local ret = data[id_func_prefab] and data[id_func_prefab](prefab, modfancy, self)
                    INFO = ret and t_util:MergeList(INFO, data.batch and ret or {ret}) or INFO
                end)
                local col_num, line_num = 0, 0
                t_util:IPairs(INFO, function(info)
                    local xml, tex = h_util:GetPrefabAsset(info.img)
                    if not (xml and type(info.text)=="string") then return end
                    local w = self.i_p:AddChild(Widget("info_one"))
                    w.img = w:AddChild(Image(xml, tex))
                    local size_img = info.size_img or save_data.size_img
                    w.img:ScaleToSize(size_img, size_img)
                    local color_text = info.color_text or h_util:GetRGB("白色")
                    local font_text = info.font_text or HEADERFONT
                    local length = info.length or 1
                    if length == 1 and col_num == 1 then
                        col_num = 2
                    else
                        col_num = 1
                        line_num = line_num + 1
                    end
                    local size_text = length == 2 and 24 or 22
                    w.text = w:AddChild(Text(font_text, size_text, info.text, color_text))
                    local posx_w = col_num == 1 and width/14-width/2 or width/14
                    local posy_w = -(line_num-1)*50
                    local posx_text = w.text:GetRegionSize()/(length == 1 and 4 or 2)+size_img
                    w:SetPosition(posx_w, posy_w)
                    w.text:SetPosition(posx_text, 0)
                    if type(info.func) == "function" then
                        info.func(w, info)
                    end
                    if type(info.hover) == "string" then
                        w.img:SetHoverText(info.hover)
                    end
                    if info.url then
                        h_util:BindMouseClick(w.img, {
                            [MOUSEBUTTON_LEFT] = function()
                                VisitURL(info.url, true)
                            end
                        })
                    end
                end)
            end
        end
        return re
    end
end)



local function GetScreenData()
    return m_util:GetData(id_craft) or {}
end
m_util:AddBindShowScreen(save_id, str_show, "bookstation", STRINGS.LMB .. 'Advanced Settings', m_util:AddBindShowScreen({
    title = str_show,
    id = "hx_" .. save_id,
    data = GetScreenData,
}))

-- Provided Interface m_util:AddGameData("CRAFT", "Add content id here", data}
-- data includes:
-- Basic showscreenbox item
-- Required:
-- func_info(prefab, modfancy, ui)
-- Optional:
--- number:priority The larger the better
--- number:length Half line when 1, full line when 2
--- table:color_text Text color
--- boolean:batch Whether to add in batches


-- func_info
--- Required:
--- string:img
--- string:text
--- Optional:
--- function:func Callback info_one(w, info)
--- number: size_img
--- string: font_text
--- string:url
--- string/function:hover Floating prompt information
-- Default function
m_util:AddGameData(id_craft, "modfancy", {
    id = "modfancy",
    label = "Display Mod Info",
    hover = "Whether to display which mod the item belongs to",
    default = fn_get,
    fn = fn_save("modfancy"),
    [id_func_prefab] = function(prefab, modfancy)
        if not (save_data.modfancy and modfancy) then return end
        return {
            img = "coin1",
            text = c_util:TruncateChineseString(modfancy, 11),
            color_text = UICOLOURS.GOLD_SELECTED,
            hover = "Mod info",
            length = 2,
        }
    end,
    priority = -100,
})

m_util:AddGameData(id_craft, "showcode", {
    id = "showcode",
    label = "Display Wiki Code",
    hover = "Whether to display item code\nAnd click to jump to search",
    default = fn_get,
    fn = fn_save("showcode"),
    [id_func_prefab] = function(prefab, modfancy)
        if not save_data.showcode then return end
        local url = "https://dontstarve.wiki.gg/wiki/"..e_util:GetPrefabName(prefab).."/DST"
        if modfancy then
            if c_util:IsStrContains(modfancy, "能力勋章") then
                url = "https://www.guanziheng.com/"
            elseif c_util:IsStrContains(modfancy, "小穹") then
                url = "http://wiki.flapi.cn/"
            else
                url = "https://search.bilibili.com/all?keyword="..modfancy
            end
        end
        return {
            img = "icon_stack",
            text = prefab,
            color_text = UICOLOURS.GOLD_SELECTED,
            url = url,
            hover = STRINGS.LMB .. ' Query wiki',
            length = 2,
        }
    end,
    priority = -200,
})