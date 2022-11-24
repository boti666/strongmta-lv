local storedTrashes = {}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		dbQuery(loadAllTrash, connection, "SELECT * FROM trashes")
	end)

addEvent("requestTrashes", true)
addEventHandler("requestTrashes", getRootElement(),
	function ()
		if isElement(source) then
			triggerLatentClientEvent(source, "receiveTrashes", source, storedTrashes)
		end
	end)

addCommandHandler("createtrash",
	function (sourcePlayer, commandName, model)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			model = tonumber(model) or 1359

			if isTrashModel(model) then
				local x, y, z = getElementPosition(sourcePlayer)
				local rx, ry, rz = getElementRotation(sourcePlayer)
				local int = getElementInterior(sourcePlayer)
				local dim = getElementDimension(sourcePlayer)

				dbExec(connection, "INSERT INTO trashes (posX, posY, posZ, rotZ, interior, dimension, model) VALUES (?,?,?,?,?,?,?)", x, y, z - 0.3, rz, int, dim, model)
				dbQuery(
					function (qh)
						local result = dbPoll(qh, 0)[1]

						if result then
							loadTrash(result.trashId, result, true)
							outputChatBox("#DC143C[SeeMTA]: #ffffffA szemetes sikeresen létrehozva. #4aabd0(" .. result.trashId .. ")", sourcePlayer, 0, 0, 0, true)
						else
							outputChatBox("#DC143C[SeeMTA]: #ffffffA szemetes létrehozása meghiúsult.", sourcePlayer, 0, 0, 0, true)
						end
					end,
				connection, "SELECT * FROM trashes WHERE trashId = LAST_INSERT_ID()")
			else
				outputChatBox("#DC143C[SeeMTA]: #ffffffA kiválasztott model nem egy szemetes model.", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

addCommandHandler("deletetrash",
	function (sourcePlayer, commandName, trashId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			trashId = tonumber(trashId)

			if not trashId then
				outputChatBox("[Használat]: #ffffff/" .. commandName .. " [Szemetes ID]", sourcePlayer, 255, 150, 0, true)
			elseif not storedTrashes[trashId] then
				outputChatBox("#DC143C[SeeMTA]: #ffffffA kiválasztott szemetes nem létezik.", sourcePlayer, 0, 0, 0, true)
			else
				dbExec(connection, "DELETE FROM trashes WHERE trashId = ?", trashId)

				if isElement(storedTrashes[trashId].objectElement) then
					destroyElement(storedTrashes[trashId].objectElement)
				end

				storedTrashes[trashId] = nil

				triggerLatentClientEvent(getElementsByType("player"), "destroyTrash", resourceRoot, trashId)

				outputChatBox("#7cc576[SeeMTA]: #ffffffA szemetes sikeresen törölve.", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

function loadAllTrash(qh)
	local result = dbPoll(qh, 0)

	if result then
		for k, v in pairs(result) do
			loadTrash(v.trashId, v)
		end
	end
end

function loadTrash(trashId, data, sync)
	if tonumber(trashId) and type(data) == "table" then
		storedTrashes[trashId] = data
		storedTrashes[trashId].objectElement = createObject(data.model, data.posX, data.posY, data.posZ, 0, 0, data.rotZ)

		if isElement(storedTrashes[trashId].objectElement) then
			setElementInterior(storedTrashes[trashId].objectElement, data.interior)
			setElementDimension(storedTrashes[trashId].objectElement, data.dimension)

			if sync then
				triggerLatentClientEvent(getElementsByType("player"), "createTrash", resourceRoot, trashId, data)
			end
		end
	end
end