local ctitle = "Bird painting roll · smart mod 󰀏"
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
        if isAssignmentError(errors_highlight) then
            text = "This error is because you have a server mods conflict, causing the master and cave to be out of sync.\n\n\n"..text
            self.additionaltext:SetString("This crash is not caused by Bird Painting! Please restart the game! \n Mod crash feedback QQ group: 941438122")
            -- self.additionaltext:SetString("Search [ 擦屁股 ] in the workshop, subscribe and enable to fix!")
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
