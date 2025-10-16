
-- Fonction pour afficher le texte 3D
function DrawText3D(coordsX, coordsY, coordsZ, text)
	local scale = scale or 0.35
    local onScreen, _x, _y = World3dToScreen2d(coordsX, coordsY, coordsZ)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(2)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 41, 41, 125)
end