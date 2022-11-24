connection = false

local rentTimeDuration = 60 * 60 * 24 * 7 -- 7 nap
local dayTimeDuration = 60 * 60 * 24 -- 24 óra

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		if connection then
			dbQuery(loadAllInterior, connection, "SELECT * FROM interiors")
		end

		setTimer(processRentedInteriors, 1000 * 60 * 30, 0)
	end
)

function loadAllInterior(queryHandle)
	local resultRows, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)

	if resultRows then
		for i, v in ipairs(resultRows) do
			loadInterior(v.interiorId, v)
		end
	end
end

function loadInterior(interiorId, interiorData, syncTheInterior)
	if interiorId and interiorData then
		if interiorData.deleted == "Y" then
			deletedInteriors[interiorId] = true
			availableInteriors[interiorId] = nil
		else
			if not availableInteriors[interiorId] then
				availableInteriors[interiorId] = {}
			end

			for k, v in pairs(interiorData) do
				parseInteriorData(interiorId, k, v)
			end

			if interiorData.renewalTime > 0 and getRealTime().timestamp > interiorData.renewalTime then
				unownInterior(interiorId)
			end

			if syncTheInterior then
				triggerClientEvent("createInterior", resourceRoot, availableInteriors[interiorId], interiorId)
			end
		end

		return true
	end

	return false
end

addEvent("requestInteriors", true)
addEventHandler("requestInteriors", getRootElement(),
	function ()
		if isElement(source) then
			triggerClientEvent(source, "requestInteriors", source, availableInteriors, deletedInteriors)
		end
	end
)

function requestInteriors(sourcePlayer)
	if isElement(sourcePlayer) then
		local characterId = getElementData(sourcePlayer, "char.ID")

		if characterId then
			local interiorsTable = {}
			
			for k, v in pairs(availableInteriors) do
				if v.ownerId == characterId then
					table.insert(interiorsTable, {
						interiorId = k,
						data = v
					})
				end
			end
			
			return interiorsTable
		end
	end
	
	return false
end

function warpElement(sourceElement, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension)
	if isElement(sourceElement) then
		local elementType = getElementType(sourceElement)

		setElementPosition(sourceElement, posX, posY, posZ)

		if elementType == "vehicle" then
			setElementVelocity(sourceElement, 0, 0, 0)
			setElementAngularVelocity(sourceElement, 0, 0, 0)
			setElementRotation(sourceElement, rotX, rotY, rotZ)
		else
			setElementRotation(sourceElement, rotX, rotY, rotZ, "default", true)
			setCameraInterior(sourceElement, interior)
		end

		setElementInterior(sourceElement, interior)
		setElementDimension(sourceElement, dimension)

		if elementType == "player" then
			setCameraTarget(sourceElement, sourceElement)
		end
	end
end

addEvent("editInterior", true)
addEventHandler("editInterior", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			local int = availableInteriors[interiorId]

			if int then
				if int.editable ~= "N" then
					local playersTable = getElementsByType("player")

					for i = 1, #playersTable do
						local playerElement = playersTable[i]

						if isElement(playerElement) then
							local customInterior = getElementData(playerElement, "currentCustomInterior") or 0

							if customInterior > 0 and customInterior == interiorId then
								warpElement(playerElement, int.entrance.position[1], int.entrance.position[2], int.entrance.position[3], int.entrance.rotation[1], int.entrance.rotation[2], int.entrance.rotation[3], int.entrance.interior, int.entrance.dimension)
								
								exports.see_hud:showInfobox(playerElement, "i", "Az interior szerkesztés alatt áll.\nEzért automatikusan kikerültél az ingatlanból.")
							end
						end
					end

					exports.see_interioredit:loadInterior(source, interiorId, true, true)
				end
			end
		end
	end
)

addEvent("warpAnimal", true)
addEventHandler("warpAnimal", getRootElement(),
	function (warpData)
		if isElement(source) and client and client == source then
			local characterId = getElementData(source, "char.ID")

			if characterId then
				local animalElement = getElementByID("animal_" .. characterId)

				if isElement(animalElement) then
					local interiorId = datas.id

					if interiorId then
						if availableInteriors[interiorId].locked == "N" then
							warpElement(animalElement, warpData.posX, warpData.posY, warpData.posZ, warpData.rotX, warpData.rotY, warpData.rotZ, warpData.interior, warpData.dimension)
						end
					end
				end
			end
		end
	end
)

