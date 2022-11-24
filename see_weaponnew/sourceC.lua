local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(value)
	return math.ceil(value * responsiveMultipler)
end

Roboto = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")

local radarDebugMode = false

local radarCenterX = screenX - respc(124)
local radarCenterY = screenY / 2 - respc(16)

local radarMaximumRange = 30
local radarRotationTick = 0
local radarRotationValue = 0
local radarDetections = {}

local isRadarSoundEnabled = true
local isRadarMoving = false

local radarAbilityShips = {
	[453] = true, -- Reefer
	[454] = true, -- Tropic (Buckingham Tug)
	[430] = true, -- Predator
	[472] = true -- Coastguard
}

local activeButton = false
local activeCraneButton = false

local glueElement = false
local _getPedContactElement = getPedContactElement

function getPedContactElement()
	if isElement(glueElement) then
		return glueElement
	else
		return _getPedContactElement(localPlayer)
	end
end

shipDatas = {}

local nearbyShips = {}
local predatorShips = {}
local lootPositions = {}
local crabPositions = {}

local objectOnCraneHead = {}
local craneObjects = {}
local craneMovements = {}
local craneModelOffsets = {
	-- [9021] = -0.5,
	[920] = -0.35,
	[1208] = -0.9,
	[3134] = -0.35,
	[3633] = -0.475,
	[3632] = -0.475
}

local cratesOnShip = {}
local shipCrateOffsetsX = {2.9, 4.25}
local shipCrateOffsetsY = {0.4, 0.6}
local shipCrateOffsetsZ = {1, 0.8}

local showLootPoints = false
local function updateLootPoints()
	local blipList = getElementsByType("blip", getResourceRootElement())

	for i = 1, #blipList do
		if isElement(blipList[i]) then
			destroyElement(blipList[i])
		end
	end

	if showLootPoints then
		for i = 1, #lootPositions do
			local blipElement = createBlip(lootPositions[i][1], lootPositions[i][2], 0, 0, 2, 150, 150, 150)
			if isElement(blipElement) then
				setElementData(blipElement, "blipTooltipText", "Loot #" .. i)
			end
		end
	end
end

addCommandHandler("showloots",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			showLootPoints = not showLootPoints
			updateLootPoints()
		end
	end
)

addCommandHandler("setshipcrates",
	function (commandName, numOfCrates)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local contactElement = getPedContactElement(localPlayer)

			if contactElement then
				numOfCrates = tonumber(numOfCrates)

				if numOfCrates >= 0 and numOfCrates <= 100 then
					setElementData(contactElement, "numOfCrates", numOfCrates)
				end
			end
		end
	end
)

