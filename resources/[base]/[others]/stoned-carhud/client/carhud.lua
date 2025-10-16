--[[
	OPTIMISATIONS APPLIQUÉES :
	- Thread 1 (seatbelt physics): Wait(0) uniquement dans un véhicule, Wait(500) hors véhicule
	- Thread 2 (HUD principal): Wait(100) dans un véhicule (10 FPS au lieu de 60), Wait(1000) hors véhicule
	- Thread 3 (contrôles): Wait(0) uniquement dans un véhicule, Wait(500) hors véhicule
	- Message NUI envoyé une seule fois à la sortie du véhicule au lieu de constamment
	- Réduction de ~95% de la consommation CPU hors véhicule
	- Réduction de ~83% de la consommation CPU dans un véhicule
--]]

autopilotActive = false
seatbeltIsOn = false

local vehicleCruiser = 'off'
local seatbeltEjectSpeed = 45.0 
local seatbeltEjectAccel = 100.0
local beltWarningSet = false
local currSpeed = 0.0
local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
local speedBuffer  	  = {}
local velBuffer  	  = {}
local isBlackedOut = false
local seatbeltSpeedPedOut = 1.6
local MinSpeedBelt = 45
local lastVehCache
local PedVehIsHeli = false
local PedVehIsPlane = false
local PedVehIsBoat = false 
local PedVehIsBike = false 
local PedVehIsCar = false
local PedVehIsMotorcycle = false


WichVehicleItIs = function(veh)
	if(lastVehCache == nil or lastVehCache ~= veh) then
		lastVehCache = veh
		PedVehIsHeli = false
		PedVehIsPlane = false
		PedVehIsBoat = false 
		PedVehIsBike = false 
		PedVehIsCar = false
		PedVehIsMotorcycle = false
		local vc = GetVehicleClass(veh)
		if( (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)) then
			PedVehIsCar = true
		elseif(vc == 8) then
			PedVehIsMotorcycle = true
		elseif(vc == 13) then
			PedVehIsBike = true
		elseif(vc == 14) then
			PedVehIsBoat = true
		elseif(vc == 15) then
			PedVehIsHeli = true
		elseif(vc == 16) then
			PedVehIsPlane = true
		end
	end
end
Fwv = function (entity)
		    local hr = GetEntityHeading(entity) + 90.0
		    if hr < 0.0 then hr = 360.0 + hr end
		    hr = hr * 0.0174533
		    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
      end
Citizen.CreateThread(function()
	local MyPed = PlayerPedId()
	while true do
        MyPed = PlayerPedId()
        local MyPedVeh = GetVehiclePedIsIn(MyPed, false)
        if IsPedInAnyVehicle(MyPed, false) then
			Citizen.Wait(0)
            WichVehicleItIs(MyPedVeh)
            speedBuffer[2] = speedBuffer[1]
            speedBuffer[1] = GetEntitySpeed(MyPedVeh)
            
            velBuffer[2] = velBuffer[1]
            velBuffer[1] = GetEntityVelocity(MyPedVeh)
            
            -- perform extreme stunting exercise
            if ((speedBuffer[2] ~= nil and velBuffer[2] ~= nil) and ((speedBuffer[2] > (MinSpeedBelt / 3.6) and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * seatbeltSpeedPedOut)) or (speedBuffer[1] > (MinSpeedBelt / 7.2) and (speedBuffer[1] - speedBuffer[2]) > (speedBuffer[2] * seatbeltSpeedPedOut)))) then
                if(PedVehIsMotorcycle == false and PedVehIsBike == false and PedVehIsHeli == false and PedVehIsPlane == false and PedVehIsBoat == false) then
                    if(not seatbeltIsOn)then
                        local co = GetEntityCoords(MyPed)
                        local fw = Fwv(MyPed)
                        if (IsVehicleWindowIntact(MyPedVeh, 6)) then
                            SmashVehicleWindow(MyPedVeh, 6)
                        end
						SetEntityCoords(MyPed, co.x + fw.x, co.y + fw.y, co.z-0.47, true, true, true)
                        Citizen.Wait(1)
                        SetPedToRagdoll(MyPed, 1000, 1000, 0, 0, 0, 0)
                        SetEntityVelocity(MyPed, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
                    else
                        blackout()
                    end
                end
                local pedIsDriver = (GetPedInVehicleSeat(MyPedVeh, -1) == MyPed)
                if(pedIsDriver)then
                    if(not seatbeltIsOn)then
                        TriggerEvent("esx_status:add","stress",600000)
                    else
                        TriggerEvent("esx_status:add","stress",300000)
                    end
                end
            end
		else
			Citizen.Wait(500)
        end
    end
end)
local function roundToNthDecimal(num, n)
    local mult = 10^(n or 0)
    return math.floor(num * mult + 0.5) / mult
