local screenX, screenY = guiGetScreenSize()

local interiorsLoaded = false
local standingMarker = false
local currentInteriorObject = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 2000, 1, "requestInteriors", localPlayer)
	end
)

function requestInteriors(player)
	if isElement(player) then
		local characterId = getElementData(player, "char.ID")

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

function createInterior(interiorId)
	local int = availableInteriors[interiorId]

	if int then
		if not int.ownerId then
			int.ownerId = 0
		end
		
		local state = "unSold"

		if int.ownerId > 0 then
			state = "sold"
		end
		
		int.enterPickup = createCoolMarker(int.entrance.position[1], int.entrance.position[2], int.entrance.position[3], int.type, state)
		
		if int.enterPickup then
			setCoolMarkerType(int.enterPickup, int.type, state)
			setElementInterior(int.enterPickup, int.entrance.interior)
			setElementDimension(int.enterPickup, int.entrance.dimension)
			setElementData(int.enterPickup, "interiorId", interiorId, false)
			setElementData(int.enterPickup, "colShapeType", "entrance", false)
		end
		
		int.exitPickup = createCoolMarker(int.exit.position[1], int.exit.position[2], int.exit.position[3], int.type, state)
		
		if int.exitPickup then
			setCoolMarkerType(int.exitPickup, int.type, state)
			setElementInterior(int.exitPickup, int.exit.interior)
			setElementDimension(int.exitPickup, int.exit.dimension)
			setElementData(int.exitPickup, "interiorId", interiorId, false)
			setElementData(int.exitPickup, "colShapeType", "exit", false)
		end
	end
end

