RegisterCommand("revive", function()
    NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true, false)
end)