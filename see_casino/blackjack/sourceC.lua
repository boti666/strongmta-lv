local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local placedTable = false
local placementData = false

addCommandHandler("createblackjack",
	function (commandName, minEntry, maxEntry)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			if not placedTable then
				minEntry = tonumber(minEntry)
				maxEntry = tonumber(maxEntry)

				if not minEntry or not maxEntry then
					outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. commandName .. " [Min. tét] [Max. tét]", 255, 255, 255, true)
				else
					if isElement(placedTable) then
						destroyElement(placedTable)
					end

					placementData = {minEntry, maxEntry}
					placedTable = createObject(2188, 0, 0, 0)

					setElementCollisionsEnabled(placedTable, false)
					setElementAlpha(placedTable, 175)
					setElementInterior(placedTable, getElementInterior(localPlayer))
					setElementDimension(placedTable, getElementDimension(localPlayer))

					addEventHandler("onClientRender", getRootElement(), tablePlaceRenderBlackJack)
					addEventHandler("onClientKey", getRootElement(), tablePlaceKeyBlackJack)

					outputChatBox("#3d7abc[StrongMTA - Blackjack]: #ffffffBlackjack létrehozás mód #3d7abcbekapcsolva!", 255, 255, 255, true)
					outputChatBox("#3d7abc[StrongMTA - Blackjack]: #ffffffAz asztal #3d7abclerakásához #ffffffnyomd meg az #3d7abcBAL CTRL #ffffffgombot.", 255, 255, 255, true)
					outputChatBox("#3d7abc[StrongMTA - Blackjack]: #ffffffA #d75959kilépéshez #ffffffírd be a #d75959/" .. commandName .. " #ffffffparancsot.", 255, 255, 255, true)
				end
			else
				removeEventHandler("onClientRender", getRootElement(), tablePlaceRenderBlackJack)
				removeEventHandler("onClientKey", getRootElement(), tablePlaceKeyBlackJack)

				if isElement(placedTable) then
					destroyElement(placedTable)
				end
				placedTable = nil

				outputChatBox("#3d7abc[StrongMTA - Blackjack]: #ffffffBlackjack létrehozás mód #d75959kikapcsolva!", 255, 255, 255, true)
			end
		end
	end)

function tablePlaceRenderBlackJack()
	if placedTable then
		local x, y, z = getElementPosition(localPlayer)
		local rz = select(3, getElementRotation(localPlayer))
		
		setElementPosition(placedTable, x, y, z - 0.1)
		setElementRotation(placedTable, 0, 0, math.ceil(math.floor(rz * 5) / 5))
	end
end

function tablePlaceKeyBlackJack(button, state)
	if isElement(placedTable) then
		if button == "lctrl" and state then
			local x, y, z = getElementPosition(placedTable)
			local rz = select(3, getElementRotation(placedTable))
			local interior = getElementInterior(placedTable)
			local dimension = getElementDimension(placedTable)

			triggerServerEvent("placeBlackjackTable", localPlayer, {x, y, z, rz, interior, dimension, placementData[1], placementData[2]})

			if isElement(placedTable) then
				destroyElement(placedTable)
			end
			placedTable = nil

			removeEventHandler("onClientRender", getRootElement(), tablePlaceRenderBlackJack)
			removeEventHandler("onClientKey", getRootElement(), tablePlaceKeyBlackJack)
		end
	end
end

