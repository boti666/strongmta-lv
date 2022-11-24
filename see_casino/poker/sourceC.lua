local activeButtonOldC = false

local screenWidth, screenHeight = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function resp(value)
	return value * responsiveMultipler
end

function respc(value)
	return math.ceil(value * responsiveMultipler)
end

function reMap(value, low1, high1, low2, high2)
	return (value - low1) * (high2 - low2) / (high1 - low1) + low2
end

local fontSizeMultipler = reMap(screenWidth, 1024, 1920, 0.7, 1)

local panelState = false
local panelWidth = respc(350)
local panelHeight = respc(220)
local panelPosX = (screenWidth - panelWidth) / 2
local panelPosY = (screenHeight - panelHeight) / 2
local panelStage = 1

local isMoving = false
local moveDifferenceX = 0
local moveDifferenceY = 0

local pokerTableModelId = 4334
local createdTableObjects = {}

local nearbyTableId = false
local nearbyOccupiedSeats = {}

local joinedTableId = false
local isHudControlled = false

local buttons = {}
local activeButton = false
local oldActiveButton = false

local sliderClickX = false
local sliderMoveX = false
local sliderValue = 0
local sliderAmount = 0
local sliderInputText = ""
local sliderInputInUse = false
local sliderInputState = {}

local mySlotCoins = 0
local myPokerCoins = 0
local myCurrentBet = 0
local myPokerTurn = false

local pokerPotAmount = 0
local pokerPlayers = {}
local pokerBoardCards = {}
local pokerGameStage = -1
local pokerHighestBet = 0
local pokerCurrentPlayer = 0
local pokerShowDown = {}

local pokerChatLines = {}
local pokerChatOffset = 0
local pokerChatMaxLine = 7

local chatLineHeight = respc(18)
local chatWidth = respc(350)
local chatHeight = chatLineHeight * pokerChatMaxLine
local chatPosX = respc(20)
local chatPosY = screenHeight - chatHeight - respc(30)

local countdownData = {}
local countdownSound = false

local cardTextures = {
	dxCreateTexture("files/cards/backs2.png"),
	dxCreateTexture("files/cards/backs3.png"),
	dxCreateTexture("files/cards/backs.png")
}

local streamedPokerTables = {}

local realCoinAmounts = {}
local realCoinObjects = {}
local realCoinObjectsEx = {}
local realCoinTimers = {}

local cardLineRenderTargets = {}
local realPlayerCardRenderTargets = {}
local realPlayerCards = {}

local smallBlindObjects = {}
local smallBlindObjectModelId = 1860
local bigBlindObjects = {}
local bigBlindObjectModelId = 1859

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		setElementData(localPlayer, "pokerTableId", false)
		setElementData(localPlayer, "pokerTableSeat", false)

		mySlotCoins = getElementData(localPlayer, "char.slotCoins") or 0
		myPokerCoins = 0

		setTimer(triggerServerEvent, math.random(2000, 4000), 1, "requestPokerTables", resourceRoot)
	end
)

addEvent("requestPokerTables", true)
addEventHandler("requestPokerTables", resourceRoot,
	function (storedTables)
		if storedTables then
			tablePositions = storedTables
			generateTables()

			for tableId, tableInfo in pairs(tablePositions) do
				createdTableObjects[tableId] = createObject(pokerTableModelId, tableInfo[1], tableInfo[2], tableInfo[3], 0, 0, tableInfo[4])

				if isElement(createdTableObjects[tableId]) then
					setElementInterior(createdTableObjects[tableId], tableInfo[5])
					setElementDimension(createdTableObjects[tableId], tableInfo[6])
					setElementData(createdTableObjects[tableId], "pokerTableObjectId", tableId)
				end
			end

			for playerIndex, playerElement in pairs(getElementsByType("player")) do
				local pokerTableId = getElementData(playerElement, "pokerTableId")
				local pokerTableSeat = getElementData(playerElement, "pokerTableSeat")

				if pokerTableId then
					if pokerTableSeat then
						local pokerCards = getPokerSeatData(pokerTableId, pokerTableSeat, "pokerCards") or {}

						if not realPlayerCards[pokerTableId] then
							realPlayerCards[pokerTableId] = {}
						end

						if #pokerCards ~= 0 then
							realPlayerCards[pokerTableId][pokerTableSeat] = {0, 2}
						else
							realPlayerCards[pokerTableId][pokerTableSeat] = nil
						end
					end
				end
			end
		end
	end
)

addEvent("createPokerTable", true)
addEventHandler("createPokerTable", resourceRoot,
	function (tableId, tableInfo)
		if tableId then
			if tableInfo then
				tablePositions[tableId] = tableInfo
				generateTables(tableId)
				createdTableObjects[tableId] = createObject(pokerTableModelId, tableInfo[1], tableInfo[2], tableInfo[3], 0, 0, tableInfo[4])
				if isElement(createdTableObjects[tableId]) then
					setElementInterior(createdTableObjects[tableId], tableInfo[5])
					setElementDimension(createdTableObjects[tableId], tableInfo[6])
					setElementData(createdTableObjects[tableId], "pokerTableObjectId", tableId)
				end
			end
		end
	end
)

addEvent("deletePokerTable", true)
addEventHandler("deletePokerTable", resourceRoot,
	function (tableId)
		if tableId then
			if tablePositions[tableId] then
				if joinedTableId then
					if joinedTableId == tableId then
						closeTheGame()
					end
				end

				destroyPokerTableStuff(tableId)

				if createdTableObjects[tableId] then
					if isElement(createdTableObjects[tableId]) then
						destroyElement(createdTableObjects[tableId])
					end

					createdTableObjects[tableId] = nil
				end

				tablePositions[tableId] = nil
				realGuiPositions[tableId] = nil
				realBlindPositions[tableId] = nil
				realCoinPositions[tableId] = nil
				realPedPositions[tableId] = nil
				realDealerPositions[tableId] = nil
				cardLinePositions[tableId] = nil
				realPlayerCardPositions[tableId] = nil
				realPlayerCards[tableId] = nil
				realCoinAmounts[tableId] = nil

				if realCoinObjects[tableId] then
					for seatId = 1, maximumPlayers * 2 do
						local theCoinObjects = realCoinObjects[tableId][seatId]
						if theCoinObjects then
							for coinId = 1, #theCoinObjects do
								if isElement(theCoinObjects[coinId]) then
									destroyElement(theCoinObjects[coinId])
								end
							end
						end

						local theWinCoinObjects = realCoinObjects[tableId]["win" .. seatId]
						if theWinCoinObjects then
							for coinId = 1, #theWinCoinObjects do
								if isElement(theWinCoinObjects[coinId]) then
									destroyElement(theWinCoinObjects[coinId])
								end
							end
						end
					end

					local thePotCoinObjects = realCoinObjects[tableId]["pot"]
					if thePotCoinObjects then
						for i = 1, #thePotCoinObjects do
							if isElement(thePotCoinObjects[i]) then
								destroyElement(thePotCoinObjects[i])
							end
						end
					end

					realCoinObjects[tableId] = nil
				end

				if realCoinObjectsEx[tableId] then
					for _, objectElement in pairs(realCoinObjectsEx[tableId]) do
						if isElement(objectElement) then
							destroyElement(objectElement)
						end
					end
					realCoinObjectsEx[tableId] = nil
				end

				if realCoinTimers[tableId] then
					for _, timerElement in pairs(realCoinTimers[tableId]) do
						if isTimer(timerElement) then
							killTimer(timerElement)
						end
					end
					realCoinTimers[tableId] = nil
				end
			end
		end
	end
)

addEvent("updatePokerTable", true)
addEventHandler("updatePokerTable", resourceRoot,
	function (tableId, tableInfo)
		if tableId then
			if tableInfo then
				tablePositions[tableId] = tableInfo
			end
		end
	end
)

local pokerPlacement = false
local pokerPlacementValues = false

addCommandHandler("createpoker",
	function (commandName, smallBlind, bigBlind, minEntry, maxEntry)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			if not pokerPlacement then
				smallBlind = tonumber(smallBlind)
				bigBlind = tonumber(bigBlind)
				minEntry = tonumber(minEntry)
				maxEntry = tonumber(maxEntry)

				if not (smallBlind and bigBlind and minEntry and maxEntry) then
					outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Kisvak] [Nagyvak] [Min. beülõ] [Max. beülõ]", 255, 255, 255, true)
				else
					if isElement(pokerPlacement) then
						destroyElement(pokerPlacement)
					end

					pokerPlacementValues = {smallBlind, bigBlind, minEntry, maxEntry}
					pokerPlacement = createObject(pokerTableModelId, 0, 0, 0)

					setElementCollisionsEnabled(pokerPlacement, false)
					setElementAlpha(pokerPlacement, 175)
					setElementInterior(pokerPlacement, getElementInterior(localPlayer))
					setElementDimension(pokerPlacement, getElementDimension(localPlayer))

					addEventHandler("onClientRender", root, renderPokerPlacement)

					outputChatBox("#3d7abc[StrongMTA]: #ffffffPókerasztal létrehozás #ffffffmód #3d7abcbekapcsolva!", 255, 255, 255, true)
					outputChatBox("#3d7abc[StrongMTA]: #ffffffAz asztal #3d7abclerakásához #ffffffnyomd meg az #3d7abcBAL ALT #ffffffgombot!", 255, 255, 255, true)
					outputChatBox("#3d7abc[StrongMTA]: #ffffffA #d75959kilépéshez #ffffffírd be a #d75959/createpoker #ffffffparancsot!", 255, 255, 255, true)
				end
			else
				removeEventHandler("onClientRender", root, renderPokerPlacement)

				if isElement(pokerPlacement) then
					destroyElement(pokerPlacement)
				end

				pokerPlacement = false
				pokerPlacementValues = false

				outputChatBox("#3d7abc[StrongMTA]: #ffffffPókerasztal létrehozás #ffffffmód #d75959kikapcsolva!", 255, 255, 255, true)
			end
		end
	end
)

function renderPokerPlacement()
	if isElement(pokerPlacement) then
		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
		local playerRotX, playerRotY, playerRotZ = getElementRotation(localPlayer)

		setElementPosition(pokerPlacement, playerPosX, playerPosY, playerPosZ - 0.5)
		setElementRotation(pokerPlacement, 0, 0, playerRotZ + 90)
	end

	if pokerPlacementValues then
		if getKeyState("lalt") then
			local objectPosX, objectPosY, objectPosZ = getElementPosition(pokerPlacement)
			local objectRotX, objectRotY, objectRotZ = getElementRotation(pokerPlacement)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)

			triggerServerEvent("createPoker", resourceRoot, {
				posX = objectPosX,
				posY = objectPosY,
				posZ = objectPosZ,
				rotZ = objectRotZ,
				interior = playerInterior,
				dimension = playerDimension,
				smallBlind = pokerPlacementValues[1],
				bigBlind = pokerPlacementValues[2],
				minEntry = pokerPlacementValues[3],
				maxEntry = pokerPlacementValues[4]
			})

			removeEventHandler("onClientRender", root, renderPokerPlacement)

			if isElement(pokerPlacement) then
				destroyElement(pokerPlacement)
			end

			pokerPlacement = false
			pokerPlacementValues = false
		end
	end
end

addCommandHandler("nearbypoker",
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local nearbyPokerTables = {}
			local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)

			for tableId, tableInfo in pairs(tablePositions) do
				local distanceBetween = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, tableInfo[1], tableInfo[2], tableInfo[3])
				if distanceBetween <= 15 then
					if tableInfo[5] == playerInterior and tableInfo[6] == playerDimension then
						table.insert(nearbyPokerTables, {tableId, distanceBetween})
					end
				end
			end

			if #nearbyPokerTables > 0 then
				outputChatBox("#3d7abc[StrongMTA]: #ffffffA közeledben lévõ pókerasztalok (15 yard):", 255, 255, 255, true)

				for arrayIndex, arrayInfo in ipairs(nearbyPokerTables) do
					outputChatBox("    * #3d7abcID: #ffffff" .. arrayInfo[1] .. " <> #3d7abcTávolság: #ffffff" .. arrayInfo[2], 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[StrongMTA]: #ffffffA közeledben nem található egyetlen pókerasztal sem.", 255, 255, 255, true)
			end
		end
	end
)

