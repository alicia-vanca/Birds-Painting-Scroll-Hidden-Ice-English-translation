local save_id, string_fn = "sw_hideshell", "Shell hidden"
local prefabs_shell = {"singingshell_octave3", "singingshell_octave5", "singingshell_octave4"}
local thread
local function fn()
    if thread then
        u_util:Say(string_fn, "Off")
        thread = nil
        KillThreadsWithID(save_id)
        t_util:IPairs(e_util:FindEnts(nil, nil, nil, {"singingshell"}), function(shell)
            shell:Show()
        end)
    else
        u_util:Say(string_fn, "On")
        thread = StartThread(function()
            while thread and e_util:IsValid(ThePlayer) do
                t_util:IPairs(e_util:FindEnts(nil, prefabs_shell, 16, {"singingshell"}), function(shell)
                    shell:Hide()
                end)
                Sleep(1)
            end
            self:StopNowTask()
        end, save_id)
    end
end
m_util:AddBindConf(save_id, fn, nil, {string_fn, "hermit_pearl", "Help Hermit salvage shell piles", true, fn, nil, 5997})