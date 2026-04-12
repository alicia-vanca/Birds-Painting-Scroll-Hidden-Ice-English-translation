local save_id, str_auto, img_show = "sw_beebox", "Burn beebox", "beebox_crystal"
local prefab_beebox = "beebox"
local function Say(str)
    if str then
        u_util:Say(str_auto, str, nil, nil, true)
    end
    return true
end

local function fn_left()
    local pusher = m_util:GetPusher()
    if not pusher then return end
    if pusher:GetNowTask() then
        return pusher:StopNowTask()
    end
    p_util:ReturnActiveItem()
    u_util:Say(str_auto, "Start")
    pusher:RegNowTask(function()
        if p_util:GetActiveItem() then
            return Say("Inventory full")
        end
        local beebox = e_util:FindEnt(nil, prefab_beebox, nil, nil, nil, nil, nil, function(ent)
            return p_util:GetMouseActionSoft({"HARVEST"}, ent)
        end)
        if not beebox then
            return Say("No beebox")
        end
        if beebox:HasTag("fire") then
            d_util:SpaceScene(beebox, "HARVEST")
        else
            local item = p_util:GetItemFromAll(nil, nil, function(item)
                return p_util:GetAction("useitem", "LIGHT", true, item, beebox) or p_util:GetAction("useitem", "LIGHT", false, item, beebox)
            end)
            if not item then
                return Say("No torch")
            end
            if d_util:SpaceUseitem(item, beebox, "LIGHT", function(target)
                return not target:HasTag("fire")
            end) then
                return Say("Unable to ignite, please contact the developer!")
            end
        end
        d_util:Wait()
    end, function()
        u_util:Say(str_auto, "End")
    end)
end

local fn_right = m_util:AddBindShowScreen({
    title="Burn Honey Tutorial",
    id=save_id,
    data = {{
        id = "bilibili",
        prefab = "bilibili",
        type = "imgstr",
        label = "Tutorial Demo",
        hover = "Click to view the video tutorial or feature demo",
        fn = function()VisitURL("https://www.bilibili.com/video/BV1DYUCB8EML", true)end
    },{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        type = "imgstr",
        label = "Special thanks",
        hover = "󰀍 Special thanks 󰀍",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special thanks 󰀍", "The Fire Honey feature was customized by player \"小宇\".\n\nMessage: \"Pure save, small server doesn't count as open\"", {{text = "󰀍"}})
        end
    },
    }
})


m_util:AddBindConf(save_id, fn_left, fn_left, {str_auto, img_show , STRINGS.LMB .. 'Start/End ' .. STRINGS.RMB .. 'Tutorial Demo'
, true, fn_left, fn_right, 5998})