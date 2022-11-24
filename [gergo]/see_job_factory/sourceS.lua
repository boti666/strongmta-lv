local baseX, baseY = 1491.7578125, 2345.3388671875

for y = 0, 1 do
	for x = 0, 5 do
		local offx, offy = rotateAround(90, y * -4, x * -4)
		local obj = createObject(937, baseX + offx, baseY + offy, -2.9797873497009)
		setElementDoubleSided(obj, true)

		if x ~= 2 and x ~= 5 then
			offx, offy = rotateAround(90, 0.15 + y * -4, -1.5 + x * -4)
			createObject(math.random(3386, 3389), baseX + offx, baseY + offy, -4.0045, 0, 0, 90)
		end
	end
end

local itemPositions = {
	[334] = 1,
	[335] = 1,
	[336] = 1,
	[337] = 2,
	[338] = 2,
	[339] = 2
}

addEvent("pickupFactoryMaterial", true)
addEventHandler("pickupFactoryMaterial", getRootElement(),
	function (materialId)
		if isElement(source) and client and client == source then 
			if materialId then
				local itemId = itemIds[materialId]

				if itemId then
					if exports.see_items:hasSpaceForItem(source, materialId) then
						exports.see_items:giveItem(source, itemId, 1, false)
						exports.see_hud:showInfobox(source, "s", "Sikeresen elvettél egy " .. itemNames[itemId] .. "-t.")
						setPedAnimation(source, "misc", "case_pickup", 1200, false, false, true, false)
					else
						exports.see_hud:showInfobox(source, "e", "Nem fér el nálad a tárgy!")
					end
				end
			end
		end
	end)

addEvent(">ĐĐĐ|}Äí{ÍÄ<đ", true)
addEventHandler(">ĐĐĐ|}Äí{ÍÄ<đ", getRootElement(),
	function (leftColshape)
		if isElement(source) and client and client == source then
			local factoryJob = getElementData(source, "factoryJob")

			if factoryJob then
				local itemId = factoryJob[2]
				local takenNum = 0

				if (leftColshape and itemPositions[itemId] == 1) or (not leftColshape and itemPositions[itemId] == 2) then
					local items = exports.see_items:getElementItems(source) or {}

					for k, v in pairs(items) do
						if v.itemId == itemId then
							exports.see_items:takeItem(source, "dbID", v.dbID)
							takenNum = takenNum + 1
						end
					end
				end

				if takenNum > 0 then
					local remainNum = factoryJob[1] - takenNum

					outputChatBox("#3d7abc[StrongMTA - Munka]: #ffffffLeadtál #3d7abc" .. takenNum .. " #ffffffdarab #3d7abc" .. exports.see_items:getItemName(itemId) .. "#ffffff-t.", source, 255, 255, 255, true)
					
					if remainNum > 0 then
						outputChatBox("#3d7abc[StrongMTA - Munka]: #ffffffA következő tárgyakat kell még összeszerelned:", source, 255, 255, 255, true)
						outputChatBox("   - #3d7abc" .. remainNum .. "#ffffff darab #3d7abc" .. exports.see_items:getItemName(itemId), source, 255, 255, 255, true)
						factoryJob = {remainNum, factoryJob[2], factoryJob[3]}
					else
						outputChatBox("#3d7abc[StrongMTA - Munka]: #ffffffA munkád elvégezted, fizetséged #3d7abc" .. factoryJob[3] * 20000 .. "$#ffffff.", source, 255, 255, 255, true)
						exports.see_core:giveMoney(source, factoryJob[3] * 20000, "factoryJob")
						factoryJob = false
					end

					setElementData(source, "factoryJob", factoryJob)
					setPedAnimation(source, "misc", "case_pickup", 1200, false, false, true, false)

					local doneItems = getElementData(resourceRoot, "doneItems:" .. itemId) or 0
					setElementData(resourceRoot, "doneItems:" .. itemId, doneItems + takenNum)
				end
			end
		end
	end)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		local doneItems = {}

		for k in pairs(itemPositions) do
			table.insert(doneItems, k .. ";" .. (getElementData(resourceRoot, "doneItems:" .. k) or 0))
		end

		if fileExists("doneItems.csv") then
			fileDelete("doneItems.csv")
		end

		local fileHandle = fileCreate("doneItems.csv")

		if fileHandle then
			fileWrite(fileHandle, table.concat(doneItems, ";"))
			fileClose(fileHandle)
		end
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		if fileExists("doneItems.csv") then
			local fileHandle = fileOpen("doneItems.csv")

			if fileHandle then
				local buffer = fileRead(fileHandle, fileGetSize(fileHandle))
				fileClose(fileHandle)

				local content = split(buffer, ";")
				for i = 1, #content, 2 do
					setElementData(resourceRoot, "doneItems:" .. content[i], tonumber(content[i+1]))
				end
			end
		end
	end)