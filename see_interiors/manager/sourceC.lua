local screenX, screenY = guiGetScreenSize()

addCommandHandler("createinterior",
	function (commandName, gameInterior, interiorType, buyPrice, ...)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			gameInterior = tonumber(gameInterior)
			interiorType = tonumber(interiorType)
			buyPrice = tonumber(buyPrice)

			if not (gameInterior and interiorType and buyPrice and (...)) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Belső Azonosító (0: DUMMY)] [Típus] [Ár] [Név]", 255, 255, 255, true)
				outputChatBox("#3d7abc[Típusok]: #ffffffHáz (1), Passzív Biznisz (2), Aktív Biznisz (3), Középület (4), Garázs (5), Zárható középület (6), Bérelhető (7)", 255, 255, 255, true)
			else
				buyPrice = math.floor(buyPrice)

				if gameInteriors[gameInterior] or gameInterior == 0 then
					if interiorType >= 1 and interiorType <= 7 then
						if interiorType == 1 then
							interiorType = "house"
						elseif interiorType == 2 then
							interiorType = "business_passive"
						elseif interiorType == 3 then
							interiorType = "business_active"
						elseif interiorType == 4 then
							interiorType = "building"
						elseif interiorType == 5 then
							interiorType = "garage"
						elseif interiorType == 6 then
							interiorType = "building2"
						else
							interiorType = "rentable"
						end

						if buyPrice >= 0 and buyPrice <= 10000000000 then
							local name = table.concat({...}, " ")

							if utf8.len(name) == 0 and gameInterior ~= 0 then
								name = gameInteriors[gameInterior]["name"]
							end

							if utf8.len(name) > 0 then
								local interiorDatas = {
									["name"] = name,
									["type"] = interiorType,
									["dummy"] = "Y",
									["price"] = buyPrice,
									["ownerId"] = 0,
									["gameInterior"] = gameInterior,
									["entrance_position"] = table.concat({getElementPosition(localPlayer)}, ","),
									["entrance_rotation"] = table.concat({getElementRotation(localPlayer)}, ","),
									["entrance_interior"] = getElementInterior(localPlayer),
									["entrance_dimension"] = getElementDimension(localPlayer),
									["exit_position"] = "0,0,0",
									["exit_rotation"] = "0,0,0",
									["exit_interior"] = 0,
									["exit_dimension"] = 65535
								}

								if gameInteriors[gameInterior] then
									interiorDatas["dummy"] = "N"
									interiorDatas["exit_position"] = table.concat(gameInteriors[gameInterior]["position"], ",")
									interiorDatas["exit_rotation"] = table.concat(gameInteriors[gameInterior]["rotation"], ",")
									interiorDatas["exit_interior"] = gameInteriors[gameInterior]["interior"]
								end

								triggerServerEvent("createInterior", localPlayer, interiorDatas)
							end
						else
							outputChatBox("#d75959[Interior]: #ffffffAz ár nem lehet kisebb mint #3d7abc0 #ffffffés nem lehet nagyobb mint #3d7abc10 000 000 000#ffffff.", 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[Interior]: #ffffffÉrvénytelen interior típus.", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffÉrvénytelen interior azonosító.", 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("createInterior", true)
addEventHandler("createInterior", getRootElement(),
	function (interiorDatas, interiorId)
		if interiorDatas and interiorId then
			if not availableInteriors[interiorId] then
				availableInteriors[interiorId] = {}
			end

			for k, v in pairs(interiorDatas) do
				parseInteriorData(interiorId, k, v)
			end

			createInterior(interiorId)
		end
	end
)

addCommandHandler("creategarage",
	function (commandName, interiorType)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorType = tonumber(interiorType)

			if not interiorType then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Típus (1: Kicsi, 2: Közepes, 3: Nagy)]", 255, 255, 255, true)
			else
				if interiorType >= 1 and interiorType <= 3 then
					local gameInterior = 134
					local buyPrice = 300000
					local name = "Garázs - Kicsi"

					if interiorType == 2 then
						gameInterior = 135
						buyPrice = 450000
						name = "Garázs - Közepes"
					elseif interiorType == 3 then
						gameInterior = 136
						buyPrice = 600000
						name = "Garázs - Nagy"
					end

					if gameInteriors[gameInterior] then
						local interiorDatas = {
							["name"] = name,
							["type"] = "garage",
							["dummy"] = "N",
							["price"] = buyPrice,
							["ownerId"] = 0,
							["gameInterior"] = gameInterior,
							["entrance_position"] = table.concat({getElementPosition(localPlayer)}, ","),
							["entrance_rotation"] = table.concat({getElementRotation(localPlayer)}, ","),
							["entrance_interior"] = getElementInterior(localPlayer),
							["entrance_dimension"] = getElementDimension(localPlayer),
							["exit_position"] = table.concat(gameInteriors[gameInterior]["position"], ","),
							["exit_rotation"] = table.concat(gameInteriors[gameInterior]["rotation"], ","),
							["exit_interior"] = gameInteriors[gameInterior]["interior"],
							["exit_dimension"] = 65535
						}

						triggerServerEvent("createInterior", localPlayer, interiorDatas)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffÉrvénytelen garázs típus.", 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("deleteinterior",
	function (commandName, interiorId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					triggerServerEvent("deleteInterior", localPlayer, interiorId)
				elseif deletedInteriors[interiorId] then
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior már törölve van.", 255, 255, 255, true)
					outputChatBox("#d75959[Interior]: #ffffffAz interior visszaállításához használd a #3d7abc'/resetinterior' #ffffffparancsot.", 255, 255, 255, true)
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("deleteInterior", true)
addEventHandler("deleteInterior", getRootElement(),
	function (interiorId)
		destroyInterior(interiorId)
	end
)

addCommandHandler("setinteriorname",
	function (commandName, interiorId, ...)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not (interiorId and (...)) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID] [Név]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					local name = table.concat({...}, " ")

					if utfLen(name) > 0 then
						triggerServerEvent("setInteriorName", localPlayer, interiorId, name)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("setInteriorName", true)
addEventHandler("setInteriorName", getRootElement(),
	function (interiorId, newName)
		if interiorId and newName then
			if availableInteriors[interiorId] then
				availableInteriors[interiorId]["name"] = newName
				refreshInteriorBox(interiorId)
			end
		end
	end
)

addCommandHandler("getinteriorname",
	function (commandName, interiorId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior neve #3d7abc" .. availableInteriors[interiorId]["name"] .. ".", 255, 255, 255, true)
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("setinteriorprice",
	function (commandName, interiorId, buyPrice)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)
			buyPrice = tonumber(buyPrice)

			if not (interiorId and buyPrice) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID] [Ár]", 255, 255, 255, true)
			else
				buyPrice = math.floor(buyPrice)

				if availableInteriors[interiorId] then
					if buyPrice >= 0 and buyPrice <= 10000000000 then
						triggerServerEvent("setInteriorPrice", localPlayer, interiorId, buyPrice)
					else
						outputChatBox("#d75959[Interior]: #ffffffAz ár nem lehet kisebb mint #3d7abc0 #ffffffés nem lehet nagyobb mint #3d7abc10 000 000 000#ffffff.", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("setInteriorPrice", true)
addEventHandler("setInteriorPrice", getRootElement(),
	function (interiorId, newPrice)
		if interiorId and newPrice then
			if availableInteriors[interiorId] then
				availableInteriors[interiorId]["price"] = newPrice
			end
		end
	end
)

addCommandHandler("getinteriorprice",
	function (commandName, interiorId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior ára #3d7abc" .. formatNumber(availableInteriors[interiorId]["price"]) .. " $.", 255, 255, 255, true)
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("setinteriortype",
	function (commandName, interiorId, interiorType)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)
			interiorType = tonumber(interiorType)

			if not (interiorId and interiorType) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID] [Típus]", 255, 255, 255, true)
				outputChatBox("#3d7abc[Típusok]: #ffffffHáz (1), Passzív Biznisz (2), Aktív Biznisz (3), Középület (4), Garázs (5), Zárható középület (6), Bérelhető (7)", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					if interiorType >= 1 and interiorType <= 7 then
						if interiorType == 1 then
							interiorType = "house"
						elseif interiorType == 2 then
							interiorType = "business_passive"
						elseif interiorType == 3 then
							interiorType = "business_active"
						elseif interiorType == 4 then
							interiorType = "building"
						elseif interiorType == 5 then
							interiorType = "garage"
						elseif interiorType == 6 then
							interiorType = "building2"
						else
							interiorType = "rentable"
						end

						triggerServerEvent("setInteriorType", localPlayer, interiorId, interiorType)
					else
						outputChatBox("#d75959[Interior]: #ffffffÉrvénytelen interior típus.", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("setInteriorType", true)
addEventHandler("setInteriorType", getRootElement(),
	function (interiorId, newType)
		if interiorId and newType then
			if availableInteriors[interiorId] then
				availableInteriors[interiorId]["type"] = newType

				if isElement(availableInteriors[interiorId]["enterPickup"]) then
					setCoolMarkerType(availableInteriors[interiorId]["enterPickup"], newType, availableInteriors[interiorId]["ownerId"] > 0 and "sold" or "unSold")
				end

				if isElement(availableInteriors[interiorId]["exitPickup"]) then
					setCoolMarkerType(availableInteriors[interiorId]["exitPickup"], newType, availableInteriors[interiorId]["ownerId"] > 0 and "sold" or "unSold")
				end

				refreshInteriorBox(interiorId)
			end
		end
	end
)

addCommandHandler("getinteriortype",
	function (commandName, interiorId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					local interiorType = availableInteriors[interiorId]["type"]

					if interiorType == "business_passive" then
						interiorType = "Passzív Biznisz"
					elseif interiorType == "business_active" then
						interiorType = "Aktív Biznisz"
					elseif interiorType == "building" then
						interiorType = "Középület"
					elseif interiorType == "garage" then
						interiorType = "Garázs"
					elseif interiorType == "building2" then
						interiorType = "Zárható Középület"
					elseif interiorType == "rentable" then
						interiorType = "Bérlakás"
					else
						interiorType = "Ház"
					end

					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior típusa #3d7abc" .. interiorType .. ".", 255, 255, 255, true)
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("setinteriorentrance",
	function (commandName, interiorId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					triggerServerEvent("setInteriorEntrance", localPlayer, interiorId, {
						["entrance_position"] = table.concat({getElementPosition(localPlayer)}, ","),
						["entrance_rotation"] = table.concat({getElementRotation(localPlayer)}, ","),
						["entrance_interior"] = getElementInterior(localPlayer),
						["entrance_dimension"] = getElementDimension(localPlayer)
					})
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("setInteriorEntrance", true)
addEventHandler("setInteriorEntrance", getRootElement(),
	function (interiorId, newDatas)
		if interiorId and newDatas then
			if availableInteriors[interiorId] then
				for k, v in pairs(newDatas) do
					parseInteriorData(interiorId, k, v)
				end

				local enterPickupElement = availableInteriors[interiorId]["enterPickup"]
				local enterColShapeElement = availableInteriors[interiorId]["enterColShape"]
				local enterPosition = availableInteriors[interiorId]["entrance"]

				if isElement(enterPickupElement) then
					setElementPosition(enterPickupElement, enterPosition["position"][1], enterPosition["position"][2], enterPosition["position"][3] - 1)
					setElementInterior(enterPickupElement, enterPosition["interior"])
					setElementDimension(enterPickupElement, enterPosition["dimension"])
				end

				if isElement(enterColShapeElement) then
					setElementPosition(enterColShapeElement, enterPosition["position"][1], enterPosition["position"][2], enterPosition["position"][3])
					setElementInterior(enterColShapeElement, enterPosition["interior"])
					setElementDimension(enterColShapeElement, enterPosition["dimension"])
				end
			end
		end
	end
)

addCommandHandler("setinteriorexit",
	function (commandName, interiorId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					triggerServerEvent("setInteriorExit", localPlayer, interiorId, {
						["exit_position"] = table.concat({getElementPosition(localPlayer)}, ","),
						["exit_rotation"] = table.concat({getElementRotation(localPlayer)}, ","),
						["exit_interior"] = getElementInterior(localPlayer),
						["exit_dimension"] = getElementDimension(localPlayer)
					})
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

function setInteriorExitPosition(interiorId, posX, posY, posZ, rotZ)
	triggerServerEvent("setInteriorExit", resourceRoot, interiorId, {
		["exit_position"] = table.concat({posX, posY, posZ}, ","),
		["exit_rotation"] = table.concat({0, 0, rotZ}, ","),
		["exit_interior"] = 1,
		["exit_dimension"] = tonumber(interiorId)
	})
end

addEvent("setInteriorExit", true)
addEventHandler("setInteriorExit", getRootElement(),
	function (interiorId, newDatas)
		if interiorId and newDatas then
			local interior = availableInteriors[interiorId]

			if interior then
				for k, v in pairs(newDatas) do
					parseInteriorData(interiorId, k, v)
				end

				local exitPickupElement = availableInteriors[interiorId]["exitPickup"]
				local exitColShapeElement = availableInteriors[interiorId]["exitColShape"]
				local exitPosition = availableInteriors[interiorId]["exit"]

				if isElement(exitPickupElement) then
					setElementPosition(exitPickupElement, exitPosition["position"][1], exitPosition["position"][2], exitPosition["position"][3] - 1)
					setElementInterior(exitPickupElement, exitPosition["interior"])
					setElementDimension(exitPickupElement, exitPosition["dimension"])
				end

				if isElement(exitColShapeElement) then
					setElementPosition(exitColShapeElement, exitPosition["position"][1], exitPosition["position"][2], exitPosition["position"][3])
					setElementInterior(exitColShapeElement, exitPosition["interior"])
					setElementDimension(exitColShapeElement, exitPosition["dimension"])
				end
			end
		end
	end
)

addCommandHandler("nearbyinteriors",
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			local currentX, currentY, currentZ = getElementPosition(localPlayer)
			local currentInterior = getElementInterior(localPlayer)
			local currentDimension = getElementDimension(localPlayer)
			local nearbyList = {}

			for k, v in pairs(availableInteriors) do
				local entranceDistance = getDistanceBetweenPoints3D(currentX, currentY, currentZ, v["entrance"]["position"][1], v["entrance"]["position"][2], v["entrance"]["position"][3])
				local exitDistance = getDistanceBetweenPoints3D(currentX, currentY, currentZ, v["exit"]["position"][1], v["exit"]["position"][2], v["exit"]["position"][3])

				if entranceDistance <= 15 then
					if v["entrance"]["interior"] == currentInterior and v["entrance"]["dimension"] == currentDimension then
						table.insert(nearbyList, {k, v["name"]})
					end
				elseif exitDistance <= 15 then
					if v["exit"]["interior"] == currentInterior and v["exit"]["dimension"] == currentDimension then
						table.insert(nearbyList, {k, v["name"]})
					end
				end
			end

			if #nearbyList > 0 then
				outputChatBox("#3d7abc[Interior]: #ffffffKözeledben lévő interiorok (15 yard):", 255, 255, 255, true)

				for k, v in ipairs(nearbyList) do
					outputChatBox("    * #3d7abcAzonosító: #ffffff" .. v[1] .. " | #3d7abcNév: #ffffff" .. utf8.gsub(v[2], "_", " "), 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[Interior]: #ffffffNincs egyetlen interior sem a közeledben.", 255, 255, 255, true)
			end
		end
	end
)

addCommandHandler("setinteriorid",
	function (commandName, interiorId, gameInterior)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)
			gameInterior = tonumber(gameInterior)

			if not (interiorId and gameInterior) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID] [Belső]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					if gameInteriors[gameInterior] then
						if availableInteriors[interiorId]["editable"] ~= "N" and getElementData(localPlayer, "acc.adminLevel") < 7 then
							outputChatBox("#d75959[Interior]: #ffffffSzerkeszthető interiorok belsejét csak SA kezelheti!", 255, 255, 255, true)
							return
						end

						triggerServerEvent("setInteriorId", localPlayer, interiorId, {
							["exit_position"] = table.concat(gameInteriors[gameInterior]["position"], ","),
							["exit_rotation"] = table.concat(gameInteriors[gameInterior]["rotation"], ","),
							["exit_interior"] = gameInteriors[gameInterior]["interior"],
							["exit_dimension"] = interiorId,
							["gameInterior"] = gameInterior
						})
					else
						outputChatBox("#d75959[Interior]: #ffffffA kiválasztott belső nem létezik.", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("setInteriorId", true)
addEventHandler("setInteriorId", getRootElement(),
	function (interiorId, newDatas)
		if interiorId and newDatas then
			if availableInteriors[interiorId] then
				for k, v in pairs(newDatas) do
					parseInteriorData(interiorId, k, v)
				end

				local exitPickupElement = availableInteriors[interiorId]["exitPickup"]
				local exitColShapeElement = availableInteriors[interiorId]["exitColShape"]
				local exitPosition = availableInteriors[interiorId]["exit"]

				if isElement(exitPickupElement) then
					setElementPosition(exitPickupElement, exitPosition["position"][1], exitPosition["position"][2], exitPosition["position"][3] - 1)
					setElementInterior(exitPickupElement, exitPosition["interior"])
					setElementDimension(exitPickupElement, exitPosition["dimension"])
				end

				if isElement(exitColShapeElement) then
					setElementPosition(exitColShapeElement, exitPosition["position"][1], exitPosition["position"][2], exitPosition["position"][3])
					setElementInterior(exitColShapeElement, exitPosition["interior"])
					setElementDimension(exitColShapeElement, exitPosition["dimension"])
				end

				refreshInteriorBox(interiorId)
			end
		end
	end
)

addCommandHandler("setinterioreditable",
	function (commandName, interiorId, x, y)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)
			x = tonumber(x)
			y = tonumber(y)

			if not (interiorId and x and y) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID] [x] [y]", 255, 255, 255, true)
			else
				if x > 13 or y > 13 or x < 2 or y < 2 then
					outputChatBox("#d75959[Interior]: #ffffffA méret 2 és 13 között lehet!", 255, 255, 255, true)
					return
				end

				if availableInteriors[interiorId] then
					if availableInteriors[interiorId]["editable"] ~= "N" then
						outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior már szerkeszthető.", 255, 255, 255, true)
						return
					end

					triggerServerEvent("setInteriorEditable", localPlayer, interiorId, {
						["exit_position"] = table.concat(gameInteriors["e"]["position"], ","),
						["exit_rotation"] = table.concat(gameInteriors["e"]["rotation"], ","),
						["exit_interior"] = gameInteriors["e"]["interior"],
						["exit_dimension"] = interiorId,
						["gameInterior"] = 1,
						["editable"] = x .. "x" .. y
					})
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("getinterioreditable",
	function (commandName, interiorId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					if availableInteriors[interiorId]["editable"] and string.find(availableInteriors[interiorId]["editable"], "x") then
						outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior szerkeszthető, mérete: " .. availableInteriors[interiorId]["editable"] .. ".", 255, 255, 255, true)
					else
						outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem szerkeszthető.", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("gotointerior",
	function (commandName, interiorId, colShapeType)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			interiorId = tonumber(interiorId)
			colShapeType = tonumber(colShapeType) or 0

			if not (interiorId and colShapeType) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID] [< 0 = bejárat | 1 = kijárat >]", 255, 255, 255, true)
			else
				if availableInteriors[interiorId] then
					if not isPedInVehicle(localPlayer) then
						if colShapeType == 1 then
							colShapeType = "exit"
						else
							colShapeType = "entrance"
						end

						local colShapePosition = availableInteriors[interiorId][colShapeType]

						if colShapePosition then
							triggerServerEvent("warpPlayerEx", localPlayer, colShapePosition["position"][1], colShapePosition["position"][2], colShapePosition["position"][3], colShapePosition["rotation"][1], colShapePosition["rotation"][2], colShapePosition["rotation"][3], colShapePosition["interior"], colShapePosition["dimension"])
						end
					else
						outputChatBox("#d75959[Interior]: #ffffffElőbb szállj ki a járműből!", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", 255, 255, 255, true)
				end
			end
		end
	end
)