function destroyInterior(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			for k, v in pairs(availableInteriors[interiorId]) do
				if isElement(v) then
					destroyElement(v)
				end
			end
			
			deletedInteriors[interiorId] = true
			availableInteriors[interiorId] = nil

			if standingMarker and standingMarker[1] == interiorId then
				exports.see_hud:endInteriorBox()
			end
		end
	end
end

addEvent("requestInteriors", true)
addEventHandler("requestInteriors", getRootElement(),
	function (interiors, deleted)
		for interiorId, data in pairs(interiors) do
			if not availableInteriors[interiorId] then
				availableInteriors[interiorId] = {}
			end

			for k, v in pairs(data) do
				parseInteriorData(interiorId, k, v)
			end
		end

		for interiorId in pairs(deleted) do
			if availableInteriors[interiorId] then
				deletedInteriors[interiorId] = true
				availableInteriors[interiorId] = nil
			end
		end
		
		for interiorId, data in pairs(availableInteriors) do
			createInterior(interiorId, data)
		end

		interiorsLoaded = true
	end)

addEvent("resetInterior", true)
addEventHandler("resetInterior", getRootElement(),
	function (interiorId)
		if interiorId then
			local int = availableInteriors[interiorId]
			
			if int then
				int.ownerId = 0

				if isElement(int.enterPickup) then
					setCoolMarkerType(int.enterPickup, int.type, "unSold")
				end
				
				if isElement(int.exitPickup) then
					setCoolMarkerType(int.exitPickup, int.type, "unSold")
				end
			end
		end
	end)

addEvent("changeInteriorOwner", true)
addEventHandler("changeInteriorOwner", getRootElement(),
	function (interiorId, ownerId)
		if interiorId and ownerId then
			local int = availableInteriors[interiorId]

			if int then
				int.ownerId = ownerId
			end
		end
	end)

addEvent("playInteriorSound", true)
addEventHandler("playInteriorSound", getRootElement(),
	function (soundType)
		if soundType then
			if soundType == "openclose" then
				playSound("files/sounds/openclose.mp3", false)
			elseif soundType == "locked" then
				playSound("files/sounds/locked.mp3", false)
			elseif soundType == "intenter" then
				playSound("files/sounds/intenter.mp3", false)
			elseif soundType == "intout" then
				playSound("files/sounds/intout.mp3", false)
			end
		end
	end)

addEventHandler("onClientMarkerHit", getResourceRootElement(),
	function (hitElement, dimensionMatch)
		if hitElement == localPlayer and dimensionMatch then
			local interiorId = getElementData(source, "interiorId")
			local colShapeType = getElementData(source, "colShapeType")

			if interiorId and colShapeType then
				local playerX, playerY, playerZ = getElementPosition(localPlayer)
				local targetX, targetY, targetZ = getElementPosition(source)
				
				if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) > 1.5 then
					return
				end
				
				local int = availableInteriors[interiorId]
				local showPreview = false

				standingMarker = {interiorId, colShapeType}

				if int.ownerId == 0 then
					if int.type ~= "building" and int.type ~= "building2" then
						if int.type == "rentable" then
							outputChatBox("#3d7abc[Ingatlan]: #ffffffEz az ingatlan kiadó! A bérléshez használd a #32b3ef/rent #ffffffparancsot!", 255, 255, 255, true)
							outputChatBox("#3d7abc[Ingatlan]: #ffffffBérleti díj: #32b3ef" .. formatNumber(int.price) .. " $/hét.#ffffff Kaució: #32b3ef" .. formatNumber(int.price * 4) .. " $", 255, 255, 255, true)
						else
							outputChatBox("#3d7abc[Ingatlan]: #ffffffEz az ingatlan eladó! A vásárláshoz használd a #32b3ef/buy #ffffffparancsot! Ár: #32b3ef" .. formatNumber(int.price) .. " $", 255, 255, 255, true)
						end

						showPreview = true
					end
				else
					if int.ownerId == tonumber(getElementData(localPlayer, "char.ID")) then
						if int.editable ~= "N" then
							if colShapeType == "entrance" then
								outputChatBox("#3d7abc[Ingatlan]: #ffffffEz az ingatlan szerkeszthető!", 255, 255, 255, true)
								outputChatBox("#3d7abc[Ingatlan]: #ffffffHasználd a #3d7abc[Z]#ffffff gombot vagy a '#3d7abc/edit#ffffff' parancsot a szerkesztéshez!", 255, 255, 255, true)
								exports.see_hud:showInfobox("i", "Ez egy szerkeszthető interior! Részletek a chatboxban.")
							end
						end
					end
				end
				
				if colShapeType == "entrance" then
					exports.see_hud:showInteriorBox("[" .. interiorId .. "] " .. int.name, "Nyomj [E] gombot a belépéshez.", int.locked, int.type, showPreview and int.gameInterior or false)
				elseif colShapeType == "exit" then
					exports.see_hud:showInteriorBox("[" .. interiorId .. "] " .. int.name, "Nyomj [E] gombot a kilépéshez.", int.locked, int.type)
				end
			end
		end
	end)

function refreshInteriorBox(interiorId)
	if standingMarker and standingMarker[1] == interiorId then
		local int = availableInteriors[interiorId]

		if int then
			local showPreview = false

			if int.ownerId == 0 then
				if int.type ~= "building" and int.type ~= "building2" then
					showPreview = true
				end
			else
				if int.ownerId == tonumber(getElementData(localPlayer, "char.ID")) then
					if int.editable ~= "N" then
						showPreview = true
					end
				end
			end
			
			if standingMarker[2] == "entrance" then
				exports.see_hud:showInteriorBox("[" .. interiorId .. "] " .. int.name, "Nyomj [E] gombot a belépéshez.", int.locked, int.type, showPreview and int.gameInterior or false)
			else
				exports.see_hud:showInteriorBox("[" .. interiorId .. "] " .. int.name, "Nyomj [E] gombot a kilépéshez.", int.locked, int.type)
			end
		else
			exports.see_hud:endInteriorBox()
		end
	end
end

local lastInteriorBuy = 0

