local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local inLotteryInterior = false
local interiorThings = {}

local Roboto = false
local Fixedsys500c = false

local promptWidth = respc(600)
local promptHeight = respc(100)

local promptPosX = screenX / 2 - promptWidth / 2
local promptPosY = screenY / 2 - promptHeight / 2

local activeButton = false
local activeButton2 = false

local lastLotteryBuy = 0
local clickTick = 0

local firstTicket = false

local firstTicketWidth = 512
local firstTicketHeight = 256

local firstTicketPosX = screenX / 2 - firstTicketWidth / 2
local firstTicketPosY = screenY / 2 - firstTicketHeight / 2

local secondTicket = false

local secondTicketWidth = 256
local secondTicketHeight = 512

local secondTicketPosX = screenX / 2 - secondTicketWidth / 2
local secondTicketPosY = screenY / 2 - secondTicketHeight / 2

local lotteryNums = {}
local lotteryFont = false
local lotteryItem = false
local lotteryAnim = {}
local barcodeFont = false

local scratchTicket = false
local scratchType = false
local scratchItem = false
local scratchData = {}
local scratchPercent = 0
local scratchState = false
local scratchTexture = false
local scratchSound = false

local scratchTypes = {
	[293] = "blackjack",
	[296] = "moneymania",
	[374] = "piggy",
	[375] = "lift"
}

local scratchPoses = {
	blackjack = {
		baseSize = {220, 398},
		zoneSize = {196, 159},
		basePos = false,
		zonePos = {12, 175}
	},
	moneymania = {
		baseSize = {223, 398},
		zoneSize = {186, 157},
		basePos = false,
		zonePos = {19, 188}
	},
	piggy = {
		baseSize = {512, 256},
		zoneSize = {208, 113},
		basePos = false,
		zonePos = {57, 72}
	},
	lift = {
		baseSize = {300, 520},
		zoneSize = {229, 223},
		basePos = false,
		zonePos = {36, 148}
	}
}

for k, v in pairs(scratchPoses) do
	if not v.basePos then
		v.basePos = {screenX / 2 - v.baseSize[1] / 2, screenY / 2 - v.baseSize[2] / 2}
	end

	v.zonePos = {v.basePos[1] + v.zonePos[1], v.basePos[2] + v.zonePos[2]}
end

local lastCursorX = 0
local lastCursorY = 0
local holdLMB = false
local successNotiState = false

local maskWidth = 64 * 0.4
local maskHeight = 31 * 0.6
local maskRotation = 0
local maskShader = false
local maskRenderTarget = false

local savedMasks = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 3000, 1, "requestMasks", localPlayer)
	end
)

addEvent("requestMasks", true)
addEventHandler("requestMasks", getRootElement(),
	function (maskList)
		if maskList and type(maskList) == "table" then
			savedMasks = {}

			for k, v in pairs(maskList) do
				savedMasks[tonumber(k)] = v
			end
		end
	end
)

addEvent("createMask", true)
addEventHandler("createMask", getRootElement(),
	function (itemId, pixels)
		if itemId and pixels then
			savedMasks[itemId] = pixels
		end
	end
)

addEvent("deleteMask", true)
addEventHandler("deleteMask", getRootElement(),
	function (itemIDs)
		if itemIDs and type(itemIDs) == "table" then
			for i = 1, #itemIDs do
				local itemId = itemIDs[i]

				if itemId then
					savedMasks[itemId] = nil
				end
			end
		end
	end
)

function isScratchTicketOpen()
	return scratchTicket
end

