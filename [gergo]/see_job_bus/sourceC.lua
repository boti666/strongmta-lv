local screenX, screenY = guiGetScreenSize()

local currentPeds = {}
local currentMarker = false
local currentBlip = false

local busPeds = {}
local busPassengers = {}

local lineColor = {50, 179, 239}
local progressBar = false

local animControls = false

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

addEvent("createBusProgressbar", true)
addEventHandler("createBusProgressbar", getRootElement(),
	function (waitingDuration)
		exports.see_hud:showInfobox("i", "Várd meg, amíg felszállnak az utasok!")
		progressBar = {getTickCount(), waitingDuration}

		local newPeds = shallowcopy(currentPeds)
		currentPeds = {}

		setTimer(
			function ()
				if isElement(newPeds[#newPeds]) then
					destroyElement(newPeds[#newPeds])
				end

				newPeds[#newPeds] = nil
			end,
		waitingDuration / (#newPeds + 1), #newPeds)

		if not animControls then
			exports.see_controls:toggleControl({"all"}, false)
			animControls = true
		end
	end
)

addEvent("nextBusStop", true)
addEventHandler("nextBusStop", localPlayer,
	function (lineType, markerId, skins)
		if isElement(currentMarker) then
			destroyElement(currentMarker)
		end

		if isElement(currentBlip) then
			destroyElement(currentBlip)
		end

		currentMarker = nil
		currentBlip = nil

		for i = 1, #currentPeds do
			if isElement(currentPeds[i]) then
				destroyElement(currentPeds[i])
			end
		end

		currentPeds = {}

		if lineType then
			if lineType == "normal" then
				lineColor = {50, 179, 239}
			else
				lineColor = {215, 89, 89}
			end

			local pedPosition = pedPoints[lineType][markerId]

			for i = 1, #skins do
				local pedElement = createPed(skins[i], pedPosition[i][1], pedPosition[i][2], pedPosition[i][3], pedPosition[i][4])

				if isElement(pedElement) then
					setElementFrozen(pedElement, true)
					table.insert(currentPeds, pedElement)
				end
			end

			local nextWaypoint = markerPoints[lineType][markerId]

			if nextWaypoint then
				local currentVeh = getPedOccupiedVehicle(localPlayer)
				local zoneName = getZoneName(nextWaypoint[1], nextWaypoint[2], nextWaypoint[3])

				setTimer(outputChatBox, 500, 1, "[StrongMTA - Buszsofőr]: #ffffffKövetkező megálló: #3d7abc" .. zoneName, lineColor[1], lineColor[2], lineColor[3], true)
				
				currentMarker = createMarker(nextWaypoint[1], nextWaypoint[2], nextWaypoint[3], "checkpoint", 3, lineColor[1], lineColor[2], lineColor[3])
				currentBlip = createBlip(nextWaypoint[1], nextWaypoint[2], nextWaypoint[3], 0, 2, lineColor[1], lineColor[2], lineColor[3])

				setElementData(currentBlip, "blipTooltipText", "Következő megálló (" .. zoneName .. ")")

				if currentVeh then
					setElementData(currentVeh, "gpsDestination", {nextWaypoint[1], nextWaypoint[2], tocolor(unpack(lineColor))})
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "busPassengers" then
			if source == getPedOccupiedVehicle(localPlayer) then
				local dataValue = getElementData(source, dataName)

				if dataValue then
					processPassengers(source, dataValue)
				end
			end
		elseif dataName == "char.Job" or dataName == "jobVehicle" then
			if source == localPlayer then
				local playerJob = getElementData(localPlayer, "char.Job")
				local jobVehicle = getElementData(localPlayer, "jobVehicle")

				if (playerJob ~= 5 and playerJob ~= 6) or not jobVehicle then
					if isElement(currentMarker) then
						destroyElement(currentMarker)
					end

					if isElement(currentBlip) then
						destroyElement(currentBlip)
					end

					currentMarker = nil
					currentBlip = nil

					for i = 1, #currentPeds do
						if isElement(currentPeds[i]) then
							destroyElement(currentPeds[i])
						end
					end

					currentPeds = {}
				end
			end
		end
	end
)

function processPassengers(busElement, passengers)
	if not busPeds[busElement] then
		busPeds[busElement] = {}
	end

	for i = 1, #busPeds[busElement] do
		local pedElement = busPeds[busElement][i]

		if isElement(pedElement) then
			destroyElement(pedElement)
			busPeds[busElement][i] = nil
		end
	end

	busPeds[busElement] = {}

	for k in pairs(passengers) do
		if passengers[k] then
			if pedPositions[k] then
				local pedElement = createPed(passengers[k], 0, 0, 0)

				if isElement(pedElement) then
					setElementCollisionsEnabled(pedElement, false)
					setPedAnimation(pedElement, "ped", "SEAT_idle", -1, true, false, false)
					attachElements(pedElement, busElement, pedPositions[k][1], pedPositions[k][2], pedPositions[k][3])
					
					for i = 1, #busPassengers + 1 do
						if not busPassengers[i] or not isElement(busPassengers[i][1]) then
							busPassengers[i] = {pedElement, busElement, pedPositions[k][4] or 0}
							break
						end
					end

					table.insert(busPeds[busElement], pedElement)
				end
			end
		end
	end

	local velX, velY, velZ = getElementVelocity(busElement)
	setElementVelocity(busElement, velX, velY, velZ + 0.01)
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		for i = 1, #busPassengers do
			local passenger = busPassengers[i]

			if passenger then
				if isElement(passenger[1]) and isElement(passenger[2]) then
					local busRotation = select(3, getElementRotation(passenger[2]))

					setElementRotation(passenger[1], 0, 0, busRotation + passenger[3])
				else
					if isElement(passenger[1]) then
						destroyElement(passenger[1])
					end

					busPassengers[i] = false
				end
			end
		end

		if progressBar then
			local currentTick = getTickCount()
			local progress = (currentTick - progressBar[1]) / progressBar[2]

			if progress > 1 then
				progress = 1
			end

			if currentTick > progressBar[1] + progressBar[2] then
				if animControls then
					exports.see_controls:toggleControl({"all"}, true)
					animControls = false
				end

				progressBar = false
			end

			local sx, sy = 251, 8
			local x = screenX / 2 - sx / 2 - 5
			local y = screenY - 56 - sy - 5

			dxDrawRectangle(x - 2, y - 2, sx + 4, 2, tocolor(0, 0, 0, 200)) -- felső
			dxDrawRectangle(x - 2, y + sy, sx + 4, 2, tocolor(0, 0, 0, 200)) -- alsó
			dxDrawRectangle(x - 2, y, 2, sy, tocolor(0, 0, 0, 200)) -- bal
			dxDrawRectangle(x + sx, y, 2, sy, tocolor(0, 0, 0, 200)) -- jobb

			dxDrawRectangle(x, y, sx, sy, tocolor(50, 50, 50, 200)) -- háttér
			dxDrawRectangle(x, y, sx * progress, sy, tocolor(unpack(lineColor))) -- progress
		end
	end
)