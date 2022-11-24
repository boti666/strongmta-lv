local lootCratePoints = {}
local lootCrateTicks = {}
local lootDropPoints = {
	{-464.77059936523, 836.12731933594, 0},
	{-480.52059936523, 853.87731933594, 0},
	{-480.52059936523, 864.37731933594, 0}
}

local availableLootItems = {
	common = {
		probability = 12500,
		items = {128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 6, 7, 39, 40, 41, 42, 43, 44, 45, 46},
	},
	uncommon = {
		probability = 7500,
		items = {301, 302, 303, 304, 305, 306, 307}
	},
	superior = {
		probability = 5000,
		items = {109, 110, 111, 112, 113, 114}
	},
	rare = {
		probability = 500,
		items = {247, 253, 254, 259, 260, 76, 79, 87}
	},
	legendary = {
		probability = 100,
		items = {234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 281, 345, 315, 299}
	}
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		generateLootPoints()

		local vehicleList = getElementsByType("vehicle", getRootElement(), true)

		for i = 1, #vehicleList do
			local vehicle = vehicleList[i]

			if getElementModel(vehicle) == 453 then
				setElementData(vehicle, "craneIsMoving", false)
				setElementData(vehicle, "objectOnCraneHead", false)
				setElementData(vehicle, "numOfCrates", false)
			end
		end

		for i = 1, #lootDropPoints do
			local dropPoint = lootDropPoints[i]

			if dropPoint then
				dropPoint[4] = createMarker(dropPoint[1], dropPoint[2], dropPoint[3], "cylinder", 4, 215, 89, 89, 255)

				if isElement(dropPoint[4]) then
					setElementData(dropPoint[4], "3DText", "Leadó pont - #d75959Láda")
					setElementData(dropPoint[4], "dropPositionId", i, false)
				end
			end
		end
	end
)

math.randomf = function (a, b)
	local random = math.random(a * 100, b * 100)
	return random ~= 0 and random / 100 or random
end

function generateLootPoints()
	local totalWorldSize = 12000
	local frequencyOfLoots = 500
	local loopCount = (totalWorldSize / frequencyOfLoots) - 1

	lootCratePoints = {}

	for x = 1, loopCount do
		for y = 1, loopCount do
			local position = {
				-(totalWorldSize / 2) + (x * frequencyOfLoots) + math.randomf(-frequencyOfLoots / 2, frequencyOfLoots / 2),
				-(totalWorldSize / 2) + (y * frequencyOfLoots) + math.randomf(-frequencyOfLoots / 2, frequencyOfLoots / 2),
			}

			if position[1] < -3250 or position[1] > 3250 then
				table.insert(lootCratePoints, position)
			elseif position[2] < 0 or position[2] > 3250 then
				table.insert(lootCratePoints, position)
			end
		end
	end

	setElementData(resourceRoot, "lootPoints", lootCratePoints)
	setTimer(restoreLootPoints, 1000 * 60 * 60 * 3, 0)
end

function restoreLootPoints()
	local lootPoints = getElementData(resourceRoot, "lootPoints")

	if lootPoints then
		local numOfResetPoints = 0

		for k, v in pairs(lootCrateTicks) do
			if getTickCount() - v >= 1000 * 60 * 60 then
				table.insert(lootPoints, lootCratePoints[k])
				numOfResetPoints = numOfResetPoints + 1
				lootCrateTicks[k] = nil
			end
		end

		if numOfResetPoints > 0 then
			setElementData(resourceRoot, "lootPoints", lootPoints)
		end
	end
end

