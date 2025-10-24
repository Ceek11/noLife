local callbacks = { 
    { "fafadev:to_server:get_armurerie", FUN_HANDLE_ARMURERIE },
    { "fafadev:to_server:get_concess", FUN_HANDLE_CONCESS },
    { "fafadev:to_server:get_pole_dance", FUN_HANDLE_POLE_DANCE },
    { "fafadev:to_server:get_garages", FUN_HANDLE_GARAGES },
    { "fafadev:to_server:get_peds", FUN_HANDLE_PEDS },
    { "fafadev:to_server:get_shops", FUN_HANDLE_SHOPS },
    { "fafadev:to_server:get_chests", FUN_HANDLE_CHESTS },
    { "fafadev:to_server:get_boss", FUN_HANDLE_BOSS_MENUS },
    { "fafadev:to_server:get_cloakrooms", FUN_HANDLE_CLOAKROOMS },
    { "fafadev:to_server:get_locations", FUN_HANDLE_LOCATIONS },
    { "fafadev:to_server:get_blips", FUN_HANDLE_BLIPS },
}

CreateThread(function() 
    -- Attendre que le serveur soit complètement prêt
    Wait(3000)
    
    for i, v in ipairs(callbacks) do
        if CORE.trigger_server_callback then
            CORE.trigger_server_callback(v[1], v[2])
        end
        Wait(1000) -- Délai plus long entre chaque callback
    end
end)