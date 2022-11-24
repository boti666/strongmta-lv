local screenX, screenY = guiGetScreenSize()

local slotLimit = 6

local panelState = false

local panelWidth = (defaultSettings.slotBoxWidth + 5) * slotLimit + 5
local panelHeight = defaultSettings.slotBoxHeight + 5 * 2

local panelPosX = screenX  / 2 - panelWidth / 2
local panelPosY = screenY - panelHeight - 5

local actionBarItems = {}
local actionBarSlots = {}
local slotPositions = false

local loggedIn = false
local editHud = false
local bigRadarState = false

local moveDifferenceX = 0
local moveDifferenceY = 0

local movedSlotId = false
local lastHoverSlotId = false
local hoverSpecialItem = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "loggedIn") then
			loadActionBarItems()

			loggedIn = true
			panelState = true

			triggerEvent("requestChangeItemStartPos", localPlayer)
			triggerEvent("movedItemInInv", localPlayer, true)
		end
	end)

function loadActionBarItems()
	local items = getElementData(localPlayer, "actionBarItems") or {}

	actionBarSlots = {}

	for i = 1, 6 do
		if items[i] then
			actionBarSlots[i - 1] = items[i]
		end
	end
end

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName, oldValue)
		if dataName == "loggedIn" then
			if getElementData(localPlayer, "loggedIn") then
				loadActionBarItems()

				loggedIn = true
				panelState = true	
			end
		elseif dataName == "actionBarItems" then
			triggerEvent("movedItemInInv", localPlayer)
		elseif dataName == "bigRadarState" then
			bigRadarState = getElementData(source, "bigRadarState")
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY)
		if loggedIn and not editHud and not bigRadarState then
			if button == "left" then
				if state == "down" then
					local hoverSlotId, slotPosX, slotPosY = findActionBarSlot(absX, absY)

					if hoverSlotId and actionBarSlots[hoverSlotId] then
						movedSlotId = hoverSlotId

						moveDifferenceX = absX - slotPosX
						moveDifferenceY = absY - slotPosY

						playSound("files/sounds/select.mp3")
					end
				elseif state == "up" then
					if movedSlotId then
						local items = getElementData(localPlayer, "actionBarItems") or {}
						local hoverSlotId = findActionBarSlot(absX, absY)

						if hoverSlotId then
							if not actionBarSlots[hoverSlotId] then
								actionBarSlots[hoverSlotId] = actionBarSlots[movedSlotId]
								items[hoverSlotId+1] = actionBarSlots[movedSlotId]

								for i = 1, 6 do
									if items[i] then
										if movedSlotId == i - 1 then
											items[i] = nil
										end
									end
								end

								setElementData(localPlayer, "actionBarItems", items)
								actionBarSlots[movedSlotId] = nil
							end
						else
							for i = 1, 6 do
								if items[i] then
									if movedSlotId == i - 1 then
										items[i] = nil
									end
								end
							end
								
							actionBarSlots[movedSlotId] = nil
							setElementData(localPlayer, "actionBarItems", items)
						end

						playSound("files/sounds/select.mp3")

						movedSlotId = false
					elseif hoverSpecialItem then
						if currentItemInUse then
							itemsTable.player[currentItemInUse.slot].inUse = false
							triggerServerEvent("detachObject", localPlayer)
							currentItemInUse = false
							currentItemRemainUses = false
						end
					end
				end
			elseif button == "right" then
				if state == "up" then
					if hoverSpecialItem and currentItemInUse then
						useSpecialItem()
					end
				end
			end
		end
	end)

function putOnActionBar(slot, item)
	if slot then
		if not actionBarSlots[slot] then
			local items = getElementData(localPlayer, "actionBarItems") or {}

			actionBarSlots[slot] = item.dbID
			items[slot + 1] = item.dbID

			setElementData(localPlayer, "actionBarItems", items)

			return true
		else
			return false
		end
	else
		return false
	end
end

function findActionBarSlot(x, y)
	if panelState then
		local slot = false
		local slotPosX, slotPosY = false, false

		for i = 0, slotLimit - 1 do
			if not slotPositions or not slotPositions[i] then
				return
			end

			local x2 = slotPositions[i][1]
			local y2 = slotPositions[i][2]

			if x >= x2 and x <= x2 + defaultSettings.slotBoxWidth and y >= y2 and y <= y2 + defaultSettings.slotBoxHeight then
				slot = tonumber(i)
				slotPosX, slotPosY = x2, y2
				break
			end
		end

		if slot then
			return slot, slotPosX, slotPosY
		else
			return false
		end
	else
		return false
	end
end

for i = 1, slotLimit do
	bindKey(tostring(i), "down",
		function ()
			if not editHud and not bigRadarState and loggedIn then
				useActionSlot(i)
			end
		end
	)
end

function useActionSlot(slot)
	if not haveMoving and slot then
		slot = tonumber(slot - 1)

		if not guiGetInputEnabled() then
			local item = tonumber(actionBarSlots[slot])

			if item then
				useItem(item)
			end
		end
	end