function showScratch(itemId, dbID, data1, data2, data3, state)
	if scratchTicket then
		if dbID ~= scratchTicket then
			return
		end
	end

	if state then
		scratchTicket = dbID
		scratchItem = itemId
		scratchType = scratchTypes[itemId]
		scratchData = {}
		scratchData.percent = tonumber(data2 or 0) or 0
		scratchPercent = scratchData.percent
		scratchState = data3
		successNotiState = false

		local scratchPos = scratchPoses[scratchType]
		local data = fromJSON(data1)

		if scratchType == "blackjack" then
			scratchData.win = data[1]
			scratchData.winnerNumber = data[2]
			scratchData.numbers = {data[3], data[4], data[5], data[6]}
			scratchData.prize = data[7]
			scratchData.theSerialNum = data[8]
		elseif scratchType == "moneymania" then
			scratchData.symbols = data[1]
			scratchData.prizes = data[2]
			scratchData.theSerialNum = data[4]
		elseif scratchType == "piggy" then
			scratchData.prizes = data[1]
			scratchData.luckPos = data[2]
			scratchData.theSerialNum = data[4]
		elseif scratchType == "lift" then
			scratchData.symbols = data[1]
			scratchData.prizes = data[2]
			scratchData.theSerialNum = data[4]
		end

		Fixedsys500c = dxCreateFont("files/Fixedsys500c.ttf", 11, true, "cleartype")

		if scratchPos then
			maskShader = dxCreateShader("files/scratch/mask.fx")
			maskRenderTarget = dxCreateRenderTarget(scratchPos.zoneSize[1], scratchPos.zoneSize[2], true)

			makeScratchTexture()

			if savedMasks[dbID] then
				dxSetTexturePixels(maskRenderTarget, savedMasks[dbID])
				dxSetShaderValue(maskShader, "MaskTexture", maskRenderTarget)
			end

			getScratchPercent()
		end

		addEventHandler("onClientClick", getRootElement(), scratchClick)
		addEventHandler("onClientRender", getRootElement(), scratchRender)
		addEventHandler("onClientCursorMove", getRootElement(), scratchCursorMove)
	else
		if isElement(maskRenderTarget) then
			local pixels = dxGetTexturePixels(maskRenderTarget)

			if pixels then
				if savedMasks[dbID] and not compareScratchOff(pixels, savedMasks[dbID]) or not savedMasks[dbID] then
					triggerServerEvent("createMask", localPlayer, scratchTicket, pixels)
				end
			end
		end

		removeEventHandler("onClientClick", getRootElement(), scratchClick)
		removeEventHandler("onClientRender", getRootElement(), scratchRender)
		removeEventHandler("onClientCursorMove", getRootElement(), scratchCursorMove)

		if isElement(scratchSound) then
			destroyElement(scratchSound)
		end
		scratchSound = nil

		if isElement(scratchTexture) then
			destroyElement(scratchTexture)
		end
		scratchTexture = nil

		if isElement(maskShader) then
			destroyElement(maskShader)
		end
		maskShader = nil

		if isElement(maskRenderTarget) then
			destroyElement(maskRenderTarget)
		end
		maskRenderTarget = nil

		if isElement(Fixedsys500c) then
			destroyElement(Fixedsys500c)
		end
		Fixedsys500c = nil

		scratchTicket = false
		scratchItem = false
		scratchType = false
	end
end