addEvent("warpPlayer", true)
addEventHandler("warpPlayer", getRootElement(),
	function (warpData, interiorId, colShapeType)
		if isElement(source) and client and client == source then
			if interiorId then
				local int = availableInteriors[interiorId]

				if int then
					if int.locked == "N" then
						local playersTable = getElementsByType("player")

						for i = 1, #playersTable do
							local playerElement = playersTable[i]

							if isElement(playerElement) then
								local editingInterior = getElementData(playerElement, "editingInterior") or 0

								if editingInterior > 0 and editingInterior == interiorId then
									outputChatBox("#d75959[Ingatlan]: #ffffffAz ingatlan szerkesztés alatt áll.", source, 255, 255, 255, true)
									triggerClientEvent(source, "playInteriorSound", source, "locked")
									return
								end
							end
						end

						local currentVehicle = getPedOccupiedVehicle(source)
						local affectedElements = {}
						local warpTimeInterval = 50

						if isElement(currentVehicle) then
							warpTimeInterval = 250
							fadeCamera(source, false, 0)

							for i = 0, getVehicleMaxPassengers(currentVehicle) do
								local playerElement = getVehicleOccupant(currentVehicle, i)

								if isElement(playerElement) then
									fadeCamera(playerElement, false, 0)
									warpPedIntoVehicle(playerElement, currentVehicle, i)
									table.insert(affectedElements, playerElement)
								end
							end

							setElementFrozen(currentVehicle, true)
							setElementPosition(currentVehicle, warpData.posX, warpData.posY, warpData.posZ)

							table.insert(affectedElements, currentVehicle)
						else
							table.insert(affectedElements, source)
						end

						if colShapeType == "enter" then
							triggerClientEvent(source, "playInteriorSound", source, "intenter")
						else
							triggerClientEvent(source, "playInteriorSound", source, "intout")
						end

						setTimer(
							function ()
								for i = 1, #affectedElements do
									local sourceElement = affectedElements[i]

									if isElement(sourceElement) then
										local isCustomInterior = false

										if getElementType(sourceElement) == "player" then
											setElementData(sourceElement, "player.currentInterior", warpData.dimension)

											if colShapeType == "enter" then
												if warpData.editable ~= "N" then
													isCustomInterior = true
													exports.see_interioredit:loadInterior(sourceElement, interiorId)
												end
											end

											fadeCamera(sourceElement, true, 0)
										end

										warpElement(sourceElement, warpData.posX, warpData.posY, warpData.posZ, warpData.rotX, warpData.rotY, warpData.rotZ, warpData.interior, warpData.dimension)

										if not isCustomInterior then
											setElementFrozen(sourceElement, false)
										end
									end
								end
							end,
						warpTimeInterval, 1)
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffAz ingatlan ajtaja #d75959be van zárva.", source, 255, 255, 255, true)
						triggerClientEvent(source, "playInteriorSound", source, "locked")
					end
				end
			end
		end
	end
)

addEvent("buyInterior", true)
addEventHandler("buyInterior", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			if interiorId then
				local int = availableInteriors[interiorId]

				if int then
					local characterId = getElementData(source, "char.ID")

					if characterId then
						if exports.see_items:hasSpaceForItem(source, 2) then
							local buyPrice = int.price

							if int.type == "rentable" then
								buyPrice = buyPrice * 5
							end

							if exports.see_core:takeMoneyEx(source, buyPrice) then
								local renewalTime = 0

								if int.type == "rentable" then
									renewalTime = getRealTime().timestamp + rentTimeDuration
								end

								int.ownerId = characterId
								int.renewalTime = renewalTime

								triggerClientEvent("buyInterior", resourceRoot, interiorId, characterId)

								if not exports.see_items:hasItemWithData(source, 2, interiorId) then
									exports.see_items:giveItem(source, 2, 1, false, interiorId)
								end

								if int.type == "rentable" then
									exports.see_accounts:showInfo(source, "s", "Sikeresen kibérelted a kiválasztott ingatlant.")
									outputChatBox("#3d7abc[Ingatlan]: #ffffffSikeresen kibérelted a kiválasztott ingatlant.", source, 255, 255, 255, true)
								else
									exports.see_accounts:showInfo(source, "s", "Sikeresen megvásároltad a kiválasztott ingatlant.")
									outputChatBox("#3d7abc[Ingatlan]: #ffffffSikeresen megvásároltad a kiválasztott ingatlant.", source, 255, 255, 255, true)
								end

								dbExec(connection, "UPDATE interiors SET ownerId = ?, renewalTime = ? WHERE interiorId = ?", characterId, renewalTime, interiorId)
							else
								if int.type == "rentable" then
									outputChatBox("#d75959[Ingatlan]: #ffffffNincs elég pénzed, hogy kifizesd a bérleti díjat és kauciót.", source, 255, 255, 255, true)
								else
									outputChatBox("#d75959[Ingatlan]: #ffffffNincs elég pénzed az ingatlan megvásárlásához. (#32b3ef" .. formatNumber(int.price) .. " $#ffffff)", source, 255, 255, 255, true)
								end
							end
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffNem fér el az inventorydban a kulcs!", source, 255, 255, 255, true)
						end
					end
				end
			end
		end
	end
)