addCommandHandler("unrent",
	function ()
		if standingMarker then
			local interiorId = standingMarker[1]
			local int = availableInteriors[interiorId]

			if int then
				if int.type == "rentable" then
					local characterId = getElementData(localPlayer, "char.ID")

					if int.ownerId == characterId then
						if getTickCount() >= lastInteriorBuy + 5000 then
							triggerServerEvent("unRentInterior", localPlayer, interiorId)
							lastInteriorBuy = getTickCount()
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffCsak 5 másodpercenként használhatod ezt a parancsot.", 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffEzt az ingatlant nem te bérled.", 255, 255, 255, true)
					end
				end
			end
		end
	end)

addCommandHandler("rent",
	function ()
		if standingMarker then
			local interiorId = standingMarker[1]
			local int = availableInteriors[interiorId]

			if int then
				if int.type == "rentable" then
					local characterId = getElementData(localPlayer, "char.ID")

					if int.ownerId == 0 then
						if exports.see_core:getMoney(localPlayer) >= int.price * 5 then
							local interiorLimit = getElementData(localPlayer, "player.interiorLimit") or 5
							local interiorCount = 0

							for k, v in pairs(availableInteriors) do
								if v.ownerId == characterId then
									interiorCount = interiorCount + 1
								end
							end

							if interiorCount < interiorLimit then
								if getTickCount() >= lastInteriorBuy + 5000 then
									triggerServerEvent("buyInterior", localPlayer, interiorId)
									lastInteriorBuy = getTickCount()
								else
									outputChatBox("#d75959[Ingatlan]: #ffffffCsak 5 másodpercenként használhatod ezt a parancsot.", 255, 255, 255, true)
								end
							else
								outputChatBox("#d75959[Ingatlan]: #ffffffNincs szabad ingatlan slotod.", 255, 255, 255, true)
							end
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffNincs elég pénzed, hogy kifizesd a bérleti díjat és kauciót.", 255, 255, 255, true)
						end
					elseif int.ownerId == characterId then
						if exports.see_core:getMoney(localPlayer) >= int.price then
							if getTickCount() >= lastInteriorBuy + 5000 then
								triggerServerEvent("tryToRenewalRent", localPlayer, interiorId)
								lastInteriorBuy = getTickCount()
							else
								outputChatBox("#d75959[Ingatlan]: #ffffffCsak 5 másodpercenként használhatod ezt a parancsot.", 255, 255, 255, true)
							end
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffNincs elég pénzed, hogy kifizesd a bérleti díjat.", 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffEz a bérlakás nem kiadó.", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Ingatlan]: #ffffffEzt az ingatlant nem lehet kibérelni.", 255, 255, 255, true)
				end
			end
		end
	end)

