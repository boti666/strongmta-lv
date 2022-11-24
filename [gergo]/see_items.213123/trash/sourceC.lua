local storedTrashes = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 2000, 1, "requestTrashes", localPlayer)
	end)

addEvent("receiveTrashes", true)
addEventHandler("receiveTrashes", getRootElement(),
	function (datas)
		if datas and type(datas) == "table" then
			storedTrashes = datas
		end
	end)

addEvent("createTrash", true)
addEventHandler("createTrash", getRootElement(),
	function (trashId, data)
		if trashId then
			trashId = tonumber(trashId)

			if data and type(data) == "table" then
				storedTrashes[trashId] = data
			end
		end
	end)

addEvent("destroyTrash", true)
addEventHandler("destroyTrash", getRootElement(),
	function (trashId)
		if trashId then
			trashId = tonumber(trashId)

			if storedTrashes[trashId] then
				storedTrashes[trashId] = nil
			end
		end
	end)

addCommandHandler("nearbytrashes",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local x, y, z = getElementPosition(localPlayer)
			local int = getElementInterior(localPlayer)
			local dim = getElementDimension(localPlayer)
			local nearby = 0

			outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben lévő szemetesek:", 255, 255, 255, true)

			for k, v in pairs(storedTrashes) do
				if int == v.interior and dim == v.dimension then
					local dist = getDistanceBetweenPoints3D(x, y, z, v.posX, v.posY, v.posZ)

					if dist <= 15 then
						outputChatBox("#DC143C[SeeMTA]: #FFFFFFAzonosító: #8dc63f" .. v.trashId .. "#FFFFFF <> Távolság: #8dc63f" .. math.floor(dist), 255, 255, 255, true)
						nearby = nearby + 1
					end
				end
			end

			if nearby == 0 then
				outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben nem található egyetlen szemetes sem.", 255, 255, 255, true)
			end
		end
	end)