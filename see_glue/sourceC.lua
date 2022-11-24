local glued = false
local allowed = {
	[470] = true,
	[548] = true,
	[508] = true,
	[577] = true,
	[406] = true,
	[478] = true,
	[506] = true,
	[602] = true,
	[563] = true,
	[427] = true,
	[513] = true,
	[520] = true,
}

addCommandHandler("glue",
	function ()
		if glued then
			triggerServerEvent("unGluePlayer", localPlayer)
			glued = false
		else
			if not getPlayerOccupiedVehicle(localPlayer) then
				local vehicle = getPedContactElement(localPlayer)

				if getElementType(vehicle) == "vehicle" then
					local model = getElementModel(vehicle)

					if getVehicleType(vehicle) == "Boat" or allowed[model] then
						outputDebugString("glue")

						local px, py, pz = getElementPosition(localPlayer)
						local vx, vy, vz = getElementPosition(vehicle)
						local sx = px - vx
						local sy = py - vy
						local sz = pz - vz
						
						local rotpX, rotpY, rotpZ = getElementRotation(localPlayer)
						local rotvX, rotvY, rotvZ = getElementRotation(vehicle)
						
						local t = math.rad(rotvX)
						local p = math.rad(rotvY)
						local f = math.rad(rotvZ)
						
						local ct = math.cos(t)
						local st = math.sin(t)
						local cp = math.cos(p)
						local sp = math.sin(p)
						local cf = math.cos(f)
						local sf = math.sin(f)
						
						local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
						local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
						local y = st*sz - sf*ct*sx + cf*ct*sy
						
						local rotX = rotpX - rotvX
						local rotY = rotpY - rotvY
						local rotZ = rotpZ - rotvZ
						
						local slot = getPedWeaponSlot(localPlayer)

						triggerServerEvent("gluePlayer", localPlayer, slot, vehicle, x, y, z, rotX, rotY, rotZ)

						glued = true
					end
				end
			end
		end
	end)

addEventHandler("onClientPlayerWasted", localPlayer,
	function ()
		if glued then
			triggerServerEvent("unGluePlayer", localPlayer)
			glued = false
		end
	end)

local playerGlueState = {}
local playerGlueRotation = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local players = getElementsByType("player")

		for i = 1, #players do
			local player = players[i]

			playerGlueState[player] = getElementData(player, "playerGlueState")
			playerGlueRotation[player] = getElementData(player, "playerGlueRotation")
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "playerGlueState" then
			playerGlueState[source] = getElementData(source, "playerGlueState")
			playerGlueRotation[source] = getElementData(source, "playerGlueRotation")
		end

		if source == localPlayer then
			if dataName == "cuffed" or dataName == "tazed" then
				if glued then
					triggerServerEvent("unGluePlayer", localPlayer)
					glued = false
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		for k, v in pairs(playerGlueState) do
			if isElement(k) and isElement(v) then
				local rx, ry, rz = getElementRotation(v)

				setElementRotation(k, 0, 0, rz + playerGlueRotation[k])
			else
				playerGlueState[k] = nil
				playerGlueRotation[k] = nil
			end
		end
	end)