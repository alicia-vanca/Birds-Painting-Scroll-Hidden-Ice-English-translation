-- 260412 VanCa: Edit strings and font size
-- 260412 VanCa: Allow unravel tradable duplicate skins

local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"
local UIAnim = require "widgets/uianim"
local h_util = require "util/hudutil"
local t_util = require "util/tableutil"
local m_util = require "util/modutil"
local u_util = require "util/userutil"
local TPS = {
    beard = "beards",
    hands = "hand",
}

local DEBUG_HX_SKINQUEUE = false
local function dbg(...)
    if DEBUG_HX_SKINQUEUE then
        print("[hx_skinqueue dbg]", ...)
    end
end

local function PrepareUnravelTarget(picker, item_key)
    if not picker then
        return false
    end
    local target = picker.last_interaction_target
    if target and target.item_key == item_key then
        return true
    end
    local data
    local items = t_util:GetRecur(picker, "scroll_list.items") or {}
    t_util:IPairs(items, function(d)
        if not data and type(d) == "table" and d.item_key == item_key then
            data = d
        end
    end)
    if data then
        picker.last_interaction_target = data
        return true
    end
    return false
end

local SQ = Class(Widget, function(self, exclude_prefabs, include_prefabs)
    Widget._ctor(self, "skin_queue_widget")

    self.exclude_prefabs = t_util:MergeList(exclude_prefabs)
    self.include_prefabs = t_util:MergeList(include_prefabs)
    local skins = self:GetSkins()
    self.count_start = #skins

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.black = self.root:AddChild(TEMPLATES.BackgroundTint(1))

    self.width, self.height = 700, 700
    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(self.width, self.height))

    local r, g, b = unpack(UICOLOURS.BROWN_DARK)
    self.dialog:SetBackgroundTint(r, g, b, 1)
    self.time_dt = 0
    self.time_flush = 1
    self.posx_start = 300
    self.posy_start = 130
    self.fontsize_count = 35

    self.color_yellow = RGB(222, 222, 99)
    self.color_blue = RGB(0, 200, 255)
    self.color_red = RGB(220, 20, 60)

    self.widget_1 = self.dialog:AddChild(Widget("skin_queue_widget_1"))
    self.text_1 = self.dialog:AddChild(Text(HEADERFONT, 30, "Press Esc to exit...", self.color_blue))
    self.text_1:SetHAlign(ANCHOR_LEFT)
    self.text_1:SetRegionSize(self.width, 55)
    self.text_1:SetPosition(-self.posx_start + self.width / 2 -40, -self.posy_start)

    if self.count_start == 0 then
        self:AutoError("No skin to unravel,\nPage will close in ({num}) seconds...", 4)
    else
        self.anim_skin = self.widget_1:AddChild(self:BuildPreview(skins[1]))
        local shift_anim = self.posy_start - 2 * self.fontsize_count
        self.anim_skin:SetPosition(190, shift_anim)
        self.anim_bar = self.widget_1:AddChild(self:BuildBar())
        self.anim_bar:SetPosition(0, 230)

        for i = 1, 5 do
            local img = self.widget_1:AddChild(Image("images/button_icons.xml", "weave_filter_on.tex"))
            self["image_" .. i] = img
            img:SetSize(self.fontsize_count - 2, self.fontsize_count - 2)
            img:SetPosition(-self.posx_start - 30, self.posy_start - (i - 1) * self.fontsize_count)
        end
        for i = 2, 6 do
            local text = self.widget_1:AddChild(Text(CHATFONT, self.fontsize_count, ""))
            self["text_" .. i] = text
            text:SetHAlign(ANCHOR_LEFT)
            text:SetRegionSize(self.width, self.fontsize_count + 5)
            text:SetPosition(-self.posx_start + self.width / 2 - 10, self.posy_start - (i - 2) * self.fontsize_count)
        end
        self.text_2:SetColour(self.color_yellow)
        self.text_3:SetColour(self.color_yellow)
        self:Flush()
        self:StartUpdating()
    end
end)