addCommandHandler("buy",
	function ()
		if standingMarker then
			local interiorId = standingMarker[1]
			local int = availableInteriors[interiorId]

			if int then
				if int.type == "rentable" then
					outputChatBox("#d75959[Ingatlan]: #ffffffBérelhető lakást nem vásárolhatsz meg.", 255, 255, 255, true)
					outputChatBox("#d75959[Ingatlan]: #ffffffBérléshez használd a #598ed7/rent#ffffff parancsot.", 255, 255, 255, true)
					return
				end

				if int.type ~= "building" and int.type ~= "building2" then
					if int.ownerId == 0 then
						if exports.see_core:getMoney(localPlayer) >= int.price then
							local interiorLimit = getElementData(localPlayer, "player.interiorLimit") or 5
							local interiorCount = 0

							for k, v in pairs(availableInteriors) do
								if v.ownerId == characterId then
									interiorCount = interiorCount + 1
								end
							end

							if interiorCount < interiorLimit then
								if getTickCount() >= lastInteriorBuy + 5000 then
									triggerServerEvent("buyInterior", localPlayer, interiorId)
									lastInteriorBuy = getTickCount()
								else
									outputChatBox("#d75959[Ingatlan]: #ffffffCsak 5 másodpercenként használhatod ezt a parancsot.", 255, 255, 255, true)
								end
							else
								outputChatBox("#d75959[Ingatlan]: #ffffffNincs szabad ingatlan slotod.", 255, 255, 255, true)
							end
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffNincs elég pénzed az ingatlan megvásárlásához. (#32b3ef" .. formatNumber(int.price) .. " $#ffffff)", 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffEz az ingatlan nem eladó.", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Ingatlan]: #ffffffKözépületet nem vásárolhatsz meg.", 255, 255, 255, true)
				end
			end
		end
	end)

local lastInteriorLock = 0

addCommandHandler("lock/unlock-interior",
	function ()
		if standingMarker then
			local interiorId = standingMarker[1]
			local int = availableInteriors[interiorId]

			if int and int.type ~= "building" then
				local characterId = getElementData(localPlayer, "char.ID")

				if characterId then
					if getTickCount() >= lastInteriorLock + 5000 then
						triggerServerEvent("lockInterior", localPlayer, interiorId)
						lastInteriorLock = getTickCount()
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffCsak 5 másodpercenként #3d7abcnyithatod #ffffff/ #d75959zárhatod #ffffffaz ajtót.", 255, 255, 255, true)
					end
				end
			end
		end
	end)
bindKey("K", "up", "lock/unlock-interior")

addEvent("lockInterior", true)
addEventHandler("lockInterior", getRootElement(),
	function (interiorId, locked)
		if interiorId then
			local int = availableInteriors[interiorId]

			if int then
				int.locked = locked

				if standingMarker and standingMarker[1] == interiorId then
					exports.see_hud:setInteriorDoorState(int.locked, int.type)
				end
			end
		end
	end)

addEvent("buyInterior", true)
addEventHandler("buyInterior", getRootElement(),
	function (interiorId, ownerId)
		if interiorId then
			local int = availableInteriors[interiorId]
			
			int.ownerId = ownerId
		
			if int.type ~= "building" then
				local state = "unSold"

				if int.ownerId > 0 then
					state = "sold"
				end

				if isElement(int.enterPickup) then
					setCoolMarkerType(int.enterPickup, int.type, state)
				end
				
				if isElement(int.exitPickup) then
					setCoolMarkerType(int.exitPickup, int.type, state)
				end
			end
		end
	end)

addEventHandler("onClientMarkerLeave", getResourceRootElement(),
	function (leaveElement)
		if leaveElement == localPlayer then
			if standingMarker then
				standingMarker = false
				exports.see_hud:endInteriorBox()
			end
		end
	end)

local lastInteriorEnter = 0

function getCurrentStandingInterior()
	return standingMarker
end

bindKey("e", "up",
	function ()
		if standingMarker then
			if getElementData(localPlayer, "editingInterior") then
				exports.see_accounts:showInfo("e", "Nem hagyhatod el az interiort szerkesztő módban.")
				return
			end

			local interiorId = tonumber(standingMarker[1])
			local colShapeType = tostring(standingMarker[2])

			if interiorId and colShapeType then
				local int = availableInteriors[interiorId]

				if int then
					if not int.dummy or int.dummy == "N" then
						if not getElementData(localPlayer, "cuffed") and not getElementData(localPlayer, "tazed") then
							if getTickCount() >= lastInteriorEnter + 3000 then
								local currentTask = getPedSimplestTask(localPlayer)

								if currentTask ~= "TASK_SIMPLE_CAR_DRIVE" and string.sub(currentTask, 0, 15) == "TASK_SIMPLE_CAR" then
									return
								end

								if currentTask == "TASK_SIMPLE_GO_TO_POINT" then
									return
								end

								local currentVehicle = getPedOccupiedVehicle(localPlayer)

								if isElement(currentVehicle) then
									setPedCanBeKnockedOffBike(localPlayer, false)
									setTimer(setPedCanBeKnockedOffBike, 1000, 1, localPlayer, true)

									if getVehicleOccupant(currentVehicle) == localPlayer then
										if int.type ~= "garage" then
											if not int.allowedVehicles then
												return
											elseif type(int.allowedVehicles) == "table" then
												local allowed = false
												
												for k, v in ipairs(int.allowedVehicles) do
													if getElementModel(currentVehicle) == v then
														allowed = true
														break
													end
												end
												
												if not allowed then
													return
												end
											end
										end
									else
										return
									end
								end

								lastInteriorEnter = getTickCount()

								if colShapeType == "entrance" then
									local warpData = {
										posX = int.exit.position[1],
										posY = int.exit.position[2],
										posZ = int.exit.position[3],
										rotX = int.exit.rotation[1],
										rotY = int.exit.rotation[2],
										rotZ = int.exit.rotation[3],
										interior = int.exit.interior,
										dimension = int.exit.dimension,
										editable = int.editable,
										id = interiorId
									}

									createInteriorObject(interiorId)
									warpAnimal(warpData)
									triggerServerEvent("warpPlayer", localPlayer, warpData, interiorId, "enter")
								elseif colShapeType == "exit" then
									local warpData = {
										posX = int.entrance.position[1],
										posY = int.entrance.position[2],
										posZ = int.entrance.position[3],
										rotX = int.entrance.rotation[1],
										rotY = int.entrance.rotation[2],
										rotZ = int.entrance.rotation[3],
										interior = int.entrance.interior,
										dimension = int.entrance.dimension,
										editable = int.editable,
										id = interiorId
									}

									warpAnimal(warpData)
									triggerServerEvent("warpPlayer", localPlayer, warpData, interiorId, "exit")
									iprint(warpData, interiorId)

									if isElement(currentInteriorObject) then
										destroyElement(currentInteriorObject)
									end

									currentInteriorObject = nil
								end
							else
								outputChatBox("#d75959[Ingatlan]: #ffffffVárj egy kicsit, mielőtt újra használod az ajtót.", 255, 255, 255, true)
							end
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffMegbilincselve/lesokkolva nem használhatod az ajtót.", 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffEz az interior nem rendelkezik tényleges belső térrel.", 255, 255, 255, true)
					end
				end
			end
		end
	end)

