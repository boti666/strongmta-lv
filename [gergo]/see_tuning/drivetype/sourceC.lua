local screenX, screenY = guiGetScreenSize()

local panelState = false
local panelPosX = screenX / 2 - 130 / 2
local panelPosY = screenY - 75 - 86
local panelIsMoving = false

local currentVehicle = false
local clickTick = 0

function renderDrivePanel()
	if not isPedInVehicle(localPlayer) or currentVehicle ~= getPedOccupiedVehicle(localPlayer) then
		panelState = false
		removeEventHandler("onClientRender", getRootElement(), renderDrivePanel)
		removeEventHandler("onClientClick", getRootElement(), onClientClick)
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

	dxDrawImage(panelPosX, panelPosY, 130, 86, "files/drivetype/panel.png")

	if getVehicleHandling(currentVehicle).driveType == "rwd" then
		dxDrawImage(panelPosX, panelPosY, 130, 86, "files/drivetype/led1.png")
	else
		dxDrawImage(panelPosX, panelPosY, 130, 86, "files/drivetype/led2.png")
	end
end

function onClientClick(button, state, absX, absY)
	local rwdButton = absX >= panelPosX + 15 and absY >= panelPosY + 17 and absX <= panelPosX + 58 and absY <= panelPosY + 52
	local awdButton = absX >= panelPosX + 73 and absY >= panelPosY + 17 and absX <= panelPosX + 116 and absY <= panelPosY + 52

	if state == "down" then
		if absX >= panelPosX and absY >= panelPosY and absX <= panelPosX + 130 and absY <= panelPosY + 86 and not rwdButton and not awdButton then
			panelIsMoving = {absX, absY, panelPosX, panelPosY}
			return
		end
	end

	if state == "up" and panelIsMoving then
		panelIsMoving = false
	end

	if state == "down" then
		if rwdButton or awdButton then
			if getTickCount() - clickTick < 1000 then
				exports.lv_hud:showInfobox("e", "Várj egy kicsit az átkapcsolással!")
				return
			end

			if rwdButton then
				if getVehicleHandling(currentVehicle).driveType ~= "rwd" then
					triggerServerEvent("setDriveType", currentVehicle, "rwd")
					clickTick = getTickCount()
				end
			elseif awdButton then
				if getVehicleHandling(currentVehicle).driveType ~= "awd" then
					triggerServerEvent("setDriveType", currentVehicle, "awd")
					clickTick = getTickCount()
				end
			end
		end
	end
end

addCommandHandler("drivetype",
	function ()
		if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local currVeh = getPedOccupiedVehicle(localPlayer)

			if getElementData(currVeh, "vehicle.tuning.DriveType") ~= "tog" then
				return
			end

			panelState = not panelState
			panelIsMoving = false

			if panelState then
				addEventHandler("onClientRender", getRootElement(), renderDrivePanel)
				addEventHandler("onClientClick", getRootElement(), onClientClick)

				currentVehicle = currVeh
			else
				removeEventHandler("onClientRender", getRootElement(), renderDrivePanel)
				removeEventHandler("onClientClick", getRootElement(), onClientClick)
			end
		end
	end)