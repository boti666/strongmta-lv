local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local windowlessModels = {
	[424] = true,
	[457] = true,
	[486] = true,
	[500] = true,
	[504] = true,
	[530] = true,
	[531] = true,
	[539] = true,
	[568] = true,
	[571] = true,
	[572] = true
}

local windowIds = {3, 1, 4, 2}
local seatWindows = {
	[0] = 4,
	[1] = 2,
	[2] = 5,
	[3] = 3
}

local windowTick = {}
local windowNames = {
	"Jobb első ablak",
	"Jobb hátsó ablak",
	"Bal első (sofőr) ablak",
	"Bal hátsó ablak"
}

local doorTick = {}
local doorNames = {
	"Motorháztető",
	"Csomagtartó",
	"Balelső ajtó",
	"Jobbelső ajtó",
	"Balhátsó ajtó",
	"Jobbhátsó ajtó"
}

local panelState = false
local panelStage = false
local panelFont = false

local panelWidth = respc(275)
local panelHeight = respc(375)

local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

local titleHeight = respc(30)

local activeButton = false

local panelIsMoving = false
local moveDifferenceX = 0
local moveDifferenceY = 0

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local vehicles = getElementsByType("vehicle")

		for i = 1, #vehicles do
			local vehicle = vehicles[i]

			if isElement(vehicle) then
				for j = 2, 5 do
					local windowState = getElementData(vehicle, "vehicle.window." .. j)

					setVehicleWindowOpen(vehicle, 5, windowState)
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if string.find(dataName, "vehicle.window.") then
			local windowId = tonumber(gettok(dataName, 3, "."))

			if windowId then
				setVehicleWindowOpen(source, windowId, getElementData(source, dataName))
			end
		end
	end
)

addEvent("playWindowSound", true)
addEventHandler("playWindowSound", getRootElement(),
	function (state)
		if state == "2d" then
			playSound("files/window.mp3")
		else
			local vehX, vehY, vehZ = getElementPosition(source)
			local soundEffect = playSound3D("files/window.mp3", vehX, vehY, vehZ)

			attachElements(soundEffect, source)
			setElementInterior(soundEffect, getElementInterior(source))
			setElementDimension(soundEffect, getElementDimension(source))
			setSoundMaxDistance(soundEffect, 5)
		end
	end
)

local lastVehcile = getPedOccupiedVehicle(localPlayer)
if not getVehicleType(lastVehcile) == "Automobile" then
	setElementData(lastVehcile, "windowState", false)
end

addCommandHandler("ablak",
	function ()
		local currentVehicle = getPedOccupiedVehicle(localPlayer)

		if currentVehicle then
			if getVehicleType(currentVehicle) == "Automobile" then
				local vehicleModel = getElementModel(currentVehicle)

				if not windowlessModels[vehicleModel] then
					local currentSeat = getPedOccupiedVehicleSeat(localPlayer)

					if currentSeat ~= 0 then
						local window = tonumber(seatWindows[currentSeat]) or 2

						if not windowTick[window] then
							windowTick[window] = 0
						end

						if getTickCount() - windowTick[window] > 4000 then
							setElementData(currentVehicle, "vehicle.window." .. window, not getElementData(currentVehicle, "vehicle.window." .. window))

							if getElementData(currentVehicle, "vehicle.window." .. window) then
								exports.see_chat:localActionC(localPlayer, "lehúzza a " .. utf8.lower(windowNames[window - 1]) .. "ot.")
							else
								exports.see_chat:localActionC(localPlayer, "felhúzza a " .. utf8.lower(windowNames[window - 1]) .. "ot.")
							end

							local windowState = false

							for i = 2, 5 do
								if getElementData(currentVehicle, "vehicle.window." .. i) then
									windowState = true
									break
								end
							end

							setElementData(currentVehicle, "vehicle.windowState", not windowState)

							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local players = getElementsByType("player", getRootElement(), true)
							local affected = {}

							for i = 1, #players do
								local player = players[i]

								if player ~= localPlayer then
									if getPedOccupiedVehicle(player) == currentVehicle then
										table.insert(affected, {player, "2d"})
									else
										local targetX, targetY, targetZ = getElementPosition(player)

										if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 10 then
											table.insert(affected, {player, "3d"})
										end
									end
								end
							end

							if #affected > 0 then
								triggerServerEvent("playWindowSound", currentVehicle, affected)
							end

							playSound("files/window.mp3")

							windowTick[window] = getTickCount()
						end
					else
						if panelStage ~= "cveh" then
							panelState = not panelState

							if panelState then
								panelStage = "window"
								panelFont = dxCreateFont("files/Roboto.ttf", respc(15), false, "antialiased")
								
								addEventHandler("onClientRender", getRootElement(), onRender)
								addEventHandler("onClientClick", getRootElement(), onClick)
							else
								panelStage = false

								removeEventHandler("onClientRender", getRootElement(), onRender)
								removeEventHandler("onClientClick", getRootElement(), onClick)

								if isElement(panelFont) then
									destroyElement(panelFont)
								end

								panelFont = nil
							end
						end
					end
				end
			else
				windowState = false
			end
		end
	end
)
bindKey("F4", "down", "ablak")