addEvent("tryToRenewalRent", true)
addEventHandler("tryToRenewalRent", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			if interiorId then
				local int = availableInteriors[interiorId]

				if int then
					if int.type == "rentable" then
						local characterId = getElementData(source, "char.ID")

						if characterId then
							if int.ownerId == characterId then
								local currentTimestamp = getRealTime().timestamp

								if int.renewalTime - dayTimeDuration < currentTimestamp then
									if exports.see_core:takeMoneyEx(source, int.price) then
										local renewalTime = currentTimestamp + rentTimeDuration

										int.renewalTime = renewalTime

										exports.see_accounts:showInfo(source, "s", "Sikeresen meghosszabítottad a bérleted 1 héttel!")
										outputChatBox("#3d7abc[Ingatlan]: #ffffffSikeresen meghosszabítottad a bérleted 1 héttel!", source, 255, 255, 255, true)

										dbExec(connection, "UPDATE interiors SET renewalTime = ? WHERE interiorId = ?", renewalTime, interiorId)
									else
										outputChatBox("#d75959[Ingatlan]: #ffffffNincs elég pénzed, hogy kifizesd a bérleti díjat.", source, 255, 255, 255, true)
									end
								else
									outputChatBox("#d75959[Ingatlan]: #ffffffMég nem tudod meghosszabítani a bérleted. (Maximum 1 nappal a lejárta előtt lehet)", source, 255, 255, 255, true)
								end
							end
						end
					end
				end
			end
		end
	end
)

addEvent("unRentInterior", true)
addEventHandler("unRentInterior", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			if interiorId then
				local int = availableInteriors[interiorId]

				if int then
					if int.type == "rentable" then
						local characterId = getElementData(source, "char.ID")

						if characterId then
							if characterId == int.ownerId then
								if unownInterior(interiorId) then
									triggerClientEvent("resetInterior", source, interiorId)
									exports.see_core:giveMoney(source, int.price * 4)

									exports.see_accounts:showInfo(source, "s", "Sikeresen felmondtad az ingatlan bérlését!")
									outputChatBox("#3d7abc[Ingatlan]: #ffffffSikeresen felmondtad az ingatlan bérlését!", source, 255, 255, 255, true)

									dbExec(connection, "UPDATE interiors SET ownerId = 0, renewalTime = 0, locked = 'Y' WHERE interiorId = ?", interiorId)
								end
							end
						end
					end
				end
			end
		end
	end
)

function unownInterior(interiorId)
	if interiorId then
		local int = availableInteriors[interiorId]

		if int then
			local playersTable = getElementsByType("player")

			for i = 1, #playersTable do
				local playerElement = playersTable[i]

				if isElement(playerElement) then
					local characterId = getElementData(playerElement, "char.ID")

					if characterId then
						if int.ownerId == characterId then
							local itemsTable = exports.see_items:getElementItems(playerElement) or {}

							for k, v in pairs(itemsTable) do
								if v.itemId == 2 and tonumber(v.data1) == interiorId then
									exports.see_items:takeItem(playerElement, "dbID", v.dbID)
									break
								end
							end

							break
						end
					end
				end
			end

			int.ownerId = 0
			int.renewalTime = 0
			int.lastReport = "0"
			int.deleted = "N"

			if int.type == "rentable" then
				int.locked = "Y"
			end

			dbExec(connection, "DELETE FROM items WHERE itemId = 2 AND data1 = ? AND ownerId = ?", interiorId, int.ownerId)
			dbExec(connection, "UPDATE interiors SET deleted = 'N', ownerId = 0, renewalTime = 0, lastReport = '0', locked = ? WHERE interiorId = ?", int.locked, interiorId)

			return true
		else
			return false
		end
	else
		return false
	end

	return false
end

