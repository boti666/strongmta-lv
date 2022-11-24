local MAX_STEERING_ANGLE = 60
local STEERING_DURATION = 200

local MIN_WIPER_ANGLE = 120
local MAX_WIPER_ANGLE = 60
local MIN_WIPER_DURATION = 600
local MAX_WIPER_DURATION = 500

local steerInterpolation = {}
local steeringValue = {}
local steeringState = {}
local steeringLookup = {
	[477] = true,
	[491] = true,
	[603] = true,
	[415] = true,
	[587] = true,
	[547] = true,
	[494] = true,
	[602] = true,
	[600] = true,
	[410] = true,
	[475] = true,
	[485] = true,
}

local spoilerValue = {}
local spoilerState = {}
local spoilerInterpolation = {}
local spoilerOverride = {}
local spoilerOffsets = {
	[506] = -30,
	[415] = -17,
	[494] = -20,
	[429] = -25,
	[451] = -25,
	[502] = -7,
	[485] = -3,
	[503] = -25,
	[516] = -25,
}

local headlightAnimation = {}

local wiperState = {}
local wiperInterpolation = {}
local wiperLookup = {
	[477] = true,
	[491] = true,
	[602] = true
}

local engineState = false

local dashboardLookup = {
	[485] = true,
	[477] = true,
	[491] = true,
	[603] = true,
	[415] = true,
	[587] = true,
	[494] = true,
	[602] = true,
	[410] = true,
	[475] = true
}

local speedoDegrees = {
	[485] = true,
	[477] = 360,
	[491] = 280,
	[603] = 241,
	[415] = 420,
	[587] = 320,
	[494] = 360,
	[602] = 280,
	[410] = 120,
	[475] = 193
}

local fuelDegrees = {
	[491] = 85,
	[603] = 45,
	[547] = 82,
	[602] = 87,
	[410] = 62.5,
	[587] = 80
}

local tahometerValue = 0
local tahometerInterpolation = false

local gaugesList = {"oil", "volts", "ampers", "temperature", "petrolok"}
local gaugeInterpolation = false
local gaugeValues = {}
local gaugeMultiplers = {
	[603] = 0.5,
	[547] = 0.8
}

function setGauges(vehicle)
	local vehicle = getPedOccupiedVehicle(localPlayer)

	if vehicle then
		local model = getElementModel(vehicle)

		if getElementData(vehicle, "vehicle.engine") == 1 then
			local gaugeFactor = gaugeMultiplers[model] or 1
			local currentFuel = getElementData(vehicle, "vehicle.fuel")
			local maxFuel = getElementData(vehicle, "vehicle.maxFuel") or 50
			local fuelFactor = (currentFuel or maxFuel) / maxFuel

			gaugeInterpolation = {
				tick = getTickCount(),
				oil = math.random(30, 60) * gaugeFactor,
				volts = math.random(30, 60) * gaugeFactor,
				ampers = math.random(30, 60) * gaugeFactor,
				temperature = math.random(30, 60) * gaugeFactor,
				petrolok = (fuelDegrees[model] or 100) * fuelFactor
			}

			engineState = true
			tahometerInterpolation = {getTickCount(), 650, tahometerValue}
		else
			gaugeInterpolation = {
				tick = getTickCount(),
				oil = 0,
				volts = 0,
				ampers = 0,
				temperature = 0,
				petrolok = 0
			}

			engineState = false
			tahometerInterpolation = {getTickCount(), 0, tahometerValue}
		end
	end
end

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (enterPlayer)
		if enterPlayer == localPlayer then
			local model = getElementModel(source)

			if dashboardLookup[model] then
				if getElementData(source, "vehicle.engine") == 1 then
					local gaugeFactor = gaugeMultiplers[model] or 1
					local currentFuel = getElementData(source, "vehicle.fuel")
					local maxFuel = getElementData(source, "vehicle.maxFuel") or 50
					local fuelFactor = (currentFuel or maxFuel) / maxFuel

					gaugeValues = {
						oil = math.random(30, 60) * gaugeFactor,
						volts = math.random(30, 60) * gaugeFactor,
						ampers = math.random(30, 60) * gaugeFactor,
						temperature = math.random(30, 60) * gaugeFactor,
						petrolok = (fuelDegrees[model] or 100) * fuelFactor
					}

					for k in pairs(gaugeValues) do
						setVehicleComponentRotation(source, k, 0, gaugeValues[k] or 0, 0)
					end

					engineState = true
				else
					gaugeValues = {
						oil = 0,
						volts = 0,
						ampers = 0,
						temperature = 0,
						petrolok = 0
					}

					engineState = false
				end

				for i = 1, #gaugesList do
					local gaugeName = gaugesList[i]

					if getVehicleComponentRotation(source, gaugeName) then
						setVehicleComponentRotation(source, gaugeName, 0, gaugeValues[gaugeName] or 0, 0)
					end
				end
			end
		end
	end
)