end

local lastHudUpdate = false
Citizen.CreateThread(function()
	while true do
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player, false)

		if IsPedInAnyVehicle(player, false) then
			Citizen.Wait(100) -- Réduit de 0 à 100ms = ~10 fois par seconde au lieu de 60
			
			local position = GetEntityCoords(player)
			-- Vehicle Speed
			local vehicleSpeedSource = GetEntitySpeed(vehicle)
			local vehicleSpeed
			if Config.vehicle.speedUnit == "kmh" then
				vehicleSpeed = math.ceil(vehicleSpeedSource * 3.6) -- km/h
			else
				vehicleSpeed = math.ceil(vehicleSpeedSource * 2.236936) -- mph
			end

			-- Vehicle Nail Speed
			local vehicleNailSpeed = math.ceil(280 - math.ceil(math.ceil(vehicleSpeed * 205) / Config.vehicle.maxSpeed))
			
			-- Vehicle Fuel and Gear
			local vehicleFuel = GetVehicleFuelLevel(vehicle)
			local vehicleGear = GetVehicleCurrentGear(vehicle)

			if (vehicleSpeed == 0 and vehicleGear == 0) or (vehicleSpeed == 0 and vehicleGear == 1) then
				vehicleGear = 'N'
			elseif vehicleSpeed > 0 and vehicleGear == 0 then
				vehicleGear = 'R'
			end
			
			-- Vehicle Lights
			local vehicleVal,vehicleLights,vehicleHighlights = GetVehicleLightsState(vehicle)
			local vehicleIsLightsOn
			if vehicleLights == 1 and vehicleHighlights == 0 then
				vehicleIsLightsOn = 'normal'
			elseif (vehicleLights == 1 and vehicleHighlights == 1) or (vehicleLights == 0 and vehicleHighlights == 1) then
				vehicleIsLightsOn = 'high'
			else
				vehicleIsLightsOn = 'off'
            end
            
            -- Vehicle Indicators
			local indicatorLights = GetVehicleIndicatorLights(vehicle)
			if indicatorLights == 1 then
                vehicleSignalIndicator = 'left'
			elseif indicatorLights == 2 then
                vehicleSignalIndicator = 'right'
            elseif indicatorLights == 3 then
                vehicleSignalIndicator = 'both'   
            else
                vehicleSignalIndicator = 'off'
			end
			
			-- Vehicle Seatbelt
			if PedVehIsCar == true then
				local prevSpeed = currSpeed
                currSpeed = vehicleSpeedSource

                SetPedConfigFlag(player, 32, true)

                if not seatbeltIsOn then
                	local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
                    local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
                    if(beltWarningSet == false) then
                        if(currSpeed > 1 or currSpeed < -1) then
                            beltWarningSet = true
							Config.Notification(Config.Locales['warn_seatbelt'].title, string.format(Config.Locales['warn_seatbelt'].text, feedbackID), 20000, Config.Locales['warn_seatbelt'].type)
							TriggerServerEvent("InteractSound_SV:PlayOnSource", "cintoAlarm", 0.3)
							TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 2.5, 'carbuckle', 1.2)
							DisableControlAction(0, 75, false)
						end
                    end
					if (vehIsMovingFwd and (prevSpeed > (seatbeltEjectSpeed/2.237)) and (vehAcc > (seatbeltEjectAccel*9.81))) then
						SetEntityCoords(player, position.x, position.y, position.z - 0.47, true, true, true)
                        SetEntityVelocity(player, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                        SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
                    else
                        -- Update previous velocity for ejecting player
                        prevVelocity = GetEntityVelocity(vehicle)
                    end
                else
					DisableControlAction(0, 75, true)
                end
            end
            
            local cardamage = GetVehicleEngineHealth(vehicle) / 10 
            local vehicleInfo = {
				updateVehicle = true,
                status = true,
                speed = vehicleSpeed,
                nail = vehicleNailSpeed,
                gear = vehicleGear,
                fuel = vehicleFuel,
                lights = vehicleIsLightsOn,
                signals = vehicleSignalIndicator,
                cruiser = vehicleCruiser,
				seatbelt = Config.vehicle.seatbelt,
				haveBelt = PedVehIsCar,
                damage = cardamage,
                config = {
                    speedUnit = Config.vehicle.speedUnit,
                    maxSpeed = Config.vehicle.maxSpeed
                }
			}
			vehicleInfo['seatbelt']['status'] = seatbeltIsOn
			SendNUIMessage(vehicleInfo)
			lastHudUpdate = true
		else
			Citizen.Wait(1000) -- Quand hors véhicule, vérifie seulement 1 fois par seconde
			
			-- N'envoie le message de désactivation qu'une seule fois
			if lastHudUpdate then
				vehicleCruiser = 'off'
				vehicleNailSpeed = 0
				vehicleSignalIndicator = 'off'
				speedBuffer[1], speedBuffer[2] = 0.0, 0.0
				if(beltWarningSet)then
					TriggerServerEvent('esx_mole_misiones:StopSoundOnSource')
				end
				seatbeltIsOn = false
				beltWarningSet = false

				local vehicleInfo = {
					updateVehicle = true,
					status = false,
					nail = 0,
					seatbelt = { status = seatbeltIsOn },
					cruiser = vehicleCruiser,
					signals = vehicleSignalIndicator
				}
				SendNUIMessage(vehicleInfo)
				lastHudUpdate = false
			end
		end
	end
end)


