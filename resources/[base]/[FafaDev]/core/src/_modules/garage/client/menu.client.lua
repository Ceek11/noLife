
local playerConfig = playerConfig or {fourrierePrice = 500}

-- Fonction helper pour obtenir les informations d'affichage d'un véhicule
function getVehicleDisplayInfo(vehicle, garageName)
    local model = vehicle.vehicle.model
    local vehicleName = GetDisplayNameFromVehicleModel(model)
    local label = vehicle.label or vehicleName
    local description = ""
    local rightLabel = ""
    
    if vehicle.parking == garageName then
        if vehicle.pound and vehicle.pound ~= "0" then
            label = ("~r~%s~s~ - ~p~%s"):format(label, vehicle.plate)
            description = "Le véhicule est en fourrière"
            rightLabel = "~r~Fourrière"
        elseif vehicle.stored == 1 then
            label = ("~g~%s~s~ - ~p~%s"):format(label, vehicle.plate)
            description = "Le véhicule est dans le garage"
            rightLabel = "~g~Disponible"
        else
            label = ("~y~%s~s~ - ~p~%s"):format(label, vehicle.plate)
            description = "Le véhicule est sorti"
            rightLabel = "~y~Sorti"
        end
    else 
        label = ("~y~%s~s~ - ~p~%s"):format(label, vehicle.plate)
        description = ("Le véhicule est dans le garage : %s"):format(vehicle.parking)
        rightLabel = "~y~Autre garage"
    end
    
    return {
        label = label,
        description = description,
        rightLabel = rightLabel
    }
end

local open_garage_menu = false
local garage_obj_menu = RageUI.CreateMenu("", "Garage")
local garage_obj_vehicles_personnel = RageUI.CreateSubMenu(garage_obj_menu, "Véhicules personnels", "Vos véhicules personnels")
local garage_obj_vehicle_details = RageUI.CreateSubMenu(garage_obj_vehicles_personnel, "Détails véhicule", "Actions sur le véhicule")

local open_fourriere_menu = false
local fourriere_obj_menu = RageUI.CreateMenu("", "Fourrière")
local fourriere_obj_vehicles_personnel = RageUI.CreateSubMenu(fourriere_obj_menu, "Véhicules personnels", "Vos véhicules en fourrière")

-- Variables globales
local current_garage_data = nil
local selected_vehicle = nil
local vehiclesPersonnel = {}
local PersonnelFourriere = {}

-- Fermeture des menus
garage_obj_menu.Closed = function()
    open_garage_menu = false
end

fourriere_obj_menu.Closed = function()
    open_fourriere_menu = false
end

