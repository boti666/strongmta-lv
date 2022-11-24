local screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local panelIsMoving = false
local panelState = false 
local panelPosX, panelPosY = screenX - respc(160) - respc(40), screenY / 2 - respc(310) / 2

local imageSizeX, imageSizeY = respc(160), respc(310)

local panelClickedTick = 0
local ledColor = false 

local panelImages = {
	mainPanel = "files/panel.png",
	ledOrange = "files/ledorange.png",
	ledRed = "files/ledred.png",
	ledGreen = "files/ledgreen.png"
}

local moveX = 0
local moveY = 0

function renderTheBackfirePanel()
	if not isPedInVehicle(localPlayer) then
		panelState = false
		removeEventHandler("onClientRender", getRootElement(), renderTheBackfirePanel)
		removeEventHandler("onClientClick", getRootElement(), handlePanelClick)
		return
	end

	buttons = {}

	-- ** Main panel
	dxDrawImage(panelPosX, panelPosY, imageSizeX, imageSizeY, panelImages.mainPanel)

	-- ** Led lights
	if getTickCount() - panelClickedTick <= 520 then
		dxDrawImage(panelPosX, panelPosY, respc(160), respc(310), panelImages.ledRed)
	else
		dxDrawImage(panelPosX, panelPosY, respc(160), respc(310), panelImages.ledGreen)
	end

	-- ** Button positions
	buttons.open = {panelPosX + respc(25), panelPosY + respc(128), respc(110), respc(30)}
	buttons.close = {panelPosX + respc(25), panelPosY + respc(128) + respc(43), respc(110), respc(30)}
	
	-- ** Button handlers 
	activeButton = false

	if isCursorShowing() then
		local relX, relY = getCursorPosition()
		local absX, absY = relX * screenX, relY * screenY

		if panelIsMoving then
			panelPosX = absX - moveX
			panelPosY = absY - moveY
		else
			for k, v in pairs(buttons) do
				if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	else
		panelIsMoving = false
	end
end

-- client side 


addEventHandler("onClientElementDataChange", localPlayer, 
	function (key, oldValue, newValue)
		if key == "afk" and newValue > 1 then 
			addEventHandler("onClientRender", getRootElement(), renderTheAfkPanel)
		elseif key == "afk" and newValue <= 0 then 
			removeEventHandler("onClientRender", getRootElement(), renderTheAfkPanel)
		end
	end 
)

function handlePanelClick(sourceKey, sourceKeyState, absX, absY)
	if sourceKey == "left" and sourceKeyState == "down" then 
		if absX >= panelPosX and absY >= panelPosY and absX <= panelPosX + respc(160) and absY <= panelPosY + respc(115) and ((absX <= panelPosX + respc(24) or absX >= panelPosX + respc(138)) and (absY >= panelPosY + respc(128) or absY <= panelPosY + respc(250)) or absY <= panelPosY + respc(128) or absY >= panelPosY + respc(250)) then
			panelIsMoving = true
			moveX = absX - panelPosX
			moveY = absY - panelPosY 
			return
		end

	elseif sourceKeyState == "up" and panelIsMoving then 
		panelIsMoving = false
	else

		local pedVehicle = getPedOccupiedVehicle(localPlayer)

		if getTickCount() - panelClickedTick <= 520 and activeButton then 
			exports.see_hud:showInfobox("e", "Várj egy kicsit a kapcsolások között.")
		end
		if activeButton == "open" then
			setElementData(pedVehicle, "vehicle.backfireToggled", false) 
			panelClickedTick = getTickCount()
		elseif activeButton == "close" then 
			setElementData(pedVehicle, "vehicle.backfireToggled", true) 
			panelClickedTick = getTickCount()
		end
	end
end

addCommandHandler("backfire", 
	function ()
		if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then 
			local pedVehicle = getPedOccupiedVehicle(localPlayer)

			if not getElementData(pedVehicle, "vehicle.backfire") then 
				--return 
			end

			panelState = not panelState
			panelIsMoving = false 

			if panelState then
				addEventHandler("onClientRender", getRootElement(), renderTheBackfirePanel)
				addEventHandler("onClientClick", getRootElement(), handlePanelClick)
			else
				removeEventHandler("onClientRender", getRootElement(), renderTheBackfirePanel)
				removeEventHandler("onClientClick", getRootElement(), handlePanelClick)
			end
		end
	end 
)