local t_util = require "util/tableutil"
local c_util = require "util/calcutil"
local r_data = require "data/redirectdata"
local e_util = require "util/entutil"
local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Image = require "widgets/image"
local Label = require "widgets/huxi/hx_label"
local ImageButton = require "widgets/imagebutton"
local xml_quag = "images/quagmire_recipebook.xml"
local xml_ui = "images/ui.xml"


local h_util = {
    doubleclicktime = 0.3,
    xml_path = {
        "hx_icons1.xml",
        "hx_icons2.xml",
        "button_icons.xml",
        "button_icons2.xml",
        "serverplaystyles.xml",
        "quagmire_recipebook.xml",
        "skilltree.xml",
        "global_redux.xml",
        -- "crafting_menu.xml", -s not recommended, please use resolvefilepath (crafting_atlas)
    },
    minimap_path = {
        "minimap/minimap_data.xml",
        "minimap/minimap_data1.xml",
        "minimap/minimap_data2.xml",
    },
    ok = "I know",
    cancel = "Off",
    error = "Error!",
    yes = "Sure!",
    no = STRINGS.UI.CONTROLSSCREEN.CANCEL,
    screen_x = RESOLUTION_X,
    screen_y = RESOLUTION_Y,
}
h_util.screen_w, h_util.screen_h = TheSim:GetScreenSize()

local rate_w, rate_h = h_util.screen_w/1920, h_util.screen_h/1080
h_util.btn_size = 50 * rate_w

function h_util:ToRate(x)
    return x * rate_w
end
function h_util:ToSize(x, y)
    return x * rate_w, y * rate_h
end

function h_util:AddXmlPath(path)
    t_util:Add(h_util.xml_path, path)
end
-- Make the UI with parent object draggable, func_stop is used to execute the event of the end position of dragging
-- When UI_follow exists, UI_follow is the dragged entity, but it will make the UI move with it
-- When there is no parent object and you want to use this method, use h_util:AddAnonUI to add an anonymous parent object
function h_util:ActivateUIDraggable(UI, func_stop, UI_follow)
    local pos_last = UI:GetPosition()

    UI_follow = UI_follow or UI
    UI_follow.FollowMouse = function(ui)
        if ui.followhandler == nil then
            local cur_pos = TheInput:GetScreenPosition()
            local scale = 1 / UI.parent:GetScale().x
            local ori_pos = pos_last
            ui.followhandler = TheInput:AddMoveHandler(function(x, y)
                pos_last = (Vector3(x, y, 0) - cur_pos) * scale + ori_pos
                UI:SetPosition(pos_last)
                if TheInput:IsControlPressed(CONTROL_CANCEL) or not TheInput:IsMouseDown(MOUSEBUTTON_LEFT) then
                    ui:StopFollowMouse()
                end
            end)
        end
    end

    local _OnMouseButton = UI_follow.OnMouseButton
    UI_follow.OnMouseButton = function(ui, press, down, ...)
        local result = _OnMouseButton(ui, press, down, ...)
        if ui.focus then
            if press == MOUSEBUTTON_LEFT then
                if down then
                    pos_last = UI:GetPosition()
                    return ui:FollowMouse()
                else
                    UI_follow:StopFollowMouse()
                    UI:SetPosition(pos_last)
                    if type(func_stop) == "function" then
                        func_stop(pos_last)
                    end
                end
            end
        end
        ui:StopFollowMouse()
        return result
    end
end

-- Anonymous Parent Object
function h_util:AddAnonUI(ui)
    local sc = self:GetActiveScreen()
    sc:AddChild(ui)
    return ui
end


-- Button zoom
function h_util:ActivateBtnScale(UI, size)
    local tp = h_util:GetType(UI)
    size = size or self.btn_size
    if tp == "UIAnim" then
        local scale = size / 60 * 0.2 * rate_w
        UI:SetScale(scale)
    elseif tp == "BUTTON" then
        local x, y = UI:GetSize()
        local nscale = math.min(size * rate_w / x, size * rate_w / y)
        UI:SetNormalScale(nscale)
        UI:SetFocusScale(nscale * 1.2)
    elseif tp == "Image" then
        local x, y = UI:GetSize()
        local nscale = math.min(size / x, size / y)
        UI:SetScale(nscale)
        UI:SetOnGainFocus(function()
            UI:SetScale(nscale * 1.2)
        end)
        UI:SetOnLoseFocus(function()
            UI:SetScale(nscale)
        end)
    end
end

