local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local zoneColShape = createColRectangle(1017.86328125, 1223.474609375, 79.96875, 139.2470703125)
local zoneColShape2 = createColRectangle(-270.57543945313, 208.2834472656, 139.61014556885, 23.2565917969)
local zoneColShape_Jesse = createColRectangle(-797.15252685547, 2741.1977539062, 45.705451965332, 35)
local zoneColShape_Graves = createColRectangle(2005.7644042969, 2028.0034179688, 73.010322570801, 73)

local groupId = false
local dutySkin = false

local panelState = false
local panelMoving = false

local panelStartX = screenX - respc(25)
local panelStartY = screenY / 2

local Roboto = false

local panelNames = {
	"Bal első sárvédő",
	"Jobb első sárvédő",
	"Bal hátsó sárvédő",
	"Jobb hátsó sárvédő",
	"Szélvédő",
	"Első lökhárító",
	"Hátsó lökhárító"
}

local doorNames = {
	"Motorháztető",
	"Csomagtartó",
	"Bal első ajtó",
	"Jobb első ajtó",
	"Bal hátsó ajtó",
	"Jobb hátsó ajtó"
}

local wheelNames = {
	"Bal első kerék",
	"Bal hátsó kerék",
	"Jobb első kerék",
	"Jobb hátsó kerék"
}

local lightNames = {
	"Bal első lámpa",
	"Jobb első lámpa",
	"Jobb hátsó lámpa",
	"Bal hátsó lámpa"
}

local detectedVehicle = false
local vehicleName = false
local vehiclePrice = 0
local vehicleGroup = 0
local elevatorLevel = 0

local priceMargin = 0

local buttons = {}
local activeButton = false

local selectedParts = {}
local playerSelection = false
local selectedPlayer = false
local selectedPlayerName = false

local invoiceList = {}
local invoiceRoboto = false

local fixProgressBar = false

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (enterPlayer, sameDimension)
		if enterPlayer == localPlayer then
			if sameDimension then
				if source == zoneColShape or source == zoneColShape2 or zoneColShape_Jesse or zoneColShape_Graves then
					checkCanFix()
				end
			end
		end
	end
)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (leftPlayer, sameDimension)
		if leftPlayer == localPlayer then
			if sameDimension then
				if source == zoneColShape or source == zoneColShape2 or zoneColShape_Jesse or zoneColShape_Graves then
					checkCanFix()
				end
			end
		end
	end
)

addEventHandler("onClientElementModelChange", localPlayer,
	function (oldModel, newModel)
		checkCanFix()
	end
)

function checkCanFix()
	groupId = false

	if isElementWithinColShape(localPlayer, zoneColShape) then
		groupId = 15
	end

	if isElementWithinColShape(localPlayer, zoneColShape_Jesse) then
		groupId = 39
		--dutySkin = true
		iprint(dutySkin)
	end

	if isElementWithinColShape(localPlayer, zoneColShape_Graves) then
		groupId = 19
		--dutySkin = true
		iprint(dutySkin)
	end

	local currentSkin = getElementModel(localPlayer)

	dutySkin = false
	--dutySkin = true

	if currentSkin == 50 or currentSkin == 305 or currentSkin == 268 or currentSkin == 191 then
		dutySkin = true
	end

	if groupId and dutySkin and exports.see_groups:isPlayerInGroup(localPlayer, 15) or isElementWithinColShape(localPlayer, zoneColShape_Jesse) and exports.see_groups:isPlayerInGroup(localPlayer, 39) or isElementWithinColShape(localPlayer, zoneColShape_Graves) and exports.see_groups:isPlayerInGroup(localPlayer, 19) then
		if not panelState then
			panelState = true

			addEventHandler("onClientRender", getRootElement(), renderService)
			addEventHandler("onClientClick", getRootElement(), clickService)
			addEventHandler("onClientElementDataChange", getRootElement(), onDataChange)

			Roboto = dxCreateFont("files/Roboto.ttf", respc(15), false, "antialiased")
		end

		priceMargin = getElementData(resourceRoot, "priceMargin:" .. groupId)
	else
		if panelState then
			panelState = false
			
			removeEventHandler("onClientRender", getRootElement(), renderService)
			removeEventHandler("onClientClick", getRootElement(), clickService)
			removeEventHandler("onClientElementDataChange", getRootElement(), onDataChange)
			
			if isElement(Roboto) then
				destroyElement(Roboto)
			end

			Roboto = false
		end
	end
