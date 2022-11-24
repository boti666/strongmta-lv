local bitsuFont = dxCreateFont("files/fonts/bitsu.ttf", resp(14), false, "antialiased")

local engineState = false
local handBrakeState = false
local tempomatSpeed = false
local lockState = false
local windowState = false

local speedoColor = {255, 255, 255}
local speedoColor2 = {255, 255, 255}
local selectedSpeedoColor = {255, 255, 255}

local vehicleName = ""
local nitroLevel = 0

local consumptions = {}
local defaultConsumption = 1
local consumptionMultipler = 3
local consumptionValue = 0

local fuelTankSize = {}
local defaultFuelTankSize = 50
local outOfFuel = false
local fuelLevel = 0

local totalDistance = 0
local tripDistance = 0
local lastOilChange = 0

local vehicleUpdateTimer = false

local seatBeltState = false
local seatBeltChange = 0
local seatBeltIcon = true

local beltlessModels = {
	[472] = true,
	[473] = true,
	[493] = true,
	[595] = true,
	[484] = true,
	[430] = true,
	[453] = true,
	[452] = true,
	[446] = true,
	[454] = true,
	[581] = true,
	[509] = true,
	[481] = true,
	[462] = true,
	[521] = true,
	[463] = true,
	[510] = true,
	[522] = true,
	[461] = true,
	[448] = true,
	[468] = true,
	[586] = true,
	[432] = true,
	[531] = true,
	[583] = true,
}

local inReverseGear = false
local lastBeepStart = 0
local lastBeepStop = 0
local beepSounds = {}
local beepingTrucks = {
	[403] = true,
	[406] = true,
	[407] = true,
	[408] = true,
	[413] = true,
	[414] = true,
	[416] = true,
	[418] = true,
	[423] = true,
	[427] = true,
	[428] = true,
	[431] = true,
	[433] = true,
	[437] = true,
	[440] = true,
	[443] = true,
	[455] = true,
	[456] = true,
	[459] = true,
	[482] = true,
	[486] = true,
	[498] = true,
	[499] = true,
	[508] = true,
	[514] = true,
	[515] = true,
	[524] = true,
	[528] = true,
	[530] = true,
	[531] = true,
	[532] = true,
	[544] = true,
	[573] = true,
	[578] = true,
	[582] = true,
	[588] = true
}

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedres)
		if getResourceName(startedres) == "see_vehiclepanel" then
			consumptions = exports.see_vehiclepanel:getTheConsumptionTable()
			fuelTankSize = exports.see_vehiclepanel:getTheFuelTankTable()
		elseif startedres == getThisResource() then
			local see_vehiclepanel = getResourceFromName("see_vehiclepanel")

			if see_vehiclepanel and getResourceState(see_vehiclepanel) == "running" then
				consumptions = exports.see_vehiclepanel:getTheConsumptionTable()
				fuelTankSize = exports.see_vehiclepanel:getTheFuelTankTable()
			end

			loadVehicleData(localPlayer)
		end
	end)

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (player, seat)
		if player == localPlayer then
			setElementData(source, "tempomatSpeed", false)

			tempomatSpeed = false

			loadVehicleData(localPlayer)
		end

		if source == getPedOccupiedVehicle(localPlayer) and player ~= localPlayer and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local vehicleId = getElementData(source, "vehicle.dbID") or 0

			if vehicleId > 0 then
				updateVehicle(source, 0, vehicleId, getElementModel(source))
			end
		end
	end)

addEventHandler("onClientVehicleExit", getRootElement(),
	function (player, seat)
		if player == localPlayer then
			if seat == 0 then
				local vehicleId = getElementData(source, "vehicle.dbID") or 0
				local model = getElementModel(source)

				if vehicleId > 0 then
					updateVehicle(source, seat, vehicleId, model, true)
				end

				if beepingTrucks[model] then
					setElementData(source, "inReverseGear", false)
				end
			end

			if isTimer(vehicleUpdateTimer) then
				killTimer(vehicleUpdateTimer)
			end

			toggleNOS(false)

			engineState = false
			outOfFuel = false
		end
	end)

addEventHandler("onClientPlayerWasted", getRootElement(),
	function ()
		if source == localPlayer then
			local occupiedVehicle = getPedOccupiedVehicle(localPlayer)

			if getPedOccupiedVehicleSeat(localPlayer) == 0 then
				local vehicleId = getElementData(occupiedVehicle, "vehicle.dbID") or 0

				if vehicleId > 0 then
					updateVehicle(occupiedVehicle, getPedOccupiedVehicleSeat(localPlayer), vehicleId, getElementModel(occupiedVehicle))
				end
			end

			if isTimer(vehicleUpdateTimer) then
				killTimer(vehicleUpdateTimer)
			end

			toggleNOS(false)

			engineState = false
			outOfFuel = false
		end
	end)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if beepSounds[source] then
			if isElement(beepSounds[source]) then
				destroyElement(beepSounds[source])
			end

			beepSounds[source] = nil
		end

		if source == getPedOccupiedVehicle(localPlayer) then
			if isTimer(vehicleUpdateTimer) then
				killTimer(vehicleUpdateTimer)
			end

			toggleNOS(false)
		end
	end)