addEventHandler("onClientElementColShapeHit", localPlayer,
	function (colShapeElement, matchingDimension)
		if isElement(colShapeElement) then
			if matchingDimension then
				if source == localPlayer then
					local occupiedVehicle = getPedOccupiedVehicle(localPlayer)

					if not occupiedVehicle then
						local pokerTableId = getElementData(colShapeElement, "pokerTableId")

						if pokerTableId then
							local occupiedSeats = getElementData(colShapeElement, "occupiedSeats")

							nearbyTableId = pokerTableId

							if occupiedSeats then
								nearbyOccupiedSeats = {}

								for arrayIndex, seatId in ipairs(occupiedSeats) do
									nearbyOccupiedSeats[seatId] = true
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementColShapeLeave", localPlayer,
	function (colShapeElement, matchingDimension)
		if isElement(colShapeElement) then
			if matchingDimension then
				if source == localPlayer then
					local pokerTableId = getElementData(colShapeElement, "pokerTableId")

					if pokerTableId then
						nearbyTableId = false
					end
				end
			end
		end
	end
)

function createFonts()
	destroyFonts(true)

	if not isHudControlled then
		exports.see_hud:hideHUD()
		exports.see_hud:setPokerMode(true)
		isHudControlled = true
	end
end

function destroyFonts(state)
	if not state then
		if isHudControlled then
			isHudControlled = false
			exports.see_hud:showHUD()
			exports.see_hud:setPokerMode(false)
		end
	end
end

addEventHandler("onClientResourceStop", resourceRoot,
	function ()
		if isHudControlled then
			isHudControlled = false
			exports.see_hud:showHUD()
			exports.see_hud:setPokerMode(false)
			setElementFrozen(localPlayer, false)
		end
	end
)

addEventHandler("onClientElementDataChange", root,
	function (dataName, oldValue)
		processDataChange(dataName, oldValue)

		if source == localPlayer then
			if dataName == "pokerTableId" then
				local pokerTableId = getElementData(source, dataName)

				if pokerTableId then
					joinedTableId = pokerTableId
					pokerPlayers = {}

					for playerIndex, playerElement in pairs(getElementsByType("player")) do
						local playerTableId = getElementData(playerElement, "pokerTableId")

						if playerTableId then
							if pokerTableId == playerTableId then
								local playerTableSeat = getElementData(playerElement, "pokerTableSeat")

								if playerTableSeat then
									pokerPlayers[playerElement] = {
										playerTableSeat,
										getPokerSeatData(playerTableId, playerTableSeat, "pokerCoins") or 0,
										getPokerSeatData(playerTableId, playerTableSeat, "pokerCards") or {},
										getPokerSeatData(playerTableId, playerTableSeat, "currentCall") or 0
									}
								end
							end
						end
					end

					addPokerChatLine("#3d7abc" .. getElementData(localPlayer, "visibleName"):gsub("_", " ") .. " #ffffffcsatlakozott a játékhoz!")

					pokerBoardCards = getPokerBoardData(pokerTableId, "boardCards") or {}
					pokerGameStage = getPokerBoardData(pokerTableId, "gameStage") or -1
					pokerHighestBet = getPokerBoardData(pokerTableId, "currentCall") or 0
					myCurrentBet = 0
					pokerCurrentPlayer = getPokerBoardData(pokerTableId, "currentPlayer") or 0

					sliderInputText = getMinimumRaise(pokerTableId)
					sliderValue = 0
				else
					closeTheGame()
				end
			elseif dataName == "char.slotCoins" then
				mySlotCoins = getElementData(source, dataName) or 0
			end
		elseif source == resourceRoot then
			if string.find(dataName, "pokerBoard") then
				local dataNameParts = split(dataName, ".")
				local sourceTableId = tonumber(dataNameParts[2])

				local myPokerTableId = getElementData(localPlayer, "pokerTableId")
				local myPokerTableSeat = getElementData(localPlayer, "pokerTableSeat")

				if myPokerTableId then
					if myPokerTableId == sourceTableId then
						if dataNameParts[3] == "boardCards" then
							pokerBoardCards = getElementData(source, dataName) or {}
						elseif dataNameParts[3] == "gameStage" then
							pokerGameStage = getElementData(source, dataName) or -1
						elseif dataNameParts[3] == "currentPlayer" then
							local currentPlayer = getElementData(source, dataName) or 0
							local playerElement = getPokerSeatData(sourceTableId, currentPlayer, "element")

							pokerCurrentPlayer = currentPlayer

							if isElement(playerElement) then
								local visibleName = getElementData(playerElement, "visibleName") or "N/A"

								countdownData = {
									playerElement,
									getTickCount(),
									pokerCurrentPlayer,
									visibleName:gsub("_", " ")
								}

								if isElement(countdownSound) then
									destroyElement(countdownSound)
								end

								if playerElement == localPlayer then
									countdownSound = playSound("files/sounds/countdown10sec.mp3")
									myPokerTurn = true
								end
							else
								countdownData = {}

								if isElement(countdownSound) then
									destroyElement(countdownSound)
								end

								countdownSound = nil
							end

							if pokerCurrentPlayer == myPokerTableSeat then
								addPokerChatLine("Te következel!")
								playSound("files/sounds/saybetspleasecsakneked.mp3")
							end
						elseif dataNameParts[3] == "currentCall" then
							pokerHighestBet = getElementData(source, dataName) or 0
						elseif dataNameParts[3] == "seat" then
							local playerSeatId = tonumber(dataNameParts[4])
							local playerElement = getPokerSeatData(sourceTableId, playerSeatId, "element")

							if isElement(playerElement) then
								if not pokerPlayers[playerElement] then
									pokerPlayers[playerElement] = {}
									pokerPlayers[playerElement][1] = playerSeatId
								end

								if dataNameParts[5] == "pokerCoins" then
									pokerPlayers[playerElement][2] = getPokerSeatData(sourceTableId, playerSeatId, "pokerCoins") or 0

									if playerSeatId == myPokerTableSeat then
										myPokerCoins = pokerPlayers[playerElement][2]

										if tonumber(sliderInputText) then
											if tonumber(sliderInputText) > myPokerCoins then
												sliderInputText = myPokerCoins
											end
										end
									end
								elseif dataNameParts[5] == "pokerCards" then
									pokerPlayers[playerElement][3] = getPokerSeatData(sourceTableId, playerSeatId, "pokerCards") or {}
								elseif dataNameParts[5] == "currentCall" then
									pokerPlayers[playerElement][4] = getPokerSeatData(sourceTableId, playerSeatId, "currentCall") or 0

									if playerSeatId == myPokerTableSeat then
										myCurrentBet = pokerPlayers[playerElement][4]
									end
								end
							end
						end
					end
				end

				if dataNameParts[3] == "gameStage" then
					local gameStage = getElementData(source, dataName) or 0

					if gameStage > 0 then
						local theDealerPosition = realDealerPositions[sourceTableId]

						if theDealerPosition then
							local soundEffect = playSound3D("files/sounds/newcardintable.mp3", theDealerPosition[1], theDealerPosition[2], theDealerPosition[3])

							if isElement(soundEffect) then
								setElementInterior(soundEffect, tablePositions[sourceTableId][5])
								setElementDimension(soundEffect, tablePositions[sourceTableId][6])
							end
						end
					end
				end
			end
		end

		if dataName == "occupiedSeats" then
			if nearbyTableId then
				local occupiedSeats = getElementData(source, dataName)

				if occupiedSeats then
					local pokerTableId = getElementData(source, "pokerTableId")

					if pokerTableId == nearbyTableId then
						nearbyOccupiedSeats = {}

						for arrayIndex, seatId in ipairs(occupiedSeats) do
							nearbyOccupiedSeats[seatId] = true
						end
					end
				end
			end
		else
			if nearbyTableId then
				if joinedTableId then
					if dataName == "pokerTableId" then
						if source ~= localPlayer then
							local pokerTableId = getElementData(source, dataName)

							if pokerTableId then
								if pokerTableId == joinedTableId then
									local pokerTableSeat = getElementData(source, "pokerTableSeat")

									if pokerTableSeat then
										pokerPlayers[source] = {
											pokerTableSeat,
											getPokerSeatData(pokerTableId, pokerTableSeat, "pokerCoins") or 0,
											getPokerSeatData(pokerTableId, pokerTableSeat, "pokerCards") or {},
											getPokerSeatData(pokerTableId, pokerTableSeat, "currentCall") or 0
										}
										addPokerChatLine("#3d7abc" .. getElementData(source, "visibleName"):gsub("_", " ") .. " #ffffffcsatlakozott a játékhoz!")
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientPlayerQuit", root,
	function ()
		local pokerTableId = getElementData(source, "pokerTableId")
		local pokerTableSeat = getElementData(source, "pokerTableSeat")

		if pokerTableId then
			if pokerTableId == joinedTableId then
				if pokerPlayers[source] then
					pokerPlayers[source] = nil
				end
			end

			if pokerTableSeat then
				if realPlayerCards[pokerTableId] then
					realPlayerCards[pokerTableId][pokerTableSeat] = nil
				end
			end
		end
	end
)