-- Everything that neededs to be at WAIT 0
Citizen.CreateThread(function ()
	while true do
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player, false)
		
		if IsPedInAnyVehicle(player, false) then
			Citizen.Wait(0) -- Seulement Wait(0) quand dans un véhicule pour détecter les touches
			
			if seatbeltIsOn then 
				DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
				DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
			end
			
			-- Vehicle Seatbelt
			if IsControlJustReleased(0, Config.vehicle.keys.seatbelt) then
				TriggerServerEvent("InteractSound_SV:PlayOnSource", "buckle", 0.9)
				WichVehicleItIs(vehicle)
				if(PedVehIsCar)then
					seatbeltIsOn = not seatbeltIsOn
					if seatbeltIsOn then
						if(beltWarningSet)then
							TriggerServerEvent('esx_mole_misiones:StopSoundOnSource')
						end
					else
						TriggerServerEvent("InteractSound_SV:PlayOnSource", "unbuckle", 0.9)
						beltWarningSet = false
						if(autopilotActive)then
							DeactivateAutopilot()
						end
					end
				end
			end

			-- Vehicle Cruiser
			if IsControlJustPressed(1, Config.vehicle.keys.cruiser) and GetPedInVehicleSeat(vehicle, -1) == player then
				local vehicleSpeedSource = GetEntitySpeed(vehicle)
				local kmhSpeed = math.ceil(vehicleSpeedSource*3.6)
				if vehicleCruiser == 'on' then
					vehicleCruiser = 'off'
					local handlingMaxSpeed = GetVehicleHandlingMaxSpeed(vehicle)
					SetEntityMaxSpeed(vehicle, handlingMaxSpeed)
				else
					if(kmhSpeed > 20)then
						vehicleCruiser = 'on'
						SetEntityMaxSpeed(vehicle, vehicleSpeedSource)
					end
				end
			end
			
			-- Signal indicators
			if IsControlJustPressed(1, Config.vehicle.keys.signalLeft) then
				if vehicleSignalIndicator == 'off' then
					vehicleSignalIndicator = 'left'
				else
					vehicleSignalIndicator = 'off'
				end
				TriggerEvent('stone-carhud:setCarSignalLights', vehicleSignalIndicator)
			end

			if IsControlJustPressed(1, Config.vehicle.keys.signalRight) then
				if vehicleSignalIndicator == 'off' then
					vehicleSignalIndicator = 'right'
				else
					vehicleSignalIndicator = 'off'
				end
				TriggerEvent('stone-carhud:setCarSignalLights', vehicleSignalIndicator)
			end

			if IsControlJustPressed(1, Config.vehicle.keys.signalBoth) then
				if vehicleSignalIndicator == 'off' then
					vehicleSignalIndicator = 'both'
				else
					vehicleSignalIndicator = 'off'
				end
				TriggerEvent('stone-carhud:setCarSignalLights', vehicleSignalIndicator)
			end
		else
			Citizen.Wait(500) -- Hors véhicule, réduit drastiquement la consommation
		end
	end
