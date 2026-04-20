local save_id,str_unlock = "sw_unlock", "Developer"
local default_data = {
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




local ismodder = m_util:IsHuxi()
local screen_data = {{
    id = "scrapbook",
    label = "Scrapbook Unlock",
    fn = function()
        
        TheScrapbookPartitions:DebugSeenEverything()
        TheScrapbookPartitions:DebugUnlockEverything()
        m_util:PopShowScreen()
        h_util:PlaySound("learn_map")
    end,
    hover = "Show full map",
    default = true
}, {
    id = "plantregistry",
    label = "Plant registry unlock",
    fn = function()
        PlantRegistry()
        m_util:PopShowScreen()
        h_util:PlaySound("learn_map")
    end,
    hover = "Fully unlock Gardening Atlas",
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
    hover = "Reset and fully unlock the local skill tree\nTo unlock the server's skill tree, press T",
    default = true
}, {
    id = "i_am_modder",
    label = ismodder and "Welcome, Developer!" or "Developer Options",
    fn = function(_, btns)
        h_util:CreatePopupWithClose("Developer option",
            ismodder and "Warning: The game will immediately close after revoking permissions!" or
                "Warning: The game will immediately close after obtaining permissions!\nNon-mod authors, do not enable this!", {{
                text = "Cancel"
            }, ismodder and {
                text = "Confirm revoke permissions",
                cb = function()
                    s_mana:SaveSettingLine("i_am_modder", {})
                    btns.i_am_modder.labeltext:SetString("Permissions Revoked")
                    i_util:DoTaskInTime(3, function()
                        DoRestart(true)
                    end)
                end
            } or {
                text = "I acknowledge the risks!",
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





m_util:AddBindShowScreen("sw_unlock", str_unlock, "blueprint_rare", "Local commands", {
    title = str_unlock,
    id = save_id,
    data = screen_data,
        icon = 
    {{
        id = "add",
        prefab = "mods",
        hover = "More features",
        fn = function()
            h_util:CreatePopupWithClose(nil, "This feature is not yet customized: full unlock recipes (Cooking Guide)")
        end,
    }}
}, nil, 9996)

