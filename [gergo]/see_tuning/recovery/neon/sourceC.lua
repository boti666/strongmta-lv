local availableNeons = {
	[14399] = "red",
	[14400] = "blue",
	[14401] = "green",
	[14402] = "yellow",
	[14403] = "pink",
	[14404] = "white",
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableNeons) do
			local dff = engineLoadDFF("files/neon/" .. v .. ".dff")
			local col = engineLoadCOL("files/neon/neon.col")

			if dff and col then
				engineReplaceCOL(col, k)
				engineReplaceModel(dff, k)
			end
		end
	end)

local lastTogNeon = 0

addCommandHandler("toggle-neon",
	function ()
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if pedveh and getVehicleController(pedveh) == localPlayer then
			if getElementData(pedveh, "tuning.neon") ~= 0 then
				if lastTogNeon + 2000 <= getTickCount() then
					if getElementData(pedveh, "tuning.neon.state") then
						if getElementData(pedveh, "tuning.neon.state") == 0 then
							setElementData(pedveh, "tuning.neon.state", 1)
						elseif getElementData(pedveh, "tuning.neon.state") == 1 then
							setElementData(pedveh, "tuning.neon.state", 0)
						end
					end

					lastTogNeon = getTickCount()
				end
			end
		end
	end)
bindKey("U", "down", "toggle-neon")

local neonObjects = {}

function changeNeonState(vehicle, state)
	if isElement(vehicle) then
		if neonObjects[vehicle] then
			if isElement(neonObjects[vehicle][1]) then
				destroyElement(neonObjects[vehicle][1])
			end

			if isElement(neonObjects[vehicle][2]) then
				destroyElement(neonObjects[vehicle][2])
			end

			neonObjects[vehicle] = nil
		end

		local currentState = getElementData(vehicle, "tuning.neon.state")
		local neonModel = getElementData(vehicle, "tuning.neon")

		if currentState == 1 and neonModel > 0 then
			local x, y, z = getElementPosition(vehicle)
			local rx, ry, rz = getElementRotation(vehicle)

			local obj1 = createObject(neonModel, x, y, z)
			local obj2 = createObject(neonModel, x, y, z)

			if isElement(obj1) and isElement(obj2) then
				setObjectScale(obj1, 0)
				setObjectScale(obj2, 0)
				
				setElementRotation(obj1, rx, ry, rz)
				setElementRotation(obj2, rx, ry, rz)
				
				attachElements(obj1, vehicle, 0.8, 0, -0.55)
				attachElements(obj2, vehicle, -0.8, 0, -0.55)
				
				neonObjects[vehicle] = {obj1, obj2}
			end
		end
	end
end

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			if neonObjects[source] then
				if isElement(neonObjects[source][1]) then
					destroyElement(neonObjects[source][1])
				end

				if isElement(neonObjects[source][2]) then
					destroyElement(neonObjects[source][2])
				end
				
				neonObjects[source] = nil
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "loggedIn" then
			if source == localPlayer then
				if getElementData(source, "loggedIn") then
					for k, v in ipairs(getElementsByType("vehicle")) do
						if (getElementData(v, "tuning.neon") or 0) ~= 0 then
							if (getElementData(v, "tuning.neon.state") or 0) == 1 then
								changeNeonState(v)
							end
						end
					end
				end
			end
		elseif dataName == "tuning.neon.state" or dataName == "tuning.neon" then
			if getElementType(source) == "vehicle" then
				local state = getElementData(source, "tuning.neon.state")

				if state then
					changeNeonState(source, state)
				end
			end
		end
	end)