local default_data = {
    prefabs = {"flower"}
}
local save_id, str_show = "sw_test", "Developer Test"
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


local fn_right = function()
    local screen = require "screens/huxi/writescreen"
    TheFrontEnd:PushScreen(screen("Enter code here:", {text = "Print result", cb = function(prefab)
        m_util:print(prefab)
    end}))
end

m_util:AddBindIcon(str_show, "snowman", STRINGS.LMB .. 'Quick Toggle' .. STRINGS.RMB .. 'Advanced Settings', true, fn_left,
    fn_right, 9990)


