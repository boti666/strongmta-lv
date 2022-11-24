local connection = false
local loadedAnimals = {}
local spawnedAnimals = {}
local petSkinTypes = {
	["Husky"] = 9,
	["Rottweiler"] = 296,
	["Doberman"] = 297,
	["Bull Terrier"] = 298,
	["Boxer"] = 257,
	["Francia Bulldog"] = 256,
}
local animalDoAction = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		dbQuery(loadAllAnimals, connection, "SELECT * FROM animals")
	end)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(spawnedAnimals) do
			if isElement(spawnedAnimals[k]) then
				saveAnimal(spawnedAnimals[k])
			end
		end
	end)

function loadAllAnimals(qh)
	local result = dbPoll(qh, 0)

	if result then
		for k, v in pairs(result) do
			loadedAnimals[v.animalId] = v
		end
	end
end

function loadNewAnimal(qh)
	local result, rows, animalId = dbPoll(qh, 0)

	if tonumber(animalId) then
		dbQuery(
			function (qh)
				local result = dbPoll(qh, 0)

				if result then
					loadedAnimals[result[1].animalId] = result[1]
				end
			end,
		connection, "SELECT * FROM animals WHERE animalId = ?", animalId)
	end

	dbFree(qh)
end

function saveAnimal(animalElement)
	local animalId = getElementData(animalElement, "animal.animalId")
	if animalId then
		loadedAnimals[animalId].health = getElementHealth(animalElement)
		loadedAnimals[animalId].hunger = getElementData(animalElement, "animal.hunger") or 100
		loadedAnimals[animalId].love = getElementData(animalElement, "animal.love") or 100

		dbExec(connection, "UPDATE animals SET health = ?, hunger = ?, love = ? WHERE animalId = ?", loadedAnimals[animalId].health, loadedAnimals[animalId].hunger, loadedAnimals[animalId].love, animalId)
	end
end

addEventHandler("onElementDataChange", getRootElement(),
	function (data)
		if getElementType(source) == "ped" then
			local animalId = getElementData(source, "animal.animalId")
			if animalId then
				if loadedAnimals[animalId] then
					if data == "animal.hunger" or data == "animal.love" or data == "animal.ownerId" then
						loadedAnimals[animalId][data] = getElementData(source, data)
					end
				end
			end
		end
	end)

addEventHandler("onPedWasted", getResourceRootElement(),
	function ()
		local animalId = getElementData(source, "animal.animalId")
		if animalId then
			loadedAnimals[animalId].health = 0
		end
	end)

addEvent("buyPet", true)
addEventHandler("buyPet", getRootElement(),
	function (petName, petType, buyPrice)
		if petName and petType then
			local characterId = tonumber(getElementData(source, "char.ID"))
			local accountId = tonumber(getElementData(source, "char.accID"))

			if characterId and accountId then
				dbQuery(
					function (qh, thePlayer)
						if isElement(thePlayer) then
							local result = dbPoll(qh, 0)

							if result then
								local row = result[1]
								local newPP = row.premiumPoints - buyPrice

								if newPP < 0 then
									exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég prémium pontod a kutya megvásárlásához!")
									triggerClientEvent(thePlayer, "buyDogNoPP", thePlayer)
								else
									setElementData(thePlayer, "acc.premiumPoints", newPP)

									dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", newPP, accountId)
									dbQuery(loadNewAnimal, connection, "INSERT INTO animals (ownerId, type, name) VALUES (?,?,?)", characterId, petType, petName)

									exports.see_accounts:showInfo(thePlayer, "s", "Sikeres vásárlás!")
									triggerClientEvent(thePlayer, "buyDogOK", thePlayer)

									exports.see_logs:addLogEntry("premiumshop", {
										accountId = accountId,
										characterId = characterId,
										itemId = "pet",
										amount = 1,
										oldPP = row.premiumPoints,
										newPP = newPP
									})
								end
							end
						end
					end,
				{source}, connection, "SELECT premiumPoints FROM accounts WHERE accountId = ? LIMIT 1", accountId)
			end
		end
	end)

