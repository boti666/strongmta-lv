local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

--pcall(loadstring(base64Decode(exports.see_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.see_core:getInterfaceElements())));end)

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

function loadFonts()
	Roboto = dxCreateFont("files/Roboto.ttf", respc(12), false, "antialiased")
	--Roboto = exports.see_core:loadFont("Raleway.ttf", respc(12), false, "antialiased")
	Raleway14 = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")
	Raleway18 = dxCreateFont("files/Roboto.ttf", respc(18), false, "antialiased")
	Raleway24 = dxCreateFont("files/Roboto.ttf", respc(24), false, "antialiased")
	Raleway12 = dxCreateFont("files/Roboto.ttf", respc(12), false, "antialiased")
end

loadFonts()

addEventHandler("onAssetsLoaded", getRootElement(),
	function ()
		loadFonts()
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setInteriorSoundsEnabled(false)

		engineImportTXD(engineLoadTXD("files/kbroul2.txd"), 1979)
		engineImportTXD(engineLoadTXD("files/chips.txd"), 1853, 1854, 1855, 1856, 1857)
		engineImportTXD(engineLoadTXD("files/kb_wheel1.txd"), 1895)
		engineReplaceModel(engineLoadDFF("files/wheel_o_fortune.dff"), 1895)
		engineImportTXD(engineLoadTXD("files/kbblackjack.txd"), 2188)
		
		engineImportTXD(engineLoadTXD("files/pokertextura.txd"), 4334)
		engineReplaceCOL(engineLoadCOL("files/nagypoker.col"), 4334)
		engineReplaceModel(engineLoadDFF("files/nagypoker.dff"), 4334)
		engineImportTXD(engineLoadTXD("files/blinds.txd"), 1859, 1860)

		removeWorldModel(2188, 10000, 0, 0, 0)
		removeWorldModel(1978, 10000, 0, 0, 0)
		
	end)

addEvent("chipSound", true)
addEventHandler("chipSound", getRootElement(),
	function (x, y, z, num)
		local soundEffect = playSound3D("files/chip" .. num .. ".mp3", x, y, z)

		setSoundMaxDistance(soundEffect, 25)
		setElementInterior(soundEffect, getElementInterior(localPlayer))
		setElementDimension(soundEffect, getElementDimension(localPlayer))
	end
)

local playerIcons = {}

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "playerIcons" then
			if source ~= localPlayer then
				if isElementStreamedIn(source) then
					local dataVal = getElementData(source, dataName)

					if dataVal then
						playerIcons[source] = {dataVal[1], formatNumberEx(dataVal[2], ","), getTickCount()}
					else
						playerIcons[source] = nil
					end
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local now = getTickCount()
		local px, py, pz = getElementPosition(localPlayer)

		for player, data in pairs(playerIcons) do
			if not isElement(player) then
				playerIcons[player] = nil
			else
				local bx, by, bz = getPedBonePosition(player, 6)
				
				bz = bz + 0.75
				
				local x, y = getScreenFromWorldPosition(bx, by, bz)
				
				if x and y then
					local dist = getDistanceBetweenPoints3D(bx, by, bz, px, py, pz)
					
					if dist <= 25 then
						local scale = interpolateBetween(0.65, 0, 0, 0.15, 0, 0, dist / 100, "OutQuad")
						local r, g, b, a = 215, 89, 89, 200
						
						if data[1] == "plus" then
							r, g, b = 61, 122, 188
						end
						
						local progress = (now - data[3]) / 500

						if progress < 1 then
							a = a * progress
						elseif progress > 8 then
							a = 0
							playerIcons[player] = nil
						elseif progress >= 7 then
							a = a * (1 - (progress - 7))
						end
						
						local size = 128 * scale

						x = x - size / 2
						y = y - size / 2

						dxDrawImage(x, y, size, size, "files/" .. data[1] .. ".png", 0, 0, 0, tocolor(r, g, b, a))
						dxDrawText(data[2] .. " Coin", x, y + size, x + size, 0, tocolor(r, g, b, a), 1, Roboto, "center", "top")
					end
				end
			end
		end
	end)

local panelState = false
local panelWidth = respc(400)
local panelHeight = respc(240)
local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

local activeButton = false
local buttons = {
	buycoin = {
		panelPosX + respc(5),
		panelPosY + panelHeight - respc(80),
		panelWidth / 2 - respc(10),
		respc(30)
	},
	sellcoin = {
		panelPosX + panelWidth / 2 + respc(5),
		panelPosY + panelHeight - respc(80),
		panelWidth / 2 - respc(10),
		respc(30)
	},
	exit = {
		panelPosX + respc(5),
		panelPosY + panelHeight - respc(40),
		panelWidth - respc(10),
		respc(30)
	}
}

