local g_util = require "util/fn_gallery"
local m_util = require "util/modutil"
local h_util = require "util/hudutil"
local save_data = require("util/fn_hxcb").save_data
local i_util = require "util/inpututil"
local t_util = require "util/tableutil"


local cates = {
    {
        id = "all",
        icon = "filter_none",
        name = "All"..g_util.str_seemore,
        prefabs = g_util.equip_all,
        fn_rr = g_util.SeeMore("About Equipment", "If you cannot find the desired equipment in the right-hand categories, spawn one under the 'All' tab. After equipping it manually, the data will be recorded here."),
        hot = true,
    },
    {
        id = "hands",
        icon = "eslot_hands",
        name = "Handheld",
        prefabs = g_util.equip_eslot("hands"),
        hot = true,
    },
    {
        id = "body",
        icon = "eslot_body",
        name = "Body",
        prefabs = function()
            local prefabs = g_util.equip_eslot("body")()
            return t_util:SubIPairs(g_util.equip_costume(), prefabs)
        end,
        hot = true,
    },
    {
        id = "head",
        icon = "strawhat",
        name = "Head",
        prefabs = function()
            local prefabs = g_util.equip_eslot("head")()
            return t_util:SubIPairs(g_util.equip_costume(), prefabs)
        end,
        hot = true,
    },
    {
        id = "sculp",
        icon = "potato_oversized_waxed",
        name = "Heavy",
        prefabs = g_util.equip_eslot("sculp")
    },
    {
        id = "costume",
        icon = "mask_dollhat",
        name = "Costumes",
        prefabs = g_util.equip_costume
    },
    {
        id = "armor",
        icon = "armorwood",
        name = "Armor",
        prefabs = g_util.equip_armor
    },
    {
        id = "weapon",
        icon = "hambat",
        name = "Weapons",
        prefabs = g_util.equip_weapon
    },
    {
        id = "tool",
        icon = "axe",
        name = "Tools",
        prefabs = g_util.equip_tool
    },
    {
        id = "backpack",
        icon = "backpack",
        name = "Backpacks",
        prefabs = g_util.equip_backpack
    },
    {
        id = "clothing",
        icon = "trunkvest_winter",
        name = "Clothing",
        prefabs = g_util.equip_clothing
    },
    {
        id = "hat",
        icon = "winterhat",
        name = "Hats",
        prefabs = g_util.equip_hat
    },
}

if save_data.equipmem then
    table.insert(cates, 6,
    {
        id = "memory",
        icon = "slurper",
        name = "Memory"..g_util.str_seemore,
        prefabs = g_util.equip_memory,
        fn_rr = function()
            h_util:CreatePopupWithClose("About Memory", "When you equip items not listed here, such as test items or modded equipment, their data will be automatically saved here.", {
                {text = "Clear Memory", cb = function()
                    i_util:DoTaskInTime(.1, g_util.equip_clear)
                end},
                {text = h_util.ok},
            })
        end
    })
end
table.insert(cates, 
    {
        id = "sew",
        icon = "sewing_kit",
        name = "Repair Materials"..g_util.str_seemore,
        prefabs = g_util.equip_sew,
        fn_rr = g_util.SeeMore("Feature Link", "Repair materials used by the Auto-Repair feature will also appear here.")
    })


if m_util:IsMilker() and false then
    table.insert(cates, {
        id = "error",
        icon = "fused_shadeling_bomb",
        name = "Crash",
        prefabs = g_util.equip_eslot("error")
    })
end


return {
    default = "hands",
    cates = cates,
}