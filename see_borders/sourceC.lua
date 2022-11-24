local screenX, screenY = guiGetScreenSize()

local bollards = {}
local bollardsLOD = {}
local borderColShape = {}
local borderState = {}
local borderAnimation = {}

local borderOffsetZ = 1.5
local borderOpenTime = 2000
local borderCloseTime = 1500

local borderPedSkins = {265, 266, 267, 277, 278, 288}

function rotateAround(angle, x, y, x2, y2)
	local theta = math.rad(angle)
	local rotatedX = x * math.cos(theta) - y * math.sin(theta) + (x2 or 0)
	local rotatedY = x * math.sin(theta) + y * math.cos(theta) + (y2 or 0)
	return rotatedX, rotatedY
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for i = 1, #availableBorders do
			local datas = availableBorders[i]

			bollards[i] = {}
			bollardsLOD[i] = {}
			
			for k, v in ipairs(borderOffset[datas[13]]) do
				local rotatedX, rotatedY = rotateAround(datas[4], v[1], v[2])
				
				bollards[i][k] = createObject(1214, datas[1] + rotatedX, datas[2] + rotatedY, datas[3])
				bollardsLOD[i][k] = createObject(1214, datas[1] + rotatedX, datas[2] + rotatedY, datas[3], 0, 0, 0, true)
				
				setLowLODElement(bollards[i][k], bollardsLOD[i][k])
				setObjectScale(bollards[i][k], 1)
				setObjectBreakable(bollards[i][k], false)
				setElementFrozen(bollards[i][k], true)
			end
			
			local collision = createObject(datas[14], datas[1], datas[2], datas[3] + 0.5, 0, 0, datas[4] + 90)
			setElementAlpha(collision, 0)
			table.insert(bollards[i], collision)
			
			borderColShape[i] = {
				[1] = createColSphere(datas[5], datas[6], datas[7], datas[8]),
				[2] = createColSphere(datas[9], datas[10], datas[11], datas[12])
			}
			
			setElementData(borderColShape[i][1], "borderId", i)
			setElementData(borderColShape[i][2], "borderId", i)
			
			borderState[i] = getElementData(resourceRoot, "border." .. i .. ".state")
			borderAnimation[i] = 0

			local borderPed = createPed(borderPedSkins[math.random(1, #borderPedSkins)], unpack(borderPedPositions[i]))
			setElementFrozen(borderPed, true)
			setElementData(borderPed, "visibleName", "Határőr", false)
			setElementData(borderPed, "invulnerable", true, false)
		end
	end)

addEventHandler("onClientElementDataChange", getResourceRootElement(),
	function (dataName, oldValue)
		if string.find(dataName, "border.") then
			local borderId = tonumber(gettok(dataName, 2, "."))

			if borderId then
				if availableBorders[borderId] then
					local dataType = gettok(dataName, 3, ".")

					if dataType == "state" then
						borderState[borderId] = getElementData(source, dataName)
						borderAnimation[borderId] = getTickCount()
					elseif dataType == "mode" then
						local dataValue = getElementData(source, dataName) or 1

						if dataValue == 1 or dataValue == 3 then
							borderState[borderId] = false
						elseif dataValue == 2 then
							borderState[borderId] = true
						end
						
						borderAnimation[borderId] = getTickCount()
					end
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local now = getTickCount()

		for k, v in pairs(borderAnimation) do
			if now <= v + borderOpenTime then
				local z = 0

				if borderState[k] then
					z = interpolateBetween(0, 0, 0, borderOffsetZ, 0, 0, (now - v) / borderOpenTime, "InQuad")
				else
					z = interpolateBetween(borderOffsetZ, 0, 0, 0, 0, 0, (now - v) / borderCloseTime, "InQuad")
				end

				for k2, v2 in pairs(bollards[k]) do
					local x, y = getElementPosition(v2)

					if k2 < #bollards[k] then
						setElementPosition(v2, x, y, availableBorders[k][3] - z)
					else
						setElementPosition(v2, x, y, availableBorders[k][3] - z + 0.5)
					end
				end
			end
		end
	end)

function isOfficer(player)
	return exports.see_groups:isPlayerInGroup(player, 1) or exports.see_groups:isPlayerInGroup(player, 12) or exports.see_groups:isPlayerInGroup(player, 13) or exports.see_groups:isPlayerInGroup(player, 21) or exports.see_groups:isPlayerInGroup(player, 26)
end

function rgbToHex(r, g, b)
	return string.format("#%.2X%.2X%.2X", r, g, b)
end

addCommandHandler("hatar",
	function (commandName, mode)
		if isOfficer(localPlayer) then
			mode = tonumber(mode)

			if not (mode and mode >= 1 and mode <= 3) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Mód (1/2/3)]", 255, 255, 255, true)
				outputChatBox("#3d7abc[Módok]: #ffffffAutomatikus(1), Nyitva(2), Zárva(3)", 255, 255, 255, true)
			else
				local borderId = false

				for k, v in pairs(borderColShape) do
					if isElementWithinColShape(localPlayer, v[1]) then
						borderId = getElementData(v[1], "borderId")
						break
					elseif isElementWithinColShape(localPlayer, v[2]) then
						borderId = getElementData(v[2], "borderId")
						break
					end
				end

				if borderId then
					setElementData(resourceRoot, "border." .. borderId .. ".mode", mode)

					if mode == 2 then
						setElementData(resourceRoot, "border." .. borderId .. ".state", true)
					elseif mode == 1 or mode == 3 then
						setElementData(resourceRoot, "border." .. borderId .. ".state", false)
					end

					triggerServerEvent("warnAboutBorderSet", localPlayer, getElementData(localPlayer, "visibleName"), borderId, mode)
				else
					outputChatBox("#3d7abc[Határ]: #ffffffCsak a határ közelében használhatod ezt a parancsot! (ColShape)", 255, 255, 255, true)
				end
			end
		end
	end)

addEvent("warnAboutBorderSet", true)
addEventHandler("warnAboutBorderSet", getRootElement(),
	function (playerName, borderId, set)
		if isOfficer(localPlayer) or getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if set == 2 or set == 3 then
				local state = "nyitva"

				if set == 3 then
					state = "zárva"
				end

				outputChatBox("#3d7abc[StrongMTA - Határ]: #ffffff" .. playerName:gsub("_", " ") .. " átállított egy határt manuális nyitásra. (#" .. borderId .. " - " .. state .. ")", 255, 255, 255, true)
			elseif set == 1 then
				outputChatBox("#3d7abc[StrongMTA - Határ]: #ffffff" .. playerName:gsub("_", " ") .. " átállított egy határt automatikus nyitásra. (#" .. borderId .. ")", 255, 255, 255, true)
			end
		end
	end)

local borderWarns = true

addCommandHandler("toghatar",
	function ()
		if borderWarns then
			outputChatBox("#3d7abc[StrongMTA - Határ]: #ffffffSikeresen kikapcsoltad az határ értesítéseket!", 255, 255, 255, true)
			borderWarns = false
		else
			outputChatBox("#3d7abc[StrongMTA - Határ]: #ffffffSikeresen bekapcsoltad az határ értesítéseket!", 255, 255, 255, true)
			borderWarns = true
		end
	end)

addEvent("warnAboutBorderCross", true)
addEventHandler("warnAboutBorderCross", getRootElement(),
	function (vehicle)
		if isElement(vehicle) and isOfficer(localPlayer) and borderWarns then
			local plateText = getVehiclePlateText(vehicle)

			if plateText then
				local plateParts = split(plateText, "-")
				
				plateText = {}

				for i = 1, #plateParts do
					if utf8.len(plateParts[i]) >= 1 then
						table.insert(plateText, plateParts[i])
					end
				end

				outputChatBox("#3d7abc[StrongMTA - Határ]:#ffffff Egy jármű átlépte a határt! Rendszáma: #3d7abc" .. table.concat(plateText, "-"), 255, 255, 255, true)

				local r1, g1, b1, r2, g2, b2 = getVehicleColor(vehicle, true)

				outputChatBox("#3d7abc[StrongMTA - Határ]:#ffffff Típus: #598ed7" .. exports.see_vehiclenames:getCustomVehicleName(getElementModel(vehicle)) .. "#FFFFFF Színek: " .. rgbToHex(r1, g1, b1) .. "szín1 " .. rgbToHex(r2, g2, b2) .. "szín2", 255, 255, 255, true)
			end
		end
	end)

local responsiveMultipler = 1

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedres)
		if getResourceName(startedres) == "see_hud" then
			responsiveMultipler = exports.see_hud:getResponsiveMultipler()
		else
			if source == getResourceRootElement() then
				local see_hud = getResourceFromName("see_hud")

				if see_hud then
					if getResourceState(see_hud) == "running" then
						responsiveMultipler = exports.see_hud:getResponsiveMultipler()
					end
				end
			end
		end
	end)

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local currentBorderId = false
local currentBorderColShapeId = false