addEvent("buyPetRevive", true)
addEventHandler("buyPetRevive", getRootElement(),
	function (animalId)
		if animalId then
			local characterId = tonumber(getElementData(source, "char.ID"))
			local accountId = tonumber(getElementData(source, "char.accID"))

			if characterId and accountId then
				dbQuery(
					function (qh, thePlayer)
						if isElement(thePlayer) then
							local result = dbPoll(qh, 0)

							if result then
								local row = result[1]
								local newPP = row.premiumPoints - 100

								if newPP < 0 then
									exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég prémium pontod a kutya felélesztéséhez!")
									triggerClientEvent(thePlayer, "buyPetReviveNoPP", thePlayer)
								else
									setElementData(thePlayer, "acc.premiumPoints", newPP)

									if loadedAnimals[animalId] then
										loadedAnimals[animalId].health = 100
										loadedAnimals[animalId].hunger = 100
										loadedAnimals[animalId].love = 100

										if isElement(spawnedAnimals[animalId]) then
											setElementData(spawnedAnimals[animalId], "animal.health", 100)
											setElementData(spawnedAnimals[animalId], "animal.hunger", 100)
											setElementData(spawnedAnimals[animalId], "animal.love", 100)
										end
									end

									dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", newPP, accountId)
									dbExec(connection, "UPDATE animals SET health = 100, hunger = 100, love = 100 WHERE animalId = ?", animalId)

									if isElement(spawnedAnimals[animalId]) then
										destroyElement(spawnedAnimals[animalId])
									end
									spawnedAnimals[animalId] = nil

									exports.see_accounts:showInfo(thePlayer, "s", "Sikeresen felélesztetted a kutyád!")
									triggerClientEvent(thePlayer, "buyPetReviveOK", thePlayer)

									exports.see_logs:addLogEntry("premiumshop", {
										accountId = accountId,
										characterId = characterId,
										itemId = "petrevive",
										amount = 1,
										oldPP = row.premiumPoints,
										newPP = newPP
									})
								end
							end
						end
					end,
				{source}, connection, "SELECT premiumPoints FROM accounts WHERE accountId = ? LIMIT 1", accountId)
			end
		end
	end)

addEvent("requestAnimals", true)
addEventHandler("requestAnimals", getRootElement(),
	function (characterId)
		if isElement(source) and client and client == source and characterId then
			local animals = {}

			for k, v in pairs(loadedAnimals) do
				if v.ownerId == characterId then
					table.insert(animals, v)
				end
			end

			triggerClientEvent(source, "receiveAnimals", source, animals)
		end
	end)

addEvent("renamePet", true)
addEventHandler("renamePet", getRootElement(),
	function (animalId, newName)
		if isElement(source) and client and client == source then 
			if animalId and newName then
				if loadedAnimals[animalId] then
					local items = exports.see_items:getElementItems(source)
					local item = false

					for k, v in pairs(items) do
						if v.itemId == 373 then
							item = v
							break
						end
					end

					if item then
						exports.see_items:takeItem(source, "dbID", item.dbID)

						loadedAnimals[animalId].name = newName
						dbExec(connection, "UPDATE animals SET name = ? WHERE animalId = ?", newName, animalId)

						if isElement(spawnedAnimals[animalId]) then
							setElementData(spawnedAnimals[animalId], "visibleName", loadedAnimals[animalId].name)
						end

						exports.see_accounts:showInfo(source, "s", "Sikeresen átnevezted a petet!")
						triggerClientEvent(source, "buyDogOK", source)
					else
						exports.see_accounts:showInfo(source, "e", "Nincs kutyaátnevező kártyád.")
					end
				end
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		local characterId = getElementData(source, "char.ID")
		if characterId then
			local animalElement = getElementByID("animal_" .. characterId)
			if isElement(animalElement) then
				local animalId = getElementData(animalElement, "animal.animalId")
				if animalId then
					if spawnedAnimals[animalId] then
						if isElement(spawnedAnimals[animalId]) then
							saveAnimal(spawnedAnimals[animalId])
							destroyElement(spawnedAnimals[animalId])
						end
						spawnedAnimals[animalId] = nil
					end
				end
			end
		end
	end
)

