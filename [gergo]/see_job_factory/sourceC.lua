local screenX, screenY = guiGetScreenSize()

local standingItems = {}
local materialItems = {}
local shelfColShape = {}
local itemPictures = {}
local finalItems = {334, 335, 336, 337, 338, 339}

local factoryBlip = false
local warehouseColShape = createColCuboid(1409.4985351563, 2347.7998046875, -6, 28.985961914, 26.4201660156, 7)
local factoryColShape = createColCuboid(1485.35, 2330.35, -3.4545001983643, 35.75, 27.15, 11.75)
local dropDownCol = createColCuboid(1497.6567382813, 2355.5668945313, -3.4545001983643, 1.75, 1, 2)
local dropDownCol2 = createColCuboid(1509.6768798828, 2355.5668945313, -3.4545001983643, 1.75, 1, 2)

local vortyPed = createPed(261, 1484.4613037109, 2343.5, 3.8970623016357, 270)
setElementFrozen(vortyPed, true)
setElementData(vortyPed, "invulnerable", true)
setPedAnimation(vortyPed, "COP_AMBIENT", "Coplook_think", -1, true, false, false)

local jessePed = createPed(162, 1484.4613037109, 2342.75, 3.8970623016357, 270)
setElementFrozen(jessePed, true)
setElementData(jessePed, "invulnerable", true)
setPedAnimation(jessePed, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)

