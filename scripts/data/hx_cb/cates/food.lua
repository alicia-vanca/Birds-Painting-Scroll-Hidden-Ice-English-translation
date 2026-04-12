local g_util = require "util/fn_gallery"


local data = {
    default = "ingredients",
    cates = {{
        id = "all",
        icon = "filter_none",
        name = STRINGS.UI.COOKBOOK.FILTER_ALL,
        prefabs = g_util.food_all,
        
    },{
        id = "ingredients",
        icon = "quagmire_turnip",
        name = "Ingredients (Cookable)",
        prefabs = g_util.food_ingredients,
    },{
        id = "recipe",
        icon = "cookpot",
        name = "Recipes (Standard Pot)",
        prefabs = g_util.food_recipe,
    },{
        id = "recipe_else",
        icon = "portablecookpot_item",
        name = "Recipes (Special Pot)",
        prefabs = g_util.food_recipe_else,
    },{
        id = "recipe_spice",
        icon = "portablespicer_item",
        name = "Recipes (Seasoned)",
        prefabs = g_util.food_recipe_spice,
    },{
        id = "ingredients_veggie",
        icon = "carrot",
        name = "Ingredients (Veggie)",
        prefabs = g_util.food_ingredients_veggie,
    },{
        id = "ingredients_meat",
        icon = "meat",
        name = "Ingredients (Meat)",
        prefabs = g_util.food_ingredients_meat,
    },{
        id = "ingredients_else",
        icon = "twigs",
        name = "Ingredients (Other)",
        prefabs = g_util.food_ingredients_else,
    },{
        id = "feast",
        icon = "berrysauce",
        name = "Festive"..g_util.str_seemore,
        prefabs = g_util.food_feast,
        fn_rr = g_util.SeeMore("Festive", "Foods related to Winter's Feast and Halloween. Note for new players: some dishes can only be enjoyed at a table.")
    },{
        id = "caneat",
        icon = "glommerfuel",
        name = "Special Foods"..g_util.str_seemore,
        prefabs = g_util.food_caneat,
        fn_rr = g_util.SeeMore("Special Foods", "This category excludes mod foods and festive dishes. These items can be eaten, but not cooked in a pot.")
    },}, 
}

return data