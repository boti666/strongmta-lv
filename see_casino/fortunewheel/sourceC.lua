local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local placedForuneTable = false

addCommandHandler("createfortune",
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			if not placedForuneTable then
				if isElement(placedForuneTable) then
					destroyElement(placedForuneTable)
				end

				placedForuneTable = createObject(1896, 0, 0, 0)

				setElementCollisionsEnabled(placedForuneTable, false)
				setElementAlpha(placedForuneTable, 175)
				setElementInterior(placedForuneTable, getElementInterior(localPlayer))
				setElementDimension(placedForuneTable, getElementDimension(localPlayer))

				addEventHandler("onClientRender", getRootElement(), tablePlaceRenderFortune)
				addEventHandler("onClientKey", getRootElement(), tablePlaceKeyFortune)

				outputChatBox("#3d7abc[StrongMTA - Szerencsekerék]: #ffffffKerék létrehozás mód #3d7abcbekapcsolva!", 255, 255, 255, true)
				outputChatBox("#3d7abc[StrongMTA - Szerencsekerék]: #ffffffA kerék #3d7abclerakásához #ffffffnyomd meg az #3d7abcBAL CTRL #ffffffgombot.", 255, 255, 255, true)
				outputChatBox("#3d7abc[StrongMTA - Szerencsekerék]: #ffffffA #d75959kilépéshez #ffffffírd be a #d75959/" .. commandName .. " #ffffffparancsot.", 255, 255, 255, true)
			else
				removeEventHandler("onClientRender", getRootElement(), tablePlaceRenderFortune)
				removeEventHandler("onClientKey", getRootElement(), tablePlaceKeyFortune)

				if isElement(placedForuneTable) then
					destroyElement(placedForuneTable)
				end
				placedForuneTable = nil

				outputChatBox("#3d7abc[StrongMTA - Szerencsekerék]: #ffffffKerék létrehozás mód #d75959kikapcsolva!", 255, 255, 255, true)
			end
		end
	end)

function tablePlaceRenderFortune()
	if placedForuneTable then
		local x, y, z = getElementPosition(localPlayer)
		local rz = select(3, getElementRotation(localPlayer))
		
		setElementPosition(placedForuneTable, x, y, z - 0.1)
		setElementRotation(placedForuneTable, 0, 0, math.ceil(math.floor(rz * 5) / 5))
	end
end

function tablePlaceKeyFortune(button, state)
	if isElement(placedForuneTable) then
		if button == "lctrl" and state then
			local x, y, z = getElementPosition(placedForuneTable)
			local rz = select(3, getElementRotation(placedForuneTable))
			local interior = getElementInterior(placedForuneTable)
			local dimension = getElementDimension(placedForuneTable)

			triggerServerEvent("placeFortuneWheel", localPlayer, {x, y, z, rz, interior, dimension})

			if isElement(placedForuneTable) then
				destroyElement(placedForuneTable)
			end
			placedForuneTable = nil

			removeEventHandler("onClientRender", getRootElement(), tablePlaceRenderFortune)
			removeEventHandler("onClientKey", getRootElement(), tablePlaceKeyFortune)
		end
	end
end

addCommandHandler("nearbyfortune",
	function (commandName, maxDistance)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local nearby = {}

			maxDistance = tonumber(maxDistance) or 15

			for i, v in ipairs(getElementsByType("object", resourceRoot, true)) do
				local tableId = getElementData(v, "fortuneTable")

				if tableId then
					local targetX, targetY, targetZ = getElementPosition(v)
					local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

					if distance <= maxDistance then
						table.insert(nearby, {tableId, distance})
					end
				end
			end

			if #nearby > 0 then
				outputChatBox("#3d7abc[StrongMTA - Szerencsekerék]: #ffffffKözeledben lévő kerekek (" .. maxDistance .. " yard):", 255, 255, 255, true)

				for i, v in ipairs(nearby) do
					outputChatBox("    * #3d7abcAzonosító: #ffffff" .. v[1] .. " - " .. math.floor(v[2] * 500) / 500 .. " yard", 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[StrongMTA - Szerencsekerék]: #ffffffNincs egyetlen kerék sem a közeledben.", 255, 255, 255, true)
			end
		end
	end)

local clickers = {}
local clickerRot = {}
local wheelRot = {}

local usingFortune = false
local mySlotCoins = 0

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs({1896, 1897, 1895, 1898}) do
			for i = 0, 50 do
				removeWorldModel(v, 1000000, 0, 0, 0, i)
			end
		end

		if getElementData(localPlayer, "playerUsingFortune") then
			setElementData(localPlayer, "playerUsingFortune", false)
		end
	end)

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		if getElementModel(source) == 1895 then
			local fortunePos = getElementData(source, "fortunePos")

			if fortunePos then
				local x, y, z, rz = unpack(fortunePos)
				local tx, ty = rotateAround(rz, 0, 0.415)

				if isElement(clickers[source]) then
					destroyElement(clickers[source])
				end

				clickers[source] = nil
				clickers[source] = createObject(1898, x + tx, y + ty, z + 2.2, 0, 0, rz)

				setElementInterior(clickers[source], getElementInterior(source))
				setElementDimension(clickers[source], getElementDimension(source))
				setElementDoubleSided(clickers[source], true)
			end
		end
	end)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
	function ()
		if clickers[source] then
			if isElement(clickers[source]) then
				destroyElement(clickers[source])
			end

			clickers[source] = nil
			clickerRot[source] = nil
			wheelRot[source] = nil
		end
	end)

