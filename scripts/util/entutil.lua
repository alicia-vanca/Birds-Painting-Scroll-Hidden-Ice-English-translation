local t_util = require "util/tableutil"
local c_util = require "util/calcutil"
local EntUtil = {}

-- Whether it is effective
function EntUtil:IsValid(ent, dead_not_valid)
    return type(ent) == "table" and ent.entity and ent:IsValid() and ent.Transform
end

-- Whether it is an effective area (not at sea or void)
-- IsPassableAtPoint
function EntUtil:InValidPos(ent)
    if self:IsValid(ent) then
        if TheWorld:HasTag("cave") then
            return ent:IsOnValidGround()
        else
            -- The boat is also effective
            return ent:IsOnValidGround() or not ent:IsOnOcean(false)
        end
    end
end

-- Get client container
function EntUtil:GetContainer(ent)
    if ent and ent.replica then
        return ent.replica.container or ent.replica.inventory
    end
end

-- Get the container widget (there are two widgets, one is the table).
function EntUtil:GetContUI(ent)
    local coners = t_util:GetRecur(ThePlayer, "HUD.controls.containers")
    return t_util:GetElement(coners, function(cont, ui)
        return cont == ent and ui
    end)
end


-- Can you put down a certain item
function EntUtil:CanPutInItem(cont, item)
    local container = self:GetContainer(cont)
    if container and self:IsValid(item) then
        local numslots = container:GetNumSlots()
        local prefab = item.prefab
        local slot
        -- I traversed first to see if there is a grid of this item
        if container:AcceptsStacks() then
            for i = 1, numslots do
                local item_slot = container:GetItemInSlot(i)
                slot = item_slot and item_slot.prefab == prefab and item_slot.skinname == item.skinname and self:GetStackSize(item_slot) < self:GetMaxSize(item_slot) and i
                if slot then
                    return slot
                end
            end
        end
        -- Live the space again to see if it can be placed
        for i = 1, numslots do
            slot = not container:GetItemInSlot(i) and container:CanTakeItemInSlot(item, i) and i
            if slot then
                return slot
            end
        end
    end
end

-- Get stacking quantity
function EntUtil:GetStackSize(ent)
    if ent and ent.replica and ent.replica.stackable then
        return ent.replica.stackable:StackSize()
    end
    return 1
end

function EntUtil:GetMaxSize(ent)
    if ent and ent.replica and ent.replica.stackable then
        return ent.replica.stackable:MaxSize()
    end
    return 1
end

-- Get atlas and image
function EntUtil:GetAtlasAndImage(ent)
    local item = ent and ent.replica and ent.replica.inventoryitem
    if item then
        local prefab = ent.prefab
        local ex_str = prefab and prefab:match("(.*)_spice_")
        local tex = ex_str and ex_str .. ".tex"
        local xml = tex and GetInventoryItemAtlas(tex)
        if xml and tex then
            return xml, tex
        end
        return item:GetAtlas(), item:GetImage()
    end
end

-- Durable
function EntUtil:GetPercent(inst)
    local i = 100
    local classified = type(inst) == "table" and inst.replica and inst.replica.inventoryitem and
    inst.replica.inventoryitem.classified
    if classified then
        if inst:HasOneOfTags({ "fresh", "show_spoilage" }) and classified.perish then
            i = math.floor(classified.perish:value() / 0.62)
        elseif classified.percentused then
            i = classified.percentused:value()
        end
    end
    return i
end



-- Get a label
function EntUtil:GetTags(ent, isclone)
    if isclone and ent.prefab then
        return self:ClonePrefab(ent.prefab).tags
    else
        local tags = {}
        local debugstring = ent and ent.entity:GetDebugString()
        if type(debugstring) == "string" then
            local tags_string = debugstring:match("Tags:(.-)\n")
            tags = tags_string and tags_string:split(" ") or {}
        end
        return t_util:IPairFilter(tags, function(tag)
            return tag ~= "FROMNUM" and tag
        end)
    end
end

-- Get component entity
function EntUtil:ClonePrefab(prefab)
    if type(prefab) ~= "string" then
        return {
            components = {},
            prefab = prefab,
            tags = {}
        }
    end
    if not Mod_ShroomMilk.PrefabCopy[prefab] then
        Mod_ShroomMilk.PrefabCopy[prefab] = {
            components = {},
            prefab = prefab,
            tags = {}
        }
        local IsMasterSim = TheWorld.ismastersim
        MOD_SRM_LOCK = true
        getmetatable(TheWorld).GetPocketDimensionContainer = getmetatable(TheWorld).GetPocketDimensionContainer or function() end
        TheWorld.ismastersim = true
        local prefab_copy = SpawnPrefab(prefab)
        local coms = prefab_copy and prefab_copy.components
        t_util:Pairs(coms or {}, function(k, v)
            Mod_ShroomMilk.PrefabCopy[prefab].components[k] = v
        end)
        Mod_ShroomMilk.PrefabCopy[prefab].tags = self:GetTags(prefab_copy)
        if prefab_copy then
            prefab_copy:Remove()
        end
        TheWorld.ismastersim = IsMasterSim
        MOD_SRM_LOCK = false
    end
    return Mod_ShroomMilk.PrefabCopy[prefab]