local scrolls = {MOUSEBUTTON_SCROLLUP, MOUSEBUTTON_SCROLLDOWN}
-- Binding click to operate
function h_util:BindMouseClick(UI, data)
    local time_press = 0
    local _OnMouseButton = UI.OnMouseButton
    UI.OnMouseButton = function(UI, btn, down, ...)
        if not table.contains(scrolls, btn) then
            if down then
                time_press = GetStaticTime()
                if btn == MOUSEBUTTON_LEFT then
                    h_util:PlaySound("click_object")
                end
            else
                if GetStaticTime() - time_press < h_util.doubleclicktime and type(data[btn]) == "function" then
                    data[btn]()
                end
            end
        elseif type(data[btn]) == "function" then
            data[btn]()
        end
        return _OnMouseButton(UI, btn, down, ...)
    end

    if t_util:GetElement(data, function(btn)
        return table.contains(scrolls, btn)
    end) and TheCamera then
        -- There is a disadvantage in this way, and the focus will take over the window control. i just wanted to control the window to become bigger and smaller. now the rotating screen has failed.
        -- Todo: there is also a way to write to control zoomin/zoomout
        local _CanControl = TheCamera.CanControl
        TheCamera.CanControl = function(...)
            return _CanControl(...) and not (UI and UI.focus) 
        end
    end
end

-- Create label
function h_util:CreateLabel(target, text, offset, font, size, colour)
    return ThePlayer and ThePlayer.HUD and ThePlayer.HUD:AddChild(Label(target, text, offset, font, size, colour))
end
-- The original label (using the original label cannot get the above font, and it may report an error for small creatures, recommend the above label)
function h_util:AddText(ent, text, offset_y, font, size, color)
    local valid = type(ent) == "table" and ent.entity and ent.prefab and ent:IsValid() and ent.Transform
    if not valid then return end
    local label = ent.entity:AddLabel()
    label:SetFont(font or CHATFONT_OUTLINE)
    label:SetFontSize(size or 35)
    label:SetWorldOffset(0, offset_y or 3, 0)
    label:SetText(text or "")
    label:SetColour(unpack(self:GetRGB(color)))
    label:Enable(text and true or false)
end
-- Set UI position
function h_util:SetUIPosition(ui, pos)
    if type(pos) == "table" and (pos[1] or pos.x) then
        ui:SetPosition(Vector3(pos[1] or pos.x, pos[2] or pos.y or 0))
    end
end

-- Create a button with an image, make sure it can be a prefab/xml/tex
-- {prefab, size, pos, fn, hover, hover_meta}
-- ForceImageSize
function h_util:CreateImageButton(info)
    -- Set the icon
    local xml, tex = info.xml, info.tex
    if h_util:GetPrefabAsset(info.prefab) then
        xml, tex = h_util:GetPrefabAsset(info.prefab)
    end
    -- Set the size
    local sizes = (type(info.size)=="table" and info.size) or (type(info.size)=="number" and {info.size, info.size}) or {80,80}
    local btn = TEMPLATES.StandardButton(nil, nil, sizes, {xml, tex})
    -- Set the hover
    if info.hover then
        btn:SetHoverText(info.hover, info.hover_meta and info.hover_meta or {offset_y = -sizes[1]})
    end
    -- Set the position
    self:SetUIPosition(btn, info.pos)
    -- Set the function
    if info.fn then
    btn:SetOnClick(function()
        info.fn(btn)
    end)
    end
    return btn
end

-- Create a single image button {id, scale, bg, noclick}
-- CreateFoodImage
-- SetPrefabIcon
local bgs_prefab = {
    quag = {xml_quag, "cookbook_known.tex", "cookbook_known_selected.tex"},
    ui = {xml_ui, "in-window_button_tile_hl.tex", "in-window_button_tile_hl_noshadow.tex"}
}
function h_util:CretePrefabButton(info)
    local w = Widget(info.id or "btn_prefab")
    local tp_bg = info.bg or "quag"
    local bg_prefab = bgs_prefab[tp_bg] or bgs_prefab.quag
    w.cell_root = w:AddChild(ImageButton(unpack(bg_prefab)))
    if info.noclick then
        w.cell_root:Disable()
    end
    w.cell_root:SetNormalScale(info.scale or 1, info.scale or 1)
    w.prefab_img = w.cell_root.image:AddChild(self:CreateFoodImage())
    w.SetPrefabIcon = w.prefab_img.SetPrefabIcon
    return w
end

