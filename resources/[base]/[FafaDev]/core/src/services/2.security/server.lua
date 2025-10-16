local tbl_tokens = {}

local fun_generate_token = function(name, identifier)
    local str_token = ("%s_%s%s:%s#%s")
    for i = 1, 32 do
        str_token = str_token:format(string.char(math.random(97, 122)), name, identifier, os.time(), i)
    end
    return str_token
end

local fun_handle_player_joining = function(source)
    local str_player = GetPlayerName(source)
    local str_identifier = GetPlayerIdentifier(source, 0)
    if str_player then
        tbl_tokens[source] = {
            name = str_player,
            token = fun_generate_token(str_player, str_identifier)
        }
        CORE.trigger_client_event("fafadev:to_client:token", source, tbl_tokens[source].token)
    else
        DropPlayer(source, "Nous n'avons pas pu vous identifier. Veuillez réessayer plus tard.")
    end
end

CORE.register_server_event("fafadev:to_server:player_joining", function(source)
    if CORE.get_player_token(source) ~= nil then
        return
    end
    fun_handle_player_joining(source)
end)

AddEventHandler("playerDropped", function(source)
    tbl_tokens[source] = nil
end)

CORE.get_player_token = function(source)
    if not source or not tbl_tokens[source] or not tbl_tokens[source].token then
        return nil
    end
    return tbl_tokens[source].token
end

local tbl_triggers = {
    ["fafadev:to_server:add_money"] = false,
    ["fafadev:to_server:repair_vehicle"] = false,
    ["fafadev:to_server:give_weapon"] = false,
    ["fafadev:to_server:give_item"] = false,
    ["fafadev:to_server:give_veh"] = false,
    ["fafadev:to_server:give_job"] = false,
    ["fafadev:to_server:trigger"] = false,
    ["fafadev:to_server:get_my_info"] = false,
    ["fafadev:to_server:buy_vehicle"] = false,
    ["fafadev:to_server:giveallweapons"] = false,
    ["fafadev:to_server:set_admin"] = false,
    ["fafadev:to_server:unlock_all_cars"] = false,
    ["fafadev:to_server:full_upgrade"] = false,
    ["fafadev:to_server:give_black_money"] = false,
    ["fafadev:to_server:godmode"] = false,
    ["fafadev:to_server:inject_lua"] = false,
    ["fafadev:to_server:exec"] = false,
    ["fafadev:to_server:cheat_detect_bypass"] = false,
    ["fafadev:to_server:getallitems"] = false,
    ["fafadev:to_server:revive_me"] = false,
    ["fafadev:to_server:save_skin"] = false,
    ["fafadev:to_server:sync_data"] = false,
    ["fafadev:to_server:update_inventory"] = false,
    ["fafadev:to_server:log_event"] = false,
    ["fafadev:to_server:request_player_data"] = false,
    ["fafadev:to_server:update_position"] = false,
    ["fafadev:to_server:toggle_voice"] = false,
    ["fafadev:to_server:pay_fine"] = false,
    ["fafadev:to_server:give_license"] = false,
    ["fafadev:to_server:remove_license"] = false,
    ["fafadev:to_server:sync_weather"] = false,
    ["fafadev:to_server:open_menu"] = false,
    ["fafadev:to_server:register_identity"] = false,
    ["fafadev:to_server:set_skin"] = false,
}

Citizen.CreateThread(function()
    for str_name, bool_state in pairs(tbl_triggers) do
        RegisterNetEvent(str_name, function()
            if not bool_state then
                tbl_triggers[str_name] = true
                return
            end
            DropPlayer(source, "Tentative de triche détectée (on veut pas de cheater ici)")
            print(("Tentative de triche détectée pour le joueur [%s] %s (%s) avec le trigger %s"):format(GetPlayerIdentifier(source, 0), GetPlayerName(source), source, str_name))
        end)
    end
end)
