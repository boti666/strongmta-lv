local connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end)

addEvent("updatePlayerDescription", true)
addEventHandler("updatePlayerDescription", getRootElement(),
	function (fakeInputValue)
		if isElement(source) and client and client == source then
			local characterId = getElementData(source, "char.ID") or 0
			dbExec(connection, "UPDATE characters SET description = ? WHERE characterId = ?", fakeInputValue, characterId)
			setElementData(source, "char.description", fakeInputValue)
			iprint(fakeInputValue)
		end
	end
)

addEvent("buyVehSlot", true)
addEventHandler("buyVehSlot", getRootElement(),
	function (slot)
		slot = tonumber(slot) or 0

		if slot > 0 then
			dbQuery(
				function (qh, thePlayer, price)
					if isElement(thePlayer) then
						local result = dbPoll(qh, 0)

						if result then
							local row = result[1]
							local newPP = row.premiumPoints - price

							if newPP < 0 then
								exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég prémium pontod a +slot megvásárlásához!")
							else
								setElementData(thePlayer, "acc.premiumPoints", newPP)

								local currentLimit = getElementData(thePlayer, "char.maxVehicles") or 0
								local newLimit = currentLimit + slot

								setElementData(thePlayer, "char.maxVehicles", newLimit)
								exports.see_accounts:showInfo(thePlayer, "s", "Sikeres vásárlás!")
								triggerClientEvent(thePlayer, "buySlotOK", thePlayer)

								dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", newPP, getElementData(thePlayer, "char.accID"))
								dbExec(connection, "UPDATE characters SET maxVehicles = ? WHERE characterId = ?", newLimit, getElementData(thePlayer, "char.ID"))

								exports.see_logs:addLogEntry("premiumshop", {
									accountId = getElementData(thePlayer, "char.accID"),
									characterId = getElementData(thePlayer, "char.ID"),
									itemId = "vehicleslot",
									amount = slot,
									oldPP = row.premiumPoints,
									newPP = newPP
								})
							end
						end
					end
				end,
			{source, slot * 500}, connection, "SELECT premiumPoints FROM accounts WHERE accountId = ? LIMIT 1", getElementData(source, "char.accID"))
		else
			exports.see_accounts:showInfo(source, "e", "Minimum 1 slotot vásárolhatsz!")
		end
	end)

addEvent("buyIntSlot", true)
addEventHandler("buyIntSlot", getRootElement(),
	function (slot)
		slot = tonumber(slot) or 0

		if slot > 0 then
			dbQuery(
				function (qh, thePlayer, price)
					if isElement(thePlayer) then
						local result = dbPoll(qh, 0)

						if result then
							local row = result[1]
							local newPP = row.premiumPoints - price

							if newPP < 0 then
								exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég prémium pontod a +slot megvásárlásához!")
							else
								setElementData(thePlayer, "acc.premiumPoints", newPP)

								local currentLimit = getElementData(thePlayer, "char.interiorLimit") or 0
								local newLimit = currentLimit + slot

								setElementData(thePlayer, "char.interiorLimit", newLimit)
								exports.see_accounts:showInfo(thePlayer, "s", "Sikeres vásárlás!")
								triggerClientEvent(thePlayer, "buySlotOK", thePlayer)

								dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", newPP, getElementData(thePlayer, "char.accID"))
								dbExec(connection, "UPDATE characters SET interiorLimit = ? WHERE characterId = ?", newLimit, getElementData(thePlayer, "char.ID"))

								exports.see_logs:addLogEntry("premiumshop", {
									accountId = getElementData(thePlayer, "char.accID"),
									characterId = getElementData(thePlayer, "char.ID"),
									itemId = "interiorslot",
									amount = slot,
									oldPP = row.premiumPoints,
									newPP = newPP
								})
							end
						end
					end
				end,
			{source, slot * 100}, connection, "SELECT premiumPoints FROM accounts WHERE accountId = ? LIMIT 1", getElementData(source, "char.accID"))
		else
			exports.see_accounts:showInfo(source, "e", "Minimum 1 slotot vásárolhatsz!")
		end
	end
)

