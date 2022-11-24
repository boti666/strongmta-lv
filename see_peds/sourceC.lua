local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = 1

function respc(x)
	return math.ceil(x * responsiveMultipler)
end

local itemNames = {}

local currentPedId = false
local pedOwnerId = false

local itemTypes = {}
local availableItems = {}
local availableItemsKeyed = {}
local itemPrices = {}
local itemAmounts = {}
local currentBalance = 0

local availableCategories = {}
local selectedCategory = 1
local itemsInCategory = {}
local visibleItem = 0
local itemCount = 0

local offsetItems = 0

local isOwner = false
local ownerMode = false

local buttons = {}
local activeButton = false

local Roboto = false
local RobotoL = false

local promptState = false
local promptItemId = false
local promptInputText = ""

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedRes)
		if getResourceName(startedRes) == "see_items" then
			itemNames = exports.see_items:getItemNameList()
		elseif source == getResourceRootElement() then
			local see_items = getResourceFromName("see_items")

			if see_items and getResourceState(see_items) == "running" then
				itemNames = exports.see_items:getItemNameList()
			end
		end
	end)

addCommandHandler("nearbypeds",
	function (commandName, distance)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			distance = tonumber(distance) or 15

			local x, y, z = getElementPosition(localPlayer)
			local nearby = {}

			for k, v in pairs(getElementsByType("ped", getResourceRootElement(), true)) do
				local pedId = getElementData(v, "pedId")

				if pedId then
					local tx, ty, tz = getElementPosition(v)

					if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) <= distance then
						table.insert(nearby, {pedId, getElementData(v, "visibleName"), getElementData(v, "interiorId") or -1})
					end
				end
			end

			if #nearby > 0 then
				outputChatBox("#3d7abc[Ped]: #ffffffKözeledben lévő pedek (" .. distance .. " yard):", 255, 255, 255, true)
				
				for k, v in ipairs(nearby) do
					outputChatBox("    * #3d7abcAzonosító: #ffffff" .. v[1] .. " | #3d7abcNév: #ffffff" .. utf8.gsub(v[2], "_", " ") .. " | #3d7abcInti: #ffffff" .. v[3], 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[Ped]: #ffffffNincs egyetlen ped sem a közeledben.", 255, 255, 255, true)
			end
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
		if isElement(clickedElement) then
			if not currentPedId then
				if button == "right" then
					if state == "up" then
						local pedId = getElementData(clickedElement, "pedId")

						if pedId then
							if isElementWithinColShape(localPlayer, getElementData(clickedElement, "pedColShapeElement")) then
								if getElementData(clickedElement, "pedType") == 10 then
									local playedMinutes = getElementData(localPlayer, "char.playedMinutes") or 0

									if exports.see_core:getLevel(nil, playedMinutes) < 10 then
										exports.see_hud:showInfobox("e", "Minimum 10 szint kell ahhoz, hogy fegyvert vehess!")
										return
									end

									if getElementData(localPlayer, "license.gun") == 0 then
										--if exports.see_items:hasItem(localPlayer, 308) then
										exports.see_hud:showInfobox("e", "Fegyverengedély kell ahhoz, hogy fegyvert vehess!")
										return
									end
								end

								isOwner = false
								itemTypes = {}
								availableItems = {}
								availableItemsKeyed = {}
								itemPrices = {}
								itemAmounts = {}
								currentBalance = 0
								offsetItems = 0

								availableCategories = {}
								selectedCategory = 1
								itemsInCategory = {}
								visibleItem = 0

								currentPedId = pedId

								triggerServerEvent("requestPedItemList", localPlayer, pedId)

								RobotoL = dxCreateFont("files/RobotoL.ttf", 15, false, "antialiased")
								Roboto = dxCreateFont("files/Roboto.ttf", 10, false, "antialiased")

								showCursor(true)
							end
						end
					end
				end
			end
		end
	end)

