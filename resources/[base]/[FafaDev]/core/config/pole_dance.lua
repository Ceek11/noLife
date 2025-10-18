-- Configuration des animations de pole dance
TBL_POLE_DANCE_ANIMATIONS = {
    {
        id = 1,
        dict = "mini@strip_club@pole_dance@pole_dance1",   
        anim = "pd_dance_01",
        label = "Danse Sensuelle 1",
        description = "Première danse sensuelle sur la barre",
        duration = 30000, -- Durée en millisecondes (optionnel)
        category = "sensuel"
    },
    {
        id = 2,
        dict = "mini@strip_club@pole_dance@pole_dance2",
        anim = "pd_dance_02",
        label = "Danse Sensuelle 2",
        description = "Deuxième danse sensuelle sur la barre",
        duration = 30000,
        category = "sensuel"
    },
    {
        id = 3,
        dict = "mini@strip_club@pole_dance@pole_dance3",

        anim = "pd_dance_03",
        label = "Danse Sensuelle 3",
        description = "Troisième danse sensuelle sur la barre",
        duration = 30000,
        category = "sensuel"
    },
    {
        id = 4,
        dict = "mini@strip_club@pole_dance@pole_dance4",
        anim = "pd_dance_04",
        label = "Danse Acrobatique",
        description = "Danse acrobatique avancée",
        duration = 45000,
        category = "acrobatique"
    },
    {
        id = 5,
        dict = "mini@strip_club@pole_dance@pole_dance5",
        anim = "pd_dance_05",
        label = "Danse Lente",
        description = "Danse lente et sensuelle",
        duration = 60000,
        category = "lent"
    }
}

-- Configuration des catégories d'animations
TBL_POLE_DANCE_CATEGORIES = {
    sensuel = {
        label = "Danses Sensuelles",
        description = "Danses sensuelles et élégantes",
        color = "~p~"
    },
    acrobatique = {
        label = "Danses Acrobatiques", 
        description = "Danses acrobatiques et techniques",
        color = "~r~"
    },
    lent = {
        label = "Danses Lentes",
        description = "Danses lentes et romantiques",
        color = "~b~"
    }
}