addEvent("syncShipDatas", true)
addEventHandler("syncShipDatas", getRootElement(),
	function (datas)
		shipDatas[source] = datas
		processCrabCrates(source, datas.numOfCrabCrates)
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if source == localPlayer then
			if dataName == "playerGlueState" then
				glueElement = getElementData(localPlayer, "playerGlueState")
			end
		elseif source == resourceRoot then
			if dataName == "lootPoints" then
				lootPositions = getElementData(source, "lootPoints")

				if showLootPoints then
					updateLootPoints()
				end
			end
		else
			if dataName == "numOfCrates" then
				if isElementStreamedIn(source) then
					processShipCrates(source, getElementData(source, "numOfCrates") or 0)
				end
			elseif dataName == "cageIsDone" then
				if isElementStreamedIn(source) then
					for k, v in pairs(crabPositions) do
						if v[5] == source then
							crabPositions[k][3] = getElementData(source, "cageIsDone")
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local objectList = getElementsByType("object", getResourceRootElement(), true)
		for i = 1, #objectList do
			local object = objectList[i]

			if getElementModel(object) == replacementModels.buoy then
				local objectX, objectY, objectZ = getElementPosition(object)

				if getElementData(object, "cageIsDone") then
					table.insert(crabPositions, {objectX, objectY, true, false, object})
				else
					table.insert(crabPositions, {objectX, objectY, false, false, object})
				end
			end
		end

		local vehicleList = getElementsByType("vehicle", getRootElement(), true)
		for i = 1, #vehicleList do
			local vehicle = vehicleList[i]

			if getVehicleType(vehicle) == "Boat" then
				local boatModel = getElementModel(vehicle)

				if boatModel == 453 or boatModel == 454 then
					if boatModel == 453 then
						applyCraneObject(vehicle)
						processShipCrates(vehicle, getElementData(vehicle, "numOfCrates") or 0)
					end

					triggerServerEvent("getTheShipDatas", localPlayer, vehicle)
				end

				if boatModel == 430 then
					predatorShips[vehicle] = true
				end

				table.insert(nearbyShips, {vehicle})
			end
		end

		lootPositions = getElementData(resourceRoot, "lootPoints")

		local crateTxd = engineLoadTXD("files/cj_crate_will.txd")
		if crateTxd then
			engineImportTXD(crateTxd, 964)
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			if getVehicleType(source) == "Boat" then
				local boatModel = getElementModel(source)

				table.insert(nearbyShips, {source})

				if boatModel == 430 then
					predatorShips[source] = true
				end

				if boatModel == 453 or boatModel == 454 then
					if boatModel == 453 then
						applyCraneObject(source)
						processShipCrates(source, getElementData(source, "numOfCrates") or 0)
					end

					triggerServerEvent("getTheShipDatas", localPlayer, source)
				end
			end
		else
			if getElementModel(source) == replacementModels.buoy then
				local objectX, objectY, objectZ = getElementPosition(source)

				if getElementData(source, "cageIsDone") then
					table.insert(crabPositions, {objectX, objectY, true, false, source})
				else
					table.insert(crabPositions, {objectX, objectY, false, false, source})
				end
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			if getVehicleType(source) == "Boat" then
				local boatModel = getElementModel(source)

				for i = 1, #nearbyShips do
					if nearbyShips[i] then
						if nearbyShips[i][1] == source then
							nearbyShips[i] = nil
						end
					end
				end

				if boatModel == 430 then
					predatorShips[source] = nil
				end

				if boatModel == 453 then
					craneMovements[source] = nil

					if craneObjects[source] then
						if isElement(craneObjects[source]) then
							destroyElement(craneObjects[source])
						end

						craneObjects[source] = nil
					end

					if objectOnCraneHead[source] then
						if isElement(objectOnCraneHead[source]) then
							destroyElement(objectOnCraneHead[source])
						end

						objectOnCraneHead[source] = nil
					end

					if cratesOnShip[source] then
						for i = 1, #cratesOnShip[source] do
							if isElement(cratesOnShip[source][i]) then
								destroyElement(cratesOnShip[source][i])
							end
						end

						cratesOnShip[source] = nil
					end
				end

				if boatModel == 453 or boatModel == 454 then
					shipDatas[source] = nil
					shipWeights[source] = nil

					if crabCratesOnShip[source] then
						for cageIndex = 1, #crabCratesOnShip[source] do
							if isElement(crabCratesOnShip[source][cageIndex]) then
								destroyElement(crabCratesOnShip[source][cageIndex])
							end
						end

						crabCratesOnShip[source] = nil
					end

					if crabObjectsOnShip[source] then
						for cageIndex in pairs(crabObjectsOnShip[source]) do
							for crabIndex = 1, #crabObjectsOnShip[source][cageIndex] do
								if isElement(crabObjectsOnShip[source][cageIndex][crabIndex]) then
									destroyElement(crabObjectsOnShip[source][cageIndex][crabIndex])
								end
							end
						end

						crabObjectsOnShip[source] = nil
					end

					if baitObjects[source] then
						for cageIndex in pairs(baitObjects[source]) do
							for baitIndex = 1, #baitObjects[source][cageIndex] do
								if isElement(baitObjects[source][cageIndex][baitIndex]) then
									destroyElement(baitObjects[source][cageIndex][baitIndex])
								end
							end
						end

						baitObjects[source] = nil
					end
				end
			end
		else
			if getElementModel(source) == replacementModels.buoy then
				for k, v in pairs(crabPositions) do
					if v[5] == source then
						table.remove(crabPositions, k)
						break
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			if getVehicleType(source) == "Boat" then
				local boatModel = getElementModel(source)

				for i = 1, #nearbyShips do
					if nearbyShips[i] then
						if nearbyShips[i][1] == source then
							nearbyShips[i] = nil
						end
					end
				end

				if boatModel == 430 then
					predatorShips[source] = nil
				end

				if boatModel == 453 then
					craneMovements[source] = nil

					if craneObjects[source] then
						if isElement(craneObjects[source]) then
							destroyElement(craneObjects[source])
						end

						craneObjects[source] = nil
					end

					if objectOnCraneHead[source] then
						if isElement(objectOnCraneHead[source]) then
							destroyElement(objectOnCraneHead[source])
						end

						objectOnCraneHead[source] = nil
					end

					if cratesOnShip[source] then
						for i = 1, #cratesOnShip[source] do
							if isElement(cratesOnShip[source][i]) then
								destroyElement(cratesOnShip[source][i])
							end
						end

						cratesOnShip[source] = nil
					end
				end

				if boatModel == 453 or boatModel == 454 then
					shipDatas[source] = nil
					shipWeights[source] = nil

					if crabCratesOnShip[source] then
						for cageIndex = 1, #crabCratesOnShip[source] do
							if isElement(crabCratesOnShip[source][cageIndex]) then
								destroyElement(crabCratesOnShip[source][cageIndex])
							end
						end

						crabCratesOnShip[source] = nil
					end

					if crabObjectsOnShip[source] then
						for cageIndex in pairs(crabObjectsOnShip[source]) do
							for crabIndex = 1, #crabObjectsOnShip[source][cageIndex] do
								if isElement(crabObjectsOnShip[source][cageIndex][crabIndex]) then
									destroyElement(crabObjectsOnShip[source][cageIndex][crabIndex])
								end
							end
						end

						crabObjectsOnShip[source] = nil
					end

					if baitObjects[source] then
						for cageIndex in pairs(baitObjects[source]) do
							for baitIndex = 1, #baitObjects[source][cageIndex] do
								if isElement(baitObjects[source][cageIndex][baitIndex]) then
									destroyElement(baitObjects[source][cageIndex][baitIndex])
								end
							end
						end

						baitObjects[source] = nil
					end
				end
			end
		else
			if getElementModel(source) == replacementModels.buoy then
				for k, v in pairs(crabPositions) do
					if v[5] == source then
						table.remove(crabPositions, k)
						break
					end
				end
			end
		end
	end
)