function warpAnimal(warpData)
	local characterId = getElementData(localPlayer, "char.ID")
	if characterId then
		local animalElement = getElementByID("animal_" .. characterId)
		if isElement(animalElement) then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local animalX, animalY, animalZ = getElementPosition(animalElement)

			if getDistanceBetweenPoints3D(playerX, playerY, playerZ, animalX, animalY, animalZ) <= 10 then
				local playerInterior = getElementInterior(localPlayer)
				local animalInterior = getElementInterior(animalElement)

				if playerInterior == animalInterior then
					local playerDimension = getElementDimension(localPlayer)
					local animalDimension = getElementDimension(animalElement)

					if playerDimension == animalDimension then
						local currentTask = getElementData(animalElement, "ped.task.1")
						if currentTask then
							if currentTask[1] == "walkFollowElement" and currentTask[2] == localPlayer then
								triggerServerEvent("warpAnimal", localPlayer, warpData)
							end
						end
					end
				end
			end
		end
	end
end

function useDoorRammer()
	if exports.see_groups:isPlayerHavePermission(localPlayer, "doorRammer") then
		if standingMarker then
			local interiorId = tonumber(standingMarker[1])

			if interiorId then
				local int = availableInteriors[interiorId]

				if int then
					if int.type ~= "building" then
						triggerServerEvent("useDoorRammer", localPlayer, interiorId)
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffItt nem használhatod a faltörő kost.", 255, 255, 255, true)
					end
				end
			end
		else
			outputChatBox("#d75959[Ingatlan]: #ffffffItt nem használhatod a faltörő kost.", 255, 255, 255, true)
		end
	else
		outputChatBox("#d75959[Ingatlan]: #ffffffNem használhatod a faltörő kost.", 255, 255, 255, true)
	end
end

function knockOnDoorCommand()
	if standingMarker then
		local interiorId = tonumber(standingMarker[1])

		if interiorId then
			local int = availableInteriors[interiorId]

			if int then
				if int.type == "house" or int.type == "garage" or int.type == "rentable" then
					triggerServerEvent("useDoorKnocking", localPlayer, interiorId)
				else
					outputChatBox("#d75959[Ingatlan]: #ffffffCsak házba vagy garázsba kopogtathatsz.", 255, 255, 255, true)
				end
			end
		end
	else
		outputChatBox("#d75959[Ingatlan]: #ffffffItt nem kopogtathatsz.", 255, 255, 255, true)
	end
