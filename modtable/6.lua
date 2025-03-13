local ctitle = "Bird painting roll · smart mod 󰀏"
local errors_exceed = {"SpawnPrefab", "mainfunctions", "ClonePrefab", "PopulateRecipeDetailPanel"}
local errors_highlight = {"componentactions", "UnregisterComponentActions", "highlight"}
AddClassPostConstruct("widgets/scripterrorwidget", function(self, title, text, buttons, texthalign, additionaltext, ...)
    -- Hijacking button
    local menu_children = self.menu and self.menu:GetChildren() or {}
    t_util:GetElement(menu_children, function(btn)
        if btn:GetText() == STRINGS.UI.MAINSCREEN.MODFORUMS then
            btn:SetOnClick(function()
                TheSim:OpenDocumentsFolder()
            end)
            btn.text:SetString("Log folder")
            return true
        end
    end)
    
    if self.text and self.title and self.additionaltext and text and title then
        local pattern = "/mods/([^/]+)/"

        local function isAssignmentError(errstrs)
            for _, fstr in pairs(errstrs)do
                if not text:find(fstr) then
                    return false
                end
            end
            return text:match(pattern) or true
        end
        -- Overlapping
        local ee_mod= isAssignmentError(errors_exceed)
        if type(ee_mod)=="string" then
            local mods_ban = s_mana:GetSettingLine("sw_info", true)
            s_mana:SaveSettingLine("sw_info", mods_ban, {[ee_mod] = 0})
            text = "This error has been fixed by this mod by itself! Please restart the game!\n\n\n"..text
            self.additionaltext:SetString("The collapse has been automatically repaired! Please restart the game!\nmod crash feedback QQ group: 941438122")
        elseif isAssignmentError(errors_highlight) then
            text = "This error is because you have a conflict server mod, which leads to different from the lord.\n\n\n"..text
            self.additionaltext:SetString("This collapse is not caused by painting! Please check yourself!\nper other collapse feedback QQ group: 941438122")
        end

        
        -- Mod replacement
        local mods_name = {}
        for match in string.gmatch(text, pattern) do
            if not table.contains(mods_name, match) then
                table.insert(mods_name, match)
            end
        end
        t_util:IPairs(mods_name, function(modpath)
            local mod = KnownModIndex:GetModInfo(modpath)
            local name = mod and mod.name
            local version = mod and mod.version
            if name and version then
                text = string.gsub(text, modpath:gsub("[%(%)%.%%%+%-%*%?%[%]%{%}%%]", function(c)
                    return "%" .. c
                end), modpath.."【"..name..version.."】")
            end
        end)
        if #mods_name > 0 then
            self.text:SetString(text)
            self.title:SetString(ctitle)
        end
    end
end)
