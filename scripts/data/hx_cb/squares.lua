


local f_util = require "util/fn_hxcb"
local ss = {
    {   id = "delete", 
        hover = "Clear Search",
        fn = function(self)
            self:SearchGrid("")
        end
    }, 
    {
        id = "search",
        hover = "Search Now",
        fn = function(self)
            self:SearchGrid()
        end
    },
    {
        id = "silver",
        hover = "Cheat Mode",
        fn = function()
            f_util:FingerSilverStart()
        end
    },
    {
        id = "close",
        hover = "Close Panel",
        fn = function(self)
            if self.CB then
                self.CB:Hide()
            end
        end
    },
    
    
    
    
    
    
    
    
}


return table.reverse(ss)