addEvent("spawnAnimal", true)
addEventHandler("spawnAnimal", getRootElement(),
	function (animalId)
		if isElement(source) and client and client == source then 
			if animalId then
				if loadedAnimals[animalId] then
					if not spawnedAnimals[animalId] then
						triggerClientEvent(source, "toggleDashboardOff", source)

						if loadedAnimals[animalId].health > 0 then
							local playerPosX, playerPosY, playerPosZ = getElementPosition(source)
							local playerRotX, playerRotY, playerRotZ = getElementRotation(source)

							playerPosX = playerPosX + math.cos(math.rad(playerRotZ)) * 1
							playerPosY = playerPosY + math.sin(math.rad(playerRotZ)) * 1

							spawnedAnimals[animalId] = createPed(petSkinTypes[loadedAnimals[animalId].type], playerPosX, playerPosY, playerPosZ, playerRotZ)

							if isElement(spawnedAnimals[animalId]) then
								setElementInterior(spawnedAnimals[animalId], getElementInterior(source))
								setElementDimension(spawnedAnimals[animalId], getElementDimension(source))

								setElementID(spawnedAnimals[animalId], "animal_" .. loadedAnimals[animalId].ownerId)
								setElementData(spawnedAnimals[animalId], "animal.animalId", animalId)
								setElementData(spawnedAnimals[animalId], "animal.ownerId", loadedAnimals[animalId].ownerId)

								setElementData(spawnedAnimals[animalId], "animal.hunger", loadedAnimals[animalId].hunger)
								setElementData(spawnedAnimals[animalId], "animal.love", loadedAnimals[animalId].love)

								if loadedAnimals[animalId].hunger <= 0 then
									setElementHealth(spawnedAnimals[animalId], 0)
								else
									setElementHealth(spawnedAnimals[animalId], loadedAnimals[animalId].health)
								end

								if loadedAnimals[animalId].love <= 0 then
									setElementData(spawnedAnimals[animalId], "animal.obedient", false)
								else
									setElementData(spawnedAnimals[animalId], "animal.obedient", true)
								end

								setElementData(spawnedAnimals[animalId], "visibleName", loadedAnimals[animalId].name)
								setElementData(spawnedAnimals[animalId], "pedNameType", loadedAnimals[animalId].type)
								setElementData(spawnedAnimals[animalId], "ped.isControllable", true)
								--setElementData(spawnedAnimals[animalId], "ped.walk_speed", "walk")
							end
						else
							exports.see_accounts:showInfo(source, "e", "Halott kutyát nem tudsz lespawnolni!")
						end
					end
				end
			end
		end
	end)

addEvent("destroyAnimal", true)
addEventHandler("destroyAnimal", getRootElement(),
	function (animalId)
		if animalId then
			if loadedAnimals[animalId] then
				triggerClientEvent(source, "toggleDashboardOff", source)

				if isElement(spawnedAnimals[animalId]) then
					saveAnimal(spawnedAnimals[animalId])
					destroyElement(spawnedAnimals[animalId])
				end

				spawnedAnimals[animalId] = nil
			end
		end
	end)

addEvent("animalStarvedToDeath", true)
addEventHandler("animalStarvedToDeath", getRootElement(),
	function (animalElement, animalId)
		if animalElement and animalId then
			if loadedAnimals[animalId] then
				loadedAnimals[animalId].health = 0
				setElementHealth(animalElement, 0)
			end
		end
	end)

