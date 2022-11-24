local screenX, screenY = guiGetScreenSize()

local panelState = false

local panelWidth = (defaultSettings.slotBoxWidth + 5) * defaultSettings.width + 5 + 50
local panelHeight = (defaultSettings.slotBoxHeight + 5) * math.floor(defaultSettings.slotLimit / defaultSettings.width) + 5 + 40

local panelPosX = screenX / 2
local panelPosY = screenY / 2

local stackGUI = false
local stackAmount = 0

local moveDifferenceX = 0
local moveDifferenceY = 0
local panelIsMoving = false

local Roboto = dxCreateFont("files/fonts/Roboto.ttf", 22, false, "antialiased")

itemsTableState = "player"
itemsTable = {}
itemsTable.player = {}
itemsTable.vehicle = {}
itemsTable.object = {}
currentInventoryElement = localPlayer

haveMoving = false
local movedSlotId = false
local lastHoverSlotId = false

local currentTab = "main"
local hoverTab = false

local itemPictures = {}
local perishableTimer = false
local grayItemPictures = {}
local rottenEffect = false

local overheatWeapons = {
	[22] = true,
	[23] = true,
	[24] = true,
	[25] = true,
	[26] = true,
	[27] = true,
	[28] = true,
	[29] = true,
	[30] = true,
	[31] = true,
	[32] = true,
	[33] = true,
	[34] = true
}

txd = engineLoadTXD("files/villogo.txd")
engineImportTXD(txd, 1314)
dff = engineLoadDFF("files/villogo.dff")
engineReplaceModel(dff, 1314)

function getPhoneBalance(phoneNum)
  for k, v in pairs(itemsTable.player) do
    if v.itemId == 9 and tonumber(v.data1) == phoneNum then
      outputDebugString("phone balance: " .. phoneNum .. "=" .. tostring(v.data2))
      return tonumber(v.data2) or 0
    end
  end
  return 0
end

function deepcopy(t)
	local copy
	if type(t) == "table" then
		copy = {}
		for k, v in next, t, nil do
			copy[deepcopy(k)] = deepcopy(v)
		end
		setmetatable(copy, deepcopy(getmetatable(t)))
	else
		copy = t
	end
	return copy
end

local currentCraftingPosition = false
local craftingColshapes = {}
local craftingPositions = {
	{2556.0322265625, -1293.4833984375, 1045.3607177734, 2, 1380, 5},
	{2543.130859375, -1293.1884765625, 1045.0771484375, 2, 1380, 5},
}

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

for y = 0, 1 do -- gyártósori összerelő
	for x = 0, 5 do
		local x, y = rotateAround(90, -1.5 + y * -4, 0.85 + x * -4, 1491.7578125, 2345.3388671875)

		table.insert(craftingPositions, {x, y, -3.4545001983643, 1.75, 1, 3})
	end
end

local craftRecipes = deepcopy(availableRecipes)
local craftList = {}
local collapsedCategories = {}
local lastCraftCategory = 0

local hoverRecipeCategory = false
local hoverRecipe = false
local selectedRecipe = false

local appliedRecipeItems = {}
local requiredRecipeItems = {}

local craftListOffset = 0
local canCraftTheRecipe = false
local hoverCraftButton = false
local craftingProcess = false
local craftStartTime = false

local currentJob = 0
local playerRecipes = {}
local defaultRecipes = {
	[1] = true,
	[2] = true
}

do
	for i = 1, #craftRecipes do
		if not craftRecipes[i] then
			craftRecipes[i] = {"null"}
			craftRecipes[i].category = "null"
		end

		craftRecipes[i].id = i
		craftRecipes[i].items = nil
		craftRecipes[i].finalItem = nil
		craftRecipes[i].requiredPermission = nil
		craftRecipes[i].suitableColShapes = nil
		craftRecipes[i].requiredJob = nil
	end

	table.sort(craftRecipes, function (a, b)
		if not a then
			return false
		end

		if not b then
			return false
		end

		return a.category < b.category or a.category == b.category and a.name < b.name
	end)

	for i = 1, #craftRecipes do
		if craftRecipes[i].name ~= "null" then
			local category = craftRecipes[i].category

			if not craftList[category] then
				craftList[category] = true
				collapsedCategories[category] = false

				table.insert(craftList, {"category", category, collapsedCategories[category]})

				lastCraftCategory = #craftList
			end

			if craftList[lastCraftCategory][3] then
				table.insert(craftList, {"recipe", craftRecipes[i].id})
			end
		end
	end
end

local renameProcess = false
local renameDetails = false

local notepadState = false
local notepadFont = false
local notepadText = false
local notepadCursorState = false
local notepadCursorChange = 0
local noteText = false
local noteIsCopy = false
local noteState = false

local wallNotes = {}
local wallNoteRadius = 80
local wallNoteCol = {}
local nearbyWallNotes = {}
local hoverWallNote = false

local myCharacterId = getElementData(localPlayer, "char.ID")
local myAdminLevel = getElementData(localPlayer, "acc.adminLevel")

addEvent("loadItems", true)
addEventHandler("loadItems", getRootElement(),
	function (items, ownerType, element, reopen)
		if items and type(items) == "table" then
			itemsTable[ownerType] = {}

			for k, v in pairs(items) do
				addItem(tostring(ownerType), v.dbID, v.slot, v.itemId, v.amount, v.data1, v.data2, v.data3, v.nameTag, v.serial)
			end

			if reopen then
				toggleInventory(false)
				currentInventoryElement = element
				itemsTableState = ownerType
				toggleInventory(true)
			end

			triggerEvent("movedItemInInv", localPlayer)
		end
	end)

addEvent("äĐĐÍÄ<", true)
addEventHandler("äĐĐÍÄ<", getRootElement(),
	function (ownerType, item)
		if itemsTable[ownerType] and item and type(item) == "table" then
			addItem(ownerType, item.dbID, item.slot, item.itemId, item.amount, item.data1, item.data2, item.data3, item.nameTag, item.serial)
		end
	end)

addEvent("deleteItem", true)
addEventHandler("deleteItem", getRootElement(),
	function (ownerType, items)
		if itemsTable[ownerType] and items and type(items) == "table" then
			for k, v in pairs(items) do
				for i = 0, defaultSettings.slotLimit * 3 - 1 do
					if itemsTable[ownerType][i] and itemsTable[ownerType][i].dbID == v then
						itemsTable[ownerType][i] = nil

						if movedSlotId == i then
							movedSlotId = false
						end
					end
				end
			end
		end
	end)

addEvent("updateAmount", true)
addEventHandler("updateAmount", getRootElement(),
	function (ownerType, itemId, newAmount)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			newAmount = tonumber(newAmount)

			if itemId and newAmount then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].amount = newAmount
					end
				end
			end
		end
	end)

addEvent("updateItemID", true)
addEventHandler("updateItemID", getRootElement(),
	function (ownerType, itemId, newId)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			newId = tonumber(newId)

			if itemId and newId then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].itemId = newId
					end
				end
			end
		end
	end)

addEvent("unuseAmmo", true)
addEventHandler("unuseAmmo", getRootElement(),
	function ()
		exports.see_chat:sendLocalDoC(source, "Tönkrement a fegyere")
		exports.see_hud:showInfobox("e", "Tönkrement a fegyvered, ezért eldobtad!")

		for k, v in pairs(itemsTable.player) do
			if v.inUse and (isWeaponItem(v.itemId) or isAmmoItem(v.itemId)) then
				itemsTable.player[v.slot].inUse = false
			end
		end
	end)

addEvent("updateData1", true)
addEventHandler("updateData1", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			newData = tonumber(newData) or newData

			if itemId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data1 = newData
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
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data2 = newData
						triggerServerEvent("updateData2", localPlayer, localPlayer, itemId, newData)
					end
				end
			end
		end
	end)

addEvent("updateData2Ex", true)
addEventHandler("updateData2Ex", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)

			if itemId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data2 = newData
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
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data3 = newData
						triggerServerEvent("updateData3", localPlayer, localPlayer, itemId, newData)
					end
				end
			end
		end
	end)

addEvent("updateNameTag", true)
addEventHandler("updateNameTag", getRootElement(),
	function (itemId, text)
		if itemsTable.player then
			itemId = tonumber(itemId)

			if itemId and text then
				for k, v in pairs(itemsTable.player) do
					if v.dbID == itemId then
						itemsTable.player[v.slot].nameTag = text
					end
				end
			end
		end
	end)

addEvent("updateInUse", true)
addEventHandler("updateInUse", getRootElement(),
	function (ownerType, itemId, inuse)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)

			if itemId then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].inUse = inuse
					end
				end
			end
		end
	end)

addEvent("unLockItem", true)
addEventHandler("unLockItem", getRootElement(),
	function (ownerType, slot)
		if itemsTable[ownerType] and itemsTable[ownerType][slot] and itemsTable[ownerType][slot].locked then
			itemsTable[ownerType][slot].locked = false
		end
	end)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "loggedIn" then
			if getElementData(source, dataName) then
				triggerServerEvent("requestWallNotes", localPlayer)

				if isTimer(perishableTimer) then
					killTimer(perishableTimer)
				end

				perishableTimer = setTimer(processPerishableItems, 60000, 0)
			end
		end

		if dataName == "playerRecipes" then
			playerRecipes = getElementData(localPlayer, "playerRecipes") or {}
		end

		if dataName == "char.Job" then
			currentJob = getElementData(localPlayer, "char.Job") or 0
		end

		if dataName == "char.ID" then
			myCharacterId = getElementData(localPlayer, "char.ID")
		end

		if dataName == "acc.adminLevel" then
			myAdminLevel = getElementData(localPlayer, "acc.adminLevel")
		end
	end)

function addItem(ownerType, dbID, slot, itemId, amount, data1, data2, data3, nameTag, serial)
	if dbID and slot and itemId and amount and not itemsTable[ownerType][slot] then
		itemsTable[ownerType][slot] = {}
		itemsTable[ownerType][slot].dbID = dbID
		itemsTable[ownerType][slot].slot = slot
		itemsTable[ownerType][slot].itemId = itemId
		itemsTable[ownerType][slot].amount = amount
		itemsTable[ownerType][slot].data1 = data1
		itemsTable[ownerType][slot].data2 = data2
		itemsTable[ownerType][slot].data3 = data3
		itemsTable[ownerType][slot].inUse = false
		itemsTable[ownerType][slot].locked = false
		itemsTable[ownerType][slot].nameTag = nameTag
		itemsTable[ownerType][slot].serial = serial
	end
end

function findEmptySlot(ownerType)
	local emptySlot = false

	for i = 0, defaultSettings.slotLimit - 1 do
		if not itemsTable[ownerType][i] then
			emptySlot = i
			break
		end
	end

	return emptySlot
end

function findEmptySlotOfKeys(ownerType)
	local emptySlot = false

	for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
		if not itemsTable[ownerType][i] then
			emptySlot = i
			break
		end
	end

	return emptySlot
end

function findEmptySlotOfPapers(ownerType)
	local emptySlot = false

	for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
		if not itemsTable[ownerType][i] then
			emptySlot = i
			break
		end
	end

	return emptySlot
end

function processPerishableItems()
	for k, v in pairs(itemsTable.player) do
		local itemId = v.itemId

		if perishableItems[itemId] then
			local value = (tonumber(v.data3) or 0) + 1

			if value - 1 > perishableItems[itemId] then
				triggerEvent("updateData3", localPlayer, "player", v.dbID, perishableItems[itemId])
			end

			if value <= perishableItems[itemId] then
				triggerEvent("updateData3", localPlayer, "player", v.dbID, value)
			elseif perishableEvent[itemId] then
				triggerServerEvent(perishableEvent[itemId], localPlayer, v.dbID)
			end
		end
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "loggedIn") then
			setTimer(triggerServerEvent, 5000, 1, "requestCache", localPlayer)

			if isTimer(perishableTimer) then
				killTimer(perishableTimer)
			end

			perishableTimer = setTimer(processPerishableItems, 60000, 0)
		end

		for k, v in pairs(availableItems) do
			if fileExists("files/items/" .. k - 1 .. ".png") then
				itemPictures[k] = dxCreateTexture("files/items/" .. k - 1 .. ".png")
			else
				itemPictures[k] = dxCreateTexture("files/items/nopic.png")
			end
		end

		for k, v in pairs(perishableItems) do
			if itemPictures[k] then
				grayItemPictures[k] = dxCreateShader("files/monochrome.fx")

				dxSetShaderValue(grayItemPictures[k], "screenSource", itemPictures[k])
			end
		end

		for k, v in pairs(copyableItems) do
			if itemPictures[k] then
				grayItemPictures[k] = dxCreateShader("files/monochrome.fx")

				dxSetShaderValue(grayItemPictures[k], "screenSource", itemPictures[k])
			end
		end

		for k, v in pairs(craftingPositions) do
			if k <= 2 then
				craftingColshapes[k] = createColSphere(v[1], v[2], v[3], v[6])

				if isElement(craftingColshapes[k]) then
					setElementInterior(craftingColshapes[k], v[4])
					setElementDimension(craftingColshapes[k], v[5])
					setElementData(craftingColshapes[k], "craftingPosition", k, false)
				end
			else
				craftingColshapes[k] = createColCuboid(v[1], v[2], v[3], v[4], v[5], v[6])

				if isElement(craftingColshapes[k]) then
					setElementData(craftingColshapes[k], "craftingPosition", k, false)
				end
			end
		end

		playerRecipes = getElementData(localPlayer, "playerRecipes") or {}
		currentJob = getElementData(localPlayer, "char.Job") or 0
	end)

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (element, matchdim)
		if element == localPlayer and matchdim then
			if getElementData(source, "craftingPosition") then
				currentCraftingPosition = getElementData(source, "craftingPosition")
				setElementData(localPlayer, "currentCraftingPosition", currentCraftingPosition)
			end
		end
	end)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (element)
		if element == localPlayer then
			if getElementData(source, "craftingPosition") then
				currentCraftingPosition = false
				setElementData(localPlayer, "currentCraftingPosition", currentCraftingPosition)
			end
		end
	end)

bindKey("i", "down",
	function ()
		if getElementData(localPlayer, "loggedIn") then
			toggleInventory(not panelState)

			itemsTableState = "player"
			currentInventoryElement = localPlayer

			panelIsMoving = false

			if renameProcess then
				itemsTable.player[renameProcess].inUse = false
				renameProcess = false
				renameDetails = false
				setCursorAlpha(255)
			end
		end
	end)

function toggleInventory(state)
	if panelState ~= state then
		if state then
			checkRecipeHaveItem()

			if isElement(stackGUI) then
				destroyElement(stackGUI)
			end

			stackAmount = 0
			stackGUI = guiCreateEdit(panelPosX + panelWidth - 50 - 10, panelPosY, 50, 20, "", false)

			addEventHandler("onClientRender", getRootElement(), onRender, true, "low-999")

			panelState = true
		else
			if itemsTableState == "vehicle" or itemsTableState == "object" then
				triggerServerEvent("closeInventory", localPlayer, currentInventoryElement, getElementsByType("player", getRootElement(), true))
			end

			removeEventHandler("onClientRender", getRootElement(), onRender)

			panelState = false

			if isElement(stackGUI) then
				destroyElement(stackGUI)
			end

			stackGUI = nil
			stackAmount = 0
		end
	end
end

function applyRecipe(items)
	appliedRecipeItems = items
	requiredRecipeItems = {}

	if items then
		checkRecipeHaveItem()
	end
end

function checkRecipeHaveItem()
	if currentTab == "crafting" and appliedRecipeItems then
		local items = {}

		for k, v in pairs(itemsTable.player) do
			items[v.itemId] = true
		end

		for y = 1, 3 do
			requiredRecipeItems[y] = {}

			if appliedRecipeItems[y] then
				for x = 1, 3 do
					if appliedRecipeItems[y][x] then
						requiredRecipeItems[y][x] = {appliedRecipeItems[y][x], items[appliedRecipeItems[y][x]]}
					end
				end
			end
		end
	end
end

addEvent("requestCrafting", true)
addEventHandler("requestCrafting", getRootElement(),
	function (recipe, state)
		if recipe and availableRecipes[recipe] then
			if state then
				craftStartTime = getTickCount()
				setTimer(craftDone, 10000, 1, availableRecipes[recipe].finalItem)
			end

			craftingProcess = false
		end
	end)

function craftDone(item)
	if item[1] and item[2] then
		outputChatBox("#3d7abc[StrongMTA]: #FFFFFFSikeresen elkészítetted a kiválasztott receptet! #32b3ef(" .. getItemName(item[1]) .. ")", 255, 255, 255, true)
		exports.see_hud:showInfobox("success", "Sikeresen elkészítetted a kiválasztott receptet! (" .. getItemName(item[1]) .. ")")
	end
end

local craftingSounds = {}

addEvent("crafting3dSound", true)
addEventHandler("crafting3dSound", getRootElement(),
	function (typ)
		if isElement(craftingSounds[source]) then
			destroyElement(craftingSounds[source])
		end

		if typ then
			craftingSounds[source] = playSound3D("files/sounds/" .. typ .. ".mp3", getElementPosition(source))
			setElementInterior(craftingSounds[source], getElementInterior(source))
			setElementDimension(craftingSounds[source], getElementDimension(source))
			attachElements(craftingSounds[source], source)
			setTimer(
				function (sourceElement)
					craftingSounds[sourceElement] = nil
				end,
			10000, 1, source)
		end
	end)

addEvent("toggleVehicleTrunk", true)
addEventHandler("toggleVehicleTrunk", getRootElement(),
	function (state, vehicle)
		if isElement(vehicle) then
			local soundPath = false

			if state == "open" then
				soundPath = exports.see_vehiclepanel:getDoorOpenSound(getElementModel(vehicle))
			elseif state == "close" then
				soundPath = exports.see_vehiclepanel:getDoorCloseSound(getElementModel(vehicle))
			end

			if soundPath then
				local x, y, z = getElementPosition(vehicle)
				local int = getElementInterior(vehicle)
				local dim = getElementDimension(vehicle)
				local sound = playSound3D(soundPath, x, y, z)

				if isElement(sound) then
					setElementInterior(sound, int)
					setElementDimension(sound, dim)
				end
			end
		end
	end)

addEventHandler("onClientGUIChanged", getRootElement(),
	function ()
		if isElement(stackGUI) and source == stackGUI then
			local stack = tonumber(guiGetText(stackGUI))

			if stack then
				if stack >= 0 then
					stackAmount = tonumber(string.format("%.0f", stack))
				else
					stackAmount = 0
				end
			else
				stackAmount = 0
			end

			if string.find(guiGetText(stackGUI), "i") then
				toggleInventory(false)
			end
		end
	end)

function processNotepadText()
	local chunks = {}

	noteText = {}

	for chunk in utf8.gmatch(notepadText .. "\n", "([^\n]*)\n") do
		table.insert(chunks, chunk)
	end

	for i = 1, #chunks do
		local t2 = {}

		for word in utf8.gmatch(chunks[i], "([^ ]*)") do
			table.insert(t2, word .. " ")
		end

		local str = ""

		for j = 1, #t2 do
			str = str .. t2[j]
			t2[j] = utf8.gsub(t2[j], "\n", "")

			if dxGetTextWidth(str, 1, notepadFont) + 70 > 395 then
				table.insert(noteText, "")
				str = str .. " "
			end
		end

		table.insert(noteText, str)
	end