function loadVehicleData(player)
	local pedveh = getPedOccupiedVehicle(player)

	if pedveh then
		local pedseat = getPedOccupiedVehicleSeat(localPlayer)

		if pedseat < 2 then
			local vehicleModel = getElementModel(pedveh)

			fuelLevel = getElementData(pedveh, "vehicle.fuel") or 50
			engineState = getElementData(pedveh, "vehicle.engine") == 1
			totalDistance = getElementData(pedveh, "vehicle.distance") or 0
			lastOilChange = getElementData(pedveh, "lastOilChange") or 0
			handBrakeState = getElementData(pedveh, "vehicle.handBrake")
			tempomatSpeed = getElementData(pedveh, "tempomatSpeed")
			nitroLevel = getElementData(pedveh, "vehicle.nitroLevel") or 0
			lockState = getElementData(pedveh, "vehicle.locked") == 1
			windowState = getElementData(pedveh, "vehicle.windowState")
			speedoColor = getElementData(pedveh, "vehicle.speedoColor") or {255, 255, 255}
			speedoColor2 = getElementData(pedveh, "vehicle.speedoColor2") or {255, 255, 255}
			vehicleName = exports.see_vehiclenames:getCustomVehicleName(vehicleModel) or exports.see_infinity:getVehicleCustomName(getElementData(pedveh, "vehicleSpecialMod"))

			local capacity = fuelTankSize[vehicleModel] or defaultFuelTankSize

			setElementData(pedveh, "vehicle.maxFuel", capacity)

			if not fuelLevel or fuelLevel > capacity then
				setElementData(pedveh, "vehicle.fuel", capacity)
				fuelLevel = capacity
			end

			consumptionValue = 0
			outOfFuel = false

			if isTimer(vehicleUpdateTimer) then
				killTimer(vehicleUpdateTimer)
			end

			if getPedOccupiedVehicleSeat(player) == 0 then
				vehicleUpdateTimer = setTimer(updateVehicle, 60000, 0)
				toggleNOS(true)
			end
			
			seatBeltState = getElementData(localPlayer, "player.seatBelt")
			seatBeltChange = getTickCount()
			seatBeltIcon = true
		end
	end
end

function updateVehicle(vehicle, seat, dbID, model, save)
	if not vehicle then
		vehicle = getPedOccupiedVehicle(localPlayer)

		if vehicle and getPedOccupiedVehicleSeat(localPlayer) == 0 and getVehicleType(vehicle) ~= "BMX" then
			local vehicleId = getElementData(vehicle, "vehicle.dbID") or 0

			if vehicleId > 0 then
				local model = getElementModel(vehicle)
				local consumption = consumptions[model] or defaultConsumption
				local fuel = fuelLevel - consumptionValue / 10000 * consumption * consumptionMultipler

				if fuel < 0 then
					fuel = 0
				end

				triggerServerEvent("updateVehicle", localPlayer, vehicle, vehicleId, save, fuel, totalDistance + tripDistance, lastOilChange)
			end
		end
	elseif seat == 0 and dbID and model and getVehicleType(vehicle) ~= "BMX" then
		local model = getElementModel(vehicle)
		local consumption = consumptions[model] or defaultConsumption
		local fuel = fuelLevel - consumptionValue / 10000 * consumption * consumptionMultipler

		if fuel < 0 then
			fuel = 0
		end

		triggerServerEvent("updateVehicle", localPlayer, vehicle, dbID, save, fuel, totalDistance + tripDistance, lastOilChange)
	end
end

