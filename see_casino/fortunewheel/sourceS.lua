local connection = false

local fortuneTables = {}

local degPerNum = 360 / #nums

local chipModels = {
	[1] = 1853,
	[5] = 1854,
	[25] = 1855,
	[50] = 1856,
	[100] = 1857,
	[500] = 1858
}

local fieldPositions = {
	["0,0"] = {-0.64, 0.25, 0}, -- 20
	["1,0"] = {-0.18, 0.25, 0}, -- 5
	["2,0"] = {0.24, 0.25, 0}, -- 1
	["0,1"] = {-0.64, -0.12, 0}, -- 10
	["1,1"] = {-0.18, -0.12, 0}, -- 2
	["2,1"] = {0.24, -0.12, 0} -- 40
}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		dbQuery(
			function (qh)
				local result = dbPoll(qh, 0)

				if result then
					for k, v in pairs(result) do
						loadFortuneWheel(v.id, v)
					end
				end
			end,
		connection, "SELECT * FROM fortunewheels")
	end)

addEvent("placeFortuneWheel", true)
addEventHandler("placeFortuneWheel", getRootElement(),
	function (dat)
		if isElement(source) and client and client == source then
			if getElementData(source, "acc.adminLevel") >= 6 then 
				if dat then
					dbExec(connection, "INSERT INTO fortunewheels (x, y, z, rz, interior, dimension) VALUES (?,?,?,?,?,?)", unpack(dat))
					dbQuery(
						function (qh, sourcePlayer)
							local result = dbPoll(qh, 0)[1]

							if result then
								loadFortuneWheel(result.id, result, true)
								exports.see_accounts:showInfo(sourcePlayer, "s", "Szerencsekerék sikeresen létrehozva! ID: " .. result.id)
							end
						end,
					{source}, connection, "SELECT * FROM fortunewheels WHERE id = LAST_INSERT_ID()")
				end
			end
		end
	end)