local currentBalance = 0
local selectedAmount = ""

local cursorState = false
local cursorStateChange = 0

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
		if button == "right" then
			if state == "up" then
				if not panelState then
					if isElement(clickedElement) then
						if getElementData(clickedElement, "currencyPed") then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local targetX, targetY, targetZ = getElementPosition(clickedElement)

							if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 5 then
								if not isPedInVehicle(localPlayer) then
									if getElementData(localPlayer, "coinTransaction") then
										exports.see_hud:showInfobox("e", "Kérlek várj egy kicsit!")
										return
									end

									togglePanel(true)
								end
							end
						end
					end
				end
			end
		end
	end)

function togglePanel(state)
	if state ~= panelState then
		panelState = state

		if panelState then

			currentBalance = getElementData(localPlayer, "char.slotCoins") or 0
			selectedAmount = ""

			addEventHandler("onClientRender", getRootElement(), renderPanel)
			addEventHandler("onClientClick", getRootElement(), clickPanel)
			addEventHandler("onClientCharacter", getRootElement(), processInputCharacter)
			addEventHandler("onClientKey", getRootElement(), processInputKey)
			addEventHandler("onClientElementDataChange", localPlayer, onSlotCoinChange)
		else
			removeEventHandler("onClientElementDataChange", localPlayer, onSlotCoinChange)
			removeEventHandler("onClientKey", getRootElement(), processInputKey)
			removeEventHandler("onClientCharacter", getRootElement(), processInputCharacter)
			removeEventHandler("onClientClick", getRootElement(), clickPanel)
			removeEventHandler("onClientRender", getRootElement(), renderPanel)

		end
	end
end

function onSlotCoinChange(dataName)
	if dataName == "char.slotCoins" then
		currentBalance = getElementData(localPlayer, dataName) or 0
	end
end

function clickPanel(button, state)
	if button == "left" then
		if state == "down" then
			if activeButton == "exit" then
				togglePanel(false)
			elseif activeButton == "buycoin" then
				local amount = tonumber(selectedAmount) or 0

				if amount > 0 then
					triggerServerEvent("buySlotCoin", localPlayer, amount)
					togglePanel(false)
				else
					exports.see_hud:showInfobox("e", "Minimum 1db Coin-t kell venned.")
				end
			elseif activeButton == "sellcoin" then
				local amount = tonumber(selectedAmount) or 0

				if amount > 0 then
					triggerServerEvent("sellSlotCoin", localPlayer, amount)
					togglePanel(false)
				else
					exports.see_hud:showInfobox("e", "Minimum 1db Coin-t kell eladnod.")
				end
			end
		end
	end
end

function processInputCharacter(character)
	if utfLen(selectedAmount) < 10 then
		if string.find(character, "[0-9]") then
			selectedAmount = selectedAmount .. character
		end
	end
end

function processInputKey(key, press)
	if press then
		if key == "backspace" then
			if utfLen(selectedAmount) >= 1 then
				selectedAmount = utfSub(selectedAmount, 1, -2)
			end
		elseif key ~= "escape" then
			cancelEvent()
		end
	end
end

function renderPanel()
	-- ** Háttér
	buttonsC = {}

	dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(25, 25, 25))
	dxDrawRectangle(panelPosX + 3, panelPosY + 3, panelWidth - 6, respc(30), tocolor(45, 45, 45))

	dxDrawText("#3d7abcStrong#ffffffMTA", panelPosX + 3 + 5, panelPosY + respc(30) / 2 + 3, nil, nil, tocolor(200, 200, 200, 200), 1, Roboto, "left", "center", false, false, false, true)

	-- ** Content
	local amount = tonumber(selectedAmount) or 0

	-- Egyenleg
	dxDrawText("Jelenlegi egyenleg: #3d7abc" .. formatNumberEx(currentBalance) .. " Coin\n#ffffffÁr: #3d7abc10 $/Coin\n#ffffffÖsszesen: #3d7abc" .. formatNumberEx(amount * 10) .. " $",
		panelPosX + panelWidth / 2, panelPosY + 3 + respc(40), nil, nil, tocolor(200, 200, 200, 200), 0.9, Roboto, "center", "top", false, false, false, true)

	-- Mennyiség
	dxDrawRectangle(panelPosX + respc(5), panelPosY + panelHeight - respc(130), panelWidth - respc(10), respc(40), tocolor(46, 46, 46, 160))

	local inputText = "Mennyiség: " .. formatNumberEx(selectedAmount)

	dxDrawText(inputText, panelPosX + respc(10), panelPosY + panelHeight - respc(130), 0, panelPosY + panelHeight - respc(90), tocolor(200, 200, 200, 200), 1, Roboto, "left", "center")

	if cursorStateChange + 500 <= getTickCount() then
		cursorState = not cursorState
		cursorStateChange = getTickCount()
	end

	if cursorState then
		dxDrawRectangle(panelPosX + respc(12) + dxGetTextWidth(inputText, 1, Roboto), panelPosY + panelHeight - respc(120), 1, respc(20), tocolor(200, 200, 200, 200))
	end

	drawButton("buycoin", "Vásárlás", buttons.buycoin[1], buttons.buycoin[2], buttons.buycoin[3], buttons.buycoin[4], {61, 122, 188}, false, Roboto, true)

	drawButton("sellcoin", "Eladás", buttons.sellcoin[1], buttons.sellcoin[2], buttons.sellcoin[3], buttons.sellcoin[4], {61, 122, 188}, false, Roboto, true)

	drawButton("exit", "Kilépés", buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], {215, 89, 89}, false, Roboto, true)

	-- ** Hovering
	local cx, cy = getCursorPosition()

	activeButton = false
	activeButtonC = false

	if cx then
		cx = cx * screenX
		cy = cy * screenY

		for k, v in pairs(buttons) do
			if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
				activeButton = k
				break
			end
		end

		for k, v in pairs(buttonsC) do
			if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
				activeButtonC = k
				break
			end
		end
	end