addEventHandler("onClientPreRender", getRootElement(),
	function (deltaTime)
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if pedveh and engineState and not outOfFuel then
			local speed = getVehicleSpeed(pedveh)
			local decimal = 1000 / deltaTime
			local distance = speed / 3600 / decimal

			if distance * 1000 >= 1 / decimal then
				consumptionValue = consumptionValue + distance * 1000
			else
				consumptionValue = consumptionValue + 1 / decimal
			end

			local model = getElementModel(pedveh)
			local consumption = consumptions[model] or defaultConsumption

			consumption = consumptionValue / 10000 * consumption * consumptionMultipler
			tripDistance = tripDistance + distance

			local pedseat = getPedOccupiedVehicleSeat(localPlayer)

			if getVehicleType(pedveh) == "Automobile" then
				lastOilChange = lastOilChange + distance * 1000

				if lastOilChange > 515000 and pedseat == 0 and getElementHealth(pedveh) > 321 then
					engineState = false
					setElementHealth(pedveh, 320)
					triggerServerEvent("setVehicleHealthSync", localPlayer, pedveh, 320)
					outputChatBox("#3d7abc[StrongMTA - Szerelő]:#FFFFFF Mivel nem cserélted ki a motorolajat, ezért az autód motorja elromlott!", 255, 255, 255, true)
				end
			end

			if fuelLevel - consumption <= 0 and pedseat == 0 then
				outOfFuel = true
				triggerServerEvent("ä}€[[€ÄŁ", localPlayer, pedveh)
				setElementData(pedveh, "vehicle.fuel", 0)
				setElementData(pedveh, "vehicle.engine", 0)
			end
		end

		if isElement(pedveh) and getVehicleController(pedveh) == localPlayer then
			if getVehicleType(pedveh) == "Automobile" then
				if getElementHealth(pedveh) <= 600 and math.random(100000) <= 20 and getVehicleEngineState(pedveh) then
					engineState = false
					setVehicleEngineState(pedveh, false)
					setElementData(pedveh, "vehicle.engine", 0)
					showInfobox("e", "Lefulladt a járműved!")
				end
			end
		end
	end)

local indicatorStates = {}

local leftIndicatorState = false
local rightIndicatorState = false

