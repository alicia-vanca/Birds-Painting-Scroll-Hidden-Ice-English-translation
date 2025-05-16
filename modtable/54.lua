-- Skin Purchase Suggestions

local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
AddClassPostConstruct("screens/redux/purchasepackscreen", function(self)
    if not (self.filter_container and self.side_panel and self.purchase_root) then return end
    -- Bubble!
    self.speech_bubble = self.side_panel:AddChild(UIAnim())
    self.speech_bubble:GetAnimState():SetBank("textbox")
    self.speech_bubble:GetAnimState():SetBuild("textbox")
    self.speech_bubble:SetScale(-.6, 1.3, .6)
    self.speech_bubble:GetAnimState():PlayAnimation("open", false)
    self.speech_bubble:Show()
    self.filter_container:SetPosition(0, -150, 0)
    self.speech_bubble:SetPosition(-11, 115, 0)
    -- Text
    self.text = self.side_panel:AddChild(Text(BUTTONFONT, 35, "", WHITE))
    -- self.text:SetRegionSize( 250, 180)
    self.text:SetVAlign(ANCHOR_MIDDLE)
    self.text:EnableWordWrap(true)
    self.text:SetPosition(-11, 115, 0)
    self.text:SetString("")
end)


local function ParsePriceStr(price_str)
    local num, currency
    num, currency = string.match(price_str, "^([A-Z]+)%s*([%d%.]+)")
    if num and currency then
        return tonumber(currency), num
    end
    num, currency = string.match(price_str, "^(%d+)%s*([A-Za-z]+)")
    if num and currency then
        return tonumber(num), currency
    end
    num, currency = string.match(price_str, "^(%d+%.%d+)%s*([A-Za-z]+)")
    if num and currency then
        return tonumber(num), currency
    end
    num, currency = string.match(price_str, "^(%d+)%s*(%S+)$")
    if num and currency then
        return tonumber(num), currency
    end
end

local InfoAll = {}
local function Getinfo(iap)
    local itp = iap and iap.item_type
    if not itp then return end
    if InfoAll[itp] then return InfoAll[itp] end
    local title = GetSkinName(itp)
    local sale_active = IsSaleActive(iap)
    local pricestr = BuildPriceStr(iap, iap, sale_active)
    if not pricestr then return end
    local money, currency = ParsePriceStr(pricestr)
    if not money or money == 0 then return end
    local items = t_util:GetRecur(MISC_ITEMS, itp..".output_items")
    if not items then return end
    local sell_all, sell_own, buy_own = 0, 0, 0
    t_util:IPairs(items, function(item_key)
        local sell = TheItems:GetBarterSellPrice(item_key) or 0
        local buy = TheItems:GetBarterBuyPrice(item_key) or 0
        sell_all = sell_all + sell
        if TheInventory:CheckOwnership(item_key) then
            sell_own = sell_own + sell
        else
            buy_own = buy_own + buy
        end
    end)

    InfoAll[itp] = {
        iap = iap,              -- Package data
        itp = itp,              -- Package key
        money = money,          -- Current price
        -- 250516 VanCa: Add process for VND
        currency = currency == "VND" and "đ" or currency,        -- Current currency
        sale_active = sale_active,  -- Whether it's on sale
        title = title,    -- Package name -- Can also get skin name
        items = items,              -- Items in the package
        sell_all = sell_all,                -- Total disassembly
        sell_own = sell_own,                -- Disassembly of owned items
        buy_own = buy_own,                  -- Exchange for missing items
        -- 250516 VanCa: Get exact value and add process for VND
        -- value = math.floor(sell_all/money),
        value = sell_all/money,
        value_per_currency = currency == "VND" and "~"..math.floor(sell_all*10000/money).." spools/10k đ" or "~"..math.floor(sell_all/money).." spools/"..currency
    }
    return InfoAll[itp]
end

