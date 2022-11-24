local screenX, screenY = guiGetScreenSize()

local panelState = false
local panelPosX = screenX - 160 - 40
local panelPosY = screenY / 2 - 310 / 2
local panelIsMoving = false

local airRideLevel = 0
local airRideMemory1 = 0
local airRideMemory2 = 0

local memorySet = false
local clickTick = 0
local ledColor = ""

local arrowSize = 5.4705882352941

addEvent("playAirRideSound", true)
addEventHandler("playAirRideSound", getRootElement(),
	function (vehicle)
		if isElement(vehicle) then
			if getElementData(localPlayer, "loggedIn") then
				local x, y, z = getElementPosition(vehicle)
				local soundElement = playSound3D("files/airride/airride.mp3", x, y, z)

				if isElement(soundElement) then
					setSoundVolume(soundElement, 0.3)
					setElementDimension(soundElement, getElementDimension(vehicle))
					setElementInterior(soundElement, getElementInterior(vehicle))
					attachElements(soundElement, vehicle)
				end
			end
		end
	end)

function renderAirRidePanel()
	if not isPedInVehicle(localPlayer) then
		panelState = false
		removeEventHandler("onClientRender", getRootElement(), renderAirRidePanel)
		removeEventHandler("onClientClick", getRootElement(), onClick)
		return
	end

	if panelIsMoving then
		local cursorX, cursorY = getCursorPosition()

		if cursorX and cursorY then
			panelPosX = panelIsMoving[3] + (cursorX - panelIsMoving[1])
			panelPosY = panelIsMoving[4] + (cursorY - panelIsMoving[2])
		else
			panelIsMoving = false
		end
	end

	dxDrawImage(panelPosX, panelPosY, 160, 310, "files/airride/panel.png")

	if memorySet then
		dxDrawImage(panelPosX, panelPosY, 160, 310, "files/airride/ledorange.png")
	elseif getTickCount() - clickTick <= 520 then
		dxDrawImage(panelPosX, panelPosY, 160, 310, "files/airride/led" .. ledColor .. ".png")
	end

	dxDrawRectangle(panelPosX + 34 + arrowSize * (16 - airRideLevel), panelPosY + 94, arrowSize, 12, tocolor(0, 0, 0, 160))
	
	if 16 - airRideLevel > 0 then
		dxDrawImage(panelPosX + 34 + arrowSize * (16 - airRideLevel - 1), panelPosY + 94, arrowSize, 12, "files/airride/arrow.png", 180, 0, 0, tocolor(0, 0, 0, 160))
	end

	if 16 - airRideLevel < 16 then
		dxDrawImage(panelPosX + 34 + arrowSize * (16 - airRideLevel + 1), panelPosY + 94, arrowSize, 12, "files/airride/arrow.png", 0, 0, 0, tocolor(0, 0, 0, 160))
	end
end

function onClick(button, state, absX, absY)
	if state == "down" then
		if absX >= panelPosX and absY >= panelPosY and absX <= panelPosX + 160 and absY <= panelPosY + 310 and ((absX <= panelPosX + 24 or absX >= panelPosX + 138) and (absY >= panelPosY + 128 or absY <= panelPosY + 250) or absY <= panelPosY + 128 or absY >= panelPosY + 250) then
			panelIsMoving = {absX, absY, panelPosX, panelPosY}
			return
		end
	end

	if state == "up" and panelIsMoving then
		panelIsMoving = false
	end

	if state == "down" and getTickCount() - clickTick > 520 then
		local currVeh = getPedOccupiedVehicle(localPlayer)
		local velX, velY, velZ = getElementVelocity(currVeh)
		local actualspeed = math.sqrt(velX * velX + velY * velY + velZ * velZ) * 160

		if absX >= panelPosX + 23 and absX <= panelPosX + 138 then
			if absY >= panelPosY + 128 and absY <= panelPosY + 160 then
				if airRideLevel > 0 then
					memorySet = false

					if actualspeed <= 1 then
						airRideLevel = airRideLevel - 1
						ledColor = ""
						clickTick = getTickCount()
						triggerServerEvent("setAirRide", localPlayer, currVeh, airRideLevel, getElementsByType("player", root, true))
					else
						ledColor = "red"
						clickTick = getTickCount()
						playSound("files/airride/beep2.mp3")
					end
				end
			elseif absY >= panelPosY + 172 and absY <= panelPosY + 204 and airRideLevel < 16 then
				memorySet = false

				if actualspeed <= 1 then
					airRideLevel = airRideLevel + 1
					ledColor = ""
					clickTick = getTickCount()
					triggerServerEvent("setAirRide", localPlayer, currVeh, airRideLevel, getElementsByType("player", root, true))
				else
					ledColor = "red"
					clickTick = getTickCount()
					playSound("files/airride/beep2.mp3")
				end
			end
		end

		if absY >= panelPosY + 218 and absY <= panelPosY + 250 then
			if absX >= panelPosX + 23 and absX <= panelPosX + 56 then
				if memorySet then
					memorySet = false

					setElementData(currVeh, "airRideMemory1", airRideLevel)
					airRideMemory1 = airRideLevel

					playSound("files/airride/beep1.mp3")
					ledColor = "green"
					clickTick = getTickCount()
				elseif actualspeed <= 1 then
					if airRideLevel ~= airRideMemory1 then
						airRideLevel = airRideMemory1

						ledColor = ""
						clickTick = getTickCount()

						triggerServerEvent("setAirRide", localPlayer, currVeh, airRideMemory1, getElementsByType("player", root, true))
					end
				else
					ledColor = "red"
					clickTick = getTickCount()
					playSound("files/airride/beep2.mp3")
				end
			end

			if absX >= panelPosX + 64 and absX <= panelPosX + 98 then
				if memorySet then
					memorySet = false

					setElementData(currVeh, "airRideMemory2", airRideLevel)
					airRideMemory2 = airRideLevel

					playSound("files/airride/beep1.mp3")
					ledColor = "green"
					clickTick = getTickCount()
				elseif actualspeed <= 1 then
					if airRideLevel ~= airRideMemory2 then
						airRideLevel = airRideMemory2

						ledColor = ""
						clickTick = getTickCount()

						triggerServerEvent("setAirRide", localPlayer, currVeh, airRideMemory2, getElementsByType("player", root, true))
					end
				else
					ledColor = "red"
					clickTick = getTickCount()
					playSound("files/airride/beep2.mp3")
				end
			end

			if absX >= panelPosX + 104 and absX <= panelPosX + 138 then
				memorySet = true
			end
		end
	end
end

addCommandHandler("airride",
	function ()
		if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local currVeh = getPedOccupiedVehicle(localPlayer)

			if not getElementData(currVeh, "vehicle.tuning.AirRide") or getElementData(currVeh, "vehicle.tuning.AirRide") == 0 then
				return
			end

			panelState = not panelState
			panelIsMoving = false

			if panelState then
				addEventHandler("onClientRender", getRootElement(), renderAirRidePanel)
				addEventHandler("onClientClick", getRootElement(), onClick)

				memorySet = false
				airRideLevel = getElementData(currVeh, "airRideLevel") or 8
				airRideMemory1 = getElementData(currVeh, "airRideMemory1") or 8
				airRideMemory2 = getElementData(currVeh, "airRideMemory2") or 8
			else
				removeEventHandler("onClientRender", getRootElement(), renderAirRidePanel)
				removeEventHandler("onClientClick", getRootElement(), onClick)
			end
		end
	end)