addCommandHandler("cveh",
	function ()
		if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			if panelStage ~= "window" then
				panelState = not panelState

				if panelState then
					panelStage = "cveh"
					panelFont = dxCreateFont("files/Roboto.ttf", respc(15), false, "antialiased")
					
					addEventHandler("onClientRender", getRootElement(), onRender)
					addEventHandler("onClientClick", getRootElement(), onClick)
				else
					panelStage = false

					removeEventHandler("onClientRender", getRootElement(), onRender)
					removeEventHandler("onClientClick", getRootElement(), onClick)

					if isElement(panelFont) then
						destroyElement(panelFont)
					end

					panelFont = nil
				end
			end
		end
	end
)

function onRender()
	local currentVehicle = getPedOccupiedVehicle(localPlayer)

	if not currentVehicle then
		panelState = false
		panelStage = false

		removeEventHandler("onClientRender", getRootElement(), onRender)
		removeEventHandler("onClientClick", getRootElement(), onClick)

		if isElement(panelFont) then
			destroyElement(panelFont)
		end

		panelFont = nil

		return
	end

	-- ** Keret
	dxDrawRectangle(panelPosX - 2, panelPosY, 2, panelHeight, tocolor(0, 0, 0, 255)) -- bal
	dxDrawRectangle(panelPosX + panelWidth, panelPosY, 2, panelHeight, tocolor(0, 0, 0, 255)) -- jobb
	dxDrawRectangle(panelPosX - 2, panelPosY - 2, panelWidth + 4, 2, tocolor(0, 0, 0, 255)) -- felső
	dxDrawRectangle(panelPosX - 2, panelPosY + panelHeight, panelWidth + 4, 2, tocolor(0, 0, 0, 255)) -- alsó
	
	-- ** Háttér
	dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 100))
	dxDrawImage(panelPosX, panelPosY + titleHeight, panelWidth, panelHeight - titleHeight, ":see_hud/files/images/vin.png")

	-- ** Cím
	dxDrawRectangle(panelPosX, panelPosY, panelWidth, titleHeight, tocolor(0, 0, 0, 200))

	if panelStage == "window" then
		dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Jármű ablak", panelPosX + respc(7.5), panelPosY, panelPosX + panelWidth, panelPosY + titleHeight, tocolor(255, 255, 255), 0.9, panelFont, "left", "center", false, false, false, true)
	elseif panelStage == "cveh" then
		dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Jármű ajtó", panelPosX + respc(7.5), panelPosY, panelPosX + panelWidth, panelPosY + titleHeight, tocolor(255, 255, 255), 0.9, panelFont, "left", "center", false, false, false, true)
	end

	-- ** Content
	local buttons = {}

	buttons.exit = {panelPosX + panelWidth - respc(28) - respc(5), panelPosY + titleHeight / 2 - respc(14), respc(28), respc(28)}

	if activeButton == "exit" then
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(215, 89, 89))
	else
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(255, 255, 255))
	end

	if panelStage == "window" then
		local oneButtonHeight = (panelHeight - titleHeight) / 4

		for i = 1, 4 do
			local buttonName = "openWindow_" .. i + 1
			local buttonY = panelPosY + titleHeight + oneButtonHeight * (i - 1)

			if i % 2 == 1 then
				dxDrawRectangle(panelPosX, buttonY, panelWidth, oneButtonHeight, tocolor(0, 0, 0, 155))
			else
				dxDrawRectangle(panelPosX, buttonY, panelWidth, oneButtonHeight, tocolor(0, 0, 0, 200))
			end

			dxDrawText(windowNames[i], panelPosX + respc(10), buttonY, 0, buttonY + oneButtonHeight, tocolor(255, 255, 255), 0.75, panelFont, "left", "center")

			buttons[buttonName] = {panelPosX + panelWidth - respc(100), buttonY + respc(10), respc(90), oneButtonHeight - respc(20)}

			if isVehicleWindowOpen(currentVehicle, i + 1) then
				if activeButton == buttonName then
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(215, 89, 89))
				else
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(215, 89, 89, 200))
				end
				dxDrawText("Felhúz", buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][1] + buttons[buttonName][3], buttons[buttonName][2] + buttons[buttonName][4], tocolor(0, 0, 0), 0.75, panelFont, "center", "center")
			else
				if activeButton == buttonName then
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(61, 122, 188))
				else
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(61, 122, 188, 200))
				end
				dxDrawText("Lehúz", buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][1] + buttons[buttonName][3], buttons[buttonName][2] + buttons[buttonName][4], tocolor(0, 0, 0), 0.75, panelFont, "center", "center")
			end
		end
	elseif panelStage == "cveh" then
		local oneButtonHeight = (panelHeight - titleHeight) / 6

		for i = 1, 6 do
			local buttonName = "openDoor_" .. i
			local buttonY = panelPosY + titleHeight + oneButtonHeight * (i - 1)

			if i % 2 == 1 then
				dxDrawRectangle(panelPosX, buttonY, panelWidth, oneButtonHeight, tocolor(0, 0, 0, 155))
			else
				dxDrawRectangle(panelPosX, buttonY, panelWidth, oneButtonHeight, tocolor(0, 0, 0, 200))
			end

			dxDrawText(doorNames[i], panelPosX + respc(10), buttonY, 0, buttonY + oneButtonHeight, tocolor(255, 255, 255), 0.75, panelFont, "left", "center")

			buttons[buttonName] = {panelPosX + panelWidth - respc(100), buttonY + respc(10), respc(90), oneButtonHeight - respc(20)}

			if getVehicleDoorOpenRatio(currentVehicle, i - 1) > 0.1 then
				if activeButton == buttonName then
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(215, 89, 89))
				else
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(215, 89, 89, 200))
				end
				dxDrawText("Becsuk", buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][1] + buttons[buttonName][3], buttons[buttonName][2] + buttons[buttonName][4], tocolor(0, 0, 0), 0.75, panelFont, "center", "center")
			else
				if activeButton == buttonName then
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(61, 122, 188))
				else
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(61, 122, 188, 200))
				end
				dxDrawText("Kinyit", buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][1] + buttons[buttonName][3], buttons[buttonName][2] + buttons[buttonName][4], tocolor(0, 0, 0), 0.75, panelFont, "center", "center")
			end
		end
	end

	-- ** Button handler
	activeButton = false

	if isCursorShowing() then
		local relX, relY = getCursorPosition()
		local absX, absY = relX * screenX, relY * screenY

		if panelIsMoving then
			panelPosX = absX - moveDifferenceX
			panelPosY = absY - moveDifferenceY
		else
			for k, v in pairs(buttons) do
				if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end