end

-- Whether the entity is one of the animation
function EntUtil:IsAnim(anim, ent)
    if self:IsValid(ent) and ent.AnimState then
        local t = type(anim)
        if t == "table" then
            return t_util:IGetElement(anim, function(anim_str)
                return ent.AnimState:IsCurrentAnimation(anim_str)
            end)
        elseif t == "string" then
            return ent.AnimState:IsCurrentAnimation(anim)
        elseif t == "function" then
            local get_anim = self:GetAnim(ent)
            if get_anim then
                return anim(get_anim)
            end
        end
    end
end

function EntUtil:TileEnts(core_ent, prefab, allowTags, banTags, allowAnims, banAnims, func)
    local pos = type(core_ent) == "table" and core_ent.x and core_ent.z and core_ent
    if not pos then
        local core = self:IsValid(core_ent) and core_ent or ThePlayer
        pos = core and core:GetPosition()
    end
    local r_ents = {}
    if pos and TheWorld and TheWorld.Map then
        -- allowTags = type(allowTags) == "table" and allowTags or {}
        banTags = type(banTags) == "table" and banTags or { 'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player' }
        r_ents = t_util:IPairFilter(TheWorld.Map:GetEntitiesOnTileAtPoint(pos.x, 0, pos.z), function(ent)
            if (not prefab or prefab == ent.prefab or (type(prefab) == "table" and table.contains(prefab, ent.prefab)))
                and (not allowTags or ent:HasTags(allowTags))
                and not ent:HasOneOfTags(banTags)
                and (not allowAnims or self:IsAnim(allowAnims, ent))
                and (banAnims and not self:IsAnim(banAnims, ent) or not IsEntityDead(ent))
                and (not func or func(ent))
            then
                return ent
            end
        end)
    end
    return r_ents
end

-- Get the nearby target entity
function EntUtil:FindEnts(core_ent, prefab, range, allowTags, banTags, allowAnims, banAnims, func)
    local pos = type(core_ent) == "table" and core_ent.x and core_ent.z and core_ent
    if not pos then
        local core = self:IsValid(core_ent) and core_ent or ThePlayer
        pos = core and core:GetPosition()
    end
    local r_ents = {}
    if pos then
        local ents = TheSim:FindEntities(pos.x, 0, pos.z,
            type(range) == "number" and range or 80,
            type(allowTags) == "table" and allowTags or nil,
            type(banTags) == "table" and banTags or { 'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player' }
        )
        for _, ent in ipairs(ents) do
            if (not prefab or prefab == ent.prefab or (type(prefab) == "table" and table.contains(prefab, ent.prefab)))
                and (not allowAnims or self:IsAnim(allowAnims, ent))
                and (banAnims and not self:IsAnim(banAnims, ent) or not IsEntityDead(ent))
                and (not func or func(ent))
            then
                table.insert(r_ents, ent)
            end
        end
    end
    return r_ents
end

-- Get the recent target entity
function EntUtil:FindEnt(core_ent, prefab, range, allowTags, banTags, allowAnims, banAnims, func)
    local pos = type(core_ent) == "table" and core_ent.x and core_ent.z and core_ent
    if not pos then
        local core = self:IsValid(core_ent) and core_ent or ThePlayer
        pos = core and core:GetPosition()
    end
    if not pos then return end
    local ents = TheSim:FindEntities(pos.x, 0, pos.z,
        type(range) == "number" and range or 64,
        (type(allowTags) == "string" and {allowTags}) or (type(allowTags) == "table" and allowTags) or nil,
        type(banTags) == "table" and banTags or { 'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player' }
    )
    for _, ent in ipairs(ents) do
        if (not prefab or prefab == ent.prefab or (type(prefab) == "table" and table.contains(prefab, ent.prefab)))
            and (not allowAnims or self:IsAnim(allowAnims, ent))
            and (banAnims and not self:IsAnim(banAnims, ent) or not IsEntityDead(ent))
            and (not func or func(ent))
        then
            return ent
        end
    end
end

-- Get the prefab in the same position
function EntUtil:FindEntLoc(core_ent, tags)
    local trans = self:IsValid(core_ent)
    if trans then
        local x, y, z = trans:GetWorldPosition()
        return TheSim:FindEntities(x, 0, z, 0.01, tags)[1]
    end
end

