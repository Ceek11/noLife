local tasks = {
    {name = "FUN_LOAD_CONCESS", func = function() 
        if FUN_LOAD_CONCESS then
            FUN_LOAD_CONCESS()
        end
    end},
    {name = "FUN_LOAD_GARAGES", func = function() 
        if FUN_LOAD_GARAGES then
            FUN_LOAD_GARAGES()
        end
    end},
    {name = "FUN_LOAD_POLE_DANCE", func = function() 
        if FUN_LOAD_POLE_DANCE then
            FUN_LOAD_POLE_DANCE()
        end
    end},
    {name = "FUN_LOAD_PEDS", func = function() 
        if FUN_LOAD_PEDS then
            FUN_LOAD_PEDS()
        end
    end},
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
    {name = "FUN_LOAD_LOCATIONS", func = function() 
        if FUN_LOAD_LOCATIONS then
            FUN_LOAD_LOCATIONS()
        end
    end},
    {name = "FUN_LOAD_BLIPS", func = function() 
        if FUN_LOAD_BLIPS then
            FUN_LOAD_BLIPS()
        end
    end},
}

CreateThread(function()
    for i = 1, #tasks do
        tasks[i].func()
    end
end)