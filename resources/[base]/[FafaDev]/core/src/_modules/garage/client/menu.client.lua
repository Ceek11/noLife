
local playerConfig = playerConfig or {fourrierePrice = 500}

function getVehicleDisplayInfo(vehicle, garageName)
    local label = vehicle.label or GetDisplayNameFromVehicleModel(vehicle.vehicle.model)
    local rightLabel, canSpawn
    
    if vehicle.pound and (vehicle.pound == 1 or vehicle.pound == "1" or vehicle.pound == true) then
        label = ("~r~%s~s~ - ~p~%s"):format(label, vehicle.plate)
        rightLabel = "~r~Fourrière"
        canSpawn = false
    elseif vehicle.parking == garageName and (vehicle.stored == 1 or vehicle.stored == "1" or vehicle.stored == true) then
        label = ("~g~%s~s~ - ~p~%s"):format(label, vehicle.plate)
        rightLabel = "~g~Disponible"
        canSpawn = true
    elseif vehicle.parking == garageName and (vehicle.stored == 0 or vehicle.stored == "0" or vehicle.stored == false) then
        label = ("~y~%s~s~ - ~p~%s"):format(label, vehicle.plate)
        rightLabel = "~y~Sorti"
        canSpawn = false
    elseif vehicle.parking and vehicle.parking ~= garageName then
        label = ("~o~%s~s~ - ~p~%s"):format(label, vehicle.plate)
        rightLabel = ("~o~%s"):format(vehicle.parking)
        canSpawn = false
    else
        label = ("~o~%s~s~ - ~p~%s"):format(label, vehicle.plate)
        rightLabel = "~o~Non assigné"
        canSpawn = false
    end
    
    return {label = label, rightLabel = rightLabel, canSpawn = canSpawn}
end

local open_garage_menu = false
local garage_obj_menu = RageUI.CreateMenu("", "Garage")
local garage_obj_vehicles_personnel = RageUI.CreateSubMenu(garage_obj_menu, "Véhicules personnels", "Vos véhicules personnels")
local garage_obj_vehicle_details = RageUI.CreateSubMenu(garage_obj_vehicles_personnel, "Détails véhicule", "Actions sur le véhicule")
local garage_obj_vehicles_job = RageUI.CreateSubMenu(garage_obj_menu, "Véhicules d'entreprise", "Véhicules de l'entreprise")
local garage_obj_vehicle_job_details = RageUI.CreateSubMenu(garage_obj_vehicles_job, "Détails véhicule", "Actions sur le véhicule")

local open_fourriere_menu = false
local fourriere_obj_menu = RageUI.CreateMenu("", "Fourrière")
local fourriere_obj_vehicles_personnel = RageUI.CreateSubMenu(fourriere_obj_menu, "Véhicules personnels", "Vos véhicules en fourrière")
local fourriere_obj_vehicles_job = RageUI.CreateSubMenu(fourriere_obj_menu, "Véhicules d'entreprise", "Véhicules de l'entreprise en fourrière")

local current_garage_data = nil
local selected_vehicle = nil
vehiclesPersonnel = vehiclesPersonnel or {}
PersonnelFourriere = PersonnelFourriere or {}
vehiclesJob = vehiclesJob or {}
JobFourriere = JobFourriere or {}

garage_obj_menu.Closed = function()
    open_garage_menu = false
end

fourriere_obj_menu.Closed = function()
    open_fourriere_menu = false
end