-- Fonction pour ouvrir le menu garage
function openGarageMenu(options)
    current_garage_data = options
    open_garage_menu = not open_garage_menu
    RageUI.Visible(garage_obj_menu, open_garage_menu)
    
    if open_garage_menu then
        CreateThread(function()
            while open_garage_menu do
                RageUI.IsVisible(garage_obj_menu, function()
                    RageUI.Separator(" GARAGE - " .. (options.garageLabel or "Garage") .. " ")
                        RageUI.Button("Véhicules personnels", "Gérer vos véhicules personnels", {}, true, {
                        onSelected = function()
                            getVehiclesPersonnel(options.typeGarage, function()
                            end)
                        end
                    }, garage_obj_vehicles_personnel, nil)
                    
                    RageUI.Line()
                    
                    RageUI.Button("Rentrer le véhicule", "Ranger votre véhicule dans le garage", {}, true, {
                        onSelected = function()
                            deleteGarage(options.typeGarage, options.garageName, options.spawnVehPositions)
                        end
                    }, nil)
                end)
                
                RageUI.IsVisible(garage_obj_vehicles_personnel, function()
                    RageUI.Separator("VÉHICULES PERSONNELS")
                    
                    if #vehiclesPersonnel > 0 then
                        for _, v in pairs(vehiclesPersonnel) do
                            local vehicleInfo = getVehicleDisplayInfo(v, current_garage_data.garageName)
                            
                            RageUI.Button(vehicleInfo.label, vehicleInfo.description, {RightLabel = vehicleInfo.rightLabel}, true, {
                                onSelected = function()
                                    selected_vehicle = v
                                end
                            }, garage_obj_vehicle_details, nil)
                        end
                    else
                        RageUI.Button("Aucun véhicule", "Vous n'avez pas de véhicule dans ce garage", {}, true, {
                            onSelected = function() end
                        }, nil)
                    end
                end)
                
                
                RageUI.IsVisible(garage_obj_vehicle_details, function() 
                    RageUI.Separator(" " .. (selected_vehicle.label or GetDisplayNameFromVehicleModel(selected_vehicle.vehicle.model)) .. " ")
                    RageUI.Line()
                    
                    local canSpawn = selected_vehicle.parking == current_garage_data.garageName and selected_vehicle.stored == 1
                    
                    RageUI.Button("Sortir le véhicule", "Sortir ce véhicule du garage", {RightLabel = canSpawn and "~g~Disponible" or "~r~Indisponible"}, canSpawn, {
                        onSelected = function()
                            if canSpawn then
                                spawnVehicle(selected_vehicle.vehicle, selected_vehicle.plate, current_garage_data.spawnVehPositions, "garage", current_garage_data.previousPosition)
                                RageUI.CloseAll()
                            end
                        end
                    }, nil)
                    
                    RageUI.Button("Renommer le véhicule", "Changer le nom de ce véhicule", {}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Renommer le véhicule", {
                                {type = "input", label = "Nom du véhicule", default = selected_vehicle.label or "", required = true}
                            })
                            if input and input[1] then
                                CORE.trigger_server_event("fCore:renameVehicle", selected_vehicle.plate, input[1])
                                selected_vehicle.label = input[1]
                            end
                        end
                    }, nil)
                    
                end)
                
                Wait(0)
            end
        end)
    end
end

-- Fonction pour ouvrir le menu fourrière
function openFourriereMenu(options)
    current_garage_data = options
    open_fourriere_menu = not open_fourriere_menu
    RageUI.Visible(fourriere_obj_menu, open_fourriere_menu)
    
    if open_fourriere_menu then
        getVehiclesFourriere(options.typeGarage, function()
            -- Les données sont chargées dans les variables globales
        end)
        
        CreateThread(function()
            while open_fourriere_menu do
                RageUI.IsVisible(fourriere_obj_menu, function()
                    RageUI.Separator(" FOURRIÈRE - " .. (options.garageLabel or "Fourrière") .. " ")
                    
                    if #PersonnelFourriere > 0 then
                        RageUI.Button("Véhicules personnels", ("%d véhicule(s) personnel(s)"):format(#PersonnelFourriere), {RightLabel = "→"}, true, {
                            onSelected = function() end
                        }, fourriere_obj_vehicles_personnel, nil)
                    else
                        RageUI.Button("Aucun véhicule", "Vous n'avez pas de véhicule en fourrière", {}, true, {
                            onSelected = function() end
                        }, nil)
                    end
                end)
                
                -- Menu véhicules personnels en fourrière
                RageUI.IsVisible(fourriere_obj_vehicles_personnel, function()
                    RageUI.Separator(" VÉHICULES PERSONNELS EN FOURRIÈRE ")
                    
                    if #PersonnelFourriere > 0 then
                        for _, v in pairs(PersonnelFourriere) do
                            local model = v.vehicle.model
                            local vehicleName = GetDisplayNameFromVehicleModel(model)
                            local label = v.label or vehicleName
                            
                            RageUI.Button(("~r~%s~s~ - ~p~%s"):format(label, v.plate), "Récupérer ce véhicule de la fourrière", {RightLabel = "~g~Récupérer"}, true, {
                                onSelected = function()
                                    CORE.trigger_server_event("fCore:takeVehicleFromFourriere", v.plate, options.spawnVehPositions, v.vehicle, playerConfig.fourrierePrice, options.previousPosition)
                                    -- Recharger les données
                                    getVehiclesFourriere(options.typeGarage, function() end)
                                end
                            }, nil)
                        end
                    else
                        RageUI.Button("Aucun véhicule", "Aucun véhicule personnel en fourrière", {}, true, {
                            onSelected = function() end
                        }, nil)
                    end
                end)
                
                
                Wait(0)
            end
        end)
    end
end