function applyCraneObject(vehicle)
	local shipPosX, shipPosY, shipPosZ = getElementPosition(vehicle)

	if isElement(craneObjects[vehicle]) then
		destroyElement(craneObjects[vehicle])
	end

	craneObjects[vehicle] = createObject(1301, shipPosX, shipPosY, shipPosZ)

	setElementCollisionsEnabled(craneObjects[vehicle], false)
	setObjectScale(craneObjects[vehicle], 0.2)
	attachElements(craneObjects[vehicle], vehicle, 0, -6.25, 2.5)
end

function setCraneDown(shipCrane)
	if type(shipCrane) == "table" then
		local shipElement = shipCrane[1]

		if objectOnCraneHead[shipElement] then
			if getElementData(shipElement, "objectOnCraneHead") then
				local isDownState = shipCrane[2]

				if not isDownState then
					if getElementModel(objectOnCraneHead[shipElement]) ~= 964 then
						return
					end
				end

				triggerServerEvent("onShipCrateMove", shipElement, isDownState)

				return
			end
		end

		return
	end

	if shipCrane then
		if getElementType(shipCrane) ~= "vehicle" then
			shipCrane = false
		end
	end

	local numOfCrates = getElementData(shipCrane, "numOfCrates") or 0
	if numOfCrates >= 2 then
		return
	end

	if getElementData(shipCrane, "craneIsMoving") then
		return
	end

	if shipCrane then
		local craneX, craneY = getElementPosition(shipCrane)
		local crateFound = false

		for i = 1, #lootPositions do
			if lootPositions[i] then
				local distanceBetween = getDistanceBetweenPoints2D(craneX, craneY, lootPositions[i][1], lootPositions[i][2])
				if math.floor(distanceBetween) <= 5 then
					crateFound = i
					break
				end
			end
		end

		if crateFound then
			triggerServerEvent("onShipCraneMovement", shipCrane, crateFound)
		end
	end
end

addEvent("onShipCraneMovement", true)
addEventHandler("onShipCraneMovement", getRootElement(),
	function (modelFound)
		if isElement(craneObjects[source]) then
			craneMovements[source] = {getTickCount()}
			craneMovements[source][2] = craneMovements[source][1] + 17500
			craneMovements[source][3] = modelFound

			playSoundForVehicle(source, "files/crane_15.mp3")
			setTimer(playSoundForVehicle, 17500, 1, source, "files/crane_15.mp3")
		end
	end
)

addEvent("onShipCrateMove", true)
addEventHandler("onShipCrateMove", getRootElement(),
	function (isDownState)
		if isElement(craneObjects[source]) then
			craneMovements[source] = {}

			if isDownState then
				if isElement(objectOnCraneHead[source]) then
					local objectPosX, objectPosY, objectPosZ = getElementPosition(objectOnCraneHead[source])

					detachElements(objectOnCraneHead[source])
					setElementRotation(objectOnCraneHead[source], 0, 0, 0)

					craneMovements[source][9] = getTickCount()
					craneMovements[source][10] = objectPosZ
					craneMovements[source][11] = false
				end
			else
				craneMovements[source][4] = getTickCount()
				craneMovements[source][5] = craneMovements[source][4] + 5000
				craneMovements[source][6] = craneMovements[source][5] + 5000
				craneMovements[source][7] = craneMovements[source][6] + 5000

				playSoundForVehicle(source, "files/crane_4.mp3")
				setTimer(playSoundForVehicle, 5000, 3, source, "files/crane_4.mp3")

				if not cratesOnShip[source] or #cratesOnShip[source] == 0 then
					craneMovements[source][8] = 2
				else
					craneMovements[source][8] = 1
				end
			end
		end
	end
)

