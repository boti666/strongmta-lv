local customHorn = false
local currentVehicle = false
local hornInUse = false
local hornKeys = {}
local lastHornState = false
local lastPressTick = 0
local hornSounds = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if pedveh then
			if getVehicleController(pedveh) == localPlayer then
				local hornId = getElementData(pedveh, "customHorn") or 0

				if hornId >= 1 then
					exports.see_controls:toggleControl({"horn"}, false)

					customHorn = true
					addEventHandler("onClientRender", getRootElement(), renderHorn)

					currentVehicle = pedveh
					hornInUse = false
					hornKeys = {}

					for k in pairs(getBoundKeys("horn")) do
						table.insert(hornKeys, k)
					end
				end
			end
		end
	end)

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (enterPlayer, seat)
		if enterPlayer == localPlayer then
			if seat == 0 then
				local hornId = getElementData(source, "customHorn") or 0

				if hornId >= 1 then
					exports.see_controls:toggleControl({"horn"}, false)

					customHorn = true
					addEventHandler("onClientRender", getRootElement(), renderHorn)

					currentVehicle = source
					hornInUse = false
					hornKeys = {}

					for k in pairs(getBoundKeys("horn")) do
						table.insert(hornKeys, k)
					end
				end
			end
		end
	end)

addEventHandler("onClientVehicleExit", getRootElement(),
	function (exitPlayer)
		if customHorn and exitPlayer == localPlayer then
			customHorn = false
			exports.see_controls:toggleControl({"horn"}, true)
			removeEventHandler("onClientRender", getRootElement(), renderHorn)
			setElementData(currentVehicle, "hornState", false)
		end
	end)

function renderHorn()
	if not isPedInVehicle(localPlayer) and customHorn then
		customHorn = false
		exports.see_controls:toggleControl({"horn"}, true)
		removeEventHandler("onClientRender", getRootElement(), renderHorn)
		setElementData(currentVehicle, "hornState", false)
	end

	local keyState = false

	if not isCursorShowing() and not isChatBoxInputActive() and not isConsoleActive() then
		for i = 1, #hornKeys do
			if getKeyState(hornKeys[i]) then
				keyState = true
				break
			end
		end
	end

	if lastHornState ~= keyState then
		lastHornState = keyState

		if lastHornState and getTickCount() - lastPressTick <= 100 then
			return
		end

		lastPressTick = getTickCount()
		setElementData(currentVehicle, "hornState", lastHornState)
	end
end

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if hornSounds[source] then
			if isElement(hornSounds[source]) then
				destroyElement(hornSounds[source])
			end

			hornSounds[source] = nil
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "customHorn" then
			if source == getPedOccupiedVehicle(localPlayer) then
				if getPedOccupiedVehicleSeat(localPlayer) == 0 then
					local hornId = getElementData(source, "customHorn") or 0

					currentVehicle = source

					if customHorn then
						customHorn = false
						exports.see_controls:toggleControl({"horn"}, true)
						removeEventHandler("onClientRender", getRootElement(), renderHorn)
						setElementData(source, "hornState", false)
					end

					if hornId >= 1 then
						exports.see_controls:toggleControl({"horn"}, false)
						customHorn = true
						addEventHandler("onClientRender", getRootElement(), renderHorn)

						hornInUse = false
						hornKeys = {}

						for k in pairs(getBoundKeys("horn")) do
							table.insert(hornKeys, k)
						end
					end
				end
			end
		end

		if dataName == "hornState" then
			if getElementData(source, dataName) then
				if isElementStreamedIn(source) then
					local hornId = getElementData(source, "customHorn") or 0

					if hornId >= 1 then
						hornSounds[source] = playSound3D("horns/" .. hornId .. ".mp3", 0, 0, 0, true)

						attachElements(hornSounds[source], source)
						setSoundMaxDistance(hornSounds[source], 50)

						local model = getElementModel(source)

						if model == 472 or model == 595 or model == 484 or model == 430 or model == 453 or model == 454 then
							setSoundMaxDistance(hornSounds[source], 150)
						end
					end
				end
			else
				if hornSounds[source] then
					if isElement(hornSounds[source]) then
						destroyElement(hornSounds[source])
					end

					hornSounds[source] = nil
				end
			end
		end
	end)