end

function onDataChange(dataName)
	if groupId then
		if source == resourceRoot then
			if dataName == "priceMargin:" .. groupId then
				priceMargin = getElementData(resourceRoot, "priceMargin:" .. groupId)
			end
		end
	end

	if detectedVehicle then
		if source == detectedVehicle then
			elevatorLevel = getElementData(source, "elevatorLevel") or 0
		end
	end
end

function clickService(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
	if not selectedPlayer then
		if state == "up" then
			if playerSelection then
				if isElement(clickedElement) then
					if getElementType(clickedElement) == "player" then
						local playerX, playerY, playerZ = getElementPosition(localPlayer)
						local targetX, targetY, targetZ = getElementPosition(clickedElement)

						playerSelection = false

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) >= 2 then
							exports.see_hud:showInfobox("e", "A kiválasztott játékos túl távol van.")
							return
						end

						local partsTable = getComponents(detectedVehicle)
						local invoiceTable = {}

						selectedPlayer = clickedElement
						selectedPlayerName = getElementData(selectedPlayer, "visibleName"):gsub("_", " ")

						setElementFrozen(localPlayer, true)

						for i = 1, #partsTable do
							local part = partsTable[i]

							if selectedParts[part[1]] then
								table.insert(invoiceTable, part)
							end
						end

						triggerServerEvent("sendInvoice", localPlayer, selectedPlayer, invoiceTable, detectedVehicle, groupId)
					end
				end
			elseif activeButton == "startfix" then
				local partsTable = getComponents(detectedVehicle)
				local partsCount = 0

				for i = 1, #partsTable do
					local part = partsTable[i]

					if selectedParts[part[1]] then
						partsCount = partsCount + 1
					end
				end

				if partsCount > 0 then
					playerSelection = true
				else
					exports.see_hud:showInfobox("e", "Minimum egy alkatrészt ki kell választanod!")
				end
			else
				if activeButton then
					local selected = split(activeButton, ":")

					if selected[1] == "check" then
						local part = selected[2]

						if part then
							selectedParts[part] = not selectedParts[part]
						end
					end
				end
			end
		end
	end
end

addEvent("sendInvoice", true)
addEventHandler("sendInvoice", getRootElement(),
	function (sourcePlayer, partsTable, vehicleElement)
		if isElement(sourcePlayer) then
			invoiceList.name = getElementData(sourcePlayer, "visibleName"):gsub("_", " ")
			invoiceList.parts = partsTable
			invoiceList.veh = vehicleElement
			invoiceList.vehName = exports.see_vehiclenames:getCustomVehicleName(getElementModel(vehicleElement))

			addEventHandler("onClientRender", getRootElement(), renderTheInvoice)
			addEventHandler("onClientClick", getRootElement(), clickInvoice)

			invoiceRoboto = dxCreateFont("files/Roboto.ttf", respc(15), false, "antialiased")
		end
	end
)

addEvent("invoiceReaction", true)
addEventHandler("invoiceReaction", getRootElement(),
	function (reactionType, repairDuration)
		selectedPlayer = false

		if reactionType == "accept" then
			fixProgressBar = {getTickCount(), repairDuration}
			selectedParts = {}
		else
			setElementFrozen(localPlayer, false)
		end
	end
)

addEvent("interruptReaction", true)
addEventHandler("interruptReaction", getRootElement(),
	function ()
		setElementFrozen(localPlayer, false)

		removeEventHandler("onClientRender", getRootElement(), renderTheInvoice)
		removeEventHandler("onClientClick", getRootElement(), clickInvoice)

		triggerServerEvent("invoiceReaction", localPlayer, activeButton, invoiceList.veh)

		if isElement(invoiceRoboto) then
			destroyElement(invoiceRoboto)
		end

		invoiceRoboto = nil
	end
)

