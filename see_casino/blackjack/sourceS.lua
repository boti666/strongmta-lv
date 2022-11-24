local connection = false
local blackjackTables = {}


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
						loadBlackjack(v.id, v)
					end
				end
			end,
		connection, "SELECT * FROM blackjack")
	end)

addEvent("placeBlackjackTable", true)
addEventHandler("placeBlackjackTable", getRootElement(),
	function (dat)
		if isElement(source) and client and client == source then
			if getElementData(source, "acc.adminLevel") >= 6 then 
				if dat then
					dbExec(connection, "INSERT INTO blackjack (x, y, z, rz, interior, dimension, minEntry, maxEntry) VALUES (?,?,?,?,?,?,?,?)", unpack(dat))
					dbQuery(
						function (qh, sourcePlayer)
							local result = dbPoll(qh, 0)[1]

							if result then
								loadBlackjack(result.id, result, true)
								exports.see_accounts:showInfo(sourcePlayer, "s", "Blackjack sikeresen létrehozva! ID: " .. result.id)
							end
						end,
					{source}, connection, "SELECT * FROM blackjack WHERE id = LAST_INSERT_ID()")
				end
			end
		end
	end)

addCommandHandler("deleteblackjack",
	function (sourcePlayer, commandName, tableIdB)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			tableIdB = tonumber(tableIdB)

			if not tableIdB then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [ID]", sourcePlayer, 255, 255, 255, true)
			else
				if blackjackTables[tableIdB] then
					if isElement(blackjackTables[tableIdB].element) then
						destroyElement(blackjackTables[tableIdB].element)
					end

					if isElement(blackjackTables[tableIdB].dealer) then
						destroyElement(blackjackTables[tableIdB].dealer)
					end

					blackjackTables[tableIdB] = nil
					tablePositionsB[tableIdB] = nil

					triggerClientEvent("deleteBlackjackTable", resourceRoot, tableIdB)

					dbExec(connection, "DELETE FROM blackjack WHERE id = ?", tableIdB)
				else
					outputChatBox("#d75959[StrongMTA - Blackjack]: #ffffffA kiválasztott asztal nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end)

function loadBlackjack(id, data, sync)
	local obj = createObject(2188, data.x, data.y, data.z, 0, 0, data.rz)

	setElementInterior(obj, data.interior)
	setElementDimension(obj, data.dimension)
	setElementData(obj, "blackjackTable", id)

	local x, y = rotateAround(data.rz, 0, 0.35)
	local ped = createPed(171, data.x + x, data.y + y, data.z, data.rz + 180)

	setElementInterior(ped, data.interior)
	setElementDimension(ped, data.dimension)
	setElementFrozen(ped, true)
	setElementData(ped, "invulnerable", true)
	setElementData(ped, "visibleName", "Dealer")

	tablePositionsB[id] = {data.x, data.y, data.z, data.rz, data.interior, data.dimension, data.minEntry, data.maxEntry}

	blackjackTables[id] = data
	blackjackTables[id].element = obj
	blackjackTables[id].dealer = ped
	blackjackTables[id].credit = 0
	blackjackTables[id].deckCards = {}
	blackjackTables[id].data = {
		tableIdB = id,
		currentPlayer = false,
		gameStage = 0,
		playerCards = {},
		dealerCards = {}
	}

	setElementData(obj, "blackjackData", blackjackTables[id].data)

	if sync then
		triggerClientEvent("createBlackjackTable", resourceRoot, id, tablePositionsB[id])
	end
end

addEvent("requestBlackjackTables", true)
addEventHandler("requestBlackjackTables", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			triggerClientEvent(source, "requestBlackjackTables", source, tablePositionsB)
		end
	end)

addEventHandler("onPlayerClick", getRootElement(),
	function (button, state, clickedElement)
		if button == "right" and state == "up" then
			if clickedElement then
				local tableIdB = getElementData(clickedElement, "blackjackTable") or 0

				if tableIdB > 0 then
					local blackjackTable = blackjackTables[tableIdB]

					if not getElementData(source, "playerUsingBlackjack") then
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

							if isElement(blackjackTable.data.currentPlayer) then
								exports.see_hud:showInfobox(source, "e", "Már valaki más használja ezt az asztalt!")
								return
							end

							local currentBalance = getElementData(source, "char.slotCoins") or 0

							if currentBalance < blackjackTable.minEntry then
								exports.see_hud:showInfobox(source, "e", "Nincs elegendő Slot Coinod az asztalhoz való beálláshoz! Az asztal minimuma: " .. formatNumber(blackjackTable.minEntry) .. " Coin")
								return
							end

							blackjackTable.data.currentPlayer = source
							blackjackTable.data.gameStage = 0
							blackjackTable.data.playerCards = {}
							blackjackTable.data.dealerCards = {}
							blackjackTable.credit = 0

							setElementData(blackjackTable.element, "blackjackData", blackjackTable.data)

							local x, y = rotateAround(blackjackTable.rz, 0, -1.65)

							setElementPosition(source, targetX + x, targetY + y, playerZ)
							setElementRotation(source, 0, 0, blackjackTable.rz)
							setElementFrozen(source, true)
							setPedAnimation(source, "CASINO", "cards_in", -1, false, false, false, true)
							setTimer(setPedAnimation, 750, 1, source, "CASINO", "cards_loop", -1, true, false, false, false)
							setElementData(source, "playerUsingBlackjack", tableIdB)

							triggerClientEvent(source, "openBlackjackGame", source, blackjackTable.data)
						end
					end
				end
			end
		end
	end)

addEvent("closeBlackjackGame", true)
addEventHandler("closeBlackjackGame", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			local tableIdB = getElementData(source, "playerUsingBlackjack")

			setElementFrozen(source, false)
			setPedAnimation(source, "CASINO", "cards_out", -1, false, false, false, false)
			setElementData(source, "playerUsingBlackjack", false)

			if tableIdB then
				resetTable(tableIdB)
			end
		end
	end)

function resetTable(tableIdB, newround)
	local blackjackTable = blackjackTables[tableIdB]

	if blackjackTable then
		local currentPlayer = blackjackTable.data.currentPlayer

		if newround then
			if isElement(currentPlayer) then
				local currentBalance = getElementData(currentPlayer, "char.slotCoins") or 0

				if currentBalance < blackjackTable.minEntry then
					exports.see_hud:showInfobox(currentPlayer, "e", "Nem volt elég Slot Coinod a folytatáshoz!")
					currentPlayer = nil
				end
			end
		end

		if newround then
			blackjackTable.data.currentPlayer = currentPlayer
		else
			blackjackTable.data.currentPlayer = false
		end

		blackjackTable.data.gameStage = 0
		blackjackTable.data.playerCards = {}
		blackjackTable.data.dealerCards = {}
		blackjackTable.data.suspended = false
		blackjackTable.credit = 0

		setElementData(blackjackTable.element, "blackjackData", blackjackTable.data)
	end
end

addEvent("blackJackHandler", true)
addEventHandler("blackJackHandler", getRootElement(),
	function (action, credit)
		if isElement(source) and client and client == source then
			local tableIdB = getElementData(source, "playerUsingBlackjack")

			if tableIdB then
				local blackjackTable = blackjackTables[tableIdB]

				if blackjackTable then
					local currentPlayer = blackjackTable.data.currentPlayer
					local currentBalance = getElementData(source, "char.slotCoins") or 0

					if action == "pot" then
						if currentBalance >= credit then
							createDeck(tableIdB)

							blackjackTable.credit = credit
							blackjackTable.data.gameStage = 1
							blackjackTable.data.playerCards = giveCards(blackjackTable.deckCards, 2)
							blackjackTable.data.dealerCards = giveCards(blackjackTable.deckCards, 2)
							blackjackTable.data.suspended = false

							setPedAnimation(blackjackTable.dealer, "CASINO", "dealone", 800, false, false, false, false)
							setTimer(setPedAnimation, 800, 3, blackjackTable.dealer, "CASINO", "dealone", 800, false, false, false, false)

							setElementData(source, "char.slotCoins", currentBalance - credit)
							setElementData(blackjackTable.element, "blackjackData", blackjackTable.data)
						end
					elseif action == "hit" then
						if not blackjackTable.data.suspended then
							if #blackjackTable.data.playerCards >= 2 then
								table.insert(blackjackTable.data.playerCards, giveCards(blackjackTable.deckCards, 1)[1])

								setPedAnimation(blackjackTable.dealer, "CASINO", "dealone", 800, false, false, false, false)

								if getHandValue(blackjackTable.data.playerCards) > 21 then
									blackjackTable.data.suspended = true
									setTimer(gameLoop, 1000, 1, tableIdB, "bust")
								end

								setElementData(blackjackTable.element, "blackjackData", blackjackTable.data)
							end
						end
					elseif action == "stay" then
						if blackjackTable.data.gameStage == 1 then
							triggerClientEvent(source, "addBlackjackHistory", source, "#ffffffA bank megfordítja a második kártyát.")
						end

						blackjackTable.data.suspended = true
						blackjackTable.data.gameStage = 2

						setTimer(gameLoop, 1000, 1, tableIdB, "newcard")
						setElementData(blackjackTable.element, "blackjackData", blackjackTable.data)
					elseif action == "double" then
						if #blackjackTable.data.playerCards == 2 then
							blackjackTable.data.suspended = false

							if currentBalance - blackjackTable.credit >= 0 then
								triggerClientEvent(source, "addBlackjackHistory", source, "#ffffff" .. getElementData(source, "char.Name"):gsub("_", " ") .. ": Double!")

								if blackjackTable.data.gameStage == 1 then
									triggerClientEvent(source, "addBlackjackHistory", source, "#ffffffA bank megfordítja a második kártyát.")
									blackjackTable.data.gameStage = 2
								end

								blackjackTable.credit = blackjackTable.credit * 2
								blackjackTable.data.suspended = true

								setElementData(source, "char.slotCoins", currentBalance - blackjackTable.credit)
								setPedAnimation(blackjackTable.dealer, "CASINO", "dealone", 800, false, false, false, false)
								
								table.insert(blackjackTable.data.playerCards, giveCards(blackjackTable.deckCards, 1)[1])

								if getHandValue(blackjackTable.data.playerCards) > 21 then
									setTimer(gameLoop, 1000, 1, tableIdB, "bust")
								else
									setTimer(gameLoop, 1000, 1, tableIdB, "newcard")
								end
							else
								triggerClientEvent(source, "addBlackjackHistory", source, "#d75959Nem rendelkezel elég Coin-al a duplázáshoz!")
							end

							setElementData(blackjackTable.element, "blackjackData", blackjackTable.data)
						end
					elseif action == "surrender" then
						if #blackjackTable.data.playerCards == 2 then
							blackjackTable.data.suspended = true

							setElementData(source, "char.slotCoins", currentBalance + blackjackTable.credit / 2)
							setElementData(source, "playerIcons", {"minus", blackjackTable.credit / 2})

							outputChatBox("#3d7abc[StrongMTA - Blackjack]: #ffffffFeladtad a kört, így vesztetted a tét felét.", source, 0, 0, 0, true)

							setTimer(resetTable, 1000, 1, tableIdB)
						end
					end
				end
			end
		end
	end)

function gameLoop(tableIdB, state)
	local blackjackTable = blackjackTables[tableIdB]

	if blackjackTable then
		local currentPlayer = blackjackTable.data.currentPlayer

		blackjackTable.data.gameStage = blackjackTable.data.gameStage + 1

		if isElement(currentPlayer) then
			local dealerHand = getHandValue(blackjackTable.data.dealerCards)
			local playerHand = getHandValue(blackjackTable.data.playerCards)

			if state == "newcard" then
				if dealerHand > 21 and playerHand <= 21 then
					return gameLoop(tableIdB, "win")
				elseif playerHand == 21 and dealerHand ~= 21 and #blackjackTable.data.playerCards == 2 then
					return gameLoop(tableIdB, "blackjack")
				elseif dealerHand < 17 then
					triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#ffffffBank lapot kér.")

					table.insert(blackjackTable.data.dealerCards, giveCards(blackjackTable.deckCards, 1)[1])

					setElementData(blackjackTable.element, "blackjackData", blackjackTable.data)
					setPedAnimation(blackjackTable.dealer, "CASINO", "dealone", 800, false, false, false, false)

					return setTimer(gameLoop, 1000, 1, tableIdB, "newcard")
				elseif playerHand > dealerHand and playerHand <= 21 then
					return gameLoop(tableIdB, "win")
				elseif playerHand > 21 then
					return gameLoop(tableIdB, "loses")
				elseif playerHand == dealerHand then
					return gameLoop(tableIdB, "push")
				elseif dealerHand > playerHand then
					return gameLoop(tableIdB, "loses")
				end
			else
				local win = 0

				triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#ffffffJáték vége.")

				if state == "push" then
					win = blackjackTable.credit
					triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#ffffffPush! Visszakapod a tétet.")
					triggerClientEvent("playBlackjackSound", resourceRoot, tableIdB, "push")
				elseif state == "bust" then
					triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#d75959Vesztettél! (Bust)")
					triggerClientEvent("playBlackjackSound", resourceRoot, tableIdB, "dealerwin")
				elseif state == "loses" then
					triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#ffffffVesztettél #d75959" .. blackjackTable.credit .. " #ffffffCoint-t!")
					triggerClientEvent("playBlackjackSound", resourceRoot, tableIdB, "dealerwin")
				elseif state == "win" then
					win = blackjackTable.credit * 2
					triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#ffffffNyertél #3d7abc" .. blackjackTable.credit .. " #ffffffCoin-t!")
					triggerClientEvent("playBlackjackSound", resourceRoot, tableIdB, "win")
				elseif state == "blackjack" then
					win = math.floor(blackjackTable.credit * 2.5)
					triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#ffffffNyertél #3d7abc" .. math.floor(blackjackTable.credit * 1.5) .. " #ffffffCoin-t! (Blackjack)")
					triggerClientEvent("playBlackjackSound", resourceRoot, tableIdB, "blackjack")
				end

				setElementData(currentPlayer, "char.slotCoins", (getElementData(currentPlayer, "char.slotCoins") or 0) + win)

				if win ~= blackjackTable.credit then
					if win > blackjackTable.credit then
						setPedAnimation(currentPlayer, "CASINO", "slot_win_out", -1, false, false, false, false)
						setElementData(currentPlayer, "playerIcons", {"plus", win})
					else
						setPedAnimation(currentPlayer, "CASINO", "cards_lose", -1, false, false, false, false)
						setElementData(currentPlayer, "playerIcons", {"minus", blackjackTable.credit})
					end

					setTimer(setPedAnimation, 2000, 1, currentPlayer, "CASINO", "cards_loop", -1, true, false, false, false)
				end

				triggerClientEvent(currentPlayer, "addBlackjackHistory", currentPlayer, "#ffffffÚj kör kezdéséig #3d7abc5 másodperc!")

				setTimer(resetTable, 5000, 1, tableIdB, true)
			end
		end
	end
end

function giveCards(deck, amount)
	local cards = {}

	for i = 1, amount do
		cards[i] = table.remove(deck)
	end

	return cards
end

function shuffleDeck(deck)
	for i = #deck, 2, -1 do
		local j = math.random(i)
		deck[i], deck[j] = deck[j], deck[i]
	end
end

function createDeck(tableIdB)
	blackjackTables[tableIdB].deckCards = {}

	for i = 1, #cardRanks do
		for j = 1, 4 do
			table.insert(blackjackTables[tableIdB].deckCards, {i, j})
		end
	end

	for i = 1, 3 do
		shuffleDeck(blackjackTables[tableIdB].deckCards)
	end
end