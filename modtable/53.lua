------------------ Function settings ------------------
local playerhud = require "screens/playerhud"
local save_id, string_brain = "sw_brain", "Memory+"
local default_data = {
    box_preview = false,
    sign_more = false,
    chester_range = 36,
    color_item = "Green",
    color_full = "Purple",
    force_memory = false,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local m_data = {
    brain_save = m_util:IsTurnOn("brain_save"),
    brain_sign = m_util:IsTurnOn("brain_sign"),
    brain_bundle = m_util:IsTurnOn("brain_bundle"),
    brain_chester = m_util:IsTurnOn("brain_chester"),
}
local fn_moddata = function(id)
    return m_data[id]
end
local function ModSave(conf)
    return function(value)
        m_data[conf] = m_util:SaveModOneConfig(conf, value)
    end
end
local DataBox, id_box = {}, "box"
local DataInv, id_inv = {}, "inv"
local function BindBrainSave(net)
    local saver = TheWorld and TheWorld.components.hx_saver
    if saver then
        saver:Save()
    end
end
local function GetItemInfo(item)
    local xml, tex = e_util:GetAtlasAndImage(item)
    local max = e_util:GetMaxSize(item)
    return {
        prefab = item.prefab,
        stack = tostring(e_util:GetStackSize(item)),
        max = tostring(max > 4096 and 4097 or max),
        -- perc = tostring(e_util:GetPercent(item)),
        xml = h_util:ZipXml(xml),
        tex = tex
    }
end
local enable_smart_minisign
------------------ Bundle wrap memory ------------------
local bundle_info_id = "_huxi_bundle_info"
local bundle_prefabs = {"bundle", "gift"}
local BundleInfo = {info = nil, time = 0, prefabs = bundle_prefabs, id = bundle_info_id}
i_util:AddPrefabsHook(BundleInfo)

local _bundle_lock  -- Let the function be only hook once
local _OpenContainer = playerhud.OpenContainer
playerhud.OpenContainer = function(self, cont, side, ...)
    local container = e_util:GetContainer(cont)
    if container and cont:HasTag("bundle") and not _bundle_lock then
        local widget = container:GetWidget()
        local _fn = t_util:GetRecur(widget, "buttoninfo.fn")
        if _fn then
            _bundle_lock = true
            widget.buttoninfo.fn = function(ent, ...)
                container = e_util:GetContainer(ent)
                if container then
                    local items = container:GetItems() or {}
                    BundleInfo.info = {}
                    BundleInfo.time = GetTime()
                    local count = 0
                    t_util:Pairs(items, function(slot, item)
                        if item then
                            count = count + 1
                            BundleInfo.info[tostring(count)] = GetItemInfo(item)
                        end
                    end)
                    BundleInfo.info.num = tostring(count)
                end
                return _fn(ent, ...)
            end
        end
    end
    return _OpenContainer(self, cont, side, ...)
end
local function GetSBox()
    return h_util:GetControls().sbox
end
i_util:AddHoverOverFunc(function(str, player, item_inv, item_world)
    if m_data.brain_bundle then
        local item = item_inv or item_world
        if item then
            local data = item[bundle_info_id]
            if data then
                local sbox = GetSBox()
                if sbox then
                    if m_util:EnableShowme() or m_util:EnableInsight() then
                        return
                    end
                    if item_inv then
                        sbox:SetData(data, TheInput:GetScreenPosition(), true)
                    elseif item_world then
                        sbox:SetData(data, item_world:GetPosition())
                    end
                    return nil, function()
                        sbox:SetData()
                    end
                end
            end
        end
    end
end)
------------ Box item highlight ---------------
local items_highlight = {}
-- Clean up highlight
local function ClearHighlight()
    t_util:IPairs(items_highlight, function(ent)
        h_util.SetAddColor(ent)
        e_util:SetHighlight(ent, false)
    end)
    items_highlight = {}
end
-- Highlight
local function AddHighlight(ent, color)
    h_util.SetAddColor(ent, color)
    e_util:SetHighlight(ent, true)
    if ent then
        table.insert(items_highlight, ent)
    end
end
local function GetMemoryBoxData(ent)
    if not e_util:IsContainer(ent) then
        return
    end
    -- Original logic
    local pos_id = e_util:GetPosID(ent)
    return pos_id and DataBox[pos_id]
end

-- This interface is provided outside
local function HasPrefabWithBox(ent, prefab, dontcheckbundle)
    local data_cont = GetMemoryBoxData(ent)
    if not data_cont then return end
    local pos_id = e_util:GetPosID(ent)
    local has = t_util:GetElement(data_cont, function(slot, data)
        if type(data) ~= "table" then return end
        if data.prefab == prefab then
            return true
        end
        -- Adaptation of packing paper memory
        if not dontcheckbundle and table.contains(bundle_prefabs, data.prefab) then
            local line = DataInv[pos_id.."_"..slot]
            if line then
                return t_util:GetElement(line, function(slot, data)
                    return data.prefab == prefab
                end)
            end
        end
    end)
    return has and data_cont
end
local function HighlightAPrefab(prefab)
    local count = 0
    -- Loop through items
    t_util:IPairs(e_util:FindEnts(nil, nil, save_data.chester_range), function(ent)
        if ent.prefab == prefab then
            -- Highlight
            AddHighlight(ent, save_data.color_item)
            count = count + 1
        else
            local function AddBoxHighlight(color)
                AddHighlight(ent, color)
                AddHighlight(ent.huxi_sign, color)
                if enable_smart_minisign then
                    AddHighlight(e_util:FindEntLoc(ent, {"sign"}), color)
                end
                count = count + 1
            end
            if m_util:EnableShowme() and not save_data.force_memory then
                local has = ent.ShowMe_chest_table and t_util:GetElement(ent.ShowMe_chest_table, function(_prefab)
                    return _prefab:gsub(" ", "") == prefab
                end)
                if has then
                    AddBoxHighlight(save_data.color_item)
                end
            elseif m_util:EnableInsight() and not save_data.force_memory then
                if e_util:IsContainer(ent) then
                    local ins = t_util:GetRecur(ThePlayer, "replica.insight")
                    if ins and ins:ContainerHas(ent, prefab, false) then
                        AddBoxHighlight(save_data.color_item)
                    end
                end
            else
                local data_cont = HasPrefabWithBox(ent, prefab)
                if data_cont then
                    AddBoxHighlight(data_cont.full and save_data.color_full or save_data.color_item)
                end
            end
        end
    end)

    return count
end

local function HighlightPrefab(prefab)
    if not m_data.brain_chester then return end
    -- m_util:print(prefab)
    ClearHighlight()
    if not prefab then return end
    HighlightAPrefab(prefab)
end

Mod_ShroomMilk.Func.GetMemoryBoxData = GetMemoryBoxData
Mod_ShroomMilk.Func.HasPrefabWithBox = HasPrefabWithBox
Mod_ShroomMilk.Func.ClearHighlight = ClearHighlight
Mod_ShroomMilk.Func.HighlightPrefabs = function(prefabs)
    local count = 0
    if m_data.brain_chester then
        ClearHighlight()
        t_util:IPairs(type(prefabs) == "table" and prefabs or {prefabs}, function(prefab)
            count = count + HighlightAPrefab(prefab)
        end)
    end
    return count
end


-- Music
AddPrefabPostInit("inventory_classified",function(inst)
    inst:ListenForEvent("activedirty", function(inst)
        local item = inst._active:value()
        HighlightPrefab(item and item.prefab)
    end)
end)
local pointer
-- is_display
--- true: show this prefab
--- false: remove the prefab display
local function ShowPrefabView(prefab, is_display)
    if not prefab then
        return
    end
    if is_display then
        pointer = prefab
    else
        if pointer == prefab then
            pointer = nil
        end
    end
    HighlightPrefab(pointer)
end
AddClassPostConstruct("widgets/ingredientui", function (self, ...)
    local _OnGainFocus = self.OnGainFocus
    function self.OnGainFocus(self, ...)
        ShowPrefabView(self.recipe_type, true)
        if _OnGainFocus then
            return _OnGainFocus(self, ...)
        end
    end

    local _OnLoseFocus = self.OnLoseFocus
    function self.OnLoseFocus(self, ...)
        ShowPrefabView(self.recipe_type, false)
        if _OnLoseFocus then
            return _OnLoseFocus(self, ...)
        end
    end
end)
-- Sidebar display
AddClassPostConstruct("widgets/redux/craftingmenu_pinslot", function (self, ...)
    local _OnGainFocus = self.OnGainFocus
    function self.OnGainFocus(self, ...)
        ShowPrefabView(self.recipe_name, true)
        return _OnGainFocus(self, ...)
    end    
    
    local _OnLoseFocus = self.OnLoseFocus
    function self.OnLoseFocus(self, ...)
        ShowPrefabView(self.recipe_name, false)
        return _OnLoseFocus(self, ...)
    end
end)
------------------ Smart mini sign ------------------
-- What mod boxes are added to me, and then write a window to allow players to add boxes
local prefabs_minisign = {}
local prefabs_box_1 = {
    "treasurechest", -- Ordinary box
    "dragonflychest", -- Dragon flying treasure box
    "medal_livingroot_chest", -- Medal tree root treasure chest
    "sora2chest_build_sora" -- Obsessive -compulsive disorder 
}
local prefabs_box_2 = {
    "icebox", "saltbox"
}
local prefabs_box_all = t_util:MergeList(prefabs_box_1, prefabs_box_2)
local function RefreshPrefabsMinisign()
    prefabs_minisign = t_util:MergeList(prefabs_box_1, save_data.sign_more and prefabs_box_2 or {})
end
RefreshPrefabsMinisign()
local seed_xml, seed_tex = h_util:GetPrefabAsset("seeds")
local enable_SeedImages = Mod_ShroomMilk.Setting.SeedImages
local function ShowSmartMinisign(cont)
    if not cont or enable_smart_minisign then return end
    if m_data.brain_sign and table.contains(prefabs_minisign, cont.prefab) then
        local id = e_util:GetPosID(cont)
        if not (cont.huxi_sign and cont.huxi_sign:IsValid()) then
            cont.huxi_sign = cont:SpawnChild("hminisign")
            if cont.prefab == "dragonflychest" then
                cont.huxi_sign.Transform:SetScale(1.2, 1.2, 1)
            end
        end
        local data = id and DataBox[id]
        if not (data and tonumber(data.num)) then return end
    
        local num = tonumber(data.num)
        local flag_draw
        for i = 1, num do
            local line = data[tostring(i)]
            if line then
                -- There is no way to solve this, and then find a way
                if enable_SeedImages and type(line.tex) == "string" and line.tex:find("_seeds.tex") then
                    cont.huxi_sign:Draw(seed_xml, seed_tex)
                else
                    cont.huxi_sign:Draw(h_util:ZipXml(line.xml, true), line.tex)
                end
                flag_draw = true
                break
            end
        end
        if not flag_draw then
            cont.huxi_sign:Draw()
        end
    elseif cont.huxi_sign then
        cont.huxi_sign:Remove()
        cont.huxi_sign = nil
    end
end
local function RefreshMinisigns()
    if m_util:isHost() then
        t_util:Pairs(Ents, function(id, ent)
            ShowSmartMinisign(ent)
        end)
    else
        t_util:IPairs(e_util:FindEnts(nil, prefabs_box_all), ShowSmartMinisign)
    end
end
t_util:IPairs(prefabs_box_all, function(prefab_box)
    AddPrefabPostInit(prefab_box, function(box)
        box:DoTaskInTime(0, ShowSmartMinisign)
    end)
end)
i_util:AddHoverOverFunc(function(str, player, item_inv, item_world)
    if item_world and not p_util:GetActiveItem() then
        ClearHighlight()
    end
end)

------------------ Daily save and load into game --aww----------------
local function SetBrainSave()
    local net = TheWorld and TheWorld.net
    if net then
        net:RemoveEventCallback("issavingdirty", BindBrainSave)
        if m_data.brain_save then
            net:ListenForEvent("issavingdirty", BindBrainSave)
        end
    end
end

i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    -- Load dawn save
    SetBrainSave()
    -- Data inlet loading
    DataBox = saver:GetMap(id_box, true)
    DataInv = saver:GetMap(id_inv)
    -- Server small wood card judgment
    enable_smart_minisign  = TUNING.SMART_SIGN_DRAW_ENABLE
end)

