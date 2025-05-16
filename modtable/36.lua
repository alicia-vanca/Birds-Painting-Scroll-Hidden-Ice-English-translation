-- Icon and Code Search
-- This is a developer mod feature!
local save_id, str_show = "sw_imgsearch", "Icon Library"
local TEMPLATES = require "widgets/redux/templates"


local function fn_left()
    local function fn_setprefab(prefab, ui)
        if not (h_util:IsValid(ui) and ui.detail) then return end
        if ui.grid then ui.grid:RefreshView() end
        if type(prefab)=="string" and prefab~="" then
            ui.detail.icon_show.SetPrefabIcon({prefab = prefab})
            local name = e_util:GetPrefabName(prefab)
            name = name == e_util.NullName and "" or name
            ui.detail.text_show:SetString(name.."\n"..prefab)
            ui.detail.btn_ann:SetOnClick(function()
                print(prefab, name)
                local str = name == "" and "Icon code: " or name.."'s icon code: "
                u_util:Say(STRINGS.LMB.." "..str..prefab, nil, "net")
            end)
            ui.detail.btn_ann:Enable()
        else
            ui.detail.icon_show.SetPrefabIcon({prefab = "cookbook_missing"})
            ui.detail.text_show:SetString("")
            ui.detail.btn_ann:Disable()
        end
    end
    local function GetPrefabsData(prefabs)
        if not prefabs then
            prefabs = t_util:PairToIPair(_G.Prefabs or {}, function(prefab)
                return prefab
            end)
        end
        table.sort(prefabs, function(a, b)
            return a < b
        end)
        return t_util:IPairFilter(prefabs, function(prefab)
            local xml, tex, name = h_util:GetPrefabAsset(prefab)
            return xml and {
                xml = xml,
                tex = tex,
                name = name,
                prefab = prefab,
                hover = name == e_util.NullName and prefab or name.."\n"..prefab
            }
        end)
    end
    local context_grid = {prefab = t_util:GetRecur(t_util, "ent.prefab")}
    local function fn_loadui(ui)
        ui.editline:SetPosition(-220, 165)
        ui.detail:SetPosition(305, 75)
        ui.detail:SetScale(1.1)
        ui.detail.btn_ann.image:SetTint(.4, 1, .4, 1) -- 1, 1, .5, 1
        ui.detail.btn_ann:SetPosition(0, -260)
        ui.grid:SetItemsData(GetPrefabsData())
        fn_setprefab(context_grid.prefab, ui)
    end
    local function fn_edited()
        local ui = h_util:GetLines()
        local textedit = t_util:GetRecur(ui, "editline.textedit.textbox")
        if not textedit then return end
        local text = c_util:TrimString(textedit:GetString())
        local p_data = GetPrefabsData()
        if text == "" then
            ui.grid:SetItemsData(p_data)
        else
            ui.grid:SetItemsData(t_util:IPairFilter(p_data, function(data)
                if data.prefab:find(text) then
                    return data
                else
                    if data.name ~= e_util.NullName and data.name:find(text) then
                        return data
                    end
                end
            end))
        end
    end
    local function fn_clear()
        local ui = h_util:GetLines()
        local textedit = t_util:GetRecur(ui, "editline.textedit.textbox")
        if textedit then
            textedit:SetString("")
            ui.grid:SetItemsData(GetPrefabsData())
        end
    end
    local function fn_btn_clear()
        return h_util:CreateImageButton({prefab = "delete", hover = "Clear Results", hover_meta = {offset_y = 50}, pos = {245}, size = 70, fn = fn_clear})
    end
    m_util:AddBindShowScreen({
        title = str_show,
        id = save_id,
        data = {},
        type = "player",
        data_create = {
            {
                id = "grid",
                name = "BuildGrid_PrefabButton",
                meta = {
                    context = context_grid,
                    fn_sel = fn_setprefab,
                }
            },{
                id = "editline",
            },{
                id = "textedit",
                pid = "editline",
                fn = function()
                    return h_util:CreateTextEdit({width = 380, height = 80, hover = "Enter the item's name or code", fn = fn_edited})
                end
            },{
                id = "btn_clear",
                pid = "editline",
                fn = fn_btn_clear,
            },{
                id = "btn_filter", -- A button that doesn't do much, as the input result can automatically search
                pid = "editline",
                fn = function()
                    return h_util:CreateImageButton({xml = HUD_ATLAS, tex = "magnifying_glass_off.tex", hover = "Click to Search", hover_meta = {offset_y = 50}, pos = {320}, size = 70, fn = fn_edited})
                end,
            },{
                id = "detail",
                name = "BuildGrid_PrefabDetail",
            },{
                id = "btn_ann",
                pid = "detail",
                fn = function()
                    return TEMPLATES.StandardButton(nil, "Click to Announce", {250, 80})
                end
            },
        },
        fn_line = fn_loadui,
    })()
end
m_util:AddBindIcon(str_show, "yellowmooneye", STRINGS.LMB .. "View Icon Code", true, fn_left, nil, 9989)