local function OnFocus(w)
    local info = Getinfo(w and w.iap_def)
    if not info then return end
    local str = info.title.."\n\n".."Price: "..info.money..info.currency.."\n"
    if info.buy_own ~= 0 then
        str = str.."Weave un-owned: "..info.buy_own.." spools".."\n"
    end
    if info.sell_own ~= 0 then
        str = str.."Unravel duplicates: "..info.sell_own.." spools".."\n"
    end
    if info.sell_all ~= 0 then
        str = str.."Value: "..info.value_per_currency.."\n"
    end
    
    local bubble = t_util:GetRecur(h_util:GetActiveScreen("PurchasePackScreen"), "text")
    if bubble then
        bubble:SetString(str)
    end
end

local info_best
local function fn_tip(w)
    local info = Getinfo(w and w.iap_def)
    if not (info and info_best) then return end
    local str = ""
    if info.buy_own == 0 then
        str = "You already own all the items or skins in this package！\n"
        if info.itp == info_best.itp then
            str = str.."This is the best package for getting spools！\n"
            str = "It can be unraveled to get "..info.sell_own.." spools ("..info_best.value_per_currency..").\n"
        else
            str = str.."This package can be unraveled to get "..info.sell_own.." spools ("..info.value_per_currency..")\n"
            str = str.."If you want to get spools, it's more recommended to buy【"..info_best.title.."】("..info_best.value_per_currency..").\n"
        end
    else
        str = "Weave all un-owned items need "..info.buy_own.." spools.\n"
        str = str.."Unravel all duplicates after buying can get "..info.sell_own.." spools.\n"
        local bount = info.buy_own+info.sell_own
        str = str.."So, it's like spending "..info.money..info.currency.." to buy "..bount.." spools.\n"
        if info.itp == info_best.itp then
            str = str.."This is the best package for getting spools right now, "
            str = str.."completely unravel can get "..info.sell_all.." spools ("..info.value_per_currency..").\n" 
        else
            str = str.."The best package for unraveling right now is【"..info_best.title.."】("..info_best.value_per_currency..")，"
            local bount_best = info.money*info_best.value
            -- 250516 VanCa: floor bount_best since value is a float value
            str = str..info.money..info.currency.." can get ~".. math.floor(bount_best).." spools with that package. "
            local str_add, money_best
            if bount > bount_best then
                str_add = "buying【"..info.title.."】directly is more cost-effective"
                -- money_best = bount - bount_best
            else
                money_best = bount_best - bount
                -- 250516 VanCa: Change saving amount to percent
                -- money_best = tonumber(string.format("%.2f", (money_best/info_best.value)))
                money_best = string.format("%.0f%%", (money_best/info_best.value)/info.money*100)
                str_add = "buying【"..info_best.title.."】and then unravel spools to weave is more cost-effective, saving "..money_best
            end

            str = str.."So, "..str_add..".\n"
        end
    end
    
    if not IsSaleActive(info_best.iap) then
        str = str.."However, there is no big sale event at the moment, it's recommended to wait for a big sale, which can save more."
    end
        -- 25516 VanCa: Shorten the title from [info.title.." · Purchase Suggestions"], change longness from "big" to "bigger"
    h_util:CreatePopupWithClose(info.title, str, nil, {longness = "bigger"})
end

local str_pcscreen = "screens/redux/purchasepackscreen"
local pc_screen = require(str_pcscreen)
local pc_widget = c_util:GetFnEnv(pc_screen._BuildPurchasePanel).PurchaseWidget
if not pc_widget then return end
local __ctor = pc_widget._ctor
pc_widget._ctor = function(self, ...)
    local ret = __ctor(self, ...)
    local _OnGainFocus = self.OnGainFocus
    self.OnGainFocus = function(w, ...)
        OnFocus(w)
        return _OnGainFocus(w, ...)
    end

    self.tip_button = self.root:AddChild(h_util:CreateImageButton{prefab = "weave_filter_on", pos = {-170, -57}, size = 45, hover = "Purchase Suggestions", hover_meta = {offset_y = 45}, fn = function()
        fn_tip(self)
    end})
    return ret
end



AddClassPostConstruct(str_pcscreen, function()
    -- Wait until loaded to read data, so players will only blame Kore for lag, not my mod
    if info_best then return end
    local value_best = -1
    t_util:IPairs(TheItems:GetIAPDefs(), function(iap)
        local info = Getinfo(iap)
        if info.value > value_best then
            info_best = info
            value_best = info.value
        end
    end)
end)