function processRentedInteriors()
	local currentTimestamp = getRealTime().timestamp
	local playersTable = getElementsByType("player")

	for k, v in pairs(availableInteriors) do
		if v.ownerId > 0 and v.renewalTime > 0 then
			local ownerPlayer = false

			for i = 1, #playersTable do
				local playerElement = playersTable[i]

				if isElement(playerElement) then
					local characterId = getElementData(playerElement, "char.ID")

					if characterId then
						if characterId == v.ownerId then
							ownerPlayer = playerElement
							break
						end
					end
				end
			end

			if currentTimestamp >= v.renewalTime then
				if unownInterior(k) then
					triggerClientEvent("resetInterior", resourceRoot, k)
				end
			end

			if isElement(ownerPlayer) then
				if currentTimestamp >= v.renewalTime then
					exports.see_accounts:showInfo(ownerPlayer, "e", "Nem fizetted ki az albérleted, ezért lejárt!")
					outputChatBox("#d75959[Ingatlan]:#ffffff Nem fizetted ki az albérleted, ezért lejárt!", ownerPlayer, 255, 255, 255, true)
				else
					if v.renewalTime - dayTimeDuration <= currentTimestamp then
						local timeLeft = math.floor((v.renewalTime - currentTimestamp) % dayTimeDuration / 3600) + 1

						if timeLeft then
							exports.see_accounts:showInfo(ownerPlayer, "e", "Hamarosan lejár az albérleted, részletek a chatboxban!")
							outputChatBox("#d75959[Ingatlan]:#ffffff Hamarosan lejár az albérleted! (Még #d75959kb. " .. timeLeft .. " óra#ffffff)", ownerPlayer, 255, 255, 255, true)
							outputChatBox("#d75959[Ingatlan]:#ffffff Menj az ingatlanhoz, és írd be a #3d7abc/rent#ffffff parancsot, hogy meghosszabítsd, vagy mondd le az albérletet a #d75959/unrent#ffffff paranccsal. (InteriorID: #598ed7" .. k .. "#ffffff)", ownerPlayer, 255, 255, 255, true)
						end
					end
				end
			end
		end
	end
end

addEvent("lockInterior", true)
addEventHandler("lockInterior", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			if interiorId then
				local int = availableInteriors[interiorId]

				if int then
					local adminDuty = getElementData(source, "adminDuty") or 0
					local hasKey = exports.see_items:hasItemWithData(source, 2, interiorId)

					if adminDuty == 1 or hasKey then
						local isLocked = "N"

						if int.locked == "N" then
							isLocked = "Y"
						end

						int.locked = isLocked

						if isLocked == "N" then
							outputChatBox("#3d7abc[Ingatlan]: #ffffffSikeresen #3d7abckinyitottad #ffffffaz ingatlan ajtaját.", source, 255, 255, 255, true)
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffSikeresen #d75959bezártad #ffffffaz ingatlan ajtaját.", source, 255, 255, 255, true)
						end

						triggerClientEvent(source, "playInteriorSound", source, "openclose")
						triggerClientEvent("lockInterior", source, interiorId, isLocked)

						dbExec(connection, "UPDATE interiors SET locked = ? WHERE interiorId = ?", isLocked, interiorId)

						if eventName then
							exports.see_logs:logCommand(source, eventName, {
								"id: " .. interiorId,
								"locked: " .. isLocked,
								"adminDuty: " .. tostring(adminDuty)
							})
						end
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffNincs kulcsod ehhez az ingatlanhoz.", source, 255, 255, 255, true)
					end
				end
			end
		end
	end
)

addEvent("useDoorRammer", true)
addEventHandler("useDoorRammer", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			if interiorId then
				local int = availableInteriors[interiorId]

				if int then
					if int.locked == "Y" then
						int.locked = "N"
						triggerClientEvent("lockInterior", source, interiorId, "N")
						dbExec(connection, "UPDATE interiors SET locked = 'N' WHERE interiorId = ?", interiorId)
					end
					
					triggerClientEvent("playRamSound", source, interiorId)
				end
			end
		end
	end
)

addEvent("useDoorBell", true)
addEventHandler("useDoorBell", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			if interiorId then
				if availableInteriors[interiorId] then
					triggerClientEvent("playBell", source, interiorId)
				end
			end
		end
	end
)

addEvent("useDoorKnocking", true)
addEventHandler("useDoorKnocking", getRootElement(),
	function (interiorId)
		if isElement(source) and client and client == source then
			if interiorId then
				if availableInteriors[interiorId] then
					triggerClientEvent("playKnocking", source, interiorId)
				end
			end
		end
	end
)