------------------ box memory -------------------
-- Treat the box on the ground
local function RefreshBoxMemory(cont)
    local container = e_util:GetContainer(cont)
    if container and not cont:HasTag("inlimbo") then
        local ui_conts = h_util:GetControls().containers or {}
        local ui_cont = t_util:GetElement(ui_conts, function(_cont, ui_cont)
            return _cont == cont and ui_cont.inv and ui_cont
        end)
        -- Only handle the box with a grid greater than 4
        if ui_cont then
            local numslots = #ui_cont.inv
            if numslots > 4 then
                local id_cont_pos = e_util:GetPosID(cont)
                if id_cont_pos then
                    DataBox[id_cont_pos] = {
                        num = tostring(numslots),
                        -- full = container:IsFull() and true or nil
                    }
                    local count = 0
                    t_util:Pairs(ui_cont.inv, function(i, slot)
                        local item = slot and slot.tile and slot.tile.item
                        if item then
                            DataBox[id_cont_pos][tostring(i)] = GetItemInfo(item) or nil
                            count = count + 1
                        end
                    end)
                    DataBox[id_cont_pos].full = count == container:GetNumSlots() and true or nil
                    ShowSmartMinisign(cont)
                end
                -- BindBrainSave () - test code remember to delete
            end
        end
    end
