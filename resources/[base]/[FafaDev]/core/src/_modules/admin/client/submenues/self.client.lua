function OpenMenuSelfAdmin()
    RageUI.IsVisible(sub_menus_admin["self"], function()
        RageUI.Checkbox("Noclip", nil, GetNoclipState(), {}, {
            onChecked = function()
                SetNoclipState(true)
            end,
            onUnChecked = function()
                SetNoclipState(false)
            end
        })
        RageUI.Checkbox("[DEV] GameTags", nil, false, {}, {
            onChecked = function()
                GlobalState.game_tags = true
            end,
            onUnChecked = function()
                GlobalState.game_tags = false
            end
        })
        RageUI.Button("[DEV] Afficher Blips ", nil, {}, true, {})
        RageUI.Button("[DEV] Give Vehicle", nil, {}, true, {})
        RageUI.Button("[DEV] Give Job", nil, {}, true, {})
        RageUI.Button("[DEV] GameMode", nil, {}, true, {})
        RageUI.Button("[DEV] Menu Peds", nil, {}, true, {})
        RageUI.List("Action Freeze", {"Freeze", "Unfreeze"}, listFreeze, nil, {}, true, {})
        RageUI.List("Action License", {"Give License", "Remove License"}, listLicense, nil, {}, true, {})
        RageUI.List("Action Item", {"Give Item", "Remove Item"}, listItem, nil, {}, true, {})
        RageUI.List("Action Weapon", {"Give Weapon", "Remove Weapon"}, listWeapon, nil, {}, true, {})
        RageUI.List("Action soins", {"Heal", "Revive"}, listSoins, nil, {}, true, {})
        RageUI.List("Action TP", {"TP sur marker", "TP sur joueur", "TP un joueur"}, listTP, nil, {}, true, {})
        RageUI.List("Action Money", {"Money", "Black Money", "Bank Money"}, listMoney, nil, {}, true, {})
    end)
end