function SQ:OnUpdate(dt)
    if TheInput:IsControlPressed(CONTROL_CANCEL) then
        dbg("Exit key pressed, closing skin queue")
        if TheFrontEnd and TheFrontEnd.PopScreen then
            TheFrontEnd:PopScreen()
        end
        self:Kill()
        return
    elseif m_util:IsHuxi() and TheInput:IsControlPressed(CONTROL_SECONDARY) then
        if TheFrontEnd and TheFrontEnd.PopScreen then
            TheFrontEnd:PopScreen()
        end
        self:Kill()
        return
    end
    self.time_dt = self.time_dt + dt
    if self.time_dt > self.time_flush then
        self.time_dt = 0
        self:Flush()
    end
end

function SQ:AutoError(str, seconds)
    if self.error_flag then return end
    self.error_flag = true
    self.widget_1:Hide()
    str = str or "An exception occurred!\nPage is automatically closing ({num})..."
    seconds = seconds or 3
    local function SetNum(i)
        return function()
            self.text_1:SetString(subfmt(str, { num = i }))
        end
    end
    self.text_1:SetHAlign(ANCHOR_MIDDLE)
    self.text_1:SetRegionSize(self.width, 200)
    self.text_1:SetPosition(0, 0)
    self.text_1:SetColour(self.color_yellow)
    SetNum(seconds)()
    for i = 1, seconds - 1 do
        self.inst:DoTaskInTime(i, SetNum(seconds - i))
    end
    self.inst:DoTaskInTime(seconds, function() self:Kill() end)
end

