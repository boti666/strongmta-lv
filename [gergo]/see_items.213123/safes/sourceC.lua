local storedSafes = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 4000, 1, "requestSafes", localPlayer)
	end)

addEvent("receiveSafes", true)
addEventHandler("receiveSafes", getRootElement(),
	function (datas)
		if datas and type(datas) == "table" then
			storedSafes = datas
		end
	end)

addCommandHandler("createsafe",
	function (commandName, ownerGroup)
		if getElementData(localPlayer, "acc.adminLevel") >= 7 then
			ownerGroup = tonumber(ownerGroup)

			if not ownerGroup then
				outputChatBox("#ea7212[Használat]: #FFFFFF/" .. commandName .. " [Csoport Azonosító < 0 ha nincs >]", 255, 255, 255, true)
			else
				local x, y, z = getElementPosition(localPlayer)
				local rx, ry, rz = getElementRotation(localPlayer)
				local int = getElementInterior(localPlayer)
				local dim = getElementDimension(localPlayer)

				triggerServerEvent("createSafe", localPlayer, ownerGroup, x, y, z - 0.55, rz, int, dim)
			end
		end
	end)

addEvent("createSafe", true)
addEventHandler("createSafe", getRootElement(),
	function (safeId, data)
		if safeId then
			safeId = tonumber(safeId)

			if data and type(data) == "table" then
				storedSafes[safeId] = data
			end
		end
	end)

addCommandHandler("deletesafe",
	function (commandName, safeId)
		if getElementData(localPlayer, "acc.adminLevel") >= 7 then
			safeId = tonumber(safeId)

			if not safeId then
				outputChatBox("#ea7212[Használat]: #FFFFFF/" .. commandName .. " [Azonosító]", 255, 255, 255, true)
			else
				if storedSafes[safeId] then
					triggerServerEvent("destroySafe", localPlayer, safeId)
				else
					outputChatBox("#DC143C[SeeMTA]: #FFFFFFA kiválasztott széf nem található.", 255, 255, 255, true)
				end
			end
		end
	end)

addEvent("destroySafe", true)
addEventHandler("destroySafe", getRootElement(),
	function (safeId)
		if safeId then
			safeId = tonumber(safeId)

			if storedSafes[safeId] then
				storedSafes[safeId] = nil
			end
		end
	end)

addEvent("updateSafe", true)
addEventHandler("updateSafe", getRootElement(),
	function (safeId, data)
		if safeId and data then
			safeId = tonumber(safeId)

			if storedSafes[safeId] then
				storedSafes[safeId] = data
			end
		end
	end)

addCommandHandler("nearbysafes",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local x, y, z = getElementPosition(localPlayer)
			local int = getElementInterior(localPlayer)
			local dim = getElementDimension(localPlayer)
			local nearby = 0

			outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben lévő széfek:", 255, 255, 255, true)

			for k, v in pairs(storedSafes) do
				if int == v.interior and dim == v.dimension then
					local dist = getDistanceBetweenPoints3D(x, y, z, v.posX, v.posY, v.posZ)

					if dist <= 15 then
						outputChatBox("#DC143C[SeeMTA]: #FFFFFFAzonosító: #8dc63f" .. v.dbID .. "#FFFFFF <> Csoport Azonosító: #8dc63f" .. v.ownerGroup .. "#FFFFFF <> Távolság: #8dc63f" .. math.floor(dist), 255, 255, 255, true)
						nearby = nearby + 1
					end
				end
			end

			if nearby == 0 then
				outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben nem található egyetlen széf sem.", 255, 255, 255, true)
			end
		end
	end)