function clickInvoice(button, state)
	if state == "down" then
		setElementFrozen(localPlayer, false)

		removeEventHandler("onClientRender", getRootElement(), renderTheInvoice)
		removeEventHandler("onClientClick", getRootElement(), clickInvoice)

		triggerServerEvent("invoiceReaction", localPlayer, activeButton, invoiceList.veh)

		if isElement(invoiceRoboto) then
			destroyElement(invoiceRoboto)
		end

		invoiceRoboto = nil
	end
end

function renderTheInvoice()
	local cursorX, cursorY = getCursorPosition()

	if isCursorShowing() then
		cursorX, cursorY = cursorX * screenX, cursorY * screenY
	else
		cursorX, cursorY = 0, 0
	end

	local partsTable = invoiceList.parts
	local partsCount = #partsTable

	local sx = respc(350)
	local sy = respc(32) + (partsCount + 1) * respc(20) + respc(4) + respc(66)

	local x = math.floor(screenX / 2 - sx / 2)
	local y = math.floor(screenY / 2 - sy / 2)

	-- ** Háttér
	dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))

	-- ** Cím
	dxDrawRectangle(x, y, sx, respc(32), tocolor(0, 0, 0, 150))
	dxDrawText(invoiceList.vehName, x, y, x + sx, y + respc(32), tocolor(255, 255, 255), 0.8, invoiceRoboto, "center", "center", false, true)

	-- ** Content
	local startX = x + respc(8)
	local startY = y + respc(32) + respc(8)

	local oneRowSizeX = sx - respc(16)
	local oneRowSizeY = respc(20)

	activeButton = false

	local totalPrice = 0

	for i = 1, partsCount + 2 do
		local part = invoiceList.parts[i]

		if i == partsCount + 2 then
			startY = y + sy - respc(8) - respc(25)

			-- Elfogadás
			if cursorX >= startX and cursorX <= startX + oneRowSizeX / 2 - respc(4) and cursorY >= startY and cursorY <= startY + respc(25) then
				activeButton = "accept"
			end

			dxDrawRectangle(startX - respc(2), startY - respc(2), oneRowSizeX / 2, respc(25) + respc(4), tocolor(0, 0, 0, 200))

			if activeButton == "accept" then
				dxDrawRectangle(startX, startY, oneRowSizeX / 2 - respc(4), respc(25), tocolor(61, 122, 188, 225))
			else
				dxDrawRectangle(startX, startY, oneRowSizeX / 2 - respc(4), respc(25), tocolor(61, 122, 188, 150))
			end

			dxDrawText("Elfogad", startX, startY, startX + oneRowSizeX / 2 - respc(4), startY + respc(25), tocolor(0, 0, 0), 0.8, invoiceRoboto, "center", "center")

			-- Elutasítás
			startX = startX + oneRowSizeX / 2 + respc(4)

			if cursorX >= startX and cursorX <= startX + oneRowSizeX / 2 - respc(4) and cursorY >= startY and cursorY <= startY + respc(25) then
				activeButton = "decline"
			end

			dxDrawRectangle(startX - respc(2), startY - respc(2), oneRowSizeX / 2, respc(25) + respc(4), tocolor(0, 0, 0, 200))

			if activeButton == "decline" then
				dxDrawRectangle(startX, startY, oneRowSizeX / 2 - respc(4), respc(25), tocolor(215, 89, 89, 225))
			else
				dxDrawRectangle(startX, startY, oneRowSizeX / 2 - respc(4), respc(25), tocolor(215, 89, 89, 150))
			end

			dxDrawText("Elutasít", startX, startY, startX + oneRowSizeX / 2 - respc(4), startY + respc(25), tocolor(0, 0, 0), 0.8, invoiceRoboto, "center", "center")
		elseif i == partsCount + 1 then
			dxDrawLine(startX + respc(4), startY, startX + oneRowSizeX - respc(4), startY, tocolor(255, 255, 255), 2)

			startY = startY + 2 + respc(4)

			dxDrawText("Összesen: ", startX + respc(4), startY, startX + oneRowSizeX, startY + oneRowSizeY, tocolor(255, 255, 255), 0.8, invoiceRoboto, "left", "center")
			dxDrawText(totalPrice .. " $", 0, startY, startX + oneRowSizeX - respc(4), startY + oneRowSizeY, tocolor(255, 255, 255), 0.8, invoiceRoboto, "right", "center")

			startY = startY + oneRowSizeY
		else
			totalPrice = totalPrice + part[2]

			if part[1] == "Olajcsere" then
				dxDrawText(part[1], startX + respc(4), startY, startX + oneRowSizeX, startY + oneRowSizeY, tocolor(255, 255, 255), 0.8, invoiceRoboto, "left", "center")
			else
				dxDrawText(part[1] .. " javítása", startX + respc(4), startY, startX + oneRowSizeX, startY + oneRowSizeY, tocolor(255, 255, 255), 0.8, invoiceRoboto, "left", "center")
			end

			dxDrawText(part[2] .. " $", 0, startY, startX + oneRowSizeX - respc(4), startY + oneRowSizeY, tocolor(255, 255, 255), 0.8, invoiceRoboto, "right", "center")

			startY = startY + oneRowSizeY
		end
	end
