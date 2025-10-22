local BlipsEntreprise = {}
local AllBlips = {}
local AllArea = {}

local function RemoveAllBlips()
    -- Suppression des anciens blips
    for _, ricon in pairs(AllBlips) do
        RemoveBlip(ricon)
    end
    for _, rarea in pairs(AllArea) do
        RemoveBlip(rarea)
    end
    for _, blip in pairs(BlipsEntreprise) do
        RemoveBlip(blip)
    end

    AllBlips = {}
    AllArea = {}
    BlipsEntreprise = {}
end

local function CreateBlipsFromData(blipsData)
    RemoveAllBlips()
    
    if not blipsData then return end
    
    local ClassicBlips = blipsData.ClassicBlips or {}
    local Blips = blipsData.Blips or {}

    -- Création des blips principaux
    for _, icon in pairs(ClassicBlips) do
        local playerJob = ESX.PlayerData.job and ESX.PlayerData.job.name
        local playerJob2 = ESX.PlayerData.job2 and ESX.PlayerData.job2.name
        if (icon.Job == "ALL" or playerJob == icon.Job) or 
           (icon.Job2 == "ALL" or playerJob2 == icon.Job2) then
            
            local blip = AddBlipForCoord(icon.X, icon.Y, icon.Z)
            SetBlipSprite(blip, icon.Id)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, icon.BSize)
            SetBlipColour(blip, icon.BColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(icon.Label)
            EndTextCommandSetBlipName(blip)

            table.insert(AllBlips, blip)
        end
    end

    -- Création des blips de zone
    for _, Area in pairs(ClassicBlips) do
        if Area.Area then
            local playerJob = ESX.PlayerData.job and ESX.PlayerData.job.name
            local playerJob2 = ESX.PlayerData.job2 and ESX.PlayerData.job2.name
            if (Area.Job == "ALL" or playerJob == Area.Job) or 
               (Area.Job2 == "ALL" or playerJob2 == Area.Job2) then
                
                local areaBlip = AddBlipForRadius(Area.X, Area.Y, Area.Z, Area.ASize)
                SetBlipColour(areaBlip, Area.AColor)
                SetBlipAlpha(areaBlip, 75)

                table.insert(AllArea, areaBlip)
            end
        end
    end

    -- Création des blips d'entreprise
    if Blips.Entreprise then
        for _, v in pairs(Blips.Entreprise) do
            local playerJob = ESX.PlayerData.job and ESX.PlayerData.job.name
            local playerJob2 = ESX.PlayerData.job2 and ESX.PlayerData.job2.name
            if v.job == playerJob or v.job == playerJob2 then
                local BlipEn = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
                SetBlipSprite(BlipEn, v.id)
                SetBlipDisplay(BlipEn, 4)
                SetBlipScale(BlipEn, 0.7)
                SetBlipCategory(BlipEn, 10)
                SetBlipColour(BlipEn, v.color)
                SetBlipAsShortRange(BlipEn, true)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.name)
                EndTextCommandSetBlipName(BlipEn)
                table.insert(BlipsEntreprise, BlipEn)
            end
        end
    end
end

function FUN_HANDLE_BLIPS(blipsData)
    CreateBlipsFromData(blipsData)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    Wait(1000) -- Attendre que ESX.PlayerData soit mis à jour
    CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blipsData)
        FUN_HANDLE_BLIPS(blipsData)
    end)
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    Wait(1000) -- Attendre que ESX.PlayerData soit mis à jour
    CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blipsData)
        FUN_HANDLE_BLIPS(blipsData)
    end)
end)

-- Callback pour rafraîchir les blips
CORE.register_client_callback("fafadev:to_client:refresh_blips", function(handler, blipsData)
    FUN_HANDLE_BLIPS(blipsData)
    handler(true)
end)