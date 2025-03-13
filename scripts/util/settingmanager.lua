-- Note: this library is generally common, and it is the world management library. that can only be used in the world
-- 2024-4-23 the library has been packed in secondary, and the specific interface refers to f_mana
local f_mana = require "util/filemanager"
local save_path = "ShroomMilkSettings.txt"
local SM = f_mana(save_path)
return SM