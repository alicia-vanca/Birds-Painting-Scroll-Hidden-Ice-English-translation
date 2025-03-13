local Widget = require "widgets/widget"
local Text = require "widgets/text"
local showprefab = (m_util:IsTurnOn("sw_info") == "code")
local Image = require "widgets/image"
local imgsize = 48
local mods_ban = s_mana:GetSettingLine("sw_info", true)
local maxLength = 11

AddClassPostConstruct("widgets/redux/craftingmenu_details", function (self)
    local _PopulateRecipeDetailPanel = self.PopulateRecipeDetailPanel    
    self.PopulateRecipeDetailPanel = function(self, data, skin_name, ...)        
        local re = _PopulateRecipeDetailPanel(self, data, skin_name, ...)
        if self.crafting_hud and self.crafting_hud:IsCraftingOpen() then
            local prefab = data and data.recipe and data.recipe.name
            if type(prefab) == "string" and self.panel_width then
                local _prefab = prefab
                if string.sub(prefab, 1, 10) == "transmute_" then
                    prefab = string.sub(prefab, 11)
                end
                if self.i_p then
                    self.i_p:Kill()
                end
                self.i_p = self:AddChild(Widget("info_panel"))
                self.i_p:SetPosition(-self.panel_width / 4, -120)
                local width = self.panel_width/2

                
                local mod_add
                local mod = m_util:IsModPrefab(_prefab)
                local modname = mod and mod.modname
                
                local getData = Mod_ShroomMilk.Func.getCopyData
                if getData and not (modname and mods_ban[modname]) then
                    local datas = getData(e_util:ClonePrefab(prefab))
                    for i, data in ipairs(datas)do
                        local w = self.i_p:AddChild(Widget("info_conn"))
                        local img = w:AddChild(Image(data.atlas, data.image))
                        img:ScaleToSize(imgsize, imgsize)
                        local text = w:AddChild(Text(HEADERFONT, 22, data.text, UICOLOURS.WHITE))
                        w:SetPosition(i%2==0 and width/14 or width/14-width/2, -math.floor((i-1)/2)*50)
                        text:SetPosition(imgsize + text:GetRegionSize()/4, 0)
                    end 
                end

                if modname then
                    local name = GetModFancyName(modname)
                    if name then
                        local xml, tex = h_util:GetPrefabAsset("coin1")
                        if xml and tex then
                            local count = table.count(self.i_p:GetChildren())
                            local w = self.i_p:AddChild(Widget("info_mod"))
                            local img = w:AddChild(Image(xml, tex))
                            img:ScaleToSize(imgsize, imgsize)
                            img:SetHoverText("Belonging mod")
                            name = c_util:TruncateChineseString(name, maxLength)
                            local text = w:AddChild(Text(HEADERFONT, 24, name, UICOLOURS.GOLD_SELECTED))
                            w:SetPosition(width/14-width/2, -math.floor((count+1)/2)*50)
                            text:SetPosition(imgsize + text:GetRegionSize()/2, 0)
                            mod_add = true
                        end
                    end
                end
                if not showprefab then
                    local count = table.count(self.i_p:GetChildren())
                    count = mod_add and count + 1 or count
                    local w = self.i_p:AddChild(Widget("info_code"))
                    local img = w:AddChild(Image(GetScrapbookIconAtlas("icon_stack.tex"), "icon_stack.tex"))
                    img:ScaleToSize(imgsize, imgsize)
                    img:SetHoverText("Item code")
                    local text = w:AddChild(Text(HEADERFONT, 24, prefab, UICOLOURS.GOLD_SELECTED))
                    w:SetPosition(width/14-width/2, -math.floor((count+1)/2)*50)
                    text:SetPosition(imgsize + text:GetRegionSize()/2, 0)
                end
            end
        end
        return re
    end
end)