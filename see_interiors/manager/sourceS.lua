local function floatToString(t)
	return string.format("%s,%s,%s", t[1], t[2], t[3])
end

local function deepcopy(t)
	local copy
	if type(t) == "table" then
		copy = {}
		for k, v in next, t, nil do
			copy[deepcopy(k)] = deepcopy(v)
		end
		setmetatable(copy, deepcopy(getmetatable(t)))
	else
		copy = t
	end
	return copy
end

local originalInteriors = deepcopy(availableInteriors)

function createInteriorCallback(queryHandle, sourcePlayer)
	local resultRows, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)

	if resultRows then
		local resultRow = resultRows[1]

		if resultRow then
			loadInterior(resultRow.interiorId, resultRow, true)

			if isElement(sourcePlayer) then
				outputChatBox("#3d7abc[Interior]: #ffffffSikeresen létrehoztál egy interiort. #32b3ef(" .. resultRow.interiorId .. ")", sourcePlayer, 255, 255, 255, true)
				
				exports.see_logs:logCommand(sourcePlayer, "createInterior", {
					resultRow.interiorId,
					resultRow.name,
					"type: " .. resultRow.type
				})
			end
		end
	end
end

addEvent("createInterior", true)
addEventHandler("createInterior", getRootElement(),
	function (interiorDatas)
		if isElement(source) then
			if interiorDatas then
				local columnNames = {}
				local valueMarks = {}
				local parameters = {}

				for k, v in pairs(interiorDatas) do
					table.insert(columnNames, k)
					table.insert(valueMarks, "?")
					table.insert(parameters, v)
				end

				dbExec(connection, "INSERT INTO interiors (" .. table.concat(columnNames, ",") .. ") VALUES (" .. table.concat(valueMarks, ",") .. ")", unpack(parameters))
				dbExec(connection, "UPDATE interiors SET exit_dimension = interiorId WHERE interiorId = LAST_INSERT_ID()")
				dbQuery(createInteriorCallback, {source}, connection, "SELECT * FROM interiors WHERE interiorId = LAST_INSERT_ID()")
			end
		end
	end
)

addEvent("deleteInterior", true)
addEventHandler("deleteInterior", getRootElement(),
	function (interiorId)
		if isElement(source) then
			if interiorId then
				if availableInteriors[interiorId] then
					if not deletedInteriors[interiorId] then
						deletedInteriors[interiorId] = true
						availableInteriors[interiorId] = nil

						triggerClientEvent("deleteInterior", resourceRoot, interiorId)

						dbExec(connection, "UPDATE interiors SET deleted = 'Y' WHERE interiorId = ?", interiorId)

						outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior sikeresen törölve. #32b3ef(" .. interiorId .. ")", source, 255, 255, 255, true)
							
						exports.see_logs:logCommand(source, "deleteInterior", {interiorId})
					else
						outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior már törölve van.", source, 255, 255, 255, true)
						outputChatBox("#d75959[Interior]: #ffffffAz interior visszaállításához használd a #d75959/resetinterior#ffffff parancsot.", source, 255, 255, 255, true)
					end
				elseif deletedInteriors[interiorId] then
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior már törölve van.", source, 255, 255, 255, true)
					outputChatBox("#d75959[Interior]: #ffffffAz interior visszaállításához használd a #3d7abc'/resetinterior' #ffffffparancsot.", source, 255, 255, 255, true)
				end
			end
		end
	end
)

function resetInteriorCallback(queryHandle, sourcePlayer)
	local resultRows, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)

	if resultRows then
		local resultRow = resultRows[1]

		if resultRow then
			loadInterior(resultRow.interiorId, resultRow, true)

			if isElement(sourcePlayer) then
				outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior sikeresen visszaállítva. #32b3ef(" .. resultRow.interiorId .. ")", sourcePlayer, 255, 255, 255, true)
				
				exports.see_logs:logCommand(sourcePlayer, "resetInterior", {resultRow.interiorId})
			end
		end
	end
end

