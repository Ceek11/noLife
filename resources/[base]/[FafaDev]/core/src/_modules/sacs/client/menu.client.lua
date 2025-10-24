local open_bag_menu = false
local bag_menu = RageUI.CreateMenu("", "Gestion des sacs")
local currentBag = nil
bag_menu.Closed = function()
    open_bag_menu = false
end

function FUN_OPEN_BAG_MENU()
    open_bag_menu = not open_bag_menu
    RageUI.Visible(bag_menu, open_bag_menu)
    if open_bag_menu then
        CreateThread(function()
            while open_bag_menu do
                RageUI.IsVisible(bag_menu, function()
                    RageUI.Separator(" GESTION DES SACS ")
                    
                           RageUI.Button("Ouvrir le sac", "Accéder à l'inventaire du sac", {RightLabel = "→"}, currentBag ~= nil, {
                               onSelected = function()
                                   CORE.trigger_server_event('fafadev:to_server:open_bag_inventory')
                                   FUN_CLOSE_BAG_MENU()
                               end
                           })

                           RageUI.Button("Retirer le sac", "Enlever le sac de votre personnage", {RightLabel = "→"}, currentBag ~= nil, {
                               onSelected = function()
                                   CORE.trigger_server_event('fafadev:to_server:remove_bag')
                                   currentBag = nil
                                   FUN_CLOSE_BAG_MENU()
                               end
                           })

                           RageUI.Button("Poser le sac", "Déposer le sac au sol", {RightLabel = "→"}, currentBag ~= nil, {
                               onSelected = function()
                                   CORE.trigger_server_event('fafadev:to_server:drop_bag')
                                   currentBag = nil
                                   FUN_CLOSE_BAG_MENU()
                               end
                           })
                end)
                Wait(0)
            end
        end)
    end
end

function FUN_CLOSE_BAG_MENU()
    open_bag_menu = false
    RageUI.Visible(bag_menu, false)
end

RegisterCommand('bagmenu', function()
    if currentBag then
        FUN_OPEN_BAG_MENU()
    else
        ESX.ShowNotification('Vous n\'avez pas de sac équipé')
    end
end, false)
RegisterKeyMapping('bagmenu', 'Ouvrir le menu des sacs', 'keyboard', 'L')


RegisterNetEvent('fafadev:client:update_current_bag')
AddEventHandler('fafadev:client:update_current_bag', function(bag)
    currentBag = bag
end)
