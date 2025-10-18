local LoadedBlips = {}
local LoadedAreas = {}

local function FUN_CHECK_BLIP_ACCESS(blipData, playerJob, playerGrade)
    if not blipData.jobs or #blipData.jobs == 0 then
        return true
    end
    
    local hasJob = false
    for _, job in pairs(blipData.jobs) do
        if playerJob == job then
            hasJob = true
            break
        end
    end
    
    if not hasJob then
        return false
    end
    
    if not blipData.grades or #blipData.grades == 0 then
        return true
    end
    
    for _, grade in pairs(blipData.grades) do
        if playerGrade >= grade then
            return true
        end
    end
    
    return false
end

local function CreateBlipFromData(blipData)
    local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
    SetBlipSprite(blip, blipData.sprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipData.scale or 0.8)
    SetBlipColour(blip, blipData.color or 1)
    SetBlipAsShortRange(blip, blipData.shortRange or true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.label or "Blip")
    EndTextCommandSetBlipName(blip)
    return blip
end

local function CreateAreaBlip(blipData)
    if not blipData.area or not blipData.area.enabled or not blipData.area.showBlip then
        return nil
    end
    local areaBlip = AddBlipForRadius(blipData.coords.x, blipData.coords.y, blipData.coords.z, blipData.area.radius)
    SetBlipColour(areaBlip, blipData.color or 1)
    SetBlipAlpha(areaBlip, blipData.area.color.a or 50)
    return areaBlip
end

local function RemoveAllBlips()
    for id, blipData in pairs(LoadedBlips) do
        if blipData.blip and DoesBlipExist(blipData.blip) then
            RemoveBlip(blipData.blip)
        end
        if blipData.areaBlip and DoesBlipExist(blipData.areaBlip) then
            RemoveBlip(blipData.areaBlip)
        end
    end
    LoadedBlips = {}
    LoadedAreas = {}
end

function FUN_HANDLE_BLIPS(tbl_blips)
    RemoveAllBlips()
    
    local xPlayer = ESX.GetPlayerData()
    local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
    local playerGrade = xPlayer and xPlayer.job and xPlayer.job.grade or 0
    
    for id, blipData in pairs(tbl_blips) do
        if FUN_CHECK_BLIP_ACCESS(blipData, playerJob, playerGrade) then
            local blip = CreateBlipFromData(blipData)
            local areaBlip = CreateAreaBlip(blipData)
            
            LoadedBlips[id] = {
                blip = blip,
                areaBlip = areaBlip,
                data = blipData
            }
            
            if blipData.area and blipData.area.enabled then
                LoadedAreas[id] = {
                    coords = vector3(blipData.coords.x, blipData.coords.y, blipData.coords.z),
                    radius = blipData.area.radius,
                    color = blipData.area.color
                }
            end
        end
    end
end

RegisterNetEvent('esx:setJob', function(job)
    if CORE.trigger_server_callback then
        CORE.trigger_server_callback("fafadev:to_server:get_blips", FUN_HANDLE_BLIPS)
    end
end)
