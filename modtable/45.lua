local TE = require "widgets/redux/templates"
local Text = require "widgets/text"
local _ModListItem = TE.ModListItem
TE.ModListItem = function(...)
    local opt = _ModListItem(...)
    local _SetMod = opt.SetMod
    opt.SetMod = function(_, modname, modinfo, modstatus, isenabled, isfavorited)
        _SetMod(_, modname, modinfo, modstatus, isenabled, isfavorited)
        local _modname = modinfo and modinfo.name
        if _modname then
            opt.setfavorite.image:SetTint(unpack(h_util:GetRGB(_modname:find("Birds Painting Scroll") and "Purple" or "White")))
            if opt.addname then opt.addname:Kill() end
            local w, h = opt.name:GetRegionSize()
            opt.name:SetPosition(w * .5 - 75, 20, 0)
            opt.addname = opt.backing:AddChild(Text(CHATFONT, 18, "\n"..modname, UICOLOURS.GOLD_CLICKABLE))
            w, h = opt.addname:GetRegionSize()
            opt.addname:SetPosition(w * .5 - 75, -2, 0)
            if _modname:find("风华") then
                local ver = tonumber(modinfo.version)
                if ver and ver >= 4 then
                    opt.addname:SetString("󰀜")
                end
            end
        end
    end
    return opt
end