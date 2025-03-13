-- Note: this interface also adapts to the form of the dictionary table to increase the mod biological icon or specify the icon of a certain creature
-- prefab = icon_prefab
local prefabs = {
        "deer", "bearger", "beefalo", "bishop", "bishop_nightmare", "knight", "knight_nightmare", "koalefant_summer",
        "koalefant_winter", "leif", "leif_sparse", "lightninggoat", "mossling", "rocky", "rook", "rook_nightmare",
        "spat", "warg", "rock_moon_shell", "worm", "slurper", "sculpture_rooknose",
        "sculpture_knighthead", "sculpture_bishophead", "claywarg", "gingerbreadwarg", "mandrake_planted", "stagehand",
        "shadowthrall_hands", "shadowthrall_horns", "shadowthrall_wings", "mutatedwarg", "mutatedbearger",
        "mutateddeerclops", "mooseegg",
        cave_exit = "cave_open2",
        moose_nesting_ground = "mooseegg"
}

local prefabs_wormhole = {"tentacle_pillar_hole", "tentacle_pillar", "wormhole", "ndpr_wormhole",}

return {
        prefabs_data = prefabs,
        wormhole_data = prefabs_wormhole
}