addEventHandler("onClientCharacter", root,
	function (character)
		if sliderInputInUse then
			if joinedTableId then
				if tonumber(character) then
					local minimumRaise = getMinimumRaise(joinedTableId)
					local raiseAmount = tostring(sliderInputText)

					if utf8.len(tostring(myPokerCoins)) >= utf8.len(raiseAmount) + 1 then
						raiseAmount = tonumber(raiseAmount .. character)

						if raiseAmount then
							if myPokerCoins < raiseAmount then
								sliderValue = 0
								sliderInputText = tostring(raiseAmount)
							elseif myPokerCoins > raiseAmount then
								sliderValue = 0
								sliderInputText = tostring(raiseAmount)
							else
								sliderValue = (raiseAmount - minimumRaise) / (myPokerCoins - minimumRaise)
								sliderInputText = math.floor(minimumRaise + (myPokerCoins - minimumRaise) * sliderValue)
							end
						else
							sliderValue = 0
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientKey", root,
	function (keyName, isPressed)
		if sliderInputInUse then
			if joinedTableId then
				if keyName == "backspace" then
					if isPressed then
						local minimumRaise = getMinimumRaise(joinedTableId)
						local raiseAmount = sliderInputText

						if utf8.len(raiseAmount) - 1 >= 0 then
							raiseAmount = tonumber(utf8.sub(raiseAmount, 1, utf8.len(raiseAmount) - 1))

							if raiseAmount then
								if myPokerCoins < raiseAmount then
									sliderValue = 0
									sliderInputText = tostring(raiseAmount)
								elseif myPokerCoins > raiseAmount then
									sliderValue = 0
									sliderInputText = tostring(raiseAmount)
								else
									sliderValue = (raiseAmount - minimumRaise) / (myPokerCoins - minimumRaise)
									sliderInputText = math.floor(minimumRaise + (myPokerCoins - minimumRaise) * sliderValue)
								end
							else
								sliderValue = 0
								sliderInputText = ""
							end
						else
							sliderValue = 0
							sliderInputText = ""
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientClick", root,
	function (button, state, absoluteX, absoluteY)
		if panelState then
			if joinedTableId then
				if button == "left" then
					if state == "down" then
						if sliderClickX then
							sliderMoveX = sliderClickX
							sliderClickX = false
						end

						if absoluteX >= panelPosX and absoluteX <= panelPosX + panelWidth and absoluteY >= panelPosY and absoluteY <= panelPosY + respc(30) then
							isMoving = true
							moveDifferenceX = absoluteX - panelPosX
							moveDifferenceY = absoluteY - panelPosY
						end

						if activeButton then
							if string.find(activeButton, "pot") then
								local buttonNumber = tonumber(string.sub(activeButton, 4))
								local raiseAmount = pokerPotAmount or 0
								local minimumRaise = getMinimumRaise(joinedTableId)

								if buttonNumber == 0 then
									raiseAmount = math.floor(raiseAmount * 0.1)
								elseif buttonNumber == 1 then
									raiseAmount = math.floor(raiseAmount * 0.3)
								elseif buttonNumber == 2 then
									raiseAmount = math.floor(raiseAmount * 0.6)
								elseif buttonNumber == 3 then
									raiseAmount = math.floor(raiseAmount * 0.9)
								elseif buttonNumber == 4 then
									local pokerTableSeat = getElementData(localPlayer, "pokerTableSeat")

									if pokerTableSeat then
										raiseAmount = getPokerSeatData(joinedTableId, pokerTableSeat, "pokerCoins") or 0
									end

									raiseAmount = myPokerCoins or raiseAmount
								end

								playSound("files/sounds/butclick.mp3")

								if myPokerCoins < raiseAmount then
									sliderValue = 0
									sliderInputText = tostring(raiseAmount)
								elseif myPokerCoins > raiseAmount then
									sliderValue = 0
									sliderInputText = tostring(raiseAmount)
								else
									sliderValue = (raiseAmount - minimumRaise) / (myPokerCoins - minimumRaise)
									sliderInputText = math.floor(minimumRaise + (myPokerCoins - minimumRaise) * sliderValue)
								end
							end

							if activeButton == "sliderinput" then
								sliderInputInUse = not sliderInputInUse
								sliderInputState = {true, getTickCount()}
							end

							if activeButton == "quitGame" then
								local pokerTableId = getElementData(localPlayer, "pokerTableId")

								if pokerTableId then
									triggerServerEvent("leavePokerTable", resourceRoot, pokerTableId)
								end

								closeTheGame()
								playSound("files/sounds/butfold.mp3")
							end

							if panelStage == 1 then
								if activeButton == "startGame" then
									triggerServerEvent("startPoker", resourceRoot, sliderAmount)
									playSound("files/sounds/butclick.mp3")
								end
							elseif panelStage == 2 then
								if activeButton == "fold" or activeButton == "check" or activeButton == "raise" then
									if pokerPlayers[localPlayer] then
										if pokerCurrentPlayer then
											if pokerPlayers[localPlayer][1] == pokerCurrentPlayer then
												if activeButton == "fold" then
													if myPokerTurn then
														triggerServerEvent("pokerAction", resourceRoot, "fold")
														playSound("files/sounds/butfold.mp3")
														myPokerTurn = false
													end
												elseif activeButton == "check" then
													if myPokerTurn then
														triggerServerEvent("pokerAction", resourceRoot, "check")
														playSound("files/sounds/butclick.mp3")
														myPokerTurn = false
													end
												elseif activeButton == "raise" then
													local raiseAmount = tonumber(sliderInputText)

													if raiseAmount then
														local minimumRaise = getMinimumRaise(joinedTableId)

														if raiseAmount >= minimumRaise and raiseAmount <= myPokerCoins then
															if myPokerTurn then
																triggerServerEvent("pokerAction", resourceRoot, "raise", raiseAmount)
																playSound("files/sounds/butclick.mp3")
																myPokerTurn = false
															end
														else
															addPokerChatLine("#d75959A megadott összeg érvénytelen!")
														end
													else
														addPokerChatLine("#d75959A megadott összeg érvénytelen!")
													end
												end
											else
												addPokerChatLine("#d75959Várd ki a sorod, most nem te következel!")
											end
										end
									end
								end
							end
						end
					elseif state == "up" then
						sliderClickX = false
						isMoving = false
					end
				end
			end
		else
			if nearbyTableId then
				if not joinedTableId then
					if button == "left" then
						if state == "up" then
							if activeButton then
								local buttonParts = split(activeButton, "_")

								if buttonParts then
									if buttonParts[1] == "join" then
										local tableId = tonumber(buttonParts[2])
										local seatId = tonumber(buttonParts[3])

										if not nearbyOccupiedSeats[seatId] then
											if tablePositions[tableId][9] <= mySlotCoins then
												triggerServerEvent("joinPokerTable", resourceRoot, tableId, seatId)
											else
												outputChatBox("#d75959[StrongMTA - Póker]: #ffffffNincs elég coinod.", 255, 255, 255, true)
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

function closeTheGame()
	panelState = false
	panelStage = 1

	joinedTableId = false

	isMoving = false
	moveDifferenceX = 0
	moveDifferenceY = 0

	destroyFonts()

	buttons = {}
	activeButton = false
	oldActiveButton = false

	sliderClickX = false
	sliderMoveX = false
	sliderValue = 0
	sliderAmount = 0
	sliderInputText = ""
	sliderInputInUse = false
	sliderInputState = {}

	myPokerCoins = 0
	myCurrentBet = 0
	myPokerTurn = false

	pokerPotAmount = 0
	pokerPlayers = {}
	pokerBoardCards = {}
	pokerGameStage = -1
	pokerHighestBet = 0
	pokerCurrentPlayer = 0
	pokerShowDown = {}

	pokerChatLines = {}
	pokerChatOffset = 0

	countdownData = {}

	if countdownSound then
		if isElement(countdownSound) then
			destroyElement(countdownSound)
		end

		countdownSound = nil
	end
end

addEvent("joinPokerTable", true)
addEventHandler("joinPokerTable", resourceRoot,
	function (tableId)
		joinedTableId = tableId
		createFonts()
		panelState = true
		myPokerTurn = false
		panelStage = 1
		pokerPotAmount = getPokerBoardData(tableId, "pot") or 0
	end
)

addEvent("startPoker", true)
addEventHandler("startPoker", resourceRoot,
	function (tableId)
		if panelState then
			if tableId then
				panelStage = 2
				sliderInputText = getMinimumRaise(tableId)
				sliderValue = 0
			end
		end
	end
)

function addPokerChatLine(textMessage)
	local newTextLines = {textMessage}

	for i = 1, #pokerChatLines do
		if i > 50 then
			break
		end

		if pokerChatLines[i] then
			table.insert(newTextLines, pokerChatLines[i])
		end
	end

	pokerChatLines = newTextLines
end

addEventHandler("onClientKey", root,
	function (keyName, isPressed)
		if isPressed then
			if activeButton == "chatscroll" then
				if keyName == "mouse_wheel_up" then
					if pokerChatOffset < #pokerChatLines - pokerChatMaxLine then
						pokerChatOffset = pokerChatOffset + 1
					end
				elseif keyName == "mouse_wheel_down" then
					if pokerChatOffset > 0 then
						pokerChatOffset = pokerChatOffset - 1
					end
				end
			end
		end
	end
)

function getMinimumRaise(tableId)
	if tableId then
		local minimumRaise = tablePositions[tableId][8]
		local amountToCall = pokerHighestBet - myCurrentBet

		if amountToCall > 0 and minimumRaise < amountToCall then
			minimumRaise = amountToCall
		end

		if minimumRaise > myPokerCoins then
			minimumRaise = myPokerCoins
		end

		return minimumRaise
	end
end

addEventHandler("onClientRender", root,
	function ()
		local absX, absY = 0, 0

		if isCursorShowing() then
			local relX, relY = getCursorPosition()

			absX = relX * screenWidth
			absY = relY * screenHeight
		else
			if sliderMoveX then
				sliderMoveX = false
			end

			if isMoving then
				isMoving = false
			end
		end

		render3dCards()

		if sliderMoveX then
			if not getKeyState("mouse1") then
				sliderMoveX = false
			end
		end

		if sliderClickX then
			sliderClickX = false
		end

		buttons = {}
		buttonsC = {}

		if nearbyTableId then
			if joinedTableId then
				-- ** Játékosok tétjei
				for playerElement, playerInfo in pairs(pokerPlayers) do
					local playerSeat = tonumber(playerInfo[1])

					if nearbyOccupiedSeats[playerSeat] then
						-- Hátralévő zseton
						if not playerInfo[2] then
							playerInfo[2] = getPokerSeatData(joinedTableId, playerSeat, "pokerCoins") or 0
						end

						if playerInfo[2] > 0 then
							local objectElement = realCoinObjects[joinedTableId][playerSeat][1]

							if isElement(objectElement) then
								local objectX, objectY, objectZ = getElementPosition(objectElement)
								local guiPosX, guiPosY = getScreenFromWorldPosition(objectX, objectY, objectZ + 0.2)

								if guiPosX and guiPosY then
									local visibleText = thousandsStepper(playerInfo[2]) .. " #3d7abcCoin"

									local guiSizeX = dxGetTextWidth(visibleText, 0.9, Raleway12, true) + respc(5)
									local guiSizeY = respc(20)

									guiPosX = guiPosX - guiSizeX / 2
									guiPosY = guiPosY - guiSizeY / 2

									--dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(0, 0, 0, 160))
									dxDrawText(thousandsStepper(playerInfo[2]).." Coin", guiPosX + 1, guiPosY + 1, guiPosX + guiSizeX + 1, guiPosY + guiSizeY + 1, tocolor(0, 0, 0, 200), 0.9, Raleway12, "center", "center", false, false, false, true)
									dxDrawText(visibleText, guiPosX, guiPosY, guiPosX + guiSizeX, guiPosY + guiSizeY, tocolor(200, 200, 200, 200), 0.9, Raleway12, "center", "center", false, false, false, true)
								end
							end
						end

						-- Licitkörre felrakott zseton
						if realCoinAmounts[joinedTableId] then
							local pokerCoins = realCoinAmounts[joinedTableId][playerSeat + maximumPlayers] or 0

							if pokerCoins > 0 then
								if realCoinObjectsEx[joinedTableId] then
									local objectElement = realCoinObjectsEx[joinedTableId][playerSeat]

									if not isElement(objectElement) then
										if realCoinObjects[joinedTableId][playerSeat + maximumPlayers] then
											objectElement = realCoinObjects[joinedTableId][playerSeat + maximumPlayers][1]
										end
									end

									if isElement(objectElement) then
										local objectX, objectY, objectZ = getElementPosition(objectElement)
										local guiPosX, guiPosY = getScreenFromWorldPosition(objectX, objectY, objectZ + 0.2)

										if guiPosX and guiPosY then
											local visibleText = thousandsStepper(pokerCoins) .. " #3d7abcCoin"

											local guiSizeX = dxGetTextWidth(visibleText, 0.9, Raleway12, true) + respc(5)
											local guiSizeY = respc(20)

											guiPosX = guiPosX - guiSizeX / 2
											guiPosY = guiPosY - guiSizeY / 2

											--dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(0, 0, 0, 160))
											dxDrawText(thousandsStepper(pokerCoins) .. " Coin", guiPosX + 1, guiPosY + 1, guiPosX + guiSizeX + 1, guiPosY + guiSizeY + 1, tocolor(0, 0, 0, 200), 0.9, Raleway12, "center", "center", false, false, false, true)
											dxDrawText(visibleText, guiPosX, guiPosY, guiPosX + guiSizeX, guiPosY + guiSizeY, tocolor(200, 200, 200, 200), 0.9, Raleway12, "center", "center", false, false, false, true)
										end
									end
								end
							end
						end
					end
				end

				-- ** Kassza
				if realCoinAmounts[joinedTableId] then
					local pokerCoins = tonumber(realCoinAmounts[joinedTableId]["pot"]) or 0

					if pokerCoins > 0 then
						pokerCoins = thousandsStepper(pokerCoins)

						-- Képernyő teteje
						local guiSizeX = dxGetTextWidth("Pot: " .. pokerCoins .. " Coin", 0.6, Raleway24) + respc(20)
						local guiSizeY = respc(35)

						local guiPosX = screenWidth / 2 - guiSizeX / 2
						local guiPosY = respc(20)

						dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(25, 25, 25))
						dxDrawText("Pot: #3d7abc" .. pokerCoins .. " Coin", guiPosX, guiPosY, guiPosX + guiSizeX, guiPosY + guiSizeY, tocolor(200, 200, 200, 200), 0.6, Raleway24, "center", "center", false, false, false, true)

						-- Zseton objekt
						local theCoinPosition = realCoinPositions[joinedTableId]["pot"]

						if theCoinPosition then
							local guiPosX, guiPosY = getScreenFromWorldPosition(theCoinPosition[1], theCoinPosition[2], theCoinPosition[7] + 0.2)

							if guiPosX and guiPosY then
								local guiSizeX = dxGetTextWidth(pokerCoins .. " Coin", 0.9, Raleway12) + respc(5)
								local guiSizeY = respc(20)

								guiPosX = guiPosX - guiSizeX / 2
								guiPosY = guiPosY - guiSizeY / 2

								--dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(0, 0, 0, 160))
								dxDrawText(pokerCoins .. " Coin", guiPosX + 1, guiPosY + 1, guiPosX + guiSizeX + 1, guiPosY + guiSizeY + 1, tocolor(0, 0, 0, 200), 0.9, Raleway12, "center", "center", false, false, false, true)
								dxDrawText(pokerCoins .. " #3d7abcCoin", guiPosX, guiPosY, guiPosX + guiSizeX, guiPosY + guiSizeY, tocolor(200, 200, 200, 200), 0.9, Raleway12, "center", "center", false, false, false, true)
							end
						end
					end
				end

				-- ** Az asztalon lévő közös lapok
				local numOfCards = 0

				if pokerGameStage == 1 then
					numOfCards = 3
				elseif pokerGameStage == 2 then
					numOfCards = 4
				elseif pokerGameStage >= 3 then
					numOfCards = 5
				end

				local cardSizeX = respc(64)
				local cardSizeY = respc(96)

				if numOfCards > 0 then
					local theTablePosition = tablePositions[nearbyTableId]

					if theTablePosition then
						local guiPosX, guiPosY = getScreenFromWorldPosition(theTablePosition[1], theTablePosition[2], theTablePosition[3] + 1)

						if guiPosX and guiPosY then
							local containerWidth = cardSizeX * numOfCards + respc(5) * (numOfCards + 1)

							guiPosX = guiPosX - containerWidth / 2
							guiPosY = guiPosY - cardSizeY / 2

							dxDrawRectangle(guiPosX, guiPosY - respc(5), containerWidth, cardSizeY + respc(10), tocolor(0, 0, 0, 150))

							for i = 1, numOfCards do
								local currentCard = pokerBoardCards[i]

								if currentCard then
									dxDrawImage(guiPosX + cardSizeX * (i - 1) + respc(5) * i, guiPosY, cardSizeX, cardSizeY, "files/cards/" .. cardRanks[currentCard[1]] .. "-" .. currentCard[2] .. ".png", 0, 0, 0, tocolor(255, 255, 255))
								end
							end
						end
					end
				end

				-- ** Ülés feletti visszaszámláló sáv
				if countdownData then
					if countdownData[1] ~= localPlayer then
						local pokerTableSeat = countdownData[3]

						if pokerTableSeat then
							if pokerTableSeat > 0 then
								local elapsedTime = getTickCount() - countdownData[2]
								local elapsedProgress = elapsedTime / interactionTime

								if elapsedProgress < 1.1 then
									local thePedPosition = realPedPositions[nearbyTableId][pokerTableSeat]

									if thePedPosition then
										local guiPosX, guiPosY = getScreenFromWorldPosition(thePedPosition[1], thePedPosition[2], thePedPosition[3] + 0.45)

										if guiPosX and guiPosY then
											local guiSizeX = respc(5) + 2 * respc(85)
											local guiSizeY = respc(18)

											guiPosX = math.floor(guiPosX - guiSizeX / 2)
											guiPosY = math.floor(guiPosY - guiSizeY / 2)

											dxDrawImage(guiPosX, guiPosY, guiSizeY, guiSizeY, "files/fonts/clock.png", 0, 0, 0, tocolor(61, 122, 188))
											dxDrawRectangle(guiPosX + guiSizeY + respc(6), guiPosY, guiSizeX, guiSizeY, tocolor(25, 25, 25))

											local coloringTime = interactionTime / 1.5
											local coloringDuration = coloringTime / 2
											local progressColor = {61, 122, 188}

											if elapsedTime >= coloringTime then
												progressColor[1], progressColor[2], progressColor[3] = interpolateBetween(61, 122, 188, 215, 89, 89, (elapsedTime - coloringTime) / coloringDuration, "Linear")
											end

											if elapsedProgress > 1 then
												elapsedProgress = 1
											end

											local barMargin = respc(4)

											guiPosX = guiPosX + guiSizeY + respc(6) + barMargin
											guiPosY = guiPosY + barMargin

											guiSizeX = guiSizeX - barMargin * 2
											guiSizeY = guiSizeY - barMargin * 2

											dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(45, 45, 45, 240))
											dxDrawRectangle(guiPosX, guiPosY, guiSizeX * (1 - elapsedProgress), guiSizeY, tocolor(progressColor[1], progressColor[2], progressColor[3]))
										end
									end
								end
							end
						end
					end
				end

				-- ** Játékosok lapjai mutatáskor vagy a saját lapjaink és a visszaszámláló
				for playerElement, playerInfo in pairs(pokerPlayers) do
					local playerCards = playerInfo[3]

					if playerCards then
						local numOfCards = #playerCards

						local guiSizeX = cardSizeX * numOfCards + respc(5) * (numOfCards + 1)
						local guiSizeY = cardSizeY

						local guiPosX = false
						local guiPosY = false

						if playerElement == localPlayer then
							guiPosX = (screenWidth - guiSizeX) / 2
							guiPosY = screenHeight - guiSizeY - respc(40)
						else
							local playerSeat = playerInfo[1]

							if pokerShowDown[joinedTableId] then
								local thePedPosition = realPedPositions[joinedTableId][playerSeat]

								if thePedPosition then
									guiPosX, guiPosY = getScreenFromWorldPosition(thePedPosition[1], thePedPosition[2], thePedPosition[3] - 0.5)

									if guiPosX and guiPosY then
										guiPosX = guiPosX - guiSizeX / 2
										guiPosY = guiPosY - guiSizeY / 2
									end
								end
							end
						end

						if guiPosX and guiPosY then
							if numOfCards > 0 then
								if countdownData then
									if countdownData[1] == localPlayer then
										if playerElement == localPlayer then
											local elapsedTime = getTickCount() - countdownData[2]
											local elapsedProgress = elapsedTime / interactionTime

											if elapsedProgress < 1.1 then
												local barMargin = respc(4)

												local barSizeX = guiSizeX
												local barSizeY = respc(18)

												local barPosX = (screenWidth - barSizeX) / 2
												local barPosY = guiPosY - barSizeY - barMargin * 2

												dxDrawRectangle(barPosX, barPosY, barSizeX, barSizeY, tocolor(25, 25, 25))

												local coloringTime = interactionTime / 1.5
												local coloringDuration = coloringTime / 2
												local progressColor = {61, 122, 188}

												if elapsedTime >= coloringTime then
													progressColor[1], progressColor[2], progressColor[3] = interpolateBetween(61, 122, 188, 215, 89, 89, (elapsedTime - coloringTime) / coloringDuration, "Linear")
												end

												if elapsedProgress > 1 then
													elapsedProgress = 1
												end

												barPosX = barPosX + barMargin
												barPosY = barPosY + barMargin

												barSizeX = barSizeX - barMargin * 2
												barSizeY = barSizeY - barMargin * 2

												dxDrawRectangle(barPosX, barPosY, barSizeX, barSizeY, tocolor(45, 45, 45, 245))
												dxDrawRectangle(barPosX, barPosY, barSizeX * (1 - elapsedProgress), barSizeY, tocolor(progressColor[1], progressColor[2], progressColor[3]))
											end
										end
									end
								end

								dxDrawRectangle(guiPosX, guiPosY - respc(5), guiSizeX, guiSizeY + respc(10), tocolor(25, 25, 25))

								for i = 1, #playerCards do
									local currentCard = playerCards[i]

									if currentCard then
										dxDrawImage(guiPosX + cardSizeX * (i - 1) + respc(5) * i, guiPosY, cardSizeX, cardSizeY, "files/cards/" .. cardRanks[currentCard[1]] .. "-" .. currentCard[2] .. ".png", 0, 0, 0, tocolor(255, 255, 255))
									end
								end
							end
						end
					end
				end
			end
		end

		if panelState then
			if isMoving then
				panelPosX = absX - moveDifferenceX
				panelPosY = absY - moveDifferenceY
			end

			if panelStage == 1 then
				-- ** Háttér
				dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(25, 25, 25), false)

				-- ** Cím
				dxDrawRectangle(panelPosX + 3, panelPosY + 3, panelWidth - 6, respc(40) - 6, tocolor(45, 45, 45, 150), false)
				dxDrawText("#3d7abcStrong#ffffffMTA - Poker", panelPosX + respc(5) + 3, panelPosY, 3, panelPosY + respc(40), tocolor(200, 200, 200, 200), 1, Raleway12, "left", "center", false, false, false, true)

				-- Kilépés
				local quitButton = {panelPosX + panelWidth - respc(20) - 3, panelPosY + 3, respc(20), respc(40) - 6}

				buttons["quitGame"] = quitButton

				--drawButton("startGame", "Játék", startButton[1], startButton[2], startButton[3], startButton[4], {61, 122, 188}, false, Raleway12, true)

				if activeButton == "quitGame" then
					quitImageColor = tocolor(215, 89, 89, 200)
				else
					quitImageColor = tocolor(215, 89, 89, 150)
				end

				dxDrawText("X", panelPosX + panelWidth - respc(10) - 3, panelPosY + respc(20), nil, nil, quitImageColor, 1, Raleway12, "center", "center")

				-- ** Slider
				dxDrawText("Mennyi zsetonnal szeretnél beülni?", panelPosX, panelPosY + respc(40), panelPosX + panelWidth, 0, tocolor(200, 200, 200, 200), 1, Raleway12, "center", "top")

				if sliderValue ~= sliderValue then -- Not a number check
					sliderValue = 0
				end

				local sliderBaseWidth = panelWidth - respc(40)
				local sliderBaseHeight = respc(20)

				local sliderKnobWidth = respc(20)
				local sliderKnobHeight = respc(40)

				local sliderBaseX = panelPosX + (panelWidth - sliderBaseWidth) / 2
				local sliderBaseY = panelPosY + respc(80)

				local sliderKnobX = sliderBaseX + (sliderBaseWidth - sliderKnobWidth) * sliderValue
				local sliderKnobY = sliderBaseY + (sliderBaseHeight - sliderKnobHeight) * 0.5

				dxDrawRectangle(sliderBaseX - respc(5), sliderBaseY, sliderBaseWidth + respc(10), sliderKnobHeight, tocolor(100, 100, 100, 100))
				dxDrawRectangle(sliderBaseX - respc(5) + 3, sliderBaseY + 3, (sliderBaseWidth * sliderValue + respc(10)) - 6, sliderKnobHeight - 6, tocolor(61, 123, 188, 150))

				if not sliderMoveX then
					if absX >= sliderKnobX - respc(10) and absX <= sliderKnobX + sliderKnobWidth + respc(10) and absY >= sliderKnobY and absY <= sliderKnobY + sliderKnobHeight then
						sliderClickX = absX - sliderKnobX
					elseif absX >= sliderBaseX and absX <= sliderBaseX + sliderBaseWidth and absY >= sliderBaseY and absY <= sliderBaseY + sliderBaseHeight then
						sliderClickX = sliderKnobWidth / 2
					end
				else
					sliderValue = (absX - sliderMoveX - sliderBaseX) / (sliderBaseWidth - sliderKnobWidth)

					if sliderValue < 0 then
						sliderValue = 0
					elseif sliderValue > 1 then
						sliderValue = 1
					end
				end

				local minimumEntry = tablePositions[joinedTableId][9]
				local maximumEntry = tablePositions[joinedTableId][10]

				local minimumValue = minimumEntry
				local maximumValue = mySlotCoins

				if maximumValue > maximumEntry then
					maximumValue = maximumEntry
				end

				sliderAmount = math.floor(minimumValue + (maximumValue - minimumValue) * sliderValue)

				dxDrawText(thousandsStepper(sliderAmount) .. " #3d7abcCoin", panelPosX, panelPosY + respc(130) - respc(10), panelPosX + panelWidth, 0 - respc(10), tocolor(200, 200, 200, 200), 1, Raleway24, "center", "top", false, false, false, true)

				-- ** Indítás
				local startButton = {panelPosX + respc(10), panelPosY + panelHeight - respc(50), panelWidth - respc(20), respc(40)}

				buttons["startGame"] = startButton

				--if activeButton == "startGame" then
				--	dxDrawRectangle(startButton[1], startButton[2], startButton[3], startButton[4], tocolor(61, 122, 188, 220), false)
				--else
				--	dxDrawRectangle(startButton[1], startButton[2], startButton[3], startButton[4], tocolor(61, 122, 188, 160), false)
				--end

				drawButton("startGame", "Játék", startButton[1], startButton[2], startButton[3], startButton[4], {61, 122, 188}, false, Raleway12, true)

				--dxDrawText("Játék", startButton[1], startButton[2], startButton[1] + startButton[3], startButton[2] + startButton[4], tocolor(255, 255, 255, 255), 1, Raleway12, "center", "center")
			elseif panelStage == 2 then
				-- ** A jelenlegi játékos jelzése a pókerchat fölött
				local canDoAction = false
				local visibleText = ""

				if countdownData[1] == localPlayer then
					canDoAction = true
					visibleText = "Te következel!"
				else
					if countdownData[4] then
						visibleText = "#d75959" .. countdownData[4] .. " #ffffffkövetkezik"
					end
				end

				if utf8.len(visibleText) > 0 then
					local countdownProgress = (getTickCount() - countdownData[2]) / interactionTime

					if countdownProgress < 1.1 then
						local guiSizeX = respc(20) + dxGetTextWidth(visibleText, 0.85, Raleway12, true)
						local guiSizeY = respc(25)

						local guiPosX = chatPosX - respc(5)
						local guiPosY = chatPosY - guiSizeY - respc(10)

						if countdownData[1] == localPlayer then
							dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(25, 25, 25))
							dxDrawText(visibleText, guiPosX, guiPosY, guiPosX + guiSizeX, guiPosY + guiSizeY, tocolor(200, 200, 200, 200), 0.85, Raleway12, "center", "center")
						else
							dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(25, 25, 25))
							dxDrawText(visibleText, guiPosX, guiPosY, guiPosX + guiSizeX, guiPosY + guiSizeY, tocolor(200, 200, 200, 200), 0.85, Raleway12, "center", "center", false, false, false, true)
						end
					end
				end

				-- ** Chat
				dxDrawRectangle(chatPosX - respc(5), chatPosY - respc(5), chatWidth + respc(10), chatHeight + respc(10), tocolor(25, 25, 25))
				dxDrawRectangle(chatPosX, chatPosY, chatWidth, chatHeight, tocolor(35, 35, 35, 250))

				if #pokerChatLines > pokerChatMaxLine then
					local oneLineHeight = chatHeight / #pokerChatLines

					local rectangleWidth = respc(4)
					local rectangleHeight = oneLineHeight * pokerChatMaxLine

					local rectanglePosX = chatPosX + chatWidth - rectangleWidth
					local rectanglePosY = oneLineHeight * pokerChatOffset

					dxDrawRectangle(rectanglePosX, chatPosY, rectangleWidth, chatHeight, tocolor(45, 45, 45))
					dxDrawRectangle(rectanglePosX, chatPosY + chatHeight - rectanglePosY - rectangleHeight, rectangleWidth, rectangleHeight, tocolor(61, 122, 188, 225))
				end

				for i = 1, pokerChatMaxLine do
					local textMessage = pokerChatLines[i + pokerChatOffset]

					if textMessage then
						dxDrawText(textMessage, chatPosX + respc(5), chatPosY + chatLineHeight * (pokerChatMaxLine - i), 0, chatPosY + chatLineHeight * (pokerChatMaxLine + 1 - i), tocolor(200, 200, 200, 200), 0.8, Raleway12, "left", "center", false, false, false, true)
					end
				end

				buttons["chatscroll"] = {chatPosX, chatPosY, chatWidth, chatHeight}

				-- ** Gombok
				local buttonCaptions = {"10% pot", "30% pot", "60% pot", "90% pot", "All in"}
				local buttonCount = #buttonCaptions

				local buttonWidth = (chatWidth - respc(20)) / buttonCount
				local buttonHeight = respc(25)
				local buttonMargin = buttonHeight / 4

				local containerWidth = buttonWidth * buttonCount + buttonMargin * buttonCount

				local guiPosX = screenWidth - respc(20) - containerWidth + respc(10)
				local guiPosY = chatPosY - respc(5)

				for i = 0, buttonCount do
					local buttonName = ""

					if i == buttonCount then
						i = 4
						buttonName = "quitGame"
					else
						buttonName = "pot" .. i
					end

					local buttonPosX = guiPosX + buttonWidth * i + buttonMargin * i
					local buttonPosY = guiPosY

					if buttonName == "quitGame" then
						buttonPosY = guiPosY - respc(35)
					end

					--[[if buttonName == "quitGame" then
						if activeButton == buttonName then
							dxDrawRectangle(buttonPosX, buttonPosY, buttonWidth, buttonHeight, tocolor(215, 89, 89))
						else
							dxDrawRectangle(buttonPosX, buttonPosY, buttonWidth, buttonHeight, tocolor(215, 89, 89, 200))
						end
					elseif activeButton == buttonName then
						dxDrawRectangle(buttonPosX, buttonPosY, buttonWidth, buttonHeight, tocolor(0, 0, 0, 200))
					else
						dxDrawRectangle(buttonPosX, buttonPosY, buttonWidth, buttonHeight, tocolor(0, 0, 0, 100))
					end

					

					if buttonName == "quitGame" then
						dxDrawText("Kilépés", buttonPosX, buttonPosY, buttonPosX + buttonWidth, buttonPosY + buttonHeight, tocolor(0, 0, 0), 0.85, Raleway12, "center", "center")
					else
						dxDrawText(buttonCaptions[i + 1], buttonPosX, buttonPosY, buttonPosX + buttonWidth, buttonPosY + buttonHeight, tocolor(255, 255, 255), 0.85, Raleway12, "center", "center")
					end]]

					buttons[buttonName] = {buttonPosX, buttonPosY, buttonWidth, buttonHeight}

					if buttonName == "quitGame" then
						drawButton(buttonName, "Kilépés", buttonPosX, buttonPosY, buttonWidth, buttonHeight, {215, 89, 89}, false, Raleway12, true)
					else
						drawButton(buttonName, buttonCaptions[i + 1], buttonPosX, buttonPosY, buttonWidth, buttonHeight, {61, 122, 188}, false, Raleway12, true)
					end
				end

				guiPosY = guiPosY + respc(35)

				-- ** Slider
				local guiWidth = containerWidth - respc(5)
				local guiHeight = respc(40)

				dxDrawRectangle(guiPosX, guiPosY, guiWidth, guiHeight, tocolor(0, 0, 0, 150))

				if sliderValue ~= sliderValue then -- NaN check (0/0)
					sliderValue = 0
				end

				local sliderBaseWidth = guiWidth - respc(100)
				local sliderBaseHeight = respc(10)

				local sliderKnobWidth = respc(10)
				local sliderKnobHeight = respc(20)

				local sliderBaseX = guiPosX + respc(10)
				local sliderBaseY = guiPosY + respc(15)

				local sliderKnobX = sliderBaseX + (sliderBaseWidth - sliderKnobWidth) * sliderValue
				local sliderKnobY = sliderBaseY + (sliderBaseHeight - sliderKnobHeight) * 0.5

				dxDrawRectangle(sliderBaseX, sliderBaseY, sliderBaseWidth, sliderBaseHeight, tocolor(100, 100, 100, 100))
				dxDrawRectangle(sliderKnobX, sliderKnobY, sliderKnobWidth, sliderKnobHeight, tocolor(61, 122, 188, 240))

				local minimumRaise = getMinimumRaise(joinedTableId)
				local amountToCall = pokerHighestBet - myCurrentBet

				if not sliderMoveX then
					if absX >= sliderKnobX and absX <= sliderKnobX + sliderKnobWidth and absY >= sliderKnobY and absY <= sliderKnobY + sliderKnobHeight then
						sliderClickX = absX - sliderKnobX
					elseif absX >= sliderBaseX and absX <= sliderBaseX + sliderBaseWidth and absY >= sliderBaseY and absY <= sliderBaseY + sliderBaseHeight then
						sliderClickX = sliderKnobWidth / 2
					end
				else
					sliderValue = (absX - sliderMoveX - sliderBaseX) / (sliderBaseWidth - sliderKnobWidth)

					if sliderValue < 0 then
						sliderValue = 0
					elseif sliderValue > 1 then
						sliderValue = 1
					end

					sliderAmount = math.floor(minimumRaise + (myPokerCoins - minimumRaise) * sliderValue)
					sliderInputText = sliderAmount
				end

				-- ** Slider Input
				local inputWidth = respc(60)
				local inputHeight = respc(20)

				local inputPosX = guiPosX + guiWidth - inputWidth - respc(10)
				local inputPosY = guiPosY + respc(10)

				buttons["sliderinput"] = {inputPosX, inputPosY, inputWidth, inputHeight}

				if sliderInputText ~= sliderInputText then -- NaN check (0/0)
					sliderInputText = myPokerCoins
				end

				dxDrawRectangle(inputPosX, inputPosY, inputWidth, inputHeight, tocolor(255, 255, 255, 225))
				dxDrawText(sliderInputText, inputPosX, inputPosY, inputPosX + inputWidth, inputPosY + inputHeight, tocolor(0, 0, 0, 225), 0.85, Raleway12, "center", "center")

				if sliderInputInUse then
					local elapsedTime = getTickCount() - sliderInputState[2]
					local textWidth = dxGetTextWidth(tostring(sliderInputText), 0.85, Raleway12) + respc(2)

					if sliderInputState[1] then
						dxDrawRectangle(inputPosX + (inputWidth + textWidth) / 2, inputPosY + respc(2.5), 2, inputHeight - respc(5), tocolor(0, 0, 0))
					end

					if elapsedTime >= 750 then
						sliderInputState[1] = not sliderInputState[1]
						sliderInputState[2] = getTickCount()
					end
				end

				guiPosY = guiPosY + guiHeight + respc(10)

				-- ** Lehetőségek
				local buttonWidth = (containerWidth - respc(10) * 2 - respc(5)) / 3
				local buttonHeight = respc(60)

				-- Eldobás
				buttons["fold"] = {guiPosX, guiPosY, buttonWidth, buttonHeight}

				drawButton("fold", "Fold", guiPosX, guiPosY, buttonWidth, buttonHeight, {215, 89, 89}, false, Raleway12, true)



				guiPosX = guiPosX + buttonWidth + respc(10)

				-- Passzolás & Tartás
				local buttonText = "Check"

				if pokerHighestBet > 0 and myCurrentBet < pokerHighestBet then
					buttonText = "Call"
				end

				buttons["check"] = {guiPosX, guiPosY, buttonWidth, buttonHeight}

				if canDoAction then
					--dxDrawRectangle(guiPosX, guiPosY, buttonWidth, buttonHeight, tocolor(122, 188, 61, 255))
					drawButton("check", buttonText, guiPosX, guiPosY, buttonWidth, buttonHeight, {122, 188, 61}, false, Raleway12, true)
				else
					if buttonText == "Check" then
						buttonText = "Check"
					else
						local callAmount = thousandsStepper(amountToCall)
						if amountToCall > myPokerCoins then
							sliderValue = 1
							callAmount = "All-In"
						end
					end

					drawButton("check", buttonText, guiPosX, guiPosY, buttonWidth, buttonHeight, {122, 188, 61}, false, Raleway12, true)
				end

				if buttonText == "Check" then
					--dxDrawText(buttonText, guiPosX, guiPosY, guiPosX + buttonWidth, guiPosY + buttonHeight, tocolor(255, 255, 255), 1, Raleway12, "center", "center")
				else
					local callAmount = thousandsStepper(amountToCall)

					if amountToCall > myPokerCoins then
						sliderValue = 1
						callAmount = "All-In"
					end

					--dxDrawText(buttonText .. "\n(" .. callAmount .. ")", guiPosX, guiPosY, guiPosX + buttonWidth, guiPosY + buttonHeight, tocolor(255, 255, 255), 1, Raleway12, "center", "center")
				end

				guiPosX = guiPosX + buttonWidth + respc(10)

				-- Emelés
				if sliderInputText ~= sliderInputText then -- NaN check (0/0)
					sliderInputText = myPokerCoins or 0
				end

				local buttonText = "Raise"
				local raiseAmount = thousandsStepper(sliderInputText)

				if amountToCall > myPokerCoins then
					sliderValue = 1
					raiseAmount = "All-In"
				end

				if pokerHighestBet == 0 then
					buttonText = "Bet"
				end

				buttons["raise"] = {guiPosX, guiPosY, buttonWidth, buttonHeight}

				--if activeButton == "raise" then
				--	if canDoAction then
				--		dxDrawRectangle(guiPosX, guiPosY, buttonWidth, buttonHeight, tocolor(89, 142, 215, 255))
				--	else
				--		dxDrawRectangle(guiPosX, guiPosY, buttonWidth, buttonHeight, tocolor(89, 142, 215, 120))
				--	end
				--elseif canDoAction then
				--	dxDrawRectangle(guiPosX, guiPosY, buttonWidth, buttonHeight, tocolor(89, 142, 215, 175))
				--else
				--	dxDrawRectangle(guiPosX, guiPosY, buttonWidth, buttonHeight, tocolor(89, 142, 215, 120))
				--end

				--dxDrawText(buttonText .. "\n(" .. raiseAmount .. ")", guiPosX, guiPosY, guiPosX + buttonWidth, guiPosY + buttonHeight, tocolor(255, 255, 255), 1, Raleway12, "center", "center")

				drawButton("raise", buttonText .. "\n(" .. raiseAmount .. ")", guiPosX, guiPosY, buttonWidth, buttonHeight, {89, 142, 215}, false, Raleway12, true)
			end
		else
			if nearbyTableId then
				if not joinedTableId then
					local theTablePosition = tablePositions[nearbyTableId]

					if realGuiPositions[nearbyTableId] then
						local guiSizeX = respc(90)
						local guiSizeY = respc(40)

						for i = 1, #realGuiPositions[nearbyTableId] do
							local theGuiPosition = realGuiPositions[nearbyTableId][i]

							if not nearbyOccupiedSeats[i] then
								local guiPosX, guiPosY = getScreenFromWorldPosition(theGuiPosition[1], theGuiPosition[2], theGuiPosition[3])

								if guiPosX and guiPosY then
									local buttonName = "join_" .. tostring(nearbyTableId) .. "_" .. tostring(i)
									guiPosX = guiPosX - guiSizeX / 2
									guiPosY = guiPosY - guiSizeY / 2

									buttons[buttonName] = {guiPosX, guiPosY, guiSizeX, guiSizeY}
									dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(25, 25, 25))
									drawButton(buttonName, "LEÜLÖK", guiPosX + 3, guiPosY + 3, guiSizeX - 6, guiSizeY - 6, {61, 122, 188}, false, Raleway12, true)
								end
							end
						end
					end

					if theTablePosition then
						local guiPosX, guiPosY = getScreenFromWorldPosition(theTablePosition[1], theTablePosition[2], theTablePosition[3] + 1)

						if guiPosX and guiPosY then
							local guiSizeX = respc(230)
							local guiSizeY = respc(90)
							local guiLineHeight = guiSizeY / 4

							guiPosX = guiPosX - guiSizeX / 2
							guiPosY = guiPosY - guiSizeY / 2

							-- Háttér
							dxDrawRectangle(guiPosX, guiPosY, guiSizeX, guiSizeY, tocolor(25, 25, 25, 240))

							-- Minimum beülő
							dxDrawText("Min. beülő:", guiPosX + respc(5), guiPosY, 0, guiPosY + guiLineHeight, tocolor(200, 200, 200, 200), 1, Raleway12, "left", "center")
							dxDrawText(thousandsStepper(theTablePosition[9]) .. " Coin", 0, guiPosY, guiPosX + guiSizeX - respc(5), guiPosY + guiLineHeight, tocolor(61, 122, 188, 200), 1, Raleway12, "right", "center")

							-- Maximum beülő
							guiPosY = guiPosY + guiLineHeight
							dxDrawText("Max. beülő:", guiPosX + respc(5), guiPosY, 0, guiPosY + guiLineHeight, tocolor(200, 200, 200, 200), 1, Raleway12, "left", "center")
							dxDrawText(thousandsStepper(theTablePosition[10]) .. " Coin", 0, guiPosY, guiPosX + guiSizeX - respc(5), guiPosY + guiLineHeight, tocolor(61, 122, 188, 200), 1, Raleway12, "right", "center")

							-- Kisvak értéke
							guiPosY = guiPosY + guiLineHeight
							dxDrawText("Kisvak:", guiPosX + respc(5), guiPosY, 0, guiPosY + guiLineHeight, tocolor(200, 200, 200, 200), 1, Raleway12, "left", "center")
							dxDrawText(thousandsStepper(theTablePosition[7]) .. " Coin", 0, guiPosY, guiPosX + guiSizeX - respc(5), guiPosY + guiLineHeight, tocolor(61, 122, 188, 200), 1, Raleway12, "right", "center")

							-- Nagyvak értéke
							guiPosY = guiPosY + guiLineHeight
							dxDrawText("Nagyvak:", guiPosX + respc(5), guiPosY, 0, guiPosY + guiLineHeight, tocolor(200, 200, 200, 200), 1, Raleway12, "left", "center")
							dxDrawText(thousandsStepper(theTablePosition[8]) .. " Coin", 0, guiPosY, guiPosX + guiSizeX - respc(5), guiPosY + guiLineHeight, tocolor(61, 122, 188, 200), 1, Raleway12, "right", "center")
						end
					end
				end
			end
		end

		if nearbyTableId then
			oldActiveButton = activeButton
			activeButton = false
			activeButtonC = false

			for buttonKey, buttonInfo in pairs(buttons) do
				if absX >= buttonInfo[1] and absX <= buttonInfo[1] + buttonInfo[3] and absY >= buttonInfo[2] and absY <= buttonInfo[2] + buttonInfo[4] then
					activeButton = buttonKey
					break
				end
			end

			for buttonKey, buttonInfo in pairs(buttonsC) do
				if absX >= buttonInfo[1] and absX <= buttonInfo[1] + buttonInfo[3] and absY >= buttonInfo[2] and absY <= buttonInfo[2] + buttonInfo[4] then
					activeButtonC = buttonKey
					break
				end
			end

			if activeButton then
				if oldActiveButton ~= activeButton then
					if string.find(activeButton, "pot") then
						--playSound("files/sounds/butmousenavi.mp3")
						triggerEvent("onHoverButtonPlaySound", localPlayer)
					elseif activeButton == "fold" or activeButton == "check" or activeButton == "raise" or activeButton == "startGame" or activeButton == "quitGame" then
						--playSound("files/sounds/butmousenavi.mp3")
						triggerEvent("onHoverButtonPlaySound", localPlayer)
					end
				end
			end
		end
	end
)

