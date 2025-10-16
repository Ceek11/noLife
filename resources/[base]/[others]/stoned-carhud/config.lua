Config = {}

Config.vehicle = {
	speedUnit = 'kmh', -- kmh or mph
	maxSpeed = 350, 
	seatbelt = {
		playBuckleSound 	= true,
		playUnbuckleSound 	= true,
		playUnsafeSound 	= true
	},

	keys = {
		seatbelt 	= 29,
		cruiser		= 137,
		signalLeft	= 174,
		signalRight	= 175,
		signalBoth	= 173,
	}
}

Config.BlackoutTime = 2000 

Config.Notification = function(title, message, time, types, svside, id)
    if svside then 
		TriggerClientEvent("esx:showNotification", source, message) -- ESX.
    else 
		TriggerEvent("esx:showNotification", message) -- ESX.
    end
end

Config.Locales = {
	['warn_seatbelt'] = { title= "Ceinture de sécurité", text = "Vous devez mettre votre ceinture de sécurité! (B key)", type = "info" },
}