addCommandHandler("nearbyblackjack",
	function (commandName, maxDistance)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local nearby = {}

			maxDistance = tonumber(maxDistance) or 15

			for i, v in ipairs(getElementsByType("object", resourceRoot, true)) do
				local tableIdB = getElementData(v, "blackjackTable")

				if tableIdB then
					local targetX, targetY, targetZ = getElementPosition(v)
					local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

					if distance <= maxDistance then
						table.insert(nearby, {tableIdB, distance})
					end
				end
			end

			if #nearby > 0 then
				outputChatBox("#3d7abc[StrongMTA - Blackjack]: #ffffffKözeledben lévő asztalok (" .. maxDistance .. " yard):", 255, 255, 255, true)

				for i, v in ipairs(nearby) do
					outputChatBox("    * #3d7abcAzonosító: #ffffff" .. v[1] .. " - " .. math.floor(v[2] * 500) / 500 .. " yard", 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[StrongMTA - Blackjack]: #ffffffNincs egyetlen asztal sem a közeledben.", 255, 255, 255, true)
			end
		end
	end)

local tablePositionsB = {}

local blackjackId = false
local blackjackData = false
local mySlotCoins = 0

local sliderMoveX = false
local sliderValue = 0
local sliderAmount = 0

local buttons = {}
local activeButton = false
local lastActiveButton = false

local blackjackBoard = {}
local boardCards = {}
local realBoardCardsB = {}

local cardTextures = {
	back = dxCreateTexture("files/cards/back.png")
}

for i = 1, #cardRanksB do
	for j = 1, 4 do
		cardTextures[cardRanksB[i] .. "-" .. j] = dxCreateTexture("files/cards/" .. cardRanksB[i] .. "-" .. j .. ".png")
	end
end

local cardPositionsB = {}
cardPositionsB.deck = {0.7, -0.1, 0}
cardPositionsB.dealer = {0.1, -0.6, 0}
cardPositionsB.player = {0.1, -1.03, 0}
local realcardPositionsBBlackJack = {}

function generateTablesB()
	for tableIdB, data in pairs(tablePositionsB) do
		realcardPositionsBBlackJack[tableIdB] = {}
		for cardType, offset in pairs(cardPositionsB) do
			local startX, startY = rotateAround(data[4], rotateAround(offset[3], 0, 0.105, offset[1], offset[2]))
			local endX, endY = rotateAround(data[4], rotateAround(offset[3], 0, -0.045, offset[1], offset[2]))

			realcardPositionsBBlackJack[tableIdB][cardType] = {data[1] + startX, data[2] + startY, data[1] + endX, data[2] + endY, data[3] + 0.02}
		end
	end
end

local hudState = true

local buttonWidth = respc(100)
local buttonHeight = respc(40)
local buttonPosX = screenX
local buttonPosY = screenY - respc(15) - buttonHeight - respc(30)
local buttonsActive = true
local actionButtons = {
	{"hit", "Lapkérés", 61, 123, 188},
	{"stay", "Megállás", 89, 142, 215},
	{"double", "Duplázás", 61, 123, 188},
	{"surrender", "Feladás", 215, 89, 89}
}

local chatWidth = respc(350)
local chatHeight = respc(20) * 7
local chatPosX = screenX - respc(350) - respc(35)
local chatPosY = buttonPosY - chatHeight - respc(30)
local chatLines = {}
local chatOffset = 0

function addChatHistory(text, showtime)
	if showtime then
		local currentTime = getRealTime()
		text = "#3d7abc[" .. string.format("%02d:%02d", currentTime.hour, currentTime.minute) .. "]: " .. text
	end

	local lines = {text}

	for i = 1, #chatLines do
		if i > 50 then
			break
		end

		if chatLines[i] then
			table.insert(lines, chatLines[i])
		end
	end

	chatLines = lines
end

addEvent("addBlackjackHistory", true)
addEventHandler("addBlackjackHistory", getRootElement(),
	function (text)
		addChatHistory(text, true)
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 1000, 1, "requestBlackjackTables", localPlayer)

		if getElementData(localPlayer, "playerUsingBlackjack") then
			setElementData(localPlayer, "playerUsingBlackjack", false)
		end
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if not hudState then
			exports.see_hud:showHUD()
			hudState = true

			setElementFrozen(localPlayer, false)
			setPedAnimation(localPlayer)
		end
	end)

addEvent("requestBlackjackTables", true)
addEventHandler("requestBlackjackTables", getRootElement(),
	function(datas)
		tablePositionsB = datas
		generateTablesB()
	end)

addEvent("createBlackjackTable", true)
addEventHandler("createBlackjackTable", getRootElement(),
	function (tableIdB, data)
		if tableIdB and data then
			tablePositionsB[tableIdB] = data
			generateTablesB()
		end
	end)

addEvent("deleteBlackjackTable", true)
addEventHandler("deleteBlackjackTable", getRootElement(),
	function (tableIdB)
		if tableIdB then
			tablePositionsB[tableIdB] = nil
			realDealerPosition[tableIdB] = nil
			realcardPositionsBBlackJack[tableIdB] = nil
			blackjackBoard[tableIdB] = nil
			realBoardCardsB[tableIdB] = nil
		end
	end)

addEvent("updateBlackjackTable", true)
addEventHandler("updateBlackjackTable", getRootElement(),
	function (tableIdB, data)
		if tableIdB and data then
			tablePositionsB[tableIdB] = data
			generateTablesB()
		end
	end)

