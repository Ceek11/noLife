Config = {}

Config.DMVSchool = {
    vector3(240.7489, -1379.575, 33.74177)
}

Config.Language = "fr"

Config.SpeedMultiplier = 3.6 -- 3.6 for kmh, 2.236936 for mph

Config.MaxErrors = 3 -- Max errors before fail

Config.MarkerSettings = {
    type = 2,
    size = vector3(1.0, 1.0, 1.0),
    color = vector3(255, 255, 255),
    rotate = false,
    dump = false
}

Config.PuntiMinimi = 5 -- Minimum points to pass the theory test

-- ATTENTION: Modifying the id after a user has already obtained a license causes them to be lost
Config.License = {
    {
        label = 'Permis A',
        id = 'drive_bike',
        img = 'bike.png',
        pricing = {
            theory = 3000,
            practice = 4000
        },
        vehicle = {
            model = 'faggio',
            coords = vector3(231.2591, -1392.982, 30.50785),
            heading = 144.40260314941,
            plate = "DMV1"
        }
    },
    {
        label = 'Permis B',
        id = 'drive',
        img = 'car.png',
        pricing = {
            theory = 3000,
            practice = 4000
        },
        vehicle = {
            model = 'blista',
            coords = vector3(231.2591, -1392.982, 30.50785),
            heading = 144.40260314941,
            plate = "DMV1"
        }
    },
    {
        label = 'Permis C',
        id = 'drive_truck',
        img = 'truck.png',
        pricing = {
            theory = 3000,
            practice = 4000
        },
        vehicle = {
            model = 'pounder',
            coords = vector3(231.2591, -1392.982, 30.50785),
            heading = 144.40260314941,
            plate = "DMV1"
        }
    }
}

Config.PracticeCoords = {
    [1] = {
        {
            coordinate = vector3(227.1181, -1399.691, 30.1),
            speedLimit = 50
        },
        {
            coordinate = vector3(183.7479, -1394.595, 29.05295),
            speedLimit = 50
        },
        {
            coordinate = vector3(210.3608, -1327.127, 29.16619),
            speedLimit = 50
        },
        {
            coordinate = vector3(217.6466, -1145.248, 29.3349),
            speedLimit = 50
        },
        {
            coordinate = vector3(83.13854, -1136.699, 29.15778),
            speedLimit = 50
        },
        {
            coordinate = vector3(55.52874, -1248.127, 29.34311),
            speedLimit = 50
        },
        {
            coordinate = vector3(82.69904, -1338.678, 29.3447),
            speedLimit = 50
        },
        {
            coordinate = vector3(131.4893, -1387.581, 29.28993),
            speedLimit = 50
        },
        {
            coordinate = vector3(220.603, -1445.61, 29.24681),
            speedLimit = 50
        },
        {
            coordinate = vector3(242.2584, -1536.136, 29.24705),
            speedLimit = 50
        },
        {
            coordinate = vector3(301.6448, -1523.68, 29.34156),
            speedLimit = 50
        },
        {
            coordinate = vector3(256.1726, -1445.458, 29.24207),
            speedLimit = 50
        },
        {
            coordinate = vector3(233.427, -1397.215, 30.5071),
            speedLimit = 50
        },
    }
}


