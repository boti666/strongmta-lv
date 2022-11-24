worldItems = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 3000, 1, "requestWorldItems", localPlayer)
	end)

addEvent("receiveWorldItems", true)
addEventHandler("receiveWorldItems", getRootElement(),
	function (datas)
		if datas and type(datas) == "table" then
			worldItems = datas

			for k, v in pairs(worldItems) do
				if isElement(v.objectElement) then
					setElementData(v.objectElement, "worldItem", v.dbID, false)
				end
			end
		end
	end)

addEvent("addWorldItem", true)
addEventHandler("addWorldItem", getRootElement(),
	function (itemId, data)
		if itemId then
			itemId = tonumber(itemId)

			if data and type(data) == "table" then
				worldItems[itemId] = data

				if isElement(worldItems[itemId].objectElement) then
					setElementData(worldItems[itemId].objectElement, "worldItem", itemId, false)
				end
			end
		end
	end)

addEvent("destroyWorldItem", true)
addEventHandler("destroyWorldItem", getRootElement(),
	function (itemId)
		if itemId then
			itemId = tonumber(itemId)

			if worldItems[itemId] then
				worldItems[itemId] = nil
			end
		end
	end)

addCommandHandler("nearbyitems",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local x, y, z = getElementPosition(localPlayer)
			local int = getElementInterior(localPlayer)
			local dim = getElementDimension(localPlayer)
			local nearby = 0

			outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben lévő tárgyak:", 255, 255, 255, true)

			for k, v in pairs(worldItems) do
				if int == v.interior and dim == v.dimension then
					local dist = getDistanceBetweenPoints3D(x, y, z, v.posX, v.posY, v.posZ)

					if dist <= 15 then
						outputChatBox("#DC143C[SeeMTA]: #FFFFFFAzonosító: #8dc63f" .. v.dbID .. "#FFFFFF <> Távolság: #8dc63f" .. math.floor(dist) .. "#FFFFFF <> Típus: #8dc63f" .. getItemName(v.itemId), 255, 255, 255, true)
						nearby = nearby + 1
					end
				end
			end

			if nearby == 0 then
				outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben nem található egyetlen tárgy sem.", 255, 255, 255, true)
			end
		end
	end)