function processShipCrates(vehicle, numOfCrates)
	if not cratesOnShip[vehicle] then
		cratesOnShip[vehicle] = {}
	end

	local cratesList = cratesOnShip[vehicle]
	local cratesCount = #cratesList

	if cratesCount ~= numOfCrates then
		if numOfCrates - cratesCount < 0 then
			for i = 1, math.abs(numOfCrates - cratesCount) do
				if isElement(cratesList[cratesCount]) then
					destroyElement(cratesList[cratesCount])
				end

				cratesList[cratesCount] = nil
				cratesCount = #cratesList
			end
		else
			if numOfCrates - cratesCount > 0 then
				for i = 1, math.abs(numOfCrates - cratesCount) do
					local crateIndex = cratesCount + 1

					if crateIndex == 1 or crateIndex == 2 then
						cratesList[crateIndex] = createObject(964, 0, 0, 0)

						if isElement(cratesList[crateIndex]) then
							if crateIndex == 1 then
								attachElements(cratesList[crateIndex], vehicle, 0, -2, 0.15)
							else
								attachElements(cratesList[crateIndex], vehicle, 0, -3.35, 0.15)
							end
						end

						local velX, velY, velZ = getElementVelocity(vehicle)
						setElementVelocity(vehicle, velX, velY, velZ + 0.01)
					end

					cratesCount = #cratesList
				end
			end
		end
	end
end

function playSoundForVehicle(vehicle, path)
	local soundEffect = playSound3D(path, getElementPosition(vehicle))
	if isElement(soundEffect) then
		attachElements(soundEffect, vehicle)
	end