function closePanel()
	currentPedId = false
	pedOwnerId = false

	promptState = false
	promptItemId = false
	promptInputText = false

	if isElement(RobotoL) then
		destroyElement(RobotoL)
	end
	RobotoL = nil

	if isElement(Roboto) then
		destroyElement(Roboto)
	end
	Roboto = nil

	showCursor(false)
end

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function ()
		if source == localPlayer then
			if currentPedId then
				if currentPedId == getElementData(source, "pedColShape") then
					closePanel()
				end
			end
		end
	end)

function checkOwnership()
	isOwner = false

	if pedOwnerId then
		if exports.see_interiors:getInteriorOwner(pedOwnerId) == getElementData(localPlayer, "char.ID") then
			isOwner = true
		end
	end

	return isOwner
end

addEvent("gotPedItems", true)
addEventHandler("gotPedItems", getRootElement(),
	function (items, prices, amounts, pedId, types, balance, ownerId)
		availableItems = items

		if not availableItems then
			availableItems = {}
		end

		for i = 1, #items do
			availableItemsKeyed[items[i]] = true
		end

		itemPrices = prices

		if not itemPrices then
			itemPrices = {}
		end

		itemAmounts = amounts

		if not itemAmounts then
			itemAmounts = {}
		end

		currentPedId = pedId
		pedOwnerId = ownerId

		for i = 1, #types do
			if types[i] then
				availableCategories[i] = categories[types[i]]
			end
		end

		for i = 1, #types do
			if types[i] then
				itemsInCategory[i] = itemsForChoosePlain[types[i]]
			end
		end

		currentBalance = balance

		local currentMode = ownerMode
		ownerMode = false

		if checkOwnership() then
			ownerMode = currentMode
		end
	end)

addEvent("setPedBalance", true)
addEventHandler("setPedBalance", getRootElement(),
	function (balance)
		currentBalance = balance
	end)

addEvent("refreshPedItemStock", true)
addEventHandler("refreshPedItemStock", getRootElement(),
	function (itemId, newAmount, balance)
		itemAmounts[itemId] = newAmount
		currentBalance = balance
	end)

addEvent("refreshPedItemPrice", true)
addEventHandler("refreshPedItemPrice", getRootElement(),
	function (itemId, newPrice)
		itemPrices[itemId] = newPrice
	end)

function drawButton(name, title, x, y, bgcolor, hovercolor, scale, scale2)
	if activeButton == name then
		bgcolor = hovercolor
	end

	local sx = dxGetTextWidth(title, scale or 0.65, RobotoL) + 2.5
	local sy = dxGetFontHeight(scale or 0.65, RobotoL)

	dxDrawRectangle(x, y, sx, sy, bgcolor)
	dxDrawText(title, x, y, x + sx, y + sy, tocolor(0, 0, 0), (scale2 or scale or 0.65) - 0.025, RobotoL, "center", "center")
	
	buttons[name] = {x, y, sx, sy}

	return x + sx
end