local vehicleIndicators = {}
local vehicleIndicatorTimers = {}
local vehicleIndicatorStates = {}
local vehicleLightStates = {}
local vehicleOverrideLights = {}

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix ( element )  -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z                               -- Return the transformed point
end

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if key == "mouse1" or key == "mouse2" or key == "F6" then
			if press then
				if not isCursorShowing() and not isConsoleActive() then
					local pedveh = getPedOccupiedVehicle(localPlayer)

					if pedveh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
						local vehtype = getVehicleType(pedveh)

						if vehtype == "Automobile" or vehtype == "Quad" then
							if key == "mouse1" then
								setElementData(pedveh, "rightIndicator", false)
			 					setElementData(pedveh, "leftIndicator", not getElementData(pedveh, "leftIndicator"))
							elseif key == "mouse2" then
								setElementData(pedveh, "leftIndicator", false)
								setElementData(pedveh, "rightIndicator", not getElementData(pedveh, "rightIndicator"))
							else
								setElementData(pedveh, "leftIndicator", false)
								setElementData(pedveh, "rightIndicator", false)
								setElementData(pedveh, "emergencyIndicator", not getElementData(pedveh, "emergencyIndicator"))
							end
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue, newValue)
		if dataName == "leftIndicator" then
			if not vehicleIndicators[source] then
				vehicleIndicators[source] = {}
			end

			if not vehicleLightStates[source] then
				vehicleLightStates[source] = {}

				for i = 0, 3 do
					vehicleLightStates[source][i] = 0
				end
			end

			if not vehicleOverrideLights[source] then
				local lightState = getElementData(source, "vehicle.light")

				if not lightState then
					vehicleOverrideLights[source] = 1
				else
					vehicleOverrideLights[source] = 2
				end
			end

			if getElementData(source, dataName) then
				vehicleIndicators[source].left = true

				vehicleLightStates[source][0] = getVehicleLightState(source, 0)
				vehicleLightStates[source][3] = getVehicleLightState(source, 3)
				vehicleOverrideLights[source] = getVehicleOverrideLights(source)

				setVehicleOverrideLights(source, 2)

				if not vehicleIndicatorTimers[source] then
					processIndicatorEffect(source)
					vehicleIndicatorTimers[source] = setTimer(processIndicatorEffect, 350, 0, source)

					vehicleLightStates[source][1] = getVehicleLightState(source, 1)
					vehicleLightStates[source][2] = getVehicleLightState(source, 2)
				end

				if vehicleOverrideLights[source] ~= 2 then
					setVehicleLightState(source, 1, 1)
					setVehicleLightState(source, 2, 1)
				end

				vehicleIndicatorStates[source] = true
			else
				vehicleIndicators[source].left = false

				setVehicleLightState(source, 0, vehicleLightStates[source][0] or 0)
				setVehicleLightState(source, 3, vehicleLightStates[source][3] or 0)

				if not vehicleIndicators[source].left then
					setVehicleOverrideLights(source, vehicleOverrideLights[source])

					setVehicleLightState(source, 1, vehicleLightStates[source][1] or 0)
					setVehicleLightState(source, 2, vehicleLightStates[source][2] or 0)

					if isTimer(vehicleIndicatorTimers[source]) then
						killTimer(vehicleIndicatorTimers[source])
						vehicleIndicatorTimers[source] = nil
					end

					vehicleIndicatorStates[source] = false
				end
			end
		end

		if dataName == "rightIndicator" then
			if not vehicleIndicators[source] then
				vehicleIndicators[source] = {}
			end

			if not vehicleLightStates[source] then
				vehicleLightStates[source] = {}

				for i = 0, 3 do
					vehicleLightStates[source][i] = 0
				end
			end

			if not vehicleOverrideLights[source] then
				local lightState = getElementData(source, "vehicle.light")

				if not lightState then
					vehicleOverrideLights[source] = 1
				else
					vehicleOverrideLights[source] = 2
				end
			end

			if getElementData(source, dataName) then
				vehicleIndicators[source].right = true

				vehicleLightStates[source][1] = getVehicleLightState(source, 1)
				vehicleLightStates[source][2] = getVehicleLightState(source, 2)
				vehicleOverrideLights[source] = getVehicleOverrideLights(source)

				setVehicleOverrideLights(source, 2)

				if not vehicleIndicatorTimers[source] then
					processIndicatorEffect(source)
					vehicleIndicatorTimers[source] = setTimer(processIndicatorEffect, 350, 0, source)

					vehicleLightStates[source][0] = getVehicleLightState(source, 0)
					vehicleLightStates[source][3] = getVehicleLightState(source, 3)
				end

				if vehicleOverrideLights[source] ~= 2 then
					setVehicleLightState(source, 0, 1)
					setVehicleLightState(source, 3, 1)
				end

				vehicleIndicatorStates[source] = true
			else
				vehicleIndicators[source].right = false

				setVehicleLightState(source, 1, vehicleLightStates[source][1] or 0)
				setVehicleLightState(source, 2, vehicleLightStates[source][2] or 0)

				if not vehicleIndicators[source].right then
					setVehicleOverrideLights(source, vehicleOverrideLights[source])
					setVehicleLightState(source, 0, vehicleLightStates[source][0] or 0)
					setVehicleLightState(source, 3, vehicleLightStates[source][3] or 0)

					if isTimer(vehicleIndicatorTimers[source]) then
						killTimer(vehicleIndicatorTimers[source])
						vehicleIndicatorTimers[source] = nil
					end

					vehicleIndicatorStates[source] = false
				end
			end
		end

		if dataName == "emergencyIndicator" then
			if not vehicleIndicators[source] then
				vehicleIndicators[source] = {}
			end

			if not vehicleLightStates[source] then
				vehicleLightStates[source] = {}

				for i = 0, 3 do
					vehicleLightStates[source][i] = 0
				end
			end

			if not vehicleOverrideLights[source] then
				local lightState = getElementData(source, "vehicle.light")

				if not lightState then
					vehicleOverrideLights[source] = 1
				else
					vehicleOverrideLights[source] = 2
				end
			end

			if getElementData(source, dataName) then
				vehicleIndicators[source].left = true
				vehicleIndicators[source].right = true

				for i = 0, 3 do
					vehicleLightStates[source][i] = getVehicleLightState(source, i)
				end

				vehicleOverrideLights[source] = getVehicleOverrideLights(source)

				setVehicleOverrideLights(source, 2)

				if not vehicleIndicatorTimers[source] then
					processIndicatorEffect(source)
					vehicleIndicatorTimers[source] = setTimer(processIndicatorEffect, 350, 0, source)
				end

				if vehicleOverrideLights[source] ~= 2 then
					for i = 0, 3 do
						setVehicleLightState(source, i, 1)
					end
				end

				vehicleIndicatorStates[source] = true
			else
				vehicleIndicators[source].left = false
				vehicleIndicators[source].right = false

				for i = 0, 3 do
					setVehicleLightState(source, i, vehicleLightStates[source][i] or 0)
				end

				setVehicleOverrideLights(source, vehicleOverrideLights[source])

				if isTimer(vehicleIndicatorTimers[source]) then
					killTimer(vehicleIndicatorTimers[source])
					vehicleIndicatorTimers[source] = nil
				end

				vehicleIndicatorStates[source] = false
			end
		end

		if dataName == "inReverseGear" then
			if isElement(beepSounds[source]) then
				destroyElement(beepSounds[source])
			end

			if getElementData(source, dataName) and isElementStreamedIn(source) then
				local x, y, z = getElementPosition(source)

				beepSounds[source] = pl
				aySound3D(":see_vehiclepanel/files/reverse.mp3", x, y, z, true)

				if isElement(beepSounds[source]) then
					setElementInterior(beepSounds[source], getElementInterior(source))
					setElementDimension(beepSounds[source], getElementDimension(source))
					attachElements(beepSounds[source], source)
				end
			end
		end

		if source == localPlayer and dataName == "player.seatBelt" then
			seatBeltState = getElementData(localPlayer, "player.seatBelt")
			seatBeltChange = getTickCount()
			seatBeltIcon = true
		end

		if isElement(source) and getPedOccupiedVehicle(localPlayer) == source then
			local dataValue = getElementData(source, dataName)

			if dataName == "vehicle.fuel" then
				if dataValue then
					fuelLevel = tonumber(dataValue)
					consumptionValue = 0

					if fuelLevel <= 0 then
						fuelLevel = 0
						outOfFuel = true

						triggerServerEvent("ä}€[[€ÄŁ", localPlayer, source)
						setElementData(source, "vehicle.fuel", 0)
						setElementData(source, "vehicle.engine", 0)

						if getVehicleController(source) == localPlayer then
							showInfobox("e", "Kifogyott az üzemanyag!")
						end
					else
						outOfFuel = false
					end
				end
			elseif dataName == "vehicle.distance" then
				if dataValue then
					totalDistance = tonumber(dataValue)
					tripDistance = 0
				end
			elseif dataName == "vehicle.nitroLevel" then
				if dataValue then
					nitroLevel = tonumber(dataValue)
				end
			elseif dataName == "vehicle.engine" then
				engineState = getElementData(source, "vehicle.engine") == 1
			elseif dataName == "vehicle.locked" then
				lockState = getElementData(source, "vehicle.locked") == 1
			elseif dataName == "vehicle.windowState" then
				windowState = getElementData(source, "vehicle.windowState")
			elseif dataName == "lastOilChange" then
				if dataValue then
					lastOilChange = tonumber(dataValue)
				end
			elseif dataName == "vehicle.handBrake" then
				handBrakeState = getElementData(source, "vehicle.handBrake")
			elseif dataName == "tempomatSpeed" then
				tempomatSpeed = getElementData(source, "tempomatSpeed")
			end
		end
	end)