Config.Question = {
    [1] = {
        {
            label = "Quelle est la couleur du signal d'interdiction ?",
            options = {
                {
                    label = "Rouge",
                    correct = true
                },
                {
                    label = "Bleu",
                    correct = false
                },
                {
                    label = "Jaune",
                    correct = false
                }
            }
        },
        {
            label = "Qu'indique un panneau routier en forme de triangle ?",
            options = {
                {
                    label = "Intersection à trois voies",
                    correct = false
                },
                {
                    label = "Céder le passage",
                    correct = true
                },
                {
                    label = "Sens unique",
                    correct = false
                }
            }
        },
        {
            label = "Que signifie une ligne continue sur le bord de la route ?",
            options = {
                {
                    label = "On peut dépasser",
                    correct = false
                },
                {
                    label = "Interdiction de dépasser",
                    correct = true
                },
                {
                    label = "Dépassement autorisé uniquement à droite",
                    correct = false
                }
            }
        },
        {
            label = "Quelle est la limite de vitesse en zone urbaine ?",
            options = {
                {
                    label = "50 km/h",
                    correct = true
                },
                {
                    label = "70 km/h",
                    correct = false
                },
                {
                    label = "90 km/h",
                    correct = false
                }
            }
        },
        {
            label = "Que signifie le panneau de danger avec un appareil photo ?",
            options = {
                {
                    label = "Zone de stationnement",
                    correct = false
                },
                {
                    label = "Zone d'interdiction de stationner",
                    correct = false
                },
                {
                    label = "Contrôle électronique de la vitesse",
                    correct = true
                }
            }
        },
        {
            label = "Quelle est la distance minimale de sécurité à maintenir avec le véhicule qui précède ?",
            options = {
                {
                    label = "1 mètre",
                    correct = false
                },
                {
                    label = "2 secondes de distance",
                    correct = true
                },
                {
                    label = "0,5 mètre",
                    correct = false
                }
            }
        },
        {
            label = "Que doit faire un conducteur lorsqu'il s'approche d'un passage à niveau avec les barrières fermées ?",
            options = {
                {
                    label = "Accélérer pour traverser avant que les barrières ne se ferment complètement",
                    correct = false
                },
                {
                    label = "Traverser uniquement s'il n'y a pas de trains en approche",
                    correct = true
                },
                {
                    label = "Klaxonner et continuer",
                    correct = false
                }
            }
        },
        {
            label = "Que représente le panneau stop ?",
            options = {
                {
                    label = "Céder le passage",
                    correct = false
                },
                {
                    label = "Obligation de s'arrêter",
                    correct = true
                },
                {
                    label = "Sens unique",
                    correct = false
                }
            }
        },
        {
            label = "Qu'indique le panneau avec une flèche verte pointant vers le haut ?",
            options = {
                {
                    label = "Voie réservée uniquement aux vélos",
                    correct = false
                },
                {
                    label = "Voie réservée uniquement aux piétons",
                    correct = true
                },
                {
                    label = "Voie réservée aux véhicules publics",
                    correct = false
                }
            }
        },
        {
            label = "Que représente le panneau avec une croix de Saint-André (X rouge sur fond blanc) ?",
            options = {
                {
                    label = "Zone à accès limité",
                    correct = true
                },
                {
                    label = "Zone de stationnement autorisée",
                    correct = false
                },
                {
                    label = "Zone piétonne",
                    correct = false
                }
            }
        }
    },
    [2] = {
        {
            label = "Qu'indique le panneau d'interdiction d'accès ?",
            options = {
                {
                    label = "Obligation de céder le passage",
                    correct = false
                },
                {
                    label = "Interdiction de circuler",
                    correct = true
                },
                {
                    label = "Dépassement obligatoire",
                    correct = false
                }
            }
        },
        {
            label = "Que doit faire un conducteur lorsqu'il s'approche d'une intersection non réglementée par des panneaux ?",
            options = {
                {
                    label = "Accélérer pour traverser rapidement",
                    correct = false
                },
                {
                    label = "S'arrêter, céder le passage et continuer avec prudence",
                    correct = true
                },
                {
                    label = "Klaxonner pour avertir les autres conducteurs",
                    correct = false
                }
            }
        },
        {
            label = "Qu'indique le panneau de virage dangereux à gauche ?",
            options = {
                {
                    label = "Proximité d'une aire de repos",
                    correct = false
                },
                {
                    label = "Présence d'une intersection",
                    correct = false
                },
                {
                    label = "Présence d'un virage à gauche dangereux",
                    correct = true
                }
            }
        },
        {
            label = "Qu'indique le panneau de fin d'interdiction de dépasser ?",
            options = {
                {
                    label = "On peut commencer à dépasser",
                    correct = true
                },
                {
                    label = "Interdiction de stationner",
                    correct = false
                },
                {
                    label = "Fin de l'autoroute",
                    correct = false
                }
            }
        },
        {
            label = "Que représente le panneau de passage piéton ?",
            options = {
                {
                    label = "Traversée autorisée uniquement pour les vélos",
                    correct = false
                },
                {
                    label = "Interdiction de traverser pour les piétons",
                    correct = false
                },
                {
                    label = "Point où les piétons peuvent traverser en toute sécurité",
                    correct = true
                }
            }
        },
        {
            label = "Qu'indique le panneau de fin de zone à circulation restreinte ?",
            options = {
                {
                    label = "Début d'une zone à circulation restreinte",
                    correct = false
                },
                {
                    label = "Fin d'une zone de stationnement",
                    correct = false
                },
                {
                    label = "Fin de la zone où les restrictions d'accès sont en vigueur",
                    correct = true
                }
            }
        },
        {
            label = "Que représente le panneau d'interdiction de circuler pour les véhicules à moteur ?",
            options = {
                {
                    label = "Obligation de céder le passage",
                    correct = false
                },
                {
                    label = "Interdiction de circuler uniquement pour les camions",
                    correct = false
                },
                {
                    label = "Interdiction de circuler pour tous les véhicules à moteur",
                    correct = true
                }
            }
        },
        {
            label = "Que doit faire un conducteur lorsqu'il s'approche d'un feu de circulation avec un feu jaune clignotant ?",
            options = {
                {
                    label = "Accélérer pour passer avant que le signal ne change",
                    correct = false
                },
                {
                    label = "S'arrêter uniquement s'il y a des véhicules traversant l'intersection",
                    correct = true
                },
                {
                    label = "Continuer sans ralentir",
                    correct = false
                }
            }
        },
        {
            label = "Qu'indique le panneau d'interdiction d'accès aux piétons ?",
            options = {
                {
                    label = "Interdiction de circuler uniquement pour les cyclistes",
                    correct = false
                },
                {
                    label = "Interdiction de circuler uniquement pour les piétons",
                    correct = true
                },
                {
                    label = "Obligation de traverser uniquement en vélo",
                    correct = false
                }
            }
        },
        {
            label = "Qu'indique le panneau d'interdiction de circuler pour les véhicules tractant une remorque ?",
            options = {
                {
                    label = "Interdiction de circuler uniquement pour les camping-cars",
                    correct = false
                },
                {
                    label = "Interdiction de circuler pour les véhicules tractant une remorque",
                    correct = true
                },
                {
                    label = "Obligation de tracter une remorque",
                    correct = false
                }
            }
        }
    }
}