end

function renderService()
	local lastDistance = 5
	local nearbyVehicle = false
	local vehiclesTable = getElementsByType("vehicle", getRootElement(), true)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)

	for i = 1, #vehiclesTable do
		local vehicleElement = vehiclesTable[i]

		if isElement(vehicleElement) then
			local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicleElement)
			local currentDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, vehicleX, vehicleY, vehicleZ)

			if lastDistance > currentDistance then
				lastDistance = currentDistance
				nearbyVehicle = vehicleElement
			end
		end
	end

	if detectedVehicle ~= nearbyVehicle then
		if nearbyVehicle then
			local detectedModel = getElementModel(nearbyVehicle)

			vehicleName = exports.see_vehiclenames:getCustomVehicleName(detectedModel)
			vehiclePrice = exports.see_carshop:getCarPrice(detectedModel)

			vehicleGroup = getElementData(nearbyVehicle, "vehicle.group") or 0
			elevatorLevel = getElementData(nearbyVehicle, "elevatorLevel") or 0
		end

		detectedVehicle = nearbyVehicle
		selectedParts = {}

		playerSelection = false
		selectedPlayer = false
	end

	local cursorX, cursorY = getCursorPosition()

	if isCursorShowing() then
		cursorX, cursorY = cursorX * screenX, cursorY * screenY
	else
		cursorX, cursorY = 0, 0
	end

	if fixProgressBar then
		local elapsedTime = getTickCount() - fixProgressBar[1]
		local progress = elapsedTime / fixProgressBar[2]
		--setElementFrozen(localPlayer, true)

		if progress >= 1 then
			fixProgressBar = false
			setElementFrozen(localPlayer, false)
		end

		local sx = respc(512)
		local sy = respc(32)

		local x = screenX / 2 - sx / 2
		local y = screenY - respc(256)

		dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))

		dxDrawRectangle(x + respc(2), y + respc(2), sx - respc(4), sy - respc(4), tocolor(0, 0, 0, 150))
		dxDrawRectangle(x + respc(2), y + respc(2), (sx - respc(4)) * progress, sy - respc(4), tocolor(61, 122, 188, 175))

		dxDrawText("Javítás folyamatban...", x, y, x + sx, y + sy, tocolor(255, 255, 255), 0.75, Roboto, "center", "center")
	elseif selectedPlayer then
		if not isElement(selectedPlayer) then
			selectedPlayer = false
			setElementFrozen(localPlayer, false)
		else
			local y = screenY - respc(256)

			for xoff = -1, 1, 2 do
				for yoff = -1, 1, 2 do
					dxDrawText("Várakozás " .. selectedPlayerName .. " reakciójára.", 0 + xoff, y + yoff, screenX + xoff, 0 + yoff, tocolor(0, 0, 0), 1, Roboto, "center", "top")
				end
			end

			dxDrawText("Várakozás " .. selectedPlayerName .. " reakciójára.", 0, y, screenX, 0, tocolor(255, 255, 255), 1, Roboto, "center", "top")
		end
	elseif nearbyVehicle then
		if playerSelection then
			local y = screenY - respc(256)

			for xoff = -1, 1, 2 do
				for yoff = -1, 1, 2 do
					dxDrawText("Kattints arra a játékosra, akinek szeretnéd a számlát átadni!", 0 + xoff, y + yoff, screenX + xoff, 0 + yoff, tocolor(0, 0, 0), 1, Roboto, "center", "top")
				end
			end

			dxDrawText("Kattints arra a játékosra, akinek szeretnéd a számlát átadni!", 0, y, screenX, 0, tocolor(255, 255, 255), 1, Roboto, "center", "top")
	
			return
		end

		local partsTable = getComponents(nearbyVehicle)
		local partsCount = #partsTable

		local sx = respc(350)
		local sy = respc(32) + (partsCount + 1) * respc(36) + respc(4) + respc(4)

		local x = math.floor(panelStartX - sx)
		local y = math.floor(panelStartY - sy / 2)

		if isCursorShowing() and getKeyState("mouse1") then
			if panelMoving then
				panelStartX = math.floor(panelMoving[3] + cursorX - panelMoving[1])
				panelStartY = math.floor(panelMoving[4] + cursorY - panelMoving[2])
			else
				if cursorX >= x and cursorY >= y and cursorX <= x + sx and cursorY <= y + respc(32) then
					panelMoving = {cursorX, cursorY, panelStartX, panelStartY}
				end
			end
		else
			panelMoving = false
		end

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))

		-- ** Cím
		dxDrawRectangle(x, y, sx, respc(32), tocolor(0, 0, 0, 150))
		dxDrawText(vehicleName, x, y, x + sx, y + respc(32), tocolor(255, 255, 255), 0.8, Roboto, "center", "center", false, true)

		-- ** Content
		local startX = x + respc(8)
		local startY = y + respc(32) + respc(8)

		local oneRowSizeX = sx - respc(16)
		local oneRowSizeY = respc(36) - respc(8)

		activeButton = false

		local totalPrice = 0

		if partsCount > 0 then
			for i = 1, partsCount + 1 do
				local part = partsTable[i]

				dxDrawRectangle(startX - respc(2), startY - respc(2), oneRowSizeX + respc(4), oneRowSizeY + respc(4), tocolor(0, 0, 0, 200))

				if i == partsCount + 1 then
					if cursorX >= startX and cursorX <= startX + oneRowSizeX and cursorY >= startY and cursorY <= startY + oneRowSizeY then
						activeButton = "startfix"
					end

					if activeButton == "startfix" then
						dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(61, 122, 188, 225))
					else
						dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(61, 122, 188, 150))
					end

					dxDrawText("Szerelés megkezdése", startX + respc(4), startY, 0, startY + oneRowSizeY, tocolor(0, 0, 0, 255), 0.8, Roboto, "left", "center")
					dxDrawText(totalPrice .. " $", 0, startY, startX + oneRowSizeX - respc(4), startY + oneRowSizeY, tocolor(0, 0, 0, 255), 0.8, Roboto, "right", "center")
				else
					if cursorX >= startX and cursorX <= startX + oneRowSizeX and cursorY >= startY and cursorY <= startY + oneRowSizeY then
						activeButton = "check:" .. part[1]
					end

					if selectedParts[part[1]] then
						if activeButton == "check:" .. part[1] then
							dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(89, 142, 215, 180))
						else
							dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(89, 142, 215, 225))
						end

						dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(50, 179, 239, 50))

						totalPrice = totalPrice + part[2]
					else
						if activeButton == "check:" .. part[1] then
							dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(89, 142, 215, 150))
						else
							dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(89, 142, 215, 115))
						end
					end

					if part[1] == "Olajcsere" then
						dxDrawText(part[1], startX + respc(4), startY, startX + oneRowSizeX, startY + oneRowSizeY, tocolor(0, 0, 0, 255), 0.8, Roboto, "left", "center")
					else
						dxDrawText(part[1] .. " javítása", startX + respc(4), startY, 0, startY + oneRowSizeY, tocolor(0, 0, 0, 255), 0.8, Roboto, "left", "center")
					end

					dxDrawText(part[2] .. " $", 0, startY, startX + oneRowSizeX - respc(4), startY + oneRowSizeY, tocolor(0, 0, 0, 255), 0.8, Roboto, "right", "center")
				end

				startY = startY + oneRowSizeY + respc(8)
			end
		else
			dxDrawRectangle(startX - respc(2), startY - respc(2), oneRowSizeX + respc(4), oneRowSizeY + respc(4), tocolor(0, 0, 0, 200))
			dxDrawRectangle(startX, startY, oneRowSizeX, oneRowSizeY, tocolor(61, 122, 188, 225))
			dxDrawText("Jelenleg nincs mit szerelni", startX, startY, startX + oneRowSizeX, startY + oneRowSizeY, tocolor(0, 0, 0, 255), 0.8, Roboto, "center", "center")
		end
	end