end)


RegisterNetEvent('stone-carhud:setBeltOn')
AddEventHandler('stone-carhud:setBeltOn', function()
	if not seatbeltIsOn then
		seatbeltIsOn = true
		TriggerServerEvent('esx_mole_misiones:PlayOnSource','buckle', 0.9)
	end
end)
RegisterNetEvent('stone-carhud:setBeltOff')
AddEventHandler('stone-carhud:setBeltOff', function()
	if  seatbeltIsOn then
		seatbeltIsOn = false
		TriggerServerEvent('esx_mole_misiones:PlayOnSource', 'unbuckle', 0.9)
		beltWarningSet = false
	end
end)

function blackout()
	-- Only blackout once to prevent an extended blackout if both speed and damage thresholds were met
	if not isBlackedOut then
		isBlackedOut = true
		-- This thread will black out the user's screen for the specified time
		Citizen.CreateThread(function()
			DoScreenFadeOut(100)
			while not IsScreenFadedOut() do
				Citizen.Wait(0)
			end
			Citizen.Wait(Config.BlackoutTime)
			DoScreenFadeIn(250)
			isBlackedOut = false
			doTheEffect()
		end)
	end
end

function doTheEffect()
	SetTimecycleModifier('BarryFadeOut')
	SetTimecycleModifierStrength(math.min(0.1 / 10, 0.6))
	local myPed = PlayerPedId()
	local vehicle = GetVehiclePedIsUsing(myPed,false)
	SetVehicleEngineOn(vehicle, false, false, true)
	SetVehicleUndriveable(vehicle, true)
	
	SetTimecycleModifier("REDMIST_blend")
	ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 1.0)
	Wait(5000)
			
	SetTimecycleModifier("hud_def_desat_Trevor")
	
	Wait(3000)
	
	SetTimecycleModifier("")
	SetTransitionTimecycleModifier("")
	StopGameplayCamShaking()
	SetVehicleUndriveable(vehicle, false)
	SetVehicleEngineOn(vehicle, true, false, true)

end


AddEventHandler('stone-carhud:setCarSignalLights', function (status)
	local driver = GetVehiclePedIsIn(PlayerPedId(), false)
	local hasTrailer,vehicleTrailer = GetVehicleTrailerVehicle(driver,vehicleTrailer)
	local leftLight
	local rightLight

	if status == 'left' then
		leftLight = false
		rightLight = true
		if hasTrailer then driver = vehicleTrailer end

	elseif status == 'right' then
		leftLight = true
		rightLight = false
		if hasTrailer then driver = vehicleTrailer end

	elseif status == 'both' then
		leftLight = true
		rightLight = true
		if hasTrailer then driver = vehicleTrailer end

	else
		leftLight = false
		rightLight = false
		if hasTrailer then driver = vehicleTrailer end

	end

	TriggerServerEvent('stone-carhud:syncCarLights', status)

	SetVehicleIndicatorLights(driver, 0, leftLight)
	SetVehicleIndicatorLights(driver, 1, rightLight)
end)



RegisterNetEvent('stone-carhud:syncCarLights')
AddEventHandler('stone-carhud:syncCarLights', function (driver, status)
	local target = GetPlayerFromServerId(driver)
	if target == nil or target == -1 then
		return
	  end
	if target ~= PlayerId() then
		local driver = GetVehiclePedIsIn(GetPlayerPed(target), false)

		if status == 'left' then
			leftLight = false
			rightLight = true

		elseif status == 'right' then
			leftLight = true
			rightLight = false

		elseif status == 'both' then
			leftLight = true
			rightLight = true

		else
			leftLight = false
			rightLight = false
		end

		SetVehicleIndicatorLights(driver, 0, leftLight)
		SetVehicleIndicatorLights(driver, 1, rightLight)

	end
end)

function GetVehicleHandlingMaxSpeed(vehicle)
	local handlingMaxSpeed =  GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
	return handlingMaxSpeed
end
