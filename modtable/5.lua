local save_id,str_unlock = "sw_unlock", "Developer"
local default_data = {
    hover = false,
    zh_cn = true,
    console = true,
    hash = false,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local function PlantRegistry()
    local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
    local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
    local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS
    local TPR = ThePlantRegistry
    local function unLockPlant(defs)
        t_util:Pairs(defs, function(plant, data)
            local info = data.plantregistryinfo
            if type(info) == "table" then
                t_util:NumElement(#info, data, function(stage)
                    TPR:LearnPlantStage(plant, stage)
                end)
            end
        end)
    end
    local function UnLockFertilizer(defs)
        t_util:Pairs(defs, function(fertilizer)
            TPR:LearnFertilizer(fertilizer)
        end)
    end
    unLockPlant(PLANT_DEFS)
    unLockPlant(WEED_DEFS)
    UnLockFertilizer(FERTILIZER_DEFS)

    local pr = require "screens/plantregistrypopupscreen"
    TheFrontEnd:PushScreen(pr(ThePlayer))
end




i_util:AddHoverOverFunc(function(str, player, item_inv, item_world)
    if not save_data.hover then
        return
    end
    local item = item_inv or item_world
    local picker = t_util:GetRecur(player, "components.playeractionpicker")
    if not (item and picker and item.prefab) then
        return
    end
    local prefab = item.prefab

    if item_world then
        local lmb, rmb = picker:DoGetMouseActions(item:GetPosition(), item)
        local lid, rid = t_util:GetRecur(lmb or {}, "action.id"), t_util:GetRecur(rmb or {}, "action.id")
        if rid then
            str = STRINGS.RMB .. rid .. "\n" .. str
        end
        if lid then
            str = STRINGS.LMB .. lid .. (rid and " " or "\n") .. str
        end
        local dist = e_util:GetDist(item_world)
        if dist then
            prefab = prefab .. " " .. string.format("%.2f", dist)
        end
    elseif e_util:IsValid(item_inv) then
        local rid = t_util:GetRecur(p_util:GetAction("inv", nil, true, item) or {}, "action.id")
        if rid then
            str = STRINGS.RMB .. rid .. "\n" .. str
        end
    end
    str = prefab .. "\n" .. str

    return str
end)
local ismodder = m_util:IsHuxi()
local screen_data = {{
    id = "scrapbook",
    label = "Illustrate",
    fn = function()
        -- TheScrapbookPartitions:DebugDeleteAllData()
        TheScrapbookPartitions:DebugSeenEverything()
        TheScrapbookPartitions:DebugUnlockEverything()
        m_util:PopShowScreen()
        h_util:PlaySound("learn_map")
    end,
    hover = "Unlock the full map",
    default = true
}, {
    id = "plantregistry",
    label = "Plant registry unlock",
    fn = function()
        PlantRegistry()
        m_util:PopShowScreen()
        h_util:PlaySound("learn_map")
    end,
    hover = "Gardening atlas fully unlocked",
    default = true
}, {
    id = "skilltree",
    label = "Skill tree unlock",
    fn = function()
        require("debugcommands")
        d_resetskilltree()
        m_util:PopShowScreen()
        h_util:PlaySound("learn_map")
    end,
    hover = "Reset and unlock the local all-skill tree\nthe skill tree to unlock the server, please use the T key",
    default = true
}, {
    id = "hover",
    fn = fn_save("hover"),
    label = "View item prefab",
    hover = "When the mouse moves over an entity, relevant information is displayed",
    default = fn_get
}, {
    id = "console",
    fn = fn_save("console"),
    label = "Console enhancement",
    hover = "Disable console closing while holding Shift",
    default = fn_get
}, {
    id = "hash",
    fn = fn_save("hash"),
    label = "Hash verification",
    hover = "Whether to enable hash verification of game files",
    default = fn_get
}, {
    id = "i_am_modder",
    label = ismodder and "Welcome, developer!" or "Developer option (disable)",
    fn = function(_, btns)
        h_util:CreatePopupWithClose("Developer option",
            ismodder and "Warning: the game will be closed immediately after giving up permissions!" or
                "Warning: the game will be closed immediately after obtaining permissions!\nthis authors, please do not turn on authority!", {{
                text = "Cancel"
            }, ismodder and {
                text = "Determine the closed authority",
                cb = function()
                    s_mana:SaveSettingLine("i_am_modder", {})
                    btns.i_am_modder.labeltext:SetString("Permissions have been closed")
                    i_util:DoTaskInTime(3, function()
                        DoRestart(true)
                    end)
                end
            } or {
                text = "I have confirmed the risk!",
                cb = function()
                    s_mana:SaveSettingLine("i_am_modder", {
                        ismodder = true
                    })
                    btns.i_am_modder.labeltext:SetString("Obtaining permissions")
                    i_util:DoTaskInTime(3, function()
                        DoRestart(true)
                    end)
                end
            }})
    end,
    hover = "It will turn on the mod test environment. please do not open\nWarning: non-developer, do not open this function!",
    default = function()
        return ismodder
    end
}}

-- Skill tree translation
local function fn_zhch_skilltree(t_zhch)
    local skilltree_def = require "prefabs/skilltree_defs"
    t_util:Pairs(t_zhch.SKILLTREE, function(PREFAB, SKILLS_T)
        local def_data = skilltree_def.SKILLTREE_DEFS[PREFAB:lower()]
        t_util:Pairs(def_data or {}, function(name_skill, skill)
            local title = name_skill:upper().."_TITLE"
            local desc = name_skill:upper().."_DESC"
            if skill.desc and SKILLS_T[desc] then
                skill.desc = SKILLS_T[desc]
            end
            if skill.title and SKILLS_T[title] then
                skill.title = SKILLS_T[title]
            end
        end)
    end)
end

-- Load the data from table t2 into table t1
local function fn_strrep(t1, t2)
    t_util:Pairs(t2, function(k, v)
        if type(t1)~="table" or not t1[k] then return end
        local tpv = type(v)
        if tpv == "table" then
            fn_strrep(t1[k], v)
        elseif tpv == "string" then
            t1[k] = v
        end
    end)
end
-- Search t2 for the data needed by t1
local function fn_strrep2(t1, t2)
    t_util:Pairs(t1, function(k, v)
        local val = t2[k]
        local tpv, tpval = type(v), type(val)
        if tpv == "table" and tpval == tpv then
            fn_strrep2(v, val)
        elseif tpv == "string" and tpval == tpv then
            t1[k] =val
        end
    end)
end

local STRINGS_BETA = require "data/language_beta"
if m_util:IsBata() == tostring(STRINGS_BETA.APP_VERSION) then
    -- Back up old data
    local STRINGS_ORI = {}
    t_util:EasyCopy(STRINGS_ORI, STRINGS_BETA)

    fn_strrep2(STRINGS_ORI, STRINGS)

    table.insert(screen_data, {
        id = "zh_cn",
        label = "Test server Chinese version",
        hover = "Part of the content of the test server will be translated into Chinese",
        fn = function(val)
            fn_save("zh_cn")(val)
            fn_strrep(STRINGS, val and STRINGS_BETA or STRINGS_ORI)
            fn_zhch_skilltree(val and STRINGS_BETA or STRINGS_ORI)
        end,
        default = fn_get,
    })
    if save_data.zh_cn then
        fn_strrep(STRINGS, STRINGS_BETA)
        fn_zhch_skilltree(STRINGS_BETA)
    end
end




AddClassPostConstruct("screens/consolescreen", function(self)
    local _Close = self.Close
    function self:Close(...)
        if save_data.console and TheInput:IsKeyDown(KEY_SHIFT) then
            return
        end
        return _Close(self, ...)
    end
end)

local _ShowBadHashUI = ShowBadHashUI
function _G.ShowBadHashUI()
    return save_data.hash and _ShowBadHashUI()
end

m_util:AddBindShowScreen("sw_unlock", str_unlock, "blueprint_rare", "Unlock some things and Developer options", {
    title = str_unlock,
    id = save_id,
    data = screen_data
}, nil, 9996)

