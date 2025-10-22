TBL_SUBMENUES_WORLD = {
    {label = "Gestion des Shops", description = "Gestion des shops du serveur", uid = "shops"},
    {label = "Gestion des Coffres", description = "Gestion des coffres du serveur", uid = "chests"},
    {label = "Gestion des Menus Boss", description = "Gestion des menus boss du serveur", uid = "boss"},
    {label = "Gestion des Vestiaires", description = "Gestion des vestiaires du serveur", uid = "cloakrooms"},
    {label = "Gestion des Locations", description = "Gestion des locations du serveur", uid = "locations"},
    {label = "Gestion des Garages", description = "Gestion des garages du serveur", uid = "garages"},
    {label = "Gestion des Blips", description = "Gestion des blips du serveur", uid = "blips"},
    {label = "Gestion des Peds", description = "Gestion des peds du serveur", uid = "peds"},
    {label = "Gestion des Pole Dance", description = "Gestion des pole dance du serveur", uid = "pole_dance"},
    {label = "Gestion des Concessionnaires", description = "Gestion des concessionnaires du serveur", uid = "concess"},
}
-- Création du menu builder principal
sub_menus_admin["server"].builder = RageUI.CreateSubMenu(sub_menus_admin["server"], "Gestion Builder", "Créer et gérer les éléments du serveur")

-- Création des sous-menus
for i = 1, #TBL_SUBMENUES_WORLD do
    local sub_menu = TBL_SUBMENUES_WORLD[i]
    sub_menus_admin[sub_menu.uid] = RageUI.CreateSubMenu(sub_menus_admin["server"].builder, sub_menu.label, sub_menu.description)
end


local TBL_SHOPS = {}
local TBL_CHESTS = {}
local TBL_BOSS = {}
local TBL_CLOAKROOMS = {}
local TBL_LOCATIONS = {}
local TBL_GARAGES = {}
local TBL_BLIPS = {}
local TBL_PEDS = {}
local TBL_POLE_DANCE = {}
local TBL_CONCESS_BUILDER = {}

function OpenMenuWorldAdmin()
    RageUI.IsVisible(sub_menus_admin["server"], function()
        RageUI.Button("Menu mapping", nil, {}, true, {})
        RageUI.Button("Gestion Builder", nil, {}, true, {}, sub_menus_admin["server"].builder)
        RageUI.Button("Gestion BDD", nil, {}, true, {})
    end)
    RageUI.IsVisible(sub_menus_admin["server"].builder, function()
        RageUI.Button("Gestion des Shops", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_shops", function(shops)
                    TBL_SHOPS = shops
                end)
            end
        }, sub_menus_admin["shops"])
        RageUI.Button("Gestion des Coffres", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_chests", function(chests)
                    TBL_CHESTS = chests
                end)
            end
        }, sub_menus_admin["chests"])
        RageUI.Button("Gestion des Menus Boss", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_boss", function(boss)
                    TBL_BOSS = boss
                end)
            end
        }, sub_menus_admin["boss"])
        RageUI.Button("Gestion des Vestiaires", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_cloakrooms", function(cloakrooms)
                    TBL_CLOAKROOMS = cloakrooms
                end)
            end
        }, sub_menus_admin["cloakrooms"])
        RageUI.Button("Gestion des Locations", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_locations", function(locations)
                    TBL_LOCATIONS = locations
                end)
            end
        }, sub_menus_admin["locations"])
        RageUI.Button("Gestion des Garages", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_garages", function(garages)
                    TBL_GARAGES = garages
                end)
            end
        }, sub_menus_admin["garages"])
        RageUI.Button("Gestion des Blips", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                    TBL_BLIPS = blips
                end)
            end
        }, sub_menus_admin["blips"])
        RageUI.Button("Gestion des Peds", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_peds", function(peds)
                    TBL_PEDS = peds
                end)
            end
        }, sub_menus_admin["peds"])
        RageUI.Button("Gestion des Pole Dance", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_pole_dance", function(pole_dance)
                    TBL_POLE_DANCE = pole_dance
                end)
            end
        }, sub_menus_admin["pole_dance"])
        RageUI.Button("Gestion des Concessionnaires", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                    TBL_CONCESS_BUILDER = concess
                end)
            end
        }, sub_menus_admin["concess"])
    end)
    
    -- Appel des builders
    blips_builder(TBL_BLIPS)
    shops_builder(TBL_SHOPS)
    chests_builder(TBL_CHESTS)
    boss_builder(TBL_BOSS)
    cloakrooms_builder(TBL_CLOAKROOMS)
    locations_builder(TBL_LOCATIONS)
    garages_builder(TBL_GARAGES)
    peds_builder(TBL_PEDS)
    pole_dance_builder(TBL_POLE_DANCE)
    concess_builder(TBL_CONCESS_BUILDER)
end