end

addEvent("updateItemID", true)
addEventHandler("updateItemID", getRootElement(),
	function (ownerType, itemId, newId)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			newId = tonumber(newId)
			
			if itemId and newId then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].itemId = newId
					end
				end
			end
		end
	end)

addEvent("updateData1", true)
addEventHandler("updateData1", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			
			if itemId and newData then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].data1 = newData
					end
				end
			end
		end
	end)

addEvent("updateData2", true)
addEventHandler("updateData2", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			
			if itemId and newData then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].data2 = newData
					end
				end
			end
		end
	end)

addEvent("updateData3", true)
addEventHandler("updateData3", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			
			if itemId and newData then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].data3 = newData
					end
				end
			end
		end
	end)

function isPointOnActionBar(x, y)
	if panelState then
		if x >= panelPosX and x <= panelPosX + panelWidth and y >= panelPosY and y <= panelPosY + panelHeight then
			return true
		else
			return false
		end
	else
		return false
	end
end

function changeItemStartPos(x, y)
	panelPosX = x
	panelPosY = y
	slotPositions = {}

	for i = 0, slotLimit - 1 do
		slotPositions[i] = {math.floor(x + (defaultSettings.slotBoxWidth + 5) * i), y}
	end
end

function processActionBarShowHide(state)
	panelState = state
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		if panelState and slotPositions then
			if isCursorShowing() then
				editHud = getKeyState("lctrl")
			elseif editHud then
				editHud = false
			end

			local cx, cy = getCursorPosition()

			if cx and cy then
				cx = cx * screenX
				cy = cy * screenY
			else
				cx, cy = -1, -1
			end

			for i = 0, slotLimit - 1 do
				if slotPositions[i] then
					renderActionBarItem(i, slotPositions[i][1], slotPositions[i][2], cx, cy)
				end
			end

			if movedSlotId then
				local x = cx - moveDifferenceX
				local y = cy - moveDifferenceY
				local item = false

				for k, v in pairs(itemsTable.player) do
					if actionBarSlots[movedSlotId] == v.dbID then
						item = v
						break
					end
				end

				if item and tonumber(item.itemId) and tonumber(item.amount) then
					drawItemPicture(item, x, y)
					dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.5, myriadpro, "right")
				else
					dxDrawImage(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, "files/noitem.png")
				end
			end

			hoverSpecialItem = false

			if currentItemInUse and specialItems[currentItemInUse.itemId] then
				local sx, sy = defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight
				local x = math.floor(panelPosX + panelWidth / 2 - sx / 2)
				local y = math.floor(panelPosY - defaultSettings.slotBoxHeight - 30)

				dxDrawRectangle(x - 2, y - 2, sx + 4, 2, tocolor(0, 0, 0, 200)) -- felső
				dxDrawRectangle(x - 2, y + sy, sx + 4, 2, tocolor(0, 0, 0, 200)) -- alsó
				dxDrawRectangle(x - 2, y, 2, sy, tocolor(0, 0, 0, 200)) -- bal
				dxDrawRectangle(x + sx, y, 2, sy, tocolor(0, 0, 0, 200)) -- jobb

				if cx >= x and cy >= y and cx <= x + sx and cy <= y + sy then
					dxDrawRectangle(x, y, sx, sy, tocolor(255, 127, 0, 200))
					hoverSpecialItem = true
				else
					dxDrawRectangle(x, y, sx, sy, tocolor(50, 50, 50, 200))
				end

				drawItemPicture(currentItemInUse, x, y, sx, sy)
				dxDrawImage(x + sx / 2 - 46 / 2 - 46, y + sy / 2 - 46 / 2, 46, 46, "files/leftMouse.png")
				dxDrawImage(x + sx / 2 - 46 / 2 + 46, y + sy / 2 - 46 / 2, 46, 46, "files/rightMouse.png")
				
				local sx, sy = panelWidth - 4, 6
				local x, y = panelPosX - 4, panelPosY - sy * 3.5

				dxDrawRectangle(x - 2, y - 2, sx + 4, 2, tocolor(0, 0, 0, 200)) -- felső
				dxDrawRectangle(x - 2, y + sy, sx + 4, 2, tocolor(0, 0, 0, 200)) -- alsó
				dxDrawRectangle(x - 2, y, 2, sy, tocolor(0, 0, 0, 200)) -- bal
				dxDrawRectangle(x + sx, y, 2, sy, tocolor(0, 0, 0, 200)) -- jobb
				dxDrawRectangle(x, y, sx, sy, tocolor(50, 50, 50, 200)) -- háttér

				local progress = currentItemRemainUses / specialItems[currentItemInUse.itemId][2]
				local progresscolor = tocolor(61, 122, 188)
			
				if progress > 0.20 and progress <= 0.65 then
					progresscolor = tocolor(255, 127, 0)
				elseif progress <= 0.20 then
					progresscolor = tocolor(215, 89, 89)
				end

				dxDrawRectangle(x, y, sx * progress, sy, progresscolor) -- állapot
			end
		end
	end, true, "low")

