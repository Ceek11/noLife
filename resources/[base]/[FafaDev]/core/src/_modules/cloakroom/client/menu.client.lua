local open_template_menu_cloakroom = false
local template_obj_menu = RageUI.CreateMenu("", "Vestiaire")
local template_obj_gestion_tenues = RageUI.CreateSubMenu(template_obj_menu, "Gestion des tenues", "Gérer les tenues")
local template_obj_update_outfit = RageUI.CreateSubMenu(template_obj_gestion_tenues, "Modifier la tenue", "Modifier cette tenue")
local template_current_civil_skin = nil
local template_selected_outfit = nil
local current_cloakroom_data = nil
TEMPLATE_DATA_CLOAKROOM = {}

template_obj_menu.Closed = function()
    open_template_menu_cloakroom = false
end

function template_menu_cloakroom(cloakroomData)
    current_cloakroom_data = cloakroomData
    open_template_menu_cloakroom = not open_template_menu_cloakroom
    RageUI.Visible(template_obj_menu, open_template_menu_cloakroom)
    if open_template_menu_cloakroom then
        get_cloakroom_data(cloakroomData.job)
        CreateThread(function()
            while open_template_menu_cloakroom do
                RageUI.IsVisible(template_obj_menu, function()
                    RageUI.Separator(" VESTIAIRE ")
                    
                    if get_is_boss(current_cloakroom_data.job) then
                        RageUI.Button("Gérer les tenues", "Gérer les tenues de service", {}, true, {
                            onSelected = function() end
                        }, template_obj_gestion_tenues)
                        RageUI.Line()
                    end

                    RageUI.Button("Tenue civile", "Remettre sa tenue civile", {}, true, {
                        onSelected = function()
                            if template_current_civil_skin then
                                TriggerEvent("skinchanger:loadSkin", template_current_civil_skin)
                                ESX.ShowNotification("Tenue civile restaurée")
                            else
                                ESX.ShowNotification("Aucune tenue civile sauvegardée")
                            end
                        end
                    })
                    RageUI.Separator(" TENUES DISPONIBLES ")
                    
                    if #TEMPLATE_DATA_CLOAKROOM > 0 then 
                        local playerModel = GetEntityModel(PlayerPedId())
                        local playerModelString = (playerModel == GetHashKey("mp_m_freemode_01") and "mp_m_freemode_01") or (playerModel == GetHashKey("mp_f_freemode_01") and "mp_f_freemode_01")
                    
                        for uid, cloakroom in pairs(TEMPLATE_DATA_CLOAKROOM) do
                            if template_has_permission_outfit(cloakroom.info_outfit.grade, current_cloakroom_data.job) and cloakroom.outfit.model == playerModelString then
                                RageUI.Button(cloakroom.info_outfit.label, "Tenue: " .. cloakroom.info_outfit.label, {}, true, {
                                    onSelected = function()
                                        if not template_current_civil_skin then
                                            ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
                                                if skin then
                                                    template_current_civil_skin = skin
                                                    apply_outfit(cloakroom.outfit)
                                                end
                                            end)
                                        else
                                            apply_outfit(cloakroom.outfit)
                                        end
                                    end
                                })
                            end
                        end
                    end
                end)
                
                RageUI.IsVisible(template_obj_gestion_tenues, function()
                    RageUI.Separator(" GESTION DES TENUES ")
                    RageUI.Line()
                    RageUI.Button("Créer une tenue", "Créer une nouvelle tenue", {}, true, {
                        onSelected = function()
                            if not get_is_boss(current_cloakroom_data.job) then
                                ESX.ShowNotification("Vous n'avez pas les permissions nécessaires")
                                return
                            end
                            
                            local input = lib.inputDialog("Créer une tenue", {
                                {type = "input", label = "Nom de la tenue", description = "Nom de la tenue", required = true},
                                {type = "number", label = "Grade minimum", description = "Grade minimum requis", min = 0, max = 10, required = true}
                            })
                            
                            if input then
                                local outfit_info = {
                                    label = input[1],
                                    grade = input[2]
                                }
                                
                                ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
                                    if skin then
                                        CORE.trigger_server_event("templatejob:to_server:add_cloakroom", current_cloakroom_data.job, outfit_info, skin)
                                    else
                                        ESX.ShowNotification("Impossible de récupérer votre apparence")
                                    end
                                end)
                            end
                        end
                    })
                    RageUI.Line()

                    RageUI.Separator(" TENUES DISPONIBLES ")
                    if #TEMPLATE_DATA_CLOAKROOM > 0 then 
                        for uid, cloakroom in pairs(TEMPLATE_DATA_CLOAKROOM) do
                            RageUI.Button(cloakroom.info_outfit.label, "Tenue: " .. cloakroom.info_outfit.label, {}, true, {
                                onSelected = function()
                                    template_selected_outfit = cloakroom
                                end
                            }, template_obj_update_outfit)
                        end
                    else
                        RageUI.Separator("Aucune tenue disponible")
                    end
                end)

                RageUI.IsVisible(template_obj_update_outfit, function()
                    RageUI.Separator(" MODIFICATION: " .. template_selected_outfit.info_outfit.label .. " ")
                    RageUI.Line()
                    
                    RageUI.Button("Modifier le grade", "Grade actuel: " .. template_selected_outfit.info_outfit.grade, {}, true, {
                        onSelected = function()
                            if not get_is_boss(current_cloakroom_data.job) then
                                ESX.ShowNotification("Vous n'avez pas les permissions nécessaires")
                                return
                            end
                            
                            local input = lib.inputDialog("Modifier le grade", {
                                {type = "number", label = "Nouveau grade", description = "Grade minimum requis", min = 0, max = 10, default = tonumber(template_selected_outfit.info_outfit.grade), required = true}
                            })
                            
                            if input then
                                CORE.trigger_server_event("templatejob:to_server:update_outfit_info", template_selected_outfit.id, "grade", input[1])
                                template_selected_outfit.info_outfit.grade = input[1]
                            end
                        end
                    })
                    
                    RageUI.Button("Modifier le nom", "Nom actuel: " .. template_selected_outfit.info_outfit.label, {}, true, {
                        onSelected = function()
                            if not get_is_boss(current_cloakroom_data.job) then
                                ESX.ShowNotification("Vous n'avez pas les permissions nécessaires")
                                return
                            end
                            
                            local input = lib.inputDialog("Modifier le nom", {
                                {type = "input", label = "Nouveau nom", description = "Nouveau nom de la tenue", default = tostring(template_selected_outfit.info_outfit.label), required = true}
                            })
                            
                            if input then
                                CORE.trigger_server_event("templatejob:to_server:update_outfit_info", template_selected_outfit.id, "label", input[1])
                                template_selected_outfit.info_outfit.label = input[1]
                            end
                        end
                    })
                    
                    RageUI.Line()
                    
                    RageUI.Button("Modifier la tenue", "Modifier l'apparence de la tenue", {}, true, {
                        onSelected = function()
                            if not get_is_boss(current_cloakroom_data.job) then
                                ESX.ShowNotification("Vous n'avez pas les permissions nécessaires")
                                return
                            end
                            
                            ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
                                if skin then
                                    local outfit_data = {
                                        model = skin.model,
                                        tshirt_1 = skin.tshirt_1 or 0,
                                        tshirt_2 = skin.tshirt_2 or 0,
                                        torso_1 = skin.torso_1 or 0,
                                        torso_2 = skin.torso_2 or 0,
                                        pants_1 = skin.pants_1 or 0,
                                        pants_2 = skin.pants_2 or 0,
                                        shoes_1 = skin.shoes_1 or 0,
                                        shoes_2 = skin.shoes_2 or 0,
                                        mask_1 = skin.mask_1 or 0,
                                        mask_2 = skin.mask_2 or 0,
                                        helmet_1 = skin.helmet_1 or -1,
                                        helmet_2 = skin.helmet_2 or 0,
                                        glasses_1 = skin.glasses_1 or -1,
                                        glasses_2 = skin.glasses_2 or 0,
                                        bags_1 = skin.bags_1 or 0,
                                        bags_2 = skin.bags_2 or 0,
                                        chain_1 = skin.chain_1 or 0,
                                        chain_2 = skin.chain_2 or 0,
                                        bproof_1 = skin.bproof_1 or 0,
                                        bproof_2 = skin.bproof_2 or 0,
                                        arms = skin.arms or 0,
                                        arms_2 = skin.arms_2 or 0,
                                        decals_1 = skin.decals_1 or 0,
                                        decals_2 = skin.decals_2 or 0,
                                        watches_1 = skin.watches_1 or -1,
                                        watches_2 = skin.watches_2 or 0,
                                        bracelets_1 = skin.bracelets_1 or -1,
                                        bracelets_2 = skin.bracelets_2 or 0,
                                        ears_1 = skin.ears_1 or -1,
                                        ears_2 = skin.ears_2 or 0
                                    }
                                    
                                    CORE.trigger_server_event("templatejob:to_server:update_outfit_clothes", template_selected_outfit.id, outfit_data)
                                    template_selected_outfit.outfit = outfit_data
                                else
                                    ESX.ShowNotification("Impossible de récupérer votre apparence")
                                end
                            end)
                        end
                    })
                    
                    RageUI.Line()
                    
                    RageUI.Button("Supprimer la tenue", "Supprimer définitivement cette tenue", {}, true, {
                        onSelected = function()
                            if not get_is_boss(current_cloakroom_data.job) then
                                ESX.ShowNotification("Vous n'avez pas les permissions nécessaires")
                                return
                            end
                            
                            CORE.trigger_server_event("templatejob:to_server:remove_cloakroom", current_cloakroom_data.job, template_selected_outfit.id)
                            template_selected_outfit = nil
                        end
                    })
                end)
                Wait(0)
            end
        end)
    end
end

CORE.register_client_event("templatejob:to_client:cloakroom_updated", function(society_name, outfits)
    if current_cloakroom_data and current_cloakroom_data.job == society_name then
        CORE.trigger_server_callback("templatejob:to_server:get_cloakroom_data", function(data)
            if data then
                TEMPLATE_DATA_CLOAKROOM = data
            end
        end, society_name)
    end
end)