function onClick(button, state, absX, absY)
	if button == "left" then
		if state == "down" then
			if absX >= panelPosX and absX <= panelPosX + panelWidth - respc(28) - respc(5) and absY >= panelPosY and absY <= panelPosY + titleHeight then
				panelIsMoving = true
				moveDifferenceX = absX - panelPosX
				moveDifferenceY = absY - panelPosY
			else
				if activeButton then
					if activeButton == "exit" then
						panelState = false
						panelStage = false

						removeEventHandler("onClientRender", getRootElement(), onRender)
						removeEventHandler("onClientClick", getRootElement(), onClick)

						if isElement(panelFont) then
							destroyElement(panelFont)
						end

						panelFont = nil
					else
						local button = split(activeButton, "_")

						if button[1] == "openWindow" then
							local window = tonumber(button[2])

							if window then
								local currentVehicle = getPedOccupiedVehicle(localPlayer)

								if currentVehicle then
									if not windowTick[window] then
										windowTick[window] = 0
									end

									if getTickCount() - windowTick[window] > 4000 then
										setElementData(currentVehicle, "vehicle.window." .. window, not getElementData(currentVehicle, "vehicle.window." .. window))

										if getElementData(currentVehicle, "vehicle.window." .. window) then
											exports.see_chat:localActionC(localPlayer, "lehúzza a " .. utf8.lower(windowNames[window - 1]) .. "ot.")
										else
											exports.see_chat:localActionC(localPlayer, "felhúzza a " .. utf8.lower(windowNames[window - 1]) .. "ot.")
										end

										local windowState = false

										for i = 2, 5 do
											if getElementData(currentVehicle, "vehicle.window." .. i) then
												windowState = true
												break
											end
										end

										setElementData(currentVehicle, "vehicle.windowState", not windowState)

										local playerX, playerY, playerZ = getElementPosition(localPlayer)
										local players = getElementsByType("player", getRootElement(), true)
										local affected = {}

										for i = 1, #players do
											local player = players[i]

											if player ~= localPlayer then
												if getPedOccupiedVehicle(player) == currentVehicle then
													table.insert(affected, {player, "2d"})
												else
													local targetX, targetY, targetZ = getElementPosition(player)

													if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 10 then
														table.insert(affected, {player, "3d"})
													end
												end
											end
										end

										if #affected > 0 then
											triggerServerEvent("playWindowSound", currentVehicle, affected)
										end

										playSound("files/window.mp3")

										windowTick[window] = getTickCount()
									end
								end
							end
						elseif button[1] == "openDoor" then
							local door = tonumber(button[2])

							if door then
								local currentVehicle = getPedOccupiedVehicle(localPlayer)

								if currentVehicle then
									local players = getElementsByType("player", getRootElement(), true)
									local occupants = {}
									local affected = {}

									for i = 1, #players do
										local player = players[i]

										if getPedOccupiedVehicle(player) == currentVehicle then
											table.insert(occupants, player)
										else
											table.insert(affected, player)
										end
									end

									if not doorTick[door] then
										doorTick[door] = 0
									end

									if getTickCount() - doorTick[door] >= 750 then
										triggerServerEvent("openTheVehicleDoor", currentVehicle, door - 1, occupants, affected)

										if getVehicleDoorOpenRatio(currentVehicle, door - 1) > 0 then
											exports.see_chat:localActionC(localPlayer, "becsukja a " .. utf8.lower(doorNames[door]) .. "t.")
										else
											exports.see_chat:localActionC(localPlayer, "kinyitja a " .. utf8.lower(doorNames[door]) .. "t.")
										end

										doorTick[door] = getTickCount()
									end
								end
							end
						end
					end
				end
			end
		else
			if state == "up" then
				panelIsMoving = false
				moveDifferenceX = 0
				moveDifferenceY = 0
			end
		end
	end
