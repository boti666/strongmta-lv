local connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end)

addEvent("buyTheCurrentBoat", true)
addEventHandler("buyTheCurrentBoat", getRootElement(),
	function (veh, typ, r, g, b)
		if isElement(source) and client and client == source then 
			if veh and typ then
				dbQuery(tryToBuyBoat, {source, {veh, typ, r, g, b}}, connection, "SELECT characters.maxVehicles, COUNT(vehicles.vehicleId) AS ownedVehicles FROM characters JOIN vehicles ON vehicles.ownerId = ? WHERE characters.characterId = ? AND vehicles.groupId = 0", getElementData(source, "char.ID"), getElementData(source, "char.ID"))
			end
		end
	end)

function tryToBuyBoat(qh, thePlayer, datas)
	local result = dbPoll(qh, 0)
	local row = result[1]

	if isElement(thePlayer) then
		if row.maxVehicles <= row.ownedVehicles then
			setElementData(thePlayer, "char.maxVehicles", row.maxVehicles)
			exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég járműslotod!")
		else
			local currentPP = false

			if datas[2] == "money" then
				if datas[1].limit ~= -1 then
					local qh = dbQuery(connection, "SELECT COUNT(vehicleId) AS vehicleCount FROM vehicles WHERE modelId = ? AND groupId = 0 AND ownerId > 0", datas[1].model)
					local result = dbPoll(qh, 1000)

					if result and result[1].vehicleCount >= datas[1].limit then
						exports.see_accounts:showInfo(thePlayer, "e", "Sajnálom, ez egy limitált szériás model, jelenleg nincs raktáron!")
						return
					end

					if not result then
						return
					end
				end

				if exports.see_core:getMoney(thePlayer) - datas[1].price < 0 then
					exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég pénzed a jármű megvásárlásához.")
					return
				end
			else
				local qh = dbQuery(connection, "SELECT premiumPoints FROM accounts WHERE accountId = ?", getElementData(thePlayer, "char.accID"))
				local result = dbPoll(qh, 1000)

				if result then
					if result[1].premiumPoints - datas[1].premium < 0 then
						exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég prémium pontod a jármű megvásárlásához.")
						return
					end

					currentPP = result[1].premiumPoints
				end

				if not result then
					return
				end
			end

			if not exports.see_items:hasSpaceForItem(thePlayer, 1, 1) then
				exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég hely az inventorydban a kulcshoz.")
				return
			end

			if datas[2] == "money" then
				exports.see_core:takeMoney(thePlayer, datas[1].price, "buyNewBoat")
			elseif currentPP then
				setElementData(thePlayer, "acc.premiumPoints", currentPP - datas[1].premium)

				dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", currentPP - datas[1].premium, getElementData(thePlayer, "char.accID"))
				
				exports.see_logs:addLogEntry("premiumshop", {
					accountId = getElementData(thePlayer, "char.accID"),
					characterId = getElementData(thePlayer, "char.ID"),
					itemId = "buynewboat",
					amount = 1,
					oldPP = currentPP,
					newPP = currentPP - datas[1].premium
				})
			else
				return
			end

			triggerClientEvent(thePlayer, "exitBoatShop", thePlayer)

			setTimer(
				function()
					exports.see_vehicles:createPermVehicle({
						modelId = datas[1].model,
						color1 = string.format("#%.2X%.2X%.2X", datas[3] or 255, datas[4] or 255, datas[5] or 255),
						color2 = string.format("#%.2X%.2X%.2X", datas[3] or 255, datas[4] or 255, datas[5] or 255),
						targetPlayer = thePlayer,
						posX = -421.36987304688,
						posY = 1157.0170898438,
						posZ = 2.7831072807312,
						rotX = 0,
						rotY = 0,
						rotZ = 90,
						interior = 0,
						dimension = 0
					})
				end,
			2100, 1)

			exports.see_accounts:showInfo(thePlayer, "s", "Sikeres vásárlás!")
		end
	end
end