end
addCommandHandler("kopogtat", knockOnDoorCommand)
addCommandHandler("kopog", knockOnDoorCommand)
addCommandHandler("kopogas", knockOnDoorCommand)
addCommandHandler("kopogás", knockOnDoorCommand)

function bellOnDoor()
	if standingMarker then
		local interiorId = tonumber(standingMarker[1])

		if interiorId then
			local int = availableInteriors[interiorId]

			if int then
				if int.type == "house" or int.type == "garage" or int.type == "rentable" then
					if getElementDimension(localPlayer) ~= 0 then
						outputChatBox("#d75959[Ingatlan]: #ffffffCsak kintről csengethetsz be.", 255, 255, 255, true)
					else
						triggerServerEvent("useDoorBell", localPlayer, interiorId)
					end
				else
					outputChatBox("#d75959[Ingatlan]: #ffffffCsak házba vagy garázsba csengethetsz.", 255, 255, 255, true)
				end
			end
		end
	else
		outputChatBox("#d75959[Ingatlan]: #ffffffItt nem csengethetsz.", 255, 255, 255, true)
	end
end
addCommandHandler("csenget", bellOnDoor)
addCommandHandler("csengetes", bellOnDoor)
addCommandHandler("csengetés", bellOnDoor)

addEvent("playRamSound", true)
addEventHandler("playRamSound", getRootElement(),
	function (interiorId)
		if interiorId then
			local int = availableInteriors[interiorId]

			if int then
				local soundElement = playSound3D("files/sounds/rammed.mp3", int.entrance.position[1], int.entrance.position[2], int.entrance.position[3])

				if isElement(soundElement) then
					setElementInterior(soundElement, int.entrance.interior)
					setElementDimension(soundElement, int.entrance.dimension)
					setSoundMaxDistance(soundElement, 200)
					setSoundVolume(soundElement, 1)
				end

				local soundElement = playSound3D("files/sounds/rammed.mp3", int.exit.position[1], int.exit.position[2], int.exit.position[3])

				if isElement(soundElement) then
					setElementInterior(soundElement, int.exit.interior)
					setElementDimension(soundElement, int.exit.dimension)
					setSoundMaxDistance(soundElement, 200)
					setSoundVolume(soundElement, 1)
				end

				if source == localPlayer then
					exports.see_chat:localActionC(localPlayer, "betöri az ajtót.")
				end
			end
		end
	end)

addEvent("playKnocking", true)
addEventHandler("playKnocking", getRootElement(),
	function (interiorId)
		if interiorId then
			local int = availableInteriors[interiorId]

			if int then
				local soundElement = playSound3D("files/sounds/knock.mp3", int.entrance.position[1], int.entrance.position[2], int.entrance.position[3])

				if isElement(soundElement) then
					setElementInterior(soundElement, int.entrance.interior)
					setElementDimension(soundElement, int.entrance.dimension)
					setSoundMaxDistance(soundElement, 60)
					setSoundVolume(soundElement, 1)
				end

				local soundElement = playSound3D("files/sounds/knock.mp3", int.exit.position[1], int.exit.position[2], int.exit.position[3])

				if isElement(soundElement) then
					setElementInterior(soundElement, int.exit.interior)
					setElementDimension(soundElement, int.exit.dimension)
					setSoundMaxDistance(soundElement, 60)
					setSoundVolume(soundElement, 1)
				end
			end
		end
	end)