end

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if button == "left" then
			if state == "down" then
				if activeCraneButton then
					setCraneDown(activeCraneButton)
				end

				if activeButton == "toggleSound" then
					isRadarSoundEnabled = not isRadarSoundEnabled
				end

				if activeButton == "setRadarRange" then
					radarMaximumRange = radarMaximumRange + 10

					if radarMaximumRange > 90 then
						radarMaximumRange = 30
					end
				end
			end
		end

		if button == "right" then
			if state == "down" then
				if activeButton == "setRadarRange" then
					radarMaximumRange = radarMaximumRange - 10

					if radarMaximumRange < 30 then
						radarMaximumRange = 90
					end
				end
			end
		end
	end
)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		local currentTickCount = getTickCount()

		for k, v in pairs(craneObjects) do
			local magnetPosX, magnetPosY, magnetPosZ = getElementPosition(v)
			local craneOffsetX, craneOffsetY, craneOffsetZ = 0, 0, 0
			local craneMovement = craneMovements[k]

			setVehicleComponentRotation(k, "boat_moving", 0, 0, radarRotationValue)

			if craneMovement then
				if craneMovement[9] then
					if currentTickCount > craneMovement[9] then
						local elapsedTime = currentTickCount - craneMovement[9]
						local progress = elapsedTime / 4000

						local objectPosX, objectPosY = getElementPosition(objectOnCraneHead[k])
						local objectPosZ, objectRotY = interpolateBetween(craneMovement[10], 0, 0, craneMovement[10] - 15, 40, 0, progress, "InOutQuad")

						setElementPosition(objectOnCraneHead[k], objectPosX, objectPosY, objectPosZ)
						setElementRotation(objectOnCraneHead[k], 0, objectRotY, 0)

						if elapsedTime >= 500 then
							if not craneMovement[11] then
								craneMovement[11] = true
								playSound3D("files/splash.mp3", objectPosX, objectPosY, objectPosZ)
							end
						end

						if progress >= 1 then
							if objectOnCraneHead[k] then
								if isElement(objectOnCraneHead[k]) then
									destroyElement(objectOnCraneHead[k])
								end

								objectOnCraneHead[k] = nil
							end

							craneMovements[k] = nil
						end
					end
				elseif craneMovement[4] then
					local numOfCrates = craneMovement[8]

					if currentTickCount > craneMovement[4] then
						local left_progress = (currentTickCount - craneMovement[4]) / 4000
						local down_progress = (currentTickCount - craneMovement[5]) / 4000

						if left_progress > 0 then
							craneOffsetX, craneOffsetY = interpolateBetween(0, 0, 0, shipCrateOffsetsX[numOfCrates], shipCrateOffsetsY[numOfCrates], 0, left_progress, "InOutQuad")
						end

						if down_progress > 0 then
							craneOffsetZ = interpolateBetween(0, 0, 0, shipCrateOffsetsZ[numOfCrates], 0, 0, down_progress, "InOutQuad")
						end

						local up_progress = (currentTickCount - craneMovement[6]) / 4000
						local right_progress = (currentTickCount - craneMovement[7]) / 4000

						if up_progress > 0 then
							if objectOnCraneHead[k] then
								processShipCrates(k, 3 - numOfCrates)

								if isElement(objectOnCraneHead[k]) then
									destroyElement(objectOnCraneHead[k])
								end

								objectOnCraneHead[k] = nil
							end

							craneOffsetZ = interpolateBetween(shipCrateOffsetsZ[numOfCrates], 0, 0, 0, 0, 0, up_progress, "InOutQuad")
						end

						if right_progress > 0 then
							craneOffsetX, craneOffsetY = interpolateBetween(shipCrateOffsetsX[numOfCrates], shipCrateOffsetsY[numOfCrates], 0, 0, 0, 0, right_progress, "InOutQuad")
						end

						if right_progress >= 1 then
							craneMovements[k] = nil
						end
					end
				elseif currentTickCount > craneMovement[2] then
					local progress = (currentTickCount - craneMovement[2]) / 15000

					if craneMovement[3] then
						if not isElement(craneMovement[3]) then
							local itemModel = craneMovement[3]

							objectOnCraneHead[k] = createObject(craneMovement[3], 0, 0, 0)
							craneMovement[3] = objectOnCraneHead[k]

							attachElements(craneMovement[3], v, 0, 0, craneModelOffsets[itemModel] or -0.95)
							setElementCollisionsEnabled(craneMovement[3], false)
						end
					end

					craneOffsetZ = interpolateBetween(20, 0, 0, 0, 0, 0, progress, "InOutQuad")

					if progress >= 1 then
						craneMovements[k] = nil
					end
				else
					craneOffsetZ = interpolateBetween(0, 0, 0, 20, 0, 0, (currentTickCount - craneMovement[1]) / 15000, "InOutQuad")
				end

				attachElements(craneObjects[k], k, 0, -6.25 + craneOffsetX, 2.5 - craneOffsetZ - craneOffsetY)
			end

			dxDrawLine3D(magnetPosX, magnetPosY, magnetPosZ, magnetPosX, magnetPosY, magnetPosZ + 1.5 + craneOffsetZ, tocolor(25, 25, 25), 2)
		end

		for k in pairs(predatorShips) do
			setVehicleComponentRotation(k, "boat_moving", 0, 0, radarRotationValue + 90)
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local currentTickCount = getTickCount()
		local myVehicleElement = getPedOccupiedVehicle(localPlayer)
		local myVehicleModel = 0

		if myVehicleElement then
			myVehicleModel = getElementModel(myVehicleElement)
		end

		radarRotationValue = 360 - (currentTickCount - radarRotationTick) / 2000 * 360

		if radarRotationValue < 0 then
			radarRotationValue = 360
			radarRotationTick = currentTickCount

			if myVehicleElement then
				if myVehicleModel == 453 or myVehicleModel == 430 or myVehicleModel == 472 then
					for i = 1, #lootPositions do
						if lootPositions[i] then
							lootPositions[i][4] = false
						end
					end
				end

				if myVehicleModel == 453 or myVehicleModel == 454 then
					for i = 1, #crabPositions do
						if crabPositions[i] then
							crabPositions[i][4] = false
						end
					end
				end

				if myVehicleModel == 430 or myVehicleModel == 472 or myVehicleModel == 454 then
					for i = 1, #nearbyShips do
						if nearbyShips[i] then
							nearbyShips[i][2] = false
						end
					end
				end
			end
		end

		if radarDebugMode then
			if myVehicleElement then
				local distanceMultiplier = 1

				if myVehicleModel == 430 or myVehicleModel == 472 then
					distanceMultiplier = 3
				end

				local totalDistance = radarMaximumRange * distanceMultiplier
				local myShipPosX, myShipPosY, myShipPosZ = getElementPosition(myVehicleElement)
				local myShipRotX, myShipRotY, myShipRotZ = getElementRotation(myVehicleElement)
				local lineHeight = 2

				for i = 1, 360, 30 do
					local angle = math.rad(i)
					local x = math.cos(angle) * totalDistance
					local y = math.sin(angle) * totalDistance

					dxDrawLine3D(myShipPosX, myShipPosY, myShipPosZ + lineHeight, myShipPosX + x, myShipPosY + y, myShipPosZ + lineHeight, tocolor(61, 122, 188, 150), 3)
					dxDrawLine3D(myShipPosX + x, myShipPosY + y, myShipPosZ, myShipPosX + x, myShipPosY + y, myShipPosZ + lineHeight, tocolor(61, 122, 188, 150), 3)
				end

				local angle = math.rad(radarRotationValue + 270)
				local x1 = math.cos(angle) * totalDistance
				local y1 = math.sin(angle) * totalDistance

				local angle = math.rad(radarRotationValue + 270 - 10)
				local x2 = math.cos(angle) * totalDistance
				local y2 = math.sin(angle) * totalDistance

				local z = myShipPosZ + lineHeight

				dxDrawLine3D(myShipPosX, myShipPosY, z, myShipPosX + x1, myShipPosY + y1, z, tocolor(61, 122, 188, 150), 10)
				dxDrawLine3D(myShipPosX, myShipPosY, z, myShipPosX + x2, myShipPosY + y2, z, tocolor(61, 122, 188, 150), 10)
				dxDrawLine3D(myShipPosX + x1, myShipPosY + y1, z, myShipPosX + x2, myShipPosY + y2, z, tocolor(61, 122, 188, 150), 10)
			end
		end

		local contactElement = getPedContactElement(localPlayer)
		local cursorX, cursorY = getCursorPosition()

		if not cursorX then
			cursorX = -1000
			cursorY = -1000
		else
			cursorX = cursorX * screenX
			cursorY = cursorY * screenY
		end

		activeCraneButton = false
		activeButton = false

		if contactElement then
			if getElementModel(contactElement) == 453 then
				if not isPedInVehicle(localPlayer) then
					if not craneMovements[contactElement] then
						local crabCrates = crabCratesOnShip[contactElement]

						if not crabCrates or #crabCrates <= 0 then
							if Vector3(getElementVelocity(contactElement)).length < 1 then
								local offsetX, offsetY, offsetZ = getPositionFromElementOffset(contactElement, 0, -1.25, 1.25)
								local guiPosX, guiPosY, guiDistance = getScreenFromWorldPosition(offsetX, offsetY, offsetZ)

								if guiPosX and guiPosY then
									local guiSize = respc(256 / guiDistance)

									guiPosX = guiPosX - guiSize / 2
									guiPosY = guiPosY - guiSize / 2

									if objectOnCraneHead[contactElement] then
										if getElementModel(objectOnCraneHead[contactElement]) ~= 964 then
											local craneAlpha = 150

											if cursorX >= guiPosX and cursorY >= guiPosY and cursorX <= guiPosX + guiSize and cursorY <= guiPosY + guiSize then
												activeCraneButton = {contactElement, true}
												craneAlpha = 255
											end

											dxDrawRectangle(guiPosX, guiPosY, guiSize, guiSize, tocolor(0, 0, 0, 150))
											dxDrawImage(guiPosX, guiPosY, guiSize, guiSize, "files/crane_down.png", 0, 0, 0, tocolor(61, 122, 188, craneAlpha))
										else
											local craneLeftPosX = guiPosX - respc(16 / guiDistance) - guiSize / 2
											local craneDownPosX = guiPosX + respc(16 / guiDistance) + guiSize / 2

											local craneLeftAlpha = 150
											local craneDownAlpha = 150

											if cursorX >= craneLeftPosX and cursorY >= guiPosY and cursorX <= craneLeftPosX + guiSize and cursorY <= guiPosY + guiSize then
												activeCraneButton = {contactElement, false}
												craneLeftAlpha = 255
											elseif cursorX >= craneDownPosX and cursorY >= guiPosY and cursorX <= craneDownPosX + guiSize and cursorY <= guiPosY + guiSize then
												activeCraneButton = {contactElement, true}
												craneDownAlpha = 255
											end

											dxDrawRectangle(craneLeftPosX, guiPosY, guiSize, guiSize, tocolor(0, 0, 0, 150))
											dxDrawImage(craneLeftPosX, guiPosY, guiSize, guiSize, "files/crane_left.png", 0, 0, 0, tocolor(61, 122, 188, craneLeftAlpha))

											dxDrawRectangle(craneDownPosX, guiPosY, guiSize, guiSize, tocolor(0, 0, 0, 150))
											dxDrawImage(craneDownPosX, guiPosY, guiSize, guiSize, "files/crane_down.png", 0, 0, 0, tocolor(61, 122, 188, craneDownAlpha))
										end
									else
										local craneAlpha = 150

										if cursorX >= guiPosX and cursorY >= guiPosY and cursorX <= guiPosX + guiSize and cursorY <= guiPosY + guiSize then
											activeCraneButton = contactElement
											craneAlpha = 255
										end

										dxDrawRectangle(guiPosX, guiPosY, guiSize, guiSize, tocolor(0, 0, 0, 150))
										dxDrawImage(guiPosX, guiPosY, guiSize, guiSize, "files/crane.png", 0, 0, 0, tocolor(61, 122, 188, craneAlpha))
									end
								end
							end
						end
					end
				end
			end
		end

		if myVehicleElement then
			if radarAbilityShips[myVehicleModel] then
				local crabCrates = crabCratesOnShip[myVehicleElement]

				local positionOffset = respc(96)
				local sizeOffset = respc(192)

				local bgWidth = sizeOffset * 1.125
				local bgHeight = sizeOffset * 1.125 + respc(32)

				if crabCrates then
					if #crabCrates > 0 then
						bgHeight = bgHeight + respc(48)
					end
				end

				local bgPosX = radarCenterX - positionOffset * 1.125
				local bgPosY = radarCenterY - positionOffset * 1.125

				local bgMargin = 2

				-- ** Keret
				dxDrawRectangle(bgPosX, bgPosY, bgWidth, bgMargin, tocolor(0, 0, 0, 200))
				dxDrawRectangle(bgPosX, bgPosY + bgHeight - bgMargin, bgWidth, bgMargin, tocolor(0, 0, 0, 200))
				dxDrawRectangle(bgPosX, bgPosY + bgMargin, bgMargin, bgHeight - (bgMargin * 2), tocolor(0, 0, 0, 200))
				dxDrawRectangle(bgPosX + bgWidth - bgMargin, bgPosY + bgMargin, bgMargin, bgHeight - (bgMargin * 2), tocolor(0, 0, 0, 200))

				-- ** Háttér
				dxDrawRectangle(bgPosX, bgPosY, bgWidth, bgHeight, tocolor(0, 0, 0, 160))

				-- ** Rács
				local gridSize = sizeOffset * 1.05
				local gridPosX = radarCenterX - positionOffset * 1.05
				local gridPosY = radarCenterY - positionOffset * 1.05
				local gridSectionSize = 16 * (radarMaximumRange / 10 + 7)

				dxDrawRectangle(gridPosX, gridPosY, gridSize, gridSize, tocolor(50, 200, 84, 25))
				dxDrawImageSection(gridPosX, gridPosY, gridSize, gridSize, 0, 0, gridSectionSize, gridSectionSize, "files/grid2.png", 0, 0, 0, tocolor(255, 255, 255, 25))

				-- ** Hang
				local soundIconState = "off"
				local soundIconAlpha = 150

				if isRadarSoundEnabled then
					soundIconState = "on"
					soundIconAlpha = 200
				end

				if cursorX >= gridPosX + gridSize - respc(28) and cursorX <= gridPosX + gridSize - respc(4) and cursorY >= gridPosY + respc(4) and cursorY <= gridPosY + respc(28) then
					activeButton = "toggleSound"
					soundIconAlpha = 255
				end

				dxDrawImage(gridPosX + gridSize - respc(28), gridPosY + respc(4), respc(24), respc(24), "files/sound" .. soundIconState .. ".png", 0, 0, 0, tocolor(255, 255, 255, soundIconAlpha))

				-- ** Látótáv
				local distanceMultiplier = 1
				local distanceAlpha = 150

				if myVehicleModel == 430 or myVehicleModel == 472 then
					distanceMultiplier = 3
				end

				local totalDistance = radarMaximumRange * distanceMultiplier

				if cursorX >= gridPosX + respc(8) and cursorX <= gridPosX + respc(32) and cursorY >= gridPosY + respc(4) and cursorY <= gridPosY + respc(28) then
					activeButton = "setRadarRange"
					distanceAlpha = 255
				end

				dxDrawText(totalDistance .. " y", gridPosX + respc(8), gridPosY + respc(4), gridPosX + respc(32), gridPosY + respc(28), tocolor(61, 122, 188, distanceAlpha), 0.75, Roboto, "center", "center")

				-- ** Koordináta
				local myShipPosX, myShipPosY, myShipPosZ = getElementPosition(myVehicleElement)
				local myShipRotX, myShipRotY, myShipRotZ = getElementRotation(myVehicleElement)

				dxDrawRectangle(gridPosX, gridPosY + gridSize + respc(8), gridSize, respc(24), tocolor(61, 122, 188, 125))
				dxDrawImage(radarCenterX - positionOffset, radarCenterY - positionOffset, sizeOffset, sizeOffset, "files/grid.png", 0, 0, 0, tocolor(255, 255, 255, 100))

				local currentX = math.floor(math.abs(myShipPosX))
				if myShipPosX < 0 then
					currentX = "W " .. currentX
				else
					currentX = "E " .. currentX
				end

				local currentY = math.floor(math.abs(myShipPosY))
				if myShipPosY < 0 then
					currentY = "N " .. currentY
				else
					currentY = "S " .. currentY
				end

				dxDrawText("(" .. currentX .. " ; " .. currentY .. ")", radarCenterX - positionOffset, gridPosY + gridSize + respc(8), radarCenterX + positionOffset, gridPosY + gridSize + respc(32), tocolor(25, 50, 25, 200), 0.75, Roboto, "center", "center")

				-- ** Ketrec adatok
				if crabCrates then
					if #crabCrates > 0 then
						local totalWeight = shipWeights[myVehicleElement] or 0

						dxDrawText("#dfb551Ketrecek: " .. #crabCrates .. " db#ffffff\n#3d7abcRák: " .. math.floor(totalWeight * 10) / 10 .. " kg", radarCenterX - positionOffset, gridPosY + gridSize + respc(32), radarCenterX + positionOffset, bgPosY + bgHeight, tocolor(255, 255, 255, 200), 0.7, Roboto, "center", "center", false, false, false, true)
					end
				end

				-- ** Radar
				local iconOffset = positionOffset - respc(8)

				if myVehicleModel == 430 or myVehicleModel == 472 then
					for i = 1, #nearbyShips do
						local v = nearbyShips[i]

						if v then
							if v[1] ~= myVehicleElement then
								if not v[2] then
									local shipPosX, shipPosY, shipPosZ = getElementPosition(v[1])
									local distanceBetween = getDistanceBetweenPoints2D(myShipPosX, myShipPosY, shipPosX, shipPosY)

									if distanceBetween <= totalDistance then
										local angleBetween = math.atan2(shipPosY - myShipPosY, shipPosX - myShipPosX) + math.rad(180 - myShipRotZ)

										if angleBetween < 0 then
											angleBetween = angleBetween + math.rad(360)
										end

										if math.deg(angleBetween) > radarRotationValue then
											local distanceFactor = distanceBetween / totalDistance

											nearbyShips[i][2] = true

											table.insert(radarDetections, {
												distanceFactor * iconOffset * math.cos(angleBetween) * -1,
												distanceFactor * iconOffset * math.sin(angleBetween),
												currentTickCount,
												true
											})

											if isRadarSoundEnabled then
												setSoundVolume(playSound("files/radar.mp3"), 1 - distanceFactor)
											end
										end
									end
								end
							end
						end
					end
				end

				for i = 1, #lootPositions do
					local v = lootPositions[i]

					if v then
						if not v[4] then
							local distanceBetween = getDistanceBetweenPoints2D(myShipPosX, myShipPosY, v[1], v[2])

							if distanceBetween <= totalDistance then
								local angleBetween = math.atan2(v[2] - myShipPosY, v[1] - myShipPosX) + math.rad(180 - myShipRotZ)

								if angleBetween < 0 then
									angleBetween = angleBetween + math.rad(360)
								end

								if math.deg(angleBetween) > radarRotationValue then
									local distanceFactor = distanceBetween / totalDistance

									lootPositions[i][4] = true

									table.insert(radarDetections, {
										distanceFactor * iconOffset * math.cos(angleBetween) * -1,
										distanceFactor * iconOffset * math.sin(angleBetween),
										currentTickCount
									})

									if isRadarSoundEnabled then
										setSoundVolume(playSound("files/radar.mp3"), 1 - distanceFactor)
									end
								end
							end
						end
					end
				end

				if myVehicleModel == 453 or myVehicleModel == 454 then
					for i = 1, #crabPositions do
						local v = crabPositions[i]

						if v then
							if not v[4] then
								local distanceBetween = getDistanceBetweenPoints2D(myShipPosX, myShipPosY, v[1], v[2])

								if distanceBetween <= totalDistance then
									local angleBetween = math.atan2(v[2] - myShipPosY, v[1] - myShipPosX) + math.rad(180 - myShipRotZ)

									if angleBetween < 0 then
										angleBetween = angleBetween + math.rad(360)
									end

									if math.deg(angleBetween) > radarRotationValue then
										local distanceFactor = distanceBetween / totalDistance

										crabPositions[i][4] = true

										table.insert(radarDetections, {
											distanceFactor * iconOffset * math.cos(angleBetween) * -1,
											distanceFactor * iconOffset * math.sin(angleBetween),
											currentTickCount,
											v[3] and "crab" or "crab2"
										})

										if isRadarSoundEnabled then
											setSoundVolume(playSound("files/radar.mp3"), 1 - distanceFactor)
										end
									end
								end
							end
						end
					end
				end

				for k, v in pairs(radarDetections) do
					if v then
						local elapsedTime = currentTickCount - v[3]
						local progress = elapsedTime / 2000
						local alpha = progress * 255

						if alpha > 255 then
							radarDetections[k] = nil
						elseif v[4] == "crab2" then
							dxDrawImage(radarCenterX + v[1] - respc(8), radarCenterY + v[2] - respc(8), respc(16), respc(16), "files/crab.png", 0, 0, 0, tocolor(215, 89, 89, 255 - alpha))
						elseif v[4] == "crab" then
							dxDrawImage(radarCenterX + v[1] - respc(8), radarCenterY + v[2] - respc(8), respc(16), respc(16), "files/crab.png", 0, 0, 0, tocolor(229, 195, 6, 255 - alpha))
						elseif v[4] then
							dxDrawImage(radarCenterX + v[1] - respc(8), radarCenterY + v[2] - respc(8), respc(16), respc(16), "files/ship.png", 0, 0, 0, tocolor(255, 255, 255, 255 - alpha))
						else
							dxDrawImage(radarCenterX + v[1] - respc(4), radarCenterY + v[2] - respc(4), respc(8), respc(8), "files/point.png", 0, 0, 0, tocolor(255, 255, 255, 255 - alpha))
						end
					end
				end

				dxDrawImage(radarCenterX + positionOffset, radarCenterY - positionOffset, -sizeOffset, sizeOffset, "files/rotate.png", -radarRotationValue, 0, 0, tocolor(255, 255, 255, 175))
				dxDrawImage(radarCenterX - positionOffset, radarCenterY - positionOffset, sizeOffset, sizeOffset, "files/circle.png")

				-- ** Mozgatás
				if getKeyState("mouse1") then
					if not isRadarMoving then
						if not activeButton then
							if cursorX >= bgPosX and cursorY >= bgPosY and cursorX <= bgPosX + bgWidth and cursorY <= bgPosY + bgHeight then
								isRadarMoving = {cursorX, cursorY, radarCenterX, radarCenterY}
							end
						end
					end

					if isRadarMoving then
						radarCenterX = isRadarMoving[3] + cursorX - isRadarMoving[1]
						radarCenterY = isRadarMoving[4] + cursorY - isRadarMoving[2]
					end
				else
					if isRadarMoving then
						isRadarMoving = false
					end
				end
			end
		end
	end
)
