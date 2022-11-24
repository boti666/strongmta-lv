local connection = false
local pedList = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		if isElement(connection) then
			dbQuery(loadAllPeds, connection, "SELECT * FROM peds")
		end

		setTimer(savePeds, 1000 * 60 * 30, 0)
	end)

addEventHandler("onResourceStop", getRootElement(),
	function (stoppedResource)
		if getResourceName(stoppedResource) == "see_database" then
			savePeds()
		else
			if stoppedResource == getThisResource() then
				if isElement(connection) then
					savePeds()
				end
			end
		end
	end)

function savePeds(pedId)
	if tonumber(pedId) then
		dbExec(connection, "UPDATE peds SET itemList = ? WHERE pedId = ?", toString(pedId), pedId)
	else
		for k, v in pairs(pedList) do
			dbExec(connection, "UPDATE peds SET itemList = ? WHERE pedId = ?", toString(k), k)
		end
	end

	outputDebugString("Save peds")
end

function toString(pedId)
	local itemList = pedList[pedId]

	if itemList and itemList.ownerId > 0 then
		local temp = {}

		for i = 1, #itemList.items do
			local itemId = itemList.items[i]

			table.insert(temp, itemId .. "/" .. (itemList.prices[itemId] or itemBasePrices[itemId]) .. "/" .. (itemList.stocks[itemId] or 0))
		end

		return table.concat(temp, ";")
	end

	return ""
end

function loadAllPeds(qh)
	local result = dbPoll(qh, 0)

	if result then
		for k, v in pairs(result) do
			loadPed(v.pedId, v)
		end
	end
end

function loadPed(pedId, data)
	local ped = createPed(data.skinId, data.posX, data.posY, data.posZ, data.rotZ, false)
	local col = createColSphere(data.posX, data.posY, data.posZ, 3.75)

	setElementInterior(col, data.interior)
	setElementDimension(col, data.dimension)
	setElementData(col, "pedColShape", pedId)

	setElementInterior(ped, data.interior)
	setElementDimension(ped, data.dimension)
	setElementFrozen(ped, true)

	setElementData(ped, "invulnerable", true)
	setElementData(ped, "visibleName", data.name)
	setElementData(ped, "interiorId", data.ownerId)

	setElementData(ped, "pedId", pedId)
	setElementData(ped, "pedType", data.mainType)
	setElementData(ped, "pedColShapeElement", col)
	setElementData(ped, "pedNameType", "Bolt")

	if data.mainType == 14 then
		setElementData(ped, "isScratchPed", true)
	end

	pedList[pedId] = {}
	pedList[pedId].element = ped
	pedList[pedId].colshape = col
	pedList[pedId].ownerId = data.ownerId
	pedList[pedId].categories = {unpack(mainTypes[data.mainType])}
	pedList[pedId].balance = tonumber(data.balance)
	pedList[pedId].items = {}
	pedList[pedId].prices = {}
	pedList[pedId].stocks = {}

	if data.ownerId > 0 then
		local items = split(data.itemList, ";")

		for i = 1, #items do
			local data = split(items[i], "/")
			local itemId = tonumber(data[1])

			table.insert(pedList[pedId].items, itemId)

			pedList[pedId].prices[itemId] = tonumber(data[2])
			pedList[pedId].stocks[itemId] = tonumber(data[3])
		end
	else
		collectPedItems(pedId)
	end
end

function collectPedItems(pedId)
	local itemList = pedList[pedId]

	if itemList then
		local itemAdded = {}

		itemList.items = {}
		itemList.prices = {}
		itemList.stocks = {}

		if itemList.ownerId <= 0 then
			for i = 1, #itemList.categories do
				local categoryId = itemList.categories[i]

				if categoryId then
					for j = 1, #itemsForChoosePlain[categoryId] do
						local itemId = itemsForChoosePlain[categoryId][j]

						if not itemAdded[itemId] then
							itemAdded[itemId] = true

							table.insert(itemList.items, itemId)

							itemList.prices[itemId] = itemBasePrices[itemId]
							itemList.stocks[itemId] = 1
						end
					end
				end
			end
		end
	end
end

