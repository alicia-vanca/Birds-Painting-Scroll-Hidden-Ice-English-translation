local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TextBtn = require "widgets/textbutton"
local Text = require "widgets/text"
local c_util, e_util, h_util, m_util, t_util,p_util = 
require "util/calcutil",
require "util/entutil",
require "util/hudutil",
require "util/modutil",
require "util/tableutil",
require "util/playerutil"



-------------------------------------------------------------------------------------------------------
local ECTRL = Class(Widget, function(self, inv, owner, meta, funcs, data)
    Widget._ctor(self, "ECTRL")
    -- Load parameter
    meta = meta or {}
    self.Func = funcs
    self.Data = data
    -- Get the original ui parameter
    -- self.eslots = t_util:PairToIPair(inv.equip or {}, function(k, v)
    --     return {slot = k, itemslot = v}
    -- end)
    -- table.sort(self.eslots, function(a, b)
    --     return a.itemslot:GetPosition().x < b.itemslot:GetPosition().x 
    -- end)
    
    -- self.a_pos = self.eslots[1] and self.eslots[1].itemslot:GetPosition() or Vector3(496, 0, 0)
    -- self.img_size = self.eslots[1] and self.eslots[1].itemslot.bgimage:GetScaledSize() or 67
    -- self.img_space = self.eslots[2] and self.eslots[2].itemslot:GetPosition().x - self.a_pos.x - self.img_size or 13
    self.a_pos = Vector3(496, 0, 0)
    self.img_size = 67
    self.img_space = 13
    self.img_a_space = self.img_size+self.img_space

    self.init_x = self.a_pos.x
    self.init_y = 2*self.img_a_space
    -- Initialization
    local init_x = meta.posx or self.init_x
    local init_y = meta.posy or self.init_y
    self:SetPosition(init_x, init_y)
    self:UI_Build(meta)
end)