local Roboto = false

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (theElement, matchingDimension)
		if theElement == localPlayer and matchingDimension then
			local borderId = getElementData(source, "borderId")

			if borderId then
				local pedveh = getPedOccupiedVehicle(localPlayer)

				if isElement(pedveh) then
					if not getElementData(pedveh, "borderTargetColShapeId") then
						if not getElementData(resourceRoot, "border." .. borderId .. ".state") and getElementData(resourceRoot, "border." .. borderId .. ".mode") == 1 then
							if source == borderColShape[borderId][2] then
								return
							end

							currentBorderId = borderId
							currentBorderColShapeId = 1

							if isElement(Roboto) then
								destroyElement(Roboto)
							end

							Roboto = dxCreateFont("files/Roboto.ttf", respc(15), false, "antialiased")
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (theElement)
		if theElement == localPlayer then
			if getElementData(source, "borderId") then
				currentBorderId = false
				currentBorderColShapeId = false

				if isElement(Roboto) then
					destroyElement(Roboto)
				end

				Roboto = nil
			end
		end

		if isElement(theElement) then
			if getElementType(theElement) == "vehicle" then
				if getVehicleController(theElement) == localPlayer then
					local targetColShapeId = getElementData(theElement, "borderTargetColShapeId")

					if targetColShapeId then
						local borderId = getElementData(source, "borderId")

						if borderId then
							if source == borderColShape[borderId][targetColShapeId] then
								triggerServerEvent("closeTheBorder", localPlayer, borderId, targetColShapeId, theElement)
							end
						end
					end
				end
			end
		end
	end)