function makeScratchTexture()
	local scratchPos = scratchPoses[scratchType]

	if isElement(scratchTexture) then
		destroyElement(scratchTexture)
	end

	scratchTexture = dxCreateRenderTarget(scratchPos.zoneSize[1], scratchPos.zoneSize[2])

	dxSetRenderTarget(scratchTexture)
	dxSetBlendMode("modulate_add")
	dxDrawImage(0, 0, scratchPos.zoneSize[1], scratchPos.zoneSize[2], "files/scratch/" .. scratchType .. "/scratch.png")

	if scratchType == "blackjack" then
		dxDrawText("Sorozatszám: " .. scratchData.theSerialNum, 0, 10, scratchPos.zoneSize[1], 0, tocolor(60, 60, 60), 0.45, Fixedsys500c, "center", "top")
		dxDrawText(formatNumber(scratchData.prize) .. " $\nOsztó:\n" .. scratchData.winnerNumber, 0, 25, scratchPos.zoneSize[1], 0, tocolor(60, 60, 60), 0.75, Fixedsys500c, "center", "top")

		dxDrawText(scratchData.numbers[1], 10, 15, 45, 50, tocolor(60, 60, 60), 1, Fixedsys500c, "center", "center")
		dxDrawText(scratchData.numbers[2], 45, 100, 80, 135, tocolor(60, 60, 60), 1, Fixedsys500c, "center", "center")
		dxDrawText(scratchData.numbers[3], 116, 100, 151, 135, tocolor(60, 60, 60), 1, Fixedsys500c, "center", "center")
		dxDrawText(scratchData.numbers[4], 151, 15, 186, 50, tocolor(60, 60, 60), 1, Fixedsys500c, "center", "center")
	end

	if scratchType == "moneymania" then
		dxDrawRectangle(7 + 45 * 3, 0, 3, scratchPos.zoneSize[2], tocolor(100, 100, 100))

		for column = 0, 2 do
			for row = 0, 3 do
				if row == 3 then
					local prize = math.floor(scratchData.prizes[column + 1] / 1000)
					local prizeText = scratchData.prizes[column + 1]

					if prize > 0 then
						prizeText = prize .. "k"
					end

					if string.len(prizeText) >= 4 then
						dxDrawText(prizeText .. "$", 7 + 45 * row, 7 + 45 * column, 14 + 45 * (row + 1), 7 + 45 * (column + 1), tocolor(60, 60, 60), 0.6, Fixedsys500c, "center", "center")
					else
						dxDrawText(prizeText .. "$", 7 + 45 * row, 7 + 45 * column, 14 + 45 * (row + 1), 7 + 45 * (column + 1), tocolor(60, 60, 60), 0.8, Fixedsys500c, "center", "center")
					end
				else
					dxDrawImage(7 + 45 * row, 7 + 45 * column, 40, 40, "files/scratch/moneymania/" .. scratchData.symbols[column + 1][row + 1] .. ".png")
				end
			end
		end

		dxDrawText(scratchData.theSerialNum, 0, 0, 36 + 45 * 3, scratchPos.zoneSize[2], tocolor(60, 60, 60), 0.75, Fixedsys500c, "center", "bottom")
	end

	if scratchType == "piggy" then
		for column = 0, 1 do
			for row = 0, 2 do
				local x = 37 + 45 * row
				local y = 45 * column

				local prize = math.floor(scratchData.prizes[column + 1][row + 1] / 1000)
				local prizeText = scratchData.prizes[column + 1][row + 1]

				if prize > 0 then
					prizeText = prize .. "k"
				end

				dxDrawText(prizeText .. "$", x, y, x + 45, y + 45, tocolor(0, 0, 0), 0.85, Fixedsys500c, "center", "center")

				if scratchData.luckPos then
					if column == 0 and row + 1 == scratchData.luckPos then
						dxDrawImage(x + 22.5 - 8, y + 22.5 + 22.5 - 8, 16, 16, "files/scratch/piggy/luck.png", 0, 0, 0, tocolor(0, 0, 0))
					end
				end
			end
		end

		dxDrawText(scratchData.theSerialNum, 0, 0, scratchPos.zoneSize[1], scratchPos.zoneSize[2], tocolor(0, 0, 0), 0.75, Fixedsys500c, "center", "bottom")
	end

	if scratchType == "lift" then
		for x = 0, 5 do
			local prize = math.floor(scratchData.prizes[x + 1] / 1000)
			local prizeText = scratchData.prizes[x + 1]

			if prize > 0 then
				prizeText = prize .. "k"
			end

			if string.len(prizeText) >= 4 then
				dxDrawText(prizeText .. "$", 40 * x, 0, 40 * x + 30, 30, tocolor(0, 0, 0), 0.65, Fixedsys500c, "center", "center")
			else
				dxDrawText(prizeText .. "$", 40 * x, 0, 40 * x + 30, 30, tocolor(0, 0, 0), 0.75, Fixedsys500c, "center", "center")
			end

			for y = 0, 4 do
				dxDrawImage(40 * x, 33 + 40 * y, 30, 30, "files/scratch/lift/" .. scratchData.symbols[x + 1][y + 1] .. ".png")
			end
		end
	end

	dxSetBlendMode("blend")
	dxSetRenderTarget()
	dxSetShaderValue(maskShader, "ScreenTexture", scratchTexture)
end

function saveScratchMask()
	if isElement(maskRenderTarget) then
		if fileExists("savedMasks/" .. scratchTicket .. ".mask") then
			fileDelete("savedMasks/" .. scratchTicket .. ".mask")
		end

		local pixels = dxGetTexturePixels(maskRenderTarget)

		if pixels then
			local maskFile = fileCreate("savedMasks/" .. scratchTicket .. ".mask")

			if maskFile then
				fileWrite(maskFile, pixels)
				fileClose(maskFile)
			end
		end
	end
end

function loadScratchMask()
	if isElement(maskRenderTarget) then
		if fileExists("savedMasks/" .. scratchTicket .. ".mask") then
			local maskFile = fileOpen("savedMasks/" .. scratchTicket .. ".mask")

			if maskFile then
				local pixels = fileRead(maskFile, fileGetSize(maskFile))

				if pixels then
					dxSetTexturePixels(maskRenderTarget, pixels)
					dxSetShaderValue(maskShader, "MaskTexture", maskRenderTarget)
				end

				fileClose(maskFile)
			end
		end
	end
end

addEventHandler("onClientRestore", getRootElement(),
	function (cleared)
		if cleared then
			if scratchTicket then
				makeScratchTexture()
				loadScratchMask()
			end
		end
	end
)