addEvent("onShipCraneMovement", true)
addEventHandler("onShipCraneMovement", getRootElement(),
	function (pointIndex)
		if isElement(source) then
			if pointIndex then
				local lootPoints = getElementData(resourceRoot, "lootPoints")

				if lootPoints then
					if lootPoints[pointIndex] then
						local modelFound = 964

						if math.random(100) <= 65 then
							local junkModels = {920, 1208, 3134, 3633, 3632}
							modelFound = junkModels[math.random(1, #junkModels)]
						end

						if modelFound then
							lootCrateTicks[pointIndex] = getTickCount()
							table.remove(lootPoints, pointIndex)

							setElementData(resourceRoot, "lootPoints", lootPoints)
							setElementData(source, "craneIsMoving", true)

							setTimer(
								function (sourceElement)
									if isElement(sourceElement) then
										setElementData(sourceElement, "objectOnCraneHead", true)
										setTimer(
											function ()
												if isElement(sourceElement) then
													setElementData(sourceElement, "craneIsMoving", false)
												end
											end,
										17500, 1)
									end
								end,
							15000, 1, source)

							triggerClientEvent("onShipCraneMovement", source, modelFound)
						end
					end
				end
			end
		end
	end
)

addEvent("onShipCrateMove", true)
addEventHandler("onShipCrateMove", getRootElement(),
	function (isDownState)
		if isElement(source) then
			triggerClientEvent("onShipCrateMove", source, isDownState)
			setTimer(
				function (sourceElement)
					if isElement(sourceElement) then
						local numOfCrates = getElementData(sourceElement, "numOfCrates") or 0

						numOfCrates = numOfCrates + 1

						if numOfCrates > 2 then
							numOfCrates = 2
						end

						setElementData(sourceElement, "numOfCrates", numOfCrates)
					end
				end,
			4000 * 3, 1, source)
		end
	end
)

function chooseRandomLootType()
	local totalWeight = 0

	for k, v in pairs(availableLootItems) do
		totalWeight = totalWeight + v.probability
	end

	local randomWeight = math.random(1, totalWeight)
	local currentWeight = 0

	for k, v in pairs(availableLootItems) do
		currentWeight = currentWeight + v.probability

		if randomWeight <= currentWeight then
			return k
		end
	end

	return false
end

addEventHandler("onVehicleExit", getRootElement(),
	function (sourceElement)
		--local pedVehicle = getPedOccupiedVehicle(sourceElement)
		--if getElementModel(pedVehicle) == 453 then 
			setElementFrozen(sourceElement, false)
		--end
	end 
)

function generateLoot(shipElement)
	if isElement(shipElement) then
		local itemCount = math.random(2, 8)

		if itemCount <= exports.see_items:getFreeSlotCount(shipElement) then
			local lootItems = {}

			for i = 1, itemCount do
				local lootRarity = chooseRandomLootType()

				if lootRarity then
					local selectedLoot = availableLootItems[lootRarity]
					local selectedItem = selectedLoot.items[math.random(1, #selectedLoot.items)]

					if selectedItem then
						if selectedItem == 299 then -- Blueprint
							table.insert(lootItems, {selectedItem, 1, math.random(3, 17), false, false, lootRarity})
						elseif exports.see_items:isWeaponItem(selectedItem) then
							table.insert(lootItems, {selectedItem, 1, false, false, math.random(25, 75), lootRarity})
						elseif exports.see_items:isAmmoItem(selectedItem) then
							table.insert(lootItems, {selectedItem, math.random(5, 205), false, false, false, lootRarity})
						else
							table.insert(lootItems, {selectedItem, 1, false, false, false, lootRarity})
						end
					end
				end
			end

			return lootItems, "succees"
		else
			return false, "not_enough_free_space"
		end
	end

	return false
end

addEventHandler("onMarkerHit", getResourceRootElement(),
	function (hitElement, matchingDimension)
		if matchingDimension then
			if isElement(hitElement) then
				if getElementType(hitElement) == "player" then
					local currentVehicle = getPedOccupiedVehicle(hitElement)

					if currentVehicle then
						if getElementModel(currentVehicle) == 453 then
							local numOfCrates = getElementData(currentVehicle, "numOfCrates") or 0

							if numOfCrates > 0 then
								local unloadInProgress = false

								setElementVelocity(currentVehicle, 0, 0, 0)

								for crateIndex = 1, numOfCrates do
									local lootItems, generationState = generateLoot(currentVehicle)

									if generationState then
										if generationState == "succees" then
											if lootItems then
												if not unloadInProgress then
													unloadInProgress = true

													outputChatBox("#3d7abc[StrongMTA - Kikötő]: #ffffffMegkezdődött a lerakodás. Kérlek várj!", hitElement, 255, 255, 255, true)
													setTimer(
														function ()
															if isElement(hitElement) then
																outputChatBox("#3d7abc[StrongMTA - Kikötő]: #ffffffBefejeződött a lerakodás. A tárgyakat a hajó csomagterében találod!", hitElement, 255, 255, 255, true)
															end

															if isElement(currentVehicle) then
																setElementFrozen(currentVehicle, false)
															end
														end,
													1000 * numOfCrates + 500 * #lootItems, 1)

													setElementFrozen(currentVehicle, true)
													setElementData(currentVehicle, "numOfCrates", 0)
												end

												for i = 1, #lootItems do
													local itemId, amount, data1, data2, data3, lootRarity = unpack(lootItems[i])

													if exports.see_items:giveItem(currentVehicle, itemId, amount, false, data1, data2, data3) then
														exports.see_logs:logCommand(hitElement, "weaponLootItem", {
															itemId .. " (" .. exports.see_items:getItemName(itemId) .. ")",
															amount,
															lootRarity
														})
													end
												end
											end
										elseif generationState == "not_enough_free_space" then
											if crateIndex == 1 then
												exports.see_hud:showInfobox(hitElement, "e", "Nincs elég hely a hajó csomagterében!")
												break
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
)