addCommandHandler("resetinterior",
	function (sourcePlayer, commandName, interiorId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", sourcePlayer, 255, 255, 255, true)
			else
				if deletedInteriors[interiorId] then
					deletedInteriors[interiorId] = nil

					local originalInterior = originalInteriors[interiorId]

					if originalInterior then
						local columnNames = {}
						local columnValues = {}
						local preparedDatas = {
							["flag"] = "dynamic",
							["price"] = originalInterior["price"],
							["type"] = originalInterior["type"],
							["name"] = originalInterior["name"],
							["gameInterior"] = originalInterior["gameInterior"],
							["entrance_position"] = floatToString(originalInterior["entrance_position"]),
							["entrance_rotation"] = floatToString(originalInterior["entrance_rotation"]),
							["entrance_interior"] = originalInterior["entrance_interior"],
							["entrance_dimension"] = originalInterior["entrance_dimension"],
							["exit_position"] = floatToString(originalInterior["exit_position"]),
							["exit_rotation"] = floatToString(originalInterior["exit_rotation"]),
							["exit_interior"] = originalInterior["exit_interior"],
							["exit_dimension"] = originalInterior["exit_dimension"]
						}

						for k, v in pairs(preparedDatas) do
							table.insert(columnNames, k .. " = ?")
							table.insert(columnValues, v)
						end

						dbExec(connection, "UPDATE interiors SET " .. table.concat(columnNames, ", ") .. " WHERE interiorId = ?", unpack(columnValues), interiorId)
					end

					dbExec(connection, "UPDATE interiors SET deleted = 'N', renewalTime = 0, lastReport = '0' WHERE interiorId = ?", interiorId)
					dbQuery(resetInteriorCallback, {source}, connection, "SELECT * FROM interiors WHERE interiorId = ? LIMIT 1", interiorId)
				elseif availableInteriors[interiorId] then
					deletedInteriors[interiorId] = nil

					triggerClientEvent("resetInterior", resourceRoot, interiorId)

					unownInterior(interiorId)

					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior sikeresen visszaállítva. #32b3ef(" .. interiorId .. ")", sourcePlayer, 255, 255, 255, true)
						
					exports.see_logs:logCommand(sourcePlayer, "resetInterior", {interiorId})
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("setInteriorName", true)
addEventHandler("setInteriorName", getRootElement(),
	function (interiorId, newName)
		if isElement(source) then
			if interiorId and newName then
				if availableInteriors[interiorId] then
					availableInteriors[interiorId]["name"] = newName

					triggerClientEvent("setInteriorName", resourceRoot, interiorId, newName)

					dbExec(connection, "UPDATE interiors SET name = ? WHERE interiorId = ?", newName, interiorId)

					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior sikeresen átnevezve. #32b3ef(" .. newName .. ")", source, 255, 255, 255, true)
						
					exports.see_logs:logCommand(source, eventName, {interiorId, newName})
				end
			end
		end
	end
)

addEvent("setInteriorPrice", true)
addEventHandler("setInteriorPrice", getRootElement(),
	function (interiorId, newPrice)
		if isElement(source) then
			if interiorId and newPrice then
				if availableInteriors[interiorId] then
					availableInteriors[interiorId]["price"] = newPrice

					triggerClientEvent("setInteriorPrice", resourceRoot, interiorId, newPrice)

					dbExec(connection, "UPDATE interiors SET price = ? WHERE interiorId = ?", newPrice, interiorId)

					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior ára sikeresen módosítva. #32b3ef(" .. formatNumber(newPrice) .. "$)", source, 255, 255, 255, true)
						
					exports.see_logs:logCommand(source, eventName, {interiorId, newPrice})
				end
			end
		end
	end
)

addEvent("setInteriorType", true)
addEventHandler("setInteriorType", getRootElement(),
	function (interiorId, newType)
		if isElement(source) then
			if interiorId and newType then
				if availableInteriors[interiorId] then
					availableInteriors[interiorId]["type"] = newType

					triggerClientEvent("setInteriorType", resourceRoot, interiorId, newType)

					dbExec(connection, "UPDATE interiors SET type = ? WHERE interiorId = ?", newType, interiorId)

					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior típusa sikeresen módosítva.", source, 255, 255, 255, true)
					
					exports.see_logs:logCommand(source, eventName, {interiorId, newType})
				end
			end
		end
	end
)

addEvent("setInteriorEntrance", true)
addEventHandler("setInteriorEntrance", getRootElement(),
	function (interiorId, newDatas)
		if isElement(source) then
			if interiorId and newDatas then
				if availableInteriors[interiorId] then
					for k, v in pairs(newDatas) do
						parseInteriorData(interiorId, k, v)
					end

					triggerClientEvent("setInteriorEntrance", resourceRoot, interiorId, newDatas)

					dbExec(connection, "UPDATE interiors SET entrance_position = ?, entrance_rotation = ?, entrance_interior = ?, entrance_dimension = ? WHERE interiorId = ?", newDatas["entrance_position"], newDatas["entrance_rotation"], newDatas["entrance_interior"], newDatas["entrance_dimension"], interiorId)
					
					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior bejárata sikeresen áthelyezve.", source, 255, 255, 255, true)
					
					exports.see_logs:logCommand(source, eventName, {interiorId})
				end
			end
		end
	end
)

addEvent("setInteriorExit", true)
addEventHandler("setInteriorExit", getRootElement(),
	function (interiorId, newDatas)
		if isElement(source) then
			if interiorId and newDatas then
				if availableInteriors[interiorId] then
					newDatas["dummy"] = "N"
					
					for k, v in pairs(newDatas) do
						parseInteriorData(interiorId, k, v)
					end
					
					triggerClientEvent("setInteriorExit", resourceRoot, interiorId, newDatas)

					dbExec(connection, "UPDATE interiors SET dummy = ?, exit_position = ?, exit_rotation = ?, exit_interior = ?, exit_dimension = ? WHERE interiorId = ?", newDatas["dummy"], newDatas["exit_position"], newDatas["exit_rotation"], newDatas["exit_interior"], newDatas["exit_dimension"], interiorId)
					
					if source == client then
						outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior kijárata sikeresen áthelyezve.", source, 255, 255, 255, true)
						
						exports.see_logs:logCommand(source, eventName, {interiorId})
					end
				end
			end
		end
	end
)

addEvent("setInteriorId", true)
addEventHandler("setInteriorId", getRootElement(),
	function (interiorId, newDatas)
		if isElement(source) then
			if interiorId and newDatas then
				if availableInteriors[interiorId] then
					newDatas["dummy"] = "N"
					
					for k, v in pairs(newDatas) do
						parseInteriorData(interiorId, k, v)
					end
					
					triggerClientEvent("setInteriorId", resourceRoot, interiorId, newDatas)

					dbExec(connection, "UPDATE interiors SET dummy = ?, gameInterior = ?, exit_position = ?, exit_rotation = ?, exit_interior = ?, exit_dimension = ? WHERE interiorId = ?", newDatas["dummy"], newDatas["gameInterior"], newDatas["exit_position"], newDatas["exit_rotation"], newDatas["exit_interior"], newDatas["exit_dimension"], interiorId)
					
					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior belső kinézete sikeresen lecserélve.", source, 255, 255, 255, true)
						
					exports.see_logs:logCommand(source, eventName, {interiorId, newDatas["gameInterior"]})
				end
			end
		end
	end
)

addEvent("setInteriorEditable", true)
addEventHandler("setInteriorEditable", getRootElement(),
	function (interiorId, newDatas)
		if isElement(source) then
			if interiorId and newDatas then
				if availableInteriors[interiorId] then
					newDatas["dummy"] = "N"
					
					for k, v in pairs(newDatas) do
						parseInteriorData(interiorId, k, v)
					end
					
					triggerClientEvent("setInteriorId", resourceRoot, interiorId, newDatas)

					dbExec(connection, "UPDATE interiors SET editable = ?, dummy = ?, gameInterior = ?, exit_position = ?, exit_rotation = ?, exit_interior = ?, exit_dimension = ? WHERE interiorId = ?", newDatas["editable"], newDatas["dummy"], newDatas["gameInterior"], newDatas["exit_position"], newDatas["exit_rotation"], newDatas["exit_interior"], newDatas["exit_dimension"], interiorId)
					dbExec(connection, "INSERT INTO interior_datas SET interiorId = ? ON DUPLICATE KEY UPDATE interiorId = interiorId", interiorId)
					
					outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior szerkeszthetővé alakítva. (" .. newDatas["editable"] .. ")", source, 255, 255, 255, true)
						
					exports.see_logs:logCommand(source, eventName, {interiorId, newDatas["editable"]})
				end
			end
		end
	end
)

addCommandHandler("setinteriorowner",
	function (sourcePlayer, commandName, interiorId, partialNick)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID] [Játékos Név / ID]", sourcePlayer, 255, 255, 255, true)
			else
				local int = availableInteriors[interiorId]

				if int then
					if int.type ~= "building" and int.type ~= "rentable" then
						local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, partialNick)

						if isElement(targetPlayer) then
							local characterId = getElementData(targetPlayer, "char.ID")

							if characterId then
								int.ownerId = characterId

								if exports.see_items:hasSpaceForItem(targetPlayer, 2) then
									if not exports.see_items:hasItemWithData(targetPlayer, 2, interiorId) then
										exports.see_items:giveItem(targetPlayer, 2, 1, false, interiorId)
									end
								end

								triggerClientEvent("changeInteriorOwner", resourceRoot, interiorId, characterId)
								dbExec(connection, "UPDATE interiors SET ownerId = ? WHERE interiorId = ?", characterId, interiorId)
							end
						end
					else
						outputChatBox("#d75959[Interior]: #ffffffKözépületnek és bérlakásnak nem lehet tulajdonost beállítani.", sourcePlayer, 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
				outputChatBox("#3d7abc[StrongMTA]: Az interior tulajdonjoga sikeresen átadva.", sourcePlayer, 255, 255, 255, true)
			end
		end
	end
)

function getInteriorOwnerCallback(queryHandle, sourcePlayer)
	if isElement(sourcePlayer) then
		local resultRows, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)

		if resultRows then
			local resultRow = resultRows[1]

			if resultRow then
				outputChatBox("#3d7abc[Interior]: #ffffffA kiválasztott interior tulajdonosa #3d7abc" .. resultRow.name .. " [Karakter ID: " .. resultRow.characterId .. " - Account ID: " .. resultRow.accountId .. "].", sourcePlayer, 255, 255, 255, true)
			end
		end
	end