function ECTRL:UI_Build(meta)
    if self.root then self.root:Kill() end
    if meta.sw ~= "on" then return end
    self.root = self:AddChild(Widget("ec_root"))
    local count_slot = 0
    local ui_slots = t_util:IPairFilter(self.Data.slots, function(slot)
        if meta["ui_"..slot] then
            count_slot = count_slot + 1
            return slot
        end
    end)
    -- frame
    local bg_width = count_slot*self.img_a_space
    local bg_height = self.img_a_space
    self.frame = self.root:AddChild(Widget("frame"))
    local function SetFrameThint(num)
        return function()
            -- self.frame.fill:SetTint(1, 1, 1, num)
            t_util:Pairs(self.frame.sides:GetChildren() or {}, function(img)
                img:SetTint(1, 1, 1, num)
            end)
        end
    end
    self.frame:SetPosition(bg_width/2-self.img_a_space/2, bg_height/2-self.img_a_space/2)
    self.frame:SetHoverText("You can drag with "..STRINGS.LMB.."\nIf stuck to the mouse, please press Esc", {offset_y = 1.5*self.img_size, colour = UICOLOURS.GOLD})
    h_util:ActivateUIDraggable(self, self.Func.SavePos, self.frame)
    -- fill
    local f_atlas = resolvefilepath(CRAFTING_ATLAS)
    -- self.frame.fill = self.frame:AddChild(Image(f_atlas, "backing.tex"))
    -- self.frame.fill:ScaleToSize(bg_width + 10, bg_height + 18)
    ---------- line
    local sides = self.frame:AddChild(Widget("sides"))
    sides:SetOnGainFocus(SetFrameThint(1))
    sides:SetOnLoseFocus(SetFrameThint(0))
    self.frame.sides = sides
    local left = sides:AddChild(Image(f_atlas, "side.tex"))
    local right = sides:AddChild(Image(f_atlas, "side.tex"))
    local top = sides:AddChild(Image(f_atlas, "top.tex"))
    local bottom = sides:AddChild(Image(f_atlas, "bottom.tex"))
    left:SetPosition(-bg_width / 2 - 15, 1)
    right:SetPosition(bg_width / 2 + 15, 1)
    top:SetPosition(0, bg_height / 2 + 10)
    bottom:SetPosition(0, -bg_height / 2 - 8)
    left:ScaleToSize(-26, -(bg_height - 20))
    right:ScaleToSize(26, bg_height - 20)
    top:ScaleToSize(bg_width+33, 38)
    bottom:ScaleToSize(bg_width+33, 38)
    -- button
    local midstr = h_util:GetStringKeyBoardMouse(MOUSEBUTTON_MIDDLE) or STRINGS.RMB
    local hover_add = "\n"..STRINGS.LMB .. "Erase  " .. midstr .. "Switch"
    local init_xml, init_tex = "images/hud.xml", "slot_select.tex"
    for i,ui_slot in ipairs(ui_slots)do
        local item_slot = "item_"..ui_slot
        local btn_slot = "btn_"..ui_slot

        local btn = self.root:AddChild(Image(init_xml, init_tex))
        self[btn_slot] = btn
        h_util:ActivateBtnScale(btn, self.img_size)
        -- btn.img = btn:AddChild(Image(init_xml, init_tex))
        -- h_util:ActivateBtnScale(btn.img, self.img_size)
        btn:SetPosition((i-1)*self.img_a_space, 0)
        local ui_data = self.Data.data_slots[ui_slot]
        btn:SetHoverText(ui_data.hover..hover_add, {offset_y = 1.5*self.img_size})
        function btn:install(item)
            local xml, tex = e_util:GetAtlasAndImage(item)
            if not (xml and tex) and type(item)=="string" then
                xml, tex = e_util:GetAtlasAndImage(p_util:GetItemFromAll(item))
                if not (xml and tex) then
                    xml, tex = h_util:GetPrefabAsset(item)
                end
            end
            if xml then
                btn:SetTexture(xml, tex)
            else
                btn:SetTexture(init_xml, init_tex)
            end
            btn.preset_prefab = type(item) == "table" and item.prefab or item
        end
        local function InstallNext(reverse)
            return function()
                local prefab = meta[item_slot]
                local items = p_util:GetItemsFromAll(nil, nil, ui_data.filter, {"equip", "body", "backpack", "container", "mouse"}) or {}
                local item = e_util:GetNextEntWithPrefab(items, prefab, reverse)
                btn:install(item)
                prefab = item and item.prefab
                self.Func.SaveData(item_slot)(prefab)
                if ui_data.work then
                    ui_data.work()
                end
            end
        end
        h_util:BindMouseClick(btn, {
            [MOUSEBUTTON_LEFT] = function()
                local prefab = meta[item_slot]
                if prefab then
                    btn:install()
                    prefab = false
                else
                    local item = p_util:GetItemFromAll(nil, nil, ui_data.filter, {"equip", "body", "backpack", "container", "mouse"})
                    btn:install(item)
                    prefab = item and item.prefab
                end
                self.Func.SaveData(item_slot)(prefab)
            end,
            [MOUSEBUTTON_RIGHT] = InstallNext(),
            [MOUSEBUTTON_SCROLLDOWN] = InstallNext(),
            [MOUSEBUTTON_SCROLLUP] = InstallNext(true),
        })
        btn:install(meta[item_slot])
    end
    SetFrameThint(0)()
end

-- Reset
function ECTRL:ResetPos()
    if self.frame then
        self.frame:StopFollowMouse()
        self:SetPosition(self.init_x, self.init_y)
        self.Func.SavePos({x = self.init_x, y = self.init_y})
    end
end

-- Re -load the icon (suitable for just entering the file)
function ECTRL:ResetIcon()
    local btns = self.root and self.root:GetChildren() or {}
    t_util:Pairs(btns, function(btn)
        local prefab = btn.preset_prefab
        if prefab and btn.install then
            btn:install(prefab)
        end
    end)
end

return ECTRL