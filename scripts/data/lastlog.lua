return 
[=[
--------------------------start logging here----------------------------
2025.4.4 v4.84
**[Range Tracking]**
- Removed Tallbird's aggro range
**[Fenghua Chapter]**
- Migrated **[Mod Compatibility Test]** from the "Hidden Ice" mod
**[Wendy Assist]**
- Added **[Forced Attack]**
**[Developer API]**
- Allowed mods to modify pop-up panels via the `m_util` interface:
  1. BindShowScreenID
  2. BindShowScreenTitle

2025.4.3 v4.83
**[Quick Announcements]**
- Added numerous meow sounds 󰀍 for AI
- Items can now be individually defined in the corpus for announcements
- Regex replacement for statements now supported in the corpus
**[Behavior Queue Theory]**
- Disabled queue preview for Abigail's Flower (to prevent crashes)
**[Range Tracking]**
- Added placement range for structures: Mushroom Lamp, Scaled Furnace, Winch, etc.

2025.3.22
**[Direction Indicator]**
- Added Little Gestalt support
**[Wendy Assist]**  
1. Added timers for **[Abigail's Potion]** and **[Abigail Affinity]**
2. Added **[Little Gestalt Assist]**
3. Added shortcut for **[Picnic Basket]**
**[T-key Console]**
- Fixed partial key malfunctions, adjusted category layouts

2025.3.20 v4.81
**[T-key Console]**
1. Reverted to lazy mode; search function no longer hidden
2. Fixed crash when removing modded items
**[Wendy Assist]**
1. Shortcut for summoning/recalling Abigail
2. Skill wheel and skill shortcuts
3. Skill cooldown display (shown on Abigail's Flower)
4. "Potions and Little Gestalt features coming soon – patience!"

2025.3.19 v4.8
【Quick Declaration】
1、Added 【AI Cat Girl】 declaration meow！
2、Added 【Mew Mew Call】 declaration meow󰀍~
【Development Interface】
ShowScreen added imgstr related direct access variables（versions below this will crash）
Database added TIP descriptions, making it easier for authors to leave messages


2025.3.18 v4.74
【Quick Declaration】
1、Can interact with showme/insight/simple health bar/epic health bar to declare health
2、Can interact with showme/insight to declare package contents
【Behavior Queue Theory】 Fixed a rare crash
【Packaging Memory】 This feature will automatically disable after enabling showme/insight


2025.3.17 v4.73
【Quick Declaration】
1、Cooking pot can declare dishes
2、Added WX-78 power declaration, chip declaration, and skill tree later
【T Key Console】
Fixed the issue where some players couldn't teleport
【Development Interface】
e_util.ClonePrefab: can now stably return name
c_util.HashEqual: performs multiple forms of hash comparison for two elements

2025.3.16 v4.72
【Quick Declaration】
1、Fixed issues with declaring blueprint drafts and advertisements incorrectly
2、Added three-tier declarations for Woby
3、Added 【Declaration Lock】 and 【Chat Lock】, newbies please do not open
【Wind and Flower Chapter】
Fixed crashes caused by certain mods


2025.3.15
【T Key Console】
1、Improved search algorithm, thanks to Luka's help
2、Now you can automatically search by typing content！
3、Divided the Deadly Brightshade into a boss
【Quick Declaration】
Added the function of 【Preventing Key Sticking】, if you've changed the game's 【Forced Attack】 【Forced Stacking】 eys, disabling this option will allow you to use declarations normally

2025.3.14
[T Key Console] Fixed the bug that the dishes did not have seasoning textures, thanks to Luka for his help
[Geometry Layout] Changed the default off to the default display preview texture
[My Notes] Fixed [Hermit Crab Task]
[Quick Announcement]
1. Fixed the problem of announcing that the number of dead entities was 0
2. Replaced the pig skin with a pig head expression
3. Added [Recipe Integration], which can batch announce the required materials
4. Added the setting of [Equipment Announcement], dividing the equipment column into the inventory column


2025.3.13
【Card Key】Optimized the card key issue for automatic cooking and queue theory on the T key console
【Chop a Cane】Fixed the issue where strong looting bags couldn't chop canes
【Quick Declaration】
1、Distinguished between gold mines and moon island saplings for declaration
2、Fixed the issue of Terraria status declaration reversal
3、Fixed the issue of declaring 255% freshness


2025.3.12
【Geometric Layout】Fixed a sporadic crash


2025.3.11
【Quick Declaration】Wrote a semi-finished product for temporary use, to be perfected next week


2025.3.4
【Item Search】Optimized logic, making it easier to find items with the same name


2025.3.1
【Recipe Bar】Fixed the issue where using other texture mods would prevent correct item retrieval
Optimized code performance and fixed some crashes


2025.2.29
【Geometric Layout】Changed the default setting of 【Placement Preview】to be enabled
【Recipe Bar】Fixed 3 known crashes


2025.2.28
【Auto Navigation】Changed the default setting of 【One-Key Transmission】to be disabled
【Demon Assistant】【On-Site Jump】changed to 【Designated Jump】, allowing jumps to the mouse pointer position

2025.2.25
【Key Display】Changed the TLIDE key icon to ~
【Behavior Queue Theory】Attempted to fix the issue of mod equipment not being able to plow, scrape, or water the ground -- untested
【Update Plan】In developer mode, the update plan will be displayed on the function panel
【T Key Console】Categorized all previously uncategorized items
【Special Thanks】Added a list of thanked players (contribution: categorized T key console, massive workload)
【Development Interface】Added t_util:NumThreshold, used to determine which numerical range an integer belongs to
【Development Interface】Saver added three interfaces for rain, moon phase, and day count
【Auto Attack】Added an option to no longer attack one's own pets




2025.2.17
【Range Tracking】Increased the attack range of the hidden nightmare
【Breath Bar】Attempted to fix a sporadic crash issue with 【Automatic Footprint】
【Development Interface】Added a function FEP_V for printing console key values, corresponding to FEP_K
【Range Tracking】Increased the thermal range of the dragon scale furnace, but when there is an item on the mouse, clicking will no longer display the range
【Special Thanks】Added a list of thanked players (contribution: fixed multiple difficult issues with the scroll)




2025.2.16
[Range Tracking] Increase the attack range of the otter
[Panel and Buttons] Because it is the Year of the Snake, the otter style icon is added
[Spawn Command] This function is set to be visible only in developer mode to prevent newbies from misoperating


2025.2.11
【Log System】The scroll can finally view the update log, thanks to the customization of the gold master Sasuke!
【Key Prompt】Waiting for default settings to be modified
【Breathing Bar】Attempting to fix an occasional crash issue with 【Auto Footprint Flip】
【Holiday Wishes】Wishing everyone a 󰀍 Valentine's Day!
【Friendly Reminder】Function panel->right-click【Update Log】->open【Popup Reminder】, so it will automatically pop up every time it's updated.



2025.2
No more logs! Thanks for subscribing!

]=]