-- Create a food image {prefab, scale}
function h_util:CreateFoodImage()
    local img = Image(xml_quag, "cookbook_missing.tex")
    img.img_hover = img:AddChild(Image(xml_quag, "cookbook_hover.tex"))
    img.img_hover:Hide()
    img.SetPrefabIcon = function(info)
        local xml, tex = self:GetPrefabAsset(info.prefab)
        if not xml then return end
        local spice_start = tex:find("spice_") and info.prefab:find("_spice_")
        local xml_hover, tex_hover
        if spice_start then
            local baseprefab = info.prefab:sub(1, spice_start - 1)
            xml_hover, tex_hover = self:GetPrefabAsset(baseprefab)
            if xml_hover then
                xml_hover, tex_hover, xml, tex = xml, tex, xml_hover, tex_hover
            end
        end
        img:SetTexture(xml, tex)
        local size = img:GetParent():GetScaledSize()*(info.scale or 0.9)
        if img.atlas:find("scrapbook_icons") then
            img:ScaleToSize(size*1.45, size*1.45)
        else
            img:ScaleToSize(size, size)
        end
        if xml_hover then
            img.img_hover:SetTexture(xml_hover, tex_hover)
            img.img_hover:SetScale(1.3)
            img.img_hover:Show()
        else
            img.img_hover:Hide()
        end
    end
    return img
end

-- Create a single line text entry
-- {hover, prompt, width, height, font_size, fn, pos}
function h_util:CreateTextEdit(info)
    local searchbox = Widget("search")
    info = info or {}
    local text_hover = info.hover or STRINGS.UI.SERVERCREATIONSCREEN.SEARCH
    local text_prompt = info.prompt or STRINGS.UI.SERVERCREATIONSCREEN.SEARCH
    local box_width, box_height = info.width or 430, info.height or 60
    local font_size = info.font_size or 50

	searchbox:SetHoverText(text_hover, {offset_y = font_size})
    searchbox.textbox_root = searchbox:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, box_width, box_height, nil, font_size))
    searchbox.textbox = searchbox.textbox_root.textbox
    -- searchbox.textbox:SetForceEdit(true)
    searchbox.textbox:EnableWordWrap(false)
    searchbox.textbox:EnableScrollEditWindow(true)
    searchbox.textbox:SetTextPrompt(text_prompt, UICOLOURS.GREY)
    searchbox.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)
    searchbox.textbox.OnTextInputted = info.fn and function(down)
        if down then
            info.fn()
        end
    end or nil
     -- If searchbox ends up focused, highlight the textbox so we can tell something is focused.
    searchbox:SetOnGainFocus( function() searchbox.textbox:OnGainFocus() end )
    searchbox:SetOnLoseFocus( function() searchbox.textbox:OnLoseFocus() end )
    searchbox.focus_forward = searchbox.textbox
    self:SetUIPosition(searchbox, info.pos)
    return searchbox
end

local function PopFunc()
    TheFrontEnd:PopScreen()
end

-- Key to identify screen
function h_util:CreatePressScreen(title, currentkey, defaultkey, allowmid, options, fn_modsave)
    local format_string = "[%s] need to bind to a keyboard buttons!\n \nCurrent: [%s] Default: [%s]"
    local body_text = format_string:format(title, currentkey, defaultkey)

    local btns = {
        { text = STRINGS.UI.CONTROLSSCREEN.CANCEL, cb = PopFunc },
        { text = "Bind default ["..defaultkey.."]", cb = function ()
            fn_modsave(nil, "Default:"..defaultkey)
            PopFunc()
        end },
        {
            text = STRINGS.UI.CONTROLSSCREEN.UNBIND,
            cb = function()
                local popup_in = PopupDialogScreen("󰀐: warning", "If you unbind, this operation will be written into the mod settings.\nAfter restarting the game, you will need to manually enable it from the mod settings next time.", {
                    { text = STRINGS.UI.CONTROLSSCREEN.CANCEL, cb = PopFunc },
                    { text = "I'm sure. "..STRINGS.UI.CONTROLSSCREEN.UNBIND, cb = function ()
                        fn_modsave(false, "Disabled")
                        PopFunc()
                        PopFunc()
                    end },
                })
                TheFrontEnd:PushScreen(popup_in)
            end
        },
    }

    if allowmid then
        table.insert(btns, {
            text = "Bind to the function panel",
            cb = function() 
                fn_modsave("biubiu", "Function panel")
                PopFunc()
            end
        })
    end
    local popup = PopupDialogScreen(title, body_text, btns)

    popup.OnRawKey = function(_, key, down)
        if down then return end
        local pressdata = t_util:IGetElement(options, function(opt)
            return opt.data == key and {
                data = opt.data,
                description = opt.description,
            }
        end)
        if pressdata then
            fn_modsave(pressdata.data, pressdata.description)
            h_util:PlaySound("click_move")
            PopFunc()
        else
            h_util:PlaySound("click_negative")
        end
    end
    TheFrontEnd:PushScreen(popup)
