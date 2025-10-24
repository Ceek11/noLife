local open_armurerie_menu = false
local armurerie_menu = RageUI.CreateMenu("Armurerie", "Armurerie")
local armurerie_obj_acheter_armes = RageUI.CreateSubMenu(armurerie_menu, "Acheter des armes", "Acheter des armes")
local armurerie_obj_deposer_armes = RageUI.CreateSubMenu(armurerie_menu, "Déposer des armes", "Déposer des armes")
local armurerie_weapons_db = {}
local player_weapons = {}
local current_armurerie_data = nil

armurerie_menu.Closed = function()
    open_armurerie_menu = false
    current_armurerie_data = nil
end

RegisterNetEvent('fafadev:to_client:refresh_armurerie')
AddEventHandler('fafadev:to_client:refresh_armurerie', function()
    if open_armurerie_menu and current_armurerie_data then
        CORE.trigger_server_callback("fafadev:to_server:get_armurerie_weapons", function(weapons)
            armurerie_weapons_db = weapons
        end, current_armurerie_data.job)
        
        CORE.trigger_server_callback("fafadev:to_server:getPlayerWeapons", function(weapons)
            player_weapons = weapons
        end)
    end
end)

function FUN_OPEN_ARMURERIE_MENU(armurerieData)
    open_armurerie_menu = not open_armurerie_menu
    current_armurerie_data = armurerieData
    RageUI.Visible(armurerie_menu, open_armurerie_menu)
    
    if open_armurerie_menu then
        CORE.trigger_server_callback("fafadev:to_server:get_armurerie_weapons", function(weapons)
            armurerie_weapons_db = weapons
        end, armurerieData.job)
        
        CORE.trigger_server_callback("fafadev:to_server:getPlayerWeapons", function(weapons)
            player_weapons = weapons
        end)
        
        CreateThread(function()
            while open_armurerie_menu do
                RageUI.IsVisible(armurerie_menu, function()
                    local xPlayer = ESX.GetPlayerData()
                    local isBoss = false
                    if xPlayer.job and xPlayer.job.name == armurerieData.job and xPlayer.job.grade_name == "boss" then
                        isBoss = true
                    elseif xPlayer.job2 and xPlayer.job2.name == armurerieData.job and xPlayer.job2.grade_name == "boss" then
                        isBoss = true
                    end
                    
                    RageUI.Button("Acheter des armes", nil, {RightLabel = "→"}, isBoss, {}, armurerie_obj_acheter_armes)
                    RageUI.Button("Déposer des armes", nil, {RightLabel = "→"}, true, {}, armurerie_obj_deposer_armes)
                    RageUI.Line()
                    
                    if #armurerie_weapons_db > 0 then
                        RageUI.Separator("~b~Stock disponible")
                        for _, weaponStock in pairs(armurerie_weapons_db) do
                            local weaponInfo = nil
                            for _, weapon in pairs(armurerieData.weapons) do
                                if weapon.name == weaponStock.weapon then
                                    weaponInfo = weapon
                                    break
                                end
                            end
                            
                            if weaponInfo then
                                local gradeText = weaponStock.grade > 0 and string.format(" (Grade %d+)", weaponStock.grade) or ""
                                
                                local hasAccess = true
                                if weaponStock.grade > 0 then
                                    local playerGrade = 0
                                    if xPlayer.job and xPlayer.job.name == armurerieData.job then
                                        playerGrade = xPlayer.job.grade
                                    elseif xPlayer.job2 and xPlayer.job2.name == armurerieData.job then
                                        playerGrade = xPlayer.job2.grade
                                    end
                                    hasAccess = playerGrade >= weaponStock.grade
                                end
                                
                                RageUI.Button(weaponInfo.label .. gradeText, string.format("Stock: %d", weaponStock.quantity), {RightLabel = "Récupérer"}, hasAccess, {
                                    onSelected = function()
                                        CORE.trigger_server_event("fafadev:to_server:takeWeapon", weaponStock.weapon, armurerieData.job, weaponStock.grade)
                                    end
                                })
                            end
                        end
                    else
                        RageUI.Separator("~r~Aucune arme en stock")
                        RageUI.Separator("Les armes achetées apparaîtront ici")
                    end
                end)
                
                RageUI.IsVisible(armurerie_obj_acheter_armes, function()
                    for _, weapon in pairs(armurerieData.weapons) do
                        RageUI.Button(weapon.label, string.format("Prix: %d$", weapon.price), {RightLabel = string.format("%d$", weapon.price)}, true, {
                            onSelected = function()
                               local input = lib.inputDialog("Acheter " .. weapon.label, {
                                   {type = "number", label = "Quantité", required = true, min = 1, max = 10},
                                   {type = "number", label = "Grade requis (0 = tous)", required = true, default = 0, min = 0, max = 10}
                               })
                               if input and input[1] and input[2] then
                                    CORE.trigger_server_event("fafadev:to_server:buyWeapon", weapon.name, input[1], weapon.price, armurerieData.job, input[2])
                               end
                            end
                        })
                    end
                end)
                
                RageUI.IsVisible(armurerie_obj_deposer_armes, function()
                    if #player_weapons > 0 then
                        RageUI.Separator("~b~Vos armes disponibles")
                        for _, weapon in pairs(player_weapons) do
                            RageUI.Button(weapon.label, string.format("Quantité: %d", weapon.count), {RightLabel = "Déposer"}, true, {
                                onSelected = function()
                                    CORE.trigger_server_event("fafadev:to_server:depositWeapon", weapon.name, 1, armurerieData.job, 0)
                                end
                            })
                        end
                    else
                        RageUI.Separator("~r~Aucune arme dans votre inventaire")
                        RageUI.Separator("Vous devez avoir des armes pour pouvoir les déposer")
                    end
                end)
                
                Wait(0)
            end
        end)
    end
end