addEventHandler("onClientElementDestroy", getResourceRootElement(),
	function ()
		if clickers[source] then
			if isElement(clickers[source]) then
				destroyElement(clickers[source])
			end
			
			clickers[source] = nil
			clickerRot[source] = nil
			wheelRot[source] = nil
		end
	end)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "char.slotCoins" then
			mySlotCoins = getElementData(localPlayer, dataName) or 0
		end

		if dataName == "playerUsingFortune" then
			if not getElementData(localPlayer, dataName) then
				if usingFortune then
					closeTheTable()
				end
			end
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		for element, obj in pairs(clickers) do
			if not clickerRot[obj] then
				clickerRot[obj] = 0
			end

			if not wheelRot[obj] then
				wheelRot[obj] = 0
			end

			local rx, ry, rz = getElementRotation(element)

			clickerRot[obj] = clickerRot[obj] + math.abs(ry - wheelRot[obj])
			wheelRot[obj] = ry

			if clickerRot[obj] > 4 then
				clickerRot[obj] = 0

				local x, y, z = getElementPosition(element)
				local sound = playSound3D("files/wheelf.mp3", x, y, z)

				setElementInterior(sound, getElementInterior(element))
				setElementDimension(sound, getElementDimension(element))
				--setSoundVolume(sound, 0.25)
			end

			if clickerRot[obj] > 1 then
				setElementRotation(obj, 0, -(clickerRot[obj] - 1) / 3 * -10, rz)
			end
		end
	end)

local panelWidth = respc(400)
local panelHeight = respc(300)
local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2
local draggingPanel = false

local buttons = {}
local activeButton = false

local fieldNames = {
	[0] = {
		[0] = "x20",
		[1] = "x10"
	},
	[1] = {
		[0] = "x5",
		[1] = "x2"
	},
	[2] = {
		[0] = "x1",
		[1] = "★ x40"
	}
}

local fieldValues = {
	[0] = {
		[0] = 20,
		[1] = 10
	},
	[1] = {
		[0] = 5,
		[1] = 2
	},
	[2] = {
		[0] = 1,
		[1] = 40
	}
}

local availableCoins = {
	[1] = 1,
	[2] = 5,
	[3] = 25,
	[4] = 50,
	[5] = 100,
	[6] = 500
}

local chipMoveX, chipMoveY = false, false
local movedChip = false

local topBets = {}
local fieldCredits = {}
local creditAll = 0
local clickTick = 0

local gtaFont = false

addEvent("openFortuneWheel", true)
addEventHandler("openFortuneWheel", getRootElement(),
	function (tableId, element)
		usingFortune = tableId
		mySlotCoins = getElementData(localPlayer, "char.slotCoins") or 0

		gtaFont = dxCreateFont("files/gtaFont.ttf", respc(20), false, "antialiased")

		draggingPanel = false
		movedChip = false
		creditAll = 0
		topBets = {}
		fieldCredits = {}
		clickTick = 0

		addEventHandler("onClientRender", getRootElement(), renderFortuneWheel)
		addEventHandler("onClientClick", getRootElement(), clickFortuneWheel)
	end)

function closeTheTable(spin)
	triggerServerEvent("closeFortuneWheel", localPlayer, usingFortune, spin)

	removeEventHandler("onClientRender", getRootElement(), renderFortuneWheel)
	removeEventHandler("onClientClick", getRootElement(), clickFortuneWheel)

	if isElement(gtaFont) then
		destroyElement(gtaFont)
	end
	gtaFont = nil

	draggingPanel = false
	usingFortune = nil
	movedChip = false
	creditAll = 0
	topBets = {}
	fieldCredits = {}
	clickTick = 0
end

