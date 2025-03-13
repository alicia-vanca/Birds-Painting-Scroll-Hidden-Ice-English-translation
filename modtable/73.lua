local data_avatars = {}
AddClassPostConstruct("widgets/redux/serversaveslot", function(self)
	local _SetSaveSlot = self.SetSaveSlot
    self.SetSaveSlot = function(self, ...)
        _SetSaveSlot(self, ...)
        if self.serverslotscreen then
            local character_atlas, character = self.serverslotscreen:GetCharacterPortrait(self.slot)
            if self.slot ~= -1 and character == "mod" then
                local character_name = ShardSaveGameIndex:GetSlotCharacter(self.slot)
                if character_name then
                    if not data_avatars[character_name] then
                        data_avatars[character_name] = {}
                        local mods = ShardSaveGameIndex:GetSlotEnabledServerMods(self.slot)
                        t_util:GetElement(mods or {}, function(modname)
                            -- The server mod does not understand, here is a mod annotation of workshop-3225961625
                            -- Archive picture
                            local path1 = MODS_ROOT .. modname .. "/images/saveslot_portraits/" .. character_name .. ".xml" 
                             -- Avatar displayed by tab key characters list
                            local path2 = MODS_ROOT .. modname .. "/images/avatars/avatar_" .. character_name .. ".xml"
                            local xml, tex
                            if kleifileexists(path1) then
                                xml = path1
                                tex = character_name..".tex"
                            elseif kleifileexists(path2) then
                                xml = path2
                                tex = "avatar_" .. character_name..".tex"
                            end
                            if xml then
                                local pref = Prefab("modavatar_"..character_name, nil, {Asset("ATLAS", xml)}, nil, true)
                                RegisterSinglePrefab(pref)
                                TheSim:LoadPrefabs({pref.name})
                                data_avatars[character_name] = {xml = xml, tex = tex}
                                return true
                            end
                        end)
                    end
                    -- There is a bug, if there are two characters of the same name in different mods, it may not be displayed
                    local xml, tex = data_avatars[character_name].xml, data_avatars[character_name].tex
                    if xml and t_util:GetRecur(self, "character_portrait.title_portrait.SetTexture") then
                        self.character_portrait.title_portrait:SetTexture(xml, tex)
                    end
                end
            end
        end
    end
end)