function getVehicleSpeed(vehicle)
	if isElement(vehicle) then
		local velX, velY, velZ = getElementVelocity(vehicle)
		return math.sqrt(velX * velX + velY * velY + velZ * velZ) * 187.5
	end
end

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "vehicle.fuel" then
			if source == getPedOccupiedVehicle(localPlayer) then
				local model = getElementModel(source)

				if dashboardLookup[model] then
					local currentFuel = getElementData(source, "vehicle.fuel")
					local maxFuel = getElementData(source, "vehicle.maxFuel") or 50
					local fuelFactor = (currentFuel or maxFuel) / maxFuel

					gaugeValues.petrolok = (fuelDegrees[model] or 100) * fuelFactor

					if getVehicleComponentRotation(source, "petrolok") then
						setVehicleComponentRotation(source, "petrolok", 0, gaugeValues.petrolok or 0, 0)
					end
				end
			end
		end

		if dataName == "vehicle.engine" then
			if source == getPedOccupiedVehicle(localPlayer) then
				setGauges()
			end
		end

		if dataName == "spoilerOverride" then
			spoilerOverride[source] = getElementData(source, dataName)
		end

		if dataName == "wiperState" then
			wiperState[source] = getElementData(source, dataName)

			if wiperState[source] then
				if not wiperInterpolation[source] then
					wiperInterpolation[source] = {getTickCount(), false}
				end
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("vehicle")) do
			spoilerOverride[v] = getElementData(v, "spoilerOverride")
			wiperState[v] = getElementData(v, "wiperState")

			if wiperState[v] then
				wiperInterpolation[v] = {getTickCount(), false}
			else
				wiperInterpolation[v] = nil
				setVehicleComponentRotation(v, "dvorleft", 0, 0, 0)
				setVehicleComponentRotation(v, "dvorright", 0, 0, 0)
			end
		end
	end
)

bindKey("p", "down",
	function ()
		local currentVehicle = getPedOccupiedVehicle(localPlayer)

		if currentVehicle then
			if getPedOccupiedVehicleSeat(localPlayer) == 0 then
				local model = getElementModel(currentVehicle)

				if wiperLookup[model] then
					if getElementData(currentVehicle, "wiperState") then
						setElementData(currentVehicle, "wiperState", nil)
						exports.see_chat:localActionC(localPlayer, "kikapcsolja az ablaktörlőt.")
					else
						setElementData(currentVehicle, "wiperState", true)
						exports.see_chat:localActionC(localPlayer, "bekapcsolja az ablaktörlőt.")
					end
				end
			end
		end
	end
)