addEvent("onFortuneBetPlaced", true)
addEventHandler("onFortuneBetPlaced", getRootElement(),
	function (x, y, amount)
		creditAll = creditAll + amount
		fieldCredits[x .. "," .. y] = (fieldCredits[x .. "," .. y] or 0) + amount
	end)

function clickFortuneWheel(button, state)
	if button == "left" then
		if state == "down" then
			if activeButton == "quitGame" then
				if creditAll == 0 then
					closeTheTable()
				else
					exports.see_hud:showInfobox("e", "Előbb pörgess, vagy vedd le a tétjeidet!")
				end
			elseif activeButton == "startGame" then
				if creditAll > 0 and not movedChip then
					if getTickCount() - clickTick > 2000 then
						if creditAll > 8000 then
							exports.see_hud:showInfobox("e", "Maximum 8000 Coin lehet a tét. A pörgetéshez vegyél le belőle!")
						else
							closeTheTable(true)
						end
					end
				end
			end
		elseif state == "up" then
			if activeButton then
				local selected = split(activeButton, "_")

				if selected[1] == "field" then
					if movedChip then
						if creditAll + movedChip > 8000 then
							exports.see_hud:showInfobox("e", "Maximum 8000 Coin lehet a tét.")
						else
							if getTickCount() - clickTick > 1275 then
								local x, y = unpack(split(selected[2], ","))

								if x and y then
									x, y = tonumber(x), tonumber(y)

									triggerServerEvent("onPlaceFortuneCoin", localPlayer, movedChip, usingFortune, x, y, getElementsByType("player", getRootElement(), true), fieldValues[x][y])

									topBets[x .. "," .. y] = movedChip
									movedChip = false
									clickTick = getTickCount()
								end
							end
						end
					end
				elseif selected[1] == "chip" then
					if not movedChip then
						local x, y = unpack(split(selected[2], ","))

						if x and y then
							x, y = tonumber(x), tonumber(y)

							local field = x .. "," .. y

							if (fieldCredits[field] or 0) > 0 then
								triggerServerEvent("onRemoveFortuneBet", localPlayer, usingFortune, x, y, fieldCredits[field])
								creditAll = creditAll - fieldCredits[field]
								fieldCredits[field] = 0
								topBets[field] = false
							end
						end
					end
				end
			end
		end
	end
end

