storedSafes = {}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		dbQuery(loadAllSafe, connection, "SELECT * FROM safes")
	end)

addEvent("requestSafes", true)
addEventHandler("requestSafes", getRootElement(),
	function ()
		if isElement(source) then
			triggerLatentClientEvent(source, "receiveSafes", source, storedSafes)
		end
	end)

addCommandHandler("movesafe",
	function (sourcePlayer, commandName, safeId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			safeId = tonumber(safeId)

			if not safeId then
				outputChatBox("#ea7212[Használat]: #FFFFFF/" .. commandName .. " [Azonosító]", sourcePlayer, 255, 255, 255, true)
			else
				local data = storedSafes[safeId]

				if data then
					local x, y, z = getElementPosition(sourcePlayer)
					local rz = select(3, getElementRotation(sourcePlayer))
					local int = getElementInterior(sourcePlayer)
					local dim = getElementDimension(sourcePlayer)

					z = z - 0.375
					rz = (rz + 180) % 360

					data.posX, data.posY, data.posZ, data.rotZ = x, y, z, rz
					data.interior, data.dimension = int, dim

					setElementPosition(data.objectElement, x, y, z)
					setElementRotation(data.objectElement, 0, 0, rz)
					setElementInterior(data.objectElement, int)
					setElementDimension(data.objectElement, dim)

					triggerClientEvent(getElementsByType("player"), "updateSafe", resourceRoot, safeId, data)

					exports.see_accounts:showInfo(sourcePlayer, "s", "A kiválasztott széf sikeresen áthelyezésre került.")

					dbExec(connection, "UPDATE safes SET posX = ?, posY = ?, posZ = ?, rotZ = ?, interior = ?, dimension = ? WHERE dbID = ?", x, y, z, rz, int, dim, safeId)
				else
					outputChatBox("#DC143C[SeeMTA]: #FFFFFFA kiválasztott széf nem található.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end)

addEvent("moveSafeFurniture", true)
addEventHandler("moveSafeFurniture", getRootElement(),
	function (safeId, x, y, z, rz, int, dim)
		if isElement(source) then
			if x and y and z and rz then
				local data = storedSafes[safeId]

				if data then
					if not int then
						int = getElementInterior(data.objectElement)
					end

					if not dim then
						dim = getElementDimension(data.objectElement)
					end

					data.posX, data.posY, data.posZ, data.rotZ = x, y, z, rz
					data.interior, data.dimension = int, dim

					setElementPosition(data.objectElement, x, y, z)
					setElementRotation(data.objectElement, 0, 0, rz)
					setElementInterior(data.objectElement, int)
					setElementDimension(data.objectElement, dim)

					triggerClientEvent(getElementsByType("player"), "updateSafe", resourceRoot, safeId, data)

					exports.see_accounts:showInfo(source, "s", "A kiválasztott széf sikeresen áthelyezésre került.")

					dbExec(connection, "UPDATE safes SET posX = ?, posY = ?, posZ = ?, rotZ = ?, interior = ?, dimension = ? WHERE dbID = ?", x, y, z, rz, int, dim, safeId)
				end
			end
		end
	end)

addEvent("createSafe", true)
addEventHandler("createSafe", getRootElement(),
	function (ownerGroup, x, y, z, rz, int, dim)
		if isElement(source) then
			ownerGroup = tonumber(ownerGroup)
			
			if ownerGroup and x and y and z and rz and int and dim then
				dbExec(connection, "INSERT INTO safes (posX, posY, posZ, rotZ, interior, dimension, ownerGroup) VALUES (?,?,?,?,?,?,?)", x, y, z, rz, int, dim, ownerGroup)
				dbQuery(
					function (qh, sourcePlayer)
						local result = dbPoll(qh, 0)[1]

						if result then
							loadSafe(result.dbID, result, true)
							giveItem(sourcePlayer, 154, 1, false, result.dbID)
							exports.see_accounts:showInfo(sourcePlayer, "s", "Széf sikeresen létrehozva! ID: " .. result.dbID)
						end
					end, {source},
				connection, "SELECT * FROM safes WHERE dbID = LAST_INSERT_ID()")
			end
		end
	end)

addEvent("destroySafe", true)
addEventHandler("destroySafe", getRootElement(),
	function (safeId)
		if isElement(source) then
			safeId = tonumber(safeId)

			if safeId then
				dbExec(connection, "DELETE FROM safes WHERE dbID = ?", safeId)

				if isElement(storedSafes[safeId].objectElement) then
					destroyElement(storedSafes[safeId].objectElement)
				end

				storedSafes[safeId] = nil

				triggerClientEvent(getElementsByType("player"), "destroySafe", resourceRoot, safeId)

				outputChatBox("#7cc576[SeeMTA]: #ffffffA széf sikeresen törölve.", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

function loadAllSafe(qh)
	local result = dbPoll(qh, 0)

	if result then
		for k, v in pairs(result) do
			loadSafe(v.dbID, v)
		end
	end
end

function loadSafe(safeId, data, sync)
	if tonumber(safeId) and type(data) == "table" then
		storedSafes[safeId] = data
		storedSafes[safeId].objectElement = createObject(2332, data.posX, data.posY, data.posZ, 0, 0, data.rotZ)

		if isElement(storedSafes[safeId].objectElement) then
			setElementInterior(storedSafes[safeId].objectElement, data.interior)
			setElementDimension(storedSafes[safeId].objectElement, data.dimension)
			setElementData(storedSafes[safeId].objectElement, defaultSettings.objectId, safeId)
			setElementData(storedSafes[safeId].objectElement, "safeId", safeId)

			if sync then
				triggerClientEvent(getElementsByType("player"), "createSafe", resourceRoot, safeId, data)
			end

			loadItems(storedSafes[safeId].objectElement)
		end
	end
end