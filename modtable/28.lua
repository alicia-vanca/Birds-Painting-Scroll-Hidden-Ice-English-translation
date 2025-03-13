local default_data = {
    sw = m_util:IsHuxi(),
    scale = 0.7,
    font = HEADERFONT,
    keytweak = {
        [1] = {"KEY_LCTRL", "KEY_SPACE"},
        [2] = {"KEY_LSHIFT", "KEY_A", "KEY_S", "KEY_D", "KEY_F"},
        [3] = {"KEY_LALT", "KEY_Q", "KEY_W", "KEY_E", "KEY_R"},
    },
    color1 = "White",
    color2 = "White",
    color3 = "White",
    init_x = -20,
    init_y = 25,
}
local save_id, str_show = "sw__keytweak", "Keyboard"
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local KT = require "widgets/huxi/hx__keytweak"
local k_util = require "util/keybind"
local PopupDialogScreen = require "screens/redux/popupdialog"
local V_data = require("data/valuetable")
local kid = "HX_KT"
local KeyBind = {}
local funcs_kt = {}
local function AddKeyBind(keycode, up, func)
    local press = up and "onkeyup" or "onkeydown"
    local ipt = TheInput[press]
    local _func = KeyBind[keycode] 
    if _func then
        m_util:RemoveHandler(ipt, keycode, _func)
        KeyBind[keycode] = nil
    end
    if func then
        ipt:AddEventHandler(keycode, func)
        KeyBind[keycode] = func
    end
end
local function GetUID(keycode)
    return kid..keycode
end

local function GetKT()
    return h_util:GetControls()[kid]
end
local function GetKT_BTN(keycode)
    local kt = GetKT()
    return h_util:IsValid(kt) and kt[GetUID(keycode)]
end

local function BindKT()
    local b_data = {}
    t_util:IPairs(save_data.keytweak, function(line)
        t_util:IPairs(line, function(key_str)
            local keycode = k_util:GetKeyCode(key_str)
            if keycode then
                table.insert(b_data, {
                    code = keycode,
                    down = function()
                        local btn = GetKT_BTN(keycode)
                        if btn then
                            btn.func_press(true)
                        end
                    end,
                    up = function()
                        local btn = GetKT_BTN(keycode)
                        if btn then
                            btn.func_press()
                        end
                    end
                })
            else
                m_util:print("Illegal save!", key_str)
            end
        end)
    end)
    t_util:IPairs(b_data, function(data)
        AddKeyBind(data.code)
        AddKeyBind(data.code, true)
    end)
    if not save_data.sw then return end
    t_util:IPairs(b_data, function(data)
        AddKeyBind(data.code, nil, data.down)
        AddKeyBind(data.code, true, data.up)
    end)
end

local function ReMakeKT(screen)
    local kt = GetKT()
    if h_util:IsValid(kt) then
        kt:Kill()
    end
    if save_data.sw then
        screen = screen or h_util:GetControls()
        if h_util:IsValid(screen) then
            screen[kid] = screen:AddChild(KT(save_data, funcs_kt))
            BindKT()
        end
    end
end

local function fn_set(id)
    return function(val)
        fn_save(id)(val)
        ReMakeKT()
    end
end

local function fn_left()
    fn_save("sw")(not save_data.sw)
    local sw = save_data.sw
    u_util:Say(str_show, sw)
    ReMakeKT()