function verifyScratch(itemId, dbID, data2, data3)
	if dbID then
		local pixels = savedMasks[dbID]
		local percent = 0

		if pixels then
			local tempTexture = dxCreateTexture(pixels)
			local sizeX, sizeY = dxGetMaterialSize(tempTexture)

			destroyElement(tempTexture)

			for i = 0, 1, 0.1 do
				for j = 0, 1, 0.1 do
					local r, g, b, a = dxGetPixelColor(pixels, i * sizeX, j * sizeY)

					if a and a > 0 then
						percent = percent + 1
					end
				end
			end
		end

		if percent >= 75 or data3 == "empty" then
			triggerServerEvent("checkTicketWin", localPlayer, dbID)
		else
			outputChatBox("#3d7abc[StrongMTA - Szerencsejáték]: #ffffffEz a sorsjegy még nincs lekaparva!", 255, 255, 255, true)
		end
	end
end

function compareScratchOff(firstPixels, secondPixels)
	if firstPixels and secondPixels then
		local firstTexture = dxCreateTexture(firstPixels)
		local secondTexture = dxCreateTexture(secondPixels)

		local firstSizeX, firstSizeY = dxGetMaterialSize(firstTexture)
		local secondSizeX, secondSizeY = dxGetMaterialSize(secondTexture)

		destroyElement(firstTexture)
		destroyElement(secondTexture)

		local firstPercent = 0
		local secondPercent = 0

		for i = 0, 1, 0.1 do
			for j = 0, 1, 0.1 do
				local r, g, b, a = dxGetPixelColor(firstPixels, i * firstSizeX, j * firstSizeY)

				if a and a > 0 then
					firstPercent = firstPercent + 1
				end

				local r2, g2, b2, a2 = dxGetPixelColor(secondPixels, i * secondSizeX, j * secondSizeY)

				if a2 and a2 > 0 then
					secondPercent = secondPercent + 1
				end
			end
		end

		if firstPercent == secondPercent then
			return true
		else
			return false
		end
	end
end

function scratchClick(button, state, absX, absY)
	if button == "left" then
		if state == "down" then
			if activeButton2 == "scratchZone" then
				lastCursorX = absX
				lastCursorY = absY
				holdLMB = true
			end
		else
			if state == "up" then
				if holdLMB then
					holdLMB = false

					saveScratchMask()

					if isElement(scratchSound) then
						destroyElement(scratchSound)
					end
					scratchSound = nil

					if scratchData.percent ~= scratchPercent then
						scratchData.percent = scratchPercent
						triggerEvent("updateData2", localPlayer, "player", scratchTicket, scratchPercent)
					end
				end
			end
		end
	end
end

local lastCheck = 0

function getScratchPercent()
	local percent = 0

	if isElement(maskRenderTarget) then
		if getTickCount() - lastCheck > 100 then
			local sx, sy = dxGetMaterialSize(maskRenderTarget)
			local pixels = dxGetTexturePixels(maskRenderTarget)

			for i = 0, 1, 0.1 do
				for j = 0, 1, 0.1 do
					local r, g, b, a = dxGetPixelColor(pixels, i * sx, j * sy)

					if a and a > 0 then
						percent = percent + 1
					end
				end
			end
			lastCheck = getTickCount()
		end
	end

	if percent > 100 then
		percent = 100
	end

	scratchPercent = percent
end

function scratchCursorMove(relX, relY, absX, absY)
	local distX = math.abs(absX - lastCursorX)
	local distY = math.abs(absY - lastCursorY)

	if distX > 1 or distY > 1 then
		local centerX = absX + (lastCursorX - absX) / 2
		local centerY = absY + (lastCursorY - absY) / 2

		maskRotation = math.deg(math.atan2(absY - centerY, absX - centerX)) - 90
	end

	if scratchType and activeButton2 == "scratchZone" and holdLMB then
		local scratchPos = scratchPoses[scratchType]

		local x = absX + (lastCursorX - absX) / 2 - scratchPos.zonePos[1] - maskWidth / 2
		local y = absY + (lastCursorY - absY) / 2 - scratchPos.zonePos[2] - maskHeight / 2

		dxSetRenderTarget(maskRenderTarget)
		dxSetBlendMode("modulate_add")
		dxDrawImage(x, y, maskWidth, maskHeight, "files/scratch/mask.png", maskRotation)
		dxSetBlendMode("blend")
		dxSetRenderTarget()
		dxSetShaderValue(maskShader, "MaskTexture", maskRenderTarget)

		getScratchPercent()

		if distX >= 1 or distY >= 1 then
			if not scratchSound then
				scratchSound = playSound("files/scratch/scratch.mp3", true)
			end
		else
			if isElement(scratchSound) then
				destroyElement(scratchSound)
			end
			scratchSound = nil
		end
	else
		if isElement(scratchSound) then
			destroyElement(scratchSound)
		end
		scratchSound = nil
	end

	lastCursorX = absX
	lastCursorY = absY
