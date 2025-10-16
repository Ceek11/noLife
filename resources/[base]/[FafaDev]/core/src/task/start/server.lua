local tasks = {
    {name = "FUN_LOAD_SHOPS", func = function() 
        if FUN_LOAD_SHOPS then
            FUN_LOAD_SHOPS()
        end
    end},
    {name = "FUN_LOAD_CHESTS", func = function() 
        if FUN_LOAD_CHESTS then
            FUN_LOAD_CHESTS()
        end
    end},
    {name = "FUN_LOAD_BOSS_MENUS", func = function() 
        if FUN_LOAD_BOSS_MENUS then
            FUN_LOAD_BOSS_MENUS()
        end
    end},
    {name = "FUN_LOAD_CLOAKROOMS", func = function() 
        if FUN_LOAD_CLOAKROOMS then
            FUN_LOAD_CLOAKROOMS()
        end
    end},
    {name = "FUN_LOAD_GARAGES", func = function() 
        if FUN_LOAD_GARAGES then
            FUN_LOAD_GARAGES()
        end
    end},
}

CreateThread(function()
    for i = 1, #tasks do
        tasks[i].func()
    end
end)