end

function getBasePrice(price)
	if vehicleGroup == 1 or vehicleGroup == 2 or vehicleGroup == 12 or vehicleGroup == 13 or vehicleGroup == 21 or vehicleGroup == 26 then
		price = price * 0.4
	end

	if price < 18400 then
		return math.floor(price * 0.006)
	elseif price < 50200 then
		return math.floor(price * 0.005)
	elseif price < 97700 then
		return math.floor(price * 0.005)
	elseif price < 148800 then
		return math.floor(price * 0.0045)
	elseif price < 170000 then
		return math.floor(price * 0.004)
	elseif price < 300000 then
		return math.floor(price * 0.004)
	elseif price < 390500 then
		return math.floor(price * 0.00375)
	elseif price < 800000 then
		return math.floor(price * 0.0035)
	elseif price < 1378000 then
		return math.floor(price * 0.00275)
	elseif price < 1787500 then
		return math.floor(price * 0.0025)
	end
end

function getComponents(vehicleElement)
	local componentsTable = {}
	local basePrice = math.floor(vehiclePrice * 0.0075) -- getBasePrice(vehiclePrice)

	if elevatorLevel == 0 then
		for i = 0, 6 do
			local state = getVehiclePanelState(vehicleElement, i)

			if state > 0 then
				if i <= 3 then
					table.insert(componentsTable, {panelNames[i + 1], math.floor(basePrice * 0.45 * state + priceMargin), "panel:" .. i, state, basePrice * 0.45 * state})
				elseif i == 4 then
					table.insert(componentsTable, {panelNames[i + 1], math.floor(basePrice * 0.4 * state + priceMargin), "panel:" .. i, state, basePrice * 0.4 * state})
				else
					table.insert(componentsTable, {panelNames[i + 1], math.floor(basePrice * 0.55 * state + priceMargin), "panel:" .. i, state, basePrice * 0.55 * state})
				end
			end
		end

		for i = 0, 5 do
			local state = getVehicleDoorState(vehicleElement, i)

			if state > 1 then
				if i <= 1 then
					if state == 4 then
						table.insert(componentsTable, {doorNames[i + 1], math.floor(basePrice * 0.75 * 2 + priceMargin), "door:" .. i, 2, basePrice * 0.75 * 2})
					else
						table.insert(componentsTable, {doorNames[i + 1], math.floor(basePrice * 0.75 * 1 + priceMargin), "door:" .. i, 1, basePrice * 0.75 * 1})
					end
				elseif state == 4 then
					table.insert(componentsTable, {doorNames[i + 1], math.floor(basePrice * 0.65 * 2 + priceMargin), "door:" .. i, 2, basePrice * 0.65 * 2})
				else
					table.insert(componentsTable, {doorNames[i + 1], math.floor(basePrice * 0.65 * 1 + priceMargin), "door:" .. i, 2, basePrice * 0.65 * 1})
				end
			end
		end

		for i = 0, 3 do
			local state = getVehicleLightState(vehicleElement, i)

			if state > 0 then
				table.insert(componentsTable, {lightNames[i + 1], math.floor(basePrice * 0.15 + priceMargin), "light:" .. i, 1, basePrice * 0.15})
			end
		end

		local vehicleHealth = getElementHealth(vehicleElement)

		if vehicleHealth < 321 then
			table.insert(componentsTable, {"Totálkáros motor", math.floor(basePrice * 3.25 + priceMargin), "engine", 3, basePrice * 3.25})
		elseif vehicleHealth < 490 then
			table.insert(componentsTable, {"Hibás motor", math.floor(basePrice * 2.25 + priceMargin), "engine", 2, basePrice * 2.25})
		elseif vehicleHealth < 650 then
			table.insert(componentsTable, {"Enyhén hibás motor", math.floor(basePrice * 1.25 + priceMargin), "engine", 1, basePrice * 1.25})
		end
	elseif elevatorLevel == 1 then
		for i = 1, 4 do
			local state = {getVehicleWheelStates(vehicleElement)}

			if state[i] > 0 then
				table.insert(componentsTable, {wheelNames[i], math.floor(basePrice * 0.35 * state[i] + priceMargin), "wheel:" .. i, state[i], basePrice * 0.35 * state[i]})
			end
		end
	elseif elevatorLevel == 2 then
		table.insert(componentsTable, {"Olajcsere", math.floor(basePrice * 0.35 + priceMargin), "oilchange", 1, basePrice * 0.35})
	end

	return componentsTable
