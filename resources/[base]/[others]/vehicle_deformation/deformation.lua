local isDebug = false

-- iterations for damage application
local MAX_DEFORM_ITERATIONS = 50
-- the minimum damage value at a deformation point
local DEFORMATION_DAMAGE_THRESHOLD = 0.05

-- gets deformation from a vehicle
function GetVehicleDeformation(vehicle)
    assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")

	-- check vehicle size and pre-calc values for offsets
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = (max.x - min.x) * 0.5
	local Y = (max.y - min.y) * 0.5
	local Z = (max.z - min.z) * 0.5
	local halfY = Y * 0.5

	-- offsets for deformation check
	local positions = {
		vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),

		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),

		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),


		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),

		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),

		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),


		vector3(-X, 0.0,  0.0),
		vector3(-X, 0.0,  Z),

		vector3(0.0, 0.0,  0.0),
		vector3(0.0, 0.0,  Z),

		vector3(X, 0.0,  0.0),
		vector3(X, 0.0,  Z),


		vector3(-X, -halfY,  0.0),
		vector3(-X, -halfY,  Z),

		vector3(0.0, -halfY,  0.0),
		vector3(0.0, -halfY,  Z),

		vector3(X, -halfY,  0.0),
		vector3(X, -halfY,  Z),


		vector3(-X, -Y,  0.0),
		vector3(-X, -Y,  Z),

		vector3(0.0, -Y,  0.0),
		vector3(0.0, -Y,  Z),

		vector3(X, -Y,  0.0),
		vector3(X, -Y,  Z),
	}

	-- get deformation from vehicle
	local deformationPoints = {}
	for i, pos in ipairs(positions) do
		-- translate damage from vector3 to a float
		local dmg = #(GetVehicleDeformationAtPos(vehicle, pos))
		if (dmg > DEFORMATION_DAMAGE_THRESHOLD) then
			table.insert(deformationPoints, { pos, dmg })
		end
	end

	Log("Got " .. tostring(#deformationPoints) .. " deformation point" .. (#deformationPoints == 1 and "" or "s") .. " from \"" .. tostring(GetVehicleNumberPlateText(vehicle)) .. "\"")

	return deformationPoints
end

-- sets deformation on a vehicle
function SetVehicleDeformation(vehicle, deformationPoints, callback)
    assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")
    assert(deformationPoints ~= nil and type(deformationPoints) == "table", "Parameter \"deformationPoints\" must be a table!")

	Citizen.CreateThread(function()
		-- set radius and damage multiplier
		local min, max = GetModelDimensions(GetEntityModel(vehicle))
		local radius = #(max - min) * 40.0			-- might need some more experimentation
		local damageMult = #(max - min) * 30.0 * 2.0		-- might need some more experimentation
        
        local printMsg = false

		for i, def in ipairs(deformationPoints) do
			def[1] = vector3(def[1].x, def[1].y, def[1].z)
		end

		-- iterate over all deformation points and check if more than one application is necessary
		-- looping is necessary for most vehicles that have a really bad damage model or take a lot of damage (e.g. neon, phantom3)
		local deform = true
		local iteration = 0
		while (deform and iteration < MAX_DEFORM_ITERATIONS) do
			if (not DoesEntityExist(vehicle)) then
				Log("Vehicle \"" .. tostring(GetVehicleNumberPlateText(vehicle)) .. "\" got deleted mid-deformation.")
				return
			end

			deform = false

			-- apply deformation if necessary
			for i, def in ipairs(deformationPoints) do
				if (#(GetVehicleDeformationAtPos(vehicle, def[1])) < def[2]) then
					SetVehicleDamage(
						vehicle, 
						def[1] * 2.0, 
						def[2] * damageMult, 
						radius, 
						true
					)

					deform = true

                    if (not printMsg) then
                        Log("Applying deformation to \"" .. tostring(GetVehicleNumberPlateText(vehicle)) .. "\"")

                        printMsg = true
                    end
				end
			end

			iteration = iteration + 1

			Citizen.Wait(100)
		end

        if (printMsg) then
		    Log("Applying deformation finished for \"" .. tostring(GetVehicleNumberPlateText(vehicle)) .. "\"")
        end

        if (callback) then
		    callback()
        end
	end)
end

function Log(text)
	if (isDebug) then
		print(text)
	end
end

exports("GetVehicleDeformation", GetVehicleDeformation)
exports("SetVehicleDeformation", SetVehicleDeformation)

local lastSpeed = 0.0
local impactCooldown = 0

local speedDamageProfile = {
    { speed = 0,   percent = 0 },
    { speed = 50,  percent = 20 },
    { speed = 100, percent = 45 },
    { speed = 150, percent = 60 },
    { speed = 180, percent = 80 },
    { speed = 220, percent = 100 }
}

local function GetDamagePercentFromSpeed(speed)
    for i = 1, #speedDamageProfile - 1 do
        local current = speedDamageProfile[i]
        local next = speedDamageProfile[i + 1]

        if speed >= current.speed and speed < next.speed then
            local range = next.speed - current.speed
            local ratio = (speed - current.speed) / range
            return current.percent + ratio * (next.percent - current.percent)
        end
    end

    return 100.0
end

CreateThread(function()
    while true do
        Wait(100)

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(veh, -1) == playerPed then
                local currentSpeed = GetEntitySpeed(veh) * 3.6

                if lastSpeed - currentSpeed >= 30.0 and currentSpeed < 100.0 and GetGameTimer() > impactCooldown then
                    local impactSpeed = lastSpeed
                    local damagePercent = GetDamagePercentFromSpeed(impactSpeed)
					local engineHealth = GetVehicleEngineHealth(veh)
					local newHealth = math.max(20.0, engineHealth * ((100 - damagePercent) / 100))

					SetVehicleEngineHealth(veh, newHealth)

					if newHealth <= 300.0 then
						SetVehicleUndriveable(veh, true)
						SetVehicleEngineOn(veh, false, true, true)
					else
						SetVehicleUndriveable(veh, false)
					end
                    if isDebug then
                        print(("[DEBUG] Impact à %.1f km/h → Perte moteur : %.1f%% → Santé = %.1f"):format(impactSpeed, damagePercent, newHealth))
                    end

                    impactCooldown = GetGameTimer() + 1500
                end

                lastSpeed = currentSpeed
            end
        end
    end
end)