addEvent("playBell", true)
addEventHandler("playBell", getRootElement(),
	function (interiorId)
		if interiorId then
			local int = availableInteriors[interiorId]

			if int then
				local soundElement = playSound3D("files/sounds/bell.mp3", int.entrance.position[1], int.entrance.position[2], int.entrance.position[3])

				if isElement(soundElement) then
					setElementInterior(soundElement, int.entrance.interior)
					setElementDimension(soundElement, int.entrance.dimension)
					setSoundMaxDistance(soundElement, 160)
					setSoundVolume(soundElement, 1)
				end

				local soundElement = playSound3D("files/sounds/bell.mp3", int.exit.position[1], int.exit.position[2], int.exit.position[3])

				if isElement(soundElement) then
					setElementInterior(soundElement, int.exit.interior)
					setElementDimension(soundElement, int.exit.dimension)
					setSoundMaxDistance(soundElement, 160)
					setSoundVolume(soundElement, 1)
				end
			end
		end
	end)

function createInteriorObject(interiorId)
	if interiorId then
		local int = availableInteriors[interiorId]

		if int then
			if isElement(currentInteriorObject) then
				destroyElement(currentInteriorObject)
			end

			if int.gameInterior then
				local gameInterior = gameInteriors[int.gameInterior]

				if gameInterior and gameInterior.object then
					currentInteriorObject = createObject(gameInterior.object.objectId, gameInterior.object.position[1], gameInterior.object.position[2], gameInterior.object.position[3])

					if isElement(currentInteriorObject) then
						setElementInterior(currentInteriorObject, gameInterior.interior)
						setElementDimension(currentInteriorObject, int.exit.dimension)
					end
				end
			end
		end
	end
end

local iconPictures = {}

iconPictures.house = dxCreateTexture("files/icons/house.png")
iconPictures.houseforsale = dxCreateTexture("files/icons/houseforsale.png")
iconPictures.info = dxCreateTexture("files/icons/info.png")
iconPictures.info2 = dxCreateTexture("files/icons/info.png")
iconPictures.garage = dxCreateTexture("files/icons/garage.png")
iconPictures.garageforsale = dxCreateTexture("files/icons/garageforsale.png")
iconPictures.business = dxCreateTexture("files/icons/business.png")
iconPictures.rentabletolet = dxCreateTexture("files/icons/rentable.png")
iconPictures.rentable = dxCreateTexture("files/icons/rentable.png")
iconPictures.duty = dxCreateTexture("files/icons/duty.png")
iconPictures.barn = dxCreateTexture("files/icons/barn.png")
iconPictures.barn2 = dxCreateTexture("files/icons/barn2.png")

local iconColors = {}

iconColors.house = {89, 142, 215}
iconColors.houseforsale = {124,	197, 118}
iconColors.info = {220, 163, 0}
iconColors.garage = {89, 142, 215}
iconColors.garageforsale = {124,	197, 118}
iconColors.business = {220, 163, 0}
iconColors.info2 = {215, 89, 89}
iconColors.rentabletolet = {244, 184, 235}
iconColors.rentable = {99, 39, 90}
iconColors.duty = {60, 100, 70}
iconColors.barn = {124,	197, 118}
iconColors.barn2 = {197, 195, 118}

local coolMarkers = {}
local coolMarkersKeyed = {}
local nearbyMarkers = {}

function getIconByMarkerType(markerType)
	if iconPictures[markerType] then
		return iconPictures[markerType]
	end

	return iconPictures.house
end

function getInteriorMarkerType(markerType, state)
	local realType = ""

	if markerType == "business_passive" then
		realType = "business"
	elseif markerType == "business_active" then
		realType = "business"
	elseif markerType == "house" then
		if state == "sold" then
			realType = "house"
		else
			realType = "houseforsale"
		end
	elseif markerType == "building" then
		realType = "info"
	elseif markerType == "building2" then
		realType = "info2"
	elseif markerType == "garage" then
		if state == "sold" then
			realType = "garage"
		else
			realType = "garageforsale"
		end
	elseif markerType == "rentable" then
		if state == "sold" then
			realType = "rentable"
		else
			realType = "rentabletolet"
		end
	else
		return markerType
	end

	return realType
end