end
local str_default_add, str_default_remove = "Click to enter key position", "No key position entered yet"
local function fn_text_all(id)
    local function printtext(i)
        local str = ""
        t_util:IPairs(save_data.keytweak[i], function(keystr)
            local show_str = k_util:GetShow(keystr)
            show_str = show_str == " " and "SPACE" or show_str
            if #str < 20 then
                str = str..show_str..","
            end
        end)
        return str == "" and str_default_add or str:sub(1, -2)
    end
    local num = tonumber(id:sub(-1))
    return num and printtext(#save_data.keytweak - num + 1) or str_default_add
end

local function fn_text_last(id)
    local function printtext(i)
        local dict = save_data.keytweak[i]
        local show_str = k_util:GetShow(dict[#dict])
        return show_str and (show_str == " " and "SPACE" or show_str) or str_default_remove
    end
    local num = tonumber(id:sub(-1))
    return num and printtext(#save_data.keytweak - num + 1) or str_default_remove
end
local function PopFunc()
    TheFrontEnd:PopScreen()
end

local function fn_bind(id)
    local _num = tonumber(id:sub(-1))
    local num = _num and #save_data.keytweak - _num + 1
    return num and function(text, ui, screen_data)
        local popup = PopupDialogScreen(str_show, "Please press the keyboard key to add a key for this line!", {{text = "Cancel", cb = PopFunc}})
        popup.OnRawKey = function(_, keycode, down)
            if down then return end
            local keystr = k_util:GetKeyStr(keycode)
            if keystr then
                -- Can't bind two of the same keys
                if t_util:IGetElement(save_data.keytweak, function(line)
                    return t_util:IGetElement(line, function(_keystr)
                        return _keystr == keystr
                    end)
                end) then
                    popup.dialog.body:SetString("The key "..keystr.." has been bound, change to another key.")
                else
                    -- Enter
                    table.insert(save_data.keytweak[num], keystr)
                    fn_save()
                    -- Update display
                    ReMakeKT()
                    ui["add_".._num].uiSwitch(fn_text_all("add_".._num))
                    ui["remove_".._num].uiSwitch(fn_text_last("remove_".._num))
                    h_util:PlaySound("click_move")
                    PopFunc()
                    return
                end
            else
                popup.dialog.body:SetString("This key is not working, change to another key.")
                m_util:print(keycode)
            end
            h_util:PlaySound("click_negative")
        end
        TheFrontEnd:PushScreen(popup)
    end or h_util.error
end


local function fn_remove(id)
    local _num = tonumber(id:sub(-1))
    local num = _num and #save_data.keytweak - _num + 1
    return num and function(text, ui, screen_data)
        local body_text = "Are you sure you want to remove the key ".. text .. " ?"
        local btns = {
            {text = h_util.no},
            {text = h_util.yes, cb = function()
                table.remove(save_data.keytweak[num])
                fn_save()
                ReMakeKT()
                ui["add_".._num].uiSwitch(fn_text_all("add_".._num))
                ui["remove_".._num].uiSwitch(fn_text_last("remove_".._num))
            end}
        }
        if text == str_default_remove then
            body_text = "There are no keys to remove!"
            btns = {{ text = h_util.ok }}
        end
        h_util:CreatePopupWithClose(str_show, body_text, btns)
    end or h_util.error
end

local function fn_reset()
    h_util:CreatePopupWithClose(str_show, "Are you sure you want to restore the default key positions?", {
        {text = h_util.no},
        {text = h_util.yes, cb = function()
            h_util:PlaySound("learn_map")
            t_util:Pairs(save_data.keytweak, function(col, line)
                save_data.keytweak[col] = {}
                t_util:IPairs(default_data.keytweak[col], function(value)
                    table.insert(save_data.keytweak[col], value)
                end)
            end)
            fn_save()
            ReMakeKT()
            PopFunc()
        end}
    })
end
local screen_data = {
    {
        id = "add_1",
        label = "1st line:",
        hover = "Click to add a new button",
        default = fn_text_all,
        fn = fn_bind("add_1"),
        type = "textbtn",
    },
    {
        id = "remove_1",
        label = "Remove:",
        hover = "Click to remove the last button",
        default = fn_text_last,
        fn = fn_remove("remove_1"),
        type = "textbtn",
    },
    {
        id = "add_2",
        label = "2nd line:",
        hover = "Click to add a new button",
        default = fn_text_all,
        fn = fn_bind("add_2"),
        type = "textbtn",
    },
    {
        id = "remove_2",
        label = "Remove:",
        hover = "Click to remove the last button",
        default = fn_text_last,
        fn = fn_remove("remove_2"),
        type = "textbtn",
    },
    {
        id = "add_3",
        label = "3rd line:",
        hover = "Click to add a new button",
        default = fn_text_all,
        fn = fn_bind("add_3"),
        type = "textbtn",
    },
    {
        id = "remove_3",
        label = "Remove:",
        hover = "Click to remove the last button",
        default = fn_text_last,
        fn = fn_remove("remove_3"),
        type = "textbtn",
    },
    {
        id = "sw",
        label = "Keyboard display",
        hover = "Turn the keyboard display on or off",
        default = fn_get,
        fn = function(value)
            fn_save("sw")(value)
            ReMakeKT()
        end,
    },
    {
        id = "reset",
        label = "Restore position",
        hover = "Click to restore default key position",
        default = true,
        fn = fn_reset,
    },{
        id = "scale",
        label = "Scale:",
        hover = "Adjust the UI size\nDefault "..default_data.scale,
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(0.1, 4, 0.05, function(i)
            return {data = i, description = i.." times"}
        end),
        fn = fn_set("scale"),
    },{
        id = "font",
        label = "Font:",
        hover = "Choose your favorite font",
        default = fn_get,
        type = "radio",
        data = V_data.font_datatable,
        fn = fn_set("font"),
    },{
        id = "color1",
        label = "Idle border:",
        hover = "The border color displayed when button is not pressed",
        default = fn_get,
        type = "radio",
        fn = fn_set("color1"),
        data = V_data.RGB_datatable,
    },{
        id = "color2",
        label = "Pressed border:",
        hover = "The border color displayed after pressing the button and the color after overlaying with yellow\nThis is color overlay, not setting the corresponding color",
        default = fn_get,
        type = "radio",
        fn = fn_set("color2"),
        data = V_data.RGB_datatable,
    },{
        id = "init_x",
        label = "X:",
        hover = "Default horizontal coordinate:"..default_data.init_x.. " pixels",
        default = fn_get,
        type = "radio",
        fn = fn_set("init_x"),
        data = t_util:BuildNumInsert(-1000, 2000, 5, function(i)
            return {data = i, description = i .. " pixels"}
        end),
    },{
        id = "init_y",
        label = "Y:",
        hover = "Default vertical coordinate: "..default_data.init_y.. " pixels",
        default = fn_get,
        type = "radio",
        fn = fn_set("init_y"),
        data = t_util:BuildNumInsert(-1000, 2000, 5, function(i)
            return {data = i, description = i .. " pixels"}
        end),
    },{
        id = "color3",
        label = "Font color:",
        hover = "The color of the font",
        default = fn_get,
        type = "radio",
        fn = fn_set("color3"),
        data = V_data.RGB_datatable,
    },
}


local fn_right = m_util:AddBindShowScreen({
    title = str_show,
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, fn_left, nil, {str_show, "quagmire_key",
                                           STRINGS.LMB .. 'Quick Switch' .. STRINGS.RMB .. 'Advanced Settings', true, fn_left,
                                           fn_right})


AddClassPostConstruct("widgets/controls", function(self)
    if not save_data.sw then return end
    ReMakeKT(self)
end)
