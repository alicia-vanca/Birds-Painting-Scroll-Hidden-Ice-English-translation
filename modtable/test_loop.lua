if not m_util:IsMilker() then
    return
end

local default_data = {}
local save_id, str_show = "sw_test", "Developer Testing"
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local function fn_left()
    local pusher = m_util:GetPusher()
    if pusher then
        if pusher:GetNowTask() then
            return pusher:StopNowTask()
        else
            pusher:RegNowTask(function(player, pc)
                local picker = player.components.playeractionpicker
                local ent = e_util:FindEnt()
                if ent then
                    local acts = picker:GetLeftClickActions(ent:GetPosition(), ent)
                    t_util:Pairs(acts, function(i, act)
                        m_util:print("test" .. i, act)
                    end)
                end
                d_util:Wait(0.5)
            end, nil, "null")
        end
    end
end


local fn_right = m_util:AddBindShowScreen({
    title = str_show,
    id = "hx_" .. save_id,
    data = screen_data
})

m_util:AddBindIcon(str_show, "snowman", STRINGS.LMB .. 'Quick switch' .. STRINGS.RMB .. 'Advanced Settings', true, fn_left,
    fn_right, 99999)
