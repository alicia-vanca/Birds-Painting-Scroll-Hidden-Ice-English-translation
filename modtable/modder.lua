
function _G.LATELY(time, func)
    print("A task will be", time, "Execute later")
    _G.CreateEntity():DoTaskInTime(time, func)
end

local looptask = false
function _G.loopStop()
    if looptask then
        looptask:Cancel()
    end
    looptask = false
end

function _G.loopStart(cd, func)
    if looptask then
        looptask:Cancel()
    end
    looptask = _G.TheGlobalInstance:DoPeriodicTask(cd, func())
    return looptask
end

function _G.FEP_M(...)
    local mt = getmetatable(...)
    t_util:FEP(mt)
    return mt
end

function _G.FEP_I(...)
    local mt = getmetatable(...) and getmetatable(...).__index
    t_util:FEP(mt)
    return mt
end

function _G.FEP_K(t, valuetype)
    if type(t) ~= "table" then
        print("This is not a table, data type: ", type(t), "Print directly: ", t)
        return
    end
    local str = ""
    local lines = {}
    local t_key = t_util:PairToIPair(t, function(k, v)
        if not valuetype or type(v) == valuetype then
            return tostring(k)
        end
    end)
    table.sort(t_key)
    t_util:IPairs(t_key, function(strk)
        if (#str + #strk) < 100 then
            str = str .. strk .. ", "
        else
            table.insert(lines, str)
            str = strk .. ", "
        end
    end)
    table.insert(lines, str)
    print(table.concat(lines, "\n"))
    if valuetype then
        print("*********", t, "Length", #t_key, "Specify type: ", valuetype, "*********")
    else
        print("*********", t, "Length", #t_key, "*********")
    end
    return t_key
end

function _G.FEP_V(t, valuetype)
    if type(t) ~= "table" then
        print("This is not a table, data type: ", type(t), "Direct Printing: ", t)
        return
    end
    local str = ""
    local lines = {}
    local t_value = t_util:PairToIPair(t, function(k, v)
        if not valuetype or type(v) == valuetype then
            return tostring(v)
        end
    end)
    table.sort(t_value)
    t_util:IPairs(t_value, function(strk)
        if (#str + #strk) < 100 then
            str = str .. strk .. ", "
        else
            table.insert(lines, str)
            str = strk .. ", "
        end
    end)
    table.insert(lines, str)
    print(table.concat(lines, "\n"))
    if valuetype then
        print("*********", t, "Length", #t_value, "Specify type: ", valuetype, "*********")
    else
        print("*********", t, "Length", #t_value, "*********")
    end
    return t_value
end

function _G.FEP(...)
    t_util:FEP(...)
end

function _G.fepAnim(ent, cd, stop)
    cd = cd or 0.3
    stop = stop or 30
    local anims = {}
    if not e_util:IsValid(ent) then return print(ent, "Invalid!") end
    ThePlayer.CommandTask = ent:DoPeriodicTask(cd, function(inst)
        local anim = e_util:GetAnim(inst)
        if anim and not table.contains(anims, anim) then
            print(anim)
            table.insert(anims, anim)
        end
    end)
    ThePlayer:DoTaskInTime(stop, function(inst)
        if inst.CommandTask then
            inst.CommandTask:Cancel()
            inst.CommandTask = nil
            print("Track", e_util:GetPrefabName(ent.prefab), "The animation has stopped", "CD:", cd, "STOP:", stop)
            print("***************************")
        end
    end)
    print("***************************")
    print("Track", e_util:GetPrefabName(ent.prefab), "The animation has begun", "CD:", cd, "STOP:", stop)
    return ThePlayer.CommandTask
end

function _G.nearEnt(...)
    return e_util:FindEnt(nil, ...)
end

function _G.nearEnts(...)
    return e_util:FindEnts(nil, ...)
end

function _G.nearSlot(loc)
    if type(loc) == "number" then
        return ThePlayer.replica.inventory:GetItemInSlot(loc)
    elseif loc == "mouse" then
        return p_util:GetActiveItem()
    else
        return p_util:GetEquip(loc)
    end
end

function _G.printDist(ent1, ent2)
    ent2 = e_util:IsValid(ent2) or ThePlayer
    if ent1 and ent1:IsValid() then
        local dis = math.sqrt(ent1:GetPosition():DistSq(ent2:GetPosition()))
        print(dis)
        return dis
    end
end

function _G.getTags(...)
    return e_util:GetTags(...)
end

function _G.compTags(tags1, tags2)
    local dif1 = {}
    local dif2 = {}
    for _, tag in pairs(tags1) do
        if not table.contains(tags2, tag) then
            table.insert(dif1, #dif1 + 1, tag)
        end
    end
    print("In TAG1 instead of TAG2:")
    print(unpack(dif1))
    for _, tag in pairs(tags2) do
        if not table.contains(tags1, tag) then
            table.insert(dif2, #dif2 + 1, tag)
        end
    end
    print("In TAG2 instead of TAG1:")
    print(unpack(dif2))
end

local _SendRPCToServer = _G.SendRPCToServer
local showrpc
function _G.watchRPC()
    showrpc = not showrpc
    if showrpc then
        print("*********************Start recording*****************************")
        _G.SendRPCToServer = function(rpc, ac, sth, ...)
            local ri, ai
            for k, v in pairs(RPC) do
                if rpc == v then
                    ri = k
                    break
                end
            end
            if not ri then
                ri = rpc
            end
            for k, v in pairs(ACTIONS) do
                if v.code == ac then
                    ai = k
                    break
                end
            end
            if not ai then
                ai = ac
            end
            print(ri, ai, "3:", sth, "4：", ...)
            _SendRPCToServer(rpc, ac, sth, ...)
        end
    else
        print("*********************Stop recording*****************************")
        _G.SendRPCToServer = _SendRPCToServer
    end
end

_G.c_util, _G.e_util, _G.h_util, _G.i_util, _G.m_util, _G.p_util, _G.t_util, _G.s_mana,_G.u_util = c_util,
e_util, h_util, i_util, m_util, p_util, t_util, s_mana, u_util

_G.w_mana, _G.w_util = {}, {}
_G.pc, _G.picker, _G.pusher, _G.saver = {}, {}, {}, {}
i_util:AddPlayerActivatedFunc(function(player, world, pusher, saver)
    _G.w_util = require "util/worldutil"
    _G.pc = player.components.playercontroller
    _G.picker = player.components.playeractionpicker
    _G.pusher = pusher
    _G.saver = saver
    _G.w_mana = require "util/worldmanager"
end)

_G.ghud = {}
_G.gHUD = function(t)
    _G.TheGlobalInstance:DoTaskInTime(t or 1, function()
        _G.ghud = _G.TheInput:GetHUDEntityUnderMouse()
        print("ghud:", _G.ghud)
    end)
end

local showevent
local _PushEvent = EntityScript.PushEvent
local dontshow = {"onremove",
 "clocktick", "entitywake", "weathertick", "temperaturetick", "overridecolourmodifier",
                  "entity_spawned", "actioncomponentsdirty", "entitysleep", "fx_spawned", "animqueueover", "locomote",
                  "newstate", "nightmareclocktick", "ontalk", "donetalking", "animover", "mouseover", "mouseout", -- Mouse movement and movement (quite useful)
                  "hungerdelta", "serverpauseddirty", "hungerdirty", "temperaturedelta", "temperaturedirty",
                  "changearea", "sanitydelta", "sanitydirty", 
                  -- Caveless
                  "master_clockupdate", "moisturedelta", "stopturning", "timedone"}
function _G.watchEvent()
    showevent = not showevent
    if showevent then
        print("************** open the event record ***************")
        EntityScript.PushEvent = function(self, event, ...)
            if not table.contains(dontshow, event) then
                print(self, event, ...)
            end
            return _PushEvent(self, event, ...)
        end
    else
        print("************** turn off the event record **************")
        EntityScript.PushEvent = _PushEvent
    end
end

function _G.getui(slot)
    local invs = t_util:GetRecur(ThePlayer or {}, "HUD.controls.inv.inv") or {}
    return invs[slot]
end

function _G.ESlot(ui)
    local invs = t_util:GetRecur(ThePlayer or {}, "HUD.controls.inv.inv") or {}
    return t_util:GetElement(invs, function(id, slot)
        return slot == ui and id
    end)
end

-- Replace the original suspension
local _OnServerPauseDirty = _G.OnServerPauseDirty
_G.OnServerPauseDirty = function(pause, autopause, gameautopause, source, ...)
    m_util:ClosePrint()
    _OnServerPauseDirty(pause, autopause, gameautopause, source, ...)
    m_util:OpenPrint()
    if not pause then
        print("*********************************")
    end
end