end
Mod_ShroomMilk.Func.RefreshBoxMemory = RefreshBoxMemory
local _CloseContainer = playerhud.CloseContainer
playerhud.CloseContainer = function(self, cont, side, ...)
    RefreshBoxMemory(cont)
    return _CloseContainer(self, cont, side, ...)
end
------------------ Box preview ------------------
local function OpenBoxNotInlimBo(player)
    local ui_conts = t_util:GetRecur(player, "HUD.controls.containers") or {}
    return t_util:GetElement(ui_conts, function(cont)
        return not cont:HasTag("inlimbo") and cont
    end)
end
AddClassPostConstruct("widgets/controls", function(self, player)
    if self.sbox then
        self.sbox:Kill()
    end
    self.sbox = self:AddChild(require("widgets/huxi/huxi_box")())
end)

i_util:AddHoverOverFunc(function(str, player, item_inv, item_world)
    if not (item_world and save_data.box_preview) then
        return
    end
    local cont_shadow = e_util:IsShadowContainer(item_world)
    if e_util:GetContainer(item_world) or cont_shadow then
        local sbox = GetSBox()
        if sbox then
            local id_cont_pos = e_util:GetPosID(item_world)
            if id_cont_pos and DataBox then
                local cont_open = OpenBoxNotInlimBo(player)
                if cont_open and (cont_open==item_world or (e_util:IsShadowContainer(cont_open) and cont_shadow)) then
                    -- If the box has been opened, it does not show the preview of this open box, but it still shows the preview of other boxes
                    sbox:SetData()
                else
                    sbox:SetData(DataBox[id_cont_pos], item_world:GetPosition())
                end
            end
            return nil, function()
                sbox:SetData()
            end
        end
    end
end)