addEvent("requestPedItemList", true)
addEventHandler("requestPedItemList", getRootElement(),
	function (pedId)
		if isElement(source) then
			local itemList = pedList[pedId]

			if itemList then
				triggerClientEvent(source, "gotPedItems", source, itemList.items, itemList.prices, itemList.stocks, pedId, itemList.categories, itemList.balance, itemList.ownerId)
			end
		end
	end)

addEvent("refreshPedItemList", true)
addEventHandler("refreshPedItemList", getRootElement(),
	function (pedId, items, prices)
		if isElement(source) then
			local itemList = pedList[pedId]

			if itemList then
				itemList.items = items
				itemList.prices = prices
			end
		end
	end)

addEvent("buyItemFromPed", true)
addEventHandler("buyItemFromPed", getRootElement(),
	function (pedId, itemId, amount)
		if isElement(source) and client and client == source then
			local itemList = pedList[pedId]

			if itemList then
				if itemList.ownerId > 0 then
					if itemList.stocks[itemId] == 0 then
						exports.see_accounts:showInfo(source, "e", "Ebből a termékből jelenleg nincs készleten.")
						return
					end
				end

				local itemPrice = itemList.prices[itemId] or itemBasePrices[itemId]
				local totalPrice = itemPrice * amount
				local currentMoney = getElementData(source, "char.Money") or 0

				currentMoney = currentMoney - totalPrice

				if currentMoney >= 0 then
					if exports.see_items:hasSpaceForItem(source, itemId, amount) then
						if itemId == 9 then 
							exports.see_items:giveItem(source, itemId, amount, false, 3876 ..math.random(1, 5000000), data2, data3)
						else
							exports.see_items:giveItem(source, itemId, amount, false, data1, data2, data3)
							exports.see_core:takeMoney(source, totalPrice, "buyItemFromPed")
						end

						if itemList.ownerId > 0 then
							if itemList.stocks[itemId] == 0 then
								--exports.see_accounts:showInfo(source, "e", "Ebből a termékből jelenleg nincs készleten.")
								return
							end
							itemList.balance = itemList.balance + totalPrice
							itemList.stocks[itemId] = itemList.stocks[itemId] - amount

							if itemList.stocks[itemId] < 0 then
								itemList.stocks[itemId] = 0
							end

							triggerClientEvent(source, "refreshPedItemStock", source, itemId, itemList.stocks[itemId], itemList.balance)

							dbExec(connection, "UPDATE peds SET balance = ? WHERE pedId = ?", itemList.balance, pedId)
						end

						exports.see_accounts:showInfo(source, "s", "Sikeres vásárlás!")
					else
						exports.see_accounts:showInfo(source, "e", "Nem fér el nálad a tárgy!")
					end
				else
					exports.see_accounts:showInfo(source, "e", "Nincs nálad elég pénz!")
				end
			end
		end
	end)

addEvent("addToPedStock", true)
addEventHandler("addToPedStock", getRootElement(),
	function (pedId, itemId, amount, basePrice)
		if isElement(source) then
			local itemList = pedList[pedId]

			if itemList then
				local currentBalance = itemList.balance
				local amountPrice = amount * basePrice

				currentBalance = currentBalance - amountPrice

				if currentBalance >= 0 then
					local currentAmount = itemList.stocks[itemId] or 0
					currentAmount = currentAmount + amount

					itemList.stocks[itemId] = currentAmount
					itemList.balance = currentBalance

					dbExec(connection, "UPDATE peds SET balance = ? WHERE pedId = ?", currentBalance, pedId)
					triggerClientEvent(source, "refreshPedItemStock", source, itemId, currentAmount, currentBalance)

					exports.see_accounts:showInfo(source, "s", "Sikeresen megrendeltél a kiválasztott tételből " .. amount .. " darabot " .. amountPrice .. " $ értékben.")
				else
					exports.see_accounts:showInfo(source, "e", "Nincs elegendő pénz a kasszában! (" .. amountPrice .. " $)")
				end
			end
		end
	end)

addEvent("setItemPrice", true)
addEventHandler("setItemPrice", getRootElement(),
	function (pedId, itemId, newPrice)
		if isElement(source) then
			local itemList = pedList[pedId]

			if itemList then
				itemList.prices[itemId] = newPrice
				triggerClientEvent(source, "refreshPedItemPrice", source, itemId, newPrice)
			end
		end
	end)