function getBoardDatas(model)
	local consumption = consumptions[model] or defaultConsumption
	return math.floor(fuelLevel - consumptionValue / 10000 * consumption * consumptionMultipler), math.floor(totalDistance + tripDistance), lastOilChange
end

function getVehicleOverrideLightsEx(vehicle)
	if vehicleIndicators[vehicle] and (vehicleIndicators[vehicle].right or vehicleIndicators[vehicle].left) then
		return vehicleIndicatorStates[vehicle]
	end

	return getVehicleOverrideLights(vehicle)
end

function getVehicleSpeed(vehicle)
	if isElement(vehicle) then
		local vx, vy, vz = getElementVelocity(vehicle)
		return math.sqrt(vx*vx + vy*vy + vz*vz) * 187.5
	end
end

function round(number)
	return math.floor(number * 10 ^ 0 + 0.5) / 10 ^ 0
end

function getVehicleGear(vehicle, speed)
	if vehicle then
		local currentGear = getVehicleCurrentGear(vehicle)
		
		if handBrakeState then
			return "P"
		elseif speed == 0 or not getVehicleEngineState(vehicle) then
			return "N"
		else
			if currentGear == 0 then
				return "R"
			else
				return tostring(currentGear)
			end
		end
	end
end

local nitroState = false
local clickTick = 0

function toggleNOS(state)
	if state ~= nitroState then
		if state then
			bindKey("lctrl", "both", startNOS)
			nitroState = true
		else
			unbindKey("lctrl", "both", startNOS)
			nitroState = false

			local pedveh = getPedOccupiedVehicle(localPlayer)

			if pedveh then
				local upgrade = getVehicleUpgradeOnSlot(pedveh, 8)

				if type(upgrade) == "number" then
					removeVehicleUpgrade(pedveh, upgrade)
				end
			end
		end
	end
end

function startNOS(button, state)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	if pedveh then
		if state == "up" then
			removeVehicleUpgrade(pedveh, 1010)
			setPedControlState("vehicle_fire", false)
			triggerServerEvent("updateNitroLevel", localPlayer, pedveh, getElementData(pedveh, "vehicle.dbID"), nitroLevel)
		else
			clickTick = getTickCount()

			if nitroLevel > 0 then
				addVehicleUpgrade(pedveh, 1010)
				setPedControlState("vehicle_fire", true)
			end
		end
	end
end

addEventHandler("onClientPreRender", getRootElement(),
	function (timeSlice)
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if pedveh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local currentTime = getTickCount()

			if getPedControlState("vehicle_fire") then
				local upgrade = getVehicleUpgradeOnSlot(pedveh, 8)

				if type(upgrade) == "number" and upgrade ~= 0 then
					if nitroLevel > 0 then
						nitroLevel = nitroLevel - timeSlice / 1000 * 3
						
						if currentTime - clickTick > 20000 then
							removeVehicleUpgrade(pedveh, upgrade)
							addVehicleUpgrade(pedveh, upgrade)
							
							setPedControlState("vehicle_fire", false)
							setPedControlState("vehicle_fire", true)

							clickTick = currentTime
						end
					else
						nitroLevel = 0
						removeVehicleUpgrade(pedveh, 1010)
						setPedControlState("vehicle_fire", false)
					end
				end
			end
		end
	end)

