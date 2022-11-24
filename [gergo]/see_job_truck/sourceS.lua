local playerWorkStates = {}
local playerCarrierObjects = {}

addEvent("tryToStartTruckerJob", true)
addEventHandler("tryToStartTruckerJob", getRootElement(),
	function ()
		if isElement(client) then
			local currentWorkState = playerWorkStates[client]

			if not currentWorkState then
				local startDestinationCompanies = {}
				local finalDestinationCompanies = {}

				for i = 1, #companies do
					if companies[i].type == "pick" then
						table.insert(startDestinationCompanies, i)
					elseif companies[i].type == "drop" then
						table.insert(finalDestinationCompanies, i)
					end
				end

				local truckerJob = {}

				if not tonumber(truckerJob[1]) then
					truckerJob[1] = math.random(1, 2)
				end

				local numOfRoutes = truckerJob[1]
				local maxPickableItem = 8
				local pickableItems = {}

				playerWorkStates[client] = {}
				playerWorkStates[client].startDestinations = {}
				playerWorkStates[client].finalDestinations = {}

				-- ** Pick start destinations and items
				for i = 1, numOfRoutes do
					if not tonumber(truckerJob[2]) then
						truckerJob[2] = math.random(1, #startDestinationCompanies - 1)
					end

					local selectedCompanyIndex = startDestinationCompanies[truckerJob[2]]
					local selectedCompany = companies[selectedCompanyIndex]
					local availableCompanyIndexes = shallowcopy(startDestinationCompanies)

					startDestinationCompanies = {}

					for j = 1, #availableCompanyIndexes do
						if availableCompanyIndexes[j] ~= selectedCompanyIndex then
							table.insert(startDestinationCompanies, availableCompanyIndexes[j])
						end
					end

					if math.random(100) > 25 then
						if not tonumber(truckerJob[3]) then
							truckerJob[3] = math.random(1, #selectedCompany.items)
						end
					else
						truckerJob[3] = math.random(1, #selectedCompany.items)
					end

					local selectedItemIndex = selectedCompany.items[truckerJob[3]]
					local numOfPickableItems = truckerJob[4]

					if not tonumber(numOfPickableItems) then
						numOfPickableItems = math.random(3, 6)
						truckerJob[4] = numOfPickableItems
					end

					if numOfRoutes > 1 then
						if i == 2 then
							numOfPickableItems = maxPickableItem
						else
							maxPickableItem = maxPickableItem - numOfPickableItems
						end
					else
						numOfPickableItems = maxPickableItem
					end

					if not pickableItems[selectedItemIndex] then
						pickableItems[selectedItemIndex] = 0
					end

					pickableItems[selectedItemIndex] = pickableItems[selectedItemIndex] + numOfPickableItems

					table.insert(playerWorkStates[client].startDestinations, {selectedCompanyIndex, selectedItemIndex, numOfPickableItems})
				end

				-- ** Pick final destinations to selected items
				local itemCounter = 0

				for itemIndex, numOfItems in pairs(pickableItems) do
					local availableFinalDestinations = {}

					for i = 1, #finalDestinationCompanies do
						local companyIndex = finalDestinationCompanies[i]

						for j = 1, #companies[companyIndex].items do
							if companies[companyIndex].items[j] == itemIndex then
								table.insert(availableFinalDestinations, companyIndex)
							end
						end
					end

					itemCounter = itemCounter + 1

					if not tonumber(truckerJob[4 + itemCounter]) then
						truckerJob[4 + itemCounter] = math.random(1, #availableFinalDestinations)
					end

					local selectedCompanyIndex = availableFinalDestinations[truckerJob[4 + itemCounter]]
					local availableCompanyIndexes = shallowcopy(finalDestinationCompanies)

					finalDestinationCompanies = {}

					for i = 1, #availableCompanyIndexes do
						if availableCompanyIndexes[i] ~= selectedCompanyIndex then
							table.insert(finalDestinationCompanies, availableCompanyIndexes[i])
						end
					end

					table.insert(playerWorkStates[client].finalDestinations, {selectedCompanyIndex, itemIndex, numOfItems})
				end

				currentWorkState = playerWorkStates[client]
			end

			triggerClientEvent(client, "onTruckerJobStarted", client, currentWorkState.startDestinations, currentWorkState.finalDestinations)
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "yankeeState" then
			local dataVal = getElementData(source, dataName) or "close"

			if dataVal ~= "close" then
				setElementFrozen(source, true)
			else
				setElementFrozen(source, false)
			end
		elseif dataName == "carrierActive" then
			if playerCarrierObjects[source] then
				if isElement(playerCarrierObjects[source]) then
					destroyElement(playerCarrierObjects[source])
				end

				playerCarrierObjects[source] = nil
			end

			if getElementData(source, dataName) then
				playerCarrierObjects[source] = createObject(CARRIER_MODEL, 0, 0, 0)

				attachElements(playerCarrierObjects[source], source, 0, 0.58, -1.05, 8.5, 0, 0)
				setObjectScale(playerCarrierObjects[source], 0.95, 0.975, 0.975)
				setElementCollisionsEnabled(playerCarrierObjects[source], false)

				setElementData(source, "carrierObject", playerCarrierObjects[source])
			else
				removeElementData(source, "carrierObject")
			end
		elseif dataName == "char.Job" then
			if playerCarrierObjects[source] then
				if isElement(playerCarrierObjects[source]) then
					destroyElement(playerCarrierObjects[source])
				end

				playerCarrierObjects[source] = nil
			end
		end
	end
)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if playerWorkStates[source] then
			playerWorkStates[source] = nil
		end

		if playerCarrierObjects[source] then
			if isElement(playerCarrierObjects[source]) then
				destroyElement(playerCarrierObjects[source])
			end

			playerCarrierObjects[source] = nil
		end
	end
)

addEvent("@Í@Äí{€&ł&äđ", true)
addEventHandler("@Í@Äí{€&ł&äđ", getRootElement(),
	function (rewardAmount)
		if isElement(source) and client and client == source then 
			if getElementData(source, "char.Job") == 2 then 
				if rewardAmount then
					exports.see_core:giveMoney(source, rewardAmount, "truckJobCash")

					if playerCarrierObjects[source] then
						if isElement(playerCarrierObjects[source]) then
							destroyElement(playerCarrierObjects[source])
						end

						playerCarrierObjects[source] = nil
					end

					playerWorkStates[source] = nil
				end
			end
		end
	end
)

addEvent("attachItemToTruck", true)
addEventHandler("attachItemToTruck", getRootElement(),
	function (modelId, position, rotation, vehicle, itemId, itemHealth)
		if isElement(vehicle) then
			local placedObjects = getElementData(vehicle, "truckPlacedObjects") or {}

			if placedObjects then
				local offsetPosX, offsetPosY, offsetPosZ, offsetRotX, offsetRotY, offsetRotZ = attachRotationAdjusted(position, rotation, vehicle)
				table.insert(placedObjects, {modelId, offsetPosX, offsetPosY, offsetPosZ, offsetRotX, offsetRotY, offsetRotZ, itemId, itemHealth})
			end

			setElementData(vehicle, "truckPlacedObjects", placedObjects)
		end
	end
)

function attachRotationAdjusted(position, rotation, vehicle)
	local frPosX, frPosY, frPosZ = unpack(position)
	local frRotX, frRotY, frRotZ = unpack(rotation)

	local toPosX, toPosY, toPosZ = getElementPosition(vehicle)
	local toRotX, toRotY, toRotZ = getElementRotation(vehicle)

	local offsetPosX = frPosX - toPosX
	local offsetPosY = frPosY - toPosY
	local offsetPosZ = frPosZ - toPosZ

	local offsetRotX = frRotX - toRotX
	local offsetRotY = frRotY - toRotY
	local offsetRotZ = frRotZ - toRotZ

	offsetPosX, offsetPosY, offsetPosZ = applyInverseRotation(offsetPosX, offsetPosY, offsetPosZ, toRotX, toRotY, toRotZ)

	return offsetPosX, offsetPosY, offsetPosZ, offsetRotX, offsetRotY, offsetRotZ
end

function applyInverseRotation(x, y, z, rx, ry, rz)
	rx = math.rad(rx)
	ry = math.rad(ry)
	rz = math.rad(rz)

	local tempY = y
	y =  math.cos(rx) * tempY + math.sin(rx) * z
	z = -math.sin(rx) * tempY + math.cos(rx) * z

	local tempX = x
	x =  math.cos(ry) * tempX - math.sin(ry) * z
	z =  math.sin(ry) * tempX + math.cos(ry) * z

	tempX = x
	x =  math.cos(rz) * tempX + math.sin(rz) * y
	y = -math.sin(rz) * tempX + math.cos(rz) * y

	return x, y, z
end
