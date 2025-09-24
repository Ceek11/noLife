function send_discord_message(source, category, color, title, message, player_name)
    if not CONFIG_DISCORD.enabled then return end
    local str_webhook_url = CONFIG_DISCORD.webhook_url[category]
    if not str_webhook_url then
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local str_player_license = GetPlayerIdentifierByType(tostring(source), 'license') or "Inconnu"
    local str_player_discord = "Inconnu"
    local str_player_ip = "Inconnu"
    local str_player_coords = "Inconnu"
    
    -- Récupérer l'identifiant Discord
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and string.sub(identifier, 1, string.len("discord:")) == "discord:" then
            str_player_discord = "<@" .. string.sub(identifier, 9) .. ">"
            break
        end
    end
    
    -- Récupérer l'IP
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and string.sub(identifier, 1, string.len("ip:")) == "ip:" then
            str_player_ip = "`" .. string.sub(identifier, 4) .. "`"
            break
        end
    end
    
    -- Récupérer les coordonnées du joueur
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if playerCoords then
        str_player_coords = string.format("`X=%.10f, Y=%.10f, Z=%.10f`", playerCoords.x, playerCoords.y, playerCoords.z)
    end
    
    local num_color = CONFIG_DISCORD.color[color] or tonumber(color)
    
    local embed_description = ""
    if category == "scripts_status" then
        embed_description = message
    else
        -- Format détaillé avec toutes les informations
        embed_description = message .. "\n\n"
        embed_description = embed_description .. "**Informations du joueur source :**\n"
        embed_description = embed_description .. "Nom : " .. (player_name or xPlayer.getName()) .. "\n"
        embed_description = embed_description .. "Job (Entreprise) : " .. (xPlayer.getJob().label or "Inconnu") .. "\n"
        embed_description = embed_description .. "License : `" .. str_player_license .. "`\n"
        embed_description = embed_description .. "Discord : " .. str_player_discord .. "\n"
        embed_description = embed_description .. "IP : " .. str_player_ip .. "\n"
        embed_description = embed_description .. "Role (Rang) : `" .. (xPlayer.getGroup() or "user") .. "`\n"
        embed_description = embed_description .. "Coordonnées : " .. str_player_coords .. "\n"
        embed_description = embed_description .. "Session ID : `" .. source .. "`\n"
        embed_description = embed_description .. "Date & Heure : `" .. os.date("%Y-%m-%d %H:%M:%S") .. "`"
    end
    
    local tbl_embed = {
        {
            ["color"] = num_color,
            ["title"] = title,
            ["description"] = embed_description,
            ["footer"] = {["text"] = os.date("%d/%m/%Y %H:%M:%S")}
        }
    }

    PerformHttpRequest(str_webhook_url, function(err, text, headers) end, 'POST', json.encode({embeds = tbl_embed}), {['Content-Type'] = 'application/json'})
end