end

function formatNumberEx(amount, stepper)
	amount = tonumber(amount)

	if not amount then
		return ""
	end

	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end



		colorSwitches = {}
		lastColorSwitches = {}
		startColorSwitch = {}
		lastColorConcat = {}
		
		function processColorSwitchEffect(key, color, duration, type)
			if not colorSwitches[key] then
				if not color[4] then
					color[4] = 255
				end
		
				colorSwitches[key] = color
				lastColorSwitches[key] = color
		
				lastColorConcat[key] = table.concat(color)
			end
		
			duration = duration or 3000
			type = type or "Linear"
		
			if lastColorConcat[key] ~= table.concat(color) then
				lastColorConcat[key] = table.concat(color)
				lastColorSwitches[key] = color
				startColorSwitch[key] = getTickCount()
			end
		
			if startColorSwitch[key] then
				local progress = (getTickCount() - startColorSwitch[key]) / duration
		
				local r, g, b = interpolateBetween(
						colorSwitches[key][1], colorSwitches[key][2], colorSwitches[key][3],
						color[1], color[2], color[3],
						progress, type
				)
		
				local a = interpolateBetween(colorSwitches[key][4], 0, 0, color[4], 0, 0, progress, type)
		
				colorSwitches[key][1] = r
				colorSwitches[key][2] = g
				colorSwitches[key][3] = b
				colorSwitches[key][4] = a
		
				if progress >= 1 then
					startColorSwitch[key] = false
				end
			end
		
			return colorSwitches[key][1], colorSwitches[key][2], colorSwitches[key][3], colorSwitches[key][4]
		end

		local alpha = 1
		
		function rgba(r, g, b, a)
			return tocolor(r, g, b, (a or 255) * alpha)
		end
		
		function drawButton(key, label, x, y, w, h, activeColor, postGui, theFont, rgbaoff, labelScale)
			local buttonColor
			if activeButtonC == key then
				buttonColor = {processColorSwitchEffect(key, {activeColor[1], activeColor[2], activeColor[3], 175})}
			else
				buttonColor = {processColorSwitchEffect(key, {60, 60, 60, 125})}
			end
		
			local alphaDifference = 175 - buttonColor[4]
		
			labelFont = theFont
			postGui = postGui or false
			labelScale = labelScale or 0.85
			rgbaoff = true
			
			if rgbaoff then
				dxDrawRectangle(x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
				dxDrawInnerBorder(2, x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 125 + alphaDifference), postGui)
				dxDrawText(label, x, y, x + w, y + h, tocolor(200, 200, 200, 200), labelScale, labelFont, "center", "center", false, false, postGui, true)
			else
				dxDrawRectangle(x, y, w, h, rgba(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
				dxDrawInnerBorder(2, x, y, w, h, rgba(buttonColor[1], buttonColor[2], buttonColor[3], 125 + alphaDifference), postGui)
				dxDrawText(label, x, y, x + w, y + h, rgba(200, 200, 200, 200), labelScale, labelFont, "center", "center", false, false, postGui, true)
			end
		
			buttonsC[key] = {x, y, w, h}
		end
		
		function dxDrawInnerBorder(thickness, x, y, w, h, color, postGUI)
			thickness = thickness or 1
			dxDrawRectangle(x, y, w, thickness, color, postGUI)
			dxDrawRectangle(x, y + h - thickness, w, thickness, color, postGUI)
			dxDrawRectangle(x, y, thickness, h, color, postGUI)
			dxDrawRectangle(x + w - thickness, y, thickness, h, color, postGUI)
		end
