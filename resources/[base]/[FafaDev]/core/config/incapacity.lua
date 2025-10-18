CONFIG_INCAPACITY = {
    [1] = {
        combat = true,        -- Désactiver le combat
        jump = true,          -- Désactiver le saut
        drive = false,        -- Permettre la conduite
        run = false,          -- Permettre la course
        animation = "move_m@injured",
        time = 3,             -- Durée en minutes
        props = false,        -- Pas de béquille
        delete = false,       -- Ne pas supprimer l'incapacité
        description = "Blessure légère - Marche lente, pas de combat ni saut"
    },
    [2] = {
        combat = true,        -- Désactiver le combat
        jump = true,          -- Désactiver le saut
        drive = true,         -- Désactiver la conduite
        run = true,           -- Désactiver la course
        animation = "move_m@injured",
        time = 8,             -- Durée en minutes
        props = true,         -- Ajouter une béquille
        delete = false,       -- Ne pas supprimer l'incapacité
        description = "Blessure modérée - Béquille, pas de combat ni saut, pas de conduite ni course"
    },
    [3] = {
        combat = true,        -- Désactiver le combat
        jump = true,          -- Désactiver le saut
        drive = true,         -- Désactiver la conduite
        run = true,           -- Désactiver la course
        animation = "move_m@injured",
        time = 15,            -- Durée en minutes
        props = true,         -- Ajouter une béquille
        delete = false,       -- Ne pas supprimer l'incapacité
        description = "Blessure sévère - Béquille, toutes actions limitées"
    },
    [4] = {
        combat = true,        -- Désactiver le combat
        jump = true,          -- Désactiver le saut
        drive = true,         -- Désactiver la conduite
        run = true,           -- Désactiver la course
        animation = "move_m@injured",
        time = 25,            -- Durée en minutes
        props = true,         -- Ajouter une béquille
        delete = false,       -- Ne pas supprimer l'incapacité
        description = "Blessure grave - Béquille, toutes actions limitées, durée prolongée"
    },
    [5] = {
        combat = false,       -- Permettre le combat
        jump = false,         -- Permettre le saut
        drive = false,        -- Permettre la conduite
        run = false,          -- Permettre la course
        animation = nil,      -- Pas d'animation
        time = 0,             -- Pas de durée
        props = false,        -- Pas de béquille
        delete = true,        -- Supprimer l'incapacité
        description = "Suppression d'incapacité - Remet le joueur en état normal"
    },
}