addEvent("putInMoney", true)
addEventHandler("putInMoney", getRootElement(),
	function (pedId, amount)
		if isElement(source) then
			local itemList = pedList[pedId]

			if itemList then
				local currentMoney = getElementData(source, "char.Money") or 0

				if currentMoney - amount >= 0 then
					local currentBalance = itemList.balance

					exports.see_core:takeMoney(source, amount, "putInMoney[PED]")

					currentBalance = currentBalance + amount
					itemList.balance = currentBalance

					dbExec(connection, "UPDATE peds SET balance = ? WHERE pedId = ?", currentBalance, pedId)
					triggerClientEvent(source, "setPedBalance", source, currentBalance)

					exports.see_accounts:showInfo(source, "s", "Sikeresen befizettél " .. amount .. " $-t.")
				else
					exports.see_accounts:showInfo(source, "e", "Nincs nálad ennyi pénz!")
				end
			end
		end
	end)

addEvent("getOutMoney", true)
addEventHandler("getOutMoney", getRootElement(),
	function (pedId, amount)
		if isElement(source) then
			local itemList = pedList[pedId]

			if itemList then
				local currentBalance = itemList.balance

				if currentBalance - amount >= 0 then
					exports.see_core:giveMoney(source, amount, "getOutMoney[PED]")

					currentBalance = currentBalance - amount
					itemList.balance = currentBalance

					dbExec(connection, "UPDATE peds SET balance = ? WHERE pedId = ?", currentBalance, pedId)
					triggerClientEvent(source, "setPedBalance", source, currentBalance)

					exports.see_accounts:showInfo(source, "s", "Sikeresen kifizettél " .. amount .. " $-t.")
				else
					exports.see_accounts:showInfo(source, "e", "Nincs a kasszában ennyi pénz!")
				end
			end
		end
	end)

function sortFunction(a, b)
	return a[1] < b[1]
end

addCommandHandler("createped",
	function (sourcePlayer, commandName, mainType, skinId, ownerId, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			mainType = tonumber(mainType)
			skinId = tonumber(skinId)
			ownerId = tonumber(ownerId)

			if not (mainType and skinId and (ownerId and ownerId >= -1) and (...)) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Típus] [Skin ID] [Interior ID (-1 = nincs)] [Név]", sourcePlayer, 0, 0, 0, true)
				outputChatBox("#3d7abc[Típusok]: #ffffffA típusok megtekintéséhez nyisd meg a konzolt. (F8)", sourcePlayer, 0, 0, 0, true)

				local temp = {}

				for k, v in pairs(mainTypes) do
					table.insert(temp, {k, v})
				end

				table.sort(temp, sortFunction)

				for k, v in ipairs(temp) do
					local types = {}

					for i = 1, #v[2] do
						table.insert(types, categories[v[2][i]])
					end

					outputConsole("    * (" .. v[1] .. "): " .. table.concat(types, ", "), sourcePlayer)
				end
			else
				if not mainTypes[mainType] then
					outputChatBox("#d75959[StrongMTA]: #ffffffÉrvénytelen ped típus.", sourcePlayer, 0, 0, 0, true)
					return
				end

				local allSkins = getValidPedModels()
				local result = false

				for i = 1, #allSkins do
					if allSkins[i] == skinId then
						result = true
						break
					end
				end

				if not result then
					outputChatBox("#d75959[StrongMTA]: #ffffffÉrvénytelen skin id.", sourcePlayer, 0, 0, 0, true)
					return
				end

				local name = table.concat({...}, " "):gsub(" ", "_")
				local x, y, z = getElementPosition(sourcePlayer)
				local rx, ry, rz = getElementRotation(sourcePlayer)
				local int = getElementInterior(sourcePlayer)
				local dim = getElementDimension(sourcePlayer)

				dbExec(connection, "INSERT INTO peds (ownerId, posX, posY, posZ, rotZ, interior, dimension, mainType, skinId, name) VALUES (?,?,?,?,?,?,?,?,?,?)", ownerId, x, y, z, rz, int, dim, mainType, skinId, name)
				dbQuery(
					function (qh)
						local result = dbPoll(qh, 0)[1]

						if result then
							loadPed(result.pedId, result)

							if isElement(sourcePlayer) then
								outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen létrehoztál egy pedet. #32b3ef(ID: " .. result.pedId .. " | Tulajdonos: " .. result.ownerId .. ")", sourcePlayer, 0, 0, 0, true)
							end
						end
					end, connection, "SELECT * FROM peds WHERE pedId = LAST_INSERT_ID()"
				)
			end
		end
	end)

