local screenX, screenY = guiGetScreenSize()

local panelState = false
local panelFont = false
local activeButton = false
					-- 1	2	 3	   4	 5		6	  7		8	 9	   10	 11		12		13	   14	  15	16	  17
local availableRBS = {978, 981, 1228, 1282, 1422, 1424, 1425, 1459, 3091, 3578, 10135, 10136, 10137, 10138, 10139, 2892, 2899}
local rbsForModel = {
	[552] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17},
	[596] = {11, 12, 13, 16, 17},
	[597] = {11, 12, 13, 16, 17},
	[598] = {11, 12, 13, 16, 17},
	[599] = {11, 12, 13, 16, 17},
}
local rbsForVeh = {}
local rbsOffset = 0
local rbsTest = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("object")) do
			if getElementData(v, "rbsData") then
				setObjectBreakable(v, false)
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "rbsData" then
			setObjectBreakable(source, false)
		end
	end)

addCommandHandler("rbs",
	function ()
		if exports.see_groups:isPlayerHavePermission(localPlayer, "roadBlock") or getElementData(player, "acc.adminLevel") >= 1 then
			if not isPedInVehicle(localPlayer) then
				local x, y, z = getElementPosition(localPlayer)
				local vehicles = getElementsWithinRange(x, y, z, 7.5, "vehicle")
				local found = false

				for i = 1, #vehicles do
					local model = getElementModel(vehicles[i])

					if rbsForModel[model] then
						found = model
						break
					end
				end

				if not found then
					outputChatBox("#d75959[StrongMTA - RBS]: #FFFFFFNincs a közeledben #3d7abcUtility Van#ffffff!", 255, 255, 255, true)
					return
				end

				rbsForVeh = {}
				rbsOffset = 0

				for i = 1, #rbsForModel[found] do
					table.insert(rbsForVeh, rbsForModel[found][i])
				end

				if rbsTest then
					removeEventHandler("onClientRender", getRootElement(), renderRoadBlockPlacement)
					removeEventHandler("onClientKey", getRootElement(), rotateRenderedRoadBlock)
					removeEventHandler("onClientClick", getRootElement(), placeRenderedRoadBlock)
				end

				if panelState then
					toggleRoadBlockPanel(false)
				else
					toggleRoadBlockPanel(true)
				end
			end
		end
	end)

function toggleRoadBlockPanel(state)
	if state ~= panelState then
		panelState = state

		if isElement(panelFont) then
			destroyElement(panelFont)
		end

		panelFont = nil

		if panelState then
			panelFont = dxCreateFont("files/fonts/Roboto.ttf", respc(15), false, "antialiased")
			
			addEventHandler("onClientRender", getRootElement(), renderRoadBlockPanel)
			addEventHandler("onClientClick", getRootElement(), clickRoadBlockPanel)
			addEventHandler("onClientKey", getRootElement(), keyRoadBlockPanel)
		else
			removeEventHandler("onClientRender", getRootElement(), renderRoadBlockPanel)
			removeEventHandler("onClientClick", getRootElement(), clickRoadBlockPanel)
			removeEventHandler("onClientKey", getRootElement(), keyRoadBlockPanel)
		end

		if isElement(rbsTest) then
			destroyElement(rbsTest)
		end

		rbsTest = nil
	end
end

function keyRoadBlockPanel(key, press)
	if key == "mouse_wheel_down" then
		if #rbsForVeh > 8 then
			if rbsOffset < #rbsForVeh - 8 then
				rbsOffset = rbsOffset + 8
			end
		end
	end

	if key == "mouse_wheel_up" then
		if rbsOffset > 0 then
			rbsOffset = rbsOffset - 8
		end
	end
end

function clickRoadBlockPanel(button, state)
	if button == "left" then
		if state == "down" then
			if activeButton then
				local selected = split(activeButton, ":")

				if activeButton == "exit" then
					toggleRoadBlockPanel(false)
				elseif selected[1] == "placeRBS" then
					local id = tonumber(selected[2])

					toggleRoadBlockPanel(false)

					if id then
						local model = availableRBS[id]

						if model then
							local x, y, z = getElementPosition(localPlayer)
							rbsTest = createObject(model, x, y, z + 10)
							
							setElementCollisionsEnabled(rbsTest, false)
							setElementInterior(rbsTest, getElementInterior(localPlayer))
							setElementDimension(rbsTest, getElementDimension(localPlayer))

							if isElement(panelFont) then
								destroyElement(panelFont)
							end

							panelFont = dxCreateFont("files/fonts/Roboto.ttf", respc(13), false, "antialiased")

							addEventHandler("onClientRender", getRootElement(), renderRoadBlockPlacement)
							addEventHandler("onClientKey", getRootElement(), rotateRenderedRoadBlock)
							addEventHandler("onClientClick", getRootElement(), placeRenderedRoadBlock)
						end
					end
				end
			end
		end
	end