end

addCommandHandler("getinteriorowner",
	function (sourcePlayer, commandName, interiorId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			interiorId = tonumber(interiorId)

			if not interiorId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Interior ID]", sourcePlayer, 255, 255, 255, true)
			else
				local int = availableInteriors[interiorId]

				if int then
					if int.ownerId > 0 then
						dbQuery(getInteriorOwnerCallback, {sourcePlayer}, connection, "SELECT characters.name, characters.characterId, characters.accountId FROM characters LEFT JOIN interiors ON interiors.ownerId = characters.characterId WHERE interiors.interiorId = ? LIMIT 1", interiorId)
					else
						outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interiornak nincs tulajdonosa.", sourcePlayer, 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[Interior]: #ffffffA kiválasztott interior nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("warpPlayerEx", true)
addEventHandler("warpPlayerEx", getRootElement(),
	function (posX, posY, posZ, rotX, rotY, rotZ, interior, dimension)
		if isElement(source) and client and client == source then
			if posX and posY and posZ and rotX and rotY and rotZ and interior and dimension then
				warpElement(source, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension)
				
				setElementData(source, "player.currentInterior", dimension)

				outputChatBox("#3d7abc[Interior]: #ffffffSikeresen elteleportáltál a kiválasztott interiorhoz.", source, 255, 255, 255, true)

				exports.see_logs:logCommand(source, commandName, {interiorId})
			end
		end
	end
)