local supervisorPed = createPed(147, 1488.724609375, 1305.3388671875, 1093.2963867188, 270)
setElementInterior(supervisorPed, 3)
setElementDimension(supervisorPed, 17)
setElementFrozen(supervisorPed, true)
setElementData(supervisorPed, "invulnerable", true)
setElementData(supervisorPed, "visibleName", "Műszakvezető")
setElementData(supervisorPed, "pedNameType", "Munka")
setPedAnimation(supervisorPed, "COP_AMBIENT", "Coplook_think", -1, true, false, false)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, _, _, _, _, _, hitElement)
		if state == "up" then
			if hitElement == supervisorPed then
				if getElementData(localPlayer, "char.Job") == 1 then
					local factoryJob = getElementData(localPlayer, "factoryJob")

					if factoryJob then
						outputChatBox("#3d7abc[StrongMTA - Munka]: #ffffffMár dolgozol. A következő tárgyakat kell még összeszerelned:", 255, 255, 255, true)
						outputChatBox("   - #3d7abc" .. factoryJob[1] .. "#ffffff darab #3d7abc" .. exports.see_items:getItemName(factoryJob[2]), 255, 255, 255, true)
						outputChatBox("#3d7abc[StrongMTA - Munka]: #ffffffA tárgy elkészítéséhez használd az inventory 'Barkácsolás' fülét.", 255, 255, 255, true)
					else
						local num = math.random(5, 15)
						local item = finalItems[math.random(#finalItems)]

						outputChatBox("#3d7abc[StrongMTA - Munka]: #ffffffElkezdtél dolgozni. A következő tárgyakat kell összeszerelned:", 255, 255, 255, true)
						outputChatBox("   - #3d7abc" .. num .. "#ffffff darab #3d7abc" .. exports.see_items:getItemName(item), 255, 255, 255, true)
						outputChatBox("#3d7abc[StrongMTA - Munka]: #ffffffA tárgy elkészítéséhez használd az inventory 'Barkácsolás' fülét.", 255, 255, 255, true)
						
						setElementData(localPlayer, "factoryJob", {num, item, num})
					end
				end
			end
		end
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		--setElementData(localPlayer, "factoryJob", false)

		if getElementData(localPlayer, "char.Job") == 1 then
			factoryBlip = createBlip(1477.5703125, 2353.498828125, 36.329479217529, 0, 2, 61, 122, 188)
			setElementData(factoryBlip, "blipTooltipText", "Elektronikai gyár")
		end

		for i = 1, #shelfPositions do
			local v = shelfPositions[i]

			if i > 2 then
				createObject(2567, v[1], v[2], v[3], 0, 0, v[4])
			else
				createObject(2567, v[1], v[2], v[3], 0, 0, v[4] + 180)
			end
			
			for j = -1, 1, 2 do
				local align = i > 2 and 1 or -1
				local materialId = 0
				local materialId2 = 0

				-- 3d label+itemkép
				local shelfX, shelfY = rotateAround(v[4], -1, 1.2 * j, v[1], v[2])
				table.insert(standingItems, {shelfX, shelfY, v[3] - 0.25})
				materialId = #standingItems
				
				local shelfX, shelfY = rotateAround(v[4], 1, 1.2 * j, v[1], v[2])
				table.insert(standingItems, {shelfX, shelfY, v[3] - 0.25})
				materialId2 = #standingItems
			
				-- colshape
				local offset = 0
				if j < 0 then
					offset = -2
				end

				local colShapeX, colShapeY = rotateAround(v[4], 2.5, 1 * j + offset, v[1], v[2])
				shelfColShape[createColCuboid(colShapeX, colShapeY, v[3] - 2, 2, 5, 4)] = {materialId, materialId2}
			
				-- material lines
				local rotatedX, rotatedY = rotateAround(v[4], 2.36 * align, 0.5 * j)

				if itemIds[materialId] then
					table.insert(materialItems, {v[1] + rotatedX, v[2] + rotatedY, v[3] + 0.5 + 0.15, itemIds[materialId], align})
				end
				
				if itemIds[materialId2] then
					table.insert(materialItems, {v[1] + rotatedX, v[2] + rotatedY, v[3] + 0.5 - 0.15, itemIds[materialId2], align})
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "char.Job" then
			if isElement(factoryBlip) then
				destroyElement(factoryBlip)
			end
			factoryBlip = nil

			if getElementData(localPlayer, "char.Job") == 1 then
				factoryBlip = createBlip(1477.5703125, 2353.498828125, 36.329479217529, 0, 2, 61, 122, 188)
				setElementData(factoryBlip, "blipTooltipText", "Elektronikai gyár")
			end
		end
	end)

local loadingBaysRT = false
local loadingBays = {
	{1497.6567382813, 2355.5668945313, 1.75, 1, tocolor(255, 255, 255), -3.4545001983643 + 0.025},
	{1509.6768798828, 2355.5668945313, 1.75, 1, tocolor(255, 255, 255), -3.4545001983643 + 0.025}
}

for y = 0, 1 do
	for x = 0, 5 do
		local x, y = rotateAround(90, -1.5 + y * -4, 0.85 + x * -4, 1491.7578125, 2345.3388671875)
		
		table.insert(loadingBays, {x, y, 1.75, 1, tocolor(215, 89, 89), -3.4545001983643 + 0.025})
	end
end

local clockRT = false
local refreshClockTimer = false

local quantityRT = false
local quantityRT2 = false

addEventHandler("onClientElementDataChange", resourceRoot,
	function (dataName)
		if utf8.find(dataName, "doneItems") then
			updateQuantity()
		end
	end)

local shelfItems = false
local Roboto = false

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (hitElement, matchingDimension)
		if hitElement == localPlayer and matchingDimension then
			if source == factoryColShape then
				loadingBaysRT = dxCreateRenderTarget(84, 48, true)
				clockRT = dxCreateRenderTarget(180, 90)
				quantityRT = dxCreateRenderTarget(250, 90, true)
				quantityRT2 = dxCreateRenderTarget(250, 90, true)

				addEventHandler("onClientRender", getRootElement(), renderInsideFactory)

				refreshClockTimer = setTimer(refreshClockRT, 10000, 0)

				createLoadingBays()
			end

			if not shelfItems then
				if source == warehouseColShape then
					for k, v in pairs(itemIds) do
						itemPictures[v] = dxCreateTexture(":see_items/files/items/" .. v - 1 .. ".png")
					end

					addEventHandler("onClientRender", getRootElement(), render3DItem)
				end

				if shelfColShape[source] then
					if getElementData(localPlayer, "char.Job") == 1 then
						if isElement(Roboto) then
							destroyElement(Roboto)
						end

						Roboto = dxCreateFont("files/Roboto.ttf", 10, false, "antialiased")
						shelfItems = shelfColShape[source]

						addEventHandler("onClientRender", getRootElement(), standingItemsRender)
						addEventHandler("onClientClick", getRootElement(), standingItemsClick)
					end
				end
			end

			if source == dropDownCol or source == dropDownCol2 then
				if getElementData(localPlayer, "char.Job") == 1 then
					triggerServerEvent(">ĐĐĐ|}Äí{ÍÄ<đ", localPlayer, source == dropDownCol)
				end
			end
		end
	end)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (leaveElement, matchingDimension)
		if leaveElement == localPlayer and matchingDimension then
			if source == factoryColShape then
				removeEventHandler("onClientRender", getRootElement(), renderInsideFactory)

				if isElement(loadingBaysRT) then
					destroyElement(loadingBaysRT)
				end
				loadingBaysRT = nil

				if isElement(clockRT) then
					destroyElement(clockRT)
				end
				clockRT = nil

				if isTimer(refreshClockTimer) then
					killTimer(refreshClockTimer)
				end
				refreshClockTimer = nil

				if isElement(quantityRT) then
					destroyElement(quantityRT)
				end
				quantityRT = nil

				if isElement(quantityRT2) then
					destroyElement(quantityRT2)
				end
				quantityRT2 = nil
			end

			if source == warehouseColShape then
				removeEventHandler("onClientRender", getRootElement(), render3DItem)

				for k, v in pairs(itemPictures) do
					if isElement(v) then
						destroyElement(v)
					end
				end

				itemPictures = {}
			end

			if shelfItems then
				if shelfColShape[source] then
					if getElementData(localPlayer, "char.Job") == 1 then
						removeEventHandler("onClientRender", getRootElement(), standingItemsRender)
						removeEventHandler("onClientClick", getRootElement(), standingItemsClick)

						shelfItems = false

						if isElement(Roboto) then
							destroyElement(Roboto)
						end
						Roboto = nil
					end
				end
			end
		end
	end)