function sendNudes(thePlayer, theVehicle, targetPlayer, vehiclePrice)
	if theVehicle then
		if isElement(targetPlayer) and tonumber(vehiclePrice) then
			if getElementData(thePlayer, "strong.Selling") then 
				return exports.see_accounts:showInfo(thePlayer, "e", "Már folyamatban van egy sell szerződés.") 
			end

			if getElementData(targetPlayer, "strong.Veh") then
				return exports.see_accounts:showInfo(thePlayer, "e", "A játékosnál már van nyitva szerződés!") 
			end

			sendOfferToPlayer(thePlayer, targetPlayer, vehiclePrice, theVehicle)
		end
	end
end
addEvent("sendNudes", true)
addEventHandler("sendNudes", getRootElement(), sendNudes)

function sendOfferToPlayer(thePlayer, targetPlayer, vehiclePrice, theVehicle)
	local vehicleName = exports.see_vehiclenames:getCustomVehicleName(getElementModel(theVehicle)) or "Ismeretlen"

	outputChatBox("#FF9600[StrongMTA]:#ffffff " .. getElementData(thePlayer, "visibleName"):gsub("_"," ") .. " eladásra kínálta neked #7cc576" .. vehicleName .. "#ffffff típusú személygépjárművét.", targetPlayer, 255, 255, 255, true)
	outputChatBox("#FF9600[StrongMTA]:#ffffff Ár: #0094ff" .. vehiclePrice .. "$", targetPlayer, 255, 255, 255, true)

	outputChatBox("#FF9600[StrongMTA]:#ffffff Eladásra kínáltad a(z) #7cc576" .. vehicleName .. "#ffffff járművedet.", thePlayer, 255, 255, 255, true)
	outputChatBox("#FF9600[StrongMTA]:#ffffff Ár: #0094ff" .. vehiclePrice .. "$", thePlayer, 255, 255, 255, true)

	outputChatBox("#1E8BC3[StrongMTA]:#ffffff Elfogadáshoz használd a #7cc576/elfogad#ffffff parancsot.", targetPlayer, 255, 255, 255, true)
	outputChatBox("#1E8BC3[StrongMTA]:#ffffff Elutasításhoz használd a #dc143c/elutasít#ffffff parancsot.", targetPlayer, 255, 255, 255, true)

	setElementData(targetPlayer, "strong.Accept", 1)
	setElementData(thePlayer, "strong.Selling", 1)
	setElementData(targetPlayer, "strong.Veh", theVehicle)
	setElementData(targetPlayer, "strong.Price", vehiclePrice)
	setElementData(targetPlayer, "strong.Tplayer", thePlayer)

	--renderData.tradeContract = true
	--renderData.dummyTradeContract = true --renderData.tradeContractDatas
	local plateText = split(getVehiclePlateText(theVehicle), "-")
	local plateSections = {}

	for i = 1, #plateText do
		if utf8.len(plateText[i]) > 0 then
			table.insert(plateSections, plateText[i])
		end
	end

	local totalDistance = getElementData(theVehicle, "vehicle.distance") or 0

	local datas = getAllElementData(theVehicle)

	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second

    local monthday = time.monthday
	local month = time.month
	local year = time.year

    local formattedTime = string.format("%04d-%02d-%02d", year + 1900, month + 1, monthday)

	vehData = {
		buyer = getElementData(targetPlayer, "visibleName"),
		seller = getElementData(thePlayer, "visibleName"),
		plate = table.concat(plateSections, "-"),
		cartype = exports.see_vehiclenames:getCustomVehicleName(getElementModel(theVehicle)) or "Ismeretlen",
		currentDistance = math.floor(totalDistance * 10) / 10,
		engine = tuningName[datas["vehicle.tuning.Engine"] or 0],
		gears = tuningName[datas["vehicle.tuning.Transmission"] or 0],
		brake = tuningName[datas["vehicle.tuning.Brakes"] or 0],
		wheels = tuningName[datas["vehicle.tuning.Tires"] or 0],
		turbo = tuningName[datas["vehicle.tuning.Turbo"] or 0],
		WeightReduction = tuningName[datas["vehicle.tuning.WeightReduction"] or 0],
		ecu = tuningName[datas["vehicle.tuning.ECU"] or 0],

		suspension = tuningName[datas["vehicle.tuning.Suspension"] or 0],
		extras = "",
		nitro = getElementData(theVehicle, "vehicle.nitroLevel") or 0,
		price = vehiclePrice,
		dateOf = formattedTime,

		sellerPed = thePlayer,
		selledVeh = theVehicle
	}

	triggerClientEvent(targetPlayer, "showTradeContatact", targetPlayer, vehData)