end

local nearbyRender = false
local nearbyFont = false
local nearbyList = {}

function nearbyRBS()
	if exports.see_groups:isPlayerHavePermission(localPlayer, "roadBlock") or getElementData(localPlayer, "acc.adminLevel") >= 1 then
		nearbyRender = not nearbyRender
		nearbyList = {}

		if nearbyRender then
			local objects = getElementsByType("object", getResourceRootElement(), true)

			for i = 1, #objects do
				local obj = objects[i]
				local dat = getElementData(obj, "rbsData")

				if dat then
					table.insert(nearbyList, dat)
				end
			end

			nearbyFont = dxCreateFont("files/fonts/Roboto.ttf", respc(10), false, "antialiased")

			addEventHandler("onClientRender", getRootElement(), renderNearbyRoadBlocks)

			outputChatBox("#3d7abc[StrongMTA - RBS]: #FFFFFFKözeli RBS mód #3d7abcbekapcsolva#ffffff!", 255, 255, 255, true)
		else
			removeEventHandler("onClientRender", getRootElement(), renderNearbyRoadBlocks)

			if isElement(nearbyFont) then
				destroyElement(nearbyFont)
			end

			nearbyFont = nil

			outputChatBox("#3d7abc[StrongMTA - RBS]: #FFFFFFKözeli RBS mód #d75959kikapcsolva#ffffff!", 255, 255, 255, true)
		end
	end
end
addCommandHandler("nearbyrb", nearbyRBS)
addCommandHandler("nearbyrbs", nearbyRBS)

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		if nearbyRender then
			local data = getElementData(source, "rbsData")

			if data then
				for i = 1, #nearbyList do
					if nearbyList[i] and nearbyList[i][2] == source then
						return
					end
				end

				table.insert(nearbyList, data)
			end
		end
	end)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
	function ()
		if nearbyRender then
			local data = getElementData(source, "rbsData")

			if data then
				local temp = {}

				for i = 1, #nearbyList do
					if nearbyList[i] and nearbyList[i][2] ~= source then
						table.insert(temp, nearbyList[i])
					end
				end

				nearbyList = temp
			end
		end
	end)

function renderNearbyRoadBlocks()
	local px, py, pz = getElementPosition(localPlayer)
	local cx, cy = getCursorPosition()

	if cx and cy then
		cx = cx * screenX
		cy = cy * screenY
	end

	for i = 1, #nearbyList do
		local dat = nearbyList[i]

		if dat and isElement(dat[2]) and isElementStreamedIn(dat[2]) then
			local tx, ty, tz = getElementPosition(dat[2])
			local dist = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)

			if dist <= 10 then
				local x, y = getScreenFromWorldPosition(tx, ty, tz)

				if x and y then
					local x2 = math.floor(x - 100)
					local y2 = math.floor(y - 10)

					dxDrawText("[RBS] ID: " .. dat[1] .. " Lerakta: " .. dat[3], x2 + 1, y2 + 1, x2 + 200 + 1, y2 + 20 + 1, tocolor(0, 0, 0), 1, nearbyFont, "center", "center")
					dxDrawText("#3d7abc[RBS]#ffffff ID: " .. dat[1] .. " Lerakta: " .. dat[3], x2, y2, x2 + 200, y2 + 20, tocolor(255, 255, 255), 1, nearbyFont, "center", "center", false, false, false, true)
					
					x = x + dxGetTextWidth("[RBS] ID: " .. dat[1] .. " Lerakta: " .. dat[3], 1, nearbyFont) / 2 + respc(5)

					if cx and cx >= x and cy >= y - respc(10) and cx <= x + respc(75) and cy <= y + respc(10) then
						if getKeyState("mouse1") then
							triggerServerEvent("deleteRoadBlock", localPlayer, dat[1])
							nearbyList[i] = false
						end

						dxDrawRectangle(x, y - respc(10), respc(75), respc(20), tocolor(215, 89, 89, 200))
					else
						dxDrawRectangle(x, y - respc(10), respc(75), respc(20), tocolor(215, 89, 89, 150))
					end

					dxDrawText("Törlés", x, y - respc(10), x + respc(75), y + respc(10), tocolor(0, 0, 0), 1, nearbyFont, "center", "center")
				end
			end
		end
	end
