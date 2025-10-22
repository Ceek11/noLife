local open_f5_menu = false
local f5_menu = RageUI.CreateMenu("F5", "Menu F5")
local portefeuille_menu = RageUI.CreateSubMenu(f5_menu, "Portefeuille", "Portefeuille")
local index_papiers = 1
f5_menu.Closed = function()
    open_f5_menu = false
end

function FUN_OPEN_F5_MENU()
    open_f5_menu = not open_f5_menu
    RageUI.Visible(f5_menu, open_f5_menu)
    if open_f5_menu then
        CreateThread(function()
            while open_f5_menu do
                RageUI.IsVisible(f5_menu, function()
                    RageUI.Button("Portefeuille", "Ouvrir le portefeuille", {}, true, {}, portefeuille_menu)
                end)
                RageUI.IsVisible(portefeuille_menu, function()
                    local blackMoney = 0
                    for _, account in pairs(ESX.PlayerData.accounts) do
                        if account.name == "black_money" then
                            blackMoney = account.money
                            break
                        end
                    end
                    RageUI.Separator(("Argent propre %s$"):format(ESX.PlayerData.money))
                    RageUI.Separator(("Argent sale %s$"):format(blackMoney))
                    RageUI.Separator(("Jobs %s | Grade %s"):format(ESX.PlayerData.job.label, ESX.PlayerData.job.grade_label))
                    RageUI.Separator(("Gang %s | Grade %s"):format(ESX.PlayerData.job2.label, ESX.PlayerData.job2.grade_label))
                    RageUI.List("Regarde papiers", {"Carte d'identité", "Permis de conduire", "Permis d'armes"}, index_papiers, nil, {}, true, {
                        onListChange = function(index)
                            index_papiers = index
                        end,
                        onSelected = function(index)
                            if index == 1 then
                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                            elseif index == 2 then
                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
                            elseif index == 3 then
                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
                            end
                        end
                    })
                    RageUI.List("Donner papiers", {"Carte d'identité", "Permis de conduire", "Permis d'armes"}, index_papiers, nil, {}, true, {
                        onListChange = function(index)
                            index_papiers = index
                        end,
                        onSelected = function(index)
                            local targetPlayer = CORE.get_nearby_player(false, true)
                            if targetPlayer then
                                if index == 1 then
                                    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(targetPlayer))
                                elseif index == 2 then
                                    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(targetPlayer), 'driver')
                                elseif index == 3 then
                                    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(targetPlayer), 'weapon')
                                end
                            end
                        end
                    })
                end)
                Wait(0)
            end
        end)
    end
end