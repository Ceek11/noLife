local PLAYER_PERMISSIONS = {}

function init_player_permissions()
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.job and playerData.job.grade_name then
        get_permissions(playerData.job.grade_name)
    end
end

function has_permission(permission)
    return PLAYER_PERMISSIONS[permission] == true
end

function update_player_permissions(permissions)
    PLAYER_PERMISSIONS = permissions or {}
end