addEvent("feedAnimal", true)
addEventHandler("feedAnimal", getRootElement(),
	function (animalElement, itemId)
		if animalElement and itemId then
			local animalId = getElementData(animalElement, "animal.animalId")
			local foodItem = exports.see_items:hasItem(source, itemId)

			if itemId == 163 then
				if not foodItem then
					outputChatBox("#d75959[StrongMTA - Pet]: #ffffffNincs nálad PPSnack.", source, 255, 255, 255, true)
					return
				end
			elseif itemId == 162 then
				if not foodItem then
					outputChatBox("#d75959[StrongMTA - Pet]: #ffffffNincs nálad Kutya snack.", source, 255, 255, 255, true)
					return
				end
			elseif itemId == 161 then
				if not foodItem then
					outputChatBox("#d75959[StrongMTA - Pet]: #ffffffNincs nálad Kutya táp.", source, 255, 255, 255, true)
					return
				end
			elseif itemId == 160 then
				if not foodItem then
					outputChatBox("#d75959[StrongMTA - Pet]: #ffffffNincs nálad Jutalom falat.", source, 255, 255, 255, true)
					return
				end
			end

			exports.see_items:takeItem(source, "dbID", foodItem.dbID)

			if itemId == 163 then
				setElementHealth(animalElement, 100)
				setElementData(animalElement, "animal.hunger", 100)
				setElementData(animalElement, "animal.love", 100)
				setElementData(animalElement, "animal.obedient", true)

				loadedAnimals[animalId].hunger = 100
				loadedAnimals[animalId].love = 100
			else
				local currentHunger = getElementData(animalElement, "animal.hunger") + math.random(20, 30)
				local currentLove = getElementData(animalElement, "animal.love") + math.random(1, 5)

				if currentHunger > 100 then
					currentHunger = 100
				end

				if currentLove > 100 then
					currentLove = 100
				end

				setElementData(animalElement, "animal.hunger", currentHunger)
				setElementData(animalElement, "animal.love", currentLove)

				loadedAnimals[animalId].hunger = currentHunger
				loadedAnimals[animalId].love = currentLove
			end

			if itemId == 163 then
				outputChatBox("#3d7abc[StrongMTA - Pet]: #ffffffAdtál a kutyának egy #3d7abcPPSnack#ffffffet.", source, 255, 255, 255, true)
				outputChatBox("#3d7abc[StrongMTA - Pet]: #ffffffA kutya minden szükségletét feltöltötte.", source, 255, 255, 255, true)
			elseif itemId == 162 then
				outputChatBox("#3d7abc[StrongMTA - Pet]: #ffffffAdtál a kutyának egy #3d7abcKutya snack#ffffffet.", source, 255, 255, 255, true)
			elseif itemId == 161 then
				outputChatBox("#3d7abc[StrongMTA - Pet]: #ffffffAdtál a kutyának egy #3d7abcKutya táp#ffffffot.", source, 255, 255, 255, true)
			elseif itemId == 160 then
				outputChatBox("#3d7abc[StrongMTA - Pet]: #ffffffAdtál a kutyának egy #3d7abcJutalom falat#ffffffot.", source, 255, 255, 255, true)
			end
		end
	end)

addEvent("setAnimationForAnimalPet", true)
addEventHandler("setAnimationForAnimalPet", getRootElement(),
	function (animalElement, state)
		if animalElement then
			if not animalDoAction[animalElement] then
				if state then
					animalDoAction[animalElement] = "caress"
					triggerClientEvent(getElementsByType("player"), "petSound", animalElement, "caress")

					setElementFrozen(source, true)
					setPedAnimation(source, "BOMBER", "bom_plant_loop", -1, true, false)

					setTimer(
						function (thePlayer)
							if isElement(thePlayer) then
								setElementFrozen(thePlayer, false)
								setPedAnimation(thePlayer, false)
							end

							animalDoAction[animalElement] = nil
						end,
					1000 * 7, 1, source)
				else
					animalDoAction[animalElement] = nil
					setPedAnimation(animalElement, false)
				end
			elseif animalDoAction[animalElement] == "caress" then
				if state then
					outputChatBox("#d75959[StrongMTA - Pet]: #ffffffNe buzeráld már szegény kutyát... Kikopik a szőre.", source, 255, 255, 255, true)
				end
			end
		end
	end)

