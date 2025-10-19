local open_employement_center_menu = false
local employement_center_menu = RageUI.CreateMenu("Pole emplois", "Pole emplois")

employement_center_menu.Closed = function()
    open_employement_center_menu = false
end

local selectedJob = nil
local jobConfirmationActive = false

function IS_JOB_CONFIRMATION_ACTIVE()
    return jobConfirmationActive
end

function FUN_OPEN_EMPLOYEMENT_CENTER_MENU(data)
    open_employement_center_menu = not open_employement_center_menu
    RageUI.Visible(employement_center_menu, open_employement_center_menu)
    if open_employement_center_menu then
        CreateThread(function()
            while open_employement_center_menu do
                RageUI.IsVisible(employement_center_menu, function()
                    for _, job in pairs(CONFIG_EMPLOYEMENT_CENTER.Jobs) do
                        RageUI.Button(job.label, job.description, {}, true, {
                            onSelected = function()
                                selectedJob = job
                                jobConfirmationActive = true
                                open_employement_center_menu = false
                            end
                        })
                    end
                end)
                Wait(0)
            end
        end)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if jobConfirmationActive and selectedJob then
            ESX.ShowHelpNotification("Voulez-vous prendre le job ~b~" .. selectedJob.label .. "~s~?\n~g~~INPUT_CONTEXT~~s~ pour accepter | ~r~~INPUT_DETONATE~~s~ pour refuser")
            
            if IsControlJustPressed(0, 38) then
                CORE.trigger_server_event("fafadev:to_server:employement_center", selectedJob.name)
                jobConfirmationActive = false
                selectedJob = nil
            end
            
            if IsControlJustPressed(0, 47) then
                ESX.ShowNotification("~y~Action annulée")
                jobConfirmationActive = false
                selectedJob = nil
            end
        else
            Wait(500)
        end
    end
end)