end

function scratchRender()
	if not scratchType then
		return
	end

	local relX, relY = getCursorPosition()
	local absX, absY = -1, -1

	if isCursorShowing() then
		absX = relX * screenX
		absY = relY * screenY
	end

	local buttons = {}
	local scratchPos = scratchPoses[scratchType]

	if activeButton2 == "scratchZone" and holdLMB then
		if scratchPercent >= 75 then
			if not successNotiState then
				successNotiState = true

				if scratchState ~= "empty" then
					triggerEvent("updateData3", localPlayer, "player", scratchTicket, "empty")
				end

				exports.see_hud:showInfobox("i", "Sikeresen lekapartad a sorsjegyet!\nAdd át egy eladónak az érvényesítéshez! ((Húzd rá))")
			end
		end
	end

	buttons.scratchZone = {scratchPos.zonePos[1], scratchPos.zonePos[2], scratchPos.zoneSize[1], scratchPos.zoneSize[2]}

	dxDrawImage(scratchPos.zonePos[1], scratchPos.zonePos[2], scratchPos.zoneSize[1], scratchPos.zoneSize[2], "files/scratch/" .. scratchType .. "/full.png")
	dxDrawImage(scratchPos.zonePos[1], scratchPos.zonePos[2], scratchPos.zoneSize[1], scratchPos.zoneSize[2], maskShader)
	dxDrawImage(scratchPos.basePos[1], scratchPos.basePos[2], scratchPos.baseSize[1], scratchPos.baseSize[2], "files/scratch/" .. scratchType .. "/background.png")

	activeButton2 = false

	for k, v in pairs(buttons) do
		if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
			activeButton2 = k
			break
		end
	end
end

function openLotteryTicket(itemId, state, data2)
	if secondTicket then
		return
	end

	if firstTicket and lotteryItem then
		if itemId ~= lotteryItem then
			return
		end
	end

	if state then
		local nums = fromJSON(data2 or "")

		lotteryNums = {}

		if nums then
			for k, v in pairs(nums) do
				lotteryNums[tonumber(v)] = true
			end
		end

		lotteryFont = dxCreateFont("files/Fixedsys500c.ttf", 9, false, "antialiased")
		lotteryItem = itemId
		firstTicket = true

		addEventHandler("onClientClick", getRootElement(), ticketClick)
		addEventHandler("onClientRender", getRootElement(), ticketRender)
	else
		removeEventHandler("onClientClick", getRootElement(), ticketClick)
		removeEventHandler("onClientRender", getRootElement(), ticketRender)

		firstTicket = false
		lotteryItem = false
		lotteryNums = {}

		if isElement(lotteryFont) then
			destroyElement(lotteryFont)
		end

		lotteryFont = nil
	end
end

function isLotteryInUse()
	if firstTicket or secondTicket then
		return true
	end

	return false
end

function checkLotteryTicket(itemId, state, data1, data2, data3)
	if firstTicket then
		return
	end

	if secondTicket and lotteryItem then
		if itemId ~= lotteryItem then
			return
		end
	end

	if state then
		secondTicket = {}

		secondTicket[1] = fromJSON(data1 or "")
		secondTicket[2] = table.concat(secondTicket[1], ", ")
		secondTicket[3] = fromJSON(data3 or "")
		secondTicket[4] = data2

		lotteryItem = itemId
		lotteryFont = dxCreateFont("files/Roboto.ttf", 14, false, "cleartype")
		barcodeFont = dxCreateFont("files/barcode.ttf", 16, false, "cleartype")

		addEventHandler("onClientClick", getRootElement(), ticketClick)
		addEventHandler("onClientRender", getRootElement(), ticketRender)
	else
		removeEventHandler("onClientClick", getRootElement(), ticketClick)
		removeEventHandler("onClientRender", getRootElement(), ticketRender)

		secondTicket = false
		lotteryItem = false

		if isElement(lotteryFont) then
			destroyElement(lotteryFont)
		end

		lotteryFont = nil

		if isElement(barcodeFont) then
			destroyElement(barcodeFont)
		end

		barcodeFont = nil
	end