-- Ent binding event
function EntUtil:SetBindEvent(ent, eventname, func)
    if not (ent and ent.prefab) then return end     -- Because of the relationship between the shadow container, it is not available here
    ent:RemoveEventCallback(eventname, func)
    ent:ListenForEvent(eventname, func)
end

-- Get physical animation
function EntUtil:GetAnim(ent)
    if ent and ent.AnimState then
        local bank, anim, frame = ent.AnimState:GetHistoryData()
        return anim
    end
end

-- Get the current animation frame number
function EntUtil:GetFrame(ent)
    if ent and ent.AnimState then
        local bank, anim, frame = ent.AnimState:GetHistoryData()
        return frame
    end
end

-- Angle
-- 呼吸: Very strange, I don't know why I have to write negative numbers. Who knows what I was thinking a few months ago?
function EntUtil:GetAngle(ent) -- EntityScript:GetRotation()
    local tags_string = self:IsValid(ent) and ent.entity:GetDebugString()
    local heading = tonumber(tags_string and tags_string:match(" Heading=(.-) Prediction"))
    return heading and -heading
end

-- Relative angle, the biological direction is connected to a straight line angle with players and creatures
-- It is 0 when facing the player, and the player is 180, the total number is a positive number
-- Less than 45 is for players
function EntUtil:GetAngleToTarget(ent, target)
    if self:IsValid(target) then
        local heading = self:GetAngle(ent)
        if heading then
            return c_util:GetAngleDiff(heading, c_util:GetAngle(ent:GetPosition(), target:GetPosition()))
        end
    end
end
-- Absolute Angle --  EntityScript:GetAngleToPoint(x, y, z)
-- Do not use, debugging is not completed yet
function EntUtil:GetAngleWithTarget(ent, target)
    local a, b = self:IsValid(ent), self:IsValid(target)
    if a and b then
        local x1, _, z1 = a:GetWorldPosition()
        local x2, _, z2 = b:GetWorldPosition()
         -- Calculate the difference between two points
        local dx, dz = x2 - x1, z2 - z1
        -- Use math.atan2 Calculates the angle in radians
        local angleRad = math.atan2(dz, dx)
        -- Convert radians to degrees
        angleRad = math.deg(angleRad)
        return c_util:GetAngleDiff(angleRad, 0)
    end
end

-- Get a distance
function EntUtil:GetDist(e1, e2)
    if not self:IsValid(e2) then
        e2 = ThePlayer
    end
    if self:IsValid(e1) and self:IsValid(e2) then
        local p1 = e1:GetPosition()
        local p2 = e2:GetPosition()
        return c_util:GetDist(p1.x, p1.z, p2.x, p2.z)
    end
end

-- Get the physical radius
function EntUtil:GetRadius(ent, default)
    return ent and ent.GetPhysicsRadius and ent:GetPhysicsRadius(default or 0)
end

-- Prefab gets the name
local NullName = "Unknown"
function EntUtil:GetPrefabName(prefab, ent)
    if not prefab then
        return NullName
    end
    local name = STRINGS.NAMES[prefab:upper()]
    if not name and string.sub(prefab, 1, 10) == "transmute_" then
        prefab = string.sub(prefab, 11)
        name = STRINGS.NAMES[prefab:upper()]
    end
    if ent then
        name = name or ent:GetBasicDisplayName()
        name = name == "MISSING NAME" and prefab or name
    end
    return name or NullName
end

-- Get the equipment field
function EntUtil:GetItemEquipSlot(item)
    return item and item.replica and item.replica.equippable and item.replica.equippable:EquipSlot()
end

-- Whether it is a light source
function EntUtil:IsLightSourceEquip(item)
    return item and self:GetItemEquipSlot(item) and
    (item:HasOneOfTags({ "light", "fire", "lighter", "cave_fueled", "wormlight_fueled" })
        or table.contains({ "lunarplanthat", "yellowamulet", "nightstick" }, item.prefab))
end

-- Perhaps in the physical list, an ent after prefab
function EntUtil:GetNextEntWithPrefab(ents, prefab, reverse)
    local prefab_ents = {}
    t_util:Pairs(ents, function(_, ent)
        local prefab = ent.prefab
        if prefab then
            prefab_ents[prefab] = ent
        end
    end)
    local nextprefab = t_util:GetNextLoopKey(prefab_ents, prefab, reverse)
    return nextprefab and prefab_ents[nextprefab]
end

-- Get the attack target
function EntUtil:GetCombatTarget(ent)
    return self:IsValid(ent) and ent.replica and ent.replica.combat and ent.replica.combat:GetTarget()
end

-- Get the goal
function EntUtil:GetLeaderTarget(ent)
    return self:IsValid(ent) and ent.replica and ent.replica.follower and ent.replica.follower:GetLeader()
end


