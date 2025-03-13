local save_id, str_auto_read = "sw_autoread", "Automatic"..STRINGS.ACTIONS.READ
local default_data = {
    sw = true,
    timetick = 0,
    stop = false,
    tip = true,
    color = "Pink",
    find = true,
    range = 64,
    keep = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local book_tags = {"bookcabinet_item", "book"}

-- Register to the menu
m_util:AddRightMouseData(save_id, str_auto_read, "Whether to enable automatic reading", function()
    return save_data.sw
end, fn_save("sw"), {
    screen_data = {
        {
            id = "readme",
            label = "Use guide",
            fn = function()
                h_util:CreatePopupWithClose(str_auto_read.." · use guide",
                    "Hold down ctrl and click the book to automatically read the book \n (retain one durability)", {{
                        text = h_util.ok
                    }})
            end,
            hover = "Click to view the tutorial",
            default = true
        },{
            id = "timetick",
            label = "Reading interval:",
            fn = fn_save("timetick"),
            hover = "Set the interval between each reading",
            default = fn_get,
            type = "radio",
            data = t_util:BuildNumInsert(0, 60, 1, function(i)
                return {data = i, description = i == 0 and "Fastest" or i.." Sec"}
            end)
        },{
            id = "find",
            label = "Find books",
            fn = fn_save("find"),
            hover = "When there are no books to read, should we search for books in other containers?",
            default = fn_get
        },{
            id = "range",
            label = "Search range:",
            fn = fn_save("range"),
            hover = "Scope of search for books",
            default = fn_get,
            type = "radio",
            data = t_util:BuildNumInsert(4, 64, 4, function(i)
                return {data = i, description = i.." wall point"}
            end)
        },{
            id = "keep",
            label = "Durable retention",
            fn = fn_save("keep"),
            hover = "Whether the book retains the last durability",
            default = fn_get
        },{
            id = "stop",
            label = "No book termination",
            fn = fn_save("stop"),
            hover = "When there is no book available, it will end the reading automatically.",
            default = fn_get
        },{
            id = "tip",
            label = "Text prompt",
            fn = fn_save("tip"),
            hover = "Whether to display automatic reading and opening prompts",
            default = fn_get
        },{
            id = "color",
            label = "Prompt color:",
            fn = fn_save("color"),
            hover = "Prompt text color",
            default = fn_get,
            type = "radio",
            data = require("data/valuetable").RGB_datatable,
        },
        {
            id = "readme",
            label = "Player message",
            fn = function()
                h_util:CreatePopupWithClose("󰀍"..str_auto_read.." · Special thanks󰀍",
                    "Please show more love to the reading bot.\n              —Kaka", {{
                        text = h_util.ok
                    }})
            end,
            hover = "Special thanks",
            default = true
        },
    },
    priority = 100,
})

-- Change the right button display
i_util:AddHoverOverFunc(function(str, player, item_inv, item_world)
    if e_util:IsValid(item_inv) and item_inv:HasTags(book_tags) and TheInput:IsKeyDown(KEY_CTRL) then
        if type(str) == "string" and str:find(STRINGS.ACTIONS.READ) then
            return save_data.sw and str:gsub(STRINGS.ACTIONS.READ, str_auto_read)
        end
    end
end)

local function Say(str)
    if save_data.tip then
        u_util:Say(str_auto_read, str, nil, save_data.color, true)  
    end  
end

i_util:AddRightClickFunc(function(pc, player, down, act_right, ent_mouse)
    -- Validity
    if down or not TheInput:IsKeyDown(KEY_CTRL) or not save_data.sw then return end
    local item = t_util:GetRecur(TheInput:GetHUDEntityUnderMouse(), "widget.parent.item")
    if not (e_util:IsValid(item) and item:HasTags(book_tags)) then return end
    local prefab = item.prefab
    local comps = e_util:ClonePrefab(prefab).components
    local total = comps.finiteuses and comps.finiteuses.total
    local pusher = player.components.hx_pusher
    if not (type(total) == "number" and pusher) then return end
    -- Main logic
    local min_perc = 100 / total
    Say(save_data.timetick == 0 and "Start, the current fastest speed" or "Start, the current interval "..save_data.timetick.." Second")
    local stations_openned = {}
    pusher:RegNowTask(function()
        local books = p_util:GetItemsFromAll(prefab, nil, function(ent)
            if save_data.keep then
                return e_util:GetPercent(ent) > min_perc
            else
                return true
            end
        end)
        table.sort(books, function(a, b)
            return e_util:GetPercent(a) > e_util:GetPercent(b)
        end)
        local book = books[1]
        if book then
            local act = p_util:GetAction("inv", "READ", true, book)
            if act then
                p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act.action.code, book)
                local _perc = e_util:GetPercent(book)
                repeat
                    d_util:Wait()
                until (e_util:GetPercent(book) ~= _perc) or not p_util:IsInBusy()
            end
        elseif save_data.stop then
            Say("Lack of available books")
            return true
        elseif save_data.find then
            local stations = e_util:FindEnts(player, nil, save_data.range, {"_container", "structure"}, {"burnt"}, nil, nil, function(station)
                if Mod_ShroomMilk.Func.HasPrefabWithBox then
                    return Mod_ShroomMilk.Func.HasPrefabWithBox(station, prefab, true)
                else
                    return true
                end
            end)
            -- Find the nearest unopened bookshelf
            local station = t_util:IGetElement(stations, function(station)
                if p_util:IsOpenContainer(station) then
                    table.insert(stations_openned, station)
                else
                    return not table.contains(stations_openned, station) and station
                end
            end)
            if station then
                repeat
                    local act, right = p_util:GetMouseActionSoft({"RUMMAGE"}, station)
                    if act then
                        p_util:DoMouseAction(act, right)
                    end
                    d_util:Wait(0.5)
                until e_util:IsValid(station) and p_util:IsOpenContainer(station)
            else
                stations_openned = {}
            end
        end
        d_util:Wait(save_data.timetick)
    end)
end)