end

function placeRenderedRoadBlock(button, state)
	if button == "left" then
		if state == "down" then
			if isElement(rbsTest) then
				local model = getElementModel(rbsTest)

				if model == 2892 or model == 2899 then
					triggerServerEvent("placeStinger", localPlayer, model,
						{getElementPosition(rbsTest)},
						{getElementRotation(rbsTest)},
						getElementInterior(rbsTest),
						getElementDimension(rbsTest)
					)
				else
					triggerServerEvent("placeRoadBlock", localPlayer, model,
						{getElementPosition(rbsTest)},
						{getElementRotation(rbsTest)},
						getElementInterior(rbsTest),
						getElementDimension(rbsTest)
					)
				end
			end

			removeEventHandler("onClientRender", getRootElement(), renderRoadBlockPlacement)
			removeEventHandler("onClientKey", getRootElement(), rotateRenderedRoadBlock)
			removeEventHandler("onClientClick", getRootElement(), placeRenderedRoadBlock)

			if isElement(rbsTest) then
				destroyElement(rbsTest)
			end

			rbsTest = nil

			if isElement(panelFont) then
				destroyElement(panelFont)
			end

			panelFont = nil
		end
	elseif button == "right" then
		if state == "down" then
			removeEventHandler("onClientRender", getRootElement(), renderRoadBlockPlacement)
			removeEventHandler("onClientKey", getRootElement(), rotateRenderedRoadBlock)
			removeEventHandler("onClientClick", getRootElement(), placeRenderedRoadBlock)

			if isElement(rbsTest) then
				destroyElement(rbsTest)
			end

			rbsTest = nil

			if isElement(panelFont) then
				destroyElement(panelFont)
			end

			panelFont = nil
		end
	end
end

function rotateRenderedRoadBlock(key, state)
	if key == "mouse_wheel_down" or key == "mouse_wheel_up" then
		if isElement(rbsTest) and isCursorShowing() then
			local rotX, rotY, rotZ = getElementRotation(rbsTest)
			local snapAmount = 1

			if getKeyState("lshift") then
				snapAmount = 45
			end

			if key == "mouse_wheel_down" then
				rotZ = rotZ - snapAmount
			else
				rotZ = rotZ + snapAmount
			end

			setElementRotation(rbsTest, 0, 0, math.floor(rotZ / snapAmount) * snapAmount)
		end
	end
end

function renderRoadBlockPlacement()
	if isElement(rbsTest) then
		if isCursorShowing() then
			local camX, camY, camZ = getCameraMatrix()
			local cursorX, cursorY = getCursorPosition()
			local worldX, worldY, worldZ = getWorldFromScreenPosition(cursorX * screenX, cursorY * screenY, 10)

			if worldX and worldY and worldZ then
				local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(camX, camY, camZ, worldX, worldY, worldZ, true, true, false, true, true)

				if hit and not hitElement then
					local dist = getElementDistanceFromCentreOfMassToBaseOfModel(rbsTest)
					setElementPosition(rbsTest, hitX, hitY, hitZ + dist)
				else
					setElementPosition(rbsTest, 0, 0, 0)
				end
			end
		end

		local model = getElementModel(rbsTest)
		local prefix = "RBS"

		if model == 2892 or model == 2899 then
			prefix = "SPIKE"
		end

		dxDrawText(prefix .. " - Használat\nMozgatás: egér, Forgatás: görgő (45°-os forgatás: Bal SHIFT + görgő)\nLerakás: bal klikk, Kilépés: jobb klikk", 1, 1, screenX + 1, screenY - respc(120) + 1, tocolor(0, 0, 0), 1, panelFont, "center", "bottom")
		dxDrawText("#598ed7" .. prefix .. " #3d7abc- Használat\n#ffffffMozgatás: #3d7abcegér#ffffff, Forgatás: #3d7abcgörgő #ffffff(45°-os forgatás: #3d7abcBal SHIFT + görgő#ffffff)\nLerakás: #3d7abcbal klikk#ffffff, Kilépés: #3d7abcjobb klikk", 0, 0, screenX, screenY - respc(120), tocolor(255, 255, 255), 1, panelFont, "center", "bottom", false, false, false, true)
	end