addEvent("triggerBark", true)
addEventHandler("triggerBark", getRootElement(),
	function (animalElement)
		if isElement(source) and client and client == source then 
			if animalElement and client then
				if not animalDoAction[animalElement] then
					animalDoAction[animalElement] = "bark"
					triggerClientEvent(getElementsByType("player"), "petSound", animalElement, "bark")

					setTimer(
						function ()
							animalDoAction[animalElement] = nil
						end,
					10000, 1)

					exports.see_chat:localAction(animalElement, "(kutya) ugat")
				end
			end
		end
	end)

addEventHandler("onPlayerVehicleEnter", getRootElement(),
	function (vehicle, seat)
		local characterId = getElementData(source, "char.ID")
		if characterId then
			local animalElement = getElementByID("animal_" .. characterId)
			if isElement(animalElement) then
				local playerX, playerY, playerZ = getElementPosition(source)
				local animalX, animalY, animalZ = getElementPosition(animalElement)

				if getDistanceBetweenPoints3D(playerX, playerY, playerZ, animalX, animalY, animalZ) <= 10 then
					local playerInterior = getElementInterior(source)
					local animalInterior = getElementInterior(animalElement)

					if playerInterior == animalInterior then
						local playerDimension = getElementDimension(source)
						local animalDimension = getElementDimension(animalElement)

						if playerDimension == animalDimension then
							local currentTask = getElementData(animalElement, "ped.task.1")
							if currentTask then
								if currentTask[1] == "walkFollowElement" and currentTask[2] == source then
									for i = 1, getVehicleMaxPassengers(vehicle) do
										if not getVehicleOccupant(vehicle, i) then
											warpPedIntoVehicle(animalElement, vehicle, i)
											exports.see_chat:localAction(animalElement, "(kutya) beugrik a kocsiba.")
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
	end)

addEventHandler("onPlayerVehicleExit", getRootElement(),
	function (vehicle, seat, jacker, forcedByScript)
		if not forcedByScript then
			local characterId = getElementData(source, "char.ID")
			if characterId then
				local animalElement = getElementByID("animal_" .. characterId)
				if isElement(animalElement) then
					if isPedInVehicle(animalElement) then
						local vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(vehicle)
						local vehicleRotX, vehicleRotY, vehicleRotZ = getElementRotation(vehicle)

						if seat == 0 or seat == 2 then
							vehiclePosX = vehiclePosX + math.cos(math.rad(vehicleRotZ)) * -2
							vehiclePosY = vehiclePosY + math.sin(math.rad(vehicleRotZ)) * -2
						else
							vehiclePosX = vehiclePosX + math.cos(math.rad(vehicleRotZ)) * 2
							vehiclePosY = vehiclePosY + math.sin(math.rad(vehicleRotZ)) * 2
						end

						removePedFromVehicle(animalElement)

						setElementPosition(animalElement, vehiclePosX, vehiclePosY, vehiclePosZ)
						setElementInterior(animalElement, getElementInterior(source))
						setElementDimension(animalElement, getElementDimension(source))

						setPedTask(animalElement, {"walkFollowElement", source, 3})

						exports.see_chat:localAction(animalElement, "(kutya) kiugrik a kocsiból.")
					end
				end
			end
		end
	end)

function clearPedTasks(pedElement)
	if isElement(pedElement) then
		local thisTask = getElementData(pedElement, "ped.thisTask")
		if thisTask then

			local lastTask = getElementData(pedElement, "ped.lastTask")
			for currentTask = thisTask, lastTask do
				removeElementData(pedElement,"ped.task." .. currentTask)
				--setElementData(pedElement, "ped.task." .. currentTask, nil)
			end

			removeElementData(pedElement, "ped.thisTask")
			--setElementData(pedElement, "ped.thisTask", nil)
			removeElementData(pedElement, "ped.lastTask")
			--setElementData(pedElement, "ped.lastTask", nil)
			return true
		end
	else
		return false
	end
end

function setPedTask(pedElement, selectedTask)
	if isElement(pedElement) then
		clearPedTasks(pedElement)
		setElementData(pedElement, "ped.task.1", selectedTask)
		setElementData(pedElement, "ped.thisTask", 1)
		setElementData(pedElement, "ped.lastTask", 1)
		return true
	else
		return false
	end
end