------------------ Panel settings ------------------
local desc_add = "\nThis is a local function. The data will not be refreshed after someone else opens the box"
local VData = require "data/valuetable"
local screen_data = {{
    id = "brain_save",
    label = "Save at dawn",
    hover = "If you don’t frequently rollback or crash,\nand you don’t like the lag when saving at dawn, you can disable this option",
    fn = function(value)
        ModSave("brain_save")(value)
        SetBrainSave()
    end,
    default = fn_moddata
}, {
    id = "box_preview",
    label = "Storage preview",
    hover = "Preview the items inside the chest when you move the mouse over it" .. desc_add,
    fn = fn_save("box_preview"),
    default = fn_get
}, {
    id = "brain_sign",
    label = "Smart mini sign",
    hover = "After opening a box, there will be a small wooden sign indicating what is inside" .. desc_add,
    fn = function(value)
        ModSave("brain_sign")(value)
        RefreshMinisigns()
    end,
    default = fn_moddata
},{
    id = "sign_more",
    label = "Refrigerator mini sign",
    hover = "[Smart mini sign] additional setting\nTo apply this setting, you need to restart the game\nToggle whether mini signs are displayed on the refrigerator and salt box",
    fn = function(value)
        fn_save("sign_more")(value)
        RefreshPrefabsMinisign()
        RefreshMinisigns()
    end,
    default = fn_get
}, {
    id = "brain_bundle",
    label = "Bundle wrap memory",
    hover = "If you pack something by yourself, you will remember what is inside.",
    fn = ModSave("brain_bundle"),
    default = fn_moddata
},{
    id = "brain_chester",
    label = "Storage highlight",
    hover = "Items and chests are highlighted when the mouse picks up something or hovers over a recipe",
    fn = ModSave("brain_chester"),
    default = fn_moddata
},{
    id = "chester_range",
    label = "Range:",
    hover = "[Storage highlight] additional setting\nThe larger the search highlight range, the more it lags, but the range will be larger!",
    fn = fn_save("chester_range"),
    default = fn_get,
    type = "radio",
    data = t_util:BuildNumInsert(4, 80, 4, function(i)
        return {data = i, description = i}
    end)
},{
    id = "color_item",
    label = "Color:",
    hover = "[Storage highlight] additional setting\nHighlight color for items and chests",
    fn = fn_save("color_item"),
    default = fn_get,
    type = "radio",
    data = VData.RGB_datatable,
},{
    id = "color_full",
    label = "Full color:",
    hover = "[Storage highlight] additional setting\n[This feature will be disabled when showme or insight is on]\nThe highlight color of items and boxes (when full)",
    fn = fn_save("color_full"),
    default = fn_get,
    type = "radio",
    data = VData.RGB_datatable,
},{
    id = "force_memory",
    label = "Force local memory",
    hover = "Enable with caution, you will no longer communicate with showme or insight after enabling!\nHighlight and other functions will be completely controlled locally!",
    fn = fn_save("force_memory"),
    default = fn_get,
}, 
}
local function fn()
    m_util:AddBindShowScreen({
        title = string_brain,
        id = save_id,
        data = screen_data
    })()
    if not save_data.force_memory and (m_util:EnableInsight() or m_util:EnableShowme()) then
        h_util:CreatePopupWithClose("Memory · tips", "You currently have insight or showme turned on, some functions will be disabled")
    end
    if enable_smart_minisign then
        h_util:CreatePopupWithClose("Memory · tips", "You currently have the server's [Smart Mini Sign] enabled, so the local mini sign will be automatically disabled")
    end
end
m_util:AddBindIcon(string_brain, "icon_sanity", STRINGS.LMB .. "Memory-related settings", true, fn, nil, 10000)