addEvent("openBlackjackGame", true)
addEventHandler("openBlackjackGame", getRootElement(),
	function (data)
		blackjackId = data.tableIdB
		blackjackData = data
		mySlotCoins = getElementData(localPlayer, "char.slotCoins") or 0

		sliderMoveX = false
		sliderValue = 0

		if hudState then
			exports.see_hud:hideHUD()
			hudState = false
		end

		addEventHandler("onClientRender", getRootElement(), renderBlackjack)
		addEventHandler("onClientClick", getRootElement(), clickBlackjack)
		addEventHandler("onClientKey", getRootElement(), chatScroll)
	end)

function closeTheBlackJackTable()
	if not hudState then
		exports.see_hud:showHUD()
		hudState = true
	end

	triggerServerEvent("closeBlackjackGame", localPlayer)
	
	removeEventHandler("onClientRender", getRootElement(), renderBlackjack)
	removeEventHandler("onClientClick", getRootElement(), clickBlackjack)
	removeEventHandler("onClientKey", getRootElement(), chatScroll)

	blackjackId = false
	blackjackData = false

	sliderMoveX = false
	sliderValue = 0

	chatLines = {}
	chatOffset = 0
end

function chatScroll(key, press)
	if press and activeButton == "chatscroll" then
		if key == "mouse_wheel_up" then
			if chatOffset < #chatLines - 7 then
				chatOffset = chatOffset + 1
			end
		elseif key == "mouse_wheel_down" then
			if chatOffset > 0 then
				chatOffset = chatOffset - 1
			end
		end
	end
end

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		if getElementModel(source) == 2188 then
			local data = getElementData(source, "blackjackData")

			if data and data.tableIdB then
				blackjackBoard[data.tableIdB] = data
			end
		end
	end)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
	function ()
		if getElementModel(source) == 2188 then
			local data = getElementData(source, "blackjackData")

			if data and data.tableIdB then
				blackjackBoard[data.tableIdB] = nil
			end
		end
	end)