addCommandHandler("deletefortune",
	function (sourcePlayer, commandName, tableId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			tableId = tonumber(tableId)

			if not tableId then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [ID]", sourcePlayer, 255, 255, 255, true)
			else
				if fortuneTables[tableId] then
					if isElement(fortuneTables[tableId].element) then
						destroyElement(fortuneTables[tableId].element)
					end

					fortuneTables[tableId] = nil

					dbExec(connection, "DELETE FROM fortunewheels WHERE id = ?", tableId)
				else
					outputChatBox("#d75959[StrongMTA - Szerencsekerék]: #ffffffA kiválasztott asztal nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

function chooseRandomNumber()
    local totalWeight = 0

    for number, weight in pairs(nums_weights) do
        totalWeight = totalWeight + weight
    end

    local randomWeight = math.random(1, totalWeight)
    local currentWeight = 0

    for number, weight in pairs(nums_weights) do
        currentWeight = currentWeight + weight

        if randomWeight <= currentWeight then
            return number
        end
    end

    return false
end	

function loadFortuneWheel(id, data)
	local obj = createObject(1896, data.x, data.y, data.z, 0, 0, data.rz)

	setElementInterior(obj, data.interior)
	setElementDimension(obj, data.dimension)
	setElementData(obj, "fortuneTable", id)

	fortuneTables[id] = {}
	fortuneTables[id].element = obj
	fortuneTables[id].currentPlayer = false
	fortuneTables[id].betsOnField = {}
	fortuneTables[id].creditAll = 0
	fortuneTables[id].theNum = 1
	fortuneTables[id].gameStage = 0
	fortuneTables[id].chipObjects = {}

	local x, y = rotateAround(data.rz, 0, 0.5, data.x, data.y)
	local obj = createObject(1897, x, y, data.z + 1.125, 0, 0, data.rz)

	setElementInterior(obj, data.interior)
	setElementDimension(obj, data.dimension)
	setElementDoubleSided(obj, true)
	fortuneTables[id].supportElement = obj

	local x, y = rotateAround(data.rz, 0, 0.5, data.x, data.y)
	local obj = createObject(1895, x, y, data.z + 1.125, 0, 0, data.rz)

	setElementInterior(obj, data.interior)
	setElementDimension(obj, data.dimension)
	setElementDoubleSided(obj, true)
	setElementData(obj, "fortunePos", {data.x, data.y, data.z, data.rz})
	fortuneTables[id].wheelElement = obj
end

addEventHandler("onPlayerClick", getRootElement(),
	function (button, state, clickedElement)
		if button == "right" and state == "up" then
			if clickedElement then
				local tableId = getElementData(clickedElement, "fortuneTable") or 0

				if tableId > 0 then
					local fortuneTable = fortuneTables[tableId]

					if not getElementData(source, "playerUsingFortune") then
						local playerX, playerY, playerZ = getElementPosition(source)
						local targetX, targetY, targetZ = getElementPosition(clickedElement)

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) < 2 then
							if math.abs(playerZ - targetZ) - 0.5 >= 0 then
								return
							end

							local playerRot = select(3, getElementRotation(source))
							local facingAngle = math.deg(math.atan2(targetY - playerY, targetX - playerX)) + 180 - playerRot

							if facingAngle < 0 then
								facingAngle = facingAngle + 360
							end

							if facingAngle < 180 then
								return
							end

							if fortuneTable.gameStage == 1 then
								exports.see_hud:showInfobox(source, "e", "Várd meg a pörgetés végét!")
								return
							end

							if isElement(fortuneTable.currentPlayer) then
								exports.see_hud:showInfobox(source, "e", "Már valaki más használja ezt az asztalt!")
								return
							end

							fortuneTable.currentPlayer = source
							fortuneTable.betsOnField = {}
							fortuneTable.creditAll = 0

							setPedAnimation(source, "CASINO", "Roulette_loop", -1, true, false, false, false)
							setElementData(source, "playerUsingFortune", tableId)

							triggerClientEvent(source, "openFortuneWheel", source, tableId, clickedElement)
						end
					end
				end
			end
		end
	end)

addEvent("closeFortuneWheel", true)
addEventHandler("closeFortuneWheel", getRootElement(),
	function (tableId, spin)
		if isElement(source) and client and client == source then
			setPedAnimation(source, "CASINO", "Roulette_out", -1, false, false, false, false)
			setElementData(source, "playerUsingFortune", false)

			local fortuneTable = fortuneTables[tableId]

			if fortuneTable then
				if not spin then
					fortuneTable.currentPlayer = false
					fortuneTable.betsOnField = {}
					fortuneTable.creditAll = 0
					fortuneTable.gameStage = 0
				else
					local num = chooseRandomNumber()

					fortuneTable.gameStage = 1
					fortuneTable.theNum = num

					local x, y, z = getElementPosition(fortuneTable.wheelElement)
					local ry = select(2, getElementRotation(fortuneTable.wheelElement))

					moveObject(fortuneTable.wheelElement, 10000, x, y, z, 0, -(ry + (num - 1) * degPerNum) - 360, 0, "InOutQuad")
					setTimer(payoutTheWinner, 10000, 1, tableId)
				end
			end
		end
	end)

function payoutTheWinner(tableId)
	local fortuneTable = fortuneTables[tableId]

	if fortuneTable then
		stopObject(fortuneTable.wheelElement)

		if isElement(fortuneTable.currentPlayer) then
			local winnerNumber = nums[fortuneTable.theNum]
			local win, lost = 0, 0

			for field, data in pairs(fortuneTable.betsOnField) do
				if data[2] == winnerNumber then
					win = win + data[1]
				else
					lost = lost + data[1]
				end
			end

			local profit = win * winnerNumber
			local currentBalance = getElementData(fortuneTable.currentPlayer, "char.slotCoins") or 0

			setElementData(fortuneTable.currentPlayer, "char.slotCoins", currentBalance + profit)

			outputChatBox("#3d7abc[StrongMTA - Szerencsekerék]: #ffffffKapott szám: #3d7abc" .. winnerNumber .. "x", fortuneTable.currentPlayer, 0, 0, 0, true)

			if profit > lost then
				outputChatBox("#3d7abc[StrongMTA - Szerencsekerék]: #ffffffNyertél #3d7abc" .. profit .. " Coin#ffffff-t.", fortuneTable.currentPlayer, 0, 0, 0, true)
				setElementData(fortuneTable.currentPlayer, "playerIcons", {"plus", profit})
			else
				outputChatBox("#d75959[StrongMTA - Szerencsekerék]: #ffffffNem nyertél semmit.", fortuneTable.currentPlayer, 0, 0, 0, true)
				setElementData(fortuneTable.currentPlayer, "playerIcons", {"minus", lost})
			end
		end

		for field, data in pairs(fortuneTable.chipObjects) do
			for i = 1, #data do
				if isElement(data[i]) then
					destroyElement(data[i])
				end
			end

			fortuneTable.chipObjects[field] = nil
		end

		fortuneTable.currentPlayer = false
		fortuneTable.betsOnField = {}
		fortuneTable.creditAll = 0
		fortuneTable.gameStage = 0
		fortuneTable.chipObjects = {}
	end
end

addEvent("onPlaceFortuneCoin", true)
addEventHandler("onPlaceFortuneCoin", getRootElement(),
	function (amount, tableId, x, y, players, value)
		if isElement(source) and client and client == source then
			local fortuneTable = fortuneTables[tableId]

			if fortuneTable then
				local playerX, playerY, playerZ = getElementPosition(source)
				local field = x .. "," .. y

				if not fortuneTable.betsOnField[field] then
					fortuneTable.betsOnField[field] = {0, value}
				end

				fortuneTable.betsOnField[field][1] = fortuneTable.betsOnField[field][1] + amount
				fortuneTable.creditAll = (fortuneTable.creditAll or 0) + amount

				local currentBalance = getElementData(source, "char.slotCoins") or 0

				if currentBalance - amount >= 0 then
					setElementData(source, "char.slotCoins", currentBalance - amount)
				else
					setElementData(source, "char.slotCoins", 0)
				end

				triggerClientEvent(source, "onFortuneBetPlaced", source, x, y, amount)
				triggerClientEvent(players, "chipSound", source, playerX, playerY, playerZ, math.random(3))

				setPedAnimation(source, "CASINO", "Roulette_bet", -1, false, false, false, false)
				setTimer(setPedAnimation, 1275, 1, source, "CASINO", "Roulette_loop", -1, true, false, false, false)

				createChipFortune(tableId, amount, field)
			end
		end
	end)

addEvent("onRemoveFortuneBet", true)
addEventHandler("onRemoveFortuneBet", getRootElement(),
	function (tableId, x, y, amount)
		if isElement(source) and client and client == source then
			local fortuneTable = fortuneTables[tableId]

			if fortuneTable then
				local field = x .. "," .. y

				fortuneTable.creditAll = fortuneTable.creditAll - fortuneTable.betsOnField[field][1]
				fortuneTable.betsOnField[field] = nil

				if fortuneTable.chipObjects[field] then
					for i = 1, #fortuneTable.chipObjects[field] do
						local obj = fortuneTable.chipObjects[field][i]

						if isElement(obj) then
							destroyElement(obj)
						end
					end
					local currentBalance = getElementData(source, "char.slotCoins") or 0
					setElementData(source, "char.slotCoins", currentBalance + amount)
					fortuneTable.chipObjects[field] = nil
				end
			end
		end
	end)

function createChipFortune(tableId, coin, field)
	local fortuneTable = fortuneTables[tableId]

	if fortuneTable then
		if not fortuneTable.chipObjects[field] then
			fortuneTable.chipObjects[field] = {}
		end

		local id = #fortuneTable.chipObjects[field]

		local x, y, z = getElementPosition(fortuneTable.element)
		local rz = select(3, getElementRotation(fortuneTable.element))

		local x2, y2 = rotateAround(rz, fieldPositions[field][1], fieldPositions[field][2])
		local obj = createObject(chipModels[coin], x + x2, y + y2, z + 0.035 + id * 0.0105, 0, 0, math.random(360))

		setObjectScale(obj, 0.375)
		setElementInterior(obj, getElementInterior(fortuneTable.element))
		setElementDimension(obj, getElementDimension(fortuneTable.element))

		table.insert(fortuneTable.chipObjects[field], obj)
	end
end

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		if getElementModel(source) == 1896 then
			local tableId = getElementData(source, "fortuneTable")

			if tableId then
				local fortuneTable = fortuneTables[tableId]

				if fortuneTable then
					if isElement(fortuneTable.supportElement) then
						destroyElement(fortuneTable.supportElement)
					end

					if isElement(fortuneTable.wheelElement) then
						destroyElement(fortuneTable.wheelElement)
					end

					for field, data in pairs(fortuneTable.chipObjects) do
						for i = 1, #data do
							if isElement(data[i]) then
								destroyElement(data[i])
							end
						end

						fortuneTable.chipObjects[field] = nil
					end

					fortuneTable = nil
				end
			end			
		end
	end)