end

-- btns:{text, cb(autopop)}  {spacing, longness, style}
function h_util:CreatePopupWithClose(title, bodytext, btns, meta)
    local btns = t_util:IPairFilter(btns or {{text = h_util.ok}}, function (btn)
        return type(btn.text)=="string" and {text = btn.text, cb = function ()
            if type(btn.cb) == "function" then
                btn.cb()
            end
            PopFunc()
        end}
    end)
    title = title or Mod_ShroomMilk.Mod["春"].name
    meta = c_util:FormatDefault(meta, "table")
    local popup = PopupDialogScreen(title, bodytext, btns, meta.spacing, meta.longness, meta.style)
    TheFrontEnd:PushScreen(popup)
end

-- info:{text, cb(prefab)}
function h_util:CreateWriteWithClose(title, info)
    local w_screen = require "screens/huxi/writescreen"
    local screen = w_screen(title, info)
    TheFrontEnd:PushScreen(screen)
    return screen
end

local function checkAtlas(xml, tex)
    xml = xml and resolvefilepath_soft(xml) or xml
    return xml and TheSim:AtlasContains(xml, tex) and xml
end


local function GetImageAsset(prefab)
    local tex = prefab .. ".tex"
    local name = e_util:GetPrefabName(prefab)
    local xml = GetInventoryItemAtlas(tex)
    local atlas = checkAtlas(xml, tex)
    if atlas then
        return atlas, tex, name
    end
    for _, path in ipairs(h_util.xml_path) do
        atlas = checkAtlas("images/" .. path, tex)
        if atlas then
            return atlas, tex, name
        end
    end

    local png = prefab .. ".png"
    for _, path in ipairs(h_util.minimap_path) do
        atlas = checkAtlas(path, png)
        if atlas then
            return atlas, png, name
        end
    end


    local p_data = Prefabs[prefab]
    if p_data then
        local p_assets = p_data.assets
        for _, asset in ipairs(p_assets) do
            local alt, img = xml, tex
            if asset.type == "INV_IMAGE" then
                img = asset.file .. '.tex'
                alt = GetInventoryItemAtlas(img)
            elseif asset.type == "ATLAS" then
                alt = asset.file
            elseif asset.type == "IMAGE" then
                img = asset.file
                img = string.reverse(img:reverse():sub(1, string.find(img:reverse(), "/") - 1))
                alt = t_util:GetElement(p_assets, function(_, asset)
                    return asset.type == "ATLAS" and asset.file
                end)
            end
            atlas = checkAtlas(alt, img)
            if atlas then
                return atlas, img, name
            elseif asset.type == "INV_IMAGE" then
                img = 'quagmire_' .. asset.file .. '.tex'
                alt = GetInventoryItemAtlas(img)
                atlas = checkAtlas(alt, img)
                if atlas then
                    return atlas, img, name
                end
            end
        end
    end


    atlas = checkAtlas(GetScrapbookIconAtlas(tex), tex)
    return atlas, atlas and tex, name
end

local ImageData = {}
local function GetPrefabAsset(prefab)
    if not prefab then return end
    prefab = prefab:gsub("%.tex$", ""):gsub("%.png$", "")
    if not ImageData[prefab] then
        local _prefab = r_data.prefab_image[prefab] or prefab
        local xml, tex, name = GetImageAsset(_prefab)
        name = r_data.prefab_name[prefab] or name
        ImageData[prefab] = xml and {xml = xml, tex = tex, name = name} or {}
    end
    return ImageData[prefab]
end


-- Todo: display seasoning dishes
-- print(h_util:GetPrefabAsset("junk_pile_big"))
function h_util:GetPrefabAsset(prefab)
    local ret = GetPrefabAsset(prefab)
    if ret then
        return ret.xml, ret.tex, ret.name
    end
end

local Sounds = {
    learn_map = "dontstarve/HUD/Together_HUD/learn_map",
    research_available = "dontstarve/HUD/research_available",
    click_move = "dontstarve/HUD/click_move",
    click_object = "dontstarve/HUD/click_object",
    click_negative = "dontstarve/HUD/click_negative",
    respec = "wilson_rework/ui/respec",
    research_unlock = "dontstarve/HUD/research_unlock",
}

