local worldItems = {}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		dbQuery(loadAllWorldItem, connection, [[
			SELECT worlditems.*, items.dbID, items.itemId, items.amount, items.data1, items.data2, items.data3, items.nameTag, items.serial 
			FROM worlditems 
			JOIN items ON items.dbID = worlditems.itemDbID 
			WHERE items.ownerType = 'world' AND items.ownerId = 0
		]])
	end)

addEvent("requestWorldItems", true)
addEventHandler("requestWorldItems", getRootElement(),
	function ()
		if isElement(source) then
			triggerLatentClientEvent(source, "receiveWorldItems", source, worldItems)
		end
	end)

addEvent("dropItem", true)
addEventHandler("dropItem", getRootElement(),
	function (movedItem, data)
		if isElement(source) then
			if movedItem and type(movedItem) == "table" and data and type(data) == "table" then
				local characterId = tonumber(getElementData(source, defaultSettings.characterId))

				if characterId and itemsTable[source] then
					local slot = false

					for k, v in pairs(itemsTable[source]) do
						if v.dbID == movedItem.dbID then
							slot = v.slot
							break
						end
					end

					if slot then
						dbExec(connection, "INSERT INTO worlditems (itemDbID, creatorCharacter, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, model) VALUES (?,?,?,?,?,?,?,?,?,?,?)", movedItem.dbID, characterId, data.posX, data.posY, data.posZ, data.rotX, data.rotY, data.rotZ, data.interior, data.dimension, data.model)
						dbQuery(
							function (qh, sourcePlayer)
								local result = dbPoll(qh, 0)[1]

								if result then
									itemsTable[sourcePlayer][slot] = nil

									dbExec(connection, "UPDATE items SET ownerType = 'world', ownerId = 0 WHERE dbID = ?", movedItem.dbID)

									if isElement(sourcePlayer) then
										triggerClientEvent(sourcePlayer, "deleteItem", sourcePlayer, "player", {movedItem.dbID})
										triggerClientEvent(sourcePlayer, "movedItemInInv", sourcePlayer)
										setPedAnimation(sourcePlayer, "CARRY", "putdwn", 500, false, false, false, false)
									end

									loadWorldItem(result.itemDbID, result, true)
								end
							end, {source},
						connection, "SELECT worlditems.*, items.dbID, items.itemId, items.amount, items.data1, items.data2, items.data3, items.nameTag, items.serial FROM worlditems JOIN items ON items.dbID = ? WHERE worlditems.itemDbID = ?", movedItem.dbID, movedItem.dbID)
					else
						outputChatBox("#DC143C[SeeMTA]: #ffffffA tárgy eldobása meghiúsult.", source, 0, 0, 0, true)
					end
				end
			end
		end
	end)

addEvent("pickUpItem", true)
addEventHandler("pickUpItem", getRootElement(),
	function (itemId)
		if isElement(source) then
			itemId = tonumber(itemId)

			if itemId then
				local worldItem = worldItems[itemId]

				if worldItem then
					local characterId = tonumber(getElementData(source, defaultSettings.characterId))

					if characterId then
						if not itemsTable[source] then
							itemsTable[source] = {}
						end

						if getCurrentWeight(source) + getItemWeight(worldItem.itemId) * worldItem.amount > getWeightLimit("player", source) then
							outputChatBox("#DC143C[SeeMTA]: #ffffffAz inventoryd nem bírja el a kiválasztott tárgyat!", source, 0, 0, 0, true)
						else
							local slotId = findEmptySlot(source, "player", worldItem.itemId)

							if not slotId then
								outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFNincs szabad slot az inventorydban!", source, 255, 255, 255, true)
							else
								if isElement(worldItems[itemId].objectElement) then
									destroyElement(worldItems[itemId].objectElement)
								end

								dbExec(connection, "DELETE FROM worlditems WHERE itemDbID = ?", worldItem.dbID)
								dbExec(connection, "UPDATE items SET ownerType = 'player', ownerId = ?, slot = ? WHERE dbID = ?", characterId, slotId, worldItem.dbID)

								addItem(source, worldItem.dbID, slotId, worldItem.itemId, worldItem.amount, worldItem.data1, worldItem.data2, worldItem.data3, worldItem.nameTag, worldItem.serial)

								triggerLatentClientEvent(getElementsByType("player"), "destroyWorldItem", resourceRoot, itemId)
								triggerClientEvent(source, "äĐĐÍÄ<", source, "player", itemsTable[source][slotId])
								triggerClientEvent(source, "movedItemInInv", source)

								if worldItem.nameTag then
									exports.see_chat:localAction(source, "felvett egy tárgyat a földről. (" .. getItemName(worldItem.itemId) .. " (" .. worldItem.nameTag .. "))")
								else
									exports.see_chat:localAction(source, "felvett egy tárgyat a földről. (" .. getItemName(worldItem.itemId) .. ")")
								end

								setPedAnimation(source, "CARRY", "liftup", 600, false, false, false, false)

								worldItems[itemId] = nil
							end
						end
					end
				end
			end
		end
	end)

function loadAllWorldItem(qh)
	local result = dbPoll(qh, 0)

	if result then
		for k, v in pairs(result) do
			loadWorldItem(v.itemDbID, v)
		end
	end
end

function loadWorldItem(itemId, data, sync)
	if tonumber(itemId) and type(data) == "table" then
		worldItems[itemId] = data
		worldItems[itemId].objectElement = createObject(data.model, data.posX, data.posY, data.posZ, data.rotX, data.rotY, data.rotZ)

		if isElement(worldItems[itemId].objectElement) then
			setElementInterior(worldItems[itemId].objectElement, data.interior)
			setElementDimension(worldItems[itemId].objectElement, data.dimension)

			if sync then
				triggerLatentClientEvent(getElementsByType("player"), "addWorldItem", resourceRoot, itemId, data)
			end
		end
	end
end