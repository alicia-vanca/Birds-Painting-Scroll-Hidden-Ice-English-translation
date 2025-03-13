local m_util = require "util/modutil"
local h_util = require "util/hudutil"

local u_util = {}


local where_default
local function getwheredefault()
    where_default = m_util:IsTurnOn("pos_say")
    return where_default
end

local _last_say_time = 0
function u_util:Say(who, what, where, color, ignoremeanwhile)
    if (GetTime() - _last_say_time < 3) and not ignoremeanwhile then
        return
    end
    _last_say_time = GetTime()
    where = where or where_default or getwheredefault()
    local rgb = h_util:GetRGB(color)
    what = type(what) == "boolean" and (what and "On" or "Off") or what
    if where == "head" then
        local content = ""
        if who and what then
            content = who.."："..what
        else
            content = type(who) ~= "nil" and content..who or content
            content = type(what) ~= "nil" and content..what or content
        end
        if ThePlayer and ThePlayer.components.talker then
            ThePlayer.components.talker:Say(content, nil, nil, nil, nil, rgb)
        end
    elseif where == "self" then
        what = what and tostring(what) or ""
        ChatHistory:AddToHistory(ChatTypes.Message, nil, nil, who, what, rgb)
    elseif where == "net" then
        TheNet:Say(who)
    end
end


return u_util