function renderFortuneWheel()
	local absX, absY = getCursorPosition()

	buttons = {}
	buttonsC = {}

	if isCursorShowing() then
		absX = absX * screenX
		absY = absY * screenY

		if getKeyState("mouse1") then
			if absX >= panelPosX and absX <= panelPosX + panelWidth - respc(40) and absY>= panelPosY and absY <= panelPosY + respc(40) and not draggingPanel then
				draggingPanel = {absX, absY, panelPosX, panelPosY}
			end

			if draggingPanel then
				panelPosX = absX - draggingPanel[1] + draggingPanel[3]
				panelPosY = absY - draggingPanel[2] + draggingPanel[4]
			end
		elseif draggingPanel then
			draggingPanel = false
		end
	else
		absX, absY = -1, -1

		if movedChip then
			chipMoveX, chipMoveY = false, false
			movedChip = false
		end

		if draggingPanel then
			draggingPanel = false
		end
	end

	if not getKeyState("mouse1") and movedChip then
		chipMoveX, chipMoveY = false, false
		movedChip = false
	end

	dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(25, 25, 25))

	-- ** Cím
	dxDrawRectangle(panelPosX + 3, panelPosY + 3, panelWidth - 6, respc(40), tocolor(45, 45, 45, 150))
	dxDrawText("#3d7abcStrong#ffffffMTA - Szerencsekerék", panelPosX + respc(10), panelPosY + 3, 0, panelPosY + 3 + respc(40), tocolor(200, 200, 200, 200), 1, Raleway14, "left", "center", false, false, false, true)

	-- ** Kilépés
	local closeLength = dxGetTextWidth("X", 0.8, Raleway14)

	buttons.quitGame = {panelPosX + panelWidth - respc(10) - closeLength, panelPosY, closeLength, respc(40)}

	if activeButton == "quitGame" then
		dxDrawText("X", buttons.quitGame[1], buttons.quitGame[2], buttons.quitGame[1] + buttons.quitGame[3], buttons.quitGame[2] + buttons.quitGame[4], tocolor(215, 89, 89), 0.8, Raleway14, "left", "center")
	else
		dxDrawText("X", buttons.quitGame[1], buttons.quitGame[2], buttons.quitGame[1] + buttons.quitGame[3], buttons.quitGame[2] + buttons.quitGame[4], tocolor(255, 255, 255), 0.8, Raleway14, "left", "center")
	end

	-- ** Tétek
	local chipSize = respc(32)
	local sx = (panelWidth - respc(40)) / 3
	local sy = (panelHeight - respc(110) - respc(86)) / 2

	for i = 0, 5 do
		local x = math.floor(i / 2)
		local y = i % 2

		local x2 = panelPosX + respc(10) + x * (sx + respc(10))
		local y2 = panelPosY + respc(90) + y * (sy + respc(10))

		drawButton("chip_" .. x .. "," .. y, fieldNames[x][y], x2, y2, sx, sy, {61, 122, 188}, false, gtaFont, true)

		local field = x .. "," .. y
		local activeField = false

		if topBets[field] then
			local chipX = math.floor(x2 + (sx - chipSize) / 2)
			local chipY = math.floor(y2 + (sy - chipSize) / 2)

			dxDrawImage(chipX, chipY, chipSize, chipSize, "files/chips/" .. topBets[field] .. ".png")

			if absX >= chipX and absY >= chipY and absX <= chipX + chipSize and absY <= chipY + chipSize then
				if movedChip and fieldCredits[field] and (fieldCredits[field] or 0) + movedChip > 8000 then
					createTooltip("Ezen a mezőn elérted a 8000-es limitet.")
				else
					createTooltip("Téted: " .. (fieldCredits[field] or 0) .. " Coin")
				end

				if not movedChip then
					activeField = field

					buttons["chip_" .. x .. "," .. y] = {chipX, chipY, chipSize, chipSize}
				end
			end
		end

		if not activeField then
			buttons["field_" .. x .. "," .. y] = {x2, y2, sx, sy}
		end
	end

	-- ** Zsetonok
	local chipPotSize = respc(40)
	local chipX = panelPosX + (panelWidth - #availableCoins * chipPotSize) / 2
	local chipY = panelPosY + respc(90) + sy * 2 + respc(22)

	for i = 1, #availableCoins do
		local x = math.floor(chipX + (i - 1) * chipPotSize)
		local y = math.floor(chipY)

		if mySlotCoins >= availableCoins[i] then
			dxDrawImage(x, y, chipSize, chipSize, "files/chips/" .. availableCoins[i] .. ".png")

			if not movedChip and absX >= x and absY >= y and absX <= x + chipSize and absY <= y + chipSize then
				if getKeyState("mouse1") then
					movedChip = availableCoins[i]
					chipMoveX = absX - x
					chipMoveY = absY - y
				end

				createTooltip("#598ed7" .. availableCoins[i] .. " #ffffffCoin")
			end
		else
			dxDrawImage(x, y, chipSize, chipSize, "files/chips/" .. availableCoins[i] .. ".png", 0, 0, 0, tocolor(255, 255, 255, 120))
		end
	end

	if movedChip then
		dxDrawImage(absX - chipMoveX, absY - chipMoveY, chipSize, chipSize, "files/chips/" .. movedChip .. ".png")
	end

	dxDrawText("#598ed7" .. formatNumber(mySlotCoins) .. " #ffffffCoin", panelPosX, panelPosY + respc(10) + respc(42.5), panelPosX + respc(10) + panelWidth, 0, tocolor(255, 255, 255), 1, Raleway14, "center", "top", false, false, false, true)

	-- ** Pörgetés
	buttons.startGame = {panelPosX, panelPosY + panelHeight - respc(40), panelWidth, respc(40)}

	drawButton("startGame", "Pörgetés", buttons.startGame[1] + 3, buttons.startGame[2] + 3, buttons.startGame[3] - 6, buttons.startGame[4] - 6, {61, 122, 188}, false, Raleway14, true)

	activeButton = false
	activeButtonC = false

	if isCursorShowing() then
		for k, v in pairs(buttons) do
			if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end

		for k, v in pairs(buttonsC) do
			if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
				activeButtonC = k
				break
			end
		end
	end
end

function createTooltip(text)
	local cx, cy = getCursorPosition()
	cx, cy = cx * screenX, cy * screenY
	if text then
		local textWidth = dxGetTextWidth(removeHex(text), 0.8)
		local height = respc(40)
        dxDrawRectangle(cx - textWidth / 2 - respc(5), cy - (height / 2) - respc(50), textWidth + respc(20), height, tocolor(23, 23, 23, 210), true)
        dxDrawText(text, cx - textWidth / 2, cy - (height / 2) - respc(100), textWidth + cx - textWidth / 2 + respc(10), height + cy - (height / 2) , tocolor(200, 200, 200, 200), 0.8, Raleway12, "center", "center", false, false, true, true)	
	end
end

function removeHex (text)
    return type(text) == "string" and string.gsub(text, "#%x%x%x%x%x%x", "") or text
end