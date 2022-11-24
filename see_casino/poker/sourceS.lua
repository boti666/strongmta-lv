local databaseConnection = false

local pokerTableCols = {}
local pokerTablePeds = {}

local pokerDeckCards = {}
local pokerBoardPots = {}

local gameCheckTimers = {}
local nextRoundTimers = {}
local playerTimeoutTimers = {}

function execute(func, ...)
	local thread = coroutine.create(func)
	coroutine.resume(thread, ...)
end

function sleep(interval)
	local thread = coroutine.running()
	setTimer(
		function ()
			coroutine.resume(thread)
		end,
	interval, 1)
	coroutine.yield()
end

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", root,
	function (connectionElement)
		databaseConnection = connectionElement
	end
)

addEventHandler("onResourceStart", resourceRoot,
	function ()
		databaseConnection = exports.see_database:getConnection()

		if databaseConnection then
			dbQuery(
				function (queryHandle)
					local queryResult = dbPoll(queryHandle, 0)

					if queryResult then
						for rowIndex, rowInfo in ipairs(queryResult) do
							local currentSenTable = {
								tableId = rowInfo.id,
								posX = rowInfo.posX,
								posY = rowInfo.posY,
								posZ = rowInfo.posZ,
								rotZ = rowInfo.rotZ,
								interior = rowInfo.interior,
								dimension = rowInfo.dimension,
								smallBlind = rowInfo.smallBlind,
								bigBlind = rowInfo.bigBlind,
								minEntry = rowInfo.minEntry,
								maxEntry = rowInfo.maxEntry
							}
							createPokerTable(currentSenTable, true)
						end
					end
				end,
			databaseConnection, "SELECT * FROM pokertables")
		end
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function ()
		for dataKey in pairs(getAllElementData(resourceRoot)) do
			removeElementData(resourceRoot, dataKey)
		end
	end
)

addEvent("requestPokerTables", true)
addEventHandler("requestPokerTables", resourceRoot,
	function ()
		if isElement(client) then
			triggerClientEvent(client, "requestPokerTables", resourceRoot, tablePositions)
		end
	end
)

addEvent("createPoker", true)
addEventHandler("createPoker", resourceRoot,
	function (dataTable)
		if isElement(client) then
			if getElementData(client, "acc.adminLevel") >= 6 then 
				if type(dataTable) == "table" then
					local columnNames = {}
					local columnValues = {}

					for columnName, columnValue in pairs(dataTable) do
						table.insert(columnNames, columnName)
						table.insert(columnValues, columnValue)
					end

					dbQuery(
						function (queryHandle, sourcePlayer)
							local queryResult, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)

							if queryResult then
								lastInsertId = tonumber(lastInsertId)

								if lastInsertId then
									if isElement(sourcePlayer) then
										outputChatBox("#3d7abc[StrongMTA]: #ffffffA pókerasztal sikeresen létrehozva. #32b3ef(ID: " .. lastInsertId .. ")", sourcePlayer, 255, 255, 255, true)
									end

									if not dataTable.tableId then
										dataTable.tableId = lastInsertId
									end

									createPokerTable(dataTable, true)
								else
									if isElement(sourcePlayer) then
										outputChatBox("#d75959[StrongMTA]: #ffffffA pókerasztal létrehozása meghiúsult.", sourcePlayer, 255, 255, 255, true)
									end
								end
							else
								if isElement(sourcePlayer) then
									outputChatBox("#d75959[StrongMTA]: #ffffffA pókerasztal létrehozása meghiúsult.", sourcePlayer, 255, 255, 255, true)
								end
							end
						end,
					{client}, databaseConnection, "INSERT INTO pokertables (" .. table.concat(columnNames, ",") .. ") VALUES (" .. string.sub(string.rep("?,", #columnNames), 1, -2) .. ")", unpack(columnValues))
				end
			end
		end
	end
)

function createPokerTable(tableInfo, justNowCreated)
	if tableInfo then
		local tableId = tableInfo.tableId or 0

		if tableId then
			tablePositions[tableId] = {
				tableInfo.posX,
				tableInfo.posY,
				tableInfo.posZ,
				tableInfo.rotZ,
				tableInfo.interior,
				tableInfo.dimension,
				tableInfo.smallBlind,
				tableInfo.bigBlind,
				tableInfo.minEntry,
				tableInfo.maxEntry
			}

			if not pokerDeckCards[tableId] then
				pokerDeckCards[tableId] = {}
			end

			if not pokerBoardPots[tableId] then
				pokerBoardPots[tableId] = {}
			end

			generateTables(tableId)

			-- Collision shape
			pokerTableCols[tableId] = createColSphere(tableInfo.posX, tableInfo.posY, tableInfo.posZ, 5)

			if isElement(pokerTableCols[tableId]) then
				setElementInterior(pokerTableCols[tableId], tableInfo.interior)
				setElementDimension(pokerTableCols[tableId], tableInfo.dimension)
				setElementData(pokerTableCols[tableId], "pokerTableId", tableId)
				setElementData(pokerTableCols[tableId], "occupiedSeats", {})
			end

			-- Osztó
			local theDealerPosition = realDealerPositions[tableId]

			pokerTablePeds[tableId] = createPed(189, theDealerPosition[1], theDealerPosition[2], theDealerPosition[3], theDealerPosition[4])

			if isElement(pokerTablePeds[tableId]) then
				setElementInterior(pokerTablePeds[tableId], tableInfo.interior)
				setElementDimension(pokerTablePeds[tableId], tableInfo.dimension)
				setElementFrozen(pokerTablePeds[tableId], true)
				setElementData(pokerTablePeds[tableId], "visibleName", "Dealer")
				setElementData(pokerTablePeds[tableId], "invulnerable", true)
			end

			-- Ha most lett lerakva az asztal, szinkronizáljuk
			if justNowCreated then
				triggerClientEvent("createPokerTable", resourceRoot, tableId, tablePositions[tableId])
			end
		end
	end
end

addCommandHandler("updatepoker",
	function (sourcePlayer, commandName, tableId, smallBlind, bigBlind, minEntry, maxEntry)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			tableId = tonumber(tableId)
			smallBlind = tonumber(smallBlind)
			bigBlind = tonumber(bigBlind)
			minEntry = tonumber(minEntry)
			maxEntry = tonumber(maxEntry)

			if not (tableId and smallBlind and bigBlind and minEntry and maxEntry) then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [ID] [Kisvak] [Nagyvak] [Min. beülõ] [Max. beülõ]", sourcePlayer, 255, 255, 255, true)
			else
				local selectedPokerTable = tablePositions[tableId]

				if selectedPokerTable then
					local executionResult = dbExec(databaseConnection, "UPDATE pokertables SET smallBlind = ?, bigBlind = ?, minEntry = ?, maxEntry = ? WHERE tableId = ?", smallBlind, bigBlind, minEntry, maxEntry, tableId)

					if executionResult then
						outputChatBox("#3d7abc[StrongMTA]: #ffffffA pókerasztal sikeresen módosítva.", sourcePlayer, 255, 255, 255, true)

						selectedPokerTable[7] = smallBlind
						selectedPokerTable[8] = bigBlind
						selectedPokerTable[9] = minEntry
						selectedPokerTable[10] = maxEntry

						triggerClientEvent("updatePokerTable", resourceRoot, tableId, selectedPokerTable)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott pókerasztal nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("deletepoker",
	function (sourcePlayer, commandName, tableId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			tableId = tonumber(tableId)

			if not tableId then
				outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [ID]", sourcePlayer, 255, 255, 255, true)
			else
				if tablePositions[tableId] then
					local executionResult = dbExec(databaseConnection, "DELETE FROM pokertables WHERE tableId = ?", tableId)

					if executionResult then
						triggerClientEvent("deletePokerTable", resourceRoot, tableId)

						removePokerBoardData(tableId, "isGameIsOn")
						removePokerBoardData(tableId, "gameStage")
						removePokerBoardData(tableId, "boardCards")
						removePokerBoardData(tableId, "dealerSeat")
						removePokerBoardData(tableId, "smallBlind")
						removePokerBoardData(tableId, "bigBlind")
						removePokerBoardData(tableId, "lastPlayer")
						removePokerBoardData(tableId, "currentPlayer")
						removePokerBoardData(tableId, "currentCall")
						removePokerBoardData(tableId, "showdown")
						removePokerBoardData(tableId, "pot")

						for seatId = 1, maximumPlayers do
							local playerElement = getPokerSeatData(tableId, seatId, "element")

							if isElement(playerElement) then
								removeElementData(playerElement, "pokerTableId")
								removeElementData(playerElement, "pokerTableSeat")

								setElementFrozen(playerElement, false)
								setPedAnimation(playerElement, false)
							end

							removePokerSeatData(tableId, seatId, "element")
							removePokerSeatData(tableId, seatId, "pokerCoins")
							removePokerSeatData(tableId, seatId, "pokerCards")
							removePokerSeatData(tableId, seatId, "currentCall")
							removePokerSeatData(tableId, seatId, "roundCall")
							removePokerSeatData(tableId, seatId, "win")
						end

						if pokerTableCols[tableId] then
							if isElement(pokerTableCols[tableId]) then
								destroyElement(pokerTableCols[tableId])
							end

							pokerTableCols[tableId] = nil
						end

						if pokerTablePeds[tableId] then
							if isElement(pokerTablePeds[tableId]) then
								destroyElement(pokerTablePeds[tableId])
							end

							pokerTablePeds[tableId] = nil
						end

						if gameCheckTimers[tableId] then
							if isTimer(gameCheckTimers[tableId]) then
								killTimer(gameCheckTimers[tableId])
							end

							gameCheckTimers[tableId] = nil
						end

						if nextRoundTimers[tableId] then
							if isTimer(nextRoundTimers[tableId]) then
								killTimer(nextRoundTimers[tableId])
							end

							nextRoundTimers[tableId] = nil
						end

						if playerTimeoutTimers[tableId] then
							if isTimer(playerTimeoutTimers[tableId]) then
								killTimer(playerTimeoutTimers[tableId])
							end

							playerTimeoutTimers[tableId] = nil
						end

						tablePositions[tableId] = nil
						realGuiPositions[tableId] = nil
						realBlindPositions[tableId] = nil
						realCoinPositions[tableId] = nil
						realPedPositions[tableId] = nil
						realDealerPositions[tableId] = nil
						cardLinePositions[tableId] = nil
						realPlayerCardPositions[tableId] = nil

						pokerDeckCards[tableId] = nil
						pokerBoardPots[tableId] = nil

						outputChatBox("#3d7abc[StrongMTA]: #ffffffA pókerasztal sikeresen törölve. #32b3ef(" .. tableId .. ")", sourcePlayer, 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott pókerasztal nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("joinPokerTable", true)
addEventHandler("joinPokerTable", resourceRoot,
	function (selectedTableId, selectedSeatId)
		if isElement(client) then
			if selectedTableId then
				if selectedSeatId then
					local pokerTable = tablePositions[selectedTableId]

					if pokerTable then
						local currentTableId = getElementData(client, "pokerTableId")

						if not currentTableId then
							local thePedPosition = realPedPositions[selectedTableId][selectedSeatId]

							if isElement(pokerTableCols[selectedTableId]) then
								local occupiedSeats = getElementData(pokerTableCols[selectedTableId], "occupiedSeats") or {}

								if occupiedSeats then
									table.insert(occupiedSeats, selectedSeatId)
								end

								setElementData(pokerTableCols[selectedTableId], "occupiedSeats", occupiedSeats)
							end

							setElementFrozen(client, true)
							setElementPosition(client, thePedPosition[1], thePedPosition[2], thePedPosition[3])
							setElementRotation(client, 0, 0, thePedPosition[4], "default", true)
							setPedAnimation(client, "FOOD", "FF_Sit_Look", -1, true, false, false)

							setElementData(client, "pokerTableSeat", selectedSeatId) -- fontos a sorrend,
							setElementData(client, "pokerTableId", selectedTableId) --  különben nem fut le megfelelőlen az onClientElementDataChange >.<

							triggerClientEvent(client, "joinPokerTable", resourceRoot, selectedTableId)
						end
					end
				end
			end
		end
	end
)

addEvent("leavePokerTable", true)
addEventHandler("leavePokerTable", resourceRoot,
	function (selectedTableId)
		if isElement(client) then
			if selectedTableId then
				if tablePositions[selectedTableId] then
					local currentTableId = getElementData(client, "pokerTableId")

					if currentTableId == selectedTableId then
						local seatId = getElementData(client, "pokerTableSeat")

						if seatId then
							setPlayerLeave(selectedTableId, seatId)

							setElementData(client, "pokerTableId", false)
							setElementData(client, "pokerTableSeat", false)

							setElementFrozen(client, false)
							setPedAnimation(client, false)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onPlayerQuit", root,
	function ()
		local pokerTableId = getElementData(source, "pokerTableId")

		if pokerTableId then
			local pokerTableSeat = getElementData(source, "pokerTableSeat")

			if pokerTableSeat then
				setPlayerLeave(pokerTableId, pokerTableSeat)
			end
		end
	end
)

addEvent("startPoker", true)
addEventHandler("startPoker", resourceRoot,
	function (buyInAmount)
		if isElement(client) then
			local pokerTableId = getElementData(client, "pokerTableId")

			if pokerTableId then
				local pokerTableSeat = getElementData(client, "pokerTableSeat")

				if pokerTableSeat then
					local pokerTable = tablePositions[pokerTableId]

					if pokerTable then
						buyInAmount = tonumber(buyInAmount)

						if buyInAmount then
							local currentCoins = getElementData(client, "char.slotCoins") or 0

							if currentCoins >= buyInAmount then
								local minimumBuyIn = pokerTable[9]
								local maximumBuyIn = pokerTable[10]

								if buyInAmount >= minimumBuyIn and buyInAmount <= maximumBuyIn then
									-- Vonjuk le a játékostól az összeget
									currentCoins = currentCoins - buyInAmount

									if currentCoins < 0 then
										currentCoins = 0
									end

									setElementData(client, "char.slotCoins", currentCoins)

									-- Inicializáljuk a kiválasztott ülést
									setPokerSeatData(pokerTableId, pokerTableSeat, "element", client)
									setPokerSeatData(pokerTableId, pokerTableSeat, "pokerCoins", buyInAmount)

									removePokerSeatData(pokerTableId, pokerTableSeat, "pokerCards")
									removePokerSeatData(pokerTableId, pokerTableSeat, "currentCall")
									removePokerSeatData(pokerTableId, pokerTableSeat, "roundCall")
									removePokerSeatData(pokerTableId, pokerTableSeat, "win")

									-- Ha jelenleg nincs aktív meccs, próbáljuk elindítani
									if not getPokerBoardData(pokerTableId, "isGameIsOn") then
										initializeRoundCheck(pokerTableId, false)
									end

									-- Szinkronizáljuk a játékosnak, hogy sikeresen leült -> GUI megjelenítése stb..
									triggerClientEvent(client, "startPoker", resourceRoot, pokerTableId)
								else
									triggerClientEvent(client, "pokerChatMessage", resourceRoot, "#d75959A megadott összeg érvénytelen!")
								end
							else
								triggerClientEvent(client, "pokerChatMessage", resourceRoot, "#d75959A megadott összeg érvénytelen!")
							end
						end
					end
				end
			end
		end
	end
)

addEvent("pokerAction", true)
addEventHandler("pokerAction", resourceRoot,
	function (actionName, betAmount)
		if isElement(client) then
			if actionName then
				local pokerTableId = getElementData(client, "pokerTableId")

				if pokerTableId then
					local pokerTableSeat = getElementData(client, "pokerTableSeat")

					if pokerTableSeat then
						local currentPlayerSeat = getPokerBoardData(pokerTableId, "currentPlayer") or 0

						if currentPlayerSeat == pokerTableSeat then
							betAmount = tonumber(betAmount) or 0

							if actionName == "fold" then
								setPlayerFolded(pokerTableId, pokerTableSeat)
							else
								setPlayerBetted(pokerTableId, pokerTableSeat, betAmount)
							end
						else
							triggerClientEvent(client, "pokerChatMessage", resourceRoot, "#d75959Várd ki a sorod, most nem te következel!")
						end
					end
				end
			end
		end
	end
)

function addPokerChatLine(textMessage, tableId)
	tableId = tonumber(tableId)

	if tableId then
		if type(textMessage) == "string" then
			local affectedPlayers = {}

			for seatId = 1, maximumPlayers do
				local playerElement = getPokerSeatData(tableId, seatId, "element")

				if isElement(playerElement) then
					table.insert(affectedPlayers, playerElement)
				end
			end

			if #affectedPlayers > 0 then
				triggerClientEvent(affectedPlayers, "pokerChatMessage", resourceRoot, textMessage)
			end
		end
	end
end

function setPlayerLeave(tableId, seatId, forcedLeave)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Ha rakott fel tétet a jelenlegi licitkörben, adjuk hozzá a jelenlegi kasszához
		local currentCall = getPokerSeatData(tableId, seatId, "currentCall") or 0

		if currentCall > 0 then
			local currentPotIndex = #pokerBoardPots[tableId]
			local currentPot = pokerBoardPots[tableId][currentPotIndex]

			if currentPot then
				currentPot.amount = currentPot.amount + currentCall
			end

			-- Számoljuk össze a kasszákban lévő összegeket és küldjük el a klienseknek
			local potValue = 0

			for i = #pokerBoardPots[tableId], 1, -1 do
				local thisPot = pokerBoardPots[tableId][i]

				if thisPot then
					potValue = potValue + thisPot.amount
				end
			end

			setPokerBoardData(tableId, "pot", potValue)
		end

		-- Vegyük ki az összes kasszából, hogy a meccs végén ne számolja bele mint résztvevő
		for i = #pokerBoardPots[tableId], 1, -1 do
			local thisPot = pokerBoardPots[tableId][i]

			if thisPot then
				thisPot.contributors[seatId] = nil
			end
		end

		-- Számoljuk össze azokat a játékosokat, akik még nem dobtál el a lapjaikat
		local remainingPlayers = 0

		for i = 1, maximumPlayers do
			if i ~= seatId then -- A jelenleg kiszálló játékost ne számoljuk bele
				if isPokerSeatActive(tableId, i, false, true) then -- Csak a lapokat nézzük, a zsetonokat hagyjuk
					remainingPlayers = remainingPlayers + 1
				end
			end
		end

		-- Ha van még elég játékos a meccs folytatásához
		if remainingPlayers >= minimumPlayers then
			local pokerCards = getPokerSeatData(tableId, seatId, "pokerCards") or {}

			-- Ha a játékos úgy hagyja el a játékot, hogy még voltak lapjai
			if #pokerCards > 0 then
				local lastPlayer = getPokerBoardData(tableId, "lastPlayer")
				local currentPlayer = getPokerBoardData(tableId, "currentPlayer")

				-- Ha az a játékos lépett ki akinek most kellett volna cselekednie
				if currentPlayer == seatId then
					-- De nem ő volt az akinek utoljára kell cselekednie
					if currentPlayer ~= lastPlayer then
						-- Passzoljuk át a cselekvést a következő játékosnak
						actionToNextPlayer(tableId)
					end
				-- Ellenkező esetben, ha az a játékos lépett ki, akinek utoljára kellett volna cselekednie
				elseif lastPlayer == seatId then
					-- Keressük meg és állítsuk be az új játékost akinek utoljára kell cselekednie
					setPokerBoardData(tableId, "lastPlayer", findPreviousPlayer(tableId, lastPlayer))
				end
			end
		end

		-- Adjuk vissza a játékosnak a maradék zsetonjait
		local playerElement = getPokerSeatData(tableId, seatId, "element")

		if isElement(playerElement) then
			local chipsInPlay = getPokerSeatData(tableId, seatId, "pokerCoins") or 0

			if chipsInPlay > 0 then
				local slotCoins = getElementData(playerElement, "char.slotCoins") or 0

				slotCoins = slotCoins + chipsInPlay

				setElementData(playerElement, "char.slotCoins", slotCoins)
			end
		end

		-- Szabadítsuk fel az ülőhelyet
		local occupiedSeats = getElementData(pokerTableCols[tableId], "occupiedSeats") or {}

		removePokerSeatData(tableId, seatId, "element")
		removePokerSeatData(tableId, seatId, "pokerCoins")
		removePokerSeatData(tableId, seatId, "pokerCards")
		removePokerSeatData(tableId, seatId, "currentCall")
		removePokerSeatData(tableId, seatId, "roundCall")
		removePokerSeatData(tableId, seatId, "win")

		if occupiedSeats then
			local seatArrayIndex = false

			for i = 1, #occupiedSeats do
				if occupiedSeats[i] == seatId then
					seatArrayIndex = i
					break
				end
			end

			if seatArrayIndex then
				table.remove(occupiedSeats, seatArrayIndex)
			end

			setElementData(pokerTableCols[tableId], "occupiedSeats", occupiedSeats)
		end

		-- Ha nincs elég játékos a játék folytatásához, töröljük a jelenlegi "osztó játékost", hogy a következő körben másvalaki legyen az
		if #occupiedSeats < minimumPlayers then
			removePokerBoardData(tableId, "dealerSeat")
		end

		if isElement(playerElement) then
			-- Küldjünk értesítést a többi játékosnak, hogy ha a játékos magától lépett ki
			if not forcedLeave then
				local playerName = getElementData(playerElement, "visibleName"):gsub("_", " ")

				if playerName then
					addPokerChatLine("#3d7abc" .. playerName .. " #ffffffkiszállt a játékból!", tableId)
				end
			-- Állítsuk fel a játékost az asztaltól ha elfogyott a zsetonja
			else
				setElementData(playerElement, "pokerTableId", false)
				setElementData(playerElement, "pokerTableSeat", false)

				setElementFrozen(playerElement, false)
				setPedAnimation(playerElement, false)

				outputChatBox("#d75959[StrongMTA - Póker]: #ffffffNincs több coinod a folytatáshoz.", playerElement, 255, 255, 255, true)
			end
		end

		-- Ha nincs meg a minimális játékosszám, legyen vége a körnek
		if remainingPlayers < minimumPlayers then
			endRound(tableId)
		else
			local lastPlayer = getPokerBoardData(tableId, "lastPlayer")

			-- Ha az a játékos lépett ki, akinek utoljára kellett volna cselekednie
			if lastPlayer == seatId then
				local currentPlayer = getPokerBoardData(tableId, "currentPlayer")

				-- És ő volt a jelenlegi cselekvő játékos is, ugorjunk a következő licitkörre
				if currentPlayer == seatId then
					execute(endPhase, tableId)
				end
			end
		end
	end
end

function setPlayerFolded(tableId, seatId, isTimeout)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		local currentPlayer = getPokerBoardData(tableId, "currentPlayer") or 0

		-- Ha a kiválasztott játékos volt akinek most cselekednie kellett
		if currentPlayer == seatId then
			local pokerCards = getPokerSeatData(tableId, seatId, "pokerCards") or {}

			-- Csak akkor lépjünk tovább, ha tényleg vannak még lapjai
			if #pokerCards > 0 then
				-- Vegyük el a játékos lapjait
				removePokerSeatData(tableId, seatId, "pokerCards")

				-- Értesítsük a többi játékost erről a cselekvésről
				local playerElement = getPokerSeatData(tableId, seatId, "element")

				if isElement(playerElement) then
					local playerName = getElementData(playerElement, "visibleName"):gsub("_", " ")

					if isTimeout then
						addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffFold! (TimeOut)", tableId)
					else
						addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffFold!", tableId)
					end
				end

				triggerClientEvent("playPokerSound", resourceRoot, tableId, "fold")

				-- Vegyük ki az összes kasszából, hogy a meccs végén ne számolja bele mint résztvevő
				for i = #pokerBoardPots[tableId], 1, -1 do
					local thisPot = pokerBoardPots[tableId][i]

					if thisPot then
						thisPot.contributors[seatId] = nil
					end
				end

				-- Számoljuk össze azokat a játékosokat, akik még nem dobtál el a lapjaikat
				local remainingPlayers = 0

				for i = 1, maximumPlayers do
					if isPokerSeatActive(tableId, i, false, true) then -- Csak a lapokat nézzük, a zsetonokat hagyjuk
						remainingPlayers = remainingPlayers + 1
					end
				end

				-- Ha nincs elég játékos a játék folytatásához, a játékban maradt utolsó játékos nyeri a kasszát
				if remainingPlayers < minimumPlayers then
					local showdownActive = getPokerBoardData(tableId, "showdown")

					-- Csak akkor nyerjen, ha nincs folyamatban showdown (különben duplán kapja meg)
					if not showdownActive then
						local winnerSeat = findNextPlayer(tableId, nil, false, true) -- Csak a lapokat nézzük, a zsetonokat hagyjuk

						-- Ha találtunk olyan játékost akinek maradt lapja, adjuk oda a kassza tartalmát
						if winnerSeat then
							resolveSidePots(tableId)
							givePotToWinner(tableId, winnerSeat)
						end

						-- Állítsuk le a játékot
						endRound(tableId, true)
					end
				else
					local lastPlayer = getPokerBoardData(tableId, "lastPlayer")

					-- Ha az utoljára cselekvő játékos az aki most eldobta a lapjait, legyen vége a jelenlegi licitkörnek
					if lastPlayer == seatId then
						execute(endPhase, tableId)
					-- Ellenkező esetben, passzoljuk át a cselekvést a következő játékosnak
					else
						actionToNextPlayer(tableId)
					end
				end
			end
		end
	end
end

function setPlayerBetted(tableId, seatId, betAmount)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		local currentPlayer = getPokerBoardData(tableId, "currentPlayer") or 0

		-- Ha a kiválasztott játékos volt akinek most cselekednie kellett
		if currentPlayer == seatId then
			betAmount = tonumber(betAmount) or 0

			local playerElement = getPokerSeatData(tableId, seatId, "element")
			-- A játékos tétje az aktuális licitkörre
			local playerCall = getPokerSeatData(tableId, seatId, "currentCall") or 0
			-- A játékos hátralévő zsetonjai
			local playerCoins = getPokerSeatData(tableId, seatId, "pokerCoins") or 0

			-- A jelenlegi licitkör eddigi legnagyobb tétje
			local highestCall = getPokerBoardData(tableId, "currentCall") or 0
			-- Az a mennyiség, amennyit mindenképp meg kell adnia a játékosnak, hogy játékban maradjon
			local amountToCall = highestCall - playerCall

			-- Ha a felrakni kívánt tét nagyobb mint a minimális tét, nyitunk vagy emelünk
			if betAmount > amountToCall then
				if isElement(playerElement) then
					local playerName = getElementData(playerElement, "visibleName"):gsub("_", " ")

					-- Levonjuk és felrakjuk a licitkörre az emelés összegét
					takePlayerPokerCoins(tableId, seatId, betAmount + amountToCall)

					if playerName then
						-- Ha ez egy All-In
						if betAmount > playerCoins then
							-- Ha a jelenlegi licitkörben még senki nem nyitott
							if highestCall == 0 then
								addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffBet! (All-In)", tableId)
							-- Ellenkező esetben, emelünk
							else
								addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffRaise! (All-In)", tableId)
							end
						-- Ha a jelenlegi licitkörben még senki nem nyitott
						elseif highestCall == 0 then
							addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffBet! (" .. thousandsStepper(betAmount) .. " Coin)", tableId)
						-- Ellenkező esetben, emelünk
						else
							addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffRaise! (" .. thousandsStepper(betAmount) .. " Coin)", tableId)
						end
					end

					triggerClientEvent("playPokerSound", resourceRoot, tableId, "raise")
				end

				-- Ha az előző játékos a jelenlegi aktív játékos, ugorjunk a következő licitkörre
				local previousPlayer = findPreviousPlayer(tableId)

				if previousPlayer == currentPlayer then
					execute(endPhase, tableId)
				-- Ellenkező esetben, passzoljuk át a cselekvést a következő játékosnak
				else
					setPokerBoardData(tableId, "lastPlayer", previousPlayer)
					actionToNextPlayer(tableId)
				end
			-- Ha a felrakni kívánt tét kisebb vagy egyenlő mint a kötelező tét, passzolunk vagy hívunk
			else
				if isElement(playerElement) then
					local playerName = getElementData(playerElement, "visibleName"):gsub("_", " ")

					-- Ha a minimális tét amit a játékos fel kell rakjon, nulla, passzolunk
					if amountToCall == 0 then
						if playerName then
							addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffCheck!", tableId)
						end

						triggerClientEvent("playPokerSound", resourceRoot, tableId, "check")
					-- Ellenkező esetben, megadjuk a minimális tétet
					else
						-- Levonjuk és felrakjuk a licitkörre a minimális összegét
						takePlayerPokerCoins(tableId, seatId, amountToCall)

						if playerName then
							-- Ha a minimális tét egyenlő (azaz meghaladta) a játékos zsetonját, All-In
							if amountToCall > playerCoins then
								addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffCall! (All-In)", tableId)
							else
								addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffCall!", tableId)
							end
						end

						triggerClientEvent("playPokerSound", resourceRoot, tableId, "call")
					end
				end

				-- Ha az utolsó játékos akinek lépnie kell, az a játékos ami most lépett, átugrunk a következő licitkörre
				local lastPlayer = getPokerBoardData(tableId, "lastPlayer")

				if lastPlayer == currentPlayer then
					execute(endPhase, tableId)
				-- Ellenkező esetben, passzoljuk át a cselekvést a következő játékosnak
				else
					actionToNextPlayer(tableId)
				end
			end
		end
	end
end

function takePlayerPokerCoins(tableId, seatId, coinsAmount)
	if tableId then
		coinsAmount = tonumber(coinsAmount)

		if coinsAmount then
			coinsAmount = math.floor(math.abs(coinsAmount))

			if coinsAmount > 0 then
				local playerCoins = getPokerSeatData(tableId, seatId, "pokerCoins") or 0

				if playerCoins > 0 then
					local currentCall = getPokerSeatData(tableId, seatId, "currentCall") or 0
					local highestCall = getPokerBoardData(tableId, "currentCall") or 0

					-- Ha a felrakni kívánt tét nagyobb mint amennyije van, ne engedjünk többet
					if coinsAmount > playerCoins then
						coinsAmount = playerCoins
					end

					playerCoins = playerCoins - coinsAmount
					currentCall = currentCall + coinsAmount

					setPokerSeatData(tableId, seatId, "pokerCoins", playerCoins)
					setPokerSeatData(tableId, seatId, "currentCall", currentCall)
					setPokerSeatData(tableId, seatId, "roundCall", currentCall)

					-- Ha a játékosnak nagyobb a jelenlegi tétje mint az eddigi legnagyobb tét az asztalon, frissítsük
					if currentCall > highestCall then
						setPokerBoardData(tableId, "currentCall", currentCall)
					end
				end
			end
		end
	end
end

function isPokerSeatActive(tableId, seatId, skipCards, skipCoins)
	if tableId then
		if seatId then
			local playerElement = getPokerSeatData(tableId, seatId, "element")

			if isElement(playerElement) then
				local haveCoins = false
				local haveCards = false

				if not skipCoins then
					local pokerCoins = getPokerSeatData(tableId, seatId, "pokerCoins") or 0

					if pokerCoins > 0 then
						haveCoins = true
					end
				end

				if not skipCards then
					local pokerCards = getPokerSeatData(tableId, seatId, "pokerCards") or {}

					if #pokerCards > 0 then
						haveCards = true
					end
				end

				return (haveCards or skipCards) and (haveCoins or skipCoins)
			end
		end
	end
end

function findNextPlayer(tableId, startOffset, skipCards, skipCoins)
	if tableId then
		startOffset = tonumber(startOffset)

		if not startOffset then
			startOffset = getPokerBoardData(tableId, "currentPlayer") or 0
		end

		if startOffset ~= maximumPlayers then
			for i = startOffset + 1, maximumPlayers do
				if isPokerSeatActive(tableId, i, skipCards, skipCoins) then
					return i
				end
			end
		end

		for i = 1, startOffset do
			if isPokerSeatActive(tableId, i, skipCards, skipCoins) then
				return i
			end
		end
	end

	return nil
end

function findPreviousPlayer(tableId, startOffset, skipCards, skipCoins)
	if tableId then
		startOffset = tonumber(startOffset)

		if not startOffset then
			startOffset = getPokerBoardData(tableId, "currentPlayer") or 0
		end

		if startOffset ~= 0 then
			for i = startOffset - 1, 1, -1 do
				if isPokerSeatActive(tableId, i, skipCards, skipCoins) then
					return i
				end
			end
		end

		for i = maximumPlayers, startOffset, -1 do
			if isPokerSeatActive(tableId, i, skipCards, skipCoins) then
				return i
			end
		end
	end

	return nil
end

function initializeRoundCheck(tableId, changeDealer)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		if not isTimer(gameCheckTimers[tableId]) then
			gameCheckTimers[tableId] = setTimer(
				function ()
					startRound(tableId, changeDealer)
				end,
			5000, 1)
		end
	end
end

function startRound(tableId, changeDealer)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Ha nincs semmi megadva (nil) az osztócserére, mindenképp cserélünk
		if changeDealer == nil then
			changeDealer = true
		end

		-- Ha jelenleg nincs aktív pókermeccs
		if not getPokerBoardData(tableId, "isGameIsOn") then
			local sittingInCounter = 0

			-- Számoljuk össze, hogy mennyi játékos tud résztvenni az új körben
			for i = 1, maximumPlayers do
				local playerElement = getPokerSeatData(tableId, i, "element")

				if isElement(playerElement) then
					local chipsInPlay = getPokerSeatData(tableId, i, "pokerCoins") or 0

					-- Ha a játékosnak maradt még zsetonja az asztalon, készítsük elő az új körre
					if chipsInPlay > 0 then
						sittingInCounter = sittingInCounter + 1

						setPokerSeatData(tableId, i, "pokerCards", {})
						setPokerSeatData(tableId, i, "currentCall", 0)
						setPokerSeatData(tableId, i, "roundCall", 0)
					-- Ellenkező esetben, állítsuk fel az asztaltól
					else
						setPlayerLeave(tableId, i, true)
					end
				end
			end

			-- Ha van elég játékos a kör megkezdéséhez
			if sittingInCounter >= minimumPlayers then
				setPokerBoardData(tableId, "isGameIsOn", true)
				setPokerBoardData(tableId, "currentCall", 0)
				setPokerBoardData(tableId, "pot", 0)

				-- Fő-kassza inicializálása
				pokerBoardPots[tableId] = {}

				if not pokerBoardPots[tableId][1] then
					pokerBoardPots[tableId][1] = {
						amount = 0,
						contributors = {}
					}
				end

				-- Kártyapakli felépítése és megkeverése
				pokerDeckCards[tableId] = {}

				for i = 1, #cardRanks do
					for j = 1, #cardSuits do
						table.insert(pokerDeckCards[tableId], {i, j})
					end
				end

				table.shuffle(pokerDeckCards[tableId])

				-- Ha eddig nem volt osztó, az "osztógomb" egy véletlenszerű játékoshoz kerül
				local dealerSeat = getPokerBoardData(tableId, "dealerSeat")

				if not dealerSeat then
					local sittingInPlayers = {}

					for i = 1, maximumPlayers do
						if isPokerSeatActive(tableId, i, true, false) then -- Ilyenkor még nincsenek lapjai, szóval ne vegyük figyelembe
							table.insert(sittingInPlayers, i)
						end
					end

					dealerSeat = sittingInPlayers[math.random(#sittingInPlayers)]
				-- Ha új játék keződik, vagy ha a régi osztó kilépett, adjuk oda az "osztógombot" a következő játékosnak
				else
					local playerElement = getPokerSeatData(tableId, dealerSeat, "element")

					if not isElement(playerElement) then
						changeDealer = true
					end

					if changeDealer then
						dealerSeat = findNextPlayer(tableId, dealerSeat, true) -- Ilyenkor még nincsenek lapjai, szóval ne vegyük figyelembe
					end
				end

				setPokerBoardData(tableId, "dealerSeat", dealerSeat)

				-- Válasszuk ki a vakokat és tegyük fel a vaktéteket
				local smallBlindSeat = false
				local bigBlindSeat = false

				-- Ha csak ketten játszanak (heads-up meccs), az osztó játékos lesz a kisvak
				if sittingInCounter == 2 then
					smallBlindSeat = dealerSeat
				-- Ellenkező esetben keressük meg a következő aktív játékost
				else
					smallBlindSeat = findNextPlayer(tableId, dealerSeat, true) -- Ilyenkor még nincsenek lapjai, szóval ne vegyük figyelembe
				end

				-- A kisvaktól balra lévő első játékos lesz a nagyvak
				bigBlindSeat = findNextPlayer(tableId, smallBlindSeat, true) -- Ilyenkor még nincsenek lapjai, szóval ne vegyük figyelembe

				-- Szinkronizáljuk ezt mindenkinek (small/big blind objectek létrehozása)
				setPokerBoardData(tableId, "smallBlind", smallBlindSeat)
				setPokerBoardData(tableId, "bigBlind", bigBlindSeat)

				-- Felrakjuk a tétjeiket automatikusan, még a lapok kiosztása előtt
				takePlayerPokerCoins(tableId, smallBlindSeat, tablePositions[tableId][7]) -- kisvak-tét
				takePlayerPokerCoins(tableId, bigBlindSeat, tablePositions[tableId][8])	-- nagyvak-tét

				-- Kiosztunk a játékosoknak egy-egy zárt lapot
				if isElement(pokerTablePeds[tableId]) then
					setPedAnimation(pokerTablePeds[tableId], "CASINO", "DEALONE", 800, false, false, false, false)
					setTimer(
						function ()
							if isElement(pokerTablePeds[tableId]) then
								setPedAnimation(pokerTablePeds[tableId], "CASINO", "DEALONE", 800, false, false, false, false)
							end
						end,
					800, sittingInCounter)
				end

				for i = 1, maximumPlayers do
					if isPokerSeatActive(tableId, i, true, false) then -- Ilyenkor még nincsenek lapjai, szóval ne vegyük figyelembe
						setPokerSeatData(tableId, i, "pokerCards", {
							table.remove(pokerDeckCards[tableId]),
							table.remove(pokerDeckCards[tableId])
						})
					end
				end

				-- Első licitkör elindítása (Pre-Flop)
				setPokerBoardData(tableId, "lastPlayer", bigBlindSeat) -- az utolsó játékos akinek lépnie kell, a nagyvak (amíg valaki nem emel)
				actionToNextPlayer(tableId, true) -- megkérjük az első aktív játékost, hogy lépjen
			end
		end
	end
end

function endRound(tableId)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Állítsuk meg az időtúllépést, és a játékos cselekvést
		if playerTimeoutTimers[tableId] then
			if isTimer(playerTimeoutTimers[tableId]) then
				killTimer(playerTimeoutTimers[tableId])
			end

			playerTimeoutTimers[tableId] = nil
		end

		removePokerBoardData(tableId, "currentPlayer")

		-- Rakjuk be a kasszába az ebben a licitkörben felrakott téteket
		resolveSidePots(tableId)

		-- Ha nincs showdown folyamatban
		local showdownActive = getPokerBoardData(tableId, "showdown")

		if not showdownActive then
			-- Ha maradt a fő-kasszában zseton, adjuk oda az első aktív játékosnak
			local mainPot = pokerBoardPots[tableId][1]

			if mainPot then
				if mainPot.amount > 0 then
					local winnerSeat = findNextPlayer(tableId, 0, false, true)

					if winnerSeat then
						givePotToWinner(tableId, winnerSeat)
					end
				end
			end
		end

		-- Készítsük elő az asztalt az új játékra
		prepareNextRound(tableId)
	end
end

function prepareNextRound(tableId, alreadyWaited)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Számoljuk össze azokat a játékosokat, akik még nem dobtál el a lapjaikat
		local remainingPlayers = 0

		for i = 1, maximumPlayers do
			local playerElement = getPokerSeatData(tableId, i, "element")

			if isElement(playerElement) then
				local chipsInPlay = getPokerSeatData(tableId, i, "pokerCoins") or 0

				if chipsInPlay == 0 then
					-- Ha nincs több zsetonja, állítsuk fel az asztaltól
					setPlayerLeave(tableId, i, true)
				else
					remainingPlayers = remainingPlayers + 1
				end
			end
		end

		-- Timerek semlegesítése
		if playerTimeoutTimers[tableId] then
			if isTimer(playerTimeoutTimers[tableId]) then
				killTimer(playerTimeoutTimers[tableId])
			end

			playerTimeoutTimers[tableId] = nil
		end

		if nextRoundTimers[tableId] then
			if isTimer(nextRoundTimers[tableId]) then
				killTimer(nextRoundTimers[tableId])
			end

			nextRoundTimers[tableId] = nil
		end

		-- Ha nincs elég játékos egy új kör kezdéséhez, állítsuk le a játékfolyamatot
		removePokerBoardData(tableId, "currentPlayer")

		if remainingPlayers < minimumPlayers then
			removePokerBoardData(tableId, "gameStage")
			removePokerBoardData(tableId, "boardCards")
			removePokerBoardData(tableId, "smallBlind")
			removePokerBoardData(tableId, "bigBlind")
			removePokerBoardData(tableId, "currentCall")
			removePokerBoardData(tableId, "showdown")
			removePokerBoardData(tableId, "pot")

			for i = 1, maximumPlayers do
				removePokerSeatData(tableId, i, "pokerCards")
				removePokerSeatData(tableId, i, "currentCall")
				removePokerSeatData(tableId, i, "roundCall")
				removePokerSeatData(tableId, i, "win")
			end

			setPokerBoardData(tableId, "lastPlayer", nil)
			setPokerBoardData(tableId, "dealerSeat", nil)
			setPokerBoardData(tableId, "isGameIsOn", false)
		-- Ellenkező esetben, próbáljunk indítani egy új kört
		else
			nextRoundTimers[tableId] = setTimer(
				function ()
					triggerClientEvent("playPokerSound", resourceRoot, tableId, "cardshuff")

					removePokerBoardData(tableId, "gameStage")
					removePokerBoardData(tableId, "boardCards")
					removePokerBoardData(tableId, "smallBlind")
					removePokerBoardData(tableId, "bigBlind")
					removePokerBoardData(tableId, "currentCall")
					removePokerBoardData(tableId, "showdown")
					removePokerBoardData(tableId, "pot")

					for i = 1, maximumPlayers do
						removePokerSeatData(tableId, i, "pokerCards")
						removePokerSeatData(tableId, i, "currentCall")
						removePokerSeatData(tableId, i, "roundCall")
						removePokerSeatData(tableId, i, "win")
					end

					nextRoundTimers[tableId] = setTimer(
						function ()
							setPokerBoardData(tableId, "isGameIsOn", false)
							initializeRoundCheck(tableId, true)
						end,
					8000, 1)
				end,
			alreadyWaited and 100 or 5000, 1)
		end
	end
end

function resolveSidePots(tableId)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Kérjük le a jelenlegi kasszát (azt amelyikbe az új tétek kerülnek)
		local currentPotId = #pokerBoardPots[tableId]
		local currentPot = pokerBoardPots[tableId][currentPotId]

		-- Ha nincs egyetlen pot sem, a játék sem fut, szóval ne is folytassuk
		if not currentPot then
			return
		end

		-- A jelenlegi licitkör legkisebb tétje
		local smallestBet = 0
		-- Jelző, amely megmutatja, hogy az összes tét összege azonos-e
		local allBetsAreEqual = true
		-- Résztvevők száma ebben a licitkörben
		local contributorsCounter = 0

		-- Keressük meg a legkisebb tétet, és ellenőrizzük, hogy a tét összege azonos-e az eddigi legkisebb téttel
		for i = 1, maximumPlayers do
			local playerElement = getPokerSeatData(tableId, i, "element")

			if isElement(playerElement) then
				local currentBet = getPokerSeatData(tableId, i, "currentCall") or 0

				if currentBet > 0 then
					contributorsCounter = contributorsCounter + 1

					if smallestBet == 0 then
						smallestBet = currentBet
					elseif currentBet ~= smallestBet then
						allBetsAreEqual = false

						if currentBet < smallestBet then
							smallestBet = currentBet
						end
					end
				end
			end
		end

		-- Számoljuk össze az előző licitkör résztvevőit
		local previousContributorsCounter = 0

		for seatId in pairs(currentPot.contributors) do
			local playerElement = getPokerSeatData(tableId, seatId, "element")

			if isElement(playerElement) then
				previousContributorsCounter = previousContributorsCounter + 1
			end
		end

		-- Ha a résztvevők száma kevesebb, mint az utolsó licitkörben, hozzunk létre egy új mellékpotot
		if contributorsCounter > 0 and contributorsCounter < previousContributorsCounter then
			table.insert(pokerBoardPots[tableId], {
				amount = 0,
				contributors = {}
			})
			currentPotId = currentPotId + 1
			currentPot = pokerBoardPots[tableId][currentPotId]
		end

		-- Ha az összes tét megegyezik, akkor távolítsuk el a játékosok tétjeit, és adjuk hozzá őket a potba
		if allBetsAreEqual then
			for i = 1, maximumPlayers do
				local playerElement = getPokerSeatData(tableId, i, "element")

				if isElement(playerElement) then
					local currentBet = getPokerSeatData(tableId, i, "currentCall") or 0

					if currentBet > 0 then
						local playerCards = getPokerSeatData(tableId, i, "pokerCards") or {}

						if #playerCards > 0 then
							currentPot.contributors[i] = true
						end

						currentPot.amount = currentPot.amount + currentBet
					end
				end

				removePokerSeatData(tableId, i, "roundCall")
				removePokerSeatData(tableId, i, "currentCall")
			end

			-- Számoljuk össze a kasszákban lévő összegeket és küldjük el a klienseknek
			local potValue = 0

			for i = #pokerBoardPots[tableId], 1, -1 do
				local thisPot = pokerBoardPots[tableId][i]

				if thisPot then
					potValue = potValue + thisPot.amount
				end
			end

			setPokerBoardData(tableId, "pot", potValue)
		else
			-- Ha nem minden tét egyenlő, vonjuk le az egyes játékosok tétjéből az asztal legkisebb tétjének összegét,
			-- adjuk hozzá ezeket a téteket a pothoz, majd hozzunk létre egy új mellékpotot,
			-- és rekurzív módon adjuk hozzá a megmaradt téteket az új pothoz
			for i = 1, maximumPlayers do
				local playerElement = getPokerSeatData(tableId, i, "element")

				if isElement(playerElement) then
					local currentBet = getPokerSeatData(tableId, i, "currentCall") or 0

					if currentBet > 0 then
						local playerCards = getPokerSeatData(tableId, i, "pokerCards") or {}

						if #playerCards > 0 then
							currentPot.contributors[i] = true
						end

						if currentBet <= smallestBet then
							currentPot.amount = currentPot.amount + currentBet
							currentBet = 0
						else
							currentPot.amount = currentPot.amount + smallestBet
							currentBet = currentBet - smallestBet
						end

						removePokerSeatData(tableId, i, "roundCall")

						if currentBet > 0 then
							setPokerSeatData(tableId, i, "currentCall", currentBet, false) -- ne szinkronizáljuk a változást, majd csak a legvégén
						else
							removePokerSeatData(tableId, i, "currentCall") -- nincs több zsetonja, szinkronizálhatjuk
						end
					end
				end
			end

			-- Új mellékpot létrehozása
			table.insert(pokerBoardPots[tableId], {
				amount = 0,
				contributors = {}
			})

			-- Rekurzió
			resolveSidePots(tableId)
		end
	end
end

function actionToNextPlayer(tableId, isFirstAction)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Állítsuk le az időtúllépést
		if playerTimeoutTimers[tableId] then
			if isTimer(playerTimeoutTimers[tableId]) then
				killTimer(playerTimeoutTimers[tableId])
			end

			playerTimeoutTimers[tableId] = nil
		end

		-- Kérjük le a jelenlegi aktív játékost, mint előző aktív játékos
		local oldActiveSeat = getPokerBoardData(tableId, "currentPlayer")

		-- Ha ez az első lépés ebben a licitkörben (pre-flop), a nagyvak volt az utoljára cselekvő játékos
		if isFirstAction then
			oldActiveSeat = getPokerBoardData(tableId, "bigBlind")
		end

		-- Keressük meg a következő játékost, ha van
		local activeSeat = findNextPlayer(tableId, oldActiveSeat)
		local isPhaseEnd = false

		if not activeSeat then
			activeSeat = oldActiveSeat
			isPhaseEnd = true
		else
			local lastPlayerSeat = getPokerBoardData(tableId, "lastPlayer")

			if lastPlayerSeat then
				if not oldActiveSeat then
					isPhaseEnd = true
				elseif oldActiveSeat == activeSeat then
					isPhaseEnd = true
				elseif oldActiveSeat < lastPlayerSeat and lastPlayerSeat < activeSeat then
					isPhaseEnd = true
				elseif activeSeat < oldActiveSeat and oldActiveSeat < lastPlayerSeat then
					isPhaseEnd = true
				elseif lastPlayerSeat < activeSeat and activeSeat < oldActiveSeat then
					isPhaseEnd = true
				end
			end
		end

		-- Lépjünk a licitkör végére ha valami miatt vége van
		if isPhaseEnd then
			execute(endPhase, tableId)
		-- Ellenkező esetben, állítsuk be az aktív játékost
		else
			setPokerBoardData(tableId, "currentPlayer", activeSeat)

			-- Ha ez az első lépés ebben a licitkörben (pre-flop), értesítsük a játékosokat
			if isFirstAction then
				local activePlayer = getPokerSeatData(tableId, activeSeat, "element")
				local otherPlayers = {}

				for playerIndex, playerElement in pairs(getElementsByType("player")) do
					if playerElement ~= activePlayer then
						table.insert(otherPlayers, playerElement)
					end
				end

				triggerClientEvent(otherPlayers, "playPokerSound", resourceRoot, tableId, "saybet")
			end

			playerTimeoutTimers[tableId] = setTimer(setPlayerFolded, interactionTime, 1, tableId, activeSeat, true)
		end
	end
end

function endPhase(tableId)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Állítsuk le az időtúllépést
		if playerTimeoutTimers[tableId] then
			if isTimer(playerTimeoutTimers[tableId]) then
				killTimer(playerTimeoutTimers[tableId])
			end

			playerTimeoutTimers[tableId] = nil
		end

		setPokerBoardData(tableId, "currentPlayer", 0)

		-- Várjunk egy kicsit mielőtt továbblépnénk a következő fázisra
		sleep(1200)

		-- Kérjük le a játékfázis állapotát
		local gameStage = getPokerBoardData(tableId, "gameStage") or 0

		-- Minden egyes licitkör végén, rakjuk be a téteket a potba
		if gameStage <= 4 then
			resolveSidePots(tableId)
			setPokerBoardData(tableId, "currentCall", 0)
		end

		-- Licitkörök
		if gameStage < 3 then
			-- Pre-flop (Rakjunk ki az első 3 lapot az asztalra)
			if gameStage == 0 then
				local boardCards = {}

				for i = 1, 3 do
					boardCards[i] = table.remove(pokerDeckCards[tableId])
				end

				setPokerBoardData(tableId, "boardCards", boardCards)
			-- Flop / Turn / River (Rakjunk ki +1 lapot az asztalra)
			elseif gameStage > 0 then
				local boardCards = getPokerBoardData(tableId, "boardCards") or {}

				if #boardCards < 5 then
					boardCards[#boardCards + 1] = table.remove(pokerDeckCards[tableId])
				end

				setPokerBoardData(tableId, "boardCards", boardCards)
			end

			setPokerBoardData(tableId, "gameStage", gameStage + 1)

			-- Várjunk egy kicsit a lapok lehelyezése, és a coinok animálása után
			sleep(1000)

			-- Számoljuk össze, hogy hány játékosnak vannak még lapjai, és hányan vannak All-In
			local allInCounter = 0
			local inHandCounter = 0

			for i = 1, maximumPlayers do
				local playerElement = getPokerSeatData(tableId, i, "element")

				if isElement(playerElement) then
					local pokerCoins = getPokerSeatData(tableId, i, "pokerCoins") or 0
					local pokerCards = getPokerSeatData(tableId, i, "pokerCards") or {}

					if pokerCoins == 0 then
						allInCounter = allInCounter + 1
					end

					if #pokerCards > 0 then
						inHandCounter = inHandCounter + 1
					end
				end
			end

			-- Keressük meg a következő játékost
			local dealerSeat = getPokerBoardData(tableId, "dealerSeat")
			local newActiveSeat = false

			-- Ha egy játékos kivételével mindenki All-In van, a coinok kihagyásával keresünk
			if allInCounter >= inHandCounter - 1 then
				newActiveSeat = findNextPlayer(tableId, dealerSeat, false, true)
			-- Ellenkező esetben, kell legyen coinja is a játékosnak
			else
				newActiveSeat = findNextPlayer(tableId, dealerSeat)
			end

			-- Állítsuk be az utoljára cselekvő játékost az új aktív játékos előtti aktív játékosra
			setPokerBoardData(tableId, "lastPlayer", findPreviousPlayer(tableId, newActiveSeat))

			-- Ha egy játékos kivételével mindenki All-In van, lerakjuk a hiányzó lapokat az asztalra és átugrunk a mutatásra (showdown)
			if allInCounter >= inHandCounter - 1 then
				local boardCards = getPokerBoardData(tableId, "boardCards") or {}

				if #boardCards < 5 then
					local numOfCardsRequired = 5 - #boardCards

					if numOfCardsRequired > 0 then
						for i = 1, numOfCardsRequired do
							boardCards[#boardCards + 1] = table.remove(pokerDeckCards[tableId])
						end
					end

					setPokerBoardData(tableId, "boardCards", boardCards)
				end

				setPokerBoardData(tableId, "gameStage", 3)
				execute(endPhase, tableId)
			-- Ellenkező esetben, beállítjuk az új aktív játékost, hogy tudjon cselekedni
			else
				setPokerBoardData(tableId, "currentPlayer", newActiveSeat)
			end
		-- Mutatás (a játékosok megmutatják lapjaikat)
		elseif gameStage == 3 then
			local showDown = getPokerBoardData(tableId, "showdown")

			if not showDown then
				triggerClientEvent("playPokerSound", resourceRoot, tableId, "sayletsee")

				setPokerBoardData(tableId, "gameStage", 4)
				setPokerBoardData(tableId, "showdown", true)

				execute(determineWinners, tableId)
			end
		end
	end
end

function determineWinners(tableId)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		-- Várunk egy kicsit, hogy ne túl gyorsan történjenek az események
		sleep(3000)

		-- Kiértékeljük a játékosok kezeit
		local boardCards = getPokerBoardData(tableId, "boardCards") or {}
		local evaluatedHands = {}

		for i = 1, maximumPlayers do
			local playerElement = getPokerSeatData(tableId, i, "element")

			if isElement(playerElement) then
				local pokerCards = getPokerSeatData(tableId, i, "pokerCards") or {}

				if #pokerCards > 0 then
					evaluatedHands[i] = {evaluateResult(pokerCards, boardCards)}
				end
			end
		end

		-- Összeszedjük a kasszák nyerteseit
		local winnedRewards = {}

		for i = #pokerBoardPots[tableId], 1, -1 do
			local thisPot = pokerBoardPots[tableId][i]

			if thisPot then
				local winnerList = {}
				local bestRating = 0

				for j = 1, maximumPlayers do
					local playerElement = getPokerSeatData(tableId, j, "element")

					if isElement(playerElement) then
						local evaluatedHand = evaluatedHands[j]

						if evaluatedHand then
							-- Ha a játékos részt vett ebben a potban
							if thisPot.contributors[j] then
								-- Ha a keze értéke nagyobb mint az eddigi legnagyobb, ő lesz az új egyedüli nyertes
								if evaluatedHand[2] > bestRating then
									bestRating = evaluatedHand[2]
									winnerList = {j}
								-- Ellenkező esetben, ha a kéz erőssége megegyezik az eddigi legjobbal, hozzáadjuk őt is a nyertesekhez
								elseif evaluatedHand[2] == bestRating then
									table.insert(winnerList, j)
								end
							end
						end
					end
				end

				-- Összeállítjuk a nyerteseket egy új táblába, // [ülőhely] = nyeremény // felépítésben
				local winnersCount = #winnerList

				if winnersCount > 0 then
					-- Ha csak egy nyertes van, ővé az egész pot
					if winnersCount == 1 then
						local winnerSeat = winnerList[1]

						if not winnedRewards[winnerSeat] then
							winnedRewards[winnerSeat] = thisPot.amount
						else
							winnedRewards[winnerSeat] = winnedRewards[winnerSeat] + thisPot.amount
						end
					-- Ellenkező esetben, osztoznak a pot összegén
					else
						local averageAmount = math.floor(thisPot.amount / winnersCount)

						if averageAmount > 0 then
							for j = 1, winnersCount do
								local winnerSeat = winnerList[j]

								if not winnedRewards[winnerSeat] then
									winnedRewards[winnerSeat] = averageAmount
								else
									winnedRewards[winnerSeat] = winnedRewards[winnerSeat] + averageAmount
								end
							end
						end
					end
				end
			end
		end

		-- Kiosztjuk a nyereményeket, kis késleltetésekkel (az animálások miatt)
		local remainingDistribution = 0

		for winnerSeat in pairs(winnedRewards) do
			remainingDistribution = remainingDistribution + 1
		end

		if remainingDistribution > 0 then
			for winnerSeat, rewardAmount in pairs(winnedRewards) do
				local winnerPlayer = getPokerSeatData(tableId, winnerSeat, "element")

				if isElement(winnerPlayer) then
					local playerName = getElementData(winnerPlayer, "visibleName"):gsub("_", " ")
					local pokerCoins = getPokerSeatData(tableId, winnerSeat, "pokerCoins") or 0

					pokerCoins = pokerCoins + rewardAmount

					setPokerSeatData(tableId, winnerSeat, "pokerCoins", pokerCoins)
					setPokerSeatData(tableId, winnerSeat, "win", rewardAmount)

					setElementData(winnerPlayer, "playerIcons", {"plus", rewardAmount})

					if playerName then
						local evaluatedHand = evaluatedHands[winnerSeat]

						-- (A SeeMTA-n ha már csak 2 játékos játszik, nem írja, hogy a nyerteseknek milyen kezeik voltak [De az rossz, szóval itt írja])
						if evaluatedHand then
							addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffNyeremény: " .. thousandsStepper(rewardAmount) .. " Coin (" .. evaluatedHand[1] .. ")", tableId)
						else
							addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffNyeremény: " .. thousandsStepper(rewardAmount) .. " Coin", tableId)
						end
					end

					triggerClientEvent(winnerPlayer, "playPokerSound", resourceRoot, tableId, "saywin")

					-- Minden egyes kiosztás között várunk egy kicsit
					if remainingDistribution > 1 then
						sleep(1200)
					end
				end

				remainingDistribution = remainingDistribution - 1
			end

			-- Ha befejeztük a nyeremények kiosztását, várunk még egy pár pillanatot mielőtt új játék kezdődne
			sleep(5000)
		-- Ha nincsenek nyertesek, akkor is várunk egy kicsit az új kör kezdetére
		else
			sleep(3000)
		end

		-- Előkészítjük az új kört
		prepareNextRound(tableId, true)
	end
end

function givePotToWinner(tableId, winnerSeat)
	local pokerTable = tablePositions[tableId]

	if pokerTable then
		local playerElement = getPokerSeatData(tableId, winnerSeat, "element")

		if isElement(playerElement) then
			local rewardAmount = getPokerBoardData(tableId, "pot") or 0

			-- Ha a kassza nem üres, odaadjuk a nyertesnek
			if rewardAmount > 0 then
				local playerName = getElementData(playerElement, "visibleName"):gsub("_", " ")
				local pokerCoins = getPokerSeatData(tableId, winnerSeat, "pokerCoins") or 0

				pokerCoins = pokerCoins + rewardAmount

				setPokerSeatData(tableId, winnerSeat, "pokerCoins", pokerCoins)
				setPokerSeatData(tableId, winnerSeat, "win", rewardAmount)

				setElementData(playerElement, "playerIcons", {"plus", rewardAmount})

				if playerName then
					addPokerChatLine("#3d7abc[" .. playerName .. "]: #ffffffNyeremény: " .. thousandsStepper(rewardAmount) .. " Coin", tableId)
				end

				triggerClientEvent(playerElement, "playPokerSound", resourceRoot, tableId, "saywin")
			end
		end

		-- Kiürítjük a kasszákat
		pokerBoardPots[tableId] = {}
		setPokerBoardData(tableId, "pot", 0)
	end
end

function evaluateResult(playerCards, boardCards)
	local evaluationRank = false
	local evaluationName = ""
	local evaluationCards = {}

	-- Összerakjuk a zárt és közös lapokat egy táblába
	local mergedCards = {}

	for i = 1, #playerCards do
		mergedCards[i] = playerCards[i]
	end

	for i = 1, #boardCards do
		mergedCards[#mergedCards + 1] = boardCards[i]
	end

	-- Sorrendezzük a játékos lapjait a lapok értéke szerint, csökkenő sorrendben
	table.sort(mergedCards,
		function (a, b)
			if a[1] > b[1] then
				return true
			elseif a[1] <= b[1] then
				return false
			end
		end
	)

	-- Megkezdjük az értékelést
	local flushesOfCards    = {}
	local straightsOfCards  = {}
	local pairsOfCards      = {}

	for i = 1, #cardSuits do
		flushesOfCards[i] = {}
	end

	-- A legelső kártyát a loop előtt berakjuk a megfelelő táblákba
	local theFirstCard = mergedCards[1]

	table.insert(flushesOfCards[theFirstCard[2]], theFirstCard)
	table.insert(straightsOfCards, theFirstCard)

	-- A többi kártyát pedig leellenőrizzük
	for i = 2, 7 do
		local currentCard = mergedCards[i]
		local currentCardValue = currentCard[1]

		local previousCard = mergedCards[i - 1]
		local previousCardValue = previousCard[1]

		table.insert(flushesOfCards[currentCard[2]], currentCard)

		-- Ha az aktuális érték eggyel kisebb, mint az előző kártya értéke, adjuk hozzá a sorhoz
		if currentCardValue + 1 == previousCardValue then
			table.insert(straightsOfCards, currentCard)
		-- Ha nem kisebb eggyel és nem is egyenlő, kezdjük elölről a sort
		elseif currentCardValue ~= previousCardValue then
			if #straightsOfCards < 5 then
				straightsOfCards = {currentCard}
			end
		-- Ha az értékek megegyeznek, hozzáadjuk a párokhoz
		elseif currentCardValue == previousCardValue then
			if not pairsOfCards[currentCardValue] then
				pairsOfCards[currentCardValue] = {previousCard, currentCard}
			else
				table.insert(pairsOfCards[currentCardValue], currentCard)
			end
		end
	end

	-- Ellenőrizzük a sort
	if #straightsOfCards >= 4 then
		-- Ha az utolsó kártya a sorban Deuce(2), és van egy Ász(14) a játékos lapjai közt, adjuk hozzá a sorokhoz
		if straightsOfCards[#straightsOfCards][1] == 1 and theFirstCard[1] == 13 then
			table.insert(straightsOfCards, theFirstCard)
		end

		-- Ha megvan a sorunk, változtassuk meg a kiértékelést
		if #straightsOfCards >= 5 then
			evaluationRank = handRankings.STRAIGHT
			evaluationName = evaluationNames.STRAIGHT
			evaluationCards = {}

			for i = 1, 5 do
				evaluationCards[i] = straightsOfCards[i]
			end
		end
	end

	-- Ellenőrizzük a flösst
	for i = 1, #flushesOfCards do
		local flushCards = flushesOfCards[i]

		-- Ha megvan az öt azonos színű lap
		if #flushCards >= 5 then
			-- Ha a kiértékelés eddig sor volt, ellenőrizzük, hogy színsor-e
			if evaluationRank == handRankings.STRAIGHT then
				local straightFlush = {flushCards[1]}

				for j = 2, #flushCards do
					local currentCard = flushCards[j]
					local currentCardValue = currentCard[1]

					local previousCard = flushCards[j - 1]
					local previousCardValue = previousCard[1]

					-- Ha az aktuális érték eggyel kisebb, mint az előző kártya értéke, adjuk hozzá a színsorhoz
					if currentCardValue + 1 == previousCardValue then
						table.insert(straightFlush, currentCard)
					-- Ha nem kisebb eggyel és nem is egyenlő, kezdjük elölről a színsort
					elseif currentCardValue ~= previousCardValue then
						if #straightFlush < 5 then
							straightFlush = {currentCard}
						end
					end

					-- Ha van elég lap, állítsuk meg a loopot
					if #straightFlush >= 5 then
						break
					end
				end

				-- Nézzük meg, hogy van-e Ász a játékos lapjai közt
				local isAceFound = false

				for j = 1, #mergedCards do
					-- Ha a kártya értéke Ász, és a színe ugyan az mint amit jelenleg ellenőrzünk
					if mergedCards[j][1] == 13 and mergedCards[j][2] == i then
						isAceFound = true
						break
					end
				end

				-- Ha csak 4 egymást követő értékű lapunk van
				if #straightFlush == 4 then
					-- De az utolsó kártya a sorban Deuce(2), és van Ászunk, adjunk hozzá egy Ászt a színsorhoz
					if straightFlush[#straightFlush][1] == 1 and isAceFound then
						table.insert(straightFlush, {13, i})
					end
				end

				-- Ha megvan a sorunk, változtassuk meg a kiértékelést
				if #straightFlush == 5 then
					evaluationCards = straightFlush

					-- Ha az első kártya értéke Ász, nincs miről beszélni, ez egy Royal Flöss
					if evaluationCards[1][1] == 13 then
						evaluationRank = handRankings.ROYAL_FLUSH
						evaluationName = evaluationNames.ROYAL_FLUSH
					else
						evaluationRank = handRankings.STRAIGHT_FLUSH
						evaluationName = evaluationNames.STRAIGHT_FLUSH
					end
				end
			end

			-- Ha nem találtunk színsort, változtassuk meg a kiértékelést flössre
			if evaluationRank ~= handRankings.ROYAL_FLUSH and evaluationRank ~= handRankings.STRAIGHT_FLUSH then
				evaluationRank = handRankings.FLUSH
				evaluationName = evaluationNames.FLUSH
				evaluationCards = {}

				for i = 1, 5 do
					evaluationCards[i] = flushCards[i]
				end
			end

			-- Több sor nem lehetséges, szóval álljunk is meg
			break
		end
	end

	-- Ha nem találtunk sort, se flösst, ellenőrizzük le a párokat
	if not evaluationRank then
		-- Számoljuk össze, hogy hány párt találtunk, és csináljunk egy referencia táblát
		local numberOfPairs = 0
		local pairKeys = {}

		for cardRank in pairs(pairsOfCards) do
			numberOfPairs = numberOfPairs + 1
			pairKeys[numberOfPairs] = cardRank
		end

		-- Rendezzük sorrendbe a párok referenciáit
		table.sort(pairKeys)

		-- Ha találtunk párokat
		if numberOfPairs > 0 then
			local kickersCounter = 0

			-- Ha összesen csak egy párt találtunk
			if numberOfPairs == 1 then
				local maximumKicker = 0

				-- Változtassuk meg a kiértékelt kártyákat a párokra
				evaluationCards = pairsOfCards[pairKeys[1]]

				-- Két azonos értékű lap, egy pár
				if #evaluationCards == 2 then
					evaluationRank = handRankings.ONE_PAIR
					evaluationName = evaluationNames.ONE_PAIR
					maximumKicker = 3
				-- Három azonos értékű lap, drill
				elseif #evaluationCards == 3 then
					evaluationRank = handRankings.THREE_OF_A_KIND
					evaluationName = evaluationNames.THREE_OF_A_KIND
					maximumKicker = 2
				-- Négy azonos értékű lap, póker
				elseif #evaluationCards == 4 then
					evaluationRank = handRankings.FOUR_OF_A_KIND
					evaluationName = evaluationNames.FOUR_OF_A_KIND
					maximumKicker = 1
				end

				-- Adjuk hozzá a kisérőket a kiértékelt kártyákhoz
				for i = 1, #mergedCards do
					local currentCard = mergedCards[i]

					if currentCard[1] ~= evaluationCards[1][1] then
						table.insert(evaluationCards, currentCard)
						kickersCounter = kickersCounter + 1
					end

					if kickersCounter >= maximumKicker then
						break
					end
				end
			--  Ha összesen két párt találtunk
			elseif numberOfPairs == 2 then
				local firstPairRank = pairKeys[1]
				local secondPairRank = pairKeys[2]

				-- Adjuk hozzá a kiértékelt kártyákhoz a legnagyobb értékű párt
				if #pairsOfCards[firstPairRank] > #pairsOfCards[secondPairRank] or (#pairsOfCards[firstPairRank] == #pairsOfCards[secondPairRank] and firstPairRank > secondPairRank) then
					evaluationCards = pairsOfCards[firstPairRank]
					table.remove(pairKeys, 1)
					firstPairRank = pairKeys[1]
				else
					evaluationCards = pairsOfCards[secondPairRank]
					table.remove(pairKeys, 2)
					firstPairRank = pairKeys[1]
				end

				-- Ha a legnagyobb párnak 2 kártyája van, két pár
				if #evaluationCards == 2 then
					evaluationRank = handRankings.TWO_PAIRS
					evaluationName = evaluationNames.TWO_PAIRS

					-- Adjuk hozzá a másik két kártyát a kiértékelt kártyákhoz
					for i = 1, 2 do
						table.insert(evaluationCards, pairsOfCards[firstPairRank][i])
					end

					-- Adjunk hozzá egy kísérő lapot
					for i = 1, #mergedCards do
						local currentCard = mergedCards[i]

						if currentCard[1] ~= evaluationCards[1][1] and currentCard[1] ~= evaluationCards[3][1] then
							table.insert(evaluationCards, currentCard)
							kickersCounter = kickersCounter + 1
						end

						if kickersCounter >= 1 then
							break
						end
					end
				-- Ha a legnagyobb párnak 3 kártyája van, full
				elseif #evaluationCards == 3 then
					evaluationRank = handRankings.FULL_HOUSE
					evaluationName = evaluationNames.FULL_HOUSE

					-- Adjuk hozzá a másik két kártyát a kiértékelt kártyákhoz
					for i = 1, 2 do
						table.insert(evaluationCards, pairsOfCards[firstPairRank][i])
					end
				-- Ha a legnagyobb párnak 4 kártyája van, póker
				else
					evaluationRank = handRankings.FOUR_OF_A_KIND
					evaluationName = evaluationNames.FOUR_OF_A_KIND

					-- Adjunk hozzá egy kísérő lapot
					for i = 1, #mergedCards do
						local currentCard = mergedCards[i]

						if currentCard[1] ~= evaluationCards[1][1] then
							table.insert(evaluationCards, currentCard)
							kickersCounter = kickersCounter + 1
						end

						if kickersCounter >= 1 then
							break
						end
					end
				end
			-- Ha összesen 3 párt találtunk
			else
				-- Ha van egy pár három kártyával, akkor az a legnagyobb pár (full)
				for cardRank in pairs(pairsOfCards) do
					if #pairsOfCards[cardRank] == 3 then
						evaluationRank = handRankings.FULL_HOUSE
						evaluationName = evaluationNames.FULL_HOUSE
						evaluationCards = pairsOfCards[cardRank]
						pairsOfCards[cardRank] = nil
						break
					end
				end

				-- Egyébként három pár és két kártya van, tehát keressük meg a legnagyobbat (két pár)
				local pairRanks = {pairKeys[1], pairKeys[2], pairKeys[3]}

				if #evaluationCards == 0 then
					evaluationRank = handRankings.TWO_PAIRS
					evaluationName = evaluationNames.TWO_PAIRS

					if pairRanks[1] > pairRanks[2] then
						if pairRanks[1] > pairRanks[3] then
							evaluationCards = pairsOfCards[pairRanks[1]]
							table.remove(pairKeys, 1)
						else
							evaluationCards = pairsOfCards[pairRanks[3]]
							table.remove(pairKeys, 3)
						end
					else
						if pairRanks[2] > pairRanks[3] then
							evaluationCards = pairsOfCards[pairRanks[2]]
							table.remove(pairKeys, 2)
						else
							evaluationCards = pairsOfCards[pairRanks[3]]
							table.remove(pairKeys, 3)
						end
					end
				end

				-- Adjuk hozzá a második legnagyobb párt a kiértékelt kártyákhoz
				if pairKeys[1] > pairKeys[2] then
					for i = 1, 2 do
						table.insert(evaluationCards, pairsOfCards[pairKeys[1]][i])
					end
				else
					for i = 1, 2 do
						table.insert(evaluationCards, pairsOfCards[pairKeys[2]][i])
					end
				end

				-- Ha a legnagyobb párnak csak 2 kártyája van, adjunk hozzá egy kísérőt
				if evaluationRank == handRankings.TWO_PAIRS then
					for i = 1, #mergedCards do
						local currentCard = mergedCards[i]

						if currentCard[1] ~= evaluationCards[1][1] and currentCard[1] ~= evaluationCards[3][1] then
							table.insert(evaluationCards, currentCard)
							kickersCounter = kickersCounter + 1
						end

						if kickersCounter >= 1 then
							break
						end
					end
				end
			end
		end
	end

	-- Ha nem találtunk eddig kategóriát, akkor ez biza magas lap
	if not evaluationRank then
		evaluationRank = handRankings.HIGH_HAND
		evaluationName = evaluationNames.HIGH_HAND
		evaluationCards = {}

		for i = 1, 5 do
			evaluationCards[i] = mergedCards[i]
		end
	end

	-- Értékeljük ki a lapokat
	local evaluationRate = 0
	local evaluatedRanks = {}

	for i = 1, 5 do
		evaluatedRanks[i] = evaluationCards[i][1]
	end

	evaluationRate = evaluationRate + evaluatedRanks[1] * 30941
	evaluationRate = evaluationRate + evaluatedRanks[2] * 2380
	evaluationRate = evaluationRate + evaluatedRanks[3] * 183
	evaluationRate = evaluationRate + evaluatedRanks[4] * 14
	evaluationRate = evaluationRate + evaluatedRanks[5]

	if secondaryValues[evaluationRank] then
		evaluationRate = evaluationRate + secondaryValues[evaluationRank]
	end

	return evaluationName, evaluationRate
end

function table:shuffle()
	local iterations = #self
	local j

	for i = iterations, 2, -1 do
		j = math.random(i)
		self[i], self[j] = self[j], self[i]
	end
end
