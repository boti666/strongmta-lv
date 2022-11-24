local screenX, screenY = guiGetScreenSize()

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
	--[506] = -30,
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
local JourneyDoorAnimation = {}
local JourneySunVisorAnimation = {}
local JourneySunVisorRodAnimation = {}

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

local AmgSpoiler = {}
local AmgSpoiler2 = {}
local AmgOneID = exports.see_infinity:getVehicleModel("amgone")

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

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local theVeh = getPedOccupiedVehicle(localPlayer)

			if getElementModel(theVeh) == 508 then
				local state = getElementData(theVeh, "JourneyDoor")
				local state2 = getElementData(theVeh, "JourneyRoof")

				if state or state2 then
					local task = getPedSimplestTask(localPlayer)

					if task == "TASK_SIMPLE_CAR_GET_OUT" or task == "TASK_SIMPLE_CAR_CLOSE_DOOR_FROM_OUTSIDE" then
						return
					end

					local keys = {}

					for k, v in pairs(getBoundKeys("accelerate")) do
						table.insert(keys, k)
					end

					for k, v in pairs(getBoundKeys("brake_reverse")) do
						table.insert(keys, k)
					end

					for k, v in pairs(keys) do
						if v == key then
							cancelEvent()

							if press then
								exports.see_hud:showInfobox("e", "Előbb rakd alaphelyzetbe a komponenseket!")
							end
						end
					end
				end
			end
		end
	end
)


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