-- Play sound
function h_util:PlaySound(sound)
    sound = Sounds[sound] or sound
    TheFrontEnd:GetSound():PlaySound(sound)
    -- TheFrontEnd.gameinterface.SoundEmitter:PlaySound
end

-- Get random skin
function h_util:GetRandomSkin(default)
    if type(PREFAB_SKINS) ~= "table" or default then
        return resolvefilepath_soft("modicon.xml"), "modicon.tex"
    end
    local xml, tex
    repeat
        local name, skins = t_util:GetRandomItem(PREFAB_SKINS)
        if name then
            skins = t_util:MergeList(skins)
            table.insert(skins, name)
            local _, skin = t_util:GetRandomItem(skins)
            xml, tex = h_util:GetPrefabAsset(skin)
        end
    until xml
    return xml, tex
end

-- Get ui category screen pos ent image uianim button
function h_util:GetType(UI)
    local tp = type(UI)
    if tp ~= "table" then
        return tp
    end
    local name = UI and UI.inst and UI.inst.widget and type(UI.name) == "string" and UI.name
    name = name and h_util:GetType(UI.parent) == "screenroot" and "Screen" or name
    name = name or (UI and UI.x and UI.y and UI.z and "Pos")
    name = name or (UI and UI.entity and UI.prefab and UI:IsValid() and "Ent")
    return name
end

-- Control ui visible
function h_util:VisibleUI(UI, show, meta)
    local tp = h_util:GetType(UI)
    if not tp then
        -- Do nothing
        return
    elseif tp == "UIAnim" then
        local anim = UI:GetAnimState()
        if show then
            anim:OverrideSymbol(meta[1], meta[2], meta[1])
        else
            anim:OverrideSymbol(meta[1], "hx_trans", "hx_trans")
        end
    elseif tp == "Image" then
        if show then
            UI:SetSize(1, 1)
            UI:SetScaleMode(SCALEMODE_FILLSCREEN)
        else
            UI:SetSize(0, 0)
        end
    end
end

-- Get color
local colour_default = "White"
local v_data = require("data/valuetable")

local data_rgb = v_data.RGB
function h_util:GetRGB(color, default)
    color = color or default or colour_default
    return data_rgb[color] or data_rgb[colour_default]
end


local wcolour_default = "Blue"
local data_wrgb = v_data.WRGB
function h_util:GetWRGB(color, default)
    color = color or default or wcolour_default
    return data_wrgb[color] or data_wrgb[wcolour_default]
end

-- It should be placed in entutil, but i think it's good to put here
function h_util.SetColor(UI, color)
    color = h_util:GetWRGB(color)
    UI.AnimState:SetMultColour(unpack(color))
    UI.AnimState:SetAddColour(unpack(color))
    return UI
end
function h_util.SetAddColor(UI, color)
    if UI and UI.AnimState then
        if color then
            color = h_util:GetRGB(color)
            UI.AnimState:SetAddColour(unpack(color))
        else
            UI.AnimState:SetAddColour(0, 0, 0, 0)
        end
    end
end

function h_util.SetVisable(UI, bool)
    if bool then
        UI:Show()
    else
        UI:Hide()
    end
    return UI
end


-- Nothing, but i just want to add it here. when other mod copy this tool class, you can delete all the code after this
function h_util:GetControls()
    return h_util:GetHUD().controls or {}
end

-- Get the player hud
function h_util:GetHUD()
    return ThePlayer and ThePlayer.HUD or {}
end

-- Get the front desk screen
function h_util:GetActiveScreen(name)
    local screens = TheFrontEnd.screenstack or {}
    if name then
        return t_util:IGetElement(table.reverse(screens), function(screen)
            return screen.name == name and screen
        end)
    end
    local count = #screens
    if count > 1 then
        return tostring(screens[count]) == "ConsoleScreen" and screens[count-1] or screens[count]
    end
    return TheFrontEnd:GetActiveScreen() or {}
end

-- Control function panel
function h_util:CtrlBoard()
    local board = h_util:GetControls().mboard or h_util:GetActiveScreen().mboard
    if not board then return end
    if board:IsVisible() then
        board:Hide()
    else
        board:Show()
    end
end
-- Get ShowScreen
function h_util:GetShowScreen()
    return self:GetActiveScreen("ShowScreen")
