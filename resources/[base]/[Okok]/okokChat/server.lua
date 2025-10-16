RegisterServerEvent('chat:init')

RegisterServerEvent('chat:addTemplate')

RegisterServerEvent('chat:addMessage')

RegisterServerEvent('chat:addSuggestion')

RegisterServerEvent('chat:removeSuggestion')

RegisterServerEvent('_chat:messageEntered')

RegisterServerEvent('chat:server:ClearChat')

RegisterServerEvent('__cfx_internal:commandFallback')



AddEventHandler('_chat:messageEntered', function(author, color, message)

	if not message or not author then

		return

	end



	TriggerEvent('chatMessage', source, author, message)



	if not WasEventCanceled() then

		TriggerClientEvent('chatMessage', -1, author, {255, 255, 255}, message)

	end

end)



AddEventHandler('__cfx_internal:commandFallback', function(command)

	local name = GetPlayerName(source)



	TriggerEvent('chatMessage', source, name, '/' .. command)



	if not WasEventCanceled() then

		TriggerClientEvent('chatMessage', -1, name, {255, 255, 255}, '/' .. command) 

	end



	CancelEvent()

end)



local function refreshCommands(player)

	if GetRegisteredCommands then

		local registeredCommands = GetRegisteredCommands()



		local suggestions = {}



		for _, command in ipairs(registeredCommands) do

			if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then

				table.insert(suggestions, {

					name = '/' .. command.name,

					help = ''

				})

			end

		end



		TriggerClientEvent('chat:addSuggestions', player, suggestions)

	end

end



AddEventHandler('onServerResourceStart', function(resName)

	Wait(500)



	for _, player in ipairs(GetPlayers()) do

		refreshCommands(player)

	end

end)



AddEventHandler("chatMessage", function(source, color, message)

	local src = source

	args = stringsplit(message, " ")

	CancelEvent()

	if string.find(args[1], "/") then

		local cmd = args[1]

		table.remove(args, 1)

	end

end)



commands = {}

commandSuggestions = {}



function starts_with(str, start)

	return str:sub(1, #start) == start

end



function stringsplit(inputstr, sep)

	if sep == nil then

		sep = "%s"

	end

	local t={} ; i=1

	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do

		t[i] = str

		i = i + 1

	end

	return t

end

RegisterCommand('hrp', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    local message = table.concat(args, " ")

    if message == nil or message == '' then
        TriggerClientEvent('esx:showNotification', source, "Vous devez entrer un message.")
        return
    end

    local playerName = xPlayer.getName()

    for _, playerId in ipairs(GetPlayers()) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)

        if #(playerCoords - targetCoords) <= 10.0 then
            local time = os.date("%H:%M")
            TriggerClientEvent('chat:addMessage', playerId, {
                template = '<div class="chat-message warning" style="background-color: rgba(255, 165, 0, 0.1); padding: 10px; border-radius: 5px;">'
                        .. '<i style="color: orange; font-size: 16px;">⚠️</i> '
                        .. '<b><span style="color: #ff0000;">{0}</span>&nbsp;'
                        .. '<span style="font-size: 14px; color: #e1e1e1;">{2}</span></b>'
                        .. '<div style="margin-top: 5px; font-weight: 300;">{1}</div></div>',
                args = { playerName, message, time }
            })
        end
    end
end, false)