render.nos = function (x, y)
	if getPedOccupiedVehicle(localPlayer) then
		local pedseat = getPedOccupiedVehicleSeat(localPlayer)

		if pedseat == 0 or pedseat == 1 then
			x = math.floor(x)
			y = math.floor(y)
	
			dxDrawImage(x, y, respc(256), respc(256), "speedo/images/nitro.png")

			local y2 = 33 * (1 - nitroLevel / 100)

			dxDrawImageSection(x, y + respc(y2), respc(256), respc(42) - respc(y2), 0, 0, 256, 42 - y2, "speedo/images/nitrolevel.png")

			return true
		end
	end

	return false
end

function math.round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

render.carname = function (x, y)
	if getPedOccupiedVehicle(localPlayer) then
		local pedseat = getPedOccupiedVehicleSeat(localPlayer)

		if pedseat == 0 or pedseat == 1 then
			x = math.floor(x)
			y = math.floor(y)

			dxDrawImageSection(x + respc(256) - respc(34), y, respc(256), respc(256), 0, 0, 256, 256, "speedo/images/name.png")
		
			if tempomatSpeed then
				dxDrawText(vehicleName .. " #DCA300(Tempomat: " .. math.round(tempomatSpeed) .. " km/h)", x, y, x + respc(231), y + respc(34), tocolor(255, 255, 255), 0.8, Roboto, "right", "center", false, false, false, true)
			else
				dxDrawText(vehicleName, x, y, x + respc(231), y + respc(34), tocolor(255, 255, 255), 0.8, Roboto, "right", "center")
			end

			return true
		end
	end

	return false
end

function renderSpeedoForTest(vehicle, color, colorId)
	if colorId == 7 then
		speedoColor = color
	else
		speedoColor2 = color
	end

	selectedSpeedoColor = color

	render.speedo(screenX / 2 - respc(128), screenY - respc(384))
end

addEvent("resetSpeedoColor", true)
addEventHandler("resetSpeedoColor", getRootElement(),
	function ()
		speedoColor = getElementData(source, "vehicle.speedoColor") or {255, 255, 255}
		speedoColor2 = getElementData(source, "vehicle.speedoColor2") or {255, 255, 255}
	end
)

addEvent("buySpeedoColor", true)
addEventHandler("buySpeedoColor", getRootElement(),
	function (colorId)
		if colorId == 7 then
			setElementData(source, "vehicle.speedoColor", selectedSpeedoColor)
		else
			setElementData(source, "vehicle.speedoColor2", selectedSpeedoColor)
		end

		speedoColor = getElementData(source, "vehicle.speedoColor") or {255, 255, 255}
		speedoColor2 = getElementData(source, "vehicle.speedoColor2") or {255, 255, 255}
	end)

render.speedo = function (x, y)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	if pedveh then
		local pedseat = getPedOccupiedVehicleSeat(localPlayer)

		if pedseat == 0 or pedseat == 1 then
			local model = getElementModel(pedveh)
			local speed = getVehicleSpeed(pedveh)

			x = math.floor(x)
			y = math.floor(y)

			local r, g, b = speedoColor[1], speedoColor[2], speedoColor[3]
			local r2, g2, b2 = speedoColor2[1], speedoColor2[2], speedoColor2[3]
			
			if speed > 280 then
				local progress = (speed - 280) / 40

				r, g, b = interpolateBetween(
					speedoColor[1], speedoColor[2], speedoColor[3],
					130, 60, 60,
					progress, "Linear")

				r2, g2, b2 = interpolateBetween(
					speedoColor2[1], speedoColor2[2], speedoColor2[3],
					215, 89, 89,
					progress, "Linear")
			end

			local sx, sy = respc(256), respc(256)
			local percentOfAngle = speed / 360

			if percentOfAngle > 1 then
				percentOfAngle = 1
			end

			local guageAngle = percentOfAngle * 256

			dxDrawImage(x, y, sx, sy, "speedo/images/base.png", 0, 0, 0, tocolor(255, 255, 255, 255))
	
			--if getVehicleOverrideLightsEx(pedveh) == 2 then
			--	--dxDrawImage(x, y, sx, sy, "speedo/images/baseglow.png", 0, 0, 0, tocolor(r, g, b, 125))
			--	--dxDrawImage(x, y, sx, sy, "speedo/images/num2.png", 0, 0, 0, tocolor(r, g, b, 125))
			--end

			dxDrawImage(x, y, sx, sy, "speedo/images/num.png", 0, 0, 0, tocolor(r, g, b))

			dxDrawText(math.floor((totalDistance + tripDistance) * 10) / 10 .. " km", x, y + respc(80), x + respc(256), y + respc(92), tocolor(75, 75, 75), 0.8, Roboto, "center", "center")
			
			local rot = -129 + guageAngle

			if rot > 129 then
				rot = 129
			end

			--dxDrawImage(x, y, sx, sy, "speedo/images/line.png", 0, 0, 0, tocolor(0, 0, 0))
			--dxDrawImage(x, y, sx, sy, "speedo/images/indicator.png", rot, 0, 0, tocolor(speedoColor2[1], speedoColor2[2], speedoColor2[3]))

			dxDrawText(math.floor(tostring(speed)), x, y + respc(116), x + respc(256), y + respc(142), tocolor(255, 255, 255), 0.8, Raleway, "center", "center")
			dxDrawText("KM/h", x, y + respc(116) + respc(52), x + respc(256), y + respc(142), tocolor(255, 255, 255), 0.6, Raleway, "center", "center")
			
			if getVehicleType(pedveh) == "Automobile" and not beltlessModels[model] then
				if not seatBeltState then
					if getTickCount() - seatBeltChange >= 750 then
						seatBeltChange = getTickCount()
						seatBeltIcon = not seatBeltIcon
					end
					
					if seatBeltIcon then
						dxDrawImage(x, y, sx, sy, "speedo/images/seatbelt1.png")
					else
						dxDrawImage(x, y, sx, sy, "speedo/images/seatbelt0.png")
					end
				else
					dxDrawImage(x, y, sx, sy, "speedo/images/seatbelt0.png")
				end
			end
			
			local gear = getVehicleGear(pedveh, speed)

			if pedseat == 0 then
				if gear == "R" then
					if not inReverseGear and beepingTrucks[model] and getTickCount() - lastBeepStop > 1000 then
						inReverseGear = true
						setElementData(pedveh, "inReverseGear", true)
						lastBeepStart = getTickCount()
					end
				else
					if inReverseGear and beepingTrucks[model] and getTickCount() - lastBeepStart > 1000 then
						inReverseGear = false
						setElementData(pedveh, "inReverseGear", false)
						lastBeepStop = getTickCount()
					end
				end
			end

			--dxDrawText(gear, x + respc(146), y + respc(116), x + respc(175), y + respc(142), tocolor(255, 255, 255), 0.75, bitsuFont, "center", "center")

			for i = 1, math.floor(guageAngle / 14.5) + 1 do
				dxDrawImage(x, y, sx, sy, "speedo/images/indicatorline.png", (i - 1) * 14.5, 0, 0, tocolor(r, g, b))
			end

			dxDrawImage(x, y, sx, sy, "speedo/images/indicatorline.png", guageAngle, 0, 0, tocolor(r, g, b))

			return true
		end
	end

	return false