function renderActionBarItem(slot, x, y, cx, cy)
	if actionBarItems[slot] and actionBarSlots[slot] and slot ~= movedSlotId then
		local item = actionBarItems[slot].slot
		local slotColor = tocolor(50, 50, 50, 200)
		local inUse = false

		if item and itemsTable.player[item] and itemsTable.player[item].inUse then
			slotColor = tocolor(61, 122, 188, 200)
			inUse = true
		end

		if (getKeyState(slot + 1) or cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight) and not editHud then
			if not inUse then
				slotColor = tocolor(255, 127, 0, 200)
			end
			
			if lastHoverSlotId ~= slot then
				lastHoverSlotId = slot

				if not movedSlotId then
					playSound("files/sounds/hover.mp3")
				end
			end
		elseif lastHoverSlotId == slot then
			lastHoverSlotId = false
		end

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, slotColor)

		if actionBarItems[slot].itemId and actionBarItems[slot].amount then
			drawItemPicture(actionBarItems[slot], x, y)
			dxDrawText(actionBarItems[slot].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.5, myriadpro, "right")
		else
			dxDrawImage(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, "files/noitem.png")
		end

		if inUse then
			dxDrawImage(x - 3, y - 3, 42, 42, "files/used.png", 0, 0, 0, tocolor(255, 255, 255, 150))
		end
	else
		local slotColor = tocolor(50, 50, 50, 200)

		if getKeyState(slot + 1) or cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight then
			if not editHud then
				slotColor = tocolor(255, 127, 0, 200)
			end
		end

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, slotColor)
	end
end

local sideWeapons = {
	[85] = 355,
	[86] = 356,
	[87] = 357,
	[88] = 358,
	[81] = 351,
	[79] = 349,
	[80] = 350,
	[83] = 353,
	[74] = 339,
	[78] = 348,
	[265] = 355,
	[266] = 355,
	[267] = 355,
	[268] = 355,
	[269] = 355,
	[270] = 355,
	[271] = 355,
	[272] = 348,
	[273] = 348,
	[274] = 358,
	[275] = 358,
	[276] = 353,
	[277] = 353,
	[278] = 353,
	[279] = 353,
	[340] = 353,
	[341] = 353,
	[280] = 335,
	[281] = 335,
	[282] = 335,
	[283] = 372,
	[284] = 372,
	[285] = 372,
	[286] = 372,
	[69] = 334,
	[71] = 336,
	[70] = 335,
	[342] = 349,
	[343] = 349,
	[344] = 349,
	[345] = 349,
	[346] = 353,
	[347] = 353,
	[102] = 323,
	[369] = 353
}

addEvent("movedItemInInv", true)
addEventHandler("movedItemInInv", getRootElement(),
	function (simpleUpdate)
		checkRecipeHaveItem()
		
		for i = 0, slotLimit - 1 do
			actionBarItems[i] = {}

			for k, v in pairs(itemsTable.player) do
				if actionBarSlots[i] == v.dbID then
					actionBarItems[i].slot = tonumber(v.slot)
					actionBarItems[i].itemId = tonumber(v.itemId)
					actionBarItems[i].amount = tonumber(v.amount)
					actionBarItems[i].data1 = tonumber(v.data1)
					actionBarItems[i].data2 = tonumber(v.data2)
					actionBarItems[i].data3 = tonumber(v.data3)
					break
				end
			end
		end

		if not simpleUpdate then
			local added = {}
			local datas = {}

			for i = 0, defaultSettings.slotLimit - 1 do
				if itemsTable.player[i] then
					local item = itemsTable.player[i]

					if sideWeapons[item.itemId] then
						local k = item.itemId .. "," .. (weaponSkins[item.itemId] or 0)

						if not added[k] then
							added[k] = true

							if item.inUse then
								table.insert(datas, {item.itemId, "inuse", weaponSkins[item.itemId] or 0})
							else
								table.insert(datas, {item.itemId, true, weaponSkins[item.itemId] or 0})
							end
						end
					end
				end
			end

			local currentdatas = getElementData(localPlayer, "playerSideWeapons") or {}
			local updatedata = false

			if currentdatas then
				local old = {}
				local new = {}

				for k, v in ipairs(currentdatas) do
					old[tostring(v[1]) .. "," .. tostring(v[2]) .. "," .. tostring(v[3])] = true
				end
				
				for k, v in ipairs(datas) do
					new[tostring(v[1]) .. "," .. tostring(v[2]) .. "," .. tostring(v[3])] = true
				end
				
				for k, v in pairs(old) do
					if not new[k] then
						updatedata = true
						break
					end
				end
				
				for k, v in pairs(new) do
					if not old[k] then
						updatedata = true
						break
					end
				end
			end

			if updatedata then
				setElementData(localPlayer, "playerSideWeapons", datas)
			end
		end
	end)

function isActionBarVisible()
	return panelState
end