end

local repairSounds = {}

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if repairSounds[source] then
			if isElement(repairSounds[source]) then
				destroyElement(repairSounds[source])
			end

			repairSounds[source] = nil
		end
	end
)

addEvent("repairVehicleSound", true)
addEventHandler("repairVehicleSound", getRootElement(),
	function (state)
		if isElement(source) then
			if state then
				if isElement(repairSounds[source]) then
					destroyElement(repairSounds[source])
				end

				repairSounds[source] = playSound3D("files/repair.mp3", 0, 0, 0, true)

				if isElement(repairSounds[source]) then
					attachElements(repairSounds[source], source)
				end
			else
				if isElement(repairSounds[source]) then
					destroyElement(repairSounds[source])
				end

				repairSounds[source] = nil
			end
		end
	end
)

addEvent("elevatorSound", true)
addEventHandler("elevatorSound", resourceRoot,
	function (sourceElevator, state)
		if isElement(sourceElevator) then
			local elevatorX, elevatorY, elevatorZ = getElementPosition(sourceElevator)
			local playerX, playerY, playerZ = getElementPosition(localPlayer)

			if state then
				if getDistanceBetweenPoints3D(elevatorX, elevatorY, elevatorZ, playerX, playerY, playerZ) < 200 then
					local soundElement = playSound3D("files/lift.mp3", elevatorX, elevatorY, elevatorZ)

					if isElement(soundElement) then
						setElementData(sourceElevator, "soundElement", soundElement, false)
					end
				end
			else
				local soundElement = getElementData(sourceElevator, "soundElement")

				if isElement(soundElement) then
					stopSound(soundElement)
				end
			end
		end
	end
)

addEvent("oilChangeEffect", true)
addEventHandler("oilChangeEffect", resourceRoot,
	function (sourceVehicle)
		if isElement(sourceVehicle) then
			local vehicleX, vehicleY, vehicleZ = getElementPosition(sourceVehicle)
			local effectElement = createEffect("puke", vehicleX, vehicleY, vehicleZ, 270, 0, 0)

			if isElement(effectElement) then
				setEffectSpeed(effectElement, 0.25)
			end
		end
	end
)