end

-- Get lines
function h_util:GetLines()
    return (self:GetShowScreen() or {}).lines
end

-- Get a small icon
function h_util:GetHicon()
    return h_util:GetControls().hicon or
        t_util:IGetElement(TheFrontEnd.screenstack, function(screen) return screen.hicon end)
end

-- Get equipment master
function h_util:GetECtrl()
    return t_util:GetRecur(h_util:GetControls(), "inv.ectrl")
end

-- Get ShowScreen

-- Get the info tray
function h_util:GetTimer()
    return t_util:GetRecur(ThePlayer, "HUD.controls.hx_timer")
end

function h_util:GetHMaps()
    local screens = TheFrontEnd.screenstack or {}
    return t_util:IPairFilter(screens, function(screen)
        return screen and screen.hx_map
    end)
end

-- Get the transfer character
function h_util:GetStringKeyBoardMouse(keycode)
    local inputs = t_util:GetRecur(STRINGS, "UI.CONTROLSSCREEN.INPUTS") or {}
    return inputs[1] and keycode and inputs[1][keycode]
end

-- Compressed xml string
local zipxmls, unzipxmls = {}, {}
for i = 1, 3 do
    zipxmls["images/inventoryimages"..i..".xml"] = i.."zip"
    unzipxmls[i..'zip'] = "images/inventoryimages"..i..".xml"
end
function h_util:ZipXml(xml, unzip)
    local xmls = unzip and unzipxmls or zipxmls
    return xml and xmls[xml] or xml
end

-- Coordinate conversion
local half_x, half_y = RESOLUTION_X / 2, RESOLUTION_Y / 2
local reso_w, reso_h = h_util.screen_w/RESOLUTION_X, h_util.screen_h/RESOLUTION_Y
function h_util:WorldPosToMinimapPos(x, z)
    -- world -> map
    local map_x, map_y = TheWorld.minimap.MiniMap:WorldPosToMapPos(x, z, 0)
    -- map -> screen
    return ((map_x * half_x) + half_x) * reso_w, ((map_y * half_y) + half_y) * reso_h
end
function h_util:WorldPosToScreenPos(x, z)
    return TheSim:GetScreenPos(x, 0, z)
end

-- Binding mouse 2458 10-14
function h_util:SetMouseSecond()
    return {{
        data = MOUSEBUTTON_RIGHT,
        description = "Right mouse button " .. self:GetStringKeyBoardMouse(MOUSEBUTTON_RIGHT)
    }, {
        data = MOUSEBUTTON_MIDDLE,
        description = "Mouse key " .. self:GetStringKeyBoardMouse(MOUSEBUTTON_MIDDLE)
    }, {
        data = 1006,
        description = "Side keys 1 " .. self:GetStringKeyBoardMouse(1006)
    }, {
        data = 1005,
        description = "Side keys 2 " .. self:GetStringKeyBoardMouse(1005)
    }, {
        data = MOUSEBUTTON_SCROLLUP,
        description = "Rolling wheel " .. self:GetStringKeyBoardMouse(MOUSEBUTTON_SCROLLUP)
    }, {
        data = MOUSEBUTTON_SCROLLDOWN,
        description = "Lower roller wheel " .. self:GetStringKeyBoardMouse(MOUSEBUTTON_SCROLLDOWN)
    }, {
        data = h_util.cancel,
        description = "Cancel binding"
    }}
end

-- The original version of Don't Starve has no way to detect being killed
function h_util:IsValid(ui)
    return ui and ui.inst and ui.inst.widget -- .widget == self, So no need and ui
end

local xml_scrap = "images/scrapbook.xml"
-- Generate illustration background
function h_util:SpawnScrapBookImage(width, height)
    local ratio = width/height
    local suffix = "_square"
    if ratio > 5 then
        suffix = "_thin"
    elseif ratio > 1 then
        suffix = "_wide"
    elseif ratio < 0.75 then
        suffix = "_tall"
    end

    local materials = {
        "scrap",
        "scrap2",
    }
    local tex = materials[math.ceil(rand()*#materials)]..suffix.. ".tex"
    local img = Image(xml_scrap, tex)
    img:ScaleToSize(width,height)
    return img
end




-----------------------------------For Modder-----------------------------------
function h_util:debug_pos(ui)
    if self:IsValid(ui) then
        self:ActivateUIDraggable(ui, function(pos)
            print("debug_pos", pos)
        end)
        t_util:JoinDebug(ui)
    end
end

return h_util