end

render.speedoicon = function (x, y)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	if pedveh then
		local pedseat = getPedOccupiedVehicleSeat(localPlayer)

		if pedseat == 0 or pedseat == 1 then
			x = math.floor(x)
			y = math.floor(y)

			dxDrawImage(x, y, respc(256), respc(256), "speedo/images/icon.png")
	
			if lockState then
				dxDrawImageSection(x, y + respc(16), respc(20), respc(20), 0, 16, 20, 20, "speedo/images/iconglow.png")
			end

			if vehicleIndicators[pedveh] then
				if vehicleIndicators[pedveh].left and not vehicleIndicatorStates[pedveh] then
					dxDrawImageSection(x, y, respc(38), respc(17), 0, 0, 38, 17, "speedo/images/iconglow.png")
				end

				if vehicleIndicators[pedveh].right and not vehicleIndicatorStates[pedveh] then
					dxDrawImageSection(x + respc(60), y, respc(38), respc(17), 60, 0, 38, 17, "speedo/images/iconglow.png")
				end

				if vehicleIndicators[pedveh].left and vehicleIndicators[pedveh].right and not vehicleIndicatorStates[pedveh] then
					dxDrawImageSection(x, y, respc(38), respc(17), 0, 0, 38, 17, "speedo/images/iconglow.png")
					dxDrawImageSection(x + respc(60), y, respc(38), respc(17), 60, 0, 38, 17, "speedo/images/iconglow.png")
				end

			end

			if getElementHealth(pedveh) <= 550 then
				dxDrawImageSection(x + respc(23), y + respc(15), respc(30), respc(21), 23, 16, 30, 21, "speedo/images/iconglow.png")
			end

			if windowState then
				dxDrawImageSection(x + respc(55), y + respc(15), respc(20), respc(21), 55, 16, 20, 21, "speedo/images/iconglow.png")
			end

			if handBrakeState then
				dxDrawImageSection(x + respc(38), y, respc(22), respc(17), 38, 0, 22, 17, "speedo/images/iconglow.png")
			end

			if getVehicleOverrideLightsEx(pedveh) == 2 then
				dxDrawImageSection(x + respc(77), y + respc(15), respc(25), respc(21), 77, 16, 25, 21, "speedo/images/iconglow.png")
			end

			return true
		end
	end

	return false
end

RalewayE = dxCreateFont("files/fonts/RalewayE.ttf", resp(12), false, "antialiased")
RalewayB = dxCreateFont("files/fonts/RalewayB.ttf", resp(24), false, "antialiased")

local fuelMove = 0