function openGarageMenu(options)
    current_garage_data = options
    open_garage_menu = not open_garage_menu
    RageUI.Visible(garage_obj_menu, open_garage_menu)
    
    if open_garage_menu then
        getVehiclesPersonnel(options.typeGarage)
        
        local playerJob = ESX.GetPlayerData().job.name
        local hasJobAccess = false
        if options.jobAccess and #options.jobAccess > 0 then
            for _, job in pairs(options.jobAccess) do
                if job == playerJob then
                    hasJobAccess = true
                    break
                end
            end
            if hasJobAccess then
                getVehiclesJob(options.typeGarage, playerJob)
            end
        end
        
        CreateThread(function()
            while open_garage_menu do
                RageUI.IsVisible(garage_obj_menu, function()
                    RageUI.Separator(" GARAGE - " .. (options.garageLabel or "Garage") .. " ")
                    RageUI.Button("Véhicules personnels", "Gérer vos véhicules personnels", {RightLabel = "→"}, true, {}, garage_obj_vehicles_personnel)
                    
                    if hasJobAccess then
                        RageUI.Button("Véhicules d'entreprise", "Gérer les véhicules de l'entreprise", {RightLabel = "→"}, true, {}, garage_obj_vehicles_job)
                    end
                    
                    RageUI.Line()
                    
                    RageUI.Button("Rentrer le véhicule", "Ranger votre véhicule dans le garage", {}, true, {
                        onSelected = function()
                            deleteGarage(options.typeGarage, options.garageName, options.spawnVehPositions)
                        end
                    })
                end)
                
                RageUI.IsVisible(garage_obj_vehicles_personnel, function()
                    RageUI.Separator("VÉHICULES PERSONNELS")
                    if #vehiclesPersonnel > 0 then
                        for _, v in pairs(vehiclesPersonnel) do
                            local vehicleInfo = getVehicleDisplayInfo(v, current_garage_data.garageName)
                            RageUI.Button(vehicleInfo.label, nil, {RightLabel = vehicleInfo.rightLabel}, true, {
                                onSelected = function()
                                    selected_vehicle = v
                                    selected_vehicle.canSpawn = vehicleInfo.canSpawn
                                end
                            }, garage_obj_vehicle_details)
                        end
                    else
                        RageUI.Button("Aucun véhicule", nil, {}, false, {})
                    end
                end)
                
                RageUI.IsVisible(garage_obj_vehicle_details, function()
                    if not selected_vehicle then return end
                    
                    RageUI.Separator(" " .. (selected_vehicle.label or GetDisplayNameFromVehicleModel(selected_vehicle.vehicle.model)) .. " ")
                    RageUI.Line()
                    
                    local canSpawn = selected_vehicle.canSpawn or false
                    RageUI.Button("Sortir le véhicule", nil, {RightLabel = canSpawn and "~g~Disponible" or "~r~Indisponible"}, canSpawn, {
                        onSelected = function()
                            spawnVehicle(selected_vehicle.vehicle, selected_vehicle.plate, current_garage_data.spawnVehPositions)
                        end
                    })
                    
                    RageUI.Button("Renommer le véhicule", nil, {}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Renommer le véhicule", {
                                {type = "input", label = "Nom du véhicule", default = selected_vehicle.label or "", required = true}
                            })
                            if input and input[1] then
                                CORE.trigger_server_event("fCore:renameVehicle", selected_vehicle.plate, input[1])
                                selected_vehicle.label = input[1]
                            end
                        end
                    })
                    
                    local playerData = ESX.GetPlayerData()
                    local isBoss = (playerData.job and playerData.job.grade_name == "boss") or (playerData.job2 and playerData.job2.grade_name == "boss")
                    if hasJobAccess and isBoss then
                        RageUI.Button("Transférer à l'entreprise", nil, {RightLabel = "→"}, true, {
                            onSelected = function()
                                local playerData = ESX.GetPlayerData()
                                local options = {}
                                if playerData.job and playerData.job.name and playerData.job.name ~= "unemployed" then
                                    table.insert(options, {value = playerData.job.name, label = "Job principal: " .. playerData.job.label})
                                end
                                if playerData.job2 and playerData.job2.name and playerData.job2.name ~= "unemployed" then
                                    table.insert(options, {value = playerData.job2.name, label = "Job secondaire: " .. playerData.job2.label})
                                end
                                if #options == 0 then
                                    ESX.ShowNotification("~r~Vous n'avez aucun job")
                                    return
                                end
                                local input = lib.inputDialog("Transférer à l'entreprise", {
                                    {type = "select", label = "Choisir l'entreprise", options = options, required = true}
                                })
                                if input and input[1] then
                                    CORE.trigger_server_event("fCore:transferVehicleToJob", selected_vehicle.plate, input[1])
                                    Wait(500)
                                    getVehiclesPersonnel(current_garage_data.typeGarage)
                                    getVehiclesJob(current_garage_data.typeGarage, ESX.GetPlayerData().job.name)
                                end
                            end
                        })
                    end
                end)
                
                RageUI.IsVisible(garage_obj_vehicles_job, function()
                    RageUI.Separator("VÉHICULES D'ENTREPRISE")
                    if #vehiclesJob > 0 then
                        for _, v in pairs(vehiclesJob) do
                            local vehicleInfo = getVehicleDisplayInfo(v, current_garage_data.garageName)
                            RageUI.Button(vehicleInfo.label, nil, {RightLabel = vehicleInfo.rightLabel}, true, {
                                onSelected = function()
                                    selected_vehicle = v
                                    selected_vehicle.canSpawn = vehicleInfo.canSpawn
                                end
                            }, garage_obj_vehicle_job_details)
                        end
                    else
                        RageUI.Button("Aucun véhicule", nil, {}, false, {})
                    end
                end)
                
                RageUI.IsVisible(garage_obj_vehicle_job_details, function()
                    if not selected_vehicle then return end
                    
                    RageUI.Separator(" " .. (selected_vehicle.label or GetDisplayNameFromVehicleModel(selected_vehicle.vehicle.model)) .. " ")
                    RageUI.Line()
                    
                    local canSpawn = selected_vehicle.canSpawn or false
                    RageUI.Button("Sortir le véhicule", nil, {RightLabel = canSpawn and "~g~Disponible" or "~r~Indisponible"}, canSpawn, {
                        onSelected = function()
                            spawnVehicle(selected_vehicle.vehicle, selected_vehicle.plate, current_garage_data.spawnVehPositions)
                        end
                    })
                    
                    RageUI.Button("Renommer le véhicule", nil, {}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Renommer le véhicule", {
                                {type = "input", label = "Nom du véhicule", default = selected_vehicle.label or "", required = true}
                            })
                            if input and input[1] then
                                CORE.trigger_server_event("fCore:renameVehicle", selected_vehicle.plate, input[1])
                                selected_vehicle.label = input[1]
                            end
                        end
                    })
                    
                    local playerData = ESX.GetPlayerData()
                    local isBoss = (playerData.job and playerData.job.grade_name == "boss") or (playerData.job2 and playerData.job2.grade_name == "boss")
                    if isBoss then
                        RageUI.Button("Transférer en personnel", nil, {RightLabel = "→"}, true, {
                            onSelected = function()
                                CORE.trigger_server_event("fCore:transferVehicleToPersonal", selected_vehicle.plate)
                                Wait(500)
                                getVehiclesPersonnel(current_garage_data.typeGarage)
                                getVehiclesJob(current_garage_data.typeGarage, ESX.GetPlayerData().job.name)
                            end
                        })
                    end
                end)
                
                Wait(0)
            end
        end)
    end