end

function renderRoadBlockPanel()
	if panelState then
		local sx = respc(710)
		local sy = respc(390)
		local x = screenX / 2 - sx / 2
		local y = screenY / 2 - sy / 2
		local buttons = {}

		-- ** Keret
		dxDrawRectangle(x, y - 2, sx, 2, tocolor(0, 0, 0, 200)) -- felső
		dxDrawRectangle(x, y + sy, sx, 2, tocolor(0, 0, 0, 200)) -- alsó
		dxDrawRectangle(x - 2, y - 2, 2, sy + 4, tocolor(0, 0, 0, 200)) -- bal
		dxDrawRectangle(x + sx, y - 2, 2, sy + 4, tocolor(0, 0, 0, 200)) -- jobb

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 160))

		-- ** Cím
		dxDrawRectangle(x, y, sx, respc(30), tocolor(0, 0, 0, 200))
		dxDrawText("#3d7abcStrong#ffffffMTA #598ed7- RBS", x + respc(7.5), y, respc(315), y + respc(30), tocolor(255, 255, 255), 1, panelFont, "left", "center", false, false, false, true)
		
		-- ** Kilépés
		if activeButton == "exit" then
			dxDrawImage(math.floor(x + sx - respc(32)), math.floor(y + respc(30) / 2 - respc(28) / 2), respc(28), respc(28), "files/images/close.png", 0, 0, 0, tocolor(215, 89, 89))
		else
			dxDrawImage(math.floor(x + sx - respc(32)), math.floor(y + respc(30) / 2 - respc(28) / 2), respc(28), respc(28), "files/images/close.png")
		end
		buttons["exit"] = {x + sx - respc(32), y, respc(28), respc(30)}

		-- ** Content
		local oneSize = respc(170)

		y = y + respc(30) + respc(5)

		for i = 1, 8 do
			local itemX = x + respc(5) + (oneSize + respc(5)) * ((i - 1) % 4)
			local itemY = y + (oneSize + respc(5)) * math.floor((i - 1) / 4)
			local item = rbsForVeh[i + rbsOffset]

			if item then
				if activeButton == "selectRBS:" .. tostring(item) or activeButton == "placeRBS:" .. tostring(item) then
					dxDrawRectangle(itemX, itemY, oneSize, oneSize, tocolor(255, 255, 255, 75))
				else
					dxDrawRectangle(itemX, itemY, oneSize, oneSize, tocolor(255, 255, 255, 20))
				end

				dxDrawImage(itemX, itemY, oneSize, oneSize, "rbs/images/" .. availableRBS[item] .. ".png")

				if activeButton == "selectRBS:" .. item or activeButton == "placeRBS:" .. item then
					buttons["placeRBS:" .. item] = {itemX, itemY + oneSize - respc(25), oneSize, respc(25)}

					if activeButton == "placeRBS:" .. item then
						dxDrawRectangle(itemX, itemY + oneSize - respc(25), oneSize, respc(25), tocolor(61, 122, 188, 240))
					else
						dxDrawRectangle(itemX, itemY + oneSize - respc(25), oneSize, respc(25), tocolor(61, 122, 188, 200))
					end

					dxDrawText("Lerakás", itemX, itemY + oneSize - respc(25), itemX + oneSize, itemY + oneSize, tocolor(0, 0, 0), 0.75, panelFont, "center", "center")
					
					buttons["selectRBS:" .. item] = {itemX, itemY, oneSize, oneSize - respc(25)}
				else
					buttons["selectRBS:" .. item] = {itemX, itemY, oneSize, oneSize}
				end
			else
				dxDrawRectangle(itemX, itemY, oneSize, oneSize, tocolor(25, 25, 25, 200))
			end
		end

		-- Scrollbar
		local listHeight = oneSize * 2 + respc(5)

		if #rbsForVeh > 8 then
			local gripSize = listHeight / #rbsForVeh
			
			dxDrawRectangle(x + sx - respc(3), y, respc(3), listHeight, tocolor(0, 0, 0, 200))
			dxDrawRectangle(x + sx - respc(3), y + math.min(rbsOffset, #rbsForVeh - 8) * gripSize, respc(3), gripSize * 8, tocolor(61, 122, 188, 150))
		end

		-- ** Gombok
		local cx, cy = getCursorPosition()

		activeButton = false

		if cx and cy then
			cx = cx * screenX
			cy = cy * screenY

			for k, v in pairs(buttons) do
				if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end