CORE.register_client_event("fafadev:to_client:token", function(token)
    CLIENT.token = token
end)

AddEventHandler('playerSpawned', function()
    CORE.trigger_server_event("fafadev:to_server:player_joining")
end)

