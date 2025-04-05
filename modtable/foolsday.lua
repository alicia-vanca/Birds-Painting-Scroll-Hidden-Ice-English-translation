local code_joke = "EKAF-EERF-AHAH-1YAD-1RPA"
local code_jokes = {
    code_joke,
    "9BKR-T7L4-FQJ3-8W5S-2N9P",
    "YL7H-MV3E-SXK8-4T9R-1D6Z",
    "4F8S-QW2P-K9JH-3R7G-VX4T",
    "A7H2-9T3L-P6SX-8R4W-M5QK",
    "3J7X-8H4V-2K9S-L6FQ-D5TZ",
}
local jokes = {}
local function addjoke(text, color, img)
    table.insert(jokes, {text=text, color=color, img=img})
end
addjoke("Due to your use of cheat mods, you have been banned by the administrator!", "Crimson", "view_ban")
addjoke("Hold down 「ALT+F4」 to speed up entering the game.", "Spring green")
addjoke("Thank you for playing, here's a skin redemption code 「"..code_joke.."」. Please activate it on the 「Collection」 page.", "Yellow", "quagmire_key")
addjoke("Three-minute countdown...The Constant is about to descend upon the globe.....", "Breathing blue", "world")
addjoke("Insufficient disk space! Uninstalling Don't Starve...")

local _, joke
if math.random() < 0.2 then
    _, joke = t_util:GetRandomItem(jokes)
end

local Loadingwidget = require "widgets/redux/loadingwidget"
local _SetEnabled = Loadingwidget.SetEnabled
Loadingwidget.SetEnabled = function(self, ...)
    local ret = _SetEnabled(self, ...)
    if joke then
        if self.loading_tip_text and joke.text then
            self.loading_tip_text:SetString(joke.text)
        end
        if self.loading_tip_icon and joke.img then
            local xml, tex = h_util:GetPrefabAsset(joke.img)
            if xml then
                self.loading_tip_icon:SetTexture(xml, tex)
            end
        end
    end
    return ret
end

local _KeepAlive = Loadingwidget.KeepAlive
Loadingwidget.KeepAlive = function(self, ...)
    local ret = _KeepAlive(self, ...)
    if joke and joke.color and self.loading_tip_text then
        self.loading_tip_text:SetColour(h_util:GetRGB(joke.color))
    end
    return ret
end

local items = t_util:GetMetaIndex(TheItems)
if not items then return end
local _RedeemCode = items.RedeemCode
items.RedeemCode = function(self, code, ...)
    if table.contains(code_jokes, code) then
        local TKU = require("screens/thankyoupopup")
        local pop = TKU({{item="emote_laugh", item_id=0, gifttype="LUNAR_NY", message="Happy April Fool's Day!"}})
        local _SetSkinName = pop.SetSkinName
        pop.SetSkinName = function(self, ...)
            _SetSkinName(self, ...)
            self.upper_banner_text:SetString("Haha")
            self.item_name:SetString("You received nothing")
        end
        TheFrontEnd:PushScreen(pop)
    else
        return items.RedeemCode(self, code,...)
    end
end