local lastPickupTick = 0
local hoverMaterial = false

function standingItemsClick(button, state)
	if state == "up" then
		if getTickCount() - lastPickupTick >= 1250 then
			if hoverMaterial then
				triggerServerEvent("pickupFactoryMaterial", localPlayer, hoverMaterial)
				exports.see_chat:localActionC(localPlayer, "elvesz egy " .. itemNames[itemIds[hoverMaterial]] .. "-t a polcról.")
				lastPickupTick = getTickCount()
			end
		end
	end
end

function standingItemsRender()
	if getTickCount() - lastPickupTick >= 1250 then
		local cx, cy = getCursorPosition()

		if tonumber(cx) then
			cx = cx * screenX
			cy = cy * screenY
		end

		hoverMaterial = false

		for i = 1, #shelfItems do
			local materialId = shelfItems[i]
			local itemId = itemIds[materialId]

			if itemId then
				local onScreenX, onScreenY = getScreenFromWorldPosition(standingItems[materialId][1], standingItems[materialId][2], standingItems[materialId][3])

				if onScreenX then
					local borderColor = tocolor(0, 0, 0, 200)

					onScreenX = math.floor(onScreenX)
					onScreenY = math.floor(onScreenY)

					if tonumber(cx) then
						if cx >= onScreenX - 24 and cx <= onScreenX + 24 and cy >= onScreenY - 24 and cy <= onScreenY + 24 then
							borderColor = tocolor(61, 122, 188)
							hoverMaterial = materialId
						end
					end

					dxDrawRectangle(onScreenX - 24, onScreenY - 24, 48, 48, borderColor)
					dxDrawImage(onScreenX - 24 + 1, onScreenY - 24 + 1, 46, 46, ":see_items/files/items/" .. itemId - 1 .. ".png")
					
					for xoff = -1, 1, 2 do
						for yoff = -1, 1, 2 do
							dxDrawText(itemNames[itemId], onScreenX - 100 + xoff, onScreenY + 24 + yoff, onScreenX + 100 + xoff, onScreenY + 48 + yoff, tocolor(0, 0, 0), 1, Roboto, "center", "center")
						end
					end
					dxDrawText(itemNames[itemId], onScreenX - 100, onScreenY + 24, onScreenX + 100, onScreenY + 48, tocolor(255, 255, 255), 1, Roboto, "center", "center")
				end
			end
		end
	end
end

function render3DItem()
	for i = 1, #materialItems do
		local v = materialItems[i]

		if v then
			dxDrawMaterialLine3D(v[1], v[2], v[3], v[1], v[2], v[3] - 0.25, itemPictures[v[4]], 0.25, tocolor(255, 255, 255), v[1], v[2] - 1 * v[5], v[3] - 0.125)
		end
	end
end

function renderInsideFactory()
	for i = 1, #loadingBays do
		local v = loadingBays[i]
		if v then
			dxDrawMaterialLine3D(v[1] + v[3] / 2, v[2], v[6], v[1] + v[3] / 2, v[2] + v[4], v[6], loadingBaysRT, v[3], v[5], v[1] + v[3] / 2, v[2] + v[4] / 2, v[6] + 0.5)
		end
	end

	dxDrawMaterialLine3D(1485.25, 2342.5952148438, 2.6, 1485.25, 2342.5952148438, 1.7, clockRT, 1.8, tocolor(255, 255, 255), 1486.25, 2342.5952148438, 0)
	dxDrawMaterialLine3D(1498.5, 2357.725, -0.8, 1498.5, 2357.725, -1.7, quantityRT, 2.5, tocolor(255, 255, 255), 1498.5, 2356.725, 0)
	dxDrawMaterialLine3D(1510.5, 2357.725, -0.8, 1510.5, 2357.725, -1.7, quantityRT2, 2.5, tocolor(255, 255, 255), 1510.5, 2356.725, 0)
