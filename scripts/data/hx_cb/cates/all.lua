local g_util = require "util/fn_gallery"
local t_util = require "util/tableutil"
local f_util = require "util/fn_hxcb"
local hxcb_tags = require "data/hx_cb/tags"
local hot_tags = t_util:IPairToPair(hxcb_tags, function(tag)
    return tag.id, tag.hot
end)

local cates = t_util:IPairToIPair({"all", "craft", "creature", "food", "equip", "items", "ground", "mod"}, function(id)
    return {
        id = id,
        icon = f_util:GetTagIcon(id) or "filter_none",
        name = f_util:GetTagName(id) or id,
        prefabs = g_util[id.."_all"] or {},
        hot = hot_tags[id],
    }
end)





table.insert(cates, {
    id = "color",
    icon = "recipe_unknown",
    name = "Missing Icons"..g_util.str_seemore,
    prefabs = g_util.color_all,
    nosort = true,
    fn_rr = g_util.SeeMore("Missing Icons", "Some items are not yet drawn or categorized; please wait for updates.")
})




return {
    default = "all",
    cates = cates,
}