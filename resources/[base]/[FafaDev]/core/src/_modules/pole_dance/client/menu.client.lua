-- Variables pour le menu
local open_pole_dance_menu = false
local pole_dance_obj_menu = RageUI.CreateMenu("Pole Dance", "Sélectionnez une animation")
local current_pole_dance_data = nil

-- Fermeture du menu
pole_dance_obj_menu.Closed = function()
    open_pole_dance_menu = false
end

-- Fonction pour ouvrir le menu pole dance
function openPoleDanceMenu(data)
    current_pole_dance_data = data
    open_pole_dance_menu = not open_pole_dance_menu
    RageUI.Visible(pole_dance_obj_menu, open_pole_dance_menu)
    
    if open_pole_dance_menu then
        CreateThread(function()
            while open_pole_dance_menu do
                RageUI.IsVisible(pole_dance_obj_menu, function()
                    RageUI.Separator(" POLE DANCE - " .. (data.label or "Pole Dance") .. " ")
                    RageUI.Line()
                    
                    if data.animations and #data.animations > 0 then
                        for i = 1, #data.animations do
                            local anim_data = find_animation_by_id(data.animations[i])
                            if anim_data and not bool_in_dance then
                                RageUI.Button("Danser " .. anim_data.label, anim_data.description, {}, true, {
                                    onSelected = function()
                                        start_poledance(anim_data.id)
                                        RageUI.CloseAll()
                                    end
                                }, nil)
                            end
                        end
                        
                        if bool_in_dance then
                            RageUI.Button("~r~Arrêter la danse", "Arrêter la danse en cours", {}, true, {
                                onSelected = function()
                                    stop_poledance()
                                    RageUI.CloseAll()
                                end
                            }, nil)
                        end
                    else
                        RageUI.Button("~r~Aucune animation disponible", "Aucune animation configurée", {}, true, {
                            onSelected = function() end
                        }, nil)
                    end
                end)
                
                Wait(0)
            end
        end)
    end
end