bindKey("num_5", "down",
	function ()
		local currentVehicle = getPedOccupiedVehicle(localPlayer)

		if currentVehicle then
			if getPedOccupiedVehicleSeat(localPlayer) == 0 then
				local model = getElementModel(currentVehicle)

				if spoilerOffsets[model] then
					if not spoilerInterpolation[currentVehicle] then
						if getVehicleSpeed(currentVehicle) <= 50 then
							if getElementData(currentVehicle, "spoilerOverride") then
								setElementData(currentVehicle, "spoilerOverride", nil)
							else
								setElementData(currentVehicle, "spoilerOverride", true)
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local vehicles = getElementsByType("vehicle", getRootElement(), true)
		local currentTick = getTickCount()

		for i = 1, #vehicles do
			local vehicle = vehicles[i]
			local model = getElementModel(vehicle)

			if model == 475 then
				local x1, y1, z1 = getVehicleComponentRotation(vehicle, "movheadlights")

				if x1 then
					if getVehicleOverrideLights(vehicle) == 2 then
						if compRotX ~= 57.5 then
							if not headlightAnimation[vehicle] or not headlightAnimation[vehicle][4] then
								headlightAnimation[vehicle] = {currentTick, math.abs(57.5 - x1) / 57.5 * 650, x1, true}
							end

							local elapsedTime = currentTick - headlightAnimation[vehicle][1]
							local progress = (currentTick - headlightAnimation[vehicle][1]) / headlightAnimation[vehicle][2]
							local x = interpolateBetween(headlightAnimation[vehicle][3], 0, 0, 57.5, 0, 0, progress, "InOutQuad")

							setVehicleComponentRotation(vehicle, "movheadlights", x, y1, z1)
						end
					else
						if x1 ~= 0 then
							if not headlightAnimation[vehicle] or headlightAnimation[vehicle][4] then
								headlightAnimation[vehicle] = {currentTick, math.abs(0 - x1) / 57.5 * 650, x1, false}
							end

							local elapsedTime = currentTick - headlightAnimation[vehicle][1]
							local progress = elapsedTime / headlightAnimation[vehicle][2]
							local x = interpolateBetween(headlightAnimation[vehicle][3], 0, 0, 0, 0, 0, progress, "InOutQuad")

							setVehicleComponentRotation(vehicle, "movheadlights", x, y1, z1)
						end
					end
				end
			end

			if spoilerOffsets[model] then
				if getVehicleSpeed(vehicle) >= 200 or spoilerOverride[vehicle] then
					if not spoilerState[vehicle] then
						local startValue = spoilerValue[vehicle] or 0
						spoilerState[vehicle] = true
						spoilerInterpolation[vehicle] = {currentTick, startValue, math.abs(startValue - spoilerOffsets[model]) * 1500 / math.abs(spoilerOffsets[model])}
					end

					if not spoilerInterpolation[vehicle] then
						setVehicleComponentRotation(vehicle, "movspoiler", spoilerOffsets[model], 0, 0)
					else
						local elapsedTime = currentTick - spoilerInterpolation[vehicle][1]
						local progress = elapsedTime / spoilerInterpolation[vehicle][3]

						spoilerValue[vehicle] = interpolateBetween(spoilerInterpolation[vehicle][2], 0, 0, spoilerOffsets[model], 0, 0, progress, "InOutQuad")
						setVehicleComponentRotation(vehicle, "movspoiler", spoilerValue[vehicle], 0, 0)

						if progress > 1.1 then
							spoilerInterpolation[vehicle] = nil
						end
					end
				else
					if spoilerState[vehicle] then
						local startValue = spoilerValue[vehicle] or 0
						spoilerState[vehicle] = nil
						spoilerInterpolation[vehicle] = {currentTick, startValue, math.abs(startValue) * 1500 / math.abs(spoilerOffsets[model])}
					end

					if not spoilerInterpolation[vehicle] then
						setVehicleComponentRotation(vehicle, "movspoiler", 0, 0, 0)
					else
						local elapsedTime = currentTick - spoilerInterpolation[vehicle][1]
						local progress = elapsedTime / spoilerInterpolation[vehicle][3]

						spoilerValue[vehicle] = interpolateBetween(spoilerInterpolation[vehicle][2], 0, 0, 0, 0, 0, progress, "InOutQuad")
						setVehicleComponentRotation(vehicle, "movspoiler", spoilerValue[vehicle], 0, 0)

						if progress > 1.1 then
							spoilerInterpolation[vehicle] = nil
							spoilerValue[vehicle] = nil
						end
					end
				end
			end

			if steeringLookup[model] then
				local controllerPlayer = getVehicleController(vehicle)

				if isElement(controllerPlayer) then
					if not steeringValue[vehicle] then
						steeringValue[vehicle] = 0
					end

					local state = "middle"
					local degrees = 0

					if getPedControlState(controllerPlayer, "vehicle_left") then
						state = "left"
						degrees = -MAX_STEERING_ANGLE
					elseif getPedControlState(controllerPlayer, "vehicle_right") then
						state = "right"
						degrees = MAX_STEERING_ANGLE
					end

					if steeringState[vehicle] ~= state then
						steeringState[vehicle] = state

						steerInterpolation[vehicle] = {currentTick, steeringValue[vehicle], degrees}
						steerInterpolation[vehicle][4] = math.abs(steerInterpolation[vehicle][2] - steerInterpolation[vehicle][3]) / MAX_STEERING_ANGLE * STEERING_DURATION

						if steerInterpolation[vehicle][4] <= 0 then
							steerInterpolation[vehicle][4] = 0.1
						end
					end

					if steerInterpolation[vehicle] then
						local elapsedTime = currentTick - steerInterpolation[vehicle][1]
						local progress = elapsedTime / steerInterpolation[vehicle][4]

						steeringValue[vehicle] = interpolateBetween(steerInterpolation[vehicle][2], 0, 0, steerInterpolation[vehicle][3], 0, 0, progress, "Linear")

						if progress > 1 then
							steerInterpolation[vehicle] = nil
						end
					end
				else
					steeringValue[vehicle] = 0
				end

				setVehicleComponentRotation(vehicle, "movsteer_1.0", 0, steeringValue[vehicle], 0)
			end

			if wiperInterpolation[vehicle] then
				local rotationAngle = MAX_WIPER_ANGLE
				local rotationDuration = MAX_WIPER_DURATION
				local wiperCounter = 0

				if getVehicleComponentRotation(vehicle, "dvorleft") then
					wiperCounter = wiperCounter + 1
				end

				if getVehicleComponentRotation(vehicle, "dvorright") then
					wiperCounter = wiperCounter + 1
				end

				if wiperCounter < 2 then
					rotationAngle = MIN_WIPER_ANGLE
					rotationDuration = MIN_WIPER_DURATION
				end

				local elapsedTime = currentTick - wiperInterpolation[vehicle][1]
				local progress = elapsedTime / rotationDuration
				local rotationValue = 0

				if wiperInterpolation[vehicle][2] then
					rotationValue = interpolateBetween(rotationAngle, 0, 0, 0, 0, 0, progress, "InOutQuad")
				else
					rotationValue = interpolateBetween(0, 0, 0, rotationAngle, 0, 0, progress, "InOutQuad")
				end

				if progress > 1 then
					if wiperInterpolation[vehicle] then
						wiperInterpolation[vehicle] = {currentTick, not wiperInterpolation[vehicle][2]}

						if not wiperInterpolation[vehicle][2] then
							if not wiperState[vehicle] then
								wiperInterpolation[vehicle] = nil
							end
						end
					end
				end

				setVehicleComponentRotation(vehicle, "dvorleft", 0, -rotationValue, 0)
				setVehicleComponentRotation(vehicle, "dvorright", 0, -rotationValue, 0)
			end
		end

		local currentVehicle = getPedOccupiedVehicle(localPlayer)

		if isElement(currentVehicle) then
			local vehicleModel = getElementModel(currentVehicle)

			if dashboardLookup[vehicleModel] then
				-- Mérők
				if gaugeInterpolation then
					for i = 1, #gaugesList do
						local gaugeName = gaugesList[i]

						if getVehicleComponentRotation(currentVehicle, gaugeName) then
							local progress = (currentTick - gaugeInterpolation.tick) / 1200

							gaugeValues[gaugeName] = interpolateBetween(gaugeValues[gaugeName] or 0, 0, 0, gaugeInterpolation[gaugeName], 0, 0, progress, "InOutQuad")
							setVehicleComponentRotation(currentVehicle, gaugeName, 0, gaugeValues[gaugeName] or 0, 0)

							if progress > 1 then
								gaugeInterpolation = false
								break
							end
						end
					end
				end

				-- Sebességmérő
				local currentSpeed = getVehicleSpeed(currentVehicle)
				local speedFactor = currentSpeed / 360

				if speedFactor > 1 then
					speedFactor = 1
				elseif speedFactor < 0 then
					speedFactor = 0
				end

				setVehicleComponentRotation(currentVehicle, "speedook", 0, speedFactor * (speedoDegrees[vehicleModel] or 240), 0)

				-- Fordulatszámmérő
				local tahometerX, tahometerY, tahometerZ = getVehicleComponentRotation(currentVehicle, "tahook")

				if tahometerX then
					if getElementData(currentVehicle, "vehicle.engine") == 1 then
						tahometerValue = getVehicleRPM(currentVehicle)

						local rpmFactor = tahometerValue / 9900
						if rpmFactor > 1 then
							rpmFactor = 1
						end

						setVehicleComponentRotation(currentVehicle, "tahook", 0, 220 * rpmFactor, 0)
					else
						setVehicleComponentRotation(currentVehicle, "tahook", 0, 0, 0)
					end

					if tahometerInterpolation then
						local progress = (currentTick - tahometerInterpolation[1]) / 650

						tahometerValue = interpolateBetween(tahometerInterpolation[3] or 0, 0, 0, tahometerInterpolation[2], 0, 0, progress, "InOutQuad")

						if progress > 1 then
							tahometerInterpolation = false
						end

						setVehicleComponentRotation(currentVehicle, "tahook", 0, 220 * (tahometerValue / 9900), 0)
					end
				end
			end
		end
	end
)

function getVehicleRPM(vehicle)
	local rpm = 0

	if vehicle then
		if getVehicleEngineState(vehicle) then
			local currentGear = getVehicleCurrentGear(vehicle)
			local currentSpeed = getVehicleSpeed(vehicle)

			if currentGear > 0 then
				rpm = math.floor(((currentSpeed / currentGear) * 160) + 0.5)

				if rpm < 650 then
					rpm = math.random(650, 750)
				elseif rpm >= 9000 then
					rpm = math.random(9000, 9900)
				end
			else
				rpm = math.floor((currentSpeed * 160) + 0.5)

				if rpm < 650 then
					rpm = math.random(650, 750)
				elseif rpm >= 9000 then
					rpm = math.random(9000, 9900)
				end
			end
		else
			rpm = 0
		end

		return tonumber(rpm)
	else
		return 0
	end
end
