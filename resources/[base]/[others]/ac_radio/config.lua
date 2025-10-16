-----------------------------------------------------------------
-- Visit https://docs.acscripts.dev/radio for documentation
-----------------------------------------------------------------

return {
    -- Enable usable item for opening the radio
    useUsableItem = true,

    -- Enable command for opening the radio
    useCommand = true,

    -- Default keybind for the '/radio' command
    commandKey = '',

    -- Enable disconnecting from frequency when there is no radio item left in player's inventory
    disconnectWithoutRadio = true,

    -- Percentage of volume to increase/decrease per step
    volumeStep = 10,

    -- Frequency decimal precision
    frequencyStep = 0.01,

    -- Maximum amount of available frequencies (starting from 0)
    maximumFrequencies = 1000,

    -- Frequency restrictions for channels
    restrictedChannels = {
        [10] = 'gouv', -- Fréquence réservée au FBI
        [11] = 'police', -- Fréquence réservée à la Police
        [12] = 'police', -- Police
        [13] = 'sheriff', -- Sheriff
        [14] = { police = 2, sheriff = 2 }, -- Police + BCSO
        [15] = { ambulance_nord = 2, ambulance_sud = 2 }, -- Ambulance Nord + Sud
        [16] = { police = 2, sheriff = 2, fbi = 2 }, -- Police + BCSO + FBI
        [17] = { police = 2, sheriff = 2, fbi = 2, ambulance_nord = 2, ambulance_sud = 2 }, -- Toutes les unités
        [18] = { police = 2, sheriff = 2, fbi = 2, ambulance_nord = 2, ambulance_sud = 2, gouv = 2 }, -- Toutes les unités + Gouv
    },

    -- ! The following options will override pma-voice convars
    -- Enable radio voice effect (voice sounds like on a real radio)
    radioEffect = true,

    -- Enable animation while talking on radio
    radioAnimation = true,

    -- Default keybind for talking on radio
    radioTalkKey = 'LMENU',
}