end

function ticketClick(button, state)
	if button == "left" then
		if state == "up" then
			if activeButton2 then
				if string.find(activeButton2, "selectNum:") then
					local theNumber = tonumber(gettok(activeButton2, 2, ":"))

					if theNumber then
						if getTickCount() - clickTick <= 750 then
							exports.see_hud:showInfobox("e", "Kicsit lassabban!")
							return
						end

						clickTick = getTickCount()
						lotteryNums[theNumber] = not lotteryNums[theNumber]

						if lotteryNums[theNumber] then
							local numbers = {}

							for k, v in pairs(lotteryNums) do
								if v then
									table.insert(numbers, k)
								end
							end

							if #numbers > 5 then
								lotteryNums[theNumber] = false
								return
							end

							lotteryAnim[theNumber] = clickTick
							playSound("files/lottery/pen.mp3")

							if #numbers == 5 then
								triggerEvent("updateData2", localPlayer, "player", lotteryItem, toJSON(numbers, true))
								exports.see_hud:showInfobox("i", "Sikeresen kitöltötted a szelvényt!\nAdd át egy eladónak az érvényesítéshez! ((Húzd rá))")
							end
						end
					end
				end
			end
		end
	end
end

local fieldPosX = firstTicketPosX + 85
local fieldPosY = firstTicketPosY + 15

local fieldWidth = 353
local fieldHeight = 222

local fieldInLine = 10
local fieldInColumn = 9

local fieldSizeX = fieldWidth / fieldInLine
local fieldSizeY = fieldHeight / fieldInColumn

function ticketRender()
	local relX, relY = getCursorPosition()
	local absX, absY = -1, -1

	if isCursorShowing() then
		absX = relX * screenX
		absY = relY * screenY
	end

	local buttons = {}

	if secondTicket then
		dxDrawImage(secondTicketPosX, secondTicketPosY, secondTicketWidth, secondTicketHeight, "files/lottery/bcg2.png")

		dxDrawText("<< NYUGTA >>", secondTicketPosX, secondTicketPosY + 123, secondTicketPosX + secondTicketWidth, secondTicketPosY, tocolor(60, 60, 60), 1, lotteryFont, "center", "top")

		dxDrawText(secondTicket[3][2] .. ". játék", secondTicketPosX, secondTicketPosY, secondTicketPosX + secondTicketWidth, secondTicketPosY + 175, tocolor(60, 60, 60), 1, lotteryFont, "center", "bottom")

		dxDrawText(secondTicket[2], secondTicketPosX, secondTicketPosY + 197, secondTicketPosX + secondTicketWidth, secondTicketPosY + 237, tocolor(60, 60, 60), 1, lotteryFont, "center", "center")

		dxDrawText(secondTicket[3][1], secondTicketPosX, secondTicketPosY, secondTicketPosX + secondTicketWidth, secondTicketPosY + 392, tocolor(60, 60, 60), 0.8, lotteryFont, "center", "bottom")
		dxDrawText(secondTicket[3][3], secondTicketPosX, secondTicketPosY + 300, secondTicketPosX + secondTicketWidth, secondTicketPosY + secondTicketHeight, tocolor(0, 0, 0), 1, barcodeFont, "center", "center")

		if secondTicket[4] == "empty" then
			dxDrawImage(secondTicketPosX - 32, secondTicketPosY - 16, secondTicketWidth, secondTicketHeight, "files/lottery/nowin.png")
		end
	elseif firstTicket then
		dxDrawImage(firstTicketPosX, firstTicketPosY, firstTicketWidth, firstTicketHeight, "files/lottery/bcg.png")

		for x = 0, fieldInLine - 1 do
			for y = 0, fieldInColumn - 1 do
				local theX = fieldPosX + x * fieldSizeX + 3
				local theY = fieldPosY + y * fieldSizeY + 3
				local theNumber = x + 1 + y * fieldInLine

				dxDrawImage(theX, theY, fieldSizeX - 6, fieldSizeY - 6, "files/lottery/rect.png")
				dxDrawText(theNumber, theX, theY, theX + fieldSizeX - 6, theY + fieldSizeY - 6, tocolor(60, 60, 60), 1, lotteryFont, "center", "center")

				if lotteryAnim[theNumber] then
					local elapsedTime = getTickCount() - lotteryAnim[theNumber]
					local progress = elapsedTime / 100

					if progress > 1 then
						progress = 1
					end

					dxDrawImageSection(theX, theY, (fieldSizeX - 6) * progress, fieldSizeY - 6, 0, 0, 21 * progress, 21, "files/lottery/pen.png", 0, 0, 0, tocolor(255, 255, 255, 240))

					if progress >= 1 then
						progress = (elapsedTime - 100) / 100

						if progress > 1 then
							progress = 1
						end

						dxDrawImageSection(theX, theY, (fieldSizeX - 6) * progress, fieldSizeY - 6, 0, 0, 21 * progress, 21, "files/lottery/pen2.png", 0, 0, 0, tocolor(255, 255, 255, 240))
					end

					if elapsedTime >= 200 then
						lotteryAnim[theNumber] = nil
					end
				else
					if lotteryNums[theNumber] then
						dxDrawImage(theX, theY, fieldSizeX - 6, fieldSizeY - 6, "files/lottery/pen.png", 0, 0, 0, tocolor(255, 255, 255, 240))
						dxDrawImage(theX, theY, fieldSizeX - 6, fieldSizeY - 6, "files/lottery/pen2.png", 0, 0, 0, tocolor(255, 255, 255, 240))
					end

					buttons["selectNum:" .. theNumber] = {theX, theY, fieldSizeX - 6, fieldSizeY - 6}
				end
			end
		end
	end

	activeButton2 = false

	for k, v in pairs(buttons) do
		if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
			activeButton2 = k
			break
		end
	end