addCommandHandler("deleteped",
	function (sourcePlayer, commandName, pedId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			pedId = tonumber(pedId)

			if not pedId then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Ped ID]", sourcePlayer, 0, 0, 0, true)
			else
				if pedList[pedId] then
					if isElement(pedList[pedId].element) then
						destroyElement(pedList[pedId].element)
					end

					if isElement(pedList[pedId].colshape) then
						destroyElement(pedList[pedId].colshape)
					end

					pedList[pedId] = nil

					outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen kitörölted a pedet. #32b3ef(" .. pedId .. ")", sourcePlayer, 0, 0, 0, true)

					dbExec(connection, "DELETE FROM peds WHERE pedId = ?", pedId)
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott ped nem létezik.", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end)

addCommandHandler("setpedtype",
	function (sourcePlayer, commandName, pedId, newType)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			pedId = tonumber(pedId)
			newType = tonumber(newType)

			if not (pedId and newType) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Ped ID] [Típus]", sourcePlayer, 0, 0, 0, true)
				outputChatBox("#3d7abc[Típusok]: #ffffffA típusok megtekintéséhez nyisd meg a konzolt. (F8)", sourcePlayer, 0, 0, 0, true)

				local temp = {}

				for k, v in pairs(mainTypes) do
					table.insert(temp, {k, v})
				end

				table.sort(temp, sortFunction)

				for k, v in ipairs(temp) do
					local types = {}

					for i = 1, #v[2] do
						table.insert(types, categories[v[2][i]])
					end

					outputConsole("    * (" .. v[1] .. "): " .. table.concat(types, ", "), sourcePlayer)
				end
			else
				local itemList = pedList[pedId]

				if itemList then
					if mainTypes[newType] then
						itemList.categories = {unpack(mainTypes[newType])}

						collectPedItems(pedId)

						outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen átállítottad a kiválasztott ped típusát.", sourcePlayer, 0, 0, 0, true)

						dbExec(connection, "UPDATE peds SET mainType = ?, itemList = ? WHERE pedId = ?", newType, toString(pedId), pedId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffÉrvénytelen ped típus.", sourcePlayer, 0, 0, 0, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott ped nem létezik.", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end)

addCommandHandler("setpedskin",
	function (sourcePlayer, commandName, pedId, skinId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			pedId = tonumber(pedId)
			skinId = tonumber(skinId)

			if not (pedId and skinId) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Ped ID] [Skin ID]", sourcePlayer, 0, 0, 0, true)
			else
				if pedList[pedId] then
					local allSkins = getValidPedModels()
					local result = false

					for i = 1, #allSkins do
						if allSkins[i] == skinId then
							result = true
							break
						end
					end

					if result then
						setElementModel(pedList[pedId].element, skinId)

						outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen átállítottad a kiválasztott ped skinjét.", sourcePlayer, 0, 0, 0, true)

						dbExec(connection, "UPDATE peds SET skinId = ? WHERE pedId = ?", skinId, pedId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffÉrvénytelen skin id.", sourcePlayer, 0, 0, 0, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott ped nem létezik.", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end)

addCommandHandler("setpedname",
	function (sourcePlayer, commandName, pedId, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			pedId = tonumber(pedId)

			if not (pedId and (...)) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Ped ID] [Új név]", sourcePlayer, 0, 0, 0, true)
			else
				if pedList[pedId] then
					local name = table.concat({...}, " "):gsub(" ", "_")

					if utfLen(name) > 0 then
						setElementData(pedList[pedId].element, "visibleName", name)

						outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen átállítottad a kiválasztott ped nevét.", sourcePlayer, 0, 0, 0, true)

						dbExec(connection, "UPDATE peds SET name = ? WHERE pedId = ?", name, pedId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffNem adtad meg a ped új nevét.", sourcePlayer, 0, 0, 0, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott ped nem létezik.", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end)