end

addEvent("playDoorSound", true)
addEventHandler("playDoorSound", getRootElement(),
	function (vehicleElement, doorRatio, inVehicle)
		if doorRatio > 0 then
			setTimer(
				function (sourceElement)
					local soundPath = exports.see_vehiclepanel:getDoorCloseSound(getElementModel(sourceElement))

					if soundPath then
						if inVehicle and not isElement(vehicleElement) then
							playSound(soundPath)
						else
							local vehX, vehY, vehZ = getElementPosition(vehicleElement)
							local soundEffect = playSound3D(soundPath, vehX, vehY, vehZ)

							attachElements(soundEffect, vehicleElement)
							setElementInterior(soundEffect, getElementInterior(vehicleElement))
							setElementDimension(soundEffect, getElementDimension(vehicleElement))
						end
					end
				end,
			250, 1, source)
		else
			local soundPath = exports.see_vehiclepanel:getDoorOpenSound(getElementModel(source))

			if soundPath then
				if inVehicle and not isElement(vehicleElement) then
					playSound(soundPath)
				else
					local vehX, vehY, vehZ = getElementPosition(vehicleElement)
					local soundEffect = playSound3D(soundPath, vehX, vehY, vehZ)

					attachElements(soundEffect, vehicleElement)
					setElementInterior(soundEffect, getElementInterior(vehicleElement))
					setElementDimension(soundEffect, getElementDimension(vehicleElement))
				end
			end
		end
	end
)