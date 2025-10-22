return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	["canneapeche"] = {
		label = "Canne à pêche",
		weight = 1,
		stack = true,
		close = true,
	},


	["paquetcigarette"] = {
		label = "Paquet de cigarettes",
		weight = 1,
		stack = true,
		close = true,
	},

	["hamecon"] = {
		label = "Hamecon",
		weight = 1,
		stack = true,
		close = true,
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
	},

	['telephone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['bouteilledeau'] = {
		label = 'Bouteille d\'eau',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'Vous avez bu une bouteille d\'eau'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	["sandwich"] = {
		label = "Pain",
		weight = 1,
		stack = true,
		close = true,
	},

	["caisse_vin"] = {
		label = "Caisse de vin",
		weight = 10,
		stack = true,
		close = true,
	},

	["champagne"] = {
		label = "Champagne",
		weight = 1,
		stack = true,
		close = true,
	},

	["cognac"] = {
		label = "Cognac",
		weight = 1,
		stack = true,
		close = true,
	},

	["diving_gear"] = {
		label = "Tenue de plongée",
		weight = 1,
		stack = true,
		close = true,
	},

	["grappe_raisin"] = {
		label = "Grappe de raisin",
		weight = 2,
		stack = true,
		close = true,
	},

	["jus_raisin"] = {
		label = "Jus de raisin",
		weight = 1,
		stack = true,
		close = true,
	},

	["lot_vin"] = {
		label = "Lot de vin",
		weight = 5,
		stack = true,
		close = true,
	},

	["raisin"] = {
		label = "Raisin",
		weight = 1,
		stack = true,
		close = true,
	},

	["raisin_blanc"] = {
		label = "Raisin blanc",
		weight = 1,
		stack = true,
		close = true,
	},

	["raisin_rouge"] = {
		label = "Raisin rouge",
		weight = 1,
		stack = true,
		close = true,
	},

	["vin_blanc"] = {
		label = "Vin blanc",
		weight = 1,
		stack = true,
		close = true,
	},

	["vin_premium"] = {
		label = "Vin premium",
		weight = 1,
		stack = true,
		close = true,
	},

	["vin_rose"] = {
		label = "Vin rosé",
		weight = 1,
		stack = true,
		close = true,
	},

	["vin_rouge"] = {
		label = "Vin rouge",
		weight = 1,
		stack = true,
		close = true,
	},

	["vin_vintage"] = {
		label = "Vin vintage",
		weight = 1,
		stack = true,
		close = true,
	},
}