end

function processNotepadTextEx(text, font)
	local chunks = {}
	local textlines = {}

	for chunk in utf8.gmatch(text .. "\n", "([^\n]*)\n") do
		table.insert(chunks, chunk)
	end

	for i = 1, #chunks do
		local t2 = {}

		for word in utf8.gmatch(chunks[i], "([^ ]*)") do
			table.insert(t2, word .. " ")
		end

		local str = ""

		for j = 1, #t2 do
			str = str .. t2[j]
			t2[j] = utf8.gsub(t2[j], "\n", "")

			if dxGetTextWidth(str, 1, font) + 70 > 395 then
				table.insert(textlines, "")
				str = str .. " "
			end
		end

		table.insert(textlines, str)
	end

	return textlines
end

function canWriteToNotepad()
	if #noteText >= 22 then
		return dxGetTextWidth(noteText[#noteText], 1, notepadFont) < 320
	elseif not utf8.find(noteText[#noteText], " ") then
		return dxGetTextWidth(noteText[#noteText], 1, notepadFont) <= 325
	end

	return true
end

addEventHandler("onClientCharacter", getRootElement(),
	function (char)
		if panelState then
			if renameDetails and utf8.len(renameDetails.text) < 16 then
				renameDetails.text = renameDetails.text .. char
			end
		end

		if notepadState then
			if canWriteToNotepad() then
				notepadText = notepadText .. char
				processNotepadText()
			end
		end
	end, true, "low-99999")

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if panelState then
			if renameDetails then
				cancelEvent()

				if key == "backspace" and press then
					renameDetails.text = utf8.sub(renameDetails.text, 1, utf8.len(renameDetails.text) - 1)
				end
			end

			if currentTab == "crafting" then
				if key == "mouse_wheel_up" then
					if craftListOffset > 0 then
						craftListOffset = craftListOffset - 1
					end
				elseif key == "mouse_wheel_down" then
					if craftListOffset < #craftList - 8 then
						craftListOffset = craftListOffset + 1
					end
				end
			end
		end

		if notepadState then
			cancelEvent()

			if key == "backspace" and press then
				notepadText = utf8.sub(notepadText, 1, utf8.len(notepadText) - 1)

				if 1 > utf8.len(notepadText) then
					noteText = {""}
				else
					processNotepadText()
				end
			end

			if key == "enter" and press then
				if #noteText < 22 then
					notepadText = notepadText .. "\n"
					processNotepadText()
				end
			end
		end
	end)

local deactivateDisabled = false

function disableDeactivateForDriveby()
	deactivateDisabled = true
end

addEventHandler("onClientPlayerWeaponSwitch", getRootElement(),
	function (prev, current)
		if getPedWeapon(localPlayer, current) == 0 then
			if deactivateDisabled then
				deactivateDisabled = false
				return
			end

			deactivateWeapon()
		end
	end)

function deactivateWeapon()
	local weaponInUse = false
	local ammoInUse = false

	for k, v in pairs(itemsTable.player) do
		if v.inUse then
			if isWeaponItem(v.itemId) and not weaponInUse then
				weaponInUse = weaponInUse or v
			elseif isAmmoItem(v.itemId) and not ammoInUse then
				ammoInUse = v
			end
		end
	end

	if weaponInUse then
		local slotId = weaponInUse.slot
		local itemId = itemsTable.player[slotId].itemId

		itemsTable.player[slotId].inUse = false

		triggerServerEvent("takeWeapon", localPlayer)

		if availableItems[itemId] then
			if itemId == 99 then
				exports.see_chat:localActionC(localPlayer, "elrakott egy fényképezőgépet.")
			elseif itemId == 155 then
				if getElementData(localPlayer, "tazerReloadNeeded") then
					exports.see_controls:toggleControl({"fire", "vehicle_fire", "action"}, true)
					setElementData(localPlayer, "tazerReloadNeeded", false)
				end

				exports.see_chat:localActionC(localPlayer, "elrakott egy sokkoló pisztolyt.")

				setElementData(localPlayer, "tazerState", false)
			else
				local itemName = getItemName(itemId)

				if itemsTable.player[slotId].nameTag then
					itemName = itemName .. " (" .. itemsTable.player[slotId].nameTag .. ")"
				end

				exports.see_chat:localActionC(localPlayer, "elrakott egy fegyvert. (" .. itemName .. ")")

				setElementData(localPlayer, "currentWeaponPaintjob", false)

				triggerEvent("movedItemInInv", localPlayer)
			end
		end

		enableWeaponFire(true)

		if ammoInUse then
			itemsTable.player[ammoInUse.slot].inUse = false
		end
	end
end

local fireworkStartTime = false
local fireworkCount = 1

addEvent("playFireworkSound", true)
addEventHandler("playFireworkSound", getRootElement(),
	function (typ)
		local x, y, z = getElementPosition(source)
		local int = getElementInterior(source)
		local dim = getElementDimension(source)
		local sound = playSound3D("files/sounds/" .. typ .. "firework.mp3", x, y, z)

		if isElement(sound) then
			setElementInterior(sound, int)
			setElementDimension(sound, dim)
			setSoundMaxDistance(sound, 50)
		end
	end)

local lastDiceUsage = 0

addEvent("playCardSound", true)
addEventHandler("playCardSound", getRootElement(),
	function ()
		local x, y, z = getElementPosition(source)
		local int = getElementInterior(source)
		local dim = getElementDimension(source)

		local sound = playSound3D("files/sounds/card.mp3", x, y, z)

		if isElement(sound) then
			setElementInterior(sound, int)
			setElementDimension(sound, dim)
		end
	end)

addEvent("playDiceSound", true)
addEventHandler("playDiceSound", getRootElement(),
	function ()
		local x, y, z = getElementPosition(source)
		local int = getElementInterior(source)
		local dim = getElementDimension(source)

		local sound = playSound3D("files/sounds/dice.mp3", x, y, z)

		if isElement(sound) then
			setElementInterior(sound, int)
			setElementDimension(sound, dim)
		end
	end)

local licenseWidth = 0
local licenseHeight = 0
local licensePosX = 0
local licensePosY = 0
local licenseState = false
local licenseData = {}
local licenseRobotoL = false
local licenseLunabar = false
local licenseLunabar2 = false
local licenseType = "identityCard"
local licenseRT = false
local licenseTexture = false
local Fixedsys500c = dxCreateFont("files/fonts/Fixedsys500c.ttf", 16, false, "antialiased")
local hoverRenewLicense = false
local licensePrices = {
	identityCard = 0,--100
	fishingLicense = 200,
	carLicense = 300,
	weaponLicense = 750
}

local rottenEffect = false

addEvent("rottenEffect", true)
addEventHandler("rottenEffect", getRootElement(),
	function (damage)
		rottenEffect = {getTickCount(), damage}
	end)

local lastSpecialItemUse = 0
local lastSpecialItemUse2 = 0
currentItemInUse = false
currentItemRemainUses = false

function useSpecialItem()
	if currentItemInUse then
		if getTickCount() - lastSpecialItemUse >= 5000 then
			local specialItem = specialItems[currentItemInUse.itemId]

			if specialItem then
				if specialItem[1] == "pizza" or specialItem[1] == "kebab" or specialItem[1] == "hamburger" then
					exports.see_chat:localActionC(localPlayer, "evett valamit.")
				elseif specialItem[1] == "beer" or specialItem[1] == "wine" or specialItem[1] == "drink" then
					exports.see_chat:localActionC(localPlayer, "ivott valamit.")

					if specialItem[1] ~= "drink" then
						--addDrunkenLevel(3)
					end
				elseif specialItem[1] == "cigarette" then
					exports.see_chat:localActionC(localPlayer, "szívott egy slukkot.")
				elseif specialItem[1] == "drug" then
					local removedHealth = 6
					local addedArmor = 14
					local nextUseText = "5 másodperc"
					setElementHealth(localPlayer, getElementHealth(localPlayer) - removedHealth) 
					setPedArmor(localPlayer, getPedArmor(localPlayer) + addedArmor)
					exports.see_hud:showInfobox("i", "Kábítószer hatása alatt állsz! Részletek a chatboxban!")
					outputChatBox("#7cc576[Droghatás - Heroin]: #ffffffÉleterő: #32b3ef-" .. removedHealth, 255, 255, 255, true)
					outputChatBox("#7cc576[Droghatás - Heroin]: #ffffffPáncél: #32b3ef" .. addedArmor, 255, 255, 255, true)
					outputChatBox("#7cc576[Droghatás - Heroin]: #ffffffÚjra fogyaszható: #32b3ef" .. nextUseText, 255, 255, 255, true)
					exports.see_chat:localActionC(localPlayer, "belőtt magának egy kis heroint.")
					triggerEvent("vortyvision3_enable", localPlayer, 5, 3)
				end
			end

			lastSpecialItemUse = getTickCount()
			currentItemRemainUses = currentItemRemainUses - 1

			if currentItemRemainUses >= 0 then
				itemsTable.player[currentItemInUse.slot].data1 = (tonumber(itemsTable.player[currentItemInUse.slot].data1) or 0) + 1
				triggerServerEvent("useSpecialItem", localPlayer, currentItemInUse, itemsTable.player[currentItemInUse.slot].data1)
			end

			if currentItemRemainUses == 0 then
				triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", currentItemInUse.dbID)
				triggerServerEvent("detachObject", localPlayer)
				itemsTable.player[currentItemInUse.slot].inUse = false
				currentItemInUse = false
				currentItemRemainUses = false
			end
		else
			outputChatBox("#DC143C[StrongMTA]: #FFFFFFCsak 5 másodpercenként használhatod a tárgyat!", 255, 255, 255, true)
		end
	end
end

local lastHealTick = 0

function useItem(itemId)
	if not itemId then
		return
	end

	if (getElementData(localPlayer, "acc.adminJail") or 0) ~= 0 then
		return
	end

	if getElementData(localPlayer, "cuffed") then
		return
	end

	local slotId = false

	itemId = tonumber(itemId)

	for k, v in pairs(itemsTable.player) do
		if v.dbID == itemId then
			slotId = k
			break
		end
	end

	if not (itemsTable.player[slotId] and itemsTable.player[slotId].amount > 0 and itemsTable.player[slotId].itemId) then
		return
	end

	local item = itemsTable.player[slotId]
	local realItemId = tonumber(item.itemId)

	-- ** Sorsjegyek
	if scratchItems[realItemId] then
		if exports.see_lottery:isScratchTicketOpen() then
			item.inUse = false
		else
			item.inUse = true
		end

		exports.see_lottery:showScratch(realItemId, item.dbID, item.data1, item.data2, item.data3, item.inUse)
	-- ** Telefon
	elseif realItemId == 9 then
		--triggerEvent("openPhone", localPlayer)
		triggerEvent("openPhone", localPlayer, item.data1) 
	-- ** Heroin
	elseif itemId == 60 then 

	-- ** Lottó nyugta
	elseif realItemId == 295 then
		if exports.see_lottery:isLotteryInUse() then
			item.inUse = false
		else
			item.inUse = true
		end

		exports.see_lottery:checkLotteryTicket(item.dbID, item.inUse, item.data1, item.data2, item.data3)
	-- ** Lottószelvény
	elseif realItemId == 294 then
		if exports.see_lottery:isLotteryInUse() then
			item.inUse = false
		else
			item.inUse = true
		end

		exports.see_lottery:openLotteryTicket(item.dbID, item.inUse, item.data2)
	-- ** Gyógyszer
	elseif itemId == 148 then
		if getTickCount() >= lastHealTick then 
			lastHealTick = getTickCount() + 60000

			setElementHealth(localPlayer, getElementHealth(localPlayer) + math.random(25, 50))
			--takeItem(source, "dbID", item.dbID, 1)
			exports.see_chat:localAction(localPlayer, "bevett egy gyógyszert.")

			triggerServerEvent("useItem", localPlayer, itemDbId)
			triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)

			itemsTable.player[slotId] = nil
		else
			exports.see_hud:showInfobox("e", "Csak percenként vehetsz be gyógyszert.")
		end
	-- ** Útlevél
	elseif realItemId == 264 then
		exports.see_borders:togglePassport(item.dbID, item.data1, item.data2, item.data3)
	-- ** Faltörőkos
	elseif realItemId == 115 then
		if exports.see_groups:isPlayerHavePermission(localPlayer, "doorRammer") then
			exports.see_interiors:useDoorRammer()
		else
			outputChatBox("#d75959[StrongMTA]: #ffffffNem használhatod a faltörő kost.", 255, 255, 255, true)
		end
	-- ** Hi-Fi
	elseif realItemId == 150 then
		local nearbyHifi = false
		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)

		for k, v in pairs(getElementsByType("object", getRootElement(), true)) do
			if getElementModel(v) == 2103 then
				local objPosX, objPosY, objPosZ = getElementPosition(v)
				if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, objPosX, objPosY, objPosZ) <= 10 then
					nearbyHifi = true
					break
				end
			end
		end

		if not nearbyHifi then
			triggerServerEvent("useItem", localPlayer, item, false, false)
		else
			outputChatBox("#d75959[StrongMTA]: #ffffffMár van egy rádió a közeledben!", 255, 255, 255, true)
		end
	-- ** Golyó bevizsgálás
	elseif realItemId == 365 then
		-- isElementWithinColShape
		if exports.see_groups:isPlayerHavePermission(localPlayer, "bulletExamine") then
			local datas = split(item.data1, ";")
			local text = "Ismeretlen"

			if #datas == 3 then
				text = getWeaponNameFromIDNew(tonumber(datas[1])):gsub("^%l", string.upper) .. " - #d75959" .. datas[3] .. "#8e8e8e"
			end

			triggerEvent("updateData2", localPlayer, "player", item.dbID, text)
		end
	-- ** Ételek/Italok stb
	elseif specialItems[realItemId] then
		if not currentItemInUse then
			if getTickCount() - lastSpecialItemUse2 >= 5000 then
				lastSpecialItemUse2 = getTickCount()
				item.inUse = true

				currentItemInUse = item
				currentItemRemainUses = specialItems[realItemId][2] - (tonumber(item.data1) or 0)

				triggerServerEvent("useItem", localPlayer, item, true, specialItems[realItemId][1])
			else
				outputChatBox("#DC143C[StrongMTA]: #FFFFFFCsak 5 másodpercenként használhatod a tárgyat!", 255, 255, 255, true)
			end
		else
			itemsTable.player[currentItemInUse.slot].inUse = false
			triggerServerEvent("detachObject", localPlayer)
			currentItemInUse = false
			currentItemRemainUses = false
		end
	-- ** Okmányok
	elseif realItemId == 207 or realItemId == 208 or realItemId == 308 or realItemId == 310 then
		if isElement(licenseRT) then
			destroyElement(licenseRT)
		end

		if isElement(licenseTexture) then
			destroyElement(licenseTexture)
		end

		licenseRT = nil
		licenseTexture = nil

		for k, v in pairs(itemsTable.player) do
			if (v.itemId == 207 or v.itemId == 208 or v.itemId == 308 or v.itemId == 310) and v.inUse then
				itemsTable.player[v.slot].inUse = false

				if v.itemId == 207 then
					exports.see_chat:localActionC(localPlayer, "elrakta a személyigazolványt.")
				elseif v.itemId == 208 then
					exports.see_chat:localActionC(localPlayer, "elrakta a jogosítványt.")
				elseif v.itemId == 308 then
					exports.see_chat:localActionC(localPlayer, "elrakta a fegyverengedélyt.")
				elseif v.itemId == 310 then
					exports.see_chat:localActionC(localPlayer, "elrakta a horgászengdélyt.")
				end
			end
		end

		if isElement(licenseRobotoL) then
			destroyElement(licenseRobotoL)
		end

		if isElement(licenseLunabar) then
			destroyElement(licenseLunabar)
		end

		if isElement(licenseLunabar2) then
			destroyElement(licenseLunabar2)
		end

		if not licenseState or realItemId ~= licenseData.realItemId then
			local data = split(item.data1, ";")
			local iscopy = data[3] and data[3] == "iscopy"

			licenseData = {
				characterId = data[1],
				characterName = data[2] or "N/A",
				skinId = item.data2 or 1,
				expireDate = item.data3 or "N/A",
				itemId = item.dbID,
				realItemId = item.itemId,
				iscopy = iscopy
			}

			licenseWidth, licenseHeight = 408, 248
			licensePosX = screenX / 2 - licenseWidth / 2
			licensePosY = screenY / 2 - licenseHeight / 2

			if iscopy then
				licenseRT = dxCreateRenderTarget(410, 410, true)
				licenseTexture = dxCreateShader("files/monochrome.fx")
				dxSetShaderValue(licenseTexture, "screenSource", licenseRT)

				licensePosX = 0
				licensePosY = 0
				licenseData.iscopypos = {data[4], data[5], data[6]}
			end

			licenseRobotoL = dxCreateFont("files/fonts/RobotoL.ttf", 20, false, "antialiased")
			licenseLunabar = dxCreateFont("files/fonts/lunabar.ttf", 44, false, "antialiased")
			licenseLunabar2 = dxCreateFont("files/fonts/lunabar.ttf", 32, false, "antialiased")

			item.inUse = true

			if realItemId == 207 then
				licenseType = "identityCard"
				licenseState = true
				exports.see_chat:localActionC(localPlayer, "megnézi a személyigazolványt.")
			elseif realItemId == 208 then
				licenseType = "carLicense"
				licenseState = true
				exports.see_chat:localActionC(localPlayer, "megnézi a jogosítványt.")
			elseif realItemId == 308 then
				licenseType = "weaponLicense"
				licenseState = true
				exports.see_chat:localActionC(localPlayer, "megnézi a fegyverengedélyt.")
			elseif realItemId == 310 then
				licenseType = "fishingLicense"
				licenseState = true
				exports.see_chat:localActionC(localPlayer, "megnézi a horgászengedélyt.")
			end
		else
			licenseState = false
			licenseData = {}
		end
	-- ** Jegyzet
	elseif realItemId == 367 then
		if not notepadState then
			if not noteState then
				noteState = slotId
				item.inUse = true

				showCursor(true)

				notepadFont = dxCreateFont("files/fonts/hand.ttf", 16, false, "antialiased")
				notepadText = item.data1

				noteIsCopy = tonumber(item.data3) == 1
				noteText = {""}

				if utf8.len(notepadText) > 0 then
					processNotepadText()
				end

				exports.see_chat:localActionC(localPlayer, "elővesz egy jegyzetet.")
			elseif noteState == slotId then
				showCursor(false)

				item.inUse = false
				notepadState = false
				notepadText = false
				noteText = false
				noteState = false

				exports.see_chat:localActionC(localPlayer, "elrak egy jegyzetet.")

				if isElement(notepadFont) then
					destroyElement(notepadFont)
				end

				notepadFont = nil
			end
		end
	-- ** Jegyzetfüzet
	elseif realItemId == 366 then
		if not isHavePen() then
			exports.see_hud:showInfobox("e", "Nincs tollad!")
			return
		end

		if not noteState then
			if not notepadState then
				notepadState = slotId
				item.inUse = true

				showCursor(true)

				notepadFont = dxCreateFont("files/fonts/hand.ttf", 16, false, "antialiased")
				notepadText = ""

				noteIsCopy = false
				noteText = {""}

				exports.see_chat:localActionC(localPlayer, "elővesz egy jegyzetfüzetet.")
			elseif notepadState == slotId then
				showCursor(false)

				item.inUse = false
				notepadState = false
				notepadText = false
				noteText = false
				noteState = false

				exports.see_chat:localActionC(localPlayer, "elrak egy jegyzetfüzetet.")

				if isElement(notepadFont) then
					destroyElement(notepadFont)
				end

				notepadFont = nil
			end
		end
	-- ** Blueprint
	elseif realItemId == 299 then
		if item.data1 then
			if not availableRecipes[tonumber(item.data1)] then
				item.data1 = 1
			end

			triggerServerEvent("useItem", localPlayer, item, false, false)
		end
	-- ** Petárda
	elseif realItemId == 165 or realItemId == 166 then
		if fireworkStartTime then
			if getRealTime().timestamp - fireworkStartTime < 20 then
				exports.see_hud:showInfobox("error", "Csak fél percenként használhatod a petárdákat.")
				return
			end
		end

		triggerServerEvent("useItem", localPlayer, item, false, getElementsByType("player", getRootElement(), true))

		fireworkStartTime = getRealTime().timestamp
		fireworkCount = 1

		setTimer(
			function ()
				if fireworkCount == 1 then
					exports.see_chat:localActionC(localPlayer, "elővesz egy petárdát.")
				elseif fireworkCount == 2 then
					exports.see_chat:localActionC(localPlayer, "meggyújtja a petárdát")
				elseif fireworkCount == 3 then
					exports.see_chat:localActionC(localPlayer, "eldobja a petárdát kicsit messzebb tőle.")
				elseif fireworkCount == 4 then
					exports.see_chat:sendLocalDoC(localPlayer, "Petárda sistergés.")
				elseif fireworkCount == 5 then
					exports.see_chat:sendLocalDoC(localPlayer, "Petárda robbanás")
				end

				fireworkCount = fireworkCount + 1
			end,
		600, 5)
	-- ** Item átnevezés
	elseif realItemId == 315 then
		if not renameProcess then
			renameProcess = slotId
			itemsTable.player[slotId].inUse = true
		end
	-- ** Dobókocka & Kártyapakli
	elseif realItemId == 204 or realItemId == 205 then
		if getTickCount() - lastDiceUsage >= 5000 then
			lastDiceUsage = getTickCount()
			triggerServerEvent("useItem", localPlayer, item, false, getElementsByType("player", root, true))
		else
			outputChatBox("#DC143C[StrongMTA]: #FFFFFFCsak 5 másodpercenként használhatod a tárgyat!", 255, 255, 255, true)
		end
	-- ** Fegyverek & töltények
	elseif isWeaponItem(realItemId) or isAmmoItem(realItemId) then
		local weaponInUse = false
		local ammoInUse = false

		for k, v in pairs(itemsTable.player) do
			if v.inUse then
				if isWeaponItem(v.itemId) and not weaponInUse then
					weaponInUse = v
				elseif isAmmoItem(v.itemId) and not ammoInUse then
					ammoInUse = v
				end
			end
		end

		if isWeaponItem(realItemId) then
			local pedtask = getPedSimplestTask(localPlayer)

			--if pedtask ~= "TASK_SIMPLE_PLAYER_ON_FOOT" and pedtask ~= "TASK_SIMPLE_CAR_DRIVE" then
			--	return
			--end

			if getPedControlState("fire") then
				outputChatBox("#3d7abc[StrongMTA]: #ffffffAmíg nyomva tartod a lövés gombot, nem veheted elő a fegyvert.", 255, 255, 255, true)
				return
			end

			if not weaponInUse then
				item.inUse = true
				weaponInUse = item

				local haveAmmo = false

				if getItemAmmoID(weaponInUse.itemId) > 0 then
					for k, v in pairs(itemsTable.player) do
						if isAmmoItem(v.itemId) and not v.inUse and getItemAmmoID(weaponInUse.itemId) == v.itemId then
							ammoInUse = v
							v.inUse = true
							haveAmmo = true
							break
						end
					end
				end

				if (not haveAmmo and getItemAmmoID(weaponInUse.itemId) == weaponInUse.itemId) or getItemAmmoID(weaponInUse.itemId) == -1 then
					ammoInUse = weaponInUse
					haveAmmo = true
				end

				local weaponId = getItemWeaponID(weaponInUse.itemId)

				if haveAmmo then
					if weaponInUse.itemId == 155 then
						triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, weaponId, 99999)
					elseif weaponInUse.itemId == ammoInUse.itemId then
						triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, weaponId, ammoInUse.amount)
					else
						triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, weaponId, ammoInUse.amount + 1)
					end
				else
					triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, weaponId, 1)
					enableWeaponFire(false)
				end

				if availableItems[weaponInUse.itemId] then
					if weaponInUse.itemId == 99 then
						exports.see_chat:localActionC(localPlayer, "elővett egy fényképezőgépet.")
					elseif weaponInUse.itemId == 155 then
						exports.see_chat:localActionC(localPlayer, "elővett egy sokkoló pisztolyt.")
						setElementData(localPlayer, "tazerState", true)
					else
						local itemName = ""

						if availableItems[weaponInUse.itemId] then
							itemName = getItemName(weaponInUse.itemId)

							if weaponInUse.nameTag then
								itemName = " (" .. itemName .. " (" .. weaponInUse.nameTag .. "))"
							else
								itemName = " (" .. itemName .. ")"
							end
						end

						exports.see_chat:localActionC(localPlayer, "elővett egy fegyvert." .. itemName)

						setElementData(localPlayer, "currentWeaponDbID", {weaponInUse.dbID, weaponId}, false)
						setElementData(localPlayer, "currentWeaponSerial", "W" .. (tonumber(weaponInUse.serial) or 0) .. (serialItems[weaponInUse.itemId] or "-"))

						if weaponSkins[weaponInUse.itemId] then
							setElementData(localPlayer, "currentWeaponPaintjob", {weaponSkins[weaponInUse.itemId], weaponId})
						end

						triggerEvent("movedItemInInv", localPlayer)
					end
				end
			else
				if weaponInUse.dbID == itemId then
					deactivateWeapon()
				end
			end
		elseif isAmmoItem(realItemId) then
			if weaponInUse then
				if not ammoInUse then
					if getItemAmmoID(weaponInUse.itemId) == realItemId then
						enableWeaponFire(true)

						triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), item.amount + 1)

						item.inUse = true
					end
				else
					if getItemWeaponID(weaponInUse.itemId) and ammoInUse.dbID == itemId then
						enableWeaponFire(false)

						triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), 1)

						item.inUse = false
					end
				end
			end
		end
	else
		triggerServerEvent("useItem", localPlayer, item, false, false)
	end
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		if rottenEffect then
			local now = getTickCount()
			local elapsedTime = now - rottenEffect[1]
			local progress = elapsedTime / 750

			local alpha = interpolateBetween(
				0, 0, 0,
				150 * rottenEffect[2] + 55, 0, 0,
				progress, "InQuad")

			if progress - 1 > 0 then
				alpha = interpolateBetween(
					150 * rottenEffect[2] + 55, 0, 0,
					0, 0, 0,
					progress - 1, "OutQuad")
			end

			if progress > 2 then
				rottenEffect = false
			end

			dxDrawImage(0, 0, screenX, screenY, "files/vin.png", 0, 0, 0, tocolor(20, 100, 40, alpha))
		end

		if notepadState or noteState then
			local cx, cy = getCursorPosition()

			if cx and cy then
				cx, cy = cx * screenX, cy * screenY
			else
				cx, cy = -1, -1
			end

			local sx, sy = 399, 527
			local x, y = math.floor(screenX / 2 - sx / 2), math.floor(screenY / 2 - sy / 2)

			if noteIsCopy then
				dxDrawImage(x, y, sx, sy, "files/pagecopy.png")
			else
				dxDrawImage(x, y, sx, sy, "files/page.png")
			end

			if notepadState then
				dxDrawRectangle(x, y + 535, 150, 32, tocolor(0, 0, 0, 150))
				dxDrawRectangle(x + 4, y + 535 + 4, 142, 24, tocolor(215, 89, 89, 160))

				dxDrawRectangle(x + sx - 150, y + 535, 150, 32, tocolor(0, 0, 0, 150))
				dxDrawRectangle(x + sx - 150 + 4, y + 535 + 4, 142, 24, tocolor(61, 122, 188, 160))

				if cx >= x and cx <= x + 150 and cy >= y + 535 and cy <= y + 535 + 32 then
					dxDrawRectangle(x + 4, y + 535 + 4, 142, 24, tocolor(215, 89, 89, 160))

					if getKeyState("mouse1") then
						showCursor(false)

						itemsTable.player[notepadState].inUse = false
						notepadState = false
						notepadText = false
						noteText = false
						noteState = false

						exports.see_chat:localActionC(localPlayer, "elrak egy jegyzetfüzetet.")

						if isElement(notepadFont) then
							destroyElement(notepadFont)
						end

						notepadFont = nil

						return
					end
				elseif cx >= x + sx - 150 and cx <= x + sx and cy >= y + 535 and cy <= y + 535 + 32 then
					dxDrawRectangle(x + sx - 150 + 4, y + 535 + 4, 142, 24, tocolor(61, 122, 188, 160))

					if getKeyState("mouse1") then
						showCursor(false)

						itemsTable.player[notepadState].inUse = false
						notepadState = false
						noteText = false
						noteState = false

						if isHavePen() then
							exports.see_chat:localActionC(localPlayer, "megír egy jegyzetet.")

							penSetData()
							notepadSetData()

							local str = split(notepadText:gsub("\n", " "), " ")

							triggerServerEvent("äĐĐÍÄ<", localPlayer, localPlayer, 367, 1, false, notepadText, utf8.sub((str[1] or "") .. " " .. (str[2] or "") .. " " .. (str[3] or ""), 1, 20) .. "...")
						else
							exports.see_hud:showInfobox("e", "Nincs tollad!")
						end

						notepadText = false

						if isElement(notepadFont) then
							destroyElement(notepadFont)
						end

						notepadFont = nil

						return
					end
				end

				dxDrawText("Mégsem", x, y + 535, x + 150, y + 535 + 32, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")
				dxDrawText("Megírás", x + sx - 150, y + 535, x + sx, y + 535 + 32, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")
			else
				dxDrawRectangle(x, y + 535, sx, 32, tocolor(0, 0, 0, 150))
				dxDrawRectangle(x + 4, y + 535 + 4, sx - 8, 24, tocolor(215, 89, 89, 160))

				if cx >= x and cx <= x + sx and cy >= y + 535 and cy <= y + 535 + 32 then
					dxDrawRectangle(x + 4, y + 535 + 4, sx - 8, 24, tocolor(215, 89, 89, 160))

					if getKeyState("mouse1") then
						showCursor(false)

						itemsTable.player[noteState].inUse = false
						notepadState = false
						notepadText = false
						noteText = false
						noteState = false

						exports.see_chat:localActionC(localPlayer, "elrak egy jegyzetet.")

						if isElement(notepadFont) then
							destroyElement(notepadFont)
						end

						notepadFont = nil

						return
					end
				end

				dxDrawText("Bezárás", x, y + 535, x + sx, y + 535 + 32, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")
			end

			if notepadState and getTickCount() - notepadCursorChange > 500 then
				notepadCursorChange = getTickCount()
				notepadCursorState = not notepadCursorState
			end

			for i = 1, 23 do
				local y2 = y + 40

				if noteIsCopy then
					dxDrawLine(x + 67, y2 + 22 * (i - 2) - 1, x + sx, y2 + 22 * (i - 2) - 1, tocolor(110, 110, 110))
				else
					dxDrawLine(x + 67, y2 + 22 * (i - 2) - 1, x + sx, y2 + 22 * (i - 2) - 1, tocolor(0, 15, 200, 185))
				end

				if noteText[i] then
					if noteIsCopy then
						dxDrawText(noteText[i], x + 70, 0, x + sx, y2 + 22 * (i - 1) + 5, tocolor(77, 77, 77), 1, notepadFont, "left", "bottom", true)
					else
						dxDrawText(noteText[i], x + 70, 0, x + sx, y2 + 22 * (i - 1) + 5, tocolor(0, 15, 85, 185), 1, notepadFont, "left", "bottom", true)
					end

					if notepadState and i == #noteText and notepadCursorState then
						local textWidth = dxGetTextWidth(noteText[i], 1, notepadFont) - 2.5

						dxDrawLine(x + 70 + textWidth, y2 + 22 * (i - 2) - 1 + 3, x + 70 + textWidth, y2 + 22 * (i - 1) - 1 - 1, tocolor(0, 15, 85), 2)
					end
				end
			end
		end

		if licenseState then
			local theX = screenX / 2
			local theY = screenY / 2

			if licenseData.iscopy then
				dxSetRenderTarget(licenseRT, true)
				theX, theY = 280 / 2, 372 / 2
			end

			local namePosX = licensePosX + 50 + 126
			local namePosY = licensePosY + 76
			local addressPosX = licensePosX + 65 + 126
			local addressPosY = licensePosY + 76 + 23 + 2
			local idPosX = licensePosX + 80 + 126
			local idPosY = addressPosY + 23
			local expirePosX = licensePosX + 100 + 126
			local expirePosY = idPosY + 23 + 2
			local signaturePosX = licensePosX + 15
			local signaturePosY = licensePosY + 190
			local renewButtonY = licenseHeight

			if licenseType == "identityCard" then
				if licenseData then
					dxDrawImage(licensePosX, licensePosY, licenseWidth, licenseHeight, ":see_regoffice/files/bg.png")
					dxDrawText(licenseData.characterName:gsub("_", " "), namePosX, namePosY, 0, 0, tocolor(0, 0, 0, 255), 0.5, licenseRobotoL)
					dxDrawText("Las Venturas", addressPosX, addressPosY, 0, 0, tocolor(255, 255, 255), 0.5, licenseRobotoL)
					dxDrawText(" " .. licenseData.itemId, idPosX, idPosY, 0, 0, tocolor(255, 255, 255), 0.5, licenseRobotoL)
					dxDrawText(licenseData.expireDate, expirePosX, expirePosY, 0, 0, tocolor(255, 255, 255), 0.5, licenseRobotoL)
					dxDrawText(licenseData.characterName:gsub("_", " "), signaturePosX, signaturePosY, 0, 0, tocolor(255, 255, 255), 0.5, licenseLunabar)

					if fileExists(":see_binco/files/skins/" .. licenseData.skinId .. ".png") then
						dxDrawRectangle(licensePosX + 17, licensePosY + 69, 101, 101, tocolor(200, 200, 200))
						dxDrawImage(licensePosX + 17, licensePosY + 69, 101, 101, ":see_binco/files/skins/" .. licenseData.skinId .. ".png")
					end
				end
			elseif licenseType == "carLicense" then
				if licenseData then
					dxDrawImage(licensePosX, licensePosY, licenseWidth, licenseHeight, ":see_regoffice/files/car.png")
					dxDrawText(licenseData.characterName:gsub("_", " "), licensePosX + 295, licensePosY + 186, licensePosX + 378, licensePosY + 220, tocolor(0, 0, 0, 225), 0.5, licenseLunabar, "center", "center")

					local str = "Név: " .. licenseData.characterName:gsub("_", " ") .. "\n"
					str = str .. "Lakhely: Las Venturas\n"
					str = str .. "Azonosító: "  .. licenseData.itemId .. "\n"
					str = str .. "Érvényesség: " .. licenseData.expireDate .. "\n"

					dxDrawText(str, licensePosX + 132, licensePosY + 69, 0, licensePosY + 69 + 101, tocolor(0, 0, 0), 0.5, licenseRobotoL, "left", "center")

					if fileExists(":see_binco/files/skins/" .. licenseData.skinId .. ".png") then
						dxDrawRectangle(licensePosX + 17, licensePosY + 69, 101, 101, tocolor(200, 200, 200))
						dxDrawImage(licensePosX + 17, licensePosY + 69, 101, 101, ":see_binco/files/skins/" .. licenseData.skinId .. ".png")
					end
				end
			elseif licenseType == "weaponLicense" then
				if licenseData then
					dxDrawImage(licensePosX, licensePosY, licenseWidth, licenseHeight, ":see_regoffice/files/weapon.png")
					dxDrawText(licenseData.characterName:gsub("_", " "), licensePosX + 295, licensePosY + 186, licensePosX + 378, licensePosY + 220, tocolor(0, 0, 0, 225), 0.5, licenseLunabar, "center", "center")

					local str = "Név: " .. licenseData.characterName:gsub("_", " ") .. "\n"
					str = str .. "Lakhely: Las Venturas\n"
					str = str .. "Azonosító: "  .. licenseData.itemId .. "\n"
					str = str .. "Érvényesség: " .. licenseData.expireDate .. "\n"

					dxDrawText(str, licensePosX + 132, licensePosY + 69, 0, licensePosY + 69 + 101, tocolor(0, 0, 0), 0.5, licenseRobotoL, "left", "center")

					if fileExists(":see_binco/files/skins/" .. licenseData.skinId .. ".png") then
						dxDrawRectangle(licensePosX + 17, licensePosY + 69, 101, 101, tocolor(200, 200, 200))
						dxDrawImage(licensePosX + 17, licensePosY + 69, 101, 101, ":see_binco/files/skins/" .. licenseData.skinId .. ".png")
					end
				end
			elseif licenseType == "fishingLicense" then
				if licenseData then
					local x = theX - 140
					local y = theY - 186

					dxDrawImage(x, y, 280, 373, ":see_regoffice/files/fishing.png")
					dxDrawText("Név: " .. licenseData.characterName:gsub("_", " "), x + 22, y + 204, 0, y + 241, tocolor(0, 0, 0, 225), 0.5, Fixedsys500c, "left", "center")
					dxDrawText("Terület: " .. licenseData.skinId, x + 22, y + 242, 0, y + 273, tocolor(0, 0, 0, 225), 0.5, Fixedsys500c, "left", "center")
					dxDrawText("Érvényesség: " .. licenseData.expireDate, x + 22, y + 274, 0, y + 306, tocolor(0, 0, 0, 225), 0.5, Fixedsys500c, "left", "center")
					dxDrawText(licenseData.characterName:gsub("_", " "), x + 80, y + 358, x + 268, y + 370, tocolor(20, 100, 200, 225), 0.75, licenseLunabar2, "center", "bottom")

					renewButtonY = 340
				end
			end

			hoverRenewLicense = false

			if licenseData.iscopy then
				dxSetRenderTarget()

				local x = screenX / 2 - 400
				local y = screenY / 2 - 250

				dxDrawRectangle(x, y, 800, 500, tocolor(255, 255, 255))
				dxDrawImage(x + licenseData.iscopypos[1], y + licenseData.iscopypos[2], 410, 410, licenseTexture, -licenseData.iscopypos[3], 210, 210)
				dxDrawImage(x, y, 800, 500, "files/paper.png")
			else
				local px, py, pz = getElementPosition(localPlayer)
				local dist = getDistanceBetweenPoints3D(356.296875, 178.0537109375, 1008.3762207031, px, py, pz)

				if dist <= 2.5 and getElementInterior(localPlayer) == 3 and getElementDimension(localPlayer) == 13 then
					local cx, cy = getCursorPosition()

					if cx and cy then
						cx, cy = cx * screenX, cy * screenY
					end

					local x = theX - 74
					local y = licensePosY + renewButtonY

					dxDrawRectangle(x, y, 150, 32, tocolor(0, 0, 0, 200))

					if cx and cx >= x and cx <= x + 150 and cy >= y and cy <= y + 32 then
						hoverRenewLicense = true
					end

					if hoverRenewLicense then
						dxDrawRectangle(x + 4, y + 4, 142, 24, tocolor(61, 122, 188, 255))
					else
						dxDrawRectangle(x + 4, y + 4, 142, 24, tocolor(61, 122, 188, 175))
					end

					dxDrawText("Megújítás (" .. math.floor(licensePrices[licenseType] * 0.75) .. " $)", x, y, x + 150, y + 32, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")
				end
			end
		end
	end)

addEvent("failedToMoveItem", true)
addEventHandler("failedToMoveItem", getRootElement(),
	function (movedSlot, hoverSlot, amount)
		if movedSlot then
			itemsTable[itemsTableState][movedSlot] = itemsTable[itemsTableState][hoverSlot]
			itemsTable[itemsTableState][movedSlot].slot = movedSlot
			itemsTable[itemsTableState][hoverSlot] = nil
		elseif stackAmount > 0 then
			itemsTable[itemsTableState][movedSlot].amount = amount
		end
	end)

local showItemTick = 0
local lastPlaceNote = 0
local copierEffect = {}

function getPositionFromElementOffset(element, x, y, z)
	local m = getElementMatrix(element)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

addEvent("copierEffect", true)
addEventHandler("copierEffect", getRootElement(),
	function ()
		local x, y, z = getElementPosition(source)
		local x2, y2, z2 = getPositionFromElementOffset(source, 0.2, -0.25, 0)
		local int = getElementInterior(source)
		local dim = getElementDimension(source)

		copierEffect[source] = {}
		copierEffect[source][1] = playSound3D("files/sounds/copy.mp3", x, y, z)
		copierEffect[source][2] = createObject(1215, x2, y2, z2 + 0.8)

		setElementInterior(copierEffect[source][1], int)
		setElementDimension(copierEffect[source][1], dim)

		setElementInterior(copierEffect[source][2], int)
		setElementDimension(copierEffect[source][2], dim)
		setObjectScale(copierEffect[source][2], 0)

		x2, y2, z2 = getPositionFromElementOffset(source, 0.9, -0.25, 0)

		moveObject(copierEffect[source][2], 3080, x2, y2, z2 + 0.8)

		setTimer(
			function (sourceElement)
				if isElement(copierEffect[sourceElement][2]) then
					destroyElement(copierEffect[sourceElement][2])
				end
			end,
		3080, 1, source)

		setTimer(
			function (sourceElement)
				copierEffect[sourceElement] = nil
			end,
		7100, 1, source)
	end)


local networkState = true
local wasFrozen = false
function getNetworkState()
	return networkState
end

function network_disableAll()
	networkState = false
	outputConsole("[Network] Disabled all.")
	outputDebugString("[Network] Disabled all.")
end

function network_enableAll()
	networkState = true
	outputConsole("[Network] Enabled all.")
	outputDebugString("[Network] Enabled all.")
end

addEventHandler("onClientPreRender", root, function()
	local loss = getNetworkStats()["packetlossLastSecond"]
	if loss > 5 and not isTransferBoxActive() then
		if networkState then
			networkState = false
			network_disableAll()
		end
	else
		if not networkState then
			networkState = true
			network_enableAll()
		end
	end
end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, hitElement)
		-- ** Okmány megújítás

		if hoverRenewLicense then
			if button == "left" and state == "up" then
				triggerServerEvent("tryToRenewLicense", localPlayer, licenseData.itemId, math.floor(licensePrices[licenseType] * 0.75), licenseData.realItemId)

				licenseState = false
				licenseData = {}

				if isElement(licenseRT) then
					destroyElement(licenseRT)
				end

				if isElement(licenseTexture) then
					destroyElement(licenseTexture)
				end

				licenseRT = nil
				licenseTexture = nil

				for k, v in pairs(itemsTable.player) do
					if (v.itemId == 207 or v.itemId == 208 or v.itemId == 308 or v.itemId == 310) and v.inUse then
						itemsTable.player[v.slot].inUse = false

						if v.itemId == 207 then
							exports.see_chat:localActionC(localPlayer, "elrakta a személyigazolványt.")
						elseif v.itemId == 208 then
							exports.see_chat:localActionC(localPlayer, "elrakta a jogosítványt.")
						elseif v.itemId == 308 then
							exports.see_chat:localActionC(localPlayer, "elrakta a fegyverengedélyt.")
						elseif v.itemId == 310 then
							exports.see_chat:localActionC(localPlayer, "elrakta a horgászengdélyt.")
						end
					end
				end

				if isElement(licenseRobotoL) then
					destroyElement(licenseRobotoL)
				end

				if isElement(licenseLunabar) then
					destroyElement(licenseLunabar)
				end

				if isElement(licenseLunabar2) then
					destroyElement(licenseLunabar2)
				end

				licenseRobotoL = nil
				licenseLunabar = nil
				licenseLunabar2 = nil
			end
		end

		-- ** Item átnevezés
		if renameDetails and renameProcess then
			if renameDetails.activeButton and state == "up" then
				if renameDetails.activeButton == "ok" then
					if renameDetails.text == renameDetails.currentNametag then
						exports.see_hud:showInfobox("e", "Nem lehet ugyan az a név, mint volt!")
						return
					end

					if utf8.len(renameDetails.text) >= 1 then
						triggerServerEvent("tryToRenameItem", localPlayer, renameDetails.text, renameDetails.renameItemId, itemsTable.player[renameProcess].dbID)
						renameProcess = false
						setCursorAlpha(255)
					else
						exports.see_hud:showInfobox("e", "Nem lehet üres a név!")
						return
					end
				end

				renameDetails = false
			end

			return
		end

		if renameProcess and panelState then
			if state == "up" then
				local hoverSlotId, slotPosX, slotPosY = findSlot(absX, absY)

				if hoverSlotId and itemsTable.player[hoverSlotId] then
					local item = itemsTable.player[hoverSlotId]

					if item.amount ~= 1 then
						exports.see_hud:showInfobox("e", "Stackelt itemet nem lehet elnevezni.")
						return
					end

					if item.data3 == "duty" then
						exports.see_hud:showInfobox("e", "Duty itemet nem lehet elnevezni.")
						return
					end

					if item.itemId == 61 or item.itemId == 62 or item.itemId == 63 or item.itemId == 150 then
						exports.see_hud:showInfobox("e", "Ezt az itemet nem lehet elnevezni.")
						return
					end

					if item.itemId ~= 315 then
						renameDetails = {
							x = absX,
							y = absY,
							text = item.nameTag or "",
							cursorChange = getTickCount(),
							cursorState = true,
							activeButton = false,
							renameItemId = item.dbID,
							currentNametag = item.nameTag or ""
						}
					else
						itemsTable.player[renameProcess].inUse = false
						renameProcess = false
						renameDetails = false
						setCursorAlpha(255)
					end
				elseif hoverTab and hoverTab ~= currentTab then
					if hoverTab ~= "crafting" and not renameDetails then
						currentTab = hoverTab
						playSound("files/sounds/tab.mp3")
					end
				else
					itemsTable.player[renameProcess].inUse = false
					renameProcess = false
					renameDetails = false
					setCursorAlpha(255)
				end
			end

			return
		end

		-- ** Inventory
		if button == "left" then
			if not panelState then
				return
			end

			-- ** Inventory mozgatás
			if panelIsMoving and state == "up" then
				panelIsMoving = false
				moveDifferenceX, moveDifferenceY = 0, 0
			end

			if state == "down" then
				-- ** Inventory mozgatás
				if absX >= panelPosX and absX <= panelPosX + panelWidth - 80 and absY >= panelPosY and absY <= panelPosY + 25 then
					moveDifferenceX = absX - panelPosX
					moveDifferenceY = absY - panelPosY
					panelIsMoving = true
					return
				end

				-- ** Tabok
				if itemsTableState == "player" then
					if hoverTab and hoverTab ~= currentTab then
						currentTab = hoverTab

						playSound("files/sounds/tab.mp3")

						if currentTab == "crafting" then
							checkRecipeHaveItem()
						end
					end
				end

				-- ** Craftolás
				if currentTab == "crafting" and hoverCraftButton and not craftingProcess then
					playSound("files/sounds/craftstart.mp3")

					if not playerRecipes[selectedRecipe] and not defaultRecipes[selectedRecipe] then
						if not availableRecipes[selectedRecipe].requiredJob then
							outputChatBox("#DC143C[StrongMTA]: #FFFFFFEzt a receptet még nem tanultad meg!", 255, 255, 255, true)
							return
						end
					end

					if availableRecipes[selectedRecipe].requiredJob then
						if availableRecipes[selectedRecipe].requiredJob ~= currentJob then
							exports.see_hud:showInfobox("e", "Csak '" .. exports.see_jobhandler:getJobName(availableRecipes[selectedRecipe].requiredJob) .. "' munkával készítheted el ezt a receptet!")
							return
						end
					end

					if availableRecipes[selectedRecipe].requiredPermission then
						if not exports.see_groups:isPlayerHavePermission(localPlayer, availableRecipes[selectedRecipe].requiredPermission) then
							exports.see_hud:showInfobox("e", "Csak a megfelelő csoport tagjaként készítheted el ezt a receptet!")
							return
						end
					end

					if availableRecipes[selectedRecipe].suitableColShapes then
						local colshape = false

						for k, v in pairs(availableRecipes[selectedRecipe].suitableColShapes) do
							if currentCraftingPosition and currentCraftingPosition == k then
								colshape = true
								break
							end
						end

						if not colshape then
							exports.see_hud:showInfobox("e", "Csak a megfelelő helyszínen készítheted el ezt a receptet!")
							return
						end
					end

					if not canCraftTheRecipe then
						return
					end

					local takeItems = {}

					for y = 1, 3 do
						for k, v in pairs(availableRecipes[selectedRecipe].items[y]) do
							if v then
								table.insert(takeItems, v)
							end
						end
					end

					craftingProcess = true
					triggerServerEvent("requestCrafting", localPlayer, selectedRecipe, takeItems, getElementsByType("player", getRootElement(), true))
					exports.see_chat:localActionC(localPlayer, "barkácsol egy " .. availableRecipes[selectedRecipe].name .. "-t.")
				end

				-- ** Craft kategória választás
				if currentTab == "crafting" and hoverRecipeCategory then
					collapsedCategories[hoverRecipeCategory] = not collapsedCategories[hoverRecipeCategory]
					craftList = {}

					for i = 1, #craftRecipes do
						if craftRecipes[i].name ~= "null" then
							local category = craftRecipes[i].category

							if not craftList[category] then
								craftList[category] = true

								table.insert(craftList, {"category", category, collapsedCategories[category]})

								lastCraftCategory = #craftList
							end

							if craftList[lastCraftCategory][3] then
								table.insert(craftList, {"recipe", craftRecipes[i].id})
							else
								if selectedRecipe == craftRecipes[i].id then
									selectedRecipe = false
									applyRecipe(false)
								end
							end
						end
					end

					if #craftList > 8 then
						if craftListOffset > #craftList - 8 then
							craftListOffset = #craftList - 8
						end
					else
						craftListOffset = 0
					end
				end

				-- ** Craft recept választás
				if currentTab == "crafting" and hoverRecipe and hoverRecipe ~= selectedRecipe and not craftingProcess and not craftStartTime then
					selectedRecipe = hoverRecipe
					applyRecipe(availableRecipes[selectedRecipe].items)
					playSound("files/sounds/select.mp3")
				end

				-- ** Item mozgatás
				local hoverSlotId, slotPosX, slotPosY = findSlot(absX, absY)

				if hoverSlotId and itemsTable[itemsTableState][hoverSlotId] then
					if currentTab == "crafting" and itemsTableState ~= "vehicle" and itemsTableState ~= "object" then
						return
					end

					if not itemsTable[itemsTableState][hoverSlotId].inUse then
						haveMoving = true
						movedSlotId = hoverSlotId
						moveDifferenceX = absX - slotPosX
						moveDifferenceY = absY - slotPosY
						playSound("files/sounds/select.mp3")
					else
						outputChatBox("#DC143C[StrongMTA]: #FFFFFFHasználatban lévő itemet nem mozgathatsz!", 255, 255, 255, true)
					end
				end

				return
			end

			if not movedSlotId then
				movedSlotId, haveMoving = false, false
				return
			end

			local hoverSlotId = findSlot(absX, absY)
			local movedItem = itemsTable[itemsTableState][movedSlotId]

			if absX >= panelPosX + panelWidth / 2 - 32 and absY >= panelPosY - 5 - 64 and absX <= panelPosX + panelWidth / 2 + 32 and absY <= panelPosY - 5 then
				if getTickCount() - showItemTick > 5500 then
					showItemTick = getTickCount()

					triggerServerEvent("showTheItem", localPlayer, movedItem, getElementsByType("player", getRootElement(), true))

					if availableItems[movedItem.itemId] then
						exports.see_chat:localActionC(localPlayer, "felmutat egy tárgyat: " .. getItemName(movedItem.itemId) .. ".")
					else
						exports.see_chat:localActionC(localPlayer, "felmutat egy tárgyat.")
					end
				end

				movedSlotId, haveMoving = false, false
				return
			end

			if not hoverSlotId then
				if isPointOnActionBar(absX, absY) then
					if itemsTableState == "player" then
						hoverSlotId = findActionBarSlot(absX, absY)

						if hoverSlotId then
							if movedItem.itemId == 315 then
								exports.see_hud:showInfobox("e", "Névcédulát nem helyezhetsz az actionbarra.")
							else
								putOnActionBar(hoverSlotId, itemsTable[itemsTableState][movedSlotId])
								playSound("files/sounds/move.mp3")
							end
						end
					end
				end

				if not movedItem.locked and not movedItem.inUse then
					if not isPointOnActionBar(absX, absY) and not isPointOnInventory(absX, absY) then
						local px, py, pz = getElementPosition(localPlayer)

						if not isElement(hitElement) then
							local dist = getDistanceBetweenPoints3D(px, py, pz, worldX, worldY, worldZ)

							if dist <= 5 then
								-- füzetlap kitűzése falra
								if movedItem.itemId == 367 and itemsTableState == "player" then
									local cx, cy, cz = getCameraMatrix()
									local tx = cx + (worldX - cx) * 10
									local ty = cy + (worldY - cy) * 10
									local tz = cz + (worldZ - cz) * 10

									local hit, hitX, hitY, hitZ, _, nx, ny, nz, _, _, piece = processLineOfSight(
										cx, cy, cz,
										tx, ty, tz,
										true, false, false, true,
										false, false, false, false)

									if hit and piece == 0 then
										dist = getDistanceBetweenPoints3D(px, py, pz, hitX, hitY, hitZ)

										if dist < 5 then
											tx = cx + ((worldX + nx * 0.15) - cx) * 10
											ty = cy + ((worldY + ny * 0.15) - cy) * 10

											local _, _, _, _, _, nx2, ny2, nz2 = processLineOfSight(
												cx, cy, cz,
												tx, ty, tz,
												true, false, false, true,
												false, false, false, false)

											tx = cx + ((worldX - nx2 * 0.15) - cx) * 10
											ty = cy + ((worldY - ny2 * 0.15) - cy) * 10

											local _, _, _, _, _, nx3, ny3, nz3 = processLineOfSight(
												cx, cy, cz,
												tx, ty, tz,
												true, false, false, true,
												false, false, false, false)

											if nx == nx2 and nx2 == nx3 and ny == ny2 and ny2 == ny3 and nz == nz2 and nz2 == nz3 then
												local interior = getElementInterior(localPlayer)
												local dimension = getElementDimension(localPlayer)
												local canPlaceNote = true

												if getTickCount() > lastPlaceNote + 15000 then
													for id in pairs(nearbyWallNotes) do
														local note = wallNotes[id]

														if note and note[8] == dimension then
															if getDistanceBetweenPoints2D(note[4], note[5], worldX, worldY) <= 0.6 then
																if math.abs(note[6] - worldZ) <= 0.65 then
																	exports.see_hud:showInfobox("e", "Túl közel van egy meglévő jegyzethez!")
																	canPlaceNote = false
																	break
																end
															end
														end
													end

													if canPlaceNote then
														lastPlaceNote = getTickCount()

														local iscopy = tonumber(movedItem.data3) == 1
														local pixels = render3DNote(movedItem.data1, iscopy)
														local str = ""

														if iscopy then
															str = "\n(másolat)"
														end

														triggerServerEvent("putNoteOnWall", localPlayer, pixels, worldX + nx * 0.02, worldY + ny * 0.02, worldZ, interior, dimension, nx, ny, movedItem.dbID, movedItem.data2 .. str)
													end
												else
													exports.see_hud:showInfobox("e", "Várj még egy kicsit.")
												end
											else
												exports.see_hud:showInfobox("e", "Csak egyenes falfelületre helyezheted fel!")
											end
										end
									end
								-- tárgy eldobása
								elseif isItemDroppable(movedItem.itemId) and not movedItem.dropped then
									local model, rx, ry, rz, offZ = getItemDropDetails(movedItem.itemId)
									local data = {}

									data.model = model or 1271
									data.posX, data.posY, data.posZ = worldX, worldY, worldZ + (offZ or 0)
									data.rotX, data.rotY, data.rotZ = rx or 0, ry or 0, rz or 0
									data.interior = getElementInterior(localPlayer)
									data.dimension = getElementDimension(localPlayer)

									triggerServerEvent("dropItem", localPlayer, movedItem, data)

									movedItem.dropped = true

									if movedItem.nameTag then
										exports.see_chat:localActionC(localPlayer, "eldobott egy tárgyat a földre. (" .. getItemName(movedItem.itemId) .. " (" .. movedItem.nameTag .. "))")
									else
										exports.see_chat:localActionC(localPlayer, "eldobott egy tárgyat a földre. (" .. getItemName(movedItem.itemId) .. ")")
									end
								else
									outputChatBox("#DC143C[StrongMTA]: #FFFFFFEzt a tárgyat nem lehet eldobni!", 255, 255, 255, true)
									playSound("files/sounds/select.mp3")
								end
							else
								outputChatBox("#DC143C[StrongMTA]: #FFFFFFIlyen messze nem dobhatsz el tárgyat!", 255, 255, 255, true)
								playSound("files/sounds/select.mp3")
							end

							movedSlotId, haveMoving = false, false
							return
						end

						local tx, ty, tz = getElementPosition(hitElement)
						local elementType = getElementType(hitElement)
						local elementModel = getElementModel(hitElement)

						if elementType == "ped" then
							if itemsTableState == "player" then
								if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 4 then
									if getElementData(hitElement, "isLottery") then
										if movedItem.itemId == 294 then
											triggerServerEvent("tryToConvertLottery", localPlayer, movedItem.dbID)
										elseif movedItem.itemId == 295 then
											triggerServerEvent("checkLotteryWin", localPlayer, movedItem.dbID)
										end
									elseif getElementData(hitElement, "isScratchPed") then
										if scratchItems[movedItem.itemId] then
											exports.see_lottery:verifyScratch(movedItem.itemId, movedItem.dbID, movedItem.data2, movedItem.data3)
										end
									end
								end
							end
						elseif elementType == "object" and elementModel == 2186 then
							if itemsTableState == "player" then
								if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 4 then
									if copierEffect[hitElement] then
										exports.see_hud:showInfobox("e", "Ez a fénymásoló jelenleg használatban van.")
									else
										if copyableItems[movedItem.itemId] then
											triggerServerEvent("tryToCopyNote", localPlayer, movedItem, hitElement)
										end
									end
								end
							end
						elseif elementType == "object" and isTrashModel(elementModel) then
							if not getElementAttachedTo(hitElement) then
								if itemsTableState == "player" then
									if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 4 then
										if availableItems[movedItem.itemId] then
											local itemName = getItemName(movedItem.itemId)

											if movedItem.nameTag then
												itemName = itemName .. " (" .. movedItem.nameTag .. ")"
											end

											exports.see_chat:localActionC(localPlayer, "kidobott egy tárgyat a szemetesbe. (" .. itemName .. ")")
										else
											exports.see_chat:localActionC(localPlayer, "kidobott egy tárgyat a szemetesbe.")
										end

										if stackAmount > 0 and stackAmount < movedItem.amount then
											triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", movedItem.dbID, stackAmount)
										else
											triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", movedItem.dbID)
										end
									end
								end
							end
						else
							if movedItem.data3 == "duty" then
								outputChatBox("#DC143C[StrongMTA]: #FFFFFFSzolgálati eszközzel ezt nem teheted meg!", 255, 255, 255, true)
								movedSlotId, haveMoving = false, false
								playSound("files/sounds/select.mp3")
								return
							end

							if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 5 then
								movedSlotId, haveMoving = false, false
								return
							end

							if elementType == "player" and hitElement == localPlayer and itemsTableState == "player" then
								outputChatBox("#DC143C[StrongMTA]: #FFFFFFSaját inventoryból magadra nem húzhatsz itemet!", 255, 255, 255, true)
								movedSlotId, haveMoving = false, false
								playSound("files/sounds/select.mp3")
								return
							end

							if (itemsTableState == "vehicle" or itemsTableState == "object") and (elementType ~= "player" or hitElement ~= localPlayer) then
								outputChatBox("#DC143C[StrongMTA]: #FFFFFFJárműből / széfből csak a saját inventorydba pakolhatsz!", 255, 255, 255, true)
								movedSlotId, haveMoving = false, false
								playSound("files/sounds/select.mp3")
								return
							end

							local elementId = false

							if elementType == "player" then
								elementId = getElementData(hitElement, defaultSettings.characterId)
							elseif elementType == "vehicle" then
								elementId = getElementData(hitElement, defaultSettings.vehicleId)
							elseif elementType == "object" then
								elementId = getElementData(hitElement, defaultSettings.objectId)
							end

							if tonumber(elementId) then
								itemsTable[itemsTableState][movedSlotId].locked = true

								triggerServerEvent("moveItem", localPlayer, movedItem.dbID, movedItem.itemId, movedSlotId, false, stackAmount, currentInventoryElement, hitElement)
							else
								outputChatBox("#DC143C[StrongMTA]: #FFFFFFA kiválasztott elem nem rendelkezik önálló tárterülettel!", 255, 255, 255, true)
								playSound("files/sounds/select.mp3")
							end
						end
					end
				end

				movedSlotId, haveMoving = false, false
				return
			end

			if itemsTableState == "player" and isKeyItem(movedItem.itemId) and hoverSlotId < defaultSettings.slotLimit then
				hoverSlotId = findEmptySlotOfKeys("player")

				if not hoverSlotId then
					movedSlotId, haveMoving = false, false
					return
				end

				outputChatBox("#DC143C[StrongMTA]: #FFFFFFEz az item átkerült a kulcsokhoz!", 255, 255, 255, true)
			end

			if itemsTableState == "player" and isPaperItem(movedItem.itemId) and hoverSlotId < defaultSettings.slotLimit then
				hoverSlotId = findEmptySlotOfPapers("player")

				if not hoverSlotId then
					movedSlotId, haveMoving = false, false
					return
				end

				outputChatBox("#DC143C[StrongMTA]: #FFFFFFEz az item átkerült az iratokhoz!", 255, 255, 255, true)
			end

			if movedSlotId == hoverSlotId or not movedItem then
				movedSlotId, haveMoving = false, false
				return
			end

			if hoverSlotId >= defaultSettings.slotLimit * 2 then
				if not isPaperItem(movedItem.itemId) then
					if isKeyItem(movedItem.itemId) then
						hoverSlotId = findEmptySlotOfKeys("player")
						outputChatBox("#DC143C[StrongMTA]: #FFFFFFEz az item átkerült a kulcsokhoz!", 255, 255, 255, true)
					else
						hoverSlotId = findEmptySlot("player")
						outputChatBox("#DC143C[StrongMTA]: #FFFFFFEz nem irat!", 255, 255, 255, true)
					end
				end
			end

			if hoverSlotId >= defaultSettings.slotLimit and hoverSlotId < defaultSettings.slotLimit * 2 then
				if not isKeyItem(movedItem.itemId) then
					if isPaperItem(movedItem.itemId) then
						hoverSlotId = findEmptySlotOfPapers("player")
						outputChatBox("#DC143C[StrongMTA]: #FFFFFFEz az item átkerült az iratokhoz!", 255, 255, 255, true)
					else
						hoverSlotId = findEmptySlot("player")
						outputChatBox("#DC143C[StrongMTA]: #FFFFFFEz nem kulcs item!", 255, 255, 255, true)
					end
				end
			end

			if not movedItem.inUse and not movedItem.locked then
				local hoverItem = itemsTable[itemsTableState][hoverSlotId]

				if not hoverItem then
					--if not exports['see_network']:getNetworkStatus() then
						print("asd")

						triggerServerEvent("moveItem", localPlayer, movedItem.dbID, movedItem.itemId, movedSlotId, hoverSlotId, stackAmount, currentInventoryElement, currentInventoryElement)

						if stackAmount >= 0 then
							if stackAmount >= movedItem.amount or stackAmount <= 0 then
								itemsTable[itemsTableState][hoverSlotId] = itemsTable[itemsTableState][movedSlotId]
								itemsTable[itemsTableState][hoverSlotId].slot = hoverSlotId
								itemsTable[itemsTableState][movedSlotId] = nil

								print("test2 1")
							elseif stackAmount > 0 then
								itemsTable[itemsTableState][movedSlotId].amount = itemsTable[itemsTableState][movedSlotId].amount - stackAmount

								print("test2 2")
							end
						end
					--end

					playSound("files/sounds/move.mp3")

					movedSlotId, haveMoving = false, false
					return
				end

				if movedItem.itemId == hoverItem.itemId and isItemStackable(hoverItem.itemId) then
					if stackAmount >= 0 then
						if movedItem.nameTag or hoverItem.nameTag then
							exports.see_hud:showInfobox("e", "Elnevezett itemet nem lehet stackelni.")
						elseif (movedItem.data3 == "duty" or hoverItem.data3 == "duty") and (movedItem.data3 ~= "duty" or hoverItem.data3 ~= "duty") then
							outputChatBox("#DC143C[StrongMTA]: #FFFFFFSzolgálati eszközzel ezt nem teheted meg!", 255, 255, 255, true)
						else
							if getElementData(localPlayer, "movedItemID") ~= movedItem.dbID then
								setElementData(localPlayer, "movedItemID", movedItem.dbID)

								local amount = stackAmount

								if amount <= 0 or amount >= movedItem.amount then
									amount = movedItem.amount
								end

								if movedItem.amount - amount > 0 then
									triggerServerEvent("stackItem", localPlayer, currentInventoryElement, movedItem.dbID, hoverItem.dbID, amount)
									print("test 1")
								else
									triggerServerEvent("stackItem", localPlayer, currentInventoryElement, movedItem.dbID, hoverItem.dbID, movedItem.amount)
									print("test 2")
								end

								playSound("files/sounds/move.mp3")
							end
						end
					end
				end
			end

			movedSlotId, haveMoving = false, false
			return
		end

		if button == "right" then
			if state == "up" then
				local hoverSlotId = findSlot(absX, absY)

				if panelState then
					if hoverSlotId then
						if itemsTable[itemsTableState][hoverSlotId] then
							useItem(itemsTable[itemsTableState][hoverSlotId].dbID)
							movedSlotId, haveMoving = false, false
						end
					end
				end

				if not hoverSlotId and isElement(hitElement) and hitElement ~= localPlayer and hitElement ~= currentInventoryElement then
					if isPointOnInventory(absX, absY) or isPointOnActionBar(absX, absY) then
						return
					end

					local px, py, pz = getElementPosition(localPlayer)
					local tx, ty, tz = getElementPosition(hitElement)
					local elementType = getElementType(hitElement)
					local elementModel = getElementModel(hitElement)
					local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

					if dist > 5 then
						return
					end

					local elementId = false

					if elementType == "vehicle" then
						elementId = tonumber(getElementData(hitElement, defaultSettings.vehicleId))

						if elementModel == 448 then
							return
						end

						if elementModel == 498 then
							return
						end

						if getPedOccupiedVehicle(localPlayer) then
							outputChatBox("#DC143C[StrongMTA]: #FFFFFFJárműben ülve nem nézhetsz bele a csomagtartóba!", 255, 255, 255, true)
							return
						end

						if not bootCheck(hitElement) then
							exports.see_hud:showInfobox("error", "Csak a jármű csomagtartójánál állva nézhetsz bele a csomagterébe!")
							return
						end
					elseif elementType == "object" then
						elementId = tonumber(getElementData(hitElement, defaultSettings.objectId))
					end

					if elementId then
						triggerServerEvent("requestItems", localPlayer, hitElement, elementId, elementType, getElementsByType("player", root, true))
					elseif dist < 1.75 then
						local worldItemId = tonumber(getElementData(hitElement, "worldItem"))

						if worldItemId then
							triggerServerEvent("pickUpItem", localPlayer, worldItemId)
						end
					end
				end
			end
		end
	end)

local bootlessModel = {
	[409] = true,
	[416] = true,
	[433] = true,
	[427] = true,
	[490] = true,
	[528] = true,
	[407] = true,
	[544] = true,
	[523] = true,
	[470] = true,
	[596] = true,
	[598] = true,
	[599] = true,
	[597] = true,
	[432] = true,
	[601] = true,
	[428] = true,
	[431] = true,
	[420] = true,
	[525] = true,
	[408] = true,
	[552] = true,
	[499] = true,
	[609] = true,
	[498] = true,
	[524] = true,
	[532] = true,
	[578] = true,
	[486] = true,
	[406] = true,
	[573] = true,
	[455] = true,
	[588] = true,
	[403] = true,
	[423] = true,
	[414] = true,
	[443] = true,
	[515] = true,
	[514] = true,
	[531] = true,
	[456] = true,
	[459] = true,
	[422] = true,
	[482] = true,
	[605] = true,
	[530] = true,
	[418] = true,
	[572] = true,
	[582] = true,
	[413] = true,
	[440] = true,
	[543] = true,
	[583] = true,
	[478] = true,
	[554] = true
}

function bootCheck(veh)
	local cx, cy, cz = getVehicleComponentPosition(veh, "boot_dummy", "world")

	if not cx or not cy or getVehicleType(veh) ~= "Automobile" or bootlessModel[getElementModel(veh)] then
		return true
	end

	local px, py, pz = getElementPosition(localPlayer)
	local vx, vy, vz = getElementPosition(veh)
	local vrx, vry, vrz = getElementRotation(veh)
	local angle = math.rad(270 + vrz)

	cx = cx + math.cos(angle) * 1.5
	cy = cy + math.sin(angle) * 1.5

	if getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz) < 1 then
		return true
	end

	return false
end

function findSlot(x, y)
	if panelState then
		local slotId = false
		local slotPosX, slotPosY = false, false

		for i = 0, defaultSettings.slotLimit - 1 do
			local x2 = panelPosX + 50 + (defaultSettings.slotBoxWidth + 5) * (i % defaultSettings.width)
			local y2 = panelPosY + 25 + (defaultSettings.slotBoxHeight + 5) * math.floor(i / defaultSettings.width)

			if x >= x2 and x <= x2 + defaultSettings.slotBoxWidth and y >= y2 and y <= y2 + defaultSettings.slotBoxHeight then
				slotId = tonumber(i)
				slotPosX, slotPosY = x2, y2
				break
			end
		end

		if slotId then
			if itemsTableState == "player" and currentTab == "keys" then
				slotId = slotId + defaultSettings.slotLimit
			elseif itemsTableState == "player" and currentTab == "papers" then
				slotId = slotId + defaultSettings.slotLimit * 2
			end

			return slotId, slotPosX, slotPosY
		else
			return false
		end
	else
		return false
	end
end

function isPointOnInventory(x, y)
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

function getLocalPlayerItems()
	return itemsTable.player
end

local showedItems = {}
local showItemHandler = false

addEvent("showTheItem", true)
addEventHandler("showTheItem", getRootElement(),
	function (item)
		table.insert(showedItems, {
			source, getTickCount(), item,
			dxCreateRenderTarget(256, 96 + defaultSettings.slotBoxHeight, true)
		})

		processShowItem()
	end)

function processShowItem(hide)
	if #showedItems > 0 then
		if not showItemHandler then
			addEventHandler("onClientRender", getRootElement(), renderShowItem)
			addEventHandler("onClientRestore", getRootElement(), processShowItem)
			showItemHandler = true
		end

		if not hide and showedItems then
			local sx = defaultSettings.slotBoxWidth * 1.1
			local sy = defaultSettings.slotBoxHeight * 1.1

			for i = 1, #showedItems do
				local v = showedItems[i]

				if v then
					local item = v[3]

					dxSetRenderTarget(v[4], true)
					dxSetBlendMode("modulate_add")

					local x, y = math.floor(128 - sx / 2), 0

					drawItemPicture(item, x, y, sx, sy)
					dxDrawText(item.amount, x + sx - 6, y + sy - 15, x + sx, y + sy - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")

					if availableItems[item.itemId] then
						processTooltip(128, defaultSettings.slotBoxHeight + 16, getItemName(item.itemId), item.itemId, item, true)
					end
				end
			end

			dxSetBlendMode("blend")
			dxSetRenderTarget()
		end
	elseif showItemHandler then
		removeEventHandler("onClientRender", getRootElement(), renderShowItem)
		removeEventHandler("onClientRestore", getRootElement(), processShowItem)

		showItemHandler = false
	end
end

function renderShowItem()
	local now = getTickCount()
	local cx, cy, cz = getCameraMatrix()
	local px, py, pz = getElementPosition(localPlayer)

	if showedItems then
		for i = 1, #showedItems do
			local v = showedItems[i]

			if v then
				local elapsedTime = now - v[2]
				local progress = 255

				if elapsedTime < 500 then
					progress = 255 * elapsedTime / 500
				end

				if elapsedTime > 5000 then
					progress = 255 - (255 * (elapsedTime - 5000) / 500)

					if progress < 0 then
						progress = 0
					end

					if elapsedTime > 5500 then
						showedItems[i] = nil
						processShowItem(true)
					end
				end

				if v then
					local source = v[1]

					if isElement(source) then
						local tx, ty, tz = getElementPosition(source)
						local dist = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)

						if dist < 10 and isLineOfSightClear(cx, cy, cz, tx, ty, tz, true, false, false, true, false, true, false) then
							local scale = 1

							if dist > 7.5 then
								scale = 1 - (dist - 7.5) / 2.5
							end

							local x, y, z = getPedBonePosition(source, 5)

							if x and y and z then
								x, y = getScreenFromWorldPosition(x, y, z + 0.55)

								if x and y then
									x = math.floor(x - 128)
									y = math.floor(y - (96 + defaultSettings.slotBoxHeight) / 2)

									dxDrawImage(x, y + (255 - progress) / 4, 256, 96 + defaultSettings.slotBoxHeight, v[4], 0, 0, 0, tocolor(255, 255, 255, progress * 0.9 * scale))
								end
							end
						end
					end
				end
			end
		end
	end
end

function onRender()
	local cx, cy = getCursorPosition()

	if tonumber(cx) then
		cx = cx * screenX
		cy = cy * screenY

		if panelIsMoving then
			panelPosX = cx - moveDifferenceX
			panelPosY = cy - moveDifferenceY

			guiSetPosition(stackGUI, panelPosX + panelWidth - 50 - 10, panelPosY, false)
		end
	else
		cx, cy = -1, -1
	end

	if currentInventoryElement ~= localPlayer and isElement(currentInventoryElement) then
		local px, py, pz = getElementPosition(localPlayer)
		local tx, ty, tz = getElementPosition(currentInventoryElement)

		if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) >= 5 then
			toggleInventory(false)
			return
		end
	end

	-- ** Háttér
	dxDrawRectangle(panelPosX - 5, panelPosY - 5, panelWidth, 2, tocolor(0, 0, 0, 200)) -- felső
	dxDrawRectangle(panelPosX - 5, panelPosY - 5 + panelHeight - 2, panelWidth, 2, tocolor(0, 0, 0, 200)) -- alsó
	dxDrawRectangle(panelPosX - 5, panelPosY - 5 + 2, 2, panelHeight - 4, tocolor(0, 0, 0, 200)) -- bal
	dxDrawRectangle(panelPosX - 5 + panelWidth - 2, panelPosY - 5 + 2, 2, panelHeight - 4, tocolor(0, 0, 0, 200)) -- jobb
	dxDrawRectangle(panelPosX - 5, panelPosY - 5, panelWidth, panelHeight, tocolor(0, 0, 0, 150)) -- háttér

	-- ** Item mennyiség @ Súly
	local weightLimit = getWeightLimit(itemsTableState, currentInventoryElement)
	local weight = 0
	local items = 0

	for k, v in pairs(itemsTable[itemsTableState]) do
		if availableItems[v.itemId] then
			weight = weight + getItemWeight(v.itemId) * v.amount
		end

		if itemsTableState == "player" then
			if currentTab == "keys" then
				if v.slot >= 50 and v.slot < 100 then
					items = items + 1
				end
			elseif currentTab == "papers" then
				if v.slot >= 100 then
					items = items + 1
				end
			elseif v.slot < 50 then
				items = items + 1
			end
		else
			items = items + 1
		end
	end

	if weightLimit < weight then
		weight = weightLimit
	end

	dxDrawRectangle(panelPosX + 50, panelPosY + panelHeight - 20, panelWidth - 50 - 10 - 60, 10, tocolor(194, 194, 194, 150))
	dxDrawRectangle(panelPosX + 50, panelPosY + panelHeight - 20, (panelWidth - 50 - 10 - 60) * (weight / weightLimit), 10, tocolor(61, 122, 188))
	dxDrawText(math.ceil(weight) .. "/" .. weightLimit .. "kg", panelPosX + (panelWidth - 10 - 55), panelPosY + panelHeight - 20, panelPosX + (panelWidth - 10), panelPosY + panelHeight - 20 + 10, tocolor(255, 255, 255), 0.4, Roboto, "center", "center")

	-- ** Cím
	local invTypText = "Tárgyak: "

	if itemsTableState == "vehicle" then
		invTypText = "Csomagtartó: "
	elseif itemsTableState == "object" then
		invTypText = "Széf: "
	elseif currentTab == "keys" then
		invTypText = "Kulcsok: "
	elseif currentTab == "papers" then
		invTypText = "Iratok: "
	elseif currentTab == "crafting" then
		if selectedRecipe then
			invTypText = "Barkácsolás: "
		else
			invTypText = "Barkácsolás"
		end
	end

	dxDrawText(invTypText, panelPosX, panelPosY, panelPosX, panelPosY + 20, tocolor(61, 122, 188, 255), 0.55, Roboto, "left", "center")

	if currentTab ~= "crafting" then
		dxDrawText("Jelenleg " .. items .. "/" .. defaultSettings.slotLimit .. "db itemed van", panelPosX + dxGetTextWidth(invTypText, 0.55, Roboto), panelPosY + 2.5, panelPosX, panelPosY + 20, tocolor(255, 255, 255), 0.45, Roboto, "left", "center")
	elseif selectedRecipe then
		dxDrawText(availableRecipes[selectedRecipe].name, panelPosX + dxGetTextWidth(invTypText, 0.55, Roboto), panelPosY + 2.5, panelPosX, panelPosY + 20, tocolor(255, 255, 255), 0.45, Roboto, "left", "center")
	end

	-- ** Kategóriák
	local sizeForTabs = (panelHeight - 20 - 10) / 4
	local tabStartX = math.floor(panelPosX + 2)
	local tabStartY = math.floor(panelPosY + 25 + sizeForTabs / 2 - 24)

	hoverTab = false

	if cx >= tabStartX and cx <= tabStartX + 40 and cy >= tabStartY and cy <= tabStartY + 48 then
		hoverTab = "main"
	elseif cx >= tabStartX and cx <= tabStartX + 40 and cy >= tabStartY + sizeForTabs and cy <= tabStartY + sizeForTabs + 48 then
		hoverTab = "keys"
	elseif cx >= tabStartX and cx <= tabStartX + 40 and cy >= tabStartY + sizeForTabs * 2 and cy <= tabStartY + sizeForTabs * 2 + 48 then
		hoverTab = "papers"
	elseif cx >= tabStartX and cx <= tabStartX + 40 and cy >= tabStartY + sizeForTabs * 3 and cy <= tabStartY + sizeForTabs * 3 + 48 then
		hoverTab = "crafting"
	end

	if itemsTableState == "vehicle" then
		dxDrawImage(tabStartX, tabStartY, 40, 48, "files/tabs/car.png", 0, 0, 0, tocolor(194, 194, 194, 200))
	elseif itemsTableState == "object" then
		dxDrawImage(tabStartX, tabStartY, 40, 48, "files/tabs/safe.png", 0, 0, 0, tocolor(194, 194, 194, 200))
	else
		if currentTab == "main" then
			dxDrawImage(tabStartX, tabStartY, 40, 48, "files/tabs/bag.png", 0, 0, 0, tocolor(194, 194, 194, 200))
		elseif hoverTab == "main" then
			dxDrawImage(tabStartX, tabStartY, 40, 48, "files/tabs/bag.png", 0, 0, 0, tocolor(194, 194, 194, 150))
		else
			dxDrawImage(tabStartX, tabStartY, 40, 48, "files/tabs/bag.png", 0, 0, 0, tocolor(194, 194, 194, 75))
		end

		if currentTab == "keys" then
			dxDrawImage(tabStartX, tabStartY + sizeForTabs, 40, 48, "files/tabs/key.png", 0, 0, 0, tocolor(194, 194, 194, 200))
		elseif hoverTab == "keys" then
			dxDrawImage(tabStartX, tabStartY + sizeForTabs, 40, 48, "files/tabs/key.png", 0, 0, 0, tocolor(194, 194, 194, 150))
		else
			dxDrawImage(tabStartX, tabStartY + sizeForTabs, 40, 48, "files/tabs/key.png", 0, 0, 0, tocolor(194, 194, 194, 75))
		end

		if currentTab == "papers" then
			dxDrawImage(tabStartX, tabStartY + sizeForTabs * 2, 40, 48, "files/tabs/wallet.png", 0, 0, 0, tocolor(194, 194, 194, 200))
		elseif hoverTab == "papers" then
			dxDrawImage(tabStartX, tabStartY + sizeForTabs * 2, 40, 48, "files/tabs/wallet.png", 0, 0, 0, tocolor(194, 194, 194, 150))
		else
			dxDrawImage(tabStartX, tabStartY + sizeForTabs * 2, 40, 48, "files/tabs/wallet.png", 0, 0, 0, tocolor(194, 194, 194, 75))
		end

		if currentTab == "crafting" then
			dxDrawImage(tabStartX, tabStartY + sizeForTabs * 3, 40, 48, "files/tabs/craft.png", 0, 0, 0, tocolor(194, 194, 194, 200))
		elseif hoverTab == "crafting" then
			dxDrawImage(tabStartX, tabStartY + sizeForTabs * 3, 40, 48, "files/tabs/craft.png", 0, 0, 0, tocolor(194, 194, 194, 150))
		else
			dxDrawImage(tabStartX, tabStartY + sizeForTabs * 3, 40, 48, "files/tabs/craft.png", 0, 0, 0, tocolor(194, 194, 194, 75))
		end
	end

	-- ** Craft
	if currentTab == "crafting" and itemsTableState ~= "vehicle" and itemsTableState ~= "object" then
		local requiredCount = 0
		local availableCount = 0

		for i = 0, 24 do
			local x = i % 5
			local y = math.floor(i / 5)

			local x2 = panelPosX + 50 + (defaultSettings.slotBoxWidth + 5) * x
			local y2 = panelPosY + 25 + (defaultSettings.slotBoxHeight + 5) * y

			if x >= 1 and x <= 3 and y >= 1 and y <= 3 then
				if requiredRecipeItems and requiredRecipeItems[y] and requiredRecipeItems[y][x] then
					local recipe = requiredRecipeItems[y][x]
					local state = ""

					if recipe[2] then
						dxDrawRectangle(x2, y2, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(61, 122, 188, 200))
						availableCount = availableCount + 1
					else
						dxDrawRectangle(x2, y2, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(215, 89, 89, 200))
						state = "2"
					end

					dxDrawImage(x2, y2, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, "files/items/" .. recipe[1] - 1 .. ".png")
					dxDrawImage(x2 - 3, y2 - 3, 42, 42, "files/used" .. state .. ".png", 0, 0, 0, tocolor(255, 255, 255, 150))

					if cx >= x2 and cx <= x2 + defaultSettings.slotBoxWidth and cy >= y2 and cy <= y2 + defaultSettings.slotBoxHeight then
						if craftDoNotTakeItems[recipe[1]] then
							showTooltip(cx, cy, availableItems[recipe[1]][1], "Szükséges a recepthez, többször használatos")
						else
							showTooltip(cx, cy, availableItems[recipe[1]][1], "Szükséges a recepthez")
						end
					end

					requiredCount = requiredCount + 1
				else
					dxDrawRectangle(x2, y2, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(50, 50, 50, 200))
				end
			else
				dxDrawRectangle(x2, y2, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(20, 20, 20, 225))
			end
		end

		local x = panelPosX + 50 + (defaultSettings.slotBoxWidth + 5) * 5 + 8
		local y = panelPosY + 25

		local sx = panelPosX + panelWidth - 16 - x
		local sy = (panelHeight - 40 + 15 - 20 - 5) / 10

		local hasAllRecipeItems = false

		if requiredCount == availableCount then
			hasAllRecipeItems = true
		end

		dxDrawText("Receptek:", x, y, panelPosX + panelWidth - 16, y + sy, tocolor(255, 255, 255), 0.45, Roboto, "left", "center")

		y = y + sy

		for i = 1, 8 do
			local y2 = y + (i - 1) * sy
			local rowalpha = 100

			if i % 2 ~= craftListOffset % 2 then
				rowalpha = 125
			end

			local craft = craftList[i + craftListOffset]

			if craft then
				local textcolor = tocolor(255, 255, 255)

				if craft[1] == "category" then
					rowalpha = 150

					if not craftingProcess and cx >= x and cx <= x + sx and cy >= y2 and cy <= y2 + sy then
						textcolor = tocolor(61, 122, 188)
						rowalpha = 200

						if hoverRecipeCategory ~= craft[2] then
							hoverRecipeCategory = craft[2]
							playSound("files/sounds/hover.mp3")
						end
					elseif hoverRecipeCategory == craft[2] then
						hoverRecipeCategory = false
					end

					local color = craft[3] and tocolor(61, 122, 188) or textcolor

					dxDrawRectangle(x, y2, sx, sy, tocolor(0, 0, 0, rowalpha))
					dxDrawImageSection(math.floor(x) + 5, math.floor(y2) + 4, sy - 8, sy - 8, craft[3] and 32 or 0, 0, 32, 32, "files/arrows.png", 0, 0, 0, color)
					dxDrawText(craft[2], x + 5 + sy - 4, y2, x + sx, y2 + sy, color, 0.4, Roboto, "left", "center", true)
				else
					if craft[1] == "recipe" and craft[2] then
						local id = craft[2]
						local recipe = availableRecipes[id]

						if recipe then
							if selectedRecipe == id then
								rowalpha = 200
							end

							if not craftingProcess and selectedRecipe ~= id and cx >= x and cx <= x + sx and cy >= y2 and cy <= y2 + sy then
								textcolor = tocolor(61, 122, 188)
								rowalpha = 200

								if hoverRecipe ~= id then
									hoverRecipe = id
									playSound("files/sounds/hover.mp3")
								end

								if recipe.requiredJob then
									if recipe.suitableColShapes then
										showTooltip(cx, cy, "#ffffffMunka: #d75959Szükséges", "Pozíció: #d75959Szükséges")
									else
										showTooltip(cx, cy, "#ffffffMunka: #d75959Szükséges", "Pozíció: #3d7abcNem szükséges")
									end
								elseif recipe.requiredPermission then
									if recipe.suitableColShapes then
										showTooltip(cx, cy, "#ffffffCsoport: #d75959Szükséges", "Pozíció: #d75959Szükséges")
									else
										showTooltip(cx, cy, "#ffffffCsoport: #d75959Szükséges", "Pozíció: #3d7abcNem szükséges")
									end
								elseif recipe.suitableColShapes then
									showTooltip(cx, cy, "Pozíció: #d75959Szükséges")
								end
							elseif hoverRecipe == id then
								hoverRecipe = false
							end
						else
							hoverRecipe = false
						end

						dxDrawRectangle(x, y2, sx, sy, tocolor(0, 0, 0, rowalpha))

						if recipe then
							textcolor = tocolor(150, 150, 150, 150)

							if playerRecipes[id] or defaultRecipes[id] or (availableRecipes[id].requiredJob and availableRecipes[id].requiredJob == currentJob) then
								textcolor = tocolor(255, 255, 255)

								if hoverRecipe == id or selectedRecipe == id then
									textcolor = tocolor(61, 122, 188)
								end
							elseif hoverRecipe == id or selectedRecipe == id then
								textcolor = tocolor(61, 122, 188, 175)
							end

							dxDrawText(recipe.name, x + 15, y2, x + sx, y2 + sy, textcolor, 0.4, Roboto, "left", "center", true)
						end
					else
						dxDrawRectangle(x, y2, sx, sy, tocolor(0, 0, 0, rowalpha))
					end
				end
			else
				dxDrawRectangle(x, y2, sx, sy, tocolor(0, 0, 0, rowalpha))
			end
		end

		local listHeight = sy * 8

		if #craftList > 8 then
			dxDrawRectangle(x + sx - 5, y, 5, listHeight, tocolor(0, 0, 0, 200))
			dxDrawRectangle(x + sx - 5, y + craftListOffset * (listHeight / (#craftList - 8 + 1)), 5, listHeight / (#craftList - 8 + 1), tocolor(61, 122, 188, 150))
		end

		hoverCraftButton = false
		canCraftTheRecipe = false

		if selectedRecipe then
			local r, g, b, a = 61, 122, 188, 175

			if cx >= x and cx <= x + sx and cy >= y + listHeight + 4 and cy <= y + listHeight + 4 + sy - 4 then
				if not craftingProcess and not craftStartTime then
					hoverCraftButton = true
				end

				a = 255
			end

			if not hasAllRecipeItems or craftStartTime then
				r, g, b = 215, 89, 89
			end

			if not hasAllRecipeItems or craftStartTime or not playerRecipes[selectedRecipe] and not defaultRecipes[selectedRecipe] and (not availableRecipes[selectedRecipe].requiredJob or availableRecipes[selectedRecipe].requiredJob ~= currentJob) then
				canCraftTheRecipe = false
			elseif a > 200 then
				canCraftTheRecipe = true
			else
				canCraftTheRecipe = false
			end

			dxDrawRectangle(x, y + listHeight + 4, sx, sy - 4, tocolor(r, g, b, a))

			if craftStartTime then
				local now = getTickCount()

				if now >= craftStartTime then
					local progress = (now - craftStartTime) / 10000

					if progress > 1 then
						progress = 1
						craftStartTime = false
					end

					dxDrawRectangle(x, y + listHeight + 4, sx * progress, sy - 4, tocolor(61, 122, 188))
				end
			end

			if playerRecipes[selectedRecipe] or defaultRecipes[selectedRecipe] or (availableRecipes[selectedRecipe].requiredJob and availableRecipes[selectedRecipe].requiredJob == currentJob) then
				dxDrawText("Elkészít", x, y + listHeight + 4, x + sx, y + listHeight + 4 + sy - 4, tocolor(0, 0, 0, 255), 0.45, Roboto, "center", "center")
			elseif availableRecipes[selectedRecipe].requiredJob then
				dxDrawText("Nincs felvéve a munka!", x, y + listHeight + 4, x + sx, y + listHeight + 4 + sy - 4, tocolor(0, 0, 0, 255), 0.45, Roboto, "center", "center")
			else
				dxDrawText("Nincs elsajátítva a recept!", x, y + listHeight + 4, x + sx, y + listHeight + 4 + sy - 4, tocolor(0, 0, 0, 255), 0.45, Roboto, "center", "center")
			end
		else
			dxDrawRectangle(x, y + listHeight + 4, sx, sy - 4, tocolor(215, 89, 89, 175))
			dxDrawText("Válassz egy receptet!", x, y + listHeight + 4, x + sx, y + listHeight + 4 + sy - 4, tocolor(0, 0, 0, 255), 0.45, Roboto, "center", "center")
		end
	-- ** Item slotok @ Itemek
	else
		for i = 0, defaultSettings.slotLimit - 1 do
			local slot = i
			local x = panelPosX + 50 + (defaultSettings.slotBoxWidth + 5) * (slot % defaultSettings.width)
			local y = panelPosY + 25 + (defaultSettings.slotBoxHeight + 5) * math.floor(slot / defaultSettings.width)

			if itemsTableState == "player" and currentTab == "keys" then
				i = i + defaultSettings.slotLimit
			elseif itemsTableState == "player" and currentTab == "papers" then
				i = i + defaultSettings.slotLimit * 2
			end

			local item = itemsTable[itemsTableState]

			if item then
				item = itemsTable[itemsTableState][i]

				if item and not availableItems[item.itemId] then
					item = false
				end
			end

			local slotColor = tocolor(50, 50, 50, 200)

			if item and item.inUse then
				slotColor = tocolor(61, 122, 188, 200)
			end

			if cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight and not renameDetails then
				slotColor = tocolor(255, 127, 0, 200)

				if item and not movedSlotId then
					if not renameProcess then
						processTooltip(cx, cy, getItemName(item.itemId), item.itemId, item, false)
					else
						slotColor = tocolor(50, 179, 239, 200)
					end

					if lastHoverSlotId ~= i then
						lastHoverSlotId = i
						playSound("files/sounds/hover.mp3")
					end
				end
			elseif lastHoverSlotId == i then
				lastHoverSlotId = false
			end

			dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, slotColor)

			if item and (movedSlotId ~= i or movedSlotId == i and stackAmount > 0 and stackAmount < item.amount) then
				drawItemPicture(item, x, y)
				dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
			end
		end

		-- ** Mozgatott item
		if movedSlotId then
			dxDrawImage(panelPosX + panelWidth / 2 - 32, panelPosY - 5 - 64, 64, 64, "files/eye.png", 0, 0, 0, tocolor(255, 255, 255, 125))

			if cx >= panelPosX + panelWidth / 2 - 32 and cy >= panelPosY - 5 - 64 and cx <= panelPosX + panelWidth / 2 + 32 and cy <= panelPosY - 5 then
				if getTickCount() - showItemTick > 5500 then
					dxDrawImage(panelPosX + panelWidth / 2 - 32, panelPosY - 5 - 64, 64, 64, "files/eye.png", 0, 0, 0, tocolor(255, 255, 255, 200))
				end
			end

			local x = cx - moveDifferenceX
			local y = cy - moveDifferenceY

			drawItemPicture(itemsTable[itemsTableState][movedSlotId], x, y)

			if stackAmount < itemsTable[itemsTableState][movedSlotId].amount then
				if stackAmount > 0 then
					dxDrawText(stackAmount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
				else
					dxDrawText(itemsTable[itemsTableState][movedSlotId].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
				end
			else
				dxDrawText(itemsTable[itemsTableState][movedSlotId].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
			end
		end

		-- ** Item átnevezés
		if not renameDetails then
			if isCursorShowing() then
				if renameProcess then
					dxDrawImage(cx, cy, 32, 32, "files/nametag.png")
					setCursorAlpha(0)
				end
			elseif renameProcess then
				renameProcess = false
				setCursorAlpha(255)
			end
		elseif isCursorShowing() then
			setCursorAlpha(255)
		end

		if renameDetails then
			if getTickCount() - renameDetails.cursorChange >= 750 then
				renameDetails.cursorChange = getTickCount()
				renameDetails.cursorState = not renameDetails.cursorState
			end

			renameDetails.activeButton = false

			-- Háttér
			dxDrawRectangle(renameDetails.x, renameDetails.y, 200, 24, tocolor(0, 0, 0, 200))

			-- Mégsem
			local closeAlpha = 225

			if cx >= renameDetails.x + 200 - 32 and cy >= renameDetails.y + 3 and cx <= renameDetails.x + 200 - 32 + 28 and cy <= renameDetails.y + 3 + 18 then
				renameDetails.activeButton = "close"
				closeAlpha = 255
			end

			dxDrawRectangle(renameDetails.x + 200 - 32 + 1, renameDetails.y + 3, 28, 18, tocolor(215, 89, 89, closeAlpha))
			dxDrawText("X", renameDetails.x + 200 - 32, renameDetails.y + 3, renameDetails.x + 200 - 32 + 28, renameDetails.y + 3 + 18, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")

			-- Alkalmaz
			local okayAlpha = 225

			if cx >= renameDetails.x + 200 - 64 and cy >= renameDetails.y + 3 and cx <= renameDetails.x + 200 - 64 + 28 and cy <= renameDetails.y + 3 + 18 then
				renameDetails.activeButton = "ok"
				okayAlpha = 255
			end

			dxDrawRectangle(renameDetails.x + 200 - 64, renameDetails.y + 3, 28, 18, tocolor(61, 122, 188, okayAlpha))
			dxDrawText("Ok", renameDetails.x + 200 - 64, renameDetails.y + 3, renameDetails.x + 200 - 64 + 28, renameDetails.y + 3 + 18, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")

			-- Szöveg
			if renameDetails.cursorState then
				dxDrawText(renameDetails.text .. "|", renameDetails.x + 2, renameDetails.y, 0, renameDetails.y + 24, tocolor(255, 255, 255), 0.5, Roboto, "left", "center")
			else
				dxDrawText(renameDetails.text, renameDetails.x + 2, renameDetails.y, 0, renameDetails.y + 24, tocolor(255, 255, 255), 0.5, Roboto, "left", "center")
			end
		end
	end
end

local searchState = false
local searchWidth = (defaultSettings.slotBoxWidth + 5) * defaultSettings.width + 5
local searchHeight = (defaultSettings.slotBoxHeight + 5) * math.floor(defaultSettings.slotLimit / defaultSettings.width) + 5 + 90
local searchPosX = screenX / 2
local searchPosY = screenY / 2
local searchDragging = false
local currentSearchTab = "main"
local hoverSearchTab = false
local bodyItems = {}
local bodyMoney = 0
local bodyName = ""
local gtaFont = false

addEvent("bodySearchGetDatas", true)
addEventHandler("bodySearchGetDatas", getRootElement(),
	function (items, name, cash)
		bodyItems = {}

		for k, v in pairs(items) do
			bodyItems[v.slot] = {
				itemId = v.itemId,
				amount = v.amount,
				data1 = v.data1,
				data2 = v.data2,
				data3 = v.data3,
				nameTag = v.nameTag,
				serial = v.serial
			}
		end

		bodyName = name
		bodyMoney = cash

		if not searchState then
			searchState = true
			gtaFont = dxCreateFont("files/fonts/gtaFont.ttf", 30, false, "antialiased")
			addEventHandler("onClientRender", getRootElement(), bodySearchRender)
			addEventHandler("onClientClick", getRootElement(), bodySearchClick)
		end
	end)

function bodySearchClick(button, state, cx, cy)
	if button == "left" and state == "up" then
		if hoverSearchTab then
			if hoverSearchTab and hoverSearchTab ~= currentSearchTab then
				currentSearchTab = hoverSearchTab
				playSound("files/sounds/tab.mp3")
			end
		elseif cx >= searchPosX + searchWidth - 35 and cx <= searchPosX + searchWidth - 5 and cy >= searchPosY and cy <= searchPosY + 30 then
			removeEventHandler("onClientRender", getRootElement(), bodySearchRender)
			removeEventHandler("onClientClick", getRootElement(), bodySearchClick)

			bodyItems = {}
			searchState = false

			if isElement(gtaFont) then
				destroyElement(gtaFont)
			end

			gtaFont = nil
		end
	end
end

function bodySearchRender()
	local cx, cy = getCursorPosition()

	if isCursorShowing() then
		cx = cx * screenX
		cy = cy * screenY

		if not searchDragging then
			if getKeyState("mouse1") and cx >= searchPosX and cx <= searchPosX + searchWidth - 30 and cy >= searchPosY and cy <= searchPosY + 30 then
				searchDragging = {cx, cy, searchPosX, searchPosY}
			end
		elseif getKeyState("mouse1") then
			searchPosX = cx - searchDragging[1] + searchDragging[3]
			searchPosY = cy - searchDragging[2] + searchDragging[4]
		else
			searchDragging = false
		end
	else
		cx, cy = -1, -1
	end

	-- ** Háttér
	dxDrawRectangle(searchPosX - 5, searchPosY - 5, searchWidth, 2, tocolor(0, 0, 0, 200)) -- felső
	dxDrawRectangle(searchPosX - 5, searchPosY - 5 + searchHeight - 2, searchWidth, 2, tocolor(0, 0, 0, 200)) -- alsó
	dxDrawRectangle(searchPosX - 5, searchPosY - 5 + 2, 2, searchHeight - 4, tocolor(0, 0, 0, 200)) -- bal
	dxDrawRectangle(searchPosX - 5 + searchWidth - 2, searchPosY - 5 + 2, 2, searchHeight - 4, tocolor(0, 0, 0, 200)) -- jobb
	dxDrawRectangle(searchPosX - 5, searchPosY - 5, searchWidth, searchHeight, tocolor(0, 0, 0, 150)) -- háttér

	-- ** Cím
	dxDrawImage(searchPosX, searchPosY, 20, 18, "files/backpack.png")
	dxDrawText("Motozás:#ffffff " .. bodyName, searchPosX + 20, searchPosY, 0, searchPosY + 18, tocolor(61, 122, 188, 255), 0.5, Roboto, "left", "center", false, false, false, true)
	dxDrawImage(searchPosX, searchPosY + 20, 20, 18, "files/dollar.png")

	local currentMoney = bodyMoney
	local moneyForDraw = ""
	local moneyTextWidth = 0

	if tonumber(bodyMoney) < 0 then
		moneyTextWidth = dxGetTextWidth("- " .. bodyMoney .. " $", 0.5, gtaFont)
	else
		moneyTextWidth = dxGetTextWidth(bodyMoney .. " $", 0.5, gtaFont)
	end

	for i = 1, 15 - utfLen(currentMoney) do
		moneyForDraw = moneyForDraw .. "0"
	end

	if tonumber(currentMoney) < 0 then
		currentMoney = "#d75959" .. math.abs(currentMoney)
	elseif tonumber(currentMoney) > 0 then
		currentMoney = "#3d7abc" .. math.abs(currentMoney)
	else
		currentMoney = 0
	end

	moneyForDraw = moneyForDraw .. currentMoney

	if tonumber(bodyMoney) < 0 then
		moneyForDraw = "- " .. moneyForDraw
	end

	dxDrawText(moneyForDraw .. " #eaeaea$", searchPosX + 20, searchPosY + 20, 0, searchPosY + 20 + 18, tocolor(255, 255, 255), 0.5, gtaFont, "left", "center", false, false, false, true)

	-- Bezárás
	if cx >= searchPosX + searchWidth - 35 and cx <= searchPosX + searchWidth - 5 and cy >= searchPosY and cy <= searchPosY + 30 then
		dxDrawText("X", searchPosX + searchWidth - 35, searchPosY, searchPosX + searchWidth - 5, searchPosY + 30, tocolor(215, 89, 89), 0.6, Roboto, "center", "center")
	else
		dxDrawText("X", searchPosX + searchWidth - 35, searchPosY, searchPosX + searchWidth - 5, searchPosY + 30, tocolor(255, 255, 255), 0.6, Roboto, "center", "center")
	end

	-- ** Kategóriák
	local sizeForTabs = searchWidth / 3
	local tabStartX = math.floor(searchPosX + sizeForTabs / 2 - 16)
	local tabStartY = math.floor(searchPosY + 45)

	hoverSearchTab = false

	if cx >= tabStartX and cx <= tabStartX + 32 and cy >= tabStartY and cy <= tabStartY + 40 then
		hoverSearchTab = "main"
	elseif cx >= tabStartX + sizeForTabs and cx <= tabStartX + sizeForTabs + 32 and cy >= tabStartY and cy <= tabStartY + 40 then
		hoverSearchTab = "keys"
	elseif cx >= tabStartX + sizeForTabs * 2 and cx <= tabStartX + sizeForTabs * 2 + 32 and cy >= tabStartY and cy <= tabStartY + 40 then
		hoverSearchTab = "papers"
	end

	if currentSearchTab == "main" then
		dxDrawImage(tabStartX, tabStartY, 32, 40, "files/tabs/bag.png", 0, 0, 0, tocolor(194, 194, 194, 200))
	elseif hoverSearchTab == "main" then
		dxDrawImage(tabStartX, tabStartY, 32, 40, "files/tabs/bag.png", 0, 0, 0, tocolor(194, 194, 194, 150))
	else
		dxDrawImage(tabStartX, tabStartY, 32, 40, "files/tabs/bag.png", 0, 0, 0, tocolor(194, 194, 194, 75))
	end

	if currentSearchTab == "keys" then
		dxDrawImage(tabStartX + sizeForTabs, tabStartY, 32, 40, "files/tabs/key.png", 0, 0, 0, tocolor(194, 194, 194, 200))
	elseif hoverSearchTab == "keys" then
		dxDrawImage(tabStartX + sizeForTabs, tabStartY, 32, 40, "files/tabs/key.png", 0, 0, 0, tocolor(194, 194, 194, 150))
	else
		dxDrawImage(tabStartX + sizeForTabs, tabStartY, 32, 40, "files/tabs/key.png", 0, 0, 0, tocolor(194, 194, 194, 75))
	end

	if currentSearchTab == "papers" then
		dxDrawImage(tabStartX + sizeForTabs * 2, tabStartY, 32, 40, "files/tabs/wallet.png", 0, 0, 0, tocolor(194, 194, 194, 200))
	elseif hoverSearchTab == "papers" then
		dxDrawImage(tabStartX + sizeForTabs * 2, tabStartY, 32, 40, "files/tabs/wallet.png", 0, 0, 0, tocolor(194, 194, 194, 150))
	else
		dxDrawImage(tabStartX + sizeForTabs * 2, tabStartY, 32, 40, "files/tabs/wallet.png", 0, 0, 0, tocolor(194, 194, 194, 75))
	end

	-- ** Itemek
	for i = 0, defaultSettings.slotLimit - 1 do
		local slot = i
		local x = searchPosX + (defaultSettings.slotBoxWidth + 5) * (slot % defaultSettings.width)
		local y = searchPosY + 90 + (defaultSettings.slotBoxHeight + 5) * math.floor(slot / defaultSettings.width)

		if currentSearchTab == "keys" then
			i = i + defaultSettings.slotLimit
		elseif currentSearchTab == "papers" then
			i = i + defaultSettings.slotLimit * 2
		end

		local item = bodyItems[i]

		if cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight then
			if item then
				processTooltip(cx, cy, getItemName(item.itemId), item.itemId, item, false)
			end
		end

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(50, 50, 50, 200))

		if item then
			drawItemPicture(item, x, y)
			dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
		end
	end
end

function isTheItemCopy(item)
	if item.itemId == 309 or item.itemId == 367 then
		return tonumber(item.data3) == 1
	end

	if item.itemId == 264 then
		return item.data3 and utf8.len(item.data3) > 0
	end

	if item.itemId == 207 or item.itemId == 208 or item.itemId == 308 or item.itemId == 310 then
		return utf8.find(item.data1, "iscopy")
	end

	if item.itemId == 289 then
		return utf8.find(item.data3, "iscopy")
	end

	return false
end

function processTooltip(x, y, text, itemId, item, showItem)
	if tonumber(item.serial) and item.serial > 0 then
		text = text .. " #8e8e8e[W" .. item.serial .. serialItems[item.itemId] .. "]"
	end

	if item.nameTag then
		text = text .. " #d75959(" .. item.nameTag .. ")"
	end

	if itemId == 365 then
		text = text .. " #8e8e8e[" .. item.data2 .. "]"
	end

	if itemId == 314 then
		if ticketGroups[item.data1] then
			showTooltip(x, y, text, ticketGroups[item.data1][1], showItem)
		end
	elseif itemId == 370 then
		showTooltip(x, y, text, "Sorszám: " .. item.data1, showItem)
	elseif itemId == 313 then
		showTooltip(x, y, text, "Hátralévő idő a befizetésig: " .. perishableItems[itemId] - item.data3 .. " perc", showTooltip)
	elseif itemId == 366 then
		showTooltip(x, y, text, "Lapok száma: " .. 20 - (tonumber(item.data1) or 0) .. " db", showItem)
	elseif itemId == 367 then
		if tonumber(item.data3) == 1 then
			showTooltip(x, y, text, "#8e8e8e[" .. item.data2 .. "] (másolat)", showItem)
		else
			showTooltip(x, y, text, "#8e8e8e[" .. item.data2 .. "]", showItem)
		end
	elseif perishableItems[itemId] or specialItems[itemId] then
		local health = 0
		local color = ""
		local text2 = ""

		if perishableItems[itemId] then
			health = math.floor(100 - (tonumber(item.data3) or 0) / perishableItems[itemId] * 100)
			color = "#d75959"

			if health > 65 and health <= 100 then
				color = "#3d7abc"
			elseif health > 20 and health <= 65 then
				color = "#FF9600"
			end

			text2 = text2 .. "Állapot: " .. color .. health .. "%"

			if specialItems[itemId] then
				text2 = text2 .. "\n"
			end
		end

		if specialItems[itemId] then
			health = math.floor((tonumber(item.data1) or 0) / specialItems[itemId][2] * 100)
			color = "#3d7abc"

			if health > 65 and health <= 100 then
				color = "#d75959"
			elseif health > 20 and health <= 65 then
				color = "#FF9600"
			end

			text2 = text2 .. "#ffffffElfogyasztva: " .. color .. health .. "%"
		end

		showTooltip(x, y, text, text2, showItem)
	elseif itemId == 312 then
		local health = math.floor(100 - (tonumber(item.data1) or 0) / 100 * 100)
		local color = "#d75959"

		if health > 65 and health <= 100 then
			color = "#3d7abc"
		elseif health > 20 and health <= 65 then
			color = "#FF9600"
		end

		showTooltip(x, y, text, "Állapot: " .. color .. health .. "%", showItem)
	elseif isKeyItem(itemId) then
		local additional = ""

		if itemId == 1 and itemsTableState == "player" and isPedInVehicle(localPlayer) and not showItem then
			local pedveh = getPedOccupiedVehicle(localPlayer)

		 	if isElement(pedveh) and getVehicleController(pedveh) == localPlayer then
		 		if (tonumber(item.data1) or 0) == getElementData(pedveh, defaultSettings.vehicleId) then
		 			additional = "\n#ff9600(( Jelenlegi jármű ))"
		 		end
		 	end
		 end

		showTooltip(x, y, text, "(( Azonosító: " .. item.data1 .. " ))" .. additional, showItem)
	elseif itemId == 309 then
		if tonumber(item.data3) == 0 then
			showTooltip(x, y, text, "Eredeti példány, rendszám: #3d7abc" .. item.data2, showItem)
		else
			showTooltip(x, y, text, "Másolat, rendszám: #3d7abc" .. item.data2, showItem)
		end
	elseif itemId == 412 then
		showTooltip(x, y, text, "Inmate " .. item.data1, showItem)
	elseif itemId == 206 then
		--drawnOnTop = true
		showTooltip(x, y, text, "#DCA300" ..item.data1, showItem)
	elseif itemId == 289 or itemId == 288 then
		if isTheItemCopy(item) then
			showTooltip(x, y, text, "Rendszám: " .. gettok(item.data3, 1, ";") .. " (másolat)", showItem)
		else
			showTooltip(x, y, text, "Rendszám: " .. gettok(item.data3, 1, ";"), showItem)
		end
	elseif itemId == 299 then
		local recipe = tonumber(item.data1) or 1

		if not availableRecipes[recipe] then
			recipe = 1
		end

		showTooltip(x, y, text, availableRecipes[recipe].name, showItem)
	elseif overheatWeapons[getItemWeaponID(itemId)] and itemId ~= 155 then
		local health = 100 - (tonumber(item.data1) or 0)
		local color = "#d75959"

		if health > 65 and health <= 100 then
			color = "#3d7abc"
		elseif health > 20 and health <= 65 then
			color = "#FF9600"
		end

		local warns = tonumber(item.data2) or 0
		local color2 = "#3d7abc"

		if warns >= 3 then
			color2 = "#d75959"
		elseif warns > 0 then
			color2 = "#FF9600"
		end

		showTooltip(x, y, text, "Állapot: " .. color .. health .. "%\n#ffffffFigyelmeztetések: " .. color2 .. warns .. "\n#ffffffSúly: #32b3ef" .. getItemWeight(itemId) * item.amount .. " kg", showItem)
	elseif itemId == 61 or itemId == 62 or itemId == 63 then
		showTooltip(x, y, availableItems[itemId][2], "Súly: #32b3ef" .. getItemWeight(itemId) * item.amount .. " kg", showItem)
	elseif itemId == 207 or itemId == 208 or itemId == 308 or itemId == 310 then
		if isTheItemCopy(item) then
			showTooltip(x, y, text, "Fénymásolt példány", showItem)
		else
			showTooltip(x, y, text, "Lejárat: #32b3ef" .. (item.data3 or "N/A"), showItem)
		end
	elseif itemId == 264 then
		if isTheItemCopy(item) then
			showTooltip(x, y, text, "Fénymásolt példány", showItem)
		else
			showTooltip(x, y, text, "Eredeti példány", showItem)
		end
	-- elseif availableItems[itemId][2] and availableItems[itemId][1] ~= availableItems[itemId][2] then
	-- 	showTooltip(x, y, text, availableItems[itemId][2] .. "\nSúly: #32b3ef" .. getItemWeight(itemId) * item.amount .. " kg", showItem)
	else
		showTooltip(x, y, text, "Súly: #32b3ef" .. getItemWeight(itemId) * item.amount .. " kg", showItem)
	end
end

function drawItemPicture(item, x, y, sx, sy)
	sx = sx or defaultSettings.slotBoxWidth
	sy = sy or defaultSettings.slotBoxHeight

	if not item then
		dxDrawImage(x, y, sx, sy, "files/noitem.png")
	else
		local itemId = item.itemId
		local itemPictureId = itemId - 1
		local itemPicture = false
		local perishableItem = false
		local pictureAlpha = 255

		if itemPictures[itemId] then
			itemPicture = itemPictures[itemId]
		else
			itemPicture = "files/items/" .. itemPictureId .. ".png"
		end

		if grayItemPictures[itemId] then
			if perishableItems[itemId] then
				pictureAlpha = 255 * (1 - (item.data3 or 0) / perishableItems[itemId])
				perishableItem = grayItemPictures[itemId]
			end
		end

		if perishableItem then
			dxDrawImage(x, y, sx, sy, perishableItem)
		end

		if itemId == 295 then
			if item.data2 == "empty" then
				itemPicture = "files/items/" .. itemPictureId .. "_monochrome.png"
			end
		else
			if itemId == 315 and renameProcess == item.slot and item.inUse then
				itemPicture = "files/items/314_2.png"
			elseif isTheItemCopy(item) then
				if grayItemPictures[itemId] then
					itemPicture = grayItemPictures[itemId]
				end
			elseif scratchItems[itemId] then
				if item.data3 == "empty" then
					itemPicture = "files/items/" .. itemPictureId .. "_monochrome.png"
				end
			end
		end

		if pictureAlpha > 0 then
			dxDrawImage(x, y, sx, sy, itemPicture, 0, 0, 0, tocolor(255, 255, 255, pictureAlpha))
		end
	end
end

function getCurrentWeight()
	local weight = 0

	for k, v in pairs(itemsTable.player) do
		if availableItems[v.itemId] then
			weight = weight + getItemWeight(v.itemId) * v.amount
		end
	end

	return weight
end

function isHavePen()
	for k, v in pairs(itemsTable.player) do
		if v.itemId == 312 then
			return true
		end
	end

	return false
end

function playerHasItem(itemId)
	for k, v in pairs(itemsTable.player) do
		if v.itemId == itemId then
			return v
		end
	end

	return false
end

function playerHasItemWithData(itemId, data, dataType)
	data = tonumber(data) or data
	dataType = dataType or "data1"

	for k, v in pairs(itemsTable.player) do
		if v.itemId == itemId and (tonumber(v[dataType]) or v[dataType]) == data then
			return v
		end
	end

	return false
end

function penSetData()
	for k, v in pairs(itemsTable.player) do
		if v.itemId == 312 then
			local damage = tonumber(v.data1 or 0) + 1

			if damage >= 100 then
				triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", v.dbID)
				exports.see_accounts:showInfo("e", "Kifogyott a tollad, ezért eldobtad.")
				break
			end

			triggerServerEvent("damagePen", localPlayer, v.dbID, damage)
			break
		end
	end

	return false
end

function notepadSetData()
	for k, v in pairs(itemsTable.player) do
		if v.itemId == 366 then
			local usedpages = tonumber(v.data1 or 0) + 1

			if usedpages >= 20 then
				triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", v.dbID)
				exports.see_accounts:showInfo("e", "Kifogyott a jegyzetfüzetedből a lap, ezért eldobtad.")
				break
			end

			triggerServerEvent("damagePen", localPlayer, v.dbID, usedpages) -- ugyan azt csinálja, ezért ugyan az az event név
			break
		end
	end

	return false
end

function unuseItem(dbID)
	if dbID then
		dbID = tonumber(dbID)

		for k, v in pairs(itemsTable.player) do
			if v.dbID == dbID then
				itemsTable.player[v.slot].inUse = false
				break
			end
		end
	end
end

local weaponFireCount = 0

addEventHandler("onClientPlayerWeaponFire", localPlayer,
	function (weaponId)
		local weaponInUse = false
		local ammoInUse = false

		for k, v in pairs(itemsTable.player) do
			if v.inUse then
				if isWeaponItem(v.itemId) then
					weaponInUse = v
				elseif isAmmoItem(v.itemId) then
					ammoInUse = v
				end
			end
		end

		local itemAmmoId = getItemAmmoID(weaponInUse.itemId)

		if weaponInUse and not ammoInUse and itemAmmoId and (itemAmmoId <= 0 or itemAmmoId == weaponInUse.itemId) then
			ammoInUse = weaponInUse
		end

		if weaponInUse and ammoInUse and ammoInUse.amount and weaponInUse.itemId ~= 155 and weaponInUse.itemId ~= 99 then
			if weaponInUse.itemId ~= ammoInUse.itemId and getPedTotalAmmo(localPlayer) > ammoInUse.amount - 1 and ammoInUse.amount - 1 == 0 then
				enableWeaponFire(false)
			end

			if ammoInUse.amount - 1 > 0 then
				if itemsTable.player[ammoInUse.slot].amount then
					weaponFireCount = weaponFireCount + 1

					itemsTable.player[ammoInUse.slot].amount = itemsTable.player[ammoInUse.slot].amount - 1

					if weaponId == 24 or weaponId == 25 or weaponId == 33 or weaponId == 34 then
						triggerServerEvent("takeAmountFrom", localPlayer, ammoInUse.dbID, 1)
						weaponFireCount = 0
					elseif weaponId == 16 or weaponId == 17 or weaponId == 18 then
						triggerServerEvent("takeAmountFrom", localPlayer, ammoInUse.dbID, 1)
						weaponFireCount = 0
					elseif weaponFireCount == 4 then
						triggerServerEvent("takeAmountFrom", localPlayer, ammoInUse.dbID, 4)
						weaponFireCount = 0
					end

					triggerEvent("movedItemInInv", localPlayer, true)
				end
			else
				triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", itemsTable.player[ammoInUse.slot].dbID)
				itemsTable.player[ammoInUse.slot] = nil
			end
		end
	end)

local playerNoAmmo = false

function enableWeaponFire(state)
	if state then
		if playerNoAmmo then
			exports.see_controls:toggleControl({"fire", "vehicle_fire", "action"}, true)
			playerNoAmmo = false
		end
	else
		if not playerNoAmmo then
			exports.see_controls:toggleControl({"fire", "vehicle_fire", "action"}, false)
			playerNoAmmo = true
		end
	end
end

local itemlistState = false
local itemlistWidth = 800
local itemlistHeight = 600
local itemlistPosX = screenX / 2 - itemlistWidth / 2
local itemlistPosY = screenY / 2 - itemlistHeight / 2
local itemlistDragging = false
local itemlistTable = false
local itemlistOffset = 0
local itemlistText = ""

addCommandHandler("itemlist",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			itemlistState = not itemlistState

			if itemlistState then
				if not itemlistTable then
					itemlistTable = {}

					for i = 1, #availableItems do
						table.insert(itemlistTable, i)
					end
				end

				addEventHandler("onClientRender", getRootElement(), itemlistRender, true, "low-1000")
				addEventHandler("onClientCharacter", getRootElement(), itemlistCharacter)
				addEventHandler("onClientKey", getRootElement(), itemlistKey)
				showCursor(true)
			else
				removeEventHandler("onClientRender", getRootElement(), itemlistRender)
				removeEventHandler("onClientCharacter", getRootElement(), itemlistCharacter)
				removeEventHandler("onClientKey", getRootElement(), itemlistKey)
				showCursor(false)
			end
		end
	end)

function itemlistKey(key, press)
	if isCursorShowing() then
		cancelEvent()

		if key == "mouse_wheel_up" then
			if itemlistOffset > 0 then
				itemlistOffset = itemlistOffset - 1
			end
		end

		if key == "mouse_wheel_down" then
			if itemlistOffset < #itemlistTable - 14 then
				itemlistOffset = itemlistOffset + 1
			end
		end

		if press and key == "backspace" then
			itemlistText = utf8.sub(itemlistText, 1, utf8.len(itemlistText) - 1)
			searchItems()
		end
	end
end

function itemlistCharacter(character)
	if isCursorShowing() then
		itemlistText = itemlistText .. character
		searchItems()
	end
end

function searchItems()
	itemlistTable = {}

	if utf8.len(itemlistText) < 1 then
		for i = 1, #availableItems do
			table.insert(itemlistTable, i)
		end
	elseif tonumber(itemlistText) then
		local id = tonumber(itemlistText)

		if availableItems[id] then
			table.insert(itemlistTable, id)
		end
	else
		for i = 1, #availableItems do
			if utf8.find(utf8.lower(availableItems[i][1]), utf8.lower(itemlistText)) then
				table.insert(itemlistTable, i)
			end
		end
	end

	itemlistOffset = 0
end

function itemlistRender()
	local exitButtonAlpha = 200

	if isCursorShowing() then
		local cx, cy = getCursorPosition()

		cx = cx * screenX
		cy = cy * screenY

		if cx >= itemlistPosX + itemlistWidth - 100 and cx <= itemlistPosX + itemlistWidth - 10 and cy >= itemlistPosY + itemlistHeight - 30 and cy <= itemlistPosY + itemlistHeight - 10 then
			exitButtonAlpha = 255

			if getKeyState("mouse1") then
				itemlistState = false
				removeEventHandler("onClientRender", getRootElement(), itemlistRender)
				removeEventHandler("onClientCharacter", getRootElement(), itemlistCharacter)
				removeEventHandler("onClientKey", getRootElement(), itemlistKey)
				showCursor(false)
				return
			end
		end

		if not itemlistDragging then
			if getKeyState("mouse1") and cx >= itemlistPosX and cx <= itemlistPosX + itemlistWidth and cy >= itemlistPosY and cy <= itemlistPosY + itemlistHeight then
				itemlistDragging = {cx, cy, itemlistPosX, itemlistPosY}
			end
		elseif getKeyState("mouse1") then
			itemlistPosX = cx - itemlistDragging[1] + itemlistDragging[3]
			itemlistPosY = cy - itemlistDragging[2] + itemlistDragging[4]
		else
			itemlistDragging = false
		end
	end

	dxDrawRectangle(itemlistPosX, itemlistPosY, itemlistWidth, itemlistHeight, tocolor(0, 0, 0, 150))
	dxDrawRectangle(itemlistPosX + 8, itemlistPosY + 8, itemlistWidth - 16, 30, tocolor(0, 0, 0, 100))
	dxDrawText(itemlistText, itemlistPosX + 16, itemlistPosY + 8, 0, itemlistPosY + 38, tocolor(255, 255, 255), 0.6, Roboto, "left", "center")

	local oneSize = defaultSettings.slotBoxHeight / 0.915

	for i = 1, 14 do
		local y = itemlistPosY + 46 + (i - 1) * oneSize

		if i % 2 == 0 then
			dxDrawRectangle(itemlistPosX, y, itemlistWidth, oneSize, tocolor(0, 0, 0, 75))
		else
			dxDrawRectangle(itemlistPosX, y, itemlistWidth, oneSize, tocolor(0, 0, 0, 100))
		end

		local item = itemlistTable[i + itemlistOffset]

		if item then
			if fileExists("files/items/" .. item - 1 .. ".png") then
				dxDrawImage(itemlistPosX + 4, y + 4, oneSize - 8, oneSize - 8, "files/items/" .. item - 1 .. ".png")
			else
				dxDrawImage(itemlistPosX + 4, y + 4, oneSize - 8, oneSize - 8, "files/items/nopic.png")
			end

			dxDrawText("[" .. item .. "] " .. availableItems[item][1], itemlistPosX + oneSize, y, 0, y + oneSize / 2 + 3, tocolor(255, 255, 255), 0.5, Roboto, "left", "center")
			dxDrawText(availableItems[item][2], itemlistPosX + oneSize, y + oneSize / 2 - 3, 0, y + oneSize, tocolor(200, 200, 200), 0.45, Roboto, "left", "center")
		end
	end

	if #itemlistTable > 14 then
		dxDrawRectangle(itemlistPosX + itemlistWidth - 5, itemlistPosY + 46, 5, 504, tocolor(0, 0, 0, 100))
		dxDrawRectangle(itemlistPosX + itemlistWidth - 5, itemlistPosY + 46 + (504 / #itemlistTable) * itemlistOffset, 5, (504 / #itemlistTable) * 14, tocolor(61, 122, 188, 150))
	end

	dxDrawRectangle(itemlistPosX + itemlistWidth - 100, itemlistPosY + itemlistHeight - 30, 90, 20, tocolor(215, 89, 89, exitButtonAlpha))
	dxDrawText("Bezárás", itemlistPosX + itemlistWidth - 100, itemlistPosY + itemlistHeight - 30, itemlistPosX + itemlistWidth - 10, itemlistPosY + itemlistHeight - 10, tocolor(0, 0, 0), 0.45, Roboto, "center", "center")
end

function render3DNote(text, iscopy)
	local rt = dxCreateRenderTarget(399, 527, true)
	local font = dxCreateFont("files/fonts/hand.ttf", 16, false, "antialiased")

	text = processNotepadTextEx(text, font)
	text[0] = "((" .. getElementData(localPlayer, "visibleName"):gsub("_", " ") .. "))"

	dxSetRenderTarget(rt)

	if iscopy then
		dxDrawImage(0, 0, 399, 527, "files/pagecopy.png")
	else
		dxDrawImage(0, 0, 399, 527, "files/page.png")
	end

	for i = 0, 23 do
		local x, y = 0, 0 + 40

		if iscopy then
			dxDrawLine(x + 67, y + 22 * (i - 2) - 1, x + 399, y + 22 * (i - 2) - 1, tocolor(110, 110, 110))
		else
			dxDrawLine(x + 67, y + 22 * (i - 2) - 1, x + 399, y + 22 * (i - 2) - 1, tocolor(0, 15, 200, 185))
		end

		if text[i] then
			if iscopy then
				dxDrawText(text[i], x + 70, 0, x + 395, y + 22 * (i - 1) + 5, tocolor(77, 77, 77), 1, font, i > 0 and "left" or "center", "bottom", true)
			else
				dxDrawText(text[i], x + 70, 0, x + 395, y + 22 * (i - 1) + 5, tocolor(0, 15, 85, 185), 1, font, i > 0 and "left" or "center", "bottom", true)
			end
		end
	end

	dxSetRenderTarget()

	if isElement(font) then
		destroyElement(font)
	end

	if isElement(rt) then
		local pixels = dxGetTexturePixels(rt)
		pixels = dxConvertPixels(pixels, "png")
		destroyElement(rt)
		return pixels
	end

	return false
end

addEvent("gotRequestWallNotes", true)
addEventHandler("gotRequestWallNotes", getRootElement(),
	function (datas)
		wallNotes = datas

		local x, y, z = getElementPosition(localPlayer)

		for id in pairs(wallNotes) do
			wallNotes[id][1] = dxCreateTexture(wallNotes[id][1], "dxt3")
			wallNotes[id][9] = createColSphere(wallNotes[id][4], wallNotes[id][5], wallNotes[id][6], wallNoteRadius)

			setElementInterior(wallNotes[id][9], wallNotes[id][7])
			setElementDimension(wallNotes[id][9], wallNotes[id][8])

			if getDistanceBetweenPoints3D(wallNotes[id][4], wallNotes[id][5], wallNotes[id][6], x, y, z) < wallNoteRadius then
				nearbyWallNotes[id] = true
			end

			wallNoteCol[wallNotes[id][9]] = id
		end
	end)

addEvent("deleteWallNote", true)
addEventHandler("deleteWallNote", getRootElement(),
	function (id)
		nearbyWallNotes[id] = nil

		if wallNotes[id] then
			if isElement(wallNotes[id][9]) then
				destroyElement(wallNotes[id][9])
			end

			wallNoteCol[id] = nil
		end

		wallNotes[id] = nil
	end)

addEvent("addWallNote", true)
addEventHandler("addWallNote", getRootElement(),
	function (id, data)
		wallNotes[id] = data
		wallNotes[id][1] = dxCreateTexture(wallNotes[id][1], "dxt3")
		wallNotes[id][9] = createColSphere(wallNotes[id][4], wallNotes[id][5], wallNotes[id][6], wallNoteRadius)

		setElementInterior(wallNotes[id][9], wallNotes[id][7])
		setElementDimension(wallNotes[id][9], wallNotes[id][8])

		local x, y, z = getElementPosition(localPlayer)

		if getDistanceBetweenPoints3D(wallNotes[id][4], wallNotes[id][5], wallNotes[id][6], x, y, z) < wallNoteRadius then
			nearbyWallNotes[id] = true
		end

		wallNoteCol[wallNotes[id][9]] = id
	end)

addEventHandler("onClientColShapeHit", getRootElement(),
	function (element, matchdim)
		if element == localPlayer and matchdim and wallNoteCol[source] then
			nearbyWallNotes[wallNoteCol[source]] = true
		end
	end)

addEventHandler("onClientColShapeLeave", getRootElement(),
	function (element, matchdim)
		if element == localPlayer and matchdim and wallNoteCol[source] then
			nearbyWallNotes[wallNoteCol[source]] = nil
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if state == "up" and hoverWallNote then
			triggerServerEvent("deleteWallNote", localPlayer, hoverWallNote)
		end
	end)

local nametagScale = (screenX + 1920) / 3840

addEventHandler("onClientRender", getRootElement(),
	function ()
		local dimension = getElementDimension(localPlayer)
		local cx, cy = getCursorPosition()
		local camx, camy, camz = getCameraMatrix()

		if isCursorShowing() then
			cx, cy = cx * screenX, cy * screenY
		else
			cx, cy = -1, -1
		end

		hoverWallNote = false

		for id in pairs(nearbyWallNotes) do
			local note = wallNotes[id]

			if note and note[8] == dimension then
				local x, y, z = note[4], note[5], note[6] - 0.2

				if isLineOfSightClear(camx, camy, camz, x, y, z, true, false, false, true, false, true, false) then
					local sx, sy = getScreenFromWorldPosition(x, y, z, 0, false)
					local sx2, sy2 = getScreenFromWorldPosition(x, y, z + 0.4, 0, false)

					if sx and sy then
						local dist = getDistanceBetweenPoints3D(camx, camy, camz, x, y, z)

						if dist <= 7 then
							local scale = interpolateBetween(1, 0, 0, 0.45, 0, 0, dist / 7, "OutQuad") * nametagScale

							if sx2 then
								dxDrawText(note[12], sx2 - 10, 0, sx2 + 10, sy2 - 4, tocolor(255, 255, 255), scale, Roboto, "center", "bottom")
							end

							dxDrawImage(math.floor(sx - 32 * scale), math.floor(sy + 32 * scale), math.floor(64 * scale), math.floor(64 * scale), "files/search.png")

							if cx >= sx - 32 * scale and cy >= sy + 32 * scale and cx <= sx + 32 * scale and cy <= sy + 96 * scale then
								if myAdminLevel >= 1 or note[2] == myCharacterId then
									dxDrawRectangle(cx - 199 - 4, cy - 4 - 263, 407, 555, tocolor(0, 0, 0, 150), true)
									dxDrawText("Kattints egyet a törléshez.", cx - 10, cy + 263 + 4, cx + 10, cy + 263 + 4 + 20, tocolor(255, 255, 255), 0.45, Roboto, "center", "center", false, false, true)
									hoverWallNote = id
								else
									dxDrawRectangle(cx - 199 - 4, cy - 4 - 263, 407, 535, tocolor(0, 0, 0, 150), true)
								end

								dxDrawImage(cx - 199, cy - 263, 399, 527, note[1], 0, 0, 0, tocolor(255, 255, 255), true)
							end
						end
					end
				end

				dxDrawMaterialLine3D(note[4], note[5], note[6] + 0.2, note[4], note[5], note[6] - 0.2, note[1], 0.3, tocolor(255, 255, 255), note[4] + note[10], note[5] + note[11], note[6])
			else
				nearbyWallNotes[id] = nil
			end
		end
	end)