function formatNumber(amount, stepper)
	if not tonumber(amount) then
		return amount
	end

	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		if promptState then
			local sx = 350
			local sy = 175

			local x = screenX / 2 - sx / 2
			local y = screenY / 2 - sy / 2

			buttons = {}

			dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 200))

			if promptState == "getOutMoney" then
				dxDrawText("Pénzkifizetés", x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Pénzkifizetés", x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				dxDrawText("Összeg: " .. formatNumber(tonumber(promptInputText) or 0) .. " $\nJelenlegi egyenleg: " .. formatNumber(currentBalance) .. " $\nVégeredmény: " .. formatNumber(currentBalance - (tonumber(promptInputText) or 0)) .. " $\n#3d7abcAdd meg az összeget a billentyűzeteddel!", x + 10, y + 10, x + sx - 10, y + sy - 10 - 35 - 10, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			
				buttons["getOutMoneyOk"] = {x + 75, y + sy - 45, sx - 150, 35}

				if activeButton == "getOutMoneyOk" then
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 150))
				end

				dxDrawText("Kifizetés", x + 75, y + sy - 45, x + sx - 75, y + sy - 10, tocolor(255, 255, 255), 0.9, RobotoL, "center", "center")
			elseif promptState == "putInMoney" then
				dxDrawText("Pénzbefizetés", x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Pénzbefizetés", x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				dxDrawText("Összeg: " .. formatNumber(tonumber(promptInputText) or 0) .. " $\nJelenlegi egyenleg: " .. formatNumber(currentBalance) .. " $\nVégeredmény: " .. formatNumber(currentBalance + (tonumber(promptInputText) or 0)) .. " $\n#3d7abcAdd meg az összeget a billentyűzeteddel!", x + 10, y + 10, x + sx - 10, y + sy - 10 - 35 - 10, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			
				buttons["putInMoneyOk"] = {x + 75, y + sy - 45, sx - 150, 35}

				if activeButton == "putInMoneyOk" then
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 150))
				end

				dxDrawText("Befizetés", x + 75, y + sy - 45, x + sx - 75, y + sy - 10, tocolor(255, 255, 255), 0.9, RobotoL, "center", "center")
			elseif promptState == "buyItem" then
				dxDrawText("Vásárlás: " .. itemNames[promptItemId], x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Vásárlás: " .. itemNames[promptItemId], x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				dxDrawText("Mennyiség: " .. (promptInputText or "") .. " db\nEgységár: " .. formatNumber(itemPrices[promptItemId] or 0) .. " $\nÖsszesen: " .. formatNumber((itemPrices[promptItemId] or 0) * (promptInputText or 1)) .. " $\n#3d7abcAdd meg a mennyiséget a billentyűzeteddel!", x + 10, y + 10, x + sx - 10, y + sy - 10 - 35 - 10, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			
				buttons["buyItemOk"] = {x + 75, y + sy - 45, sx - 150, 35}

				if activeButton == "buyItemOk" then
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 150))
				end

				dxDrawText("Vásárlás", x + 75, y + sy - 45, x + sx - 75, y + sy - 10, tocolor(255, 255, 255), 0.9, RobotoL, "center", "center")
			elseif promptState == "setprice" then
				dxDrawText("Beárazás: " .. itemNames[promptItemId], x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Beárazás: " .. itemNames[promptItemId], x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				dxDrawText("Ár: " .. (promptInputText or "") .. " $\nÁrrés: " .. (promptInputText or 0) - itemBasePrices[promptItemId] .. " $\nNagyker ár: " .. itemBasePrices[promptItemId] .. " $\n#3d7abcAdd meg az árat a billentyűzeteddel!", x + 10, y + 10, x + sx - 10, y + sy - 10 - 35 - 10, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			
				buttons["setPriceOk"] = {x + 75, y + sy - 45, sx - 150, 35}

				if activeButton == "setPriceOk" then
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 150))
				end

				dxDrawText("Beárazás", x + 75, y + sy - 45, x + sx - 75, y + sy - 10, tocolor(255, 255, 255), 0.9, RobotoL, "center", "center")
			else
				dxDrawText("Rendelés: " .. itemNames[promptItemId], x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Rendelés: " .. itemNames[promptItemId], x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				dxDrawText("Jelenlegi készleten: " .. (itemAmounts[promptItemId] or 0) .. " db\nRendelni kívánt mennyiség: " .. (promptInputText or "") .. " db\nÁr: " .. itemBasePrices[promptItemId] .. " $/db\nÖsszesen: " .. formatNumber((tonumber(promptInputText) or 0) * itemBasePrices[promptItemId]) .. " $\n#3d7abcAdd meg a mennyiséget a billentyűzeteddel!", x + 10, y + 10, x + sx - 10, y + sy - 10 - 35 - 10, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			
				buttons["addStockOk"] = {x + 75, y + sy - 45, sx - 150, 35}

				if activeButton == "addStockOk" then
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 150))
				end

				dxDrawText("Megrendelés", x + 75, y + sy - 45, x + sx - 75, y + sy - 10, tocolor(255, 255, 255), 0.9, RobotoL, "center", "center")
			end

			local cx, cy = getCursorPosition()

			activeButton = false

			if tonumber(cx) then
				cx = cx * screenX
				cy = cy * screenY

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			end
		elseif currentPedId then
			local oneSize = 40
			local tabNum = 12

			local sx = 400
			local sy = oneSize * tabNum

			local x = screenX / 2 - sx / 2
			local y = screenY / 2 - sy / 2

			local logoWidth = 165 * 0.55
			local logoHeight = 132 * 0.55

			buttons = {}

			dxDrawImage(math.floor(screenX / 2 - logoWidth / 2), math.floor(y - logoHeight - 35), logoWidth, logoHeight, "files/logo.png")

			if not ownerMode then
				dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 200))

				dxDrawText("Bolt", x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Bolt", x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				for i = 1, tabNum do
					local itemId = availableItems[i + offsetItems]

					if itemId then
						local itemY = y + oneSize * (i - 1)

						if i % 2 == 1 then
							dxDrawRectangle(x, itemY, sx, oneSize, tocolor(0, 0, 0, 75))
						else
							dxDrawRectangle(x, itemY, sx, oneSize, tocolor(0, 0, 0, 125))
						end

						dxDrawImage(math.floor(x + 2), math.floor(itemY + 2), 36, 36, ":see_items/files/items/" .. itemId - 1 .. ".png")
						
						dxDrawText(itemNames[itemId], x + 2 + 36 + 5, itemY + 2, 0, 0, tocolor(255, 255, 255), 1, Roboto)
						
						dxDrawText("Ár: " .. itemPrices[itemId] .. " $", x + 2 + 36 + 10, itemY + 2 + dxGetFontHeight(1, Roboto), 0, 0, tocolor(255, 255, 255), 0.65, RobotoL)
						
						drawButton("buyitem_" .. itemId, "Vásárlás", x + sx - 15 - dxGetTextWidth("Vásárlás", 0.8, RobotoL) - 2.5, itemY + 20 - dxGetFontHeight(0.8, RobotoL) / 2, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.65)
					end
				end

				if #availableItems > tabNum then
					local totalSize = oneSize * tabNum
					local gripSize = totalSize / #availableItems

					dxDrawRectangle(x + sx - 5, y, 5, totalSize, tocolor(0, 0, 0, 200))

					dxDrawRectangle(x + sx - 5, y + offsetItems * gripSize, 5, tabNum * gripSize, tocolor(61, 122, 188, 150))
				end

				drawButton("exit", "Kilépés", x + sx - dxGetTextWidth("Kilépés", 0.8, RobotoL) - 2.5, y - dxGetFontHeight(0.8, RobotoL) - 5, tocolor(215, 89, 89, 150), tocolor(215, 89, 89, 200), 0.8, 0.7)
				
				if isOwner then
					drawButton("changeOwnerMode", "Tulajdonosi mód", x + sx - dxGetTextWidth("Tulajdonosi mód", 0.8, RobotoL) - 2.5, y + sy + 5, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.7)
				end
			else
				if not availableCategories[selectedCategory] then
					return
				end

				x = screenX / 2 - sx - 2.5

				-- ** Háttér
				dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 200))

				-- ** Cím
				dxDrawText("Jelenlegi kínálat", x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Jelenlegi kínálat", x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				-- ** Content
				oneSize = 60
				tabNum = 8

				for i = 1, tabNum do
					local itemId = availableItems[i + offsetItems]

					if itemId then
						local itemX = x + 2
						local itemY = y + oneSize * (i - 1)

						if i % 2 == 1 then
							dxDrawRectangle(x, itemY, sx, oneSize, tocolor(0, 0, 0, 75))
						else
							dxDrawRectangle(x, itemY, sx, oneSize, tocolor(0, 0, 0, 125))
						end

						dxDrawImage(math.floor(itemX), math.floor(itemY + oneSize / 2 - 18), 36, 36, ":see_items/files/items/" .. itemId - 1 .. ".png")
						
						itemX = itemX + 36 + 5

						dxDrawText(itemNames[itemId], itemX, itemY + 2, 0, 0, tocolor(255, 255, 255), 1, Roboto)

						itemX = itemX + 5
						
						dxDrawText("Ár: " .. itemPrices[itemId] .. " $ Árrés: " .. itemPrices[itemId] - itemBasePrices[itemId] .. " $ Nagyker ár: " .. itemBasePrices[itemId] .. " $ \nKészleten: " .. (itemAmounts[itemId] or 0) .. " db", itemX, itemY + 2 + dxGetFontHeight(1, Roboto), x + sx, itemY + 2, tocolor(255, 255, 255), 0.65, RobotoL)

						itemX = itemX + 5
						itemY = itemY + 2 + dxGetFontHeight(1, Roboto) + dxGetFontHeight(0.65, RobotoL)

						local w1 = dxGetTextWidth("Készleten: " .. (itemAmounts[itemId] or 0) .. " db", 1, Roboto)

						itemX = drawButton("addstock_" .. itemId, "Rendelés", itemX + w1, itemY, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200))

						itemX = drawButton("setprice_" .. itemId, "Beárazás", itemX + 5, itemY, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200))

						itemX = drawButton("removefromlist_" .. itemId, "Eltávolítás", itemX + 5, itemY, tocolor(215, 89, 89, 150), tocolor(215, 89, 89, 200))
					end
				end

				if #availableItems > tabNum then
					local totalSize = oneSize * tabNum
					local gripSize = totalSize / #availableItems

					dxDrawRectangle(x + sx - 5, y, 5, totalSize, tocolor(0, 0, 0, 200))

					dxDrawRectangle(x + sx - 5, y + offsetItems * gripSize, 5, tabNum * gripSize, tocolor(61, 122, 188, 150))
				end

				x = screenX / 2 + 2.5

				-- ** Háttér
				dxDrawRectangle(x, y + 40, sx, sx, tocolor(0, 0, 0, 200))

				-- ** Cím
				dxDrawText("Választék", x + 1, y - 35 + 1, x + sx + 1, y + 1, tocolor(0, 0, 0), 1, RobotoL, "center", "center")
				dxDrawText("Választék", x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				-- **  Kategóriák
				local holderSize = sx / 3

				-- Előző oldal
				if activeButton == "setcategory_" .. selectedCategory - 1 then
					dxDrawRectangle(x, y, holderSize, 35, tocolor(61, 122, 188, 175))
				else
					dxDrawRectangle(x, y, holderSize, 35, tocolor(0, 0, 0, 175))
				end

				if availableCategories[selectedCategory - 1] then
					dxDrawText(availableCategories[selectedCategory - 1], x, y, x + holderSize, y + 35, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center")
					buttons["setcategory_" .. selectedCategory - 1] = {x, y, holderSize, 35}
				end

				-- Jelenlegi oldal
				dxDrawRectangle(x + holderSize, y, holderSize, 35, tocolor(0, 0, 0, 225))
				dxDrawText(availableCategories[selectedCategory], x + holderSize, y, x + holderSize * 2, y + 35, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center")
				
				-- Következő oldal
				if activeButton == "setcategory_" .. selectedCategory + 1 then
					dxDrawRectangle(x + holderSize * 2, y, holderSize, 35, tocolor(61, 122, 188, 175))
				else
					dxDrawRectangle(x + holderSize * 2, y, holderSize, 35, tocolor(0, 0, 0, 175))
				end

				if availableCategories[selectedCategory + 1] then
					dxDrawText(availableCategories[selectedCategory + 1], x + holderSize * 2, y, x + holderSize * 3, y + 35, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center")
					buttons["setcategory_" .. selectedCategory + 1] = {x + holderSize * 2, y, holderSize, 35}
				end

				-- ** Választék
				local itemY = y + 40

				oneSize = 40
				tabNum = 10
				itemCount = 0

				for i = 1, #itemsInCategory[selectedCategory] do
					local itemId = itemsInCategory[selectedCategory][i]

					if itemId and not availableItemsKeyed[itemId] then
						itemCount = itemCount + 1

						if itemCount > visibleItem and itemCount <= visibleItem + tabNum then
							local index = (itemY - y) / oneSize + 1

							if index % 2 == 1 then
								dxDrawRectangle(x, itemY, sx, oneSize, tocolor(0, 0, 0, 75))
							else
								dxDrawRectangle(x, itemY, sx, oneSize, tocolor(0, 0, 0, 125))
							end

							local x2 = x + 2
							local y2 = itemY + 2

							dxDrawImage(math.floor(x2), math.floor(itemY + oneSize / 2 - 18), 36, 36, ":see_items/files/items/" .. itemId - 1 .. ".png")
							
							x2 = x2 + 36 + 5

							dxDrawText(itemNames[itemId], x2, y2, 0, 0, tocolor(255, 255, 255), 1, Roboto)

							local fontHeight = dxGetFontHeight(1, Roboto)

							x2 = x2 + 5
							y2 = y2 + fontHeight

							if itemAmounts[itemId] then
								local amount = itemAmounts[itemId] or 0

								if amount > 0 then
									dxDrawText("Nagyker ár: " .. itemBasePrices[itemId] .. " $ Készleten: " .. amount .. " db", x2, y2, 0, 0, tocolor(255, 255, 255), 0.65, RobotoL)
								end
							end

							dxDrawText("Nagyker ár: " .. itemBasePrices[itemId] .. " $", x2, y2, 0, 0, tocolor(255, 255, 255), 0.65, RobotoL)
							
							drawButton("additem_" .. itemId, "Hozzáadás", x + sx - 15 - dxGetTextWidth("Hozzáadás", 0.8, RobotoL) - 2.5, itemY + oneSize / 2 - dxGetFontHeight(0.8, RobotoL) / 2, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.65)

							itemY = itemY + oneSize
						end
					end
				end

				if itemCount > tabNum then
					local totalSize = oneSize * tabNum
					local gripSize = totalSize / itemCount

					dxDrawRectangle(x + sx - 5, y + 40, 5, totalSize, tocolor(0, 0, 0, 200))

					dxDrawRectangle(x + sx - 5, y + 40 + visibleItem * gripSize, 5, tabNum * gripSize, tocolor(61, 122, 188, 150))
				end

				-- ** Egyenleg
				dxDrawRectangle(x, y + sy - 40 + 5, sx, 35, tocolor(0, 0, 0, 200))
				dxDrawText("Jelenlegi egyenleg: " .. formatNumber(currentBalance) .. " $", x + 10, y + sy - 35, x, y + sy, tocolor(255, 255, 255), 0.75, RobotoL, "left", "center")
				
				local w1 = dxGetTextWidth("Kifizetés", 0.75, RobotoL) + 2.5
				local w2 = dxGetTextWidth("Befizetés", 0.75, RobotoL) + 2.5
				local h = dxGetFontHeight(0.75, RobotoL)
				
				local buttonX = drawButton("getOutMoney", "Kifizetés", x + sx - 10 - w1, y + sy - 35 + 17.5 - h / 2, tocolor(215, 89, 89, 150), tocolor(215, 89, 89, 200), 0.75)
				local buttonX = drawButton("putInMoney", "Befizetés", buttonX - 5 - w2 - w1, y + sy - 35 + 17.5 - h / 2, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.75)

				-- Kilépés
				drawButton("exit", "Kilépés", x + sx - dxGetTextWidth("Kilépés", 0.8, RobotoL) - 2.5, y - dxGetFontHeight(0.8, RobotoL) - 5, tocolor(215, 89, 89, 150), tocolor(215, 89, 89, 200), 0.8, 0.7)
				
				-- Vásárlói mód
				if isOwner then
					drawButton("changeOwnerMode", "Vásárlói mód", x + sx - dxGetTextWidth("Vásárlói mód", 0.8, RobotoL) - 2.5, y + sy + 5, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.7)
				end
			end

			local cx, cy = getCursorPosition()

			activeButton = false

			if tonumber(cx) then
				cx = cx * screenX
				cy = cy * screenY

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			end
		end
	end)

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if promptState and tonumber(character) then
			if not promptInputText then
				promptInputText = ""
			end

			if utf8.len(promptInputText) < 10 then
				promptInputText = promptInputText .. character
				promptInputText = tonumber(promptInputText)
			end
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if promptState then
			if tonumber(key) then
				cancelEvent()
			end

			if key == "backspace" and press and promptInputText then
				promptInputText = utf8.sub(promptInputText, 0, utf8.len(promptInputText) - 1)
				promptInputText = tonumber(promptInputText)
				cancelEvent()
			end

			if key == "escape" then
				if not press then
					promptState = false
					promptInputText = false
				end

				cancelEvent()
			end
		elseif currentPedId then
			local cx, cy = getCursorPosition()

			if tonumber(cx) then
				cx = cx * screenX
				cy = cy * screenY
			end

			if key == "backspace" and press then
				closePanel()
				cancelEvent()
			end

			if ownerMode then
				if itemCount > 10 then
					if cx >= screenX / 2 + 2.5 and cy >= screenY / 2 - 240 + 40 and cx <= screenX / 2 + 2.5 + 400 and cy <= screenY / 2 - 240 + 40 + 480 - 80 then
						if key == "mouse_wheel_up" then
							if visibleItem > 0 then
								visibleItem = visibleItem - 1
							end
						elseif key == "mouse_wheel_down" then
							if visibleItem < itemCount - 10 then
								visibleItem = visibleItem + 1
							end
						end
					end
				end

				if #availableItems > 8 then
					if cx >= screenX / 2 - 400 - 2.5 and cy >= screenY / 2 - 240 and cx <= screenX / 2 - 2.5 and cy <= screenY / 2 - 240 + 480 then
						if key == "mouse_wheel_up" then
							if offsetItems > 0 then
								offsetItems = offsetItems - 1
							end
						elseif key == "mouse_wheel_down" then
							if offsetItems < #availableItems - 8 then
								offsetItems = offsetItems + 1
							end
						end
					end
				end
			else
				if key == "mouse_wheel_up" then
					if offsetItems > 0 then
						offsetItems = offsetItems - 1
					end
				elseif key == "mouse_wheel_down" then
					if offsetItems < #availableItems - 12 then
						offsetItems = offsetItems + 1
					end
				end
			end
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if currentPedId then
			if button == "left" then
				if state == "up" then
					if activeButton then
						local selected = split(activeButton, "_")

						if activeButton == "exit" then
							closePanel()
						end

						if activeButton == "changeOwnerMode" then
							if checkOwnership() then
								ownerMode = not ownerMode
								offsetItems = 0
								playSound("files/switchoption.mp3")
							end
						end

						if selected[1] == "setcategory" then
							if checkOwnership() then
								selectedCategory = tonumber(selected[2])
								visibleItem = 0
								playSound("files/switchoption.mp3")
							end
						end

						if selected[1] == "additem" then
							if checkOwnership() then
								local itemId = tonumber(selected[2])

								table.insert(availableItems, itemId)

								itemPrices[itemId] = itemBasePrices[itemId]
								availableItemsKeyed[itemId] = true

								if itemCount > 10 then
									if visibleItem > itemCount - 10 then
										visibleItem = itemCount - 10
									end
								end

								triggerServerEvent("refreshPedItemList", localPlayer, currentPedId, availableItems, itemPrices)
								playSound("files/promptaccept.mp3")
							end
						end

						if selected[1] == "removefromlist" then
							if checkOwnership() then
								local itemId = tonumber(selected[2])
								local temp = {}

								for i = 1, #availableItems do
									if availableItems[i] ~= itemId then
										table.insert(temp, availableItems[i])
									end
								end

								availableItemsKeyed[itemId] = false
								itemPrices[itemId] = false

								if #availableItems > 8 then
									if offsetItems > #availableItems - 8 then
										offsetItems = #availableItems - 8
									end
								end

								availableItems = temp

								triggerServerEvent("refreshPedItemList", localPlayer, currentPedId, availableItems, itemPrices)
								playSound("files/promptaccept.mp3")
							end
						end

						if selected[1] == "addstock" then
							if checkOwnership() then
								promptState = true
								promptItemId = tonumber(selected[2])
								playSound("files/prompt.mp3")
							end
						elseif selected[1] == "addStockOk" then
							if checkOwnership() then
								promptState = false

								if promptInputText and promptInputText > 0 then
									triggerServerEvent("addToPedStock", localPlayer, currentPedId, promptItemId, tonumber(promptInputText), itemBasePrices[promptItemId])
								end

								promptInputText = false
								playSound("files/promptaccept.mp3")
							end
						end

						if selected[1] == "setprice" then
							if checkOwnership() then
								promptState = "setprice"
								promptItemId = tonumber(selected[2])
								promptInputText = itemPrices[promptItemId]
								playSound("files/prompt.mp3")
							end
						elseif selected[1] == "setPriceOk" then
							if checkOwnership() then
								promptState = false

								if promptInputText and promptInputText > 0 then
									triggerServerEvent("setItemPrice", localPlayer, currentPedId, promptItemId, tonumber(promptInputText))
								end

								promptInputText = false
								playSound("files/promptaccept.mp3")
							end
						end

						if selected[1] == "putInMoney" then
							if checkOwnership() then
								promptState = "putInMoney"
								promptItemId = false
								promptInputText = 0
								playSound("files/prompt.mp3")
							end
						elseif selected[1] == "putInMoneyOk" then
							if checkOwnership() then
								promptState = false

								if promptInputText and promptInputText > 0 then
									triggerServerEvent("putInMoney", localPlayer, currentPedId, tonumber(promptInputText))
								end

								promptInputText = false
								playSound("files/promptaccept.mp3")
							end
						end

						if selected[1] == "getOutMoney" then
							if checkOwnership() then
								promptState = "getOutMoney"
								promptItemId = false
								promptInputText = 0
								playSound("files/prompt.mp3")
							end
						elseif selected[1] == "getOutMoneyOk" then
							if checkOwnership() then
								promptState = false

								if promptInputText and promptInputText > 0 then
									triggerServerEvent("getOutMoney", localPlayer, currentPedId, tonumber(promptInputText))
								end

								promptInputText = false
								playSound("files/promptaccept.mp3")
							end
						end

						if selected[1] == "buyitem" then
							promptState = "buyItem"
							promptItemId = tonumber(selected[2])
							promptInputText = 1
							playSound("files/prompt.mp3")
						elseif selected[1] == "buyItemOk" then
							promptState = false

							if tonumber(promptInputText) then
								if tonumber(promptInputText) < 1 then
									exports.see_accounts:showInfo("e", "Minimum 1 darabot vehetsz egyszerre!")
									return
								end

								if maxItems[promptItemId] and tonumber(promptInputText) > maxItems[promptItemId] then
									exports.see_accounts:showInfo("e", "Ebből maximum " .. maxItems[promptItemId] .. " darabot vehetsz egyszerre!")
									return
								end

								triggerServerEvent("buyItemFromPed", localPlayer, currentPedId, promptItemId, tonumber(promptInputText))
							end

							promptInputText = false
							playSound("files/promptaccept.mp3")
						end
					end
				end
			end
		end
	end)