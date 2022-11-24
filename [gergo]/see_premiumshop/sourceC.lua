local screenX, screenY = guiGetScreenSize()

local itemNames = {}
local itemDescs = {}

local panelState = false
local lastShowTick = 0

local RobotoL = false
local Roboto = false

local buttons = {}
local activeButton = false

local currentCategory = 1
local categoryOffset = 0

local premiumPoints = 0
local premiumPointsForDraw = "Egyenleg: #32b3ef0 #eaeaeaPP"

local panelStage = false
local buyItemId = false
local buyItemAmount = 1

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

addEventHandler("onClientResourceStart", getRootElement(),
	function (res)
		if getResourceName(res) == "see_items" then
			itemNames = exports.see_items:getItemNameList()
			itemDescs = exports.see_items:getItemDescriptionList()

			itemNames.money1 = "24 000 $"
			itemNames.money2 = "100 000 $"
			itemNames.money3 = "300 000 $"
			itemNames.money4 = "700 000 $"

			for i = 3, 17 do
				itemNames["bp" .. i] = blueprintNames[i]
			end
		elseif source == getResourceRootElement() then
			local see_items = getResourceFromName("see_items")

			if see_items and getResourceState(see_items) == "running" then
				itemNames = exports.see_items:getItemNameList()
				itemDescs = exports.see_items:getItemDescriptionList()

				itemNames.money1 = "24 000 $"
				itemNames.money2 = "100 000 $"
				itemNames.money3 = "300 000 $"
				itemNames.money4 = "700 000 $"

				for i = 3, 17 do
					itemNames["bp" .. i] = "Blueprint: " .. blueprintNames[i]
				end
			end
		end
	end)

bindKey("F437", "down", "pp")
addCommandHandler("pp",
	function ()
		--if panelState or getTickCount() - lastShowTick >= 2000 then
			panelState = not panelState

			if isElement(RobotoL) then
				destroyElement(RobotoL)
			end

			if isElement(Roboto) then
				destroyElement(Roboto)
			end

			showCursor(false)

			if panelState then
				lastShowTick = getTickCount()
				ppinfo = false

				RobotoL = dxCreateFont("files/fonts/RobotoL.ttf", 15, false, "antialiased")
				Roboto = dxCreateFont("files/fonts/Roboto.ttf", 10, false, "antialiased")

				showCursor(true)

				premiumPoints = 0
				triggerServerEvent("refreshPPShop", localPlayer)
			else
				ppinfo = false
				--cancelEvent()
				panelStage = false
				buyItemAmount = false
			end
		--else
			--exports.see_accounts:showInfo("e", "Ilyen gyorsan nem tudod megnyitni!")
		--end
	end)


addEvent("syncPPShop", true)
addEventHandler("syncPPShop", getRootElement(), 
	function()
		--executeCommandHandler("pp")
		print("asd")
	end
)



function closePanel()
	if panelState then
		panelState = false

		if isElement(Roboto) then
			destroyElement(Roboto)
		end

		if isElement(RobotoL) then
			destroyElement(RobotoL)
		end

		Roboto = nil
		RobotoL = nil

		showCursor(false)
	end
end

addEvent("ppShopPoints", true)
addEventHandler("ppShopPoints", getRootElement(),
	function (pp)
		premiumPoints = pp
		premiumPointsForDraw = "Egyenleg: #e38724" .. formatNumber(pp) .. " #eaeaeaToken"
	end)

