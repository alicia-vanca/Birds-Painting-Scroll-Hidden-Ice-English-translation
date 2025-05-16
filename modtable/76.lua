local HxNote = require "widgets/huxi/huxi_note"
local save_id, str_title, icon = "sw_mynote", "My notes", "skill_icon_bw"
local default_data = {}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local funcs = {
    SavePos = function(pos)
        fn_save("posx")(pos.x)
        fn_save("posy")(pos.y)
    end
}

local function GetUIData()
    local ui_data = {}
    local note_data = m_util:GetData("NOTE")
    t_util:Pairs(note_data, function(dot, data)
        local info = {
            id = data.id,
            label = data.title,
            default = true,
            hover = STRINGS.LMB .. "View " .. data.title,
            fn = function()
                m_util:PopShowScreen()
                h_util:AddAnonUI(HxNote(funcs, save_data, note_data, dot))
            end,
            priority = data.priority,
        }
        -- Compatible with new and old interfaces
        if data.icon then
            info = t_util:MergeMap(info, {
                type = "imgstr",
                prefab = data.icon,
            })
        end
        table.insert(ui_data, info)
        t_util:SortIPair(ui_data)
    end)

    return ui_data
end

local fn_left = function()
    m_util:AddBindShowScreen({
        title = str_title,
        id = save_id,
        data = GetUIData()
    })()
end

m_util:AddBindConf(save_id, fn_left, nil, {str_title, icon,
                                           STRINGS.LMB .. 'Game notes' .. STRINGS.RMB .. 'Reset position',
                                           true, fn_left, function()
                                            fn_save("posx")(false)
                                            fn_save("posy")(false)
                                           end, 3000})

----------------------------------- Content below can be written anywhere
-- Vanca: edit the size of the note
m_util:AddNoteData("farmplant", "Seasonal Crops", 600, 700, [[
Spring:
1:1    Potato:Tomato
1:2    Dragon Fruit:Tomato
1:1:1    Garlic:Onion:Dragon Fruit
1:2:2    Onion:Potato:Corn/Asparagus
Summer:
1:2    Pepper/Dragon Fruit:Tomato
1:1:1    Pepper/Dragon Fruit:Garlic:Onion
Fall:
1:1    Potato:Tomato
1:2    Pepper:Tomato
1:1:1    Garlic:Onion:Pepper
1:2:2    Onion:Potato:Corn
Winter:
1:1:1    Pumpkin:Potato:Asparagus
1:2:2    Garlic:Potato:Pumpkin
]], {icon = "tomato_oversized"})

-- Vanca: edit the size of the note
m_util:AddNoteData("fertilizer", "Fertilizer Guide", 700, 570, [[
Growth    Compost    Manure    Fertilizer
     1               0               0       Spoiled Fish
     2              0               0       Rotten Fish
     4              0               0       Growth Formula
     0              1                0       Rot
     0              2               0       Rotten Egg
     0              3               0       Compost
     3              4               3       Fertilizer
     0              0               1       Manure
     0              0               2       Guano
     0              0               2       Bucket-o-poop
     1               1                1       Glommer
     1              4                1       Jam
]], {icon = "fertilizer"})

-- Vanca: edit the size of the note
m_util:AddNoteData("farmcook", "Top Farm Recipes", 550, 700, [[
[ 2 Ingredients ]
Salsa: Onion+Tomato
Veggie Burger: Onion+Leafy Meat
Roasted Gluten: Twigs+Potato*1

[ 2.5 Ingredients ]
Cocktail: Ice+Tomato/Asparagus

[ 3 Ingredients ]
Mashed Potatoes: Garlic + 2*Potatoes

Health: Eggplant    Potato    Tomato    Pomegranate    Dragon Fruit
Hunger: Pumpkin    Corn    Durian    Dragon Fruit
]], {icon = "cookbook"})

