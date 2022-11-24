local screenSize = {guiGetScreenSize()}
screenSize.x, screenSize.y = screenSize[1], screenSize[2]

local bgColor = tocolor(50, 50, 50, 240)
local slotColor = tocolor(40, 40, 40, 200)

local hoverColor = tocolor(59, 122, 188, 180)
local hoverColor2 = tocolor(59, 122, 188, 255)
local cancelColor = tocolor(252, 63, 63, 180)

local markers = {
	{1082.3842773438, 1349.5979003906, 10.8203125, 0}
}
local createdMarkers = {}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for key, value in ipairs(markers) do
			createdMarkers[key] = createMarker(value[1], value[2], value[3] - 1, "cylinder", 3, 0, 174, 235, 150)
			setElementData(createdMarkers[key], "points->FixMarker", true)
		end
	end
)

setTimer(
	function()
		local markerDelete = false
		
		for k, v in pairs(getElementsByType("player")) do
			if exports.see_groups:isPlayerInGroup(v, 15) then
				if getElementData(v, "inDuty") then
					markerDelete = true
					break
				end
			end
		end

		
		if markerDelete then
			for k, v in pairs(createdMarkers) do
				if isElement(v) then
					destroyElement(v)
				end
			end
		else
			for k, v in pairs(createdMarkers) do
				if isElement(v) then
					destroyElement(v)
				end
			end
			for key, value in ipairs(markers) do
				createdMarkers[key] = createMarker(value[1], value[2], value[3] - 1, "cylinder", 3, 0, 59, 122, 188)
				setElementData(createdMarkers[key], "points->FixMarker", true)
			end
		end
	end, 15000, 0
)

function isCursorHover(startX, startY, sizeX, sizeY)
	if isCursorShowing() then
		local cursorPosition = {getCursorPosition()}
		cursorPosition.x, cursorPosition.y = cursorPosition[1] * screenSize.x, cursorPosition[2] * screenSize.y

		if cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY then
			return true
		else
			return false
		end
	else
		return false
	end
end

local roboto = dxCreateFont("files/Roboto.ttf", 9)

local panelStates = false

addEventHandler("onClientMarkerHit", root, function(player)
		if player == localPlayer and getElementData(source, "points->FixMarker") then
			vehicle = getPedOccupiedVehicle(localPlayer)

			if vehicle and getPedOccupiedVehicleSeat(localPlayer) == 0 then
				if getElementHealth(vehicle) >= 990 then
					outputChatBox("#3b7abc[StrongMTA - Szerelő]#ffffff: A járműved nem sérült.", 0, 0, 0, true)
				else
					panelStates = true
					fixMoney = 30000
				end
			end
		end
	end)

addEventHandler("onClientMarkerLeave", root, function(player)
	if player == localPlayer and getElementData(source, "points->FixMarker") then
		if panelStates then
			panelStates = false
		end
	end
end)

addEventHandler("onClientRender", root, function()
	if panelStates then
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 - 50, 400, 100, bgColor)
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 + 50, 400, 2, hoverColor2) -- Alsó csík
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 - 50, 400, 2, hoverColor2) -- Felső csík
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 - 50, 2, 100, hoverColor2) -- Bal oldali csík
		dxDrawRectangle(screenSize.x/2 + 200, screenSize.y/2 - 50, 2, 102, hoverColor2) -- Bal oldali csík

		dxDrawText("Szeretnéd megjavítani a járművedet?\nJavítás ára #3b7abc" .. convertNumber(fixMoney).." $", screenSize.x/2 - 200, screenSize.y/2 - 45, screenSize.x/2 + 200, 0, tocolor(255, 255, 255), 1, roboto, "center", "top", false, false, false, true)
	
		dxDrawRectangle(screenSize.x/2 - 170, screenSize.y/2, 150, 30, slotColor)
		dxDrawText("Javítás", screenSize.x/2 - 170, screenSize.y/2, screenSize.x/2 - 20, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
	
		if isCursorHover(screenSize.x/2 - 170, screenSize.y/2, 150, 30) then
			dxDrawRectangle(screenSize.x/2 - 170, screenSize.y/2, 150, 30, hoverColor)
			dxDrawText("Javítás", screenSize.x/2 - 170, screenSize.y/2, screenSize.x/2 - 20, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
		end

		dxDrawRectangle(screenSize.x/2 + 20, screenSize.y/2, 150, 30, slotColor)
		dxDrawText("Kilépés", screenSize.x/2 + 20, screenSize.y/2, screenSize.x/2 + 170, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
	
		if isCursorHover(screenSize.x/2 + 20, screenSize.y/2, 150, 30) then
			dxDrawRectangle(screenSize.x/2 + 20, screenSize.y/2, 150, 30, cancelColor)
			dxDrawText("Kilépés", screenSize.x/2 + 20, screenSize.y/2, screenSize.x/2 + 170, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
		end
	elseif repairState then
		if getTickCount() >= startTick then
			local delayTime = getTickCount() - startTick
			if delayTime < 8000 then
				progTime = delayTime / 8000
				panelX = interpolateBetween(0, 0, 0, 250, 0, 0, progTime, "Linear")

				dxDrawRectangle(screenSize.x/2 - 250/2 - 2, screenSize.y/2 - 10, 254, 20, bgColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, 250, 16, slotColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, panelX, 16, hoverColor)

				dxDrawText("Szerelés folyamatban...", 0, 0, screenSize.x, screenSize.y, tocolor(255, 255, 255), 1, roboto, "center", "center")
				setElementFrozen(localPlayer, true)
				setElementFrozen(vehicle, true)
			else
				setElementFrozen(localPlayer, false)
				setElementFrozen(vehicle, false)
				repairState = false

				triggerServerEvent("fixVehicle", localPlayer, fixMoney)
				--setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money") - fixMoney)
				outputChatBox("#3b7abc[StrongMTA - Szerelő]#ffffff: Sikeresen megjavíttattad a járműved #bc873d"..convertNumber(fixMoney).." $#ffffff-ért.", 0, 0, 0, true)

				triggerServerEvent("points->FixVehicle", localPlayer, vehicle)

				toggleAllControls(true)
			end
		end
	end
end)

function convertNumber(number)  
local formatted = number;
while true do      
	formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2'); 
	if (k==0) then      
		break;
	end  
end  
return formatted;
end

addEventHandler("onClientClick", root, function(key, state)
	if key == "left" and state == "down" and panelStates then
		if isCursorHover(screenSize.x/2 - 170, screenSize.y/2, 150, 30) then
			if getElementData(localPlayer, "char.Money") >= fixMoney then
				panelStates = false

				repairState = true
				startTick = getTickCount()

				toggleAllControls(false)
			else
				outputChatBox("#3b7abc[StrongMTA - Szerelő]#ffffff: Nincs elég pénzed a jármű javításához. #bc873d($"..fixMoney..")", 0, 0, 0, true)
			end
		elseif isCursorHover(screenSize.x/2 + 20, screenSize.y/2, 150, 30) then
			panelStates = false
		end
	end
end)