Config.Lang = {
    ['fr'] = {
        ['speed_error'] = "Vous roulez trop vite, ralentissez !",
        ['open_dmv'] = "Appuyez sur ~INPUT_CONTEXT~ pour ouvrir l'auto-école",
        ['dmv'] = "AUTO-ÉCOLE",
        ['point'] = "POINTS",
        ['error'] = "ERREURS",
        ['ok'] = "Ok",
        ['start_theory'] = "Commencer le test théorique",
        ['theory_before'] = "Faites le test théorique",
        ['start_practice'] = "Commencer le test pratique",
        ['test_passed'] = "Test réussi !",
        ['already_done'] = "Vous avez déjà fait ce test !",
        ['theory_success'] = "Félicitations, vous avez réussi le test théorique, revenez bientôt pour le test pratique !",
        ['theory_error'] = "Nous sommes désolés de vous informer que vous n'avez pas réussi le test théorique, n'abandonnez pas, revenez bientôt mieux préparé et réessayez le test !",
        ['practice_success'] = "Félicitations, vous avez réussi le test pratique, vous êtes maintenant un conducteur avec permis !",
        ['practice_error'] = "Nous sommes désolés de vous informer que vous n'avez pas réussi le test pratique, n'abandonnez pas, revenez bientôt mieux préparé et réessayez le test !",
        ['money_error'] = "Vous n'avez pas assez d'argent pour faire ce test ! Il vous manque %s€"
    }
}

onCompleteTheory = function(license)
    TriggerServerEvent('ricky-dmv:givelicense', license) -- Give license to sql
end

onCompletePractice = function(license)
    TriggerServerEvent('ricky-dmv:givelicense', license) -- Give license to sql
end