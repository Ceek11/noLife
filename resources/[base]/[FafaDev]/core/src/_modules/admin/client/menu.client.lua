local tbl_sub_menus = {
    {label = "Liste des signalements", description = "Liste des signalements", RightLabel = ("~r~x%s"):format(GlobalState.reports or 0), uid = "reports"},
    {label = "Liste des joueurs", description = "Liste des joueurs", RightLabel = ("~r~x%s"):format(GlobalState.players or 0), uid = "players"},
    {label = "Gestion personnel", description = "Gestion personnel", RightLabel = nil, uid = "self"},
    {label = "Gestion Vehicule", description = "Gestion Vehicule", RightLabel = nil, uid = "vehicles"},
    {label = "Gestion Serveur", description = "Gestion Serveur", RightLabel = nil, uid = "server"},
    {label = "Gestion Ranks", description = "Gestion Ranks", RightLabel = nil, uid = "ranks"},
}

sub_menus_admin = {}
local open_menu_admin = false
local menu_admin = RageUI.CreateMenu("Admin", "Menu Admin")
for i = 1, #tbl_sub_menus do
    sub_menus_admin[tbl_sub_menus[i].uid] = RageUI.CreateSubMenu(menu_admin, tbl_sub_menus[i].label, tbl_sub_menus[i].description)
end
menu_admin.Closed = function()
    open_menu_admin = false
end

GlobalState.staff_mode = false

function OpenMenuAdmin()
    open_menu_admin = not open_menu_admin
    RageUI.Visible(menu_admin, open_menu_admin)
    if open_menu_admin then
        CreateThread(function()
            while open_menu_admin do
                RageUI.IsVisible(menu_admin, function()
                    RageUI.Checkbox("Mode staff", nil, GlobalState.staff_mode, {}, {
                        onChecked = function()
                            GlobalState.staff_mode = true
                        end,
                        onUnChecked = function()
                            GlobalState.staff_mode = false
                        end
                    })
                    if GlobalState.staff_mode then
                        for i = 1, #tbl_sub_menus do
                            local sub_menu = tbl_sub_menus[i]
                            RageUI.Button(sub_menu.label, sub_menu.description, { RightLabel = sub_menu.RightLabel or "→→→" }, true, {
                                onSelected = function()

                                end
                            }, sub_menus_admin[sub_menu.uid])
                        end
                    end
                end)
                OpenMenuSelfAdmin()
                OpenMenuPlayersAdmin()
                OpenMenuVehiclesAdmin()
                OpenMenuWorldAdmin()
                OpenMenuRanksAdmin()
                OpenMenuReportsAdmin()
                Wait(0)
            end
        end)
    end
end