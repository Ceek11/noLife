CORE.fun_send_to_discord = function(source, category, color, title, message, player_name)
    if not CONFIG_LOGS.enabled then return end
    local str_webhook_url = CONFIG_LOGS.webhooks_urls[category]
    if not str_webhook_url then
        return
    end
    local str_full_message = ""
    local str_player_license = ""

    if category == "scripts_status" then
        str_full_message = message
    else
        str_player_license = GetPlayerIdentifierByType(tostring(source), 'license')
        str_full_message = ("%s\n`🪪`-Nom: %s\n`🆔`-ID: %s\n%s"):format(message, player_name or "inconnu", tostring(source), str_player_license)
    end
    local num_color = CONFIG_LOGS.colors[color] or tonumber(color)
    local tbl_embed = {
        {
            ["color"] = num_color,
            ["title"] = title,
            ["description"] = str_full_message,
            ["footer"] = {["text"] = os.date("%d/%m/%Y %H:%M:%S")}
        }
    }
    PerformHttpRequest(str_webhook_url, function(_, _, _) end, 'POST', json.encode({embeds = tbl_embed}), {['Content-Type'] = 'application/json'})
end