-- Until executed, it feels not as good as threadutil
-- func_if(ent) func_succ(value, count) func_fail()
function EntUtil:WaitToDo(ent, interval, num, func_if, func_succ, func_fail)
    ent = ent or TheGlobalInstance
    local count = 0
    local function countToDo()
        count = count + 1
        if (count > num or not self:IsValid(ent)) and type(func_fail) == "function" then
            func_fail()
        else
            ent:DoTaskInTime(interval, function()
                local value
                if type(func_if) == "function" then
                    value = func_if(ent)
                else
                    value = func_if
                end
                if value then
                    if type(func_succ) == "function" then
                        func_succ(value, count)
                    end
                else
                    countToDo()
                end
            end)
        end
    end
    countToDo()
end

function EntUtil:SpawnFx(hxname, build, bank, anim, color, scale)
    scale = scale or 1
    local inst = self:SpawnNull()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBuild(build)
    inst.AnimState:SetBank(bank)
    inst.AnimState:PlayAnimation(anim, true)
    inst.AnimState:SetScale(scale, scale, scale)
    if color then
        inst.AnimState:SetMultColour(unpack(color))
    end
    inst:AddTag("FX")
    inst.hxname = hxname
    return inst
end

function EntUtil:SpawnNull()
    local inst = CreateEntity()
    inst:AddTag("huxi")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst.persists = false
    return inst
end


-- Set highlight
function EntUtil:SetHighlight(ent, bool)
    if ent and ent.AnimState then
        local light = bool and 1 or 0
        ent.AnimState:SetLightOverride(light)
        t_util:Pairs(ent.children or {}, function (child)
            if child and child.AnimState then
                child.AnimState:SetLightOverride(light)
            end
        end)
    end
    return ent
end

-- Including components
function EntUtil:HasOneOfComps(ent, comps)
    local comps = type(comps) == "table" and comps or {comps}
    return t_util:IGetElement(comps, function(comp)
        return ent:HasActionComponent(comp)
    end)
end


---the code here is very bad.
local prefab_sc, prefab_chester = "shadow_container", "cont_chester"
local prefabs_chester = {"chester", "hutch"}
local prefabs_shadow = {prefab_sc, "magician_chest"}
-- Is a shadow container
function EntUtil:IsShadowContainer(ent)
    local prefab = ent and ent.prefab
    if prefab then
        if table.contains(prefabs_shadow, prefab) then
            return true
        elseif ent._chesterstate then
            return ent._chesterstate:value() == 3
        end
    end
end
-- It is a container entity
function EntUtil:IsContainer(ent)
    if not ent then return end
    return (ent.replica and ent.replica.container) or ent.prefab=="magician_chest"
end

-- In fact, the two obtaining ids can be integrated together
-- But i am old lazy
-- Get position id
function EntUtil:GetPosID(ent)
    -- Special container
    local prefab = ent and ent.prefab
    if prefab then
        if self:IsShadowContainer(ent) then
            return prefab_sc
        elseif table.contains(prefabs_chester, prefab) then
            return prefab_chester
        end
    end
    local trans = self:IsValid(ent)
    if trans then
        if ent:HasOneOfTags({"INLIMBO", "player"}) then
            -- On your body or box, player
        else
            -- Ground
            local x, y, z = trans:GetWorldPosition()
            return c_util:GetPosID(x, z)
        end
    end
end

function EntUtil:Mod_Showme_Has(ent, prefab)
    return ent.ShowMe_chest_table and t_util:GetElement(ent.ShowMe_chest_table, function(_prefab)
        return _prefab:gsub(" ", "") == prefab and ent
    end)
end
function EntUtil:Mod_Insight_Has(ent, prefab)
    if self:IsContainer(ent) then
        local ins = t_util:GetRecur(ThePlayer, "replica.insight")
        return ins and ins:ContainerHas(ent, prefab, false) and ent
    end
end

function EntUtil:Hook_Say(ent, func)
    local _Say = t_util:GetRecur(ent, "components.talker.Say")
    if _Say then
        ent.components.talker.Say = function(self, str_say, ...)
            str_say = func(str_say) or str_say
            return _Say(self, str_say, ...)
        end
    end
end


function EntUtil:OnPlayerScreen(ent)
    if t_util:GetRecur(ent, "entity.FrustumCheck") then
        return ent.entity:FrustumCheck() or ent:HasTag("INLIMBO")
    end
end


-------------------------------------------------------------------------
-- Note: Do not call the following interfaces from other modules. Change the name or content frequently. Call them only after they are stable.
-------------------------------------------------------------------------

---- The test function, provided to developers
function EntUtil:debug(ent)
    if not self:IsValid(ent) then return end
    ent._harrow = ent:SpawnChild("harrow")
    ent._harrow.Transform:SetScale(2, 2, 2)
    ent._harrow.Transform:SetRotation(-90)
    local watcher = ent.components.hx_watcher
    return watcher or ent:AddComponent("hx_watcher")
end


return EntUtil