addEventHandler("onClientElementDestroy", getResourceRootElement(),
	function ()
		if getElementModel(source) == 2188 then
			local data = getElementData(source, "blackjackData")

			if data and data.tableIdB then
				blackjackBoard[data.tableIdB] = nil
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldVal)
		if source == localPlayer then
			if dataName == "char.slotCoins" then
				mySlotCoins = getElementData(localPlayer, dataName) or 0
			end
		elseif dataName == "blackjackData" then
			local dataVal = getElementData(source, dataName)

			if not dataVal then
				return
			end

			local tableIdB = dataVal.tableIdB

			if blackjackId and tableIdB == blackjackId and (not dataVal.currentPlayer or dataVal.currentPlayer ~= localPlayer) then
				closeTheBlackJackTable()
				return
			end

			if blackjackData and blackjackData.tableIdB == tableIdB then
				blackjackData = dataVal

				if dataVal.gameStage == 0 and oldVal.gameStage ~= 0 then
					chatLines = {}
					chatOffset = 0
				end
			end

			boardCards[tableIdB] = {}
			boardCards[tableIdB].dealerCards = dataVal.dealerCards
			boardCards[tableIdB].playerCards = dataVal.playerCards

			if isElementStreamedIn(source) then
				blackjackBoard[tableIdB] = getElementData(source, "blackjackData")

				-- új kör
				if oldVal and oldVal.gameStage == 0 and dataVal.gameStage ~= 0 then
					blackjackBoard[tableIdB].dealerCards = {}
					blackjackBoard[tableIdB].playerCards = {}
					realBoardCardsB[tableIdB] = {}

					if dataVal.currentPlayer == localPlayer then
						addChatHistory("#7bbc3dÚj kör kezdődik.", true)
						addChatHistory("A dealer kiosztja a kártyákat.", true)
					end

					insertDealerCard(tableIdB, dataVal.dealerCards, 1)

					setTimer(
						function ()
							insertDealerCard(tableIdB, dataVal.dealerCards, 2, "back")
							insertPlayerCard(tableIdB, dataVal.playerCards, 1)

							setTimer(
								function ()
									insertPlayerCard(tableIdB, dataVal.playerCards, 2)
								end,
							1700, 1)
						end,
					850, 1)
				-- játék
				elseif dataVal.gameStage ~= 0 then
					if not table_eq(oldVal.playerCards, dataVal.playerCards) and #dataVal.playerCards > 2 then
						blackjackBoard[tableIdB].playerCards = oldVal.playerCards
						insertPlayerCard(tableIdB, dataVal.playerCards, #boardCards[tableIdB].playerCards)
					end

					if oldVal.dealerCards ~= dataVal.dealerCards and oldVal.gameStage ~= dataVal.gameStage and dataVal.gameStage ~= 2 then
						blackjackBoard[tableIdB].dealerCards = oldVal.dealerCards
						insertDealerCard(tableIdB, dataVal.dealerCards, #boardCards[tableIdB].dealerCards)
					end
				-- játék vége
				elseif dataVal.gameStage == 0 then
					blackjackBoard[tableIdB].dealerCards = {}
					blackjackBoard[tableIdB].playerCards = {}
					realBoardCardsB[tableIdB] = {}
				end
			end
		end
	end)

function insertDealerCard(tableIdB, cards, slot, side)
	local picture = "back"

	if not side or side ~= "back" then
		picture = cardRanksB[cards[slot][1]] .. "-" .. cards[slot][2]
	end

	local x1, y1 = rotateAround(tablePositionsB[tableIdB][4], 0.15 * (#blackjackBoard[tableIdB].dealerCards + 1) / 2, 0)
	local x2, y2 = rotateAround(tablePositionsB[tableIdB][4], (slot - 1) * 0.125, 0)
	local pos = realcardPositionsBBlackJack[tableIdB]

	table.insert(realBoardCardsB[tableIdB], {
		theType = "dealer",
		startTick = getTickCount(),
		texture = picture,
		start = {pos.deck[1], pos.deck[2], pos.deck[5], pos.deck[3], pos.deck[4], pos.deck[5]},
		stop = {
			pos.dealer[1] - x1 + x2, pos.dealer[2] - y1 + y2, pos.dealer[5],
			pos.dealer[3] - x1 + x2, pos.dealer[4] - y1 + y2, pos.dealer[5]
		},
		execute = function (tableIdB)
			table.insert(blackjackBoard[tableIdB].dealerCards, boardCards[tableIdB].dealerCards[slot])
		end
	})
end

function insertPlayerCard(tableIdB, cards, slot, side)
	local picture = "back"

	if not side or side ~= "back" then
		picture = cardRanksB[cards[slot][1]] .. "-" .. cards[slot][2]
	end

	local x1, y1 = rotateAround(tablePositionsB[tableIdB][4], 0.15 * (#blackjackBoard[tableIdB].playerCards + 1) / 2, 0)
	local x2, y2 = rotateAround(tablePositionsB[tableIdB][4], (slot - 1) * 0.125, 0)
	local pos = realcardPositionsBBlackJack[tableIdB]

	table.insert(realBoardCardsB[tableIdB], {
		theType = "player",
		startTick = getTickCount(),
		texture = picture,
		start = {pos.deck[1], pos.deck[2], pos.deck[5], pos.deck[3], pos.deck[4], pos.deck[5]},
		stop = {
			pos.player[1] - x1 + x2, pos.player[2] - y1 + y2, pos.player[5],
			pos.player[3] - x1 + x2, pos.player[4] - y1 + y2, pos.player[5]
		},
		execute = function (tableIdB)
			table.insert(blackjackBoard[tableIdB].playerCards, boardCards[tableIdB].playerCards[slot])
		end
	})
end

addEvent("playBlackjackSound", true)
addEventHandler("playBlackjackSound", getRootElement(),
	function (tableIdB, path)
		if tableIdB and path then
			if tablePositionsB[tableIdB] then
				local sound = playSound3D("files/sounds/" .. path .. ".mp3", tablePositionsB[tableIdB][1], tablePositionsB[tableIdB][2], tablePositionsB[tableIdB][3])
				
				setElementInterior(sound, tablePositionsB[tableIdB][5])
				setElementDimension(sound, tablePositionsB[tableIdB][6])

				if path ~= "newcardintable" then
					setSoundVolume(sound, 0.25)
				end
			end
		end
	end)

function clickBlackjack(button, state)
	if button == "left" then
		if state == "down" then
			if activeButton == "quitGame" then
				closeTheBlackJackTable()
				playSound("files/sounds/butfold.mp3")
			elseif activeButton == "startGame" then
				if sliderAmount > mySlotCoins then
					outputChatBox("#3d7abc[StrongMTA]: #ffffffNincs elég Slot Coinod!", 255, 255, 255, true)
				else
					if tonumber(sliderAmount) < tablePositionsB[blackjackId][7] or tonumber(sliderAmount) > tablePositionsB[blackjackId][8] then
						outputChatBox("#d75959[StrongMTA]: #ffffffHiba történt, próbáld újra.", 255, 255, 255, true)
					else
						triggerServerEvent("blackJackHandler", localPlayer, "pot", sliderAmount)
						blackjackData.gameStage = -1
						playSound("files/sounds/butfold.mp3")
					end
				end
			else
				if buttonsActive and activeButton then
					local visibleName = getElementData(localPlayer, "char.Name"):gsub("_", " ")

					if activeButton == "hit" then
						if not blackjackData.suspended and #blackjackBoard[blackjackId].playerCards >= 2 then
							blackjackData.suspended = true
							addChatHistory("#ffffff" .. visibleName .. ": Hit!", true)
							triggerServerEvent("blackJackHandler", localPlayer, "hit")
							playSound("files/sounds/butclick.mp3")
						end
					elseif activeButton == "stay" then
						if not blackjackData.suspended then
							blackjackData.suspended = true
							addChatHistory("#ffffff" .. visibleName .. ": Stay!", true)
							triggerServerEvent("blackJackHandler", localPlayer, "stay")
							playSound("files/sounds/butclick.mp3")
						end
					elseif activeButton == "double" then
						if #blackjackBoard[blackjackId].playerCards == 2 then
							triggerServerEvent("blackJackHandler", localPlayer, "double")
							playSound("files/sounds/butclick.mp3")
						end
					elseif activeButton == "surrender" then
						if not blackjackData.suspended and #blackjackBoard[blackjackId].playerCards == 2 then
							blackjackData.suspended = true
							addChatHistory("#ffffff" .. visibleName .. ": Surrender!", true)
							triggerServerEvent("blackJackHandler", localPlayer, "surrender")
							playSound("files/sounds/butclick.mp3")
						end
					end
				end
			end
		end
	end
end

function renderBlackjack()
	local cursorX, cursorY = getCursorPosition()

	if isCursorShowing() then
		cursorX = cursorX * screenX
		cursorY = cursorY * screenY
	else
		cursorX, cursorY = -1, -1

		if sliderMoveX then
			sliderMoveX = false
		end
	end

	if not getKeyState("mouse1") and sliderMoveX then
		sliderMoveX = false
	end

	buttons = {}
	buttonsC = {}

	if not tablePositionsB[blackjackId] then
		closeTheBlackJackTable()
		return
	end

	if blackjackData.gameStage > 0 then
		local board = blackjackBoard[blackjackId]

		if not board then
			closeTheBlackJackTable()
			return
		end

		buttonsActive = true

		if not realBoardCardsB[blackjackId] then
			buttonsActive = false
		elseif #realBoardCardsB[blackjackId] ~= 0 then
			buttonsActive = false
		end

		local allWidth = (buttonWidth + respc(15)) * #actionButtons
		local startX = screenX - allWidth - respc(30)

		dxDrawRectangle(startX - respc(15), buttonPosY - respc(15), allWidth + respc(15), buttonHeight + respc(30), tocolor(25, 25, 25))

		for i = 1, #actionButtons do
			local dat = actionButtons[i]
			
			buttonPosX = startX + (i - 1) * (buttonWidth + respc(15))
			drawButton(dat[1], dat[2], buttonPosX, buttonPosY, buttonWidth, buttonHeight, {dat[3], dat[4], dat[5]}, false, Raleway18, true)


			buttons[dat[1]] = {buttonPosX, buttonPosY, buttonWidth, buttonHeight}

		end

		local playerCardsNum = #board.playerCards
		local dealerCardsNum = #board.dealerCards

		if playerCardsNum ~= 0 then
			local sx = respc(125) * 0.75
			local sy = respc(182) * 0.75

			local cardSizeX = (respc(5) + sx) * playerCardsNum
			
			local x = math.floor(screenX / 2 - cardSizeX / 2)
			local y = math.floor(screenY - sy * 1.25)

			dxDrawRectangle(x - 5, y - 5, cardSizeX + 5, sy + 10, tocolor(0, 0, 0, 180))

			for i = 1, playerCardsNum do
				local dat = board.playerCards[i]
				local card = cardRanksB[dat[1]] .. "-" .. dat[2]

				dxDrawImage(x + (i - 1) * (respc(5) + sx), y, sx, sy, cardTextures[card])
			end

			local value = getHandValue(board.playerCards)

			if value > 21 then
				value = "#d75959" .. value
			else
				value = "#3d7abc" .. value
			end

			dxDrawText("Játékos: " .. value, x, y - respc(50), x + cardSizeX, 0, tocolor(200, 200, 200, 200), 1, Raleway18, "center", "top", false, false, false, true)
		end

		if dealerCardsNum ~= 0 then
			local sx = respc(125) * 0.55
			local sy = respc(182) * 0.55

			local cardSizeX = dealerCardsNum * (respc(5) + sx)
			
			local x = math.floor(screenX / 2 - cardSizeX / 2)
			local y = math.floor(screenY - sy * 3.5)

			dxDrawRectangle(x - 5, y - 5, cardSizeX + 5, sy + 10, tocolor(0, 0, 0, 180))

			for i = 1, dealerCardsNum do
				if i == 2 and blackjackData.gameStage == 1 then
					dxDrawImage(x + (i - 1) * (respc(5) + sx), y, sx, sy, cardTextures.back)
				else
					local dat = board.dealerCards[i]
					local card = cardRanksB[dat[1]] .. "-" .. dat[2]

					dxDrawImage(x + (i - 1) * (respc(5) + sx), y, sx, sy, cardTextures[card])
				end
			end

			local value = getHandValue(board.dealerCards)
			
			if blackjackData.gameStage == 1 then
				value = getHandValue({board.dealerCards[1]})
			end

			if value > 21 then
				value = "#d75959" .. value
			else
				value = "#3d7abc" .. value
			end

			dxDrawText("Dealer: " .. value, x, y - respc(50), x + cardSizeX, 0, tocolor(200, 200, 200, 200), 0.85, Raleway18, "center", "top", false, false, false, true)
		end

		-- ** Chat history
		buttons.chatscroll = {chatPosX, chatPosY, chatWidth, chatHeight}

		dxDrawRectangle(chatPosX - respc(5), chatPosY - respc(5), chatWidth + respc(10), chatHeight + respc(10), tocolor(25, 25, 25))
		dxDrawRectangle(chatPosX, chatPosY, chatWidth, chatHeight, tocolor(35, 35, 35, 120))

		local lines = #chatLines

		if lines > 6 then
			local gripHeight = (chatHeight / lines) * 7
			dxDrawRectangle(chatPosX + chatWidth, chatPosY - (chatHeight / lines) * chatOffset + chatHeight - gripHeight, respc(5), gripHeight, tocolor(61, 123, 188, 225))
		end

		for i = 1, 7 do
			local text = chatLines[i + chatOffset]

			if text then
				dxDrawText(text, chatPosX + 5, chatPosY + respc(20) * (7 - i), 0, chatPosY + respc(20) * (8 - i), tocolor(200, 200, 200, 200), 0.6, Raleway18, "left", "center", false, false, false, true)
			end
		end
	elseif blackjackData.gameStage == 0 then
		local sx, sy = respc(500), respc(220)
		local x = screenX / 2 - sx / 2
		local y = screenY / 2 - sy / 2

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, tocolor(25, 25, 25))

		-- ** Cím
		dxDrawRectangle(x + 3, y + 3, sx - 6, respc(40) - 6, tocolor(45, 45, 45, 150))
		dxDrawText("#3d7abcStrong#ffffffMTA - Blackjack", x + respc(10), y - 3, 0, y - 3 + respc(40), tocolor(200, 200, 200, 200), 1, Raleway18, "left", "center", false, false, false, true)

		-- ** Kilépés
		local closeLength = dxGetTextWidth("X", 0.8, Raleway18)

		buttons.quitGame = {x + sx - respc(10) - closeLength, y, closeLength, respc(40)}

		if activeButton == "quitGame" then
			dxDrawText("X", buttons.quitGame[1], buttons.quitGame[2], buttons.quitGame[1] + buttons.quitGame[3], buttons.quitGame[2] + buttons.quitGame[4], tocolor(215, 89, 89), 0.8, Raleway18, "left", "center")
		else
			dxDrawText("X", buttons.quitGame[1], buttons.quitGame[2], buttons.quitGame[1] + buttons.quitGame[3], buttons.quitGame[2] + buttons.quitGame[4], tocolor(200, 200, 200, 200), 0.8, Raleway18, "left", "center")
		end

		--  ** Content
		dxDrawText("Mennyi zsetont szeretnél feltenni a körre?", x, y + respc(45), x + sx, 0, tocolor(200, 200, 200, 200), 0.75, Raleway18, "center", "top")

		-- Slider
		local sliderWidth = sx * 0.75
		local sliderHeight = respc(40)

		local sliderBaseX = x + sx / 2 - sliderWidth / 2
		local sliderBaseY = y + respc(60) + sliderHeight

		if sliderValue ~= sliderValue then
			sliderValue = 0
		end

		local sliderX = sliderBaseX + sliderValue * (sliderWidth - respc(15))
		local sliderY = sliderBaseY + (respc(10) - sliderHeight) / 2

		dxDrawRectangle(sliderBaseX, sliderY, sliderWidth, sliderHeight, tocolor(45, 45, 45, 150))
		dxDrawRectangle((sliderX - sliderValue * (sliderWidth - respc(15))) + 3, sliderY + 3, (respc(15) + sliderValue * (sliderWidth - respc(15))) - 6, sliderHeight - 6, tocolor(61, 123, 188, 150))

		if sliderMoveX then
			sliderValue = (cursorX - sliderMoveX - sliderBaseX) / (sliderWidth - respc(15))

			if sliderValue < 0 then
				sliderValue = 0
			end

			if sliderValue > 1 then
				sliderValue = 1
			end
		end
		
		if not sliderMoveX and cursorX >= sliderX and cursorX <= sliderX + respc(15) and cursorY >= sliderY and cursorY <= sliderY + sliderHeight then
			sliderMoveX = cursorX - sliderX
		end

		local minEntry = tablePositionsB[blackjackId][7]
		local maxEntry = mySlotCoins

		if maxEntry > tablePositionsB[blackjackId][8] then
			maxEntry = tablePositionsB[blackjackId][8]
		end

		sliderAmount = math.floor(sliderValue * (maxEntry - minEntry) + minEntry)

		dxDrawText(formatNumber(sliderAmount) .. " #3d7bbcCoin", x, sliderY + sliderHeight, x + sx, y + sy - respc(40), tocolor(200, 200, 200, 200), 1, Raleway18, "center", "center", false, false, false, true)

		-- Játék
		buttons.startGame = {x, y + sy - respc(40), sx, respc(40)}

		--if activeButton == "startGame" then
		--	dxDrawRectangle(buttons.startGame[1] - 2, buttons.startGame[2], buttons.startGame[3] + 4, buttons.startGame[4] + 2, tocolor(61, 123, 188, 220))
		--else
		--	dxDrawRectangle(buttons.startGame[1] - 2, buttons.startGame[2], buttons.startGame[3] + 4, buttons.startGame[4] + 2, tocolor(61, 123, 188, 160))
		--end

		--dxDrawText("Játék indítása", buttons.startGame[1], buttons.startGame[2], buttons.startGame[1] + buttons.startGame[3], buttons.startGame[2] + buttons.startGame[4], tocolor(0, 0, 0), 0.75, Raleway18, "center", "center")
		drawButton("startGame", "Játék indítása", buttons.startGame[1] + 3, buttons.startGame[2] + 3, buttons.startGame[3] - 6, buttons.startGame[4] - 6, {61, 122, 188}, false, Raleway18, true)
	end

	lastActiveButton = activeButton
	activeButton = false
	activeButtonC = false

	if cursorX then
		for k, v in pairs(buttons) do
			if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
		for k, v in pairs(buttonsC) do
			if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
				activeButtonC = k
				break
			end
		end
	end

--tuddja gecikmmmm mi etz dejkke
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		local playerX, playerY, playerZ = getElementPosition(localPlayer)

		for tableIdB, board in pairs(blackjackBoard) do
			local boardCards = realBoardCardsB[tableIdB]

			if not blackjackData then
				local dat = tablePositionsB[tableIdB]

				if dat then
					local dist = getDistanceBetweenPoints3D(dat[1], dat[2], dat[3], playerX, playerY, playerZ)

					if dist < 10 then
						local x, y = getScreenFromWorldPosition(dat[1], dat[2], dat[3] + 0.3)
						
						if x and y then
							local scale = 1 - dist / 20
							local sx, sy = respc(230) * scale, respc(55) * scale

							x = x - sx / 2
							y = y - sy / 2

							dxDrawRectangle(x, y, sx, sy, tocolor(25, 25, 25, 240))
							
							dxDrawText("Min. tét/kör:", x + respc(5) * scale, y + respc(5) * scale, 0, y + respc(27.5) * scale, tocolor(200, 200, 200, 200), 0.675 * scale, Raleway18, "left", "center")
							dxDrawText(formatNumber(dat[7]) .. " Coin", 0, y + respc(5) * scale, x + sx - respc(5) * scale, y + respc(27.5) * scale, tocolor(61, 123, 188, 200), 0.675 * scale, Raleway18, "right", "center")
							
							dxDrawText("Max. tét/kör:", x + respc(5) * scale, y + respc(27.5) * scale, 0, y + respc(55) * scale, tocolor(200, 200, 200, 200), 0.675 * scale, Raleway18, "left", "center")
							dxDrawText(formatNumber(dat[8]) .. " Coin", 0, y + respc(27.5) * scale, x + sx - respc(5) * scale, y + respc(55) * scale, tocolor(61, 123, 188, 200), 0.675 * scale, Raleway18, "right", "center")
						end
					end
				end
			end

			if boardCards then
				local dat = boardCards[1]

				if dat then
					local elapsedTime = getTickCount() - dat.startTick
					local progress = elapsedTime / 800

					local x1, y1, z1 = interpolateBetween(dat.start[1], dat.start[2], dat.start[3], dat.stop[1], dat.stop[2], dat.stop[3], progress, "Linear")
					local x2, y2, z2 = interpolateBetween(dat.start[4], dat.start[5], dat.start[6], dat.stop[4], dat.stop[5], dat.stop[6], progress, "Linear")

					dxDrawMaterialLine3D(x1, y1, z1, x2, y2, z2, cardTextures[dat.texture], 0.1, tocolor(200, 200, 200, 200), x1, y1, z1 + 1)

					if progress > 0 then
						if not dat.sound then
							dat.sound = true
							triggerEvent("playBlackjackSound", localPlayer, tableIdB, "newcardintable")
						end
					end

					if progress >= 1 then
						if dat.execute then
							dat.execute(tableIdB)
							dat.execute = nil
						end

						table.remove(boardCards, 1)

						if boardCards[1] then
							boardCards[1].startTick = getTickCount()
						end
					end
				end

				if board.gameStage > 0 then
					if board.dealerCards then
						for i = 1, #board.dealerCards do
							local dat = board.dealerCards[i]

							if dat then
								local texture = "back"
								local offsetX = 0

								if not (board.gameStage == 1 and i == 2) then
									texture = cardRanksB[dat[1]] .. "-" .. dat[2]
								end

								if boardCards and boardCards[1] and boardCards[1].theType == "dealer" then
									offsetX = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - boardCards[1].startTick) / 800, "Linear")
								end

								local x1, y1 = rotateAround(tablePositionsB[tableIdB][4], 0.15 * (#board.dealerCards + offsetX) / 2, 0)
								local x2, y2 = rotateAround(tablePositionsB[tableIdB][4], (i - 1) * 0.125, 0)
								local pos = realcardPositionsBBlackJack[tableIdB].dealer

								dxDrawMaterialLine3D(
									pos[1] - x1 + x2, pos[2] - y1 + y2, pos[5],
									pos[3] - x1 + x2, pos[4] - y1 + y2, pos[5],
									cardTextures[texture], 0.1, tocolor(200, 200, 200, 200),
									pos[1] - x1 + x2, pos[2] - y1 + y2, pos[5] + 1
								)
							end
						end
					end

					if board.playerCards then
						for i = 1, #board.playerCards do
							local dat = board.playerCards[i]

							if dat then
								local texture = cardRanksB[dat[1]] .. "-" .. dat[2]
								local offsetX = 0

								if boardCards and boardCards[1] and boardCards[1].theType == "player" then
									offsetX = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - boardCards[1].startTick) / 800, "Linear")
								end

								local x1, y1 = rotateAround(tablePositionsB[tableIdB][4], 0.15 * (#board.playerCards + offsetX) / 2, 0)
								local x2, y2 = rotateAround(tablePositionsB[tableIdB][4], (i - 1) * 0.125, 0)
								local pos = realcardPositionsBBlackJack[tableIdB].player

								dxDrawMaterialLine3D(
									pos[1] - x1 + x2, pos[2] - y1 + y2, pos[5],
									pos[3] - x1 + x2, pos[4] - y1 + y2, pos[5],
									cardTextures[texture], 0.1, tocolor(200, 200, 200, 200),
									pos[1] - x1 + x2, pos[2] - y1 + y2, pos[5] + 1
								)
							end
						end
					end
				end
			end
		end
	end)