function createCoolMarker(posX, posY, posZ, markerType, state)
	markerType = getInteriorMarkerType(markerType, state)
	
	local markerId = #coolMarkers + 1
	local markerElement = createMarker(posX, posY, posZ - 1, "cylinder", 0.75, iconColors[markerType][1], iconColors[markerType][2], iconColors[markerType][3], 200)
	
	coolMarkers[markerId] = {markerElement, markerType}
	coolMarkersKeyed[markerElement] = markerId
	
	return markerElement
end

function setCoolMarkerType(markerElement, markerType, state)
	markerType = getInteriorMarkerType(markerType, state)

	local markerId = coolMarkersKeyed[markerElement]

	coolMarkers[markerId][2] = markerType

	setMarkerColor(coolMarkers[markerId][1], iconColors[markerType][1], iconColors[markerType][2], iconColors[markerType][3], 200)

	for i = 1, #nearbyMarkers do
		local marker = nearbyMarkers[i]

		if marker and (markerElement == marker[3] or marker == markerId) then
			marker[2] = markerType
			break
		end
	end

	return true
end

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		if coolMarkersKeyed[source] then
			local markerId = coolMarkersKeyed[source]

			table.insert(nearbyMarkers, {markerId, coolMarkers[markerId][2], source})
		end
	end)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
	function ()
		if coolMarkersKeyed[source] then
			local markerId = coolMarkersKeyed[source]

			for i = 1, #nearbyMarkers do
				local marker = nearbyMarkers[i]

				if marker and (source == marker[3] or marker == markerId) then
					table.remove(nearbyMarkers, i)
					break
				end
			end
		end
	end)

addEventHandler("onClientElementDestroy", getResourceRootElement(),
	function ()
		if coolMarkersKeyed[source] then
			local markerId = coolMarkersKeyed[source]

			coolMarkers[markerId] = nil

			for i = 1, #nearbyMarkers do
				local marker = nearbyMarkers[i]

				if marker and (source == marker[3] or marker == markerId) then
					table.remove(nearbyMarkers, i)
					coolMarkersKeyed[source] = nil
					break
				end
			end
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		local cameraInterior = getCameraInterior()
		local playerInterior = getElementInterior(localPlayer)

		if cameraInterior ~= playerInterior then
			setCameraInterior(playerInterior)
		end

		for i = 1, #nearbyMarkers do
			local data = nearbyMarkers[i]

			if data then
				local markerElement = data[3]

				if isElement(markerElement) then
					if playerInterior == getElementInterior(markerElement) then
						local x, y, z = getElementPosition(markerElement)
						local typ = data[2]

						z = z + 1
					
						dxDrawMaterialLine3D(x, y, z + 0.225, x, y, z - 0.225, iconPictures[typ], 0.45, tocolor(iconColors[typ][1], iconColors[typ][2], iconColors[typ][3]))
					end
				end
			end
		end
	end)

local lastInteriorEdit = 0

addCommandHandler("edit",
	function ()
		if interiorsLoaded and standingMarker then
			local interiorId = tonumber(standingMarker[1])
			local colShapeType = tostring(standingMarker[2])

			if interiorId and colShapeType == "entrance" then
				local int = availableInteriors[interiorId]

				if int then
					if int.editable ~= "N" then
						local characterId = tonumber(getElementData(localPlayer, "char.ID"))

						if int.ownerId == characterId then
							if getTickCount() >= lastInteriorEdit + 5000 then
								triggerServerEvent("editInterior", localPlayer, interiorId)
								lastInteriorEdit = getTickCount()
							else
								outputChatBox("#d75959[Ingatlan]: #ffffffCsak 5 másodpercenként használhatod ezt a parancsot.", 255, 255, 255, true)
							end
						else
							outputChatBox("#d75959[Ingatlan]: #ffffffEz az ingatlan nem a te tulajdonod.", 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[Ingatlan]: #ffffffEz nem szerkeszthető interior.", 255, 255, 255, true)
					end
				end
			end
		end
	end)
bindKey("Z", "down", "edit")