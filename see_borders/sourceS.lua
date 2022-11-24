local longVehicles = {
	[409] = true,
	[431] = true,
	[437] = true,
	[408] = 1500,
	[407] = true,
	[544] = true,
	[578] = true,
	[443] = true,
	[515] = 5000,
	[514] = 5000,
	[508] = 1000
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		for i = 1, #availableBorders do
			setElementData(resourceRoot, "border." .. i .. ".mode", 1)
			setElementData(resourceRoot, "border." .. i .. ".state", false)
		end
	end)

addEvent("openTheBorder", true)
addEventHandler("openTheBorder", getRootElement(),
	function (borderId, colShapeId, vehicle)
		if borderId and colShapeId and vehicle then 
			if isElement(source) and client and client == source then 
				--iprint({borderId, colShapeId, vehicle})
				--source == client
				if exports.see_core:takeMoneyEx(source, 25, "borderCross") then
					setElementData(vehicle, "borderTargetColShapeId", colShapeId)
					setElementData(resourceRoot, "border." .. borderId .. ".state", true)
				else
					exports.see_hud:showInfobox(source, "e", "Nincs elég pénzed a határ átlépéséhez!")
				end
			end
		end
	end)

addEvent("closeTheBorder", true)
addEventHandler("closeTheBorder", getRootElement(),
	function (borderId, colShapeId, vehicle)
		if isElement(source) and client and client == source then 
			if borderId and colShapeId and vehicle then
				local model = getElementModel(vehicle)

				removeElementData(vehicle, "borderTargetColShapeId")

				if longVehicles[model] then
					setTimer(setElementData, tonumber(longVehicles[model]) or 2000, 1, resourceRoot, "border." .. borderId .. ".state", false)
				else
					setElementData(resourceRoot, "border." .. borderId .. ".state", false)
				end

				triggerClientEvent(getElementsByType("player"), "warnAboutBorderCross", source, vehicle)
			end
		end
	end)

addEvent("warnAboutBorderSet", true)
addEventHandler("warnAboutBorderSet", getRootElement(),
	function (playerName, borderId, set)
		if isElement(source) and client and client == source then
			if playerName and borderId and set then
				triggerClientEvent(getElementsByType("player"), "warnAboutBorderSet", source, playerName, borderId, set)
			end
		end
	end)