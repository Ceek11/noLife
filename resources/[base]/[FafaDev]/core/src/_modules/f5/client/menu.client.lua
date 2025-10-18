local open_f5_menu = false
local f5_menu = RageUI.CreateMenu("F5", "Menu F5")
local portefeuille_menu = RageUI.CreateSubMenu(f5_menu, "Portefeuille", "Portefeuille")
local options_menu = RageUI.CreateSubMenu(f5_menu, "Options", "Options")
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
                    RageUI.Button("options", "Ouvrir les options", {}, true, {}, options_menu)
                end)
                RageUI.IsVisible(portefeuille_menu, function()
                    print(json.encode(ESX.PlayerData))
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
                    RageUI.List("Papiers", {"Permis de conduire", "Permis de chasse"}, index_papiers, nil, {}, true, {
                        onListChange = function(index)
                            index_papiers = index
                        end,
                        onSelected = function(index)
                            
                        end
                    })
                end)
                Wait(0)
            end
        end)
    end
end
                   