end

function createLoadingBays()
	if loadingBaysRT then
		local sx = 1.75
		local sy = 1

		dxSetRenderTarget(loadingBaysRT)

		for x = 0, sx * 4 do
			for y = 0, sy * 4 do
				dxDrawImage(x * 12, y * 12, 12, 12, "files/stripe.png")
			end
		end

		dxDrawRectangle(0, 0, 4, sy * 48, tocolor(255, 255, 255))
		dxDrawRectangle(sx * 48 - 4, 0, 4, sy * 48, tocolor(255, 255, 255))
		dxDrawRectangle(0, 0, sx * 48, 4, tocolor(255, 255, 255))
		dxDrawRectangle(0, sy * 48 - 4, sx * 48, 4, tocolor(255, 255, 255))
	end
	
	refreshClockRT()
	updateQuantity()
end
addEventHandler("onClientResourceStart", getResourceRootElement(), createLoadingBays)
addEventHandler("onClientRestore", getRootElement(), createLoadingBays)

function refreshClockRT()
	if isElementWithinColShape(localPlayer, factoryColShape) then
		dxSetRenderTarget(clockRT)

		local tempFont = dxCreateFont("files/ocr.ttf", 25, true)

		dxDrawRectangle(0, 0, 180, 90, tocolor(40, 40, 40))
		dxDrawRectangle(10, 10, 160, 70, tocolor(0, 0, 0))
		
		dxDrawText(string.format("%02d:%02d", getRealTime().hour, getRealTime().minute), 0, 0, 180, 90, tocolor(245, 10, 10), 1, tempFont, "center", "center")
		destroyElement(tempFont)

		dxSetRenderTarget()
	end
end

function updateQuantity()
	if isElementWithinColShape(localPlayer, factoryColShape) then
		local tempFont = dxCreateFont("files/ocr.ttf", 10, true)

		dxSetRenderTarget(quantityRT, true)
		
		dxDrawRectangle(0, 0, 250, 90, tocolor(20, 20, 20))
		dxDrawRectangle(5, 5, 240, 80, tocolor(74, 80, 24))
		
		local doneItems = {}

		for i = 1, 3 do
			table.insert(doneItems, exports.see_items:getItemName(finalItems[i]) .. ": " .. (getElementData(resourceRoot, "doneItems:" .. finalItems[i]) or 0) .. " db")
		end
		
		dxDrawText(table.concat(doneItems, "\n"), 0, 0, 250, 90, tocolor(37, 40, 12), 1, tempFont, "center", "center")
		
		dxSetRenderTarget(quantityRT2, true)
		
		dxDrawRectangle(0, 0, 250, 90, tocolor(20, 20, 20))
		dxDrawRectangle(5, 5, 240, 80, tocolor(74, 80, 24))

		local doneItems = {}
		
		for i = 4, 6 do
			table.insert(doneItems, exports.see_items:getItemName(finalItems[i]) .. ": " .. (getElementData(resourceRoot, "doneItems:" .. finalItems[i]) or 0) .. " db")
		end
		
		dxDrawText(table.concat(doneItems, "\n"), 0, 0, 250, 90, tocolor(37, 40, 12), 1, tempFont, "center", "center")
		
		destroyElement(tempFont)
		
		dxSetRenderTarget()
	end
end

local sign1 = dxCreateTexture("files/sign1.png")
local sign2 = dxCreateTexture("files/sign2.png")
local sign3 = dxCreateTexture("files/sign3.png")

addEventHandler("onClientRender", getRootElement(),
	function ()
		dxDrawMaterialLine3D(1441.45, 2360.1328125, 13.213333333333, 1441.45, 2360.1328125, 12.786666666667, sign1, 1.7066666666667, tocolor(255, 255, 255), 1442.45, 2360.1328125, 0)
		dxDrawMaterialLine3D(1441.15, 2349.5571289069, 13.176666666667, 1441.15, 2349.5571289069, 12.323333333333, sign2, 3.4133333333333, tocolor(255, 255, 255), 1442.15, 2349.5571289069, 0)
		dxDrawMaterialLine3D(1467.35, 2357.7880859375, 12.963333333333, 1467.35, 2357.7880859375, 12.536666666667, sign3, 1.7066666666667, tocolor(255, 255, 255), 1466.35, 2357.7880859375, 0)
	end)