function SQ:Flush()
    if self.error_flag then return end
    local skins = self:GetSkins()
    local line = skins[1]
    if line then
        local pause_reason
        dbg("Flush line", line.prefab, "count", line.count, "spool", line.spool)
        local spools_has, spools_pre = self:GetAmout(skins)
        self.text_2:SetString("Unraveling: " .. GetSkinName(line.prefab))
        self.text_3:SetString("Value: " .. line.spool * (line.count - 1) .. " spools")
        self.text_4:SetString("Current: " .. spools_has .. " spools")
        self.text_5:SetString("Pending: " .. spools_pre .. " spools")
        self.text_6:SetString("Final total: " .. spools_pre + spools_has .. " spools")
        self.anim_bar:SetPercent((self.count_start - #skins) / self.count_start)
        self.anim_skin:SetPreview(line.prefab)

        local isPaused
        local screen = h_util:GetActiveScreen()
        dbg("Active screen", screen and screen.name or "nil")

        if screen.name ~= "CollectionScreen" then
            self.waiting_for_wardrobe = false
        end

        if screen.name == "SkinQueuePlus" then
            TheFrontEnd:PopScreen()
        elseif screen.name == "PlayerSummaryScreen" then
            screen:OnSkinsButton()
        elseif screen.name == "CollectionScreen" then
            local item_type = GetTypeForItem(line.prefab)
            local str_btn = TPS[item_type] or item_type
            dbg("CollectionScreen route", "item_type", item_type, "str_btn", str_btn)

            if str_btn == "beards" then
                local picker = t_util:GetRecur(screen, "subscreener.sub_screens.beards.picker")
                dbg("Beards picker", picker and "found" or "nil", "has_target", picker and picker.last_interaction_target and "yes" or "no")
                if picker and type(picker._DoCommerce) == "function" and PrepareUnravelTarget(picker, line.prefab) then
                    picker:_DoCommerce(line.prefab)
                else
                    local subscreener = t_util:GetRecur(screen, "subscreener")
                    dbg("Beards menu select", subscreener and "found" or "nil")
                    if subscreener and subscreener.OnMenuButtonSelected then
                        subscreener:OnMenuButtonSelected("beards")
                    else
                        return self:AutoError()
                    end
                end
            else
                if not self.waiting_for_wardrobe then
                    self.waiting_for_wardrobe = true
                    local hero = "wendy"
                    dbg("Open WardrobeScreen with hero", hero)
                    screen:OnSkinsButton(hero)
                end
                return
            end
        elseif screen.name == "WardrobeScreen" then
            local item_type = GetTypeForItem(line.prefab)
            local str_btn = TPS[item_type] or item_type
            local picker = str_btn and t_util:GetRecur(screen, "subscreener.sub_screens." .. str_btn .. ".filter_bar.picker")
            dbg("Wardrobe route", "item_type", item_type, "str_btn", str_btn, "picker", picker and "found" or "nil", "has_target", picker and picker.last_interaction_target and "yes" or "no")
            if picker and type(picker._DoCommerce) == "function" and PrepareUnravelTarget(picker, line.prefab) then
                picker:_DoCommerce(line.prefab)
                dbg("Wardrobe unravel", "performed unravel action for", line.prefab)
            else
                local subscreener = t_util:GetRecur(screen, "subscreener")
                dbg("Wardrobe subscreener", subscreener and "found" or "nil")
                if subscreener and subscreener.OnMenuButtonSelected and str_btn then
                    dbg("Wardrobe menu select", "selected", str_btn)
                    subscreener:OnMenuButtonSelected(str_btn)
                else
                    dbg("Wardrobe error", "missing subscreener or menu function")
                    return self:AutoError()
                end
            end
        elseif screen.name == "BarterScreen" then
            local title = screen.dialog.title:GetString()
            dbg("Barter title", title)
            local btn_dupes
            local btn_single
            if title == STRINGS.UI.BARTERSCREEN.TITLE then
                if (line.count > 2) then
                    btn_dupes = t_util:IGetElement(t_util:GetRecur(screen, "dialog.actions.items") or {}, function(btn)
                        return btn.text and btn.text:GetString() == STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND_DUPES and btn
                    end)
                else
                    btn_single = t_util:IGetElement(t_util:GetRecur(screen, "dialog.actions.items") or {}, function(btn)
                        return btn.text and btn.text:GetString() == STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND and btn
                    end)
                end
                dbg("Barter buttons", "dupes", btn_dupes and "found" or "nil", "single", btn_single and "found" or "nil")

                local btn_cancel = t_util:IGetElement(t_util:GetRecur(screen, "dialog.actions.items") or {}, function(btn)
                    return btn.text and btn.text:GetString() == STRINGS.UI.BARTERSCREEN.CANCEL and btn
                end)
                if btn_cancel then
                    btn_cancel:Hide()
                end

                if btn_dupes then
                    btn_dupes:ForceImageSize(h_util:ToPos(2, 2))
                    isPaused = true
                    pause_reason = "Manual click required by Klei, click to continue (1/2)"
                elseif btn_single then
                    btn_single:ForceImageSize(h_util:ToPos(2, 2))
                    isPaused = true
                    pause_reason = "Manual click required by Klei, click to continue (1/1)"
                else
                    return TheFrontEnd:PopScreen()
                end
            else
                local fn_btn = screen.item_key and screen.doodad_value and not screen.is_buying and t_util:IGetElement(t_util:GetRecur(screen, "dialog.actions.items") or {}, function(btn)
                    return btn.text and btn.text:GetString() == STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND_DUPES and btn.onclick
                end)
                dbg("Barter grind dupes onclick", fn_btn and "found" or "nil")
                if fn_btn then
                    fn_btn()
                else
                    return TheFrontEnd:PopScreen()
                end
            end
        elseif screen.name == "PopupDialogScreen" then
            local title = screen.dialog.title:GetString()
            dbg("Popup title", title)
            if title == "Disclaimer" then
                return TheFrontEnd:PopScreen()
            elseif title and title:lower():find("connection") and title:lower():find("fail") then
                return TheFrontEnd:PopScreen()
            elseif title and title:lower():find("error") and title:lower():find("trading") then
                return TheFrontEnd:PopScreen()
            elseif title == STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND_DUPES or title == STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND then
                local btn = t_util:IGetElement(t_util:GetRecur(screen, "dialog.actions.items") or {}, function(btn)
                    return btn.text and btn.text:GetString() == STRINGS.UI.POPUPDIALOG.OK and btn.inst and btn.inst.GUID and btn
                end)
                local btn_cancel = t_util:IGetElement(t_util:GetRecur(screen, "dialog.actions.items") or {}, function(btn)
                    return btn.text and btn.text:GetString() == STRINGS.UI.BARTERSCREEN.CANCEL and btn
                end)
                if btn_cancel then
                    btn_cancel:Hide()
                end
                dbg("Popup OK button", btn and "found" or "nil")
                if btn then
                    btn:ForceImageSize(h_util:ToPos(2, 2))
                    isPaused = true
                    pause_reason = "Manual click required by Klei, click to continue (2/2)"
                else
                    return TheFrontEnd:PopScreen()
                end
            else
                return self:AutoError("Error page 1: " .. title .. "-" .. screen.name .. "\nAutomatically closing in ({num})...", 100)
            end
        elseif screen.name == "ItemServerContactPopup" then
            -- Wait for server contact popup to resolve.
        else
            return self:AutoError("Error page 2: " .. screen.name .. "\nAutomatically closing in ({num})...", 5)
        end

        local num_dot = math.ceil(GetTime() % 10)
        local str_dot = ""
        for i = 1, num_dot do
            str_dot = str_dot .. "."
        end
        if isPaused then
            self.text_1:SetColour(self.color_red)
            self.text_1:SetString((pause_reason or "Paused by Klei, click screen to continue") .. str_dot)
            dbg("Paused state active")
        else
            self.text_1:SetColour(self.color_blue)
            self.text_1:SetString("Unraveling, press Esc to exit" .. str_dot)
        end
    else
        self:AutoError("All unraveling completed!\nPage will close in ({num})", 5)
    end
end

-- 260412 VanCa: Allow unravel tradable duplicate skins
function SQ:GetSkins()
    local skins = {}
    local skin_data = u_util:GetSkinsData()
    t_util:IPairs(skin_data.dupes, function(line)
        if not table.contains(self.exclude_prefabs, line.prefab) then
            table.insert(skins, line)
        end
    end)
    t_util:IPairs(self.include_prefabs, function(prefab)
        local line = t_util:GetElement(skin_data.shops, function(_, item)
            return item.prefab == prefab and item.count > 1 and item.spool > 0 and item
        end)
        if line and not table.contains(skins, line) then
            table.insert(skins, line)
        end
    end)
    return table.reverse(skins)
end

function SQ:GetAmout(dupes)
    local now = TheInventory:GetCurrencyAmount()
    local count = 0
    t_util:IPairs(dupes, function(line)
        count = (line.count - 1) * line.spool + count
    end)
    return now, count
end

function SQ:BuildPreview(line)
    local w = UIAnim()
    local prefab = line.prefab
    w:GetAnimState():SetBuild("skingift_popup")
    w:GetAnimState():SetBank("gift_popup")
    w.banner = w:AddChild(Image("images/giftpopup.xml", "banner.tex"))
    w.banner:SetPosition(0, -200, 0)

    w.text_up = w.banner:AddChild(Text(HEADERFONT, 45, "Unravel Preview", UICOLOURS.GOLD_SELECTED))
    w.text_up:SetPosition(0, 370, 0)
    w.text_down = w.banner:AddChild(Text(UIFONT, 55))
    w.text_down:SetPosition(0, -10, 0)
    w:GetAnimState():PushAnimation("skin_loop")
    w:SetScale(.4)

    w.SetPreview = function(ui, prefab_name)
        w.text_down:SetTruncatedString(GetSkinName(prefab_name), 500, 35, true)
        w.text_down:SetColour(line.spool > 100 and GetColorForItem(prefab_name) or UICOLOURS.WHITE)
        w:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(prefab_name), "SWAP_ICON")
    end
    w:SetPreview(prefab)

    return w
end

function SQ:BuildBar()
    local wxpbar = Widget("Bar")
    local bar = wxpbar:AddChild(TEMPLATES.LargeScissorProgressBar())
    local text = wxpbar:AddChild(Text(HEADERFONT, self.fontsize_count, "100%", UICOLOURS.HIGHLIGHT_GOLD))
    text:SetPosition(0, self.fontsize_count * 1.1)
    wxpbar.SetPercent = function(ui, num)
        bar:SetPercent(num)
        text:SetString("Overall progress: " .. string.format("%.2f", num * 100) .. "%")
    end
    wxpbar:SetPercent(0)
    return wxpbar
end

return SQ