end

function openFourriereMenu(options)
    current_garage_data = options
    open_fourriere_menu = not open_fourriere_menu
    RageUI.Visible(fourriere_obj_menu, open_fourriere_menu)
    
    local playerJob = ESX.GetPlayerData().job.name
    local hasJobAccess = false
    
    if open_fourriere_menu then
        getVehiclesFourriere(options.typeGarage)
        
        if options.jobAccess and #options.jobAccess > 0 then
            for _, job in pairs(options.jobAccess) do
                if job == playerJob then
                    hasJobAccess = true
                    break
                end
            end
            if hasJobAccess then
                getVehiclesJobFourriere(options.typeGarage, playerJob)
            end
        end
        
        CreateThread(function()
            while open_fourriere_menu do
                RageUI.IsVisible(fourriere_obj_menu, function()
                    RageUI.Separator(" FOURRIÈRE - " .. (options.garageLabel or "Fourrière") .. " ")
                    RageUI.Button("Véhicules personnels", #PersonnelFourriere > 0 and ("%d véhicule(s)"):format(#PersonnelFourriere) or "Aucun véhicule", {RightLabel = "→"}, true, {}, fourriere_obj_vehicles_personnel)
                    if hasJobAccess then
                        RageUI.Button("Véhicules d'entreprise", #JobFourriere > 0 and ("%d véhicule(s)"):format(#JobFourriere) or "Aucun véhicule", {RightLabel = "→"}, true, {}, fourriere_obj_vehicles_job)
                    end
                end)
                
                RageUI.IsVisible(fourriere_obj_vehicles_personnel, function()
                    RageUI.Separator("VÉHICULES PERSONNELS EN FOURRIÈRE")
                    if #PersonnelFourriere > 0 then
                        for _, v in pairs(PersonnelFourriere) do
                            local label = v.label or GetDisplayNameFromVehicleModel(v.vehicle.model)
                            RageUI.Button(("~r~%s - ~p~%s"):format(label, v.plate), nil, {RightLabel = "~g~Récupérer"}, true, {
                                onSelected = function()
                                    CORE.trigger_server_event("fCore:takeVehicleFromFourriere", v.plate, options.spawnVehPositions, v.vehicle, playerConfig.fourrierePrice)
                                    getVehiclesFourriere(options.typeGarage)
                                end
                            })
                        end
                    else
                        RageUI.Button("Aucun véhicule", nil, {}, false, {})
                    end
                end)
                
                RageUI.IsVisible(fourriere_obj_vehicles_job, function()
                    RageUI.Separator("VÉHICULES D'ENTREPRISE EN FOURRIÈRE")
                    if #JobFourriere > 0 then
                        for _, v in pairs(JobFourriere) do
                            local label = v.label or GetDisplayNameFromVehicleModel(v.vehicle.model)
                            RageUI.Button(("~r~%s - ~p~%s"):format(label, v.plate), nil, {RightLabel = "~g~Récupérer"}, true, {
                                onSelected = function()
                                    CORE.trigger_server_event("fCore:takeVehicleFromFourriere", v.plate, options.spawnVehPositions, v.vehicle, playerConfig.fourrierePrice)
                                    getVehiclesJobFourriere(options.typeGarage, playerJob)
                                end
                            })
                        end
                    else
                        RageUI.Button("Aucun véhicule", nil, {}, false, {})
                    end
                end)
                
                Wait(0)
            end
        end)
    end
end