-- Vanca: edit the size of the note
m_util:AddNoteData("hermit_crab", "Hermit Crab Tasks", 700, 800, [[
1. 1st House: Cutter shell*10, Boards*10, Firefly*1
2. 2nd House: Marble*10, Cutstone*5, Light Bulb*3
3. 3rd House: Moon Rock*10, Rope*5, Carpet Flooring*5
4. Plant 10 Flowers: Butterfly*10
5. Fish Trash: Boards*2, Cutstone*1, Rope*2 Empty Bottle*1
6. Clear Lureplants: After first Spring
7. Dry 6 Foods: Kelp or Raw Meat*6
8. Plant 8 Berry Bushes and Fertilizes
9. Place Chair: other chairs are needed, 
the ruins chair is only used to unlock the Sawhorse
10. Feed Flower Salad: Flower Salad*1
11. Snow: Tooth Vest Beefalo Vest etc
12. Rain: Umbrella Pretty Parasol Eyebrella etc
13. Heavy Sea Fish*5
14. Any Heavy Seasonal Fish
]], {icon = "hermitcrab"})

-- Vanca: edit the size of the note
m_util:AddNoteData("relic", "Relic Recipes", 480, 450, [[
First Three Fixed:
Thulecite Medallion, Cutstone, Nightmare Fuel
Last Three in Order:
Chair: Purple Gem, Rabbit, Petals
Stool: Purple Gem, Crow, Rabbit
Vase: Red Gem, Butterfly, Petals
Plate: Petals, Berries, Carrot
Bowl: Rabbit, Carrot, Petals
Floor: Carrot, Berries, Petals
]], {icon = "ancient_altar"})

-- Vanca: edit the size of the note
m_util:AddNoteData("wx_78", "WX-78 Scanner Data", 670, 800, [[
1 Overclock (50HP) Spider
2 Super Overclock (150HP) Nurse Spider
1 Processing (40SAN) Butterfly/Moth
2 Super Processing (100SAN+) Shadow Creature
3 Wagstaff (100SAN++) Bee Queen
3 Music Box (SAN+) Crab King/Hermit Crab
1 Stomach (40HUN) Hound
2 Super Stomach (100HUN+) Bearger/Lureplant
6 Speed (25%) Rabbit
2 Super Speed (25%-) Clockwork/Ancient Guardian
3 Heat (Warming) Dragonfly/Fire Hound
3 Cooling (Cooling) Deerclops/Ice Hound
2 Electric (30 Reflect) Volt Goat
4 Solar (Night Vision) Mole
3 Illumination (Glow) Octopus/Firefly/Depth Worm
]], {icon = "wx78"})

-- Vanca: edit the size of the note
m_util:AddNoteData("alter", "Lunar Siphonator", 600, 350, [[
Stage 1: Scrap*4, Moongleam*5, Electrical Doodad*2
Stage 2: Scrap*4, Moongleam*10, Infused Moon Shard*10
Stage 3: Restrained Static*1, Celestial Orb*1, Infused Moon Shard*20 
Total: Orb*1, Static*1, Electrical Doodad*2, Moongleam*15, Scrap*8, Infused Shards*30
]], {icon = "moon_device"})

-- Vanca: edit the size of the note
m_util:AddNoteData("crabking", "Crab King Buff", 500, 650, [[
Blue: +Freeze Resistance +Ice Shield Health, Break Time
Red: +Turret Attack Power, +Ship Leak Size
Yellow: +Turret Quantity, Health -Collision Damage
Purple: +Crab Guard Quantity, Health, Hypnosis Resistance
Orange: +Healing Amount, +Interrupt Healing Required Hits
Green: +Crab Claw Quantity, Health, Damage

Pearl of Pearls: All Gem Color +3
Rainbow Gem: All Gem Color +1
]], {icon = "crabking"})

if not m_util:IsHuxi() then
    return
end
m_util:AddNoteData("showme", "Console Commands", 800, 500, [[
    Print Data: FEP(t) FEP_M(t) FEP_K(t) FEP_I(t)
    Watch Animation: fepAnim(ent, cd, stop)
    Get Nearby Entities: nearEnt_s?(prefab, range, allowTags, banTags, allowAnims, banAnims, func)
    Get Inventory Item: nearSlot(slot)
    Print Distance: printDist(ent1, ent2)
    Get Tags: getTags(ent, isclone)
    Compare Tags: compTags(tags1, tags2)
    Loop Task: loopStart(cd, func), loopStop
    Watch RPC: watchRPC()
    Listen for eventsÅF watchEvent()
    Inventory UI: getui(slot), ESlot(ui)
]], {icon = icon, priority = 999})