function drawButton(id, text, x, y, bgcolor, hovercolor, scale, scale2)
	if activeButton == id then
		bgcolor = hovercolor
	end

	local sx = dxGetTextWidth(text, scale or 0.65, RobotoL) + 2.5
	local sy = dxGetFontHeight(scale or 0.65, RobotoL)

	dxDrawRectangle(x, y, sx, sy, bgcolor, true)
	dxDrawText(text, x, y, x + sx, y + sy, tocolor(0, 0, 0), (scale2 or scale or 0.65) - 0.025, RobotoL, "center", "center", false, false, true)
	
	buttons[id] = {x, y, sx, sy}

	return x + sx
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		if ppinfo then
			local sx = screenX - respc(460)	- screenX / 4
			local sy = screenY - screenY / 4

			local x = math.floor(screenX / 2 - sx / 2) + respc(420) / 2
			local y = math.floor(screenY / 2 - sy / 2)

			buttons = {}

			drawButton("ppinfo", "Kilépés", x + sx - dxGetTextWidth("Kilépés", 0.9, RobotoL) - 2.5, y + sy + 1 + 5, tocolor(215, 89, 89, 150), tocolor(215, 89, 89, 200), 0.9, 0.75)
			
			dxDrawImage(x, y, sx, sy, "files/images/ppinfo.png", 0, 0, 0, tocolor(255, 255, 255), true)

			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx = cx * screenX
				cy = cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			else
				activeButton = false
			end
		elseif panelStage == "buyItem" then
			buttons = {}

			local sx, sy = 350, 175
			local x = screenX / 2 - sx / 2
			local y = screenY / 2 - sy / 2

			dxDrawText("Vásárlás: " .. itemNames[buyItemId], x, y - 35, x + sx, y, tocolor(255, 255, 255), 1, RobotoL, "center", "center", false, false, true)
			
			dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 200), true)
			
			dxDrawText("Mennyiség: " .. (buyItemAmount or "") .. " db\nEgységár: " .. formatNumber(currentPedItemPrices[buyItemId] or 0) .. " PP\nÖsszesen: " .. formatNumber((currentPedItemPrices[buyItemId] or 0) * (buyItemAmount or 1)) .. " PP\n#3d7abcAdd meg a mennyiséget a billentyűzeteddel!", x + 10, y + 10, x + sx - 10, y + sy - 10 - 35 - 10, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, true, true)
			
			buttons["buyItemOk"] = {x + 75, y + sy - 45, sx - 150, 35}

			if activeButton == "buyItemOk" then
				dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 200), true)
			else
				dxDrawRectangle(x + 75, y + sy - 45, sx - 150, 35, tocolor(61, 122, 188, 150), true)
			end

			dxDrawText("Vásárlás", x + 75, y + sy - 45, x + sx - 75, y + sy - 10, tocolor(255, 255, 255), 0.9, RobotoL, "center", "center", false, false, true)

			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx = cx * screenX
				cy = cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			else
				activeButton = false
			end
		elseif panelState then
			buttons = {}

			local sx = screenX - respc(460)	- screenX / 4
			local sy = screenY - screenY / 4

			local x = math.floor(screenX / 2 - sx / 2) + respc(420) / 2
			local y = math.floor(screenY / 2 - sy / 2)


			local y = y + respc(40) + respc(5)

			-- ** Content
			local holderSize = sx / 3

			y = y + 10

			-- Előző oldal
			if activeButton == "setcategory_" .. currentCategory - 1 then
				dxDrawRectangle(x, y, holderSize, 35, tocolor(61, 122, 188, 175), true)
			else
				dxDrawRectangle(x, y, holderSize, 35, tocolor(0, 0, 0, 175), true)
			end

			if currentCategories[currentCategory - 1] then
				dxDrawText(currentCategories[currentCategory - 1], x, y, x + holderSize, y + 35, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, true)
				buttons["setcategory_" .. currentCategory - 1] = {x, y, holderSize, 35}
			end

			-- Jelenlegi oldal
			dxDrawRectangle(x + holderSize, y, holderSize, 35, tocolor(0, 0, 0, 225), true)
			dxDrawText(currentCategories[currentCategory], x + holderSize, y, x + holderSize * 2, y + 35, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, true)
			
			-- Következő oldal
			if activeButton == "setcategory_" .. currentCategory + 1 then
				dxDrawRectangle(x + holderSize * 2, y, holderSize, 35, tocolor(61, 122, 188, 175), true)
			else
				dxDrawRectangle(x + holderSize * 2, y, holderSize, 35, tocolor(0, 0, 0, 175), true)
			end

			if currentCategories[currentCategory + 1] then
				dxDrawText(currentCategories[currentCategory + 1], x + holderSize * 2, y, x + holderSize * 3, y + 35, tocolor(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, true)
				buttons["setcategory_" .. currentCategory + 1] = {x + holderSize * 2, y, holderSize, 35}
			end

			-- Lista
			y = y + 35

			for i = 1, 12 do
				local itemId = ppItems[currentCategory][i + categoryOffset]

				if itemId then
					local y = y + (i - 1) * 40

					if i % 2 == 1 then
						dxDrawRectangle(x, y, sx, 40, tocolor(0, 0, 0, 125), true)
					else
						dxDrawRectangle(x, y, sx, 40, tocolor(0, 0, 0, 75), true)
					end

					if tonumber(itemId) then
						dxDrawImage(x + 2, y + 2, 36, 36, ":see_items/files/items/" .. itemId - 1 .. ".png", 0, 0, 0, tocolor(255, 255, 255), true)
					elseif string.find(itemId, "bp") then
						dxDrawImage(x + 2, y + 2, 36, 36, "files/images/items/bp.png", 0, 0, 0, tocolor(255, 255, 255), true)
					else
						dxDrawImage(x + 2, y + 2, 36, 36, "files/images/items/" .. itemId .. ".png", 0, 0, 0, tocolor(255, 255, 255), true)
					end

					local text = itemNames[itemId]

					if itemDescs[itemId] and currentCategory ~= 4 then
						text = text
					end

					dxDrawText(text, x + 5 + 36, y, x + sx, y + 40, tocolor(255, 255, 255), 1, Roboto, "left", "center", false, false, true, true)

					if currentCategory == 2 then
						local buyTextWidth = dxGetTextWidth("Vásárlás", 0.8, RobotoL)
						local previewTextWidth = dxGetTextWidth("Előnézet", 0.8, RobotoL)
						local buttonsWidth = buyTextWidth + previewTextWidth + 15
						local buttonHeight = dxGetFontHeight(0.8, RobotoL)

						dxDrawText("Ár: " .. formatNumber(currentPedItemPrices[itemId]) .. " #32b3efPP", x + 5, y, x + sx - 25 - buttonsWidth, y + 40, tocolor(255, 255, 255), 1, Roboto, "right", "center", false, false, true, true)
						
						drawButton("preview_" .. itemId, "Előnézet", x + sx - buttonsWidth - 15, y + 20 - buttonHeight / 2, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.65, false, false, true)
						
						drawButton("buyitem_" .. itemId, "Vásárlás", x + sx - 15 - buyTextWidth - 2.5, y + 20 - buttonHeight / 2, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.65, false, false, true)
					elseif currentCategory == 8 then 
						local buyTextWidth = dxGetTextWidth("Vásárlás", 0.8, RobotoL)
						local buttonsWidth = buyTextWidth + 15
						local buttonHeight = dxGetFontHeight(0.8, RobotoL)
						dxDrawText("Ár: " .. formatNumber(currentPedItemPrices[itemId]) .. " #32b3efSummer Token", x + 5, y, x + sx - 25 - buttonsWidth, y + 40, tocolor(255, 255, 255), 1, Roboto, "right", "center", false, false, true, true)
						drawButton("buyitem_" .. itemId, "Vásárlás", x + sx - 15 - buyTextWidth - 2.5, y + 20 - buttonHeight / 2, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.65, false, false, true)
					else
						local buyTextWidth = dxGetTextWidth("Vásárlás", 0.8, RobotoL)
						local buttonHeight = dxGetFontHeight(0.8, RobotoL)

						dxDrawText("Ár: " .. formatNumber(currentPedItemPrices[itemId]) .. " #32b3efPP", x + 5, y, x + sx - 25 - buyTextWidth - 2.5, y + 40, tocolor(255, 255, 255), 1, Roboto, "right", "center", false, false, true, true)
						
						drawButton("buyitem_" .. itemId, "Vásárlás", x + sx - 15 - buyTextWidth - 2.5, y + 20 - buttonHeight / 2, tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.8, 0.65, false, false, true)
					end
				end
			end

			-- Scroll
			if #ppItems[currentCategory] > 12 then
				local listheight = 40 * 12
				local gripheight = listheight / (#ppItems[currentCategory] - 11)

				dxDrawRectangle(x + sx - 5, y, 5, listheight, tocolor(0, 0, 0, 200), true)
				dxDrawRectangle(x + sx - 5, y + categoryOffset * gripheight, 5, gripheight, tocolor(61, 122, 188, 150), true)
			end

			-- Pépé
			--dxDrawText(premiumPointsForDraw:gsub("#%x%x%x%x%x%x", ""), x + 1, y + respc(400) + respc(100) + 1, x + 1, y + 1, tocolor(0, 0, 0), 1, Roboto, "left", "top", false, false, true)
			--dxDrawText(premiumPointsForDraw, x, y + respc(400) + respc(100), x, y, tocolor(255, 255, 255), 1, Roboto, "left", "top", false, false, true, true)

			-- ** Gombok
			local closeTextWidth = dxGetTextWidth("Kilépés", 0.9, RobotoL)
			local ppinfoTextWidth = dxGetTextWidth("Prémium információ", 0.9, RobotoL)

			--drawButton("exit", "Kilépés", x + sx - closeTextWidth - 2.5, y + sy + 5, tocolor(215, 89, 89, 150), tocolor(215, 89, 89, 200), 0.9, 0.75)
			drawButton("ppinfo", "Prémium információ", x + sx - ppinfoTextWidth - 2.5, y - 45 - dxGetFontHeight(0.9, RobotoL), tocolor(61, 122, 188, 150), tocolor(61, 122, 188, 200), 0.9, 0.75)
		
			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx = cx * screenX
				cy = cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			else
				activeButton = false
			end
		end
	end)

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if panelStage and tonumber(character) then
			if not buyItemAmount then
				buyItemAmount = ""
			end

			if utf8.len(buyItemAmount) < 10 then
				buyItemAmount = buyItemAmount .. character
				buyItemAmount = tonumber(buyItemAmount)
			end
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if panelStage then
			if tonumber(key) then
				cancelEvent()
			end

			if key == "backspace" and press and buyItemAmount then
				buyItemAmount = utf8.sub(buyItemAmount, 0, utf8.len(buyItemAmount) - 1)
				buyItemAmount = tonumber(buyItemAmount)
				cancelEvent()
			end

			if key == "escape" then
				if not press then
					panelStage = false
					buyItemAmount = false
				end

				cancelEvent()
			end
		elseif panelState then
			if ppinfo and key == "escape" then
				ppinfo = false
				cancelEvent()
			end

			if key == "backspace" then
				if ppinfo then
					ppinfo = false
					cancelEvent()
					return
				end

				if not press then
					panelStage = false
					closePanel()
				end

				cancelEvent()
			end

			if getCursorPosition() then
				if key == "mouse_wheel_up" then
					if categoryOffset > 0 then
						categoryOffset = categoryOffset - 1
					end

					cancelEvent()
				elseif key == "mouse_wheel_down" then
					if categoryOffset < #ppItems[currentCategory] - 12 then
						categoryOffset = categoryOffset + 1
					end

					cancelEvent()
				end
			end
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if panelState then
			if button == "left" then
				if state == "up" then
					if activeButton then
						local button = split(activeButton, "_")

						if button[1] == "ppinfo" then
							ppinfo = not ppinfo
						elseif button[1] == "setcategory" then
							categoryOffset = 0
							currentCategory = tonumber(button[2])
							playSound("files/sounds/switchoption.mp3")
						elseif button[1] == "buyItemOk" then
							local amount = tonumber(buyItemAmount)

							panelStage = false

							if amount then
								if amount < 1 then
									exports.see_accounts:showInfo("e", "Minimum 1 darabot vehetsz egyszerre!")
									return
								end

								if limitCount[buyItemId] and limitCount[buyItemId] < amount then
									exports.see_accounts:showInfo("e", "Ebből maximum " .. limitCount[buyItemId] .. " darabot vehetsz egyszerre!")
									return
								end

								triggerServerEvent("buyPremiumItem", localPlayer, buyItemId, amount)
							end

							buyItemAmount = false
							playSound("files/sounds/promptaccept.mp3")
							--closePanel()
						elseif button[1] == "preview" then
							local itemId = tonumber(button[2])

							exports.see_weapontuning:previewWeapon(itemId)

							closePanel()
							executeCommandHandler("dashboard")
							executeCommandHandler("pp")
						elseif button[1] == "buyitem" then
							local itemId = tonumber(button[2])

							panelStage = "buyItem"

							if itemId then
								buyItemId = itemId
							else
								buyItemId = button[2]
							end

							buyItemAmount = 1

							playSound("files/sounds/prompt.mp3")
						elseif button[1] == "exit" then
							--closePanel()
						end
					end
				end
			end
		end
	end)