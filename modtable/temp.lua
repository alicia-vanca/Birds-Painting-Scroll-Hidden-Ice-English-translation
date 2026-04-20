local pfs = {_PFS}
local pents = {}
local nents = table.invert(pfs)
for _, e in pairs(Ents) do
    if table.contains(pfs, type(e) == "table" and e.IsValid and e:IsValid() and e.HasTag and not e:HasTag("inlimbo")and e.prefab) then
        table.insert(pents, e)
    end
end
table.sort(pents, function(a, b)
    if nents[a.prefab] == nents[b.prefab] then
        return a.GUID < b.GUID
    else
        return nents[a.prefab] < nents[b.prefab]
    end
end)
local tent
if TUNING._tele_GUID then
    local loc = 0
    for i, e in ipairs(pents) do
        if e.GUID == TUNING._tele_GUID then
            loc = i
            break
        end
    end
    tent = pents[loc + 1] or pents[1]
else
    tent = pents[1]
end
if tent then
    TUNING._tele_GUID = tent and tent.GUID
    if tent.Transform then
        _U_.Transform:SetPosition(tent.Transform:GetWorldPosition())
    end
end
