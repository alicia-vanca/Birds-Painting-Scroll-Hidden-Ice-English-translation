local HGift = require "widgets/huxi/huxi_gift"
local HSkin = require "screens/huxi/skinhistory"
local save_id, string_skin = "sw_skinHistory", "Gift records"
local default_data = {
    pre = true,
    auto = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local skin_id = "skin_hy"
local skin_list = s_mana:GetSettingList(skin_id, true)


local skin_items = {}
AddPrefabPostInit("player_classified", function(inst)
    inst:ListenForEvent("giftsdirty", function()
        local item = TheInventory:GetUnopenedItems()[1]
        if not item then return end
        local prefab, id = item.item_type, item.item_id
        local rarity, rarity_cn, name, rgb = GetRarityForItem(prefab), GetModifiedRarityStringForItem(prefab), GetSkinName(prefab), GetColorForItem(prefab)
        local show_gift
        if save_data.pre and not table.contains(skin_items, id) then
            ChatHistory:AddToHistory(ChatTypes.Message, nil, nil, "Gift prediction", name.." (quality: "..rarity_cn.."）", rgb)
            table.insert(skin_items, id)
            show_gift = true
        end
        if save_data.auto then
            table.insert(skin_list, {
                skin = prefab,
                time = os.time(),
                type = "Weekly gift",
            })
            s_mana:SaveSettingList(skin_id, skin_list)
            TheInventory:SetItemOpened(id)
            show_gift = true
        end
        local ctrl = t_util:GetRecur(ThePlayer or {}, "HUD.controls")
        if ctrl and show_gift then
            ctrl:AddChild(HGift(prefab))
        end
    end)
end)

local giftitempopup = require("screens/giftitempopup")
local _RevealItem = giftitempopup.RevealItem
giftitempopup.RevealItem = function(self, ...)
    local ret = _RevealItem(self, ...)
    local prefab = self.item_name
    if prefab then
        table.insert(skin_list, {
            skin = prefab,
            time = os.time(),
            type = "Weekly gift",
        })
        -- m_util: print (prefab, 'Weekly gift')
        s_mana:SaveSettingList(skin_id, skin_list)
    end
    return ret
end

local gt_data = require("data/valuetable").gifttype_table
local thankyoupopup = require("screens/thankyoupopup")
local _OpenGift = thankyoupopup.OpenGift
thankyoupopup.OpenGift = function(self, ...)
    local ret = _OpenGift(self, ...)
    local item = self.items and self.current_item and self.items[self.current_item]
    if item then
        if item.item ~= "" then
            local prefab = item.item
            local tp = item.gifttype and gt_data[item.gifttype]
            if prefab then
                table.insert(skin_list, {
                    skin = prefab,
                    time = os.time(),
                    type = tp or "Thanks for playing",
                })
                -- m_util:print(prefab, tp)
                s_mana:SaveSettingList(skin_id, skin_list)
            end
        end
    end
    return ret
end


local screen_data = {
    {
        id = "pre",
        label = "Gift prediction",
        fn = fn_save("pre"),
        hover = "You can know in advance what kind of gift it is!",
        default = fn_get,
    },
    {
        id = "auto",
        label = "Automatically open gifts",
        fn = function(v)
            fn_save("auto")(v)
            local pc = v and ThePlayer and ThePlayer.player_classified
            if pc then
                pc:PushEvent("giftsdirty")
            end
        end,
        hover = "You can automatically open gifts without technology, and you can hang up with a god model to hang up and wait for gifts.",
        default = fn_get,
    }
}


local function fn()
    TheFrontEnd:PushScreen(HSkin(skin_list))
end
AddClassPostConstruct("screens/redux/playersummaryscreen", function(self)
    local TEMPLATES = require "widgets/redux/templates"
	self.bottom_root:AddChild(TEMPLATES.StandardButton(fn, "Historical gift data", {225, 40})):SetPosition(-300, 10)
end)
local func_right = m_util:AddBindShowScreen({
    title = string_skin,
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, fn, nil,
    {string_skin, "wardrobe_armoire", STRINGS.LMB .. "Gift records" .. STRINGS.RMB .. "Advanced settings", true, fn,
     func_right, 6000})