end

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
	if button == "right" then
		if state == "up" then
			if isElement(clickedElement) then
				if getElementData(clickedElement, "isLottery") then
					if not buyPanelState then
						buyPanelState = true
					end
				end
			end
		end
	else
		if button == "left" then
			if state == "up" then
				if activeButton then
					if activeButton == "promptNo" then
						if buyPanelState then
							buyPanelState = false
						end
					elseif activeButton == "promptYes" then
						if buyPanelState then
							if getTickCount() - lastLotteryBuy <= 10000 then
								exports.see_hud:showInfobox("e", "Csak 10 másodpercenként kérhetsz új szelvényt!")
								return
							end

							lastLotteryBuy = getTickCount()
							triggerServerEvent("giveALotteryTicket", localPlayer)
							buyPanelState = false
						end
					end
				end
			end
		end
	end
end

function onRender()
	local relX, relY = getCursorPosition()
	local absX, absY = -1, -1

	if isCursorShowing() then
		absX = relX * screenX
		absY = relY * screenY
	end

	local buttons = {}

	if buyPanelState then
		dxDrawRectangle(promptPosX, promptPosY, promptWidth, promptHeight, tocolor(0, 0, 0, 200))
		dxDrawText("Szeretnél vásárolni egy üres lottó szelvényt?\n\nÁr: 500$", promptPosX, promptPosY, promptPosX + promptWidth, promptPosY + promptHeight, tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)

		buttons.promptYes = {promptPosX, promptPosY + promptHeight, promptWidth / 2, respc(50)}

		if activeButton == "promptYes" then
			dxDrawRectangle(buttons.promptYes[1], buttons.promptYes[2], buttons.promptYes[3], buttons.promptYes[4], tocolor(61, 122, 188, 255))
		else
			dxDrawRectangle(buttons.promptYes[1], buttons.promptYes[2], buttons.promptYes[3], buttons.promptYes[4], tocolor(61, 122, 188, 175))
		end

		dxDrawText("Igen", buttons.promptYes[1], buttons.promptYes[2], buttons.promptYes[1] + buttons.promptYes[3], buttons.promptYes[2] + buttons.promptYes[4], tocolor(0, 0, 0), 1, Roboto, "center", "center")

		buttons.promptNo = {buttons.promptYes[1] + buttons.promptYes[3], buttons.promptYes[2], buttons.promptYes[3], buttons.promptYes[4]}

		if activeButton == "promptNo" then
			dxDrawRectangle(buttons.promptNo[1], buttons.promptNo[2], buttons.promptNo[3], buttons.promptNo[4], tocolor(215, 89, 89, 255))
		else
			dxDrawRectangle(buttons.promptNo[1], buttons.promptNo[2], buttons.promptNo[3], buttons.promptNo[4], tocolor(215, 89, 89, 175))
		end

		dxDrawText("Nem", buttons.promptNo[1], buttons.promptNo[2], buttons.promptNo[1] + buttons.promptNo[3], buttons.promptNo[2] + buttons.promptNo[4], tocolor(0, 0, 0), 1, Roboto, "center", "center")
	end

	activeButton = false

	for k, v in pairs(buttons) do
		if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
			activeButton = k
			break
		end
	end
