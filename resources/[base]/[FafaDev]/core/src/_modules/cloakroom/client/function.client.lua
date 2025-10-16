function get_cloakroom_data(society_name)
    if not society_name then
        return
    end
    
    CORE.trigger_server_callback("templatejob:to_server:get_cloakroom_data", function(data)
        if data then
            TEMPLATE_DATA_CLOAKROOM = data
        else
            TEMPLATE_DATA_CLOAKROOM = {}
        end
    end, society_name)
end

function get_is_boss(job_name)
    if not ESX.PlayerData or not ESX.PlayerData.job then
        return false
    end
    return ESX.PlayerData.job.grade_name == "boss" and ESX.PlayerData.job.name == job_name
end

function template_has_permission_outfit(grade, job_name)
    if not ESX.PlayerData or not ESX.PlayerData.job then
        return false
    end
    
    if ESX.PlayerData.job.name ~= job_name then
        return false
    end
    
    local player_grade = ESX.PlayerData.job.grade
    local required_grade = tonumber(grade)
    
    if not player_grade or not required_grade then
        return false
    end
    
    return player_grade >= required_grade
end



function apply_outfit(outfit_data)
    if not outfit_data then
        ESX.ShowNotification("Données de tenue manquantes")
        return
    end
    
    local playerModel = GetEntityModel(PlayerPedId())
    local playerModelString = (playerModel == GetHashKey("mp_m_freemode_01") and "mp_m_freemode_01") or (playerModel == GetHashKey("mp_f_freemode_01") and "mp_f_freemode_01")
    
    if not playerModelString or outfit_data.model ~= playerModelString then
        ESX.ShowNotification("Tenue incompatible avec votre personnage")
        return
    end
    
    ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
        if not skin then
            ESX.ShowNotification("Impossible de récupérer votre apparence")
            return
        end
        
        apply_outfit_from_skin(skin, outfit_data)
    end)
end

function apply_outfit_from_skin(skin, outfit_data)
    local new_skin = {}
    
    for k, v in pairs(skin) do
        new_skin[k] = v
    end
    
    for k, v in pairs(outfit_data) do
        if k ~= "model" then
            new_skin[k] = v
        end
    end
    
    TriggerEvent("skinchanger:loadSkin", new_skin)
    ESX.ShowNotification("Tenue appliquée avec succès")
end