local activeButton = false

local passportItemId = false
local passportData1 = false
local passportData2 = false
local passportIsCopy = false

local passportRoboto = false
local passportRT = false
local passportShader = false

function togglePassport(itemId, data1, data2, data3)
	if passportData1 then
		triggerEvent("updateInUse", localPlayer, "player", passportItemId, false)

		passportItemId = false
		passportData1 = false
		passportData2 = false
		passportIsCopy = false

		if isElement(passportRoboto) then
			destroyElement(passportRoboto)
		end

		if isElement(passportRT) then
			destroyElement(passportRT)
		end

		if isElement(passportShader) then
			destroyElement(passportShader)
		end

		passportRoboto = nil
		passportRT = nil
		passportShader = nil

		exports.see_chat:localActionC(localPlayer, "elrak egy útlevelet.")
	else
		triggerEvent("updateInUse", localPlayer, "player", itemId, true)

		passportItemId = itemId
		passportData1 = fromJSON(data1)
		passportData2 = data2
		passportIsCopy = data3 and split(data3, ";")

		passportRoboto = dxCreateFont("files/Roboto.ttf", respc(11), false, "antialiased")
		passportRT = dxCreateRenderTarget(481, 481, true)
		passportShader = dxCreateShader(":see_items/files/monochrome.fx")
		dxSetShaderValue(passportShader, "screenSource", passportRT)

		exports.see_chat:localActionC(localPlayer, "elővesz egy útlevelet.")
	end
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		if passportData1 then
			local sx = 481
			local sy = 277

			local x = screenX / 2 - sx / 2
			local y = screenY / 2 - sy / 2

			x = math.floor(x)
			y = math.floor(y)

			if passportIsCopy then
				dxSetRenderTarget(passportRT, true)
				x, y = 0, 0
			end

			dxDrawImage(x, y, sx, sy, ":see_accounts/files/passport.png")

			if fileExists(":see_binco/files/skins/" .. passportData1.skin .. ".png") then
				dxDrawImage(x + 20, y + 43, 120, 120, ":see_binco/files/skins/" .. passportData1.skin .. ".png")
			end

			dxDrawText(passportData1.name1, x + 260, y + 45, 0, 0, tocolor(10, 10, 10), 1, passportRoboto, "left", "top")
			dxDrawText(passportData1.name2, x + 260, y + 63, 0, 0, tocolor(10, 10, 10), 1, passportRoboto, "left", "top")
			dxDrawText(passportData1.age, x + 260, y + 82, 0, 0, tocolor(10, 10, 10), 1, passportRoboto, "left", "top")
			dxDrawText(passportData1.sex, x + 260, y + 103, 0, 0, tocolor(10, 10, 10), 1, passportRoboto, "left", "top")
			dxDrawText(passportData1.weight, x + 260, y + 122, 0, 0, tocolor(10, 10, 10), 1, passportRoboto, "left", "top")
			dxDrawText(passportData1.height, x + 260, y + 143, 0, 0, tocolor(10, 10, 10), 1, passportRoboto, "left", "top")
			dxDrawText(passportData2, x + 25, y + 186, x + 461, 0, tocolor(10, 10, 10), 1, passportRoboto, "left", "top", false, true)

			if passportIsCopy then
				dxSetRenderTarget()

				local x = screenX / 2 - 400
				local y = screenY / 2 - 250

				dxDrawRectangle(x, y, 800, 500, tocolor(255, 255, 255))
				dxDrawImage(x + passportIsCopy[1], y + passportIsCopy[2], 481, 481, passportShader, -passportIsCopy[3], 210, 210)
				dxDrawImage(x, y, 800, 500, ":see_items/files/paper.png")
			end
		end

		if not getPedOccupiedVehicle(localPlayer) or getPedOccupiedVehicleSeat(localPlayer) ~= 0 then
			currentBorderId = false
			currentBorderColShapeId = false
		end

		if currentBorderId then
			local sx, sy = respc(300), respc(200)
			local x = screenX / 2 - sx / 2
			local y = screenY / 2 - sy / 2

			dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))
			dxDrawRectangle(x, y, sx, respc(30), tocolor(0, 0, 0, 100))
			
			dxDrawText("#ffffffStrong#3d7abcMTA #ffffff - Határ", x + respc(7.5), y, 0, y + respc(30), tocolor(255, 255, 255), 0.75, Roboto, "left", "center", false, false, false, true)
			dxDrawText("Szeretnél átlépni a határon?\nA határátlépés ára #3d7abc25$#ffffff.", x, y + respc(30), x + sx, y + sy - respc(45) * 2, tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)
			
			if activeButton == "yes" then
				dxDrawRectangle(x + respc(5), y + sy - respc(45) * 2, sx - respc(10), respc(40), tocolor(61, 122, 188, 255))
			else
				dxDrawRectangle(x + respc(5), y + sy - respc(45) * 2, sx - respc(10), respc(40), tocolor(61, 122, 188, 200))
			end
			dxDrawText("Igen", x + respc(5), y + sy - respc(45) * 2, x + respc(5) + sx - respc(10), y + sy - respc(45) * 2 + respc(40), tocolor(0, 0, 0), 0.75, Roboto, "center", "center")
			
			if activeButton == "no" then
				dxDrawRectangle(x + respc(5), y + sy - respc(45), sx - respc(10), respc(40), tocolor(215, 89, 89, 255))
			else
				dxDrawRectangle(x + respc(5), y + sy - respc(45), sx - respc(10), respc(40), tocolor(215, 89, 89, 200))
			end
			dxDrawText("Nem", x + respc(5), y + sy - respc(45) * 1, x + respc(5) + sx - respc(10), y + sy - respc(45) * 1 + respc(40), tocolor(0, 0, 0), 0.75, Roboto, "center", "center")
			
			local cx, cy = getCursorPosition()

			activeButton = false
			
			if cx and cy then
				cx = cx * screenX
				cy = cy * screenY

				if cx >= x + respc(5) and cy >= y + sy - respc(45) * 2 and cx <= x + respc(5) + sx - respc(10) and cy <= y + sy - respc(45) * 2 + respc(40) then
					activeButton = "yes"
				elseif cx >= x + respc(5) and cy >= y + sy - respc(45) * 1 and cx <= x + respc(5) + sx - respc(10) and cy <= y + sy - respc(45) * 1 + respc(40) then
					activeButton = "no"
				end
			end
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if button == "left" then
			if state == "down" then
				if currentBorderId then
					if activeButton then
						if activeButton == "yes" then
							local pedveh = getPedOccupiedVehicle(localPlayer)

							triggerServerEvent("openTheBorder", localPlayer, currentBorderId, currentBorderColShapeId, pedveh)
						end

						currentBorderId = false
						currentBorderColShapeId = false

						if isElement(Roboto) then
							destroyElement(Roboto)
						end

						Roboto = nil
					end
				end
			end
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if currentBorderId then
			if key == "enter" or key == "backspace" then
				cancelEvent()

				if press then
					if key == "enter" then
						local pedveh = getPedOccupiedVehicle(localPlayer)

						triggerServerEvent("openTheBorder", localPlayer, currentBorderId, currentBorderColShapeId, pedveh)
					end

					currentBorderId = false
					currentBorderColShapeId = false

					if isElement(Roboto) then
						destroyElement(Roboto)
					end

					Roboto = nil
				end
			end
		end
	end)