end

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

addEvent("requestDatasOfLottery", true)
addEventHandler("requestDatasOfLottery", getRootElement(),
	function (curgame, prize, numbers)
		currentGame = curgame

		if isElement(interiorThings[6]) then
			local textLines = {}
			local tempFont = dxCreateFont("files/ocr.ttf", 7, false, "antialiased")

			for i = 1, #numbers do
				local v = numbers[i]

				table.insert(textLines, string.format("#ff0000%d. #ffffffjáték: #32b3ef%s\n#ffffffFőnyeremény: #00ff00%s $", v.id, table.concat(fromJSON(v.nums), " | "), formatNumber(v.prize)))
			end

			dxSetRenderTarget(interiorThings[6])

			dxDrawRectangle(0, 0, 256, 200, tocolor(0, 0, 0))
			dxDrawImage(2, 0, 256, 49, "files/lottery/teletext.png")
			dxDrawText(string.format("#ffff00Jelenlegi játék: %d#ffffff.\nVárható főnyeremény: #00ff00%s $#ffffff\n%s", currentGame, formatNumber(prize), table.concat(textLines, "\n")), 0, 32, 256, 128, tocolor(255, 255, 255), 1, tempFont, "center", "center", false, false, false, true)

			dxSetRenderTarget()

			if isElement(tempFont) then
				destroyElement(tempFont)
			end
		end
	end
)

addEventHandler("onClientRestore", getRootElement(),
	function ()
		if inLotteryInterior then
			if isElement(interiorThings[6]) then
				triggerServerEvent("requestDatasOfLottery", localPlayer)
			end
		end
	end
)

function isInLotteryInterior(dimension)
	if dimension == 33 then
		return true
	end

	return false
end

function checkInterior()
	local myDimension = getElementDimension(localPlayer)

	if isInLotteryInterior(myDimension) then
		if not inLotteryInterior then
			inLotteryInterior = true
			interiorThings = {}

			Roboto = dxCreateFont("files/Roboto.ttf", respc(16), false, "antialiased")

			interiorThings[1] = createObject(1504, -2171.1001, 639.90002, 1051.4)
			setElementInterior(interiorThings[1], 1)
			setElementDimension(interiorThings[1], myDimension)

			interiorThings[2] = createObject(3095, -2160.8999, 640, 1050.8)
			setElementInterior(interiorThings[2], 1)
			setElementDimension(interiorThings[2], myDimension)

			interiorThings[3] = createPed(190, -2158.8662109375, 640.36663818359, 1052.3817138672)
			setElementInterior(interiorThings[3], 1)
			setElementDimension(interiorThings[3], myDimension)
			setElementFrozen(interiorThings[3], true)
			setElementData(interiorThings[3], "invulnerable", true)
			setElementData(interiorThings[3], "visibleName", "Vivian")
			setElementData(interiorThings[3], "isLottery", true)

			interiorThings[4] = createObject(2790, -2171.7, 643.59998, 1053.9, 0, 0, 90)
			setElementInterior(interiorThings[4], 1)
			setElementDimension(interiorThings[4], myDimension)
			setObjectScale(interiorThings[4], 0.45)

			interiorThings[5] = dxCreateShader("files/texturechanger.fx")
			interiorThings[6] = dxCreateRenderTarget(256, 132)

			dxSetShaderValue(interiorThings[5], "gTexture", interiorThings[6])
			engineApplyShaderToWorldTexture(interiorThings[5], "cj_airp_s_2")

			addEventHandler("onClientClick", getRootElement(), onClick)
			addEventHandler("onClientRender", getRootElement(), onRender)

			if eventName == "onClientResourceStart" then
				setTimer(triggerServerEvent, 2000, 1, "requestDatasOfLottery", localPlayer)
			else
				triggerServerEvent("requestDatasOfLottery", localPlayer)
			end
		end
	else
		if inLotteryInterior then
			inLotteryInterior = false
			buyPanelState = false

			removeEventHandler("onClientClick", getRootElement(), onClick)
			removeEventHandler("onClientRender", getRootElement(), onRender)

			if isElement(Roboto) then
				destroyElement(Roboto)
			end

			Roboto = nil

			for i = 1, #interiorThings do
				if isElement(interiorThings[i]) then
					destroyElement(interiorThings[i])
				end
			end

			interiorThings = {}
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, checkInterior)
addEventHandler("onClientElementStreamOut", localPlayer, checkInterior)