addEventHandler("onClientElementStreamOut", getRootElement(),
	function()
		if getElementModel(source) == 508 then
			DestroyObject(source)
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function()
		if getElementModel(source) == 508 then
			DestroyObject(source)
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for k, v in ipairs(getElementsByType("vehicle")) do
			if isElementStreamedIn(v) then
				local State = getElementData(v, "JourneyChair") 

				if not State then
					State = 0
				end

				chairGetOut(v, State)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function()
		if getElementModel(source) == 508 then
			local State = getElementData(source, "JourneyChair") 

			if not State then
				State = 0
			end

			chairGetOut(source, State)
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		
		if dataName == "JourneyChair" then
			if isElementStreamedIn(source) then
				local State = getElementData(source, "JourneyChair") 

				if not State then
					State = 0
				end

				chairGetOut(source, State)
			end
		end

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

				if spoilerOffsets[model] or model == AmgOneID then
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

addEventHandler("onClientClick", getRootElement(),
	function(key, state, x, y, wx, wy, wz, element)
		if element then
			if state == "down" then
				if key == "left" then
					if activeButton then
						if activeButton[2] == "door" then
							local DoorState = getElementData(activeButton[1], "JourneyDoor")

							setElementData(activeButton[1], "JourneyDoor", not DoorState)
						elseif activeButton[2] == "roof" then
							local DoorState = getElementData(activeButton[1], "JourneyRoof")

							setElementData(activeButton[1], "JourneyRoof", not DoorState)

							--DestroyObject(activeButton[1])
							setElementData(activeButton[1], "JourneyChair", 0)
						elseif activeButton[2] == "chair" then
							local ChairState = getElementData(activeButton[1], "JourneyChair")

							if not ChairState then
								ChairState = 0
							end

							if ChairState >= 3 then
								ChairState = 0
							end

							setElementData(activeButton[1], "JourneyChair", ChairState + 1)
						end
					end
				end
			end
		end
	end
)

local JourneyDoorAnim = {}
local JourneyRoofAnim = {}

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
			elseif model == 508 then
				if isPedInVehicle(localPlayer) then 
					return  
				end
				local relX, relY = getCursorPosition()
				local absX, absY = -1, -1

				if relX then
					absX = relX * screenX
					absY = relY * screenY
				end

				local px, py, pz = getElementPosition(localPlayer)

				local x, y, z = getPositionFromElementOffset(vehicle, 1.5, 0, 1.3)
				local dist = getDistanceBetweenPoints3D(px, py, pz, x, y, z)

				activeButton = {}

				if dist <= 2 then
					local x, y = getScreenFromWorldPosition(x, y, z)

					if x and y then
						local oneSize = 48
						local x = x - oneSize / 2
						local y = y - oneSize / 2

						local pictureColor = tocolor(255, 255, 255)
						local pictureColor2 = tocolor(255, 255, 255)
						local pictureColor3 = tocolor(255, 255, 255)

						if JourneyDoorAnim[vehicle] or JourneyRoofAnim[vehicle] then
							pictureColor = tocolor(215, 89, 89, 150)
							pictureColor2 = tocolor(215, 89, 89, 150)
							pictureColor3 = tocolor(215, 89, 89, 150)
						else
							if absX >= x and absX <= x + oneSize and absY >= y and absY <= y + oneSize then
								pictureColor = tocolor(61, 122, 188)
								activeButton = {vehicle, "door"}
							elseif absX >= x and absX <= x + oneSize and absY >= y + oneSize + 4 and absY <= y + oneSize + 4 + oneSize then
								pictureColor2 = tocolor(61, 122, 188)
								activeButton = {vehicle, "roof"}
							elseif absX >= x and absX <= x + oneSize and absY >= y + (oneSize + 4) * 2 and absY <= y + (oneSize + 4) * 2 + oneSize then
								pictureColor3 = tocolor(61, 122, 188)
								activeButton = {vehicle, "chair"}
							end
						end

						dxDrawRectangle(x, y, oneSize, oneSize, tocolor(0, 0, 0, 150))
						dxDrawRectangle(x, y + oneSize + 4, oneSize, oneSize, tocolor(0, 0, 0, 150))

						
						if getElementData(vehicle, "JourneyDoor") then
							dxDrawImage(x, y, oneSize, oneSize, "files/doorclose.png", 0, 0, 0, pictureColor)
						else
							dxDrawImage(x, y, oneSize, oneSize, "files/dooropen.png", 0, 0, 0, pictureColor)
						end

						if getElementData(vehicle, "JourneyRoof") then
							dxDrawImage(x, y + oneSize + 4, oneSize, oneSize, "files/roofin.png", 0, 0, 0, pictureColor2)

							dxDrawRectangle(x, y + (oneSize + 4) * 2, oneSize, oneSize, tocolor(0, 0, 0, 150))
							dxDrawImage(x, y + (oneSize + 4) * 2, oneSize, oneSize, "files/chair.png", 0, 0, 0, pictureColor3)
						else
							dxDrawImage(x, y + oneSize + 4, oneSize, oneSize, "files/roofout.png", 0, 0, 0, pictureColor2)
						end
					end
				end

				local x1, y1, z1 = getVehicleComponentRotation(vehicle, "doorside")

				if z1 then
					if getElementData(vehicle, "JourneyDoor") then
						if z1 ~= 90 then
							if not JourneyDoorAnimation[vehicle] or not JourneyDoorAnimation[vehicle][4] then
								JourneyDoorAnimation[vehicle] = {currentTick, math.abs(90 - z1) / 90 * 3000, z1, true}
							end

							local elapsedTime = currentTick - JourneyDoorAnimation[vehicle][1]
							local progress = (currentTick - JourneyDoorAnimation[vehicle][1]) / JourneyDoorAnimation[vehicle][2]
							local x = interpolateBetween(JourneyDoorAnimation[vehicle][3], 0, 0, 90, 0, 0, progress, "InOutQuad")

							setVehicleComponentRotation(vehicle, "doorside", x1, y1, x)

							if progress >= 1 then
								JourneyDoorAnim[vehicle] = false
							else
								JourneyDoorAnim[vehicle] = true
							end
						end
					else
						if z1 ~= 0 then
							if not JourneyDoorAnimation[vehicle] or JourneyDoorAnimation[vehicle][4] then
								JourneyDoorAnimation[vehicle] = {currentTick, math.abs(0 - z1) / 90 * 3000, z1, false}
							end

							local elapsedTime = currentTick - JourneyDoorAnimation[vehicle][1]
							local progress = elapsedTime / JourneyDoorAnimation[vehicle][2]
							local x = interpolateBetween(JourneyDoorAnimation[vehicle][3], 0, 0, 0, 0, 0, progress, "InOutQuad")

							setVehicleComponentRotation(vehicle, "doorside", x1, y1, x)

							if progress >= 1 then
								JourneyDoorAnim[vehicle] = false
							else
								JourneyDoorAnim[vehicle] = true
							end
						end
					end
				end

				local x2, y2, z2 = getVehicleComponentPosition(vehicle, "sunvisor")
				local x3, y3, z3 = getVehicleComponentPosition(vehicle, "sunvisor_moving_rod")
				local rx2, ry2, rz2 = getVehicleComponentRotation(vehicle, "sunvisor")
				local sX, sY, sZ = getVehicleComponentScale(vehicle, "sunvisor_moving_rod")

				if x2 then
					if getElementData(vehicle, "JourneyRoof") then
						if x2 ~= 3.5 then
							if not JourneySunVisorAnimation[vehicle] or not JourneySunVisorAnimation[vehicle][4] then
								JourneySunVisorAnimation[vehicle] = {currentTick, math.abs(3.5 - x2) / 3.5 * 5000, x2, true, ry2, z2, x3, sZ, z3}
							end

							local elapsedTime = currentTick - JourneySunVisorAnimation[vehicle][1]
							local progress = (currentTick - JourneySunVisorAnimation[vehicle][1]) / JourneySunVisorAnimation[vehicle][2]
							local x, ry, z = interpolateBetween(JourneySunVisorAnimation[vehicle][3], JourneySunVisorAnimation[vehicle][5], JourneySunVisorAnimation[vehicle][6], 3, 10, -0.4, progress, "InOutQuad")
							local x4, scale, plus = interpolateBetween(JourneySunVisorAnimation[vehicle][7], JourneySunVisorAnimation[vehicle][8], JourneySunVisorAnimation[vehicle][9], 3.4, 1.5, -1.52, progress, "InOutQuad")

							setVehicleComponentPosition(vehicle, "sunvisor", x, y2, z)
							setVehicleComponentRotation(vehicle, "sunvisor", rx2, ry, rz2)
							setVehicleComponentPosition(vehicle, "sunvisor_moving_rod", x4, y3, plus)
							setVehicleComponentScale(vehicle, "sunvisor_moving_rod", sX, sY, scale)

							if progress >= 1 then
								JourneyRoofAnim[vehicle] = false
							else
								JourneyRoofAnim[vehicle] = true
							end
						end
					else
						if x2 ~= 0 then
							if not JourneySunVisorAnimation[vehicle] or JourneySunVisorAnimation[vehicle][4] then
								JourneySunVisorAnimation[vehicle] = {currentTick, math.abs(0 - x2) / 3.5 * 5000, x2, false, ry2, z2, x3, sZ, z3}
							end

							local elapsedTime = currentTick - JourneySunVisorAnimation[vehicle][1]
							local progress = elapsedTime / JourneySunVisorAnimation[vehicle][2]
							local x, ry, z = interpolateBetween(JourneySunVisorAnimation[vehicle][3], JourneySunVisorAnimation[vehicle][5], JourneySunVisorAnimation[vehicle][6], 1.35, 0, -0.1, progress, "InOutQuad")
							local x4, scale, plus = interpolateBetween(JourneySunVisorAnimation[vehicle][7], JourneySunVisorAnimation[vehicle][8], JourneySunVisorAnimation[vehicle][9], 1.35, 1, 0, progress, "InOutQuad")

							setVehicleComponentPosition(vehicle, "sunvisor", x, y2, z)
							setVehicleComponentRotation(vehicle, "sunvisor", rx2, ry, rz2)
							setVehicleComponentPosition(vehicle, "sunvisor_moving_rod", x4, y3, plus)
							setVehicleComponentScale(vehicle, "sunvisor_moving_rod", sX, sY, scale)

							if progress >= 1 then
								JourneyRoofAnim[vehicle] = false
							else
								JourneyRoofAnim[vehicle] = true
							end
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

			if model == AmgOneID then
				local offset = -20
				
				if not AmgSpoiler[vehicle] then
					AmgSpoiler[vehicle] = 0
				end

				if not AmgSpoiler2[vehicle] then
					AmgSpoiler2[vehicle] = 0
				end

				local brakeState = false

    			if vehicle.controller and vehicle.onGround then
			        local movingBackwards, movingFast = isVehicleMovingBackwards(vehicle)
			        local accelerateState = vehicle.controller:getControlState("accelerate")
			        
			        if movingBackwards then
			            brakeState = movingFast and accelerateState
			        else
			            brakeState = (movingFast or accelerateState) and vehicle.controller:getControlState("brake_reverse")
			        end
			    else
			       brakeState = false
			    end

				if brakeState then
					if AmgSpoiler[vehicle] < 15 then
						AmgSpoiler[vehicle] = AmgSpoiler[vehicle] + 1
					end

					if AmgSpoiler2[vehicle] < 5 then
						AmgSpoiler2[vehicle] = AmgSpoiler2[vehicle] + 1
					end
				else
					if AmgSpoiler[vehicle] > 0 then
						AmgSpoiler[vehicle] = AmgSpoiler[vehicle] - 1
					end

					if AmgSpoiler2[vehicle] > 0 then
						AmgSpoiler2[vehicle] = AmgSpoiler2[vehicle] - 1
					end
				end
				
				if getVehicleSpeed(vehicle) >= 200 or spoilerOverride[vehicle] then
					if not spoilerState[vehicle] then
						local startValue = spoilerValue[vehicle] or 0
						spoilerState[vehicle] = true
						spoilerInterpolation[vehicle] = {currentTick, startValue, math.abs(startValue - offset) * 1500 / math.abs(offset)}
					end

					if not spoilerInterpolation[vehicle] then
						setVehicleComponentRotation(vehicle, "movspoiler_1", offset - AmgSpoiler[vehicle], 0, 0)
						setVehicleComponentRotation(vehicle, "movspoiler_0", offset - AmgSpoiler[vehicle] - AmgSpoiler2[vehicle], 0, 0)

						for Key = 2, 9 do
							setVehicleComponentRotation(vehicle, "movspoiler_" .. Key, offset - AmgSpoiler[vehicle], 0, 0)
						end
					else
						local elapsedTime = currentTick - spoilerInterpolation[vehicle][1]
						local progress = elapsedTime / spoilerInterpolation[vehicle][3]

						spoilerValue[vehicle] = interpolateBetween(spoilerInterpolation[vehicle][2], 0, 0, offset, 0, 0, progress, "InOutQuad")
						setVehicleComponentRotation(vehicle, "movspoiler_1", spoilerValue[vehicle] - AmgSpoiler[vehicle], 0, 0)
						setVehicleComponentRotation(vehicle, "movspoiler_0", spoilerValue[vehicle] - AmgSpoiler[vehicle] - AmgSpoiler2[vehicle], 0, 0)

						for Key = 2, 9 do
							setVehicleComponentRotation(vehicle, "movspoiler_" .. Key, spoilerValue[vehicle] - AmgSpoiler[vehicle], 0, 0)
						end

						if progress > 1.1 then
							spoilerInterpolation[vehicle] = nil
						end
					end
				else
					if spoilerState[vehicle] then
						local startValue = spoilerValue[vehicle] or 0
						spoilerState[vehicle] = nil
						spoilerInterpolation[vehicle] = {currentTick, startValue, math.abs(startValue) * 1500 / math.abs(offset)}
					end

					if not spoilerInterpolation[vehicle] then
						setVehicleComponentRotation(vehicle, "movspoiler_1", -AmgSpoiler[vehicle], 0, 0)
						setVehicleComponentRotation(vehicle, "movspoiler_0", -AmgSpoiler[vehicle] - AmgSpoiler2[vehicle], 0, 0)

						for Key = 2, 9 do
							setVehicleComponentRotation(vehicle, "movspoiler_" .. Key, -AmgSpoiler[vehicle], 0, 0)
						end
					else
						local elapsedTime = currentTick - spoilerInterpolation[vehicle][1]
						local progress = elapsedTime / spoilerInterpolation[vehicle][3]

						spoilerValue[vehicle] = interpolateBetween(spoilerInterpolation[vehicle][2] - AmgSpoiler[vehicle], 0, 0, - AmgSpoiler[vehicle], 0, 0, progress, "InOutQuad")
						setVehicleComponentRotation(vehicle, "movspoiler_1", spoilerValue[vehicle], 0, 0)
						setVehicleComponentRotation(vehicle, "movspoiler_0", spoilerValue[vehicle] - AmgSpoiler2[vehicle], 0, 0)

						for Key = 2, 9 do
							setVehicleComponentRotation(vehicle, "movspoiler_" .. Key, spoilerValue[vehicle], 0, 0)
						end

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

function isVehicleMovingBackwards(vehicle)
    if vehicle.velocity.length < 0.05 then
        return false, false
    end

    local direction = vehicle.matrix.forward
    local velocity = vehicle.velocity.normalized

    local dot = direction.x * velocity.x + direction.y * velocity.y
    local det = direction.x * velocity.y - direction.y * velocity.x

    local angle = math.deg(math.atan2(det, dot))
    return math.abs(angle) > 120, true
end

function getPositionFromElementOffset(element, x, y, z)
	local m = false

	if not isElementStreamedIn(element) then
		local rx, ry, rz = getElementRotation(element, "ZXY")

		rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
		m = {}

		m[1] = {}
		m[1][1] = math.cos(rz) * math.cos(ry) - math.sin(rz) * math.sin(rx) * math.sin(ry)
		m[1][2] = math.cos(ry) * math.sin(rz) + math.cos(rz) * math.sin(rx) * math.sin(ry)
		m[1][3] = -math.cos(rx) * math.sin(ry)
		m[1][4] = 1

		m[2] = {}
		m[2][1] = -math.cos(rx) * math.sin(rz)
		m[2][2] = math.cos(rz) * math.cos(rx)
		m[2][3] = math.sin(rx)
		m[2][4] = 1

		m[3] = {}
		m[3][1] = math.cos(rz) * math.sin(ry) + math.cos(ry) * math.sin(rz) * math.sin(rx)
		m[3][2] = math.sin(rz) * math.sin(ry) - math.cos(rz) * math.cos(ry) * math.sin(rx)
		m[3][3] = math.cos(rx) * math.cos(ry)
		m[3][4] = 1

		m[4] = {}
		m[4][1], m[4][2], m[4][3] = getElementPosition(element)
		m[4][4] = 1
	else
		m = getElementMatrix(element)
	end

	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

local JourneyObjects = {}

function chairGetOut(veh, state)
	local x, y, z = getElementPosition(veh)

	if not JourneyObjects[veh] then
		JourneyObjects[veh] = {}
	end
	DestroyObject(veh)

    if state == 1 then
        local Object = createObject(2121, x, y, z)
        attachElementToElement(Object, veh, 2, 2, -0.5)
        setElementAttachedOffsets(Object, 2, -2, -0.32, 0, 0, 45)
        setElementCollisionsEnabled(Object, false)
        table.insert(JourneyObjects[veh], Object)

        local Object = createObject(2121, x, y, z)
        attachElementToElement(Object, veh, 2, 2, -0.5)
        setElementAttachedOffsets(Object, 2, -4.5, -0.32, 0, 0, 115)
        setElementCollisionsEnabled(Object, false)
        table.insert(JourneyObjects[veh], Object)

    elseif state == 2 then
        local Object = createObject(1281,x,y,z)
        attachElementToElement(Object,veh,2,2,-0.5)
        setElementAttachedOffsets(Object,5.5,-2,-0.32,0,0,90)
        setElementCollisionsEnabled(Object, false)
        table.insert(JourneyObjects[veh], Object)

    elseif state == 3 then
        local Object = createObject(2121, x, y, z)
        attachElementToElement(Object, veh, 2, 2, -0.5)
        setElementAttachedOffsets(Object, 2, -2, -0.32, 0, 0, 45)
        setElementCollisionsEnabled(Object, false)
        table.insert(JourneyObjects[veh], Object)

        local Object = createObject(2121, x, y, z)
        attachElementToElement(Object, veh, 2, 2, -0.5)
        setElementAttachedOffsets(Object, 2, -4.5, -0.32, 0, 0, 115)
        setElementCollisionsEnabled(Object, false)
        table.insert(JourneyObjects[veh], Object)

        local Object = createObject(1281, x, y, z)
        attachElementToElement(Object,veh, 2, 2, -0.5)
        setElementAttachedOffsets(Object, 5.5, -2, -0.32, 0, 0, 90)
        setElementCollisionsEnabled(Object, false)
        table.insert(JourneyObjects[veh], Object)
    end
end

function DestroyObject(Vehicle)
	if not JourneyObjects[Vehicle] then
		JourneyObjects[Vehicle] = {}
	end

	for k, v in ipairs(JourneyObjects[Vehicle]) do
    	destroyElement(v)
	end

	JourneyObjects[Vehicle] = {}
end	