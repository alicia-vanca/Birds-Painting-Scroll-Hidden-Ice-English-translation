i_util:AddWorldActivatedFunc(function()
    local Pcrs = t_util:GetMetaIndex(PostProcessor)
    local fn_str = "AddTextureSampler"
    local _fn = Pcrs[fn_str]
    if not _fn then return end
    Pcrs[fn_str] = function(self, ...)
        print(fn_str, ...)
        return _fn(self, ...)
    end
end)