return 
[=[

[Action Sequence]

1. Support action wait, for example double-clicking to catch a butterfly can wait and auto-catch when it appears.
2. Support empty response, so you can double-click to catch without clicking the butterfly precisely.
3. Support preview, with no major difference from actual planting.
4. Allow custom items to be treated as the same category.
5. Support queued attacks, no need to hold ctrl+shift; shift double-click will work.
6. Remove farmland alignment, allow box-select planting in 3x3 or 10-tile blocks.
7. Support continuous repeated giving and using on yourself.
8. Support double-click fertilizing and watering.
9. Further strengthen queued attacks, allowing double-click chase for walrus butterflies, etc., instead of chasing and then running away.
10. No longer click-first logic; it is still space-priority logic, so it can work while the mouse is holding an item.
11. Support lighting trees with empty hands (caves only).
12. Lantern tree chopping?


[Simple Geometry]

1. Simplify code, keep only rectangular range display.
2. Hold Alt to automatically hide entities around the mouse for easier placement (@CyB-T inspiration).
3. Display grid cell center points (this feature existed before, but the previous implementation was not the original version).
4. Preserve the old Ctrl-hold temporary display toggle.
5. Always show the item on the mouse when holding fertilizer (new players in the old version often asked why poop did not show).
6. Preserve the old feature to set colors for point markers.
7. Preserve the old feature to change grid size (or maybe add a hotkey to show all surrounding points at once).
8. Preserve the old option to choose whether to show planting preview.
9. Preserve the old option to choose whether to display the item on the cursor, show quantity, or show nothing.
10. Add precise structure placement support (show placement points when carrying a statue).
Doubts:
1. Keep the optional grid display on farmland, but should farmland alignment be part of geometry or action sequence?
2. Should geometry directly include circle planting and similar features?

]=]