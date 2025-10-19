RegisterCommand("revive", function()
    NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true, false)
end)


RegisterCommand("pos", function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local playerHeading = GetEntityHeading(PlayerPedId())
    print(("Coords - Vector3: ^5%s^0"):format(vector3(playerCoords.x, playerCoords.y, playerCoords.z)))
    print(("Coords - Vector4: ^5%s^0"):format(vector4(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading)))
end)

