local storedCopiers = {}
local copierModel = 2186

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		dbQuery(loadAllCopier, connection, "SELECT * FROM copiers")
	end)

addEvent("requestCopiers", true)
addEventHandler("requestCopiers", getRootElement(),
	function ()
		if isElement(source) then
			triggerLatentClientEvent(source, "receiveCopiers", source, storedCopiers)
		end
	end)

addEvent("placeCopier", true)
addEventHandler("placeCopier", getRootElement(),
	function (x, y, z, rz, int, dim)
		if isElement(source) then
			dbExec(connection, "INSERT INTO copiers (posX, posY, posZ, rotZ, interior, dimension) VALUES (?,?,?,?,?,?)", x, y, z, rz, int, dim)
			dbQuery(
				function (qh, sourcePlayer)
					local result = dbPoll(qh, 0)[1]

					if result then
						loadCopier(result.copierId, result, true)
						outputChatBox("#DC143C[StrongMTA]: #ffffffA fénymásoló sikeresen létrehozva. #4aabd0(" .. result.copierId .. ")", sourcePlayer, 0, 0, 0, true)
					else
						outputChatBox("#DC143C[StrongMTA]: #ffffffA fénymásoló létrehozása meghiúsult.", sourcePlayer, 0, 0, 0, true)
					end
				end, {source},
			connection, "SELECT * FROM copiers WHERE copierId = LAST_INSERT_ID()")
		end
	end)

addCommandHandler("deletecopier",
	function (sourcePlayer, commandName, copierId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			copierId = tonumber(copierId)

			if not copierId then
				outputChatBox("[Használat]: #ffffff/" .. commandName .. " [Fénymásoló ID]", sourcePlayer, 255, 150, 0, true)
			elseif not storedCopiers[copierId] then
				outputChatBox("#DC143C[StrongMTA]: #ffffffA kiválasztott fénymásoló nem létezik.", sourcePlayer, 0, 0, 0, true)
			else
				dbExec(connection, "DELETE FROM copiers WHERE copierId = ?", copierId)

				if isElement(storedCopiers[copierId].objectElement) then
					destroyElement(storedCopiers[copierId].objectElement)
				end

				storedCopiers[copierId] = nil

				triggerLatentClientEvent(getElementsByType("player"), "destroyCopier", resourceRoot, copierId)

				outputChatBox("#3d7abc[StrongMTA]: #ffffffA fénymásoló sikeresen törölve.", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

function loadAllCopier(qh)
	local result = dbPoll(qh, 0)

	if result then
		for k, v in pairs(result) do
			loadCopier(v.copierId, v)
		end
	end
end

function loadCopier(copierId, data, sync)
	if tonumber(copierId) and type(data) == "table" then
		storedCopiers[copierId] = data
		storedCopiers[copierId].objectElement = createObject(copierModel, data.posX, data.posY, data.posZ, 0, 0, data.rotZ)

		if isElement(storedCopiers[copierId].objectElement) then
			setElementInterior(storedCopiers[copierId].objectElement, data.interior)
			setElementDimension(storedCopiers[copierId].objectElement, data.dimension)

			if sync then
				triggerLatentClientEvent(getElementsByType("player"), "createCopier", resourceRoot, copierId, data)
			end
		end
	end
end

addEvent("tryToCopyNote", true)
addEventHandler("tryToCopyNote", getRootElement(),
	function (item, copierElement)
		if isElement(source) then
			if item and type(item) == "table" then
				if exports.see_core:getMoney(source) - 10 >= 0 then
					if getCurrentWeight(source) + getItemWeight(item.itemId) <= getWeightLimit("player", source) then
						local state = false

						-- adásvételi & jegyzet
						if item.itemId == 309 or item.itemId == 367 then
							state = giveItem(source, item.itemId, 1, false, item.data1, item.data2, 1)
						-- útlevél
						elseif item.itemId == 264 then
							if not item.data3 then
								local x = math.random(50, 350) * 0.75
								local y = math.random(25, 198) * 0.75
								local rz = y * 0.035

								if math.random(100) >= 50 then
									rz = -rz
								end

								item.data3 = x .. ";" .. y .. ";" .. rz
							end

							state = giveItem(source, item.itemId, 1, false, item.data1, item.data2, item.data3)
						-- iratok
						elseif item.itemId == 207 or item.itemId == 208 or item.itemId == 308 or item.itemId == 310 then
							local datas = split(item.data1, ";")

							if not datas[3] or datas[3] ~= "iscopy" then
								local x = math.random(50, 350)
								local y = math.random(25, 198)

								if item.itemId == 310 then
									y = math.random(25, 140)
								end

								local rz = y * 0.035

								if math.random(100) >= 50 then
									rz = -rz
								end

								item.data1 = item.data1 .. ";iscopy;" .. x .. ";" .. y .. ";" .. rz
							end

							state = giveItem(source, item.itemId, 1, false, item.data1, item.data2, item.data3)
						end

						if state then
							exports.see_core:takeMoney(source, 10, "copyNote")
							triggerClientEvent(getElementsByType("player"), "copierEffect", copierElement)
						else
							exports.see_hud:showInfobox(source, "e", "Nincs szabad slot az inventorydban!")
						end
					else
						exports.see_hud:showInfobox(source, "e", "Az inventoryd nem bírja el a tárgyat!")
					end
				else
					exports.see_hud:showInfobox(source, "e", "Nincs elég pénzed a fénymásoló használatához. (10 $)")
				end
			end
		end
	end)