render.fuel = function (x, y)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	if pedveh then
		local pedseat = getPedOccupiedVehicleSeat(localPlayer)

		if pedseat == 0 or pedseat == 1 then
			local model = getElementModel(pedveh)
			local speed = getVehicleSpeed(pedveh)

			x = math.floor(x + respc(75))
			y = math.floor(y + respc(75))

			local r, g, b = speedoColor[1], speedoColor[2], speedoColor[3]
			local r2, g2, b2 = 0, 0, 0
			
			if speed > 280 then
				local progress = (speed - 280) / 40

				r, g, b = interpolateBetween(
					speedoColor[1], speedoColor[2], speedoColor[3],
					215, 89, 89,
					progress, "Linear")

				r2, g2, b2 = interpolateBetween(
					0, 0, 0,
					215, 89, 89,
					progress, "Linear")
			end

			local currentFuel = fuelLevel - consumptionValue / 10000 * (consumptions[model] or defaultConsumption) * consumptionMultipler
			local fuelTankSize = fuelTankSize[model] or defaultFuelTankSize
			local fuelProgress = currentFuel / fuelTankSize

			if fuelProgress < 0.1 then
				r, g, b = 215, 89, 89
			end
			
			local y = y - resp(7)
			local multiValue = 1
			local hs = resp(128 - ((fuelProgress * 100) * 1.28))
			--dxDrawImageSection(x, y+hs/multiValue, resp(64), resp(64)-hs/multiValue, 0, 0, 512, moveHealth * 5.12, hudLines, 180, 0, 0, tocolor(152, 39, 8, 255))
			
			if fuelMove > currentFuel then 
				fuelMove = fuelMove - 1 
			end
			if fuelMove < currentFuel then 
				fuelMove = fuelMove + 1 
			end


			-- ** Fuel mérő fel-le mozgása
			--dxDrawImageSection(x, y+hs/multiValue, respc(128), respc(128)-hs/multiValue, 0, 0, 512, fuelMove * 5.12, "speedo/images/fuelbase.png", 0, 0, 0)

			--dxDrawImageSection(x, y, respc(256), respc(256), 74, 74, 256, 256, "speedo/images/fuelnum.png", 0, 0, 0, tocolor(r, g, b))
			--dxDrawImageSection(x, y, respc(128), respc(128), 0, 0, 128, 128, "speedo/images/fuelbase.png")
			dxDrawImageSection(x, y + hs / multiValue, resp(128), resp(128) - hs / multiValue, 0, 0, 128, (fuelProgress * 100) * 1.28, "speedo/images/fuelbase.png", 180, 0, 0)
			dxDrawImageSection(x, y, respc(128), respc(128), 0, 0, 128, 128, "speedo/images/fuelline.png")

			dxDrawText(math.floor(fuelProgress * 100) .. "%", x, y - respc(75), x + respc(128), y + respc(183), tocolor(180, 180, 180), 0.65, RalewayB, "center", "center")
			dxDrawText("üzemanyag", x, y - respc(75), x + respc(128), y + respc(222), tocolor(180, 180, 180), 0.7, RalewayE, "center", "center")

			local rot = -89 + 176 * fuelProgress
			local center = -(math.abs(90 - respc(256)) / 2)

			--dxDrawImageSection(x, y, respc(256), respc(256), 74, 74, 256, 256, "speedo/images/fuelindicator.png", rot, center, center, tocolor(speedoColor2[1], speedoColor2[2], speedoColor2[3]))

			return true
		end
	end

	return false
end

function processIndicatorEffect(vehicle)
	if isElement(vehicle) then
		if vehicleIndicators[vehicle].left then
			if vehicleLightStates[vehicle][0] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 0, 0)
				else
					setVehicleLightState(vehicle, 0, 1)
				end
			end

			if vehicleLightStates[vehicle][3] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 3, 0)
				else
					setVehicleLightState(vehicle, 3, 1)
				end
			end

			if vehicle == getPedOccupiedVehicle(localPlayer) then
				currentIndicatorState = vehicleIndicatorStates[vehicle]
			end
		end

		if vehicleIndicators[vehicle].right then
			if vehicleLightStates[vehicle][1] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 1, 0)
				else
					setVehicleLightState(vehicle, 1, 1)
				end
			end

			if vehicleLightStates[vehicle][2] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 2, 0)
				else
					setVehicleLightState(vehicle, 2, 1)
				end
			end

			if vehicle == getPedOccupiedVehicle(localPlayer) then
				currentIndicatorState = vehicleIndicatorStates[vehicle]
			end
		end

		if vehicle == getPedOccupiedVehicle(localPlayer) and vehicleIndicatorStates[vehicle] then
			playSound(":see_vehiclepanel/files/turnsignal.mp3")
		end

		vehicleIndicatorStates[vehicle] = not vehicleIndicatorStates[vehicle]
	else
		killTimer(sourceTimer)
	end
end