addEvent("pokerChatMessage", true)
addEventHandler("pokerChatMessage", resourceRoot,
	function (textMessage)
		if textMessage then
			addPokerChatLine(textMessage)
		end
	end
)

addEvent("playPokerSound", true)
addEventHandler("playPokerSound", resourceRoot,
	function (tableId, soundName)
		if tableId then
			if soundName then
				local theDealerPosition = realDealerPositions[tableId]

				if theDealerPosition then
					local soundList = {soundName}

					if soundName == "fold" then
						soundList = {"sayfold", "sayfolds"}
					elseif soundName == "call" then
						soundList = {"saycall", "saycalls"}
					elseif soundName == "raise" then
						soundList = {"sayraise", "sayraises"}
					elseif soundName == "check" then
						soundList = {"saycheck", "saychecks"}
					elseif soundName == "pot" then
						soundList = {"pot1", "pot2"}
					elseif soundName == "chip" then
						soundList = {"chip1", "chip3", "chip4", "chip5mp3", "chip6"}
					end

					local soundEffect = playSound3D("files/sounds/" .. soundList[math.random(1, #soundList)] .. ".mp3", theDealerPosition[1], theDealerPosition[2], theDealerPosition[3])

					if isElement(soundEffect) then
						setElementInterior(soundEffect, tablePositions[tableId][5])
						setElementDimension(soundEffect, tablePositions[tableId][6])
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", resourceRoot,
	function ()
		local tableId = getElementData(source, "pokerTableObjectId")

		if tableId then
			streamedPokerTables[source] = tableId

			if not cardLineRenderTargets[tableId] then
				cardLineRenderTargets[tableId] = dxCreateRenderTarget(388, 100, true)
			end

			if not realPlayerCardRenderTargets[tableId] then
				realPlayerCardRenderTargets[tableId] = {}
			end

			for i = 1, maximumPlayers do
				if not realPlayerCardRenderTargets[tableId][i] then
					realPlayerCardRenderTargets[tableId][i] = dxCreateRenderTarget(160, 100, true)
				end
			end

			processRenderTargets(tableId)
		end
	end
)

function processCoins(pokerTableId, pokerTableSeat, pokerCoins, isRoundCall, isMatchOver)
	local coinRoundCallIndex = pokerTableSeat

	if not realCoinAmounts[pokerTableId] then
		realCoinAmounts[pokerTableId] = {}
	end

	if not realCoinObjects[pokerTableId] then
		realCoinObjects[pokerTableId] = {}
	end

	if not realCoinObjects[pokerTableId][pokerTableSeat] then
		realCoinObjects[pokerTableId][pokerTableSeat] = {}
	end

	if tonumber(pokerTableSeat) then
		if not realCoinObjects[pokerTableId]["win" .. pokerTableSeat] then
			realCoinObjects[pokerTableId]["win" .. pokerTableSeat] = {}
		end

		coinRoundCallIndex = pokerTableSeat + maximumPlayers

		if isRoundCall then
			realCoinAmounts[pokerTableId][coinRoundCallIndex] = pokerCoins
		end

		if not realCoinObjects[pokerTableId][coinRoundCallIndex] then
			realCoinObjects[pokerTableId][coinRoundCallIndex] = {}
		end
	elseif pokerTableSeat == "pot" then
		realCoinAmounts[pokerTableId]["pot"] = pokerCoins
	end

	if not realCoinTimers[pokerTableId] then
		realCoinTimers[pokerTableId] = {}
	end

	if not isRoundCall then
		if pokerTableSeat == "pot" then
			setTimer(
				function ()
					if realCoinObjects[pokerTableId] then
						local theCoinObjects = realCoinObjects[pokerTableId][pokerTableSeat]

						if theCoinObjects then
							for i = 1, #theCoinObjects do
								if isElement(theCoinObjects[i]) then
									destroyElement(theCoinObjects[i])
								end
							end
						end

						realCoinObjects[pokerTableId][pokerTableSeat] = {}
					end

					if realCoinObjectsEx[pokerTableId] then
						for _, objectElement in pairs(realCoinObjectsEx[pokerTableId]) do
							if isElement(objectElement) then
								destroyElement(objectElement)
							end
						end
						realCoinObjectsEx[pokerTableId] = nil
					end
				end,
			1100, 1)
		elseif isMatchOver then
			setTimer(
				function ()
					if realCoinObjects[pokerTableId] then
						local theWinCoinObjects = realCoinObjects[pokerTableId]["win" .. pokerTableSeat]

						if theWinCoinObjects then
							for i = 1, #theWinCoinObjects do
								if isElement(theWinCoinObjects[i]) then
									destroyElement(theWinCoinObjects[i])
								end
							end
						end

						realCoinObjects[pokerTableId]["win" .. pokerTableSeat] = {}
					end
				end,
			1200, 1)

			if realCoinObjects[pokerTableId] then
				local thePotCoinObjects = realCoinObjects[pokerTableId]["pot"]

				if thePotCoinObjects then
					for i = 1, #thePotCoinObjects do
						if isElement(thePotCoinObjects[i]) then
							destroyElement(thePotCoinObjects[i])
						end
					end
				end

				realCoinObjects[pokerTableId]["pot"] = {}
			end
		else
			if realCoinObjects[pokerTableId] then
				local theCoinObjects = realCoinObjects[pokerTableId][pokerTableSeat]
				if theCoinObjects then
					for i = 1, #theCoinObjects do
						if isElement(theCoinObjects[i]) then
							destroyElement(theCoinObjects[i])
						end
					end
				end

				realCoinObjects[pokerTableId][pokerTableSeat] = {}

				local theCallCoinObjects = realCoinObjects[pokerTableId][coinRoundCallIndex]
				if theCallCoinObjects then
					for i = 1, #theCallCoinObjects do
						if isElement(theCallCoinObjects[i]) then
							destroyElement(theCallCoinObjects[i])
						end
					end
				end

				realCoinObjects[pokerTableId][coinRoundCallIndex] = {}
			end
		end
	elseif not pokerCoins or pokerCoins <= 0 then
		if realCoinObjects[pokerTableId] then
			local theCallCoinObjects = realCoinObjects[pokerTableId][coinRoundCallIndex]

			if theCallCoinObjects then
				for i = 1, #theCallCoinObjects do
					if isElement(theCallCoinObjects[i]) then
						destroyElement(theCallCoinObjects[i])
					end
				end
			end

			realCoinObjects[pokerTableId][coinRoundCallIndex] = {}
		end
	else
		if realCoinTimers[pokerTableId] then
			realCoinTimers[pokerTableId][coinRoundCallIndex] = setTimer(
				function ()
					if realCoinObjects[pokerTableId] then
						local theCallCoinObjects = realCoinObjects[pokerTableId][coinRoundCallIndex]

						if theCallCoinObjects then
							for i = 1, #theCallCoinObjects do
								if isElement(theCallCoinObjects[i]) then
									destroyElement(theCallCoinObjects[i])
								end
							end
						end

						realCoinObjects[pokerTableId][coinRoundCallIndex] = {}
					end
				end,
			1000, 1)
		end
	end

	if not pokerCoins then
		return
	end

	if pokerCoins <= 0 then
		return
	end

	local stackValue = pokerCoins

	if stackValue > 3000 then
		stackValue = 3000
	end

	local coinPosition = false

	if realCoinPositions[pokerTableId] then
		coinPosition = realCoinPositions[pokerTableId][pokerTableSeat]
	end

	if not coinPosition then
		return
	end

	if pokerTableSeat ~= "pot" then
		processCoins2(pokerTableId, pokerTableSeat, pokerCoins, isRoundCall, isMatchOver, coinPosition, stackValue)
	end

	if pokerTableSeat == "pot" then
		for i = 1, maximumPlayers do
			if realCoinObjects[pokerTableId] then
				local theCallCoinObjects = realCoinObjects[pokerTableId][i + maximumPlayers]

				if theCallCoinObjects then
					for j = 1, #theCallCoinObjects do
						local objectElement = theCallCoinObjects[j]

						if isElement(objectElement) then
							local objectX, objectY, objectZ = getElementPosition(objectElement)

							if realCoinTimers[pokerTableId] then
								local theCoinTimer = realCoinTimers[pokerTableId][i + maximumPlayers]

								if theCoinTimer then
									if isTimer(theCoinTimer) then
										killTimer(theCoinTimer)
									end
								end

								realCoinTimers[pokerTableId][i + maximumPlayers] = nil
							end

							stopObject(objectElement)
							setTimer(
								function ()
									if isElement(objectElement) then
										if realCoinPositions[pokerTableId] then
											local theCoinPosition = realCoinPositions[pokerTableId]["pot"]

											if theCoinPosition then
												moveObject(objectElement, 1000, theCoinPosition[1 + (j - 1) * 2], theCoinPosition[2 + (j - 1) * 2], objectZ)
											end
										end
									end
								end,
							100, 1)
						end
					end

					setTimer(
						function ()
							if realCoinObjects[pokerTableId] then
								local theCallCoinObjects = realCoinObjects[pokerTableId][i + maximumPlayers]
								if theCallCoinObjects then
									for j = 1, #theCallCoinObjects do
										if isElement(theCallCoinObjects[j]) then
											destroyElement(theCallCoinObjects[j])
										end
									end
								end

								realCoinObjects[pokerTableId][i + maximumPlayers] = {}

								local theCoinObjects = realCoinObjects[pokerTableId][pokerTableSeat]
								if theCoinObjects then
									for j = 1, #theCoinObjects do
										if isElement(theCoinObjects[j]) then
											destroyElement(theCoinObjects[j])
										end
									end
								end

								realCoinObjects[pokerTableId][pokerTableSeat] = {}
							end

							processCoins2(pokerTableId, pokerTableSeat, pokerCoins, isRoundCall, isMatchOver, coinPosition, stackValue)
						end,
					1200, 1)
				end
			end
		end
	end
end

function processCoins2(pokerTableId, pokerTableSeat, pokerCoins, isRoundCall, isMatchOver, coinPosition, stackValue, stackModelId, coinIndex)
	local stackOffsetZ = 0.15 * (1 - stackValue / 3000)

	if isMatchOver then
		if realCoinPositions[pokerTableId] then
			coinPosition = realCoinPositions[pokerTableId]["pot"]
		end
	end

	if not coinPosition then
		return
	end

	if not coinIndex then
		coinIndex = 0
	end

	if not stackModelId then
		stackModelId = 1877
	end

	local objectElement = createObject(stackModelId, coinPosition[coinIndex + 1], coinPosition[coinIndex + 2], coinPosition[7] - stackOffsetZ)

	if isElement(objectElement) then
		setObjectScale(objectElement, 0.3)
		setElementInterior(objectElement, tablePositions[pokerTableId][5])
		setElementDimension(objectElement, tablePositions[pokerTableId][6])

		if not isRoundCall then
			if pokerTableSeat == "pot" then
				setTimer(
					function ()
						if realCoinObjects[pokerTableId] then
							if realCoinObjects[pokerTableId][pokerTableSeat] then
								table.insert(realCoinObjects[pokerTableId][pokerTableSeat], objectElement)
							end
						end
					end,
				1200, 1)
			else
				if realCoinObjects[pokerTableId] then
					if realCoinObjects[pokerTableId][pokerTableSeat] then
						table.insert(realCoinObjects[pokerTableId][pokerTableSeat], objectElement)
					end
				end
			end

			if isMatchOver then
				setTimer(
					function ()
						if realCoinObjects[pokerTableId] then
							if realCoinObjects[pokerTableId]["win" .. pokerTableSeat] then
								table.insert(realCoinObjects[pokerTableId]["win" .. pokerTableSeat], objectElement)
							end
						end
					end,
				1000, 1)
			end
		else
			setTimer(
				function ()
					if realCoinObjects[pokerTableId] then
						if realCoinObjects[pokerTableId][pokerTableSeat + maximumPlayers] then
							table.insert(realCoinObjects[pokerTableId][pokerTableSeat + maximumPlayers], objectElement)
						end
					end
				end,
			1000, 1)

			if not realCoinObjectsEx[pokerTableId] then
				realCoinObjectsEx[pokerTableId] = {}
			end

			realCoinObjectsEx[pokerTableId][pokerTableSeat] = objectElement
		end

		if isRoundCall then
			if realCoinPositions[pokerTableId] then
				local theCoinPosition = realCoinPositions[pokerTableId][pokerTableSeat + maximumPlayers]

				if theCoinPosition then
					moveObject(objectElement, 1000, theCoinPosition[coinIndex + 1], theCoinPosition[coinIndex + 2], theCoinPosition[7] - stackOffsetZ)
				end
			end
		end

		if isMatchOver then
			if realCoinPositions[pokerTableId] then
				local theCoinPosition = realCoinPositions[pokerTableId][pokerTableSeat]

				if theCoinPosition then
					moveObject(objectElement, 1000, theCoinPosition[coinIndex + 1], theCoinPosition[coinIndex + 2], theCoinPosition[7] - stackOffsetZ)
				end
			end
		end
	end

	if not pokerCoins then
		return
	end

	if pokerCoins >= 3000 then
		stackValue = pokerCoins - 3000

		if stackValue > 3000 then
			stackValue = 3000
		end

		processCoins2(pokerTableId, pokerTableSeat, false, isRoundCall, isMatchOver, coinPosition, stackValue, 1879, 2)
	end

	if pokerCoins >= 6000 then
		stackValue = pokerCoins - 6000

		if stackValue > 3000 then
			stackValue = 3000
		end

		processCoins2(pokerTableId, pokerTableSeat, false, isRoundCall, isMatchOver, coinPosition, stackValue, 1880, 4)
	end
end

function processDataChange(dataName, oldValue)
	if dataName == "pokerTableId" then
		local pokerTableId = getElementData(source, "pokerTableId")

		if not pokerTableId then
			local pokerTableSeat = getElementData(source, "pokerTableSeat")

			if pokerTableSeat then
				if realPlayerCards[oldValue] then
					realPlayerCards[oldValue][pokerTableSeat] = nil
				end

				processCoins(oldValue, pokerTableSeat, nil, false)
				processCoins(oldValue, pokerTableSeat, nil, true)
			end
		end
	end

	if source == resourceRoot then
		local dataNameParts = split(dataName, ".")
		local pokerTableId = tonumber(dataNameParts[2])
		local pokerTableSeat = tonumber(dataNameParts[4])

		if string.find(dataName, ".pot") then
			if joinedTableId == pokerTableId then
				pokerPotAmount = getPokerBoardData(pokerTableId, "pot") or 0
			end
		elseif string.find(dataName, ".pokerCoins") then
			if pokerTableId then
				if pokerTableSeat then
					local pokerCoins = getPokerSeatData(pokerTableId, pokerTableSeat, "pokerCoins") or 0

					if pokerCoins then
						processCoins(pokerTableId, pokerTableSeat, pokerCoins, false)
					end
				end
			end
		elseif string.find(dataName, ".roundCall") then
			if string.find(dataName, ".seat.") then
				if pokerTableId then
					if pokerTableSeat then
						local pokerCoins = getPokerSeatData(pokerTableId, pokerTableSeat, "roundCall") or 0

						if pokerCoins <= 0 then
							if not realCoinAmounts[pokerTableId] then
								realCoinAmounts[pokerTableId] = {}
							end

							realCoinAmounts[pokerTableId][pokerTableSeat + maximumPlayers] = 0
						else
							processCoins(pokerTableId, pokerTableSeat, pokerCoins, true)
							triggerEvent("playPokerSound", resourceRoot, pokerTableId, "chip")
						end
					end
				end
			end
		elseif string.find(dataName, ".smallBlind") then
			if pokerTableId then
				local pokerTableSeat = tonumber(getPokerBoardData(pokerTableId, "smallBlind"))

				if pokerTableSeat then
					local theBlindPosition = realBlindPositions[pokerTableId][pokerTableSeat]

					if theBlindPosition then
						if not smallBlindObjects[pokerTableId] then
							smallBlindObjects[pokerTableId] = createObject(smallBlindObjectModelId, theBlindPosition[1], theBlindPosition[2], theBlindPosition[3], 0, 0, math.random(360))
						end

						if isElement(smallBlindObjects[pokerTableId]) then
							setElementPosition(smallBlindObjects[pokerTableId], theBlindPosition[1], theBlindPosition[2], theBlindPosition[3])
							setElementInterior(smallBlindObjects[pokerTableId], tablePositions[pokerTableId][5])
							setElementDimension(smallBlindObjects[pokerTableId], tablePositions[pokerTableId][6])
							setObjectScale(smallBlindObjects[pokerTableId], 0.4)
						end
					end
				else
					if isElement(smallBlindObjects[pokerTableId]) then
						destroyElement(smallBlindObjects[pokerTableId])
					end

					smallBlindObjects[pokerTableId] = nil
				end
			end
		elseif string.find(dataName, ".bigBlind") then
			if pokerTableId then
				local pokerTableSeat = tonumber(getPokerBoardData(pokerTableId, "bigBlind"))

				if pokerTableSeat then
					local theBlindPosition = realBlindPositions[pokerTableId][pokerTableSeat]

					if theBlindPosition then
						if not bigBlindObjects[pokerTableId] then
							bigBlindObjects[pokerTableId] = createObject(bigBlindObjectModelId, theBlindPosition[1], theBlindPosition[2], theBlindPosition[3], 0, 0, math.random(360))
						end

						if isElement(bigBlindObjects[pokerTableId]) then
							setElementPosition(bigBlindObjects[pokerTableId], theBlindPosition[1], theBlindPosition[2], theBlindPosition[3])
							setElementInterior(bigBlindObjects[pokerTableId], tablePositions[pokerTableId][5])
							setElementDimension(bigBlindObjects[pokerTableId], tablePositions[pokerTableId][6])
							setObjectScale(bigBlindObjects[pokerTableId], 0.4)
						end
					end
				else
					if isElement(bigBlindObjects[pokerTableId]) then
						destroyElement(bigBlindObjects[pokerTableId])
					end

					bigBlindObjects[pokerTableId] = nil
				end
			end
		elseif string.find(dataName, ".showdown") then
			if pokerTableId then
				pokerShowDown[pokerTableId] = getPokerBoardData(pokerTableId, "showdown")
			end
		elseif string.find(dataName, ".win") then
			if pokerTableId then
				if pokerTableSeat then
					local pokerCoins = getElementData(source, dataName) or 0

					if pokerCoins > 0 then
						processCoins(pokerTableId, pokerTableSeat, pokerCoins, false, true)
						triggerEvent("playPokerSound", resourceRoot, pokerTableId, "chip")
					end
				end
			end
		elseif string.find(dataName, ".gameStage") then
			if pokerTableId then
				local currentGameStage = tonumber(getElementData(source, dataName)) or 0

				if currentGameStage == 0 then
					processCoins(pokerTableId, "pot", false, false)
				elseif currentGameStage > 0 then
					local oldGameStage = tonumber(oldValue) or 0

					if currentGameStage > oldGameStage then
						local pokerCoins = getPokerBoardData(pokerTableId, "pot") or 0

						if pokerCoins then
							processCoins(pokerTableId, "pot", pokerCoins, false)
							triggerEvent("playPokerSound", resourceRoot, pokerTableId, "chip")
						end
					end
				end
			end
		end

		if string.find(dataName, ".boardCards") or string.find(dataName, ".gameStage") then
			if pokerTableId then
				processRenderTargets(pokerTableId)
			end
		elseif string.find(dataName, ".pokerCards") and string.find(dataName, ".seat.") then
			if pokerTableId then
				processRenderTargets(pokerTableId)
			end
		end
	end

	if dataName == "pokerTableId" or dataName == "pokerTableSeat" or string.find(dataName, ".pokerCards") then
		local pokerTableId = getElementData(source, "pokerTableId")
		local pokerTableSeat = getElementData(source, "pokerTableSeat")

		if not pokerTableId then
			if not pokerTableSeat then
				local dataNameParts = split(dataName, ".")

				pokerTableId = tonumber(dataNameParts[2])
				pokerTableSeat = tonumber(dataNameParts[4])
			end
		end

		if pokerTableId then
			if pokerTableSeat then
				local pokerCards = getPokerSeatData(pokerTableId, pokerTableSeat, "pokerCards") or {}

				if not realPlayerCards[pokerTableId] then
					realPlayerCards[pokerTableId] = {}
				end

				if #pokerCards ~= 0 then
					realPlayerCards[pokerTableId][pokerTableSeat] = {getTickCount(), 1}
					triggerEvent("playPokerSound", resourceRoot, pokerTableId, "dealer2lap")
					setTimer(triggerEvent, 750, 1, "playPokerSound", resourceRoot, pokerTableId, "dealer2lap")
				else
					if realPlayerCards[pokerTableId][pokerTableSeat] then
						realPlayerCards[pokerTableId][pokerTableSeat] = {"back", getTickCount(), 1}
						triggerEvent("playPokerSound", resourceRoot, pokerTableId, "dealer2lap")
					else
						realPlayerCards[pokerTableId][pokerTableSeat] = nil
					end
				end
			end
		end
	end
end

function processRenderTargets(pokerTableId)
	if realPlayerCardRenderTargets[pokerTableId] then
		for i = 1, maximumPlayers do
			local renderTarget = realPlayerCardRenderTargets[pokerTableId][i]

			if isElement(renderTarget) then
				local pokerCards = getPokerSeatData(pokerTableId, i, "pokerCards") or {}

				if #pokerCards > 0 then
					dxSetRenderTarget(renderTarget, true)

					for j = 1, 2 do
						local currentCard = pokerCards[j]

						if currentCard then
							dxDrawImage(80 * (j - 1), 0, 68, 100, "files/cards/" .. cardRanks[currentCard[1]] .. "-" .. currentCard[2] .. ".png")
						end
					end

					dxSetRenderTarget()
				end
			end
		end
	end

	local gameStage = getPokerBoardData(pokerTableId, "gameStage") or 0
	local boardCards = getPokerBoardData(pokerTableId, "boardCards") or {}
	local numOfCards = 0

	if gameStage == 1 then
		numOfCards = 3
	elseif gameStage == 2 then
		numOfCards = 4
	elseif gameStage >= 3 then
		numOfCards = 5
	end

	if isElement(cardLineRenderTargets[pokerTableId]) then
		dxSetRenderTarget(cardLineRenderTargets[pokerTableId], true)

		for i = 1, numOfCards do
			local currentCard = boardCards[i]

			if currentCard then
				dxDrawImage(80 * (i - 1), 0, 68, 100, "files/cards/" .. cardRanks[currentCard[1]] .. "-" .. currentCard[2] .. ".png")
			end
		end

		dxSetRenderTarget()
	end
end

addEventHandler("onClientRestore", root,
	function ()
		for objectElement, tableId in pairs(streamedPokerTables) do
			processRenderTargets(tableId)
		end
	end
)

function destroyPokerTableStuff(pokerTableId)
	if pokerTableId then
		if cardLineRenderTargets[pokerTableId] then
			if isElement(cardLineRenderTargets[pokerTableId]) then
				destroyElement(cardLineRenderTargets[pokerTableId])
			end

			cardLineRenderTargets[pokerTableId] = nil
		end

		if realPlayerCardRenderTargets[pokerTableId] then
			for k, v in pairs(realPlayerCardRenderTargets[pokerTableId]) do
				if isElement(v) then
					destroyElement(v)
				end
			end

			realPlayerCardRenderTargets[pokerTableId] = nil
		end

		if smallBlindObjects[pokerTableId] then
			if isElement(smallBlindObjects[pokerTableId]) then
				destroyElement(smallBlindObjects[pokerTableId])
			end

			smallBlindObjects[pokerTableId] = nil
		end

		if bigBlindObjects[pokerTableId] then
			if isElement(bigBlindObjects[pokerTableId]) then
				destroyElement(bigBlindObjects[pokerTableId])
			end

			bigBlindObjects[pokerTableId] = nil
		end
	end
end

addEventHandler("onClientElementStreamOut", resourceRoot,
	function ()
		local pokerTableId = streamedPokerTables[source]

		if pokerTableId then
			destroyPokerTableStuff(pokerTableId)
			streamedPokerTables[source] = nil
		end
	end
)

addEventHandler("onClientElementDestroy", resourceRoot,
	function ()
		local pokerTableId = streamedPokerTables[source]

		if pokerTableId then
			destroyPokerTableStuff(pokerTableId)
			streamedPokerTables[source] = nil
		end
	end
)

function render3dCards()
	for objectElement, tableId in pairs(streamedPokerTables) do
		local cardLinePosition = cardLinePositions[tableId]

		dxDrawMaterialLine3D(cardLinePosition[1], cardLinePosition[2], cardLinePosition[3], cardLinePosition[4], cardLinePosition[5], cardLinePosition[3], cardLineRenderTargets[tableId], 0.8, 0xFFFFFFFF, cardLinePosition[6], cardLinePosition[7], cardLinePosition[3] + 1)

		if realPlayerCards[tableId] then
			for seatId, cardInfo in pairs(realPlayerCards[tableId]) do
				local playerCardPosition = realPlayerCardPositions[tableId][seatId]
				local dealerCardPosition = realPlayerCardPositions[tableId][seatId + maximumPlayers]

				if cardInfo[1] == "back" then
					local progress = (getTickCount() - cardInfo[2]) / 750

					local x1, y1, z1 = interpolateBetween(playerCardPosition[1], playerCardPosition[2], 0, dealerCardPosition[1], dealerCardPosition[2], 0, progress, "Linear")
					local x2, y2, z2 = interpolateBetween(playerCardPosition[3], playerCardPosition[4], 0, dealerCardPosition[3], dealerCardPosition[4], 0, progress, "Linear")

					if progress > 1 then
						realPlayerCards[tableId][seatId] = nil
					end

					dxDrawMaterialLine3D(x1, y1, z1 + cardLinePosition[3], x2, y2, z2 + cardLinePosition[3], cardTextures[1], 0.3, 0xFFFFFFFF, x1, y1, z1 + cardLinePosition[3] + 1)
				else
					local totalDuration = cardInfo[1] + cardInfo[2] * 500
					local elapsedTime = getTickCount() - totalDuration

					if elapsedTime >= 750 and cardInfo[2] >= 2 then
						local cardTexture = cardTextures[3]

						if pokerShowDown[tableId] then
							cardTexture = realPlayerCardRenderTargets[tableId][seatId]
						end

						dxDrawMaterialLine3D(playerCardPosition[1], playerCardPosition[2], playerCardPosition[5], playerCardPosition[3], playerCardPosition[4], playerCardPosition[5], cardTexture, 0.3, 0xFFFFFFFF, playerCardPosition[1], playerCardPosition[2], playerCardPosition[5] + 1)
					else
						if cardInfo[2] == 2 then
							dxDrawMaterialLine3D(playerCardPosition[1], playerCardPosition[2], playerCardPosition[5], playerCardPosition[3], playerCardPosition[4], playerCardPosition[5], cardTextures[1], 0.3, 0xFFFFFFFF, playerCardPosition[1], playerCardPosition[2], playerCardPosition[5] + 1)
						else
							if elapsedTime > 750 then
								cardInfo[1] = getTickCount()
								cardInfo[2] = 2
							end
						end

						local progress = (getTickCount() - cardInfo[1]) / 750

						if progress < 0 then
							progress = 0
						end

						local x1, y1, z1 = interpolateBetween(dealerCardPosition[1], dealerCardPosition[2], 0, playerCardPosition[1], playerCardPosition[2], 0, progress, "Linear")
						local x2, y2, z2 = interpolateBetween(dealerCardPosition[3], dealerCardPosition[4], 0, playerCardPosition[3], playerCardPosition[4], 0, progress, "Linear")

						if cardInfo[2] == 2 then
							dxDrawMaterialLine3D(x1, y1, z1 + playerCardPosition[5], x2, y2, z2 + playerCardPosition[5], cardTextures[2], 0.3, 0xFFFFFFFF, x1, y1, z1 + playerCardPosition[5] + 1)
						else
							dxDrawMaterialLine3D(x1, y1, z1 + playerCardPosition[5], x2, y2, z2 + playerCardPosition[5], cardTextures[1], 0.3, 0xFFFFFFFF, x1, y1, z1 + playerCardPosition[5] + 1)
						end
					end
				end
			end
		end
	end
end
