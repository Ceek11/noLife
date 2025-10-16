RegisterNetEvent("esx:onPlayerDeath", function (data)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local str_log_message = ""
    if data.killedByPlayer then
        local xTarget = ESX.GetPlayerFromId(data.killerId)
        if xTarget then
            local str_target_name = xTarget and xTarget.getName() or tostring(target)
            local str_target_license = GetPlayerIdentifierByType(tostring(data.killerId), 'license') or "inconnue"
            str_log_message = ("Le joueur %s a tué %s\n`` - Cible: %s\n`` - ID: %s\n`` - %s"):format(str_target_name, xPlayer.getName(), str_target_name, data.killerId, str_target_license)
        end
    else
        str_log_message = ("Le joueur **%s** est mort"):format(xPlayer.getName())
    end
    CORE.fun_send_to_discord(source, "death", "red", "- Mort d'un joueur", str_log_message, xPlayer.getName())
end)