end

function acceptOffer(sourcePlayer, theCommand)
	if getElementData(sourcePlayer, "strong.Accept") == 1 then
		local characterId = getElementData(sourcePlayer, "char.ID") or 0
		local theVeh = getElementData(sourcePlayer, "strong.Veh")
		local vehicleId = getElementData(theVeh, "vehicle.dbID") or 0
		local sellerPlayer = getElementData(sourcePlayer, "strong.Tplayer")
		local vehprice = getElementData(sourcePlayer, "strong.Price") or 0

		iprint(vehicleId)
		iprint(characterId)
		iprint(theVeh)

		setElementData(theVeh, "vehicle.group", 0)
		setElementData(theVeh, "vehicle.owner", characterId)

		dbExec(connection, "UPDATE vehicles SET ownerId = ?, groupId = ? WHERE vehicleId = ?", characterId, 0, vehicleId)

		exports.see_core:takeMoney(sourcePlayer, vehprice, "buyVehFromPlayer")
		exports.see_core:giveMoney(sellerPlayer, vehprice, "sellVehForPlayer")

		setElementData(sourcePlayer, "strong.Tplayer", false)
		setElementData(sourcePlayer, "strong.Accept", false)
		setElementData(sourcePlayer, "strong.Veh", false)
		setElementData(sourcePlayer, "strong.Price", false)
		setElementData(getElementData(sourcePlayer, "strong.Tplayer"), "strong.Selling", false)
		dbExec(connection, "UPDATE characters SET money WHERE characterId = ?", getElementData(sourcePlayer, "char.Money"), characterId)
		dbExec(connection, "UPDATE characters SET money WHERE characterId = ?", getElementData(sellerPlayer, "char.Money"), getElementData(sellerPlayer, "char.ID"))
	end
end
addCommandHandler("elfogad", acceptOffer)
addEvent("acceptOffer", true)
addEventHandler("acceptOffer", getRootElement(), acceptOffer)


function cancelOffer(sourcePlayer, theCommand)
	setElementData(sourcePlayer, "strong.Accept", false)
	setElementData(sourcePlayer, "strong.Veh", false)
	setElementData(sourcePlayer, "strong.Price", false)
	setElementData(getElementData(sourcePlayer, "strong.Tplayer"), "strong.Selling", false)
	outputChatBox("#1e8bc3[StrongMTA]:#ffffff Elutasítottad az Sell szerződést.", sourcePlayer, 255, 255, 255, true)
	outputChatBox("#1e8bc3[StrongMTA]:#ffffff Elutasították az Sell szerződésed.", getElementData(sourcePlayer, "strong.Tplayer"), 255, 255, 255, true)
	setElementData(sourcePlayer, "strong.Tplayer", false)
end
addCommandHandler("elutasít", cancelOffer)
addEvent("cancelOffer", true)
addEventHandler("cancelOffer", getRootElement(), cancelOffer)
