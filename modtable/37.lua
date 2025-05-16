-- Space Filter
local default_data = {
    prefabs = {"flower_evil"}
}
local save_id, str_show, img_show = "sw_space", "Space Filter", "stagehand"
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= ThePlayer then return end
    local _GetActionButtonAction = self.GetActionButtonAction
    self.GetActionButtonAction = function(self, ...)
        local act = _GetActionButtonAction(self, ...)
        if act and table.contains(save_data.prefabs, act.target and act.target.prefab) then
            return
        end
        return act
    end
end)

local function fn_showdata()
    return t_util:IPairToIPair(save_data.prefabs, function(prefab)
        local name = e_util:GetPrefabName(prefab)
        local label = name == e_util.NullName and prefab or name
        local data = {}
        if h_util:GetPrefabAsset(prefab) then
            data.type = "imgstr"
            data.prefab = prefab
            data.label = label
        else
            data.type = "textbtn"
            data.label = "Unknown Item: "
            data.default = label
        end
        return t_util:MergeMap({
            id = prefab,
            hover = "Item Code: "..prefab.."\nClick to remove this item from the filter!",
            fn = function()
                h_util:CreatePopupWithClose(str_show, "Are you sure you want to remove the filter for "..label.. "?", {{
                    text = h_util.no,
                }, {text = h_util.yes, cb = function()
                    t_util:Sub(save_data.prefabs, prefab)
                    fn_save()
                end}})
            end
        }, data)
    end)
end

local fn_screenadd = function()
    -- Pop up selection page
    m_util:PushPrefabScreen({
        text_title = "Select Items to Filter",
        text_btnok = "Add Filter",
        hover_btnok = "Add this item to the filter list",
        fn_btnok = function(prefab)
            t_util:Add(save_data.prefabs, prefab, true)
            fn_save()
        end
    })
end

local icondata = {
    {
        id = "add",
        prefab = "mods",
        hover = "Click to add items to be filtered by space!",
        fn = fn_screenadd,
    }
}

local fn_left = m_util:AddBindShowScreen{
    title = str_show,
    id = "hx_" .. save_id,
    data = fn_showdata,
    icon = icondata,
    help = 'Items shown here will not respond to space, but will respond to mouse click actions.\nClick the wrench button on the right to add filters, and click the item name below to remove filters.',
    fn_active = true,
}
m_util:AddBindConf(save_id, fn_left, nil, {str_show, img_show, STRINGS.LMB .. str_show..' Settings', true, fn_left})
