local screenX, screenY = guiGetScreenSize()

crabCratesOnShip = {}
crabObjectsOnShip = {}

shipWeights = {}
baitObjects = {}

local myShipCrabWeight = 0
local myShipCagesCount = 0
local myShipCagesPrice = 0

local menuWidth = respc(300)
local menuHeight = respc(120)

local menuPosX = screenX / 2 - menuWidth / 2
local menuPosY = screenY / 2 - menuHeight / 2

local activeButton = false
local activeCageButton = false
local lastClickTick = 0

local availableMarkerPoints = {
	{-2421.123046875, 2299.9033203125, -0.55000001192093},
	{-2421.123046875, 2287.9033203125, -0.55000001192093},
	{-2421.123046875, 2275.9033203125, -0.55000001192093},
	{-2421.123046875, 2263.9033203125, -0.55000001192093},
	{2321.6001, 487, -0.4}
}

local crabCratesInWater = {}
local fishingShips = {}

local shipInteriorObjects = {}
local shipInteriorCoronas = {}

local priceRenderTarget = dxCreateRenderTarget(275, 256, true)

function redrawPrice()
	local BrushScriptStd = dxCreateFont("files/BrushScriptStd.ttf", 30, false, "antialiased")

	dxSetRenderTarget(priceRenderTarget, true)
	dxDrawText("Rák árfolyam:\n" .. math.floor(crabPrice * 10) / 10 .. " $/kg", 0, 0, 275, 256, tocolor(255, 255, 255), 1, BrushScriptStd, "center", "center")
	dxSetRenderTarget()

	destroyElement(BrushScriptStd)
end

addEventHandler("onClientRestore", getRootElement(),
	function ()
		redrawPrice()
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "crabPrice" then
			crabPrice = getElementData(resourceRoot, "crabPrice")
			redrawPrice()
		elseif dataName == "cageOfShip" then
			if isElementStreamedIn(source) then
				local shipId = getElementData(source, "cageOfShip")

				if shipId then
					crabCratesInWater[source] = shipId
				end
			end
		elseif dataName == "vehicle.dbID" then
			local vehicleModel = getElementModel(source)

			if vehicleModel == 453 or vehicleModel == 454 then
				fishingShips[source] = getElementData(source, "vehicle.dbID")
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local cageCol = engineLoadCOL("files/cage.col")
		if cageCol then
			engineReplaceCOL(cageCol, replacementModels.cage)
			engineReplaceCOL(cageCol, replacementModels.crab)
			engineReplaceCOL(cageCol, replacementModels.bait)
			engineReplaceCOL(cageCol, replacementModels.buoy)

			local cageTxd = engineLoadTXD("files/cage.txd")
			if cageTxd then
				engineImportTXD(cageTxd, replacementModels.cage)
				engineImportTXD(cageTxd, replacementModels.crab)
				engineImportTXD(cageTxd, replacementModels.bait)

				local cageDff = engineLoadDFF("files/cage.dff")
				if cageDff then
					engineReplaceModel(cageDff, replacementModels.cage)
				end

				local buoyTxd = engineLoadTXD("files/buoy.txd")
				if buoyTxd then
					engineImportTXD(buoyTxd, replacementModels.buoy)

					local buoyDff = engineLoadDFF("files/buoy.dff")
					if buoyDff then
						engineReplaceModel(buoyDff, replacementModels.buoy)
					end
				end

				local crabDff = engineLoadDFF("files/crab.dff")
				if crabDff then
					engineReplaceModel(crabDff, replacementModels.crab)
				end

				local fishDff = engineLoadDFF("files/deadfish.dff")
				if fishDff then
					engineReplaceModel(fishDff, replacementModels.bait)
				end
			end
		end

		for i = 1, #availableMarkerPoints do
			local markerPoint = availableMarkerPoints[i]

			if markerPoint then
				markerPoint[4] = createMarker(markerPoint[1], markerPoint[2], markerPoint[3], "cylinder", 4, 223, 181, 81, 150)

				if isElement(markerPoint[4]) then
					setElementData(markerPoint[4], "3DText", "Leadó pont - #dfb551Rák", false)
					setElementData(markerPoint[4], "markerPointId", i, false)
				end
			end
		end

		crabPrice = getElementData(resourceRoot, "crabPrice")
		redrawPrice()

		local objectList = getElementsByType("object", getResourceRootElement(), true)
		local vehicleList = getElementsByType("vehicle")

		for i = 1, #objectList do
			local objectElement = objectList[i]

			if getElementModel(objectElement) == replacementModels.buoy then
				local shipId = getElementData(objectElement, "cageOfShip")

				if shipId then
					crabCratesInWater[objectElement] = shipId
				end
			end
		end

		for i = 1, #vehicleList do
			local vehicleElement = vehicleList[i]
			local vehicleModel = getElementModel(vehicleElement)

			if vehicleModel == 453 or vehicleModel == 454 then
				fishingShips[vehicleElement] = getElementData(vehicleElement, "vehicle.dbID")
			end
		end

		if getElementInterior(localPlayer) == 123 then
			createShipInterior(getElementDimension(localPlayer))
		end
	end
)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if getElementInterior(localPlayer) == 123 then
			if getElementData(localPlayer, "inTugBoat") then
				setElementFrozen(localPlayer, true)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		if getElementModel(source) == replacementModels.buoy then
			local shipId = getElementData(source, "cageOfShip")

			if shipId then
				crabCratesInWater[source] = shipId
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
	function ()
		if crabCratesInWater[source] then
			crabCratesInWater[source] = nil
		end
	end
)

addEventHandler("onClientMarkerHit", getResourceRootElement(),
	function (hitElement, matchingDimension)
		if matchingDimension then
			if hitElement == localPlayer then
				if getElementData(source, "markerPointId") then
					local currentVehicle = getPedOccupiedVehicle(localPlayer)

					if currentVehicle then
						local vehicleModel = getElementModel(currentVehicle)

						if vehicleModel == 453 or vehicleModel == 454 then
							local numOfCrates = getElementData(currentVehicle, "numOfCrates") or 0

							if numOfCrates > 0 then
								exports.see_hud:showInfobox("e", "Előbb add le a másik fajta ládákat.")
								return
							end

							setElementVelocity(currentVehicle, 0, 0, 0)
							setElementFrozen(currentVehicle, true)

							local crabWeights = shipDatas[currentVehicle].crabWeights or {}
							local totalWeight = 0
							local totalPrice = 0

							for k in pairs(crabWeights) do
								local thisWeight = tonumber(crabWeights[k]) or 0

								if thisWeight > 0 then
									totalWeight = totalWeight + thisWeight
									totalPrice = totalPrice + cagePrice
								end
							end

							myShipCrabWeight = totalWeight
							myShipCagesCount = shipDatas[currentVehicle].numOfCrabCrates or 0
							myShipCagesPrice = totalPrice

							addEventHandler("onClientRender", getRootElement(), renderCrabMenu)
							addEventHandler("onClientClick", getRootElement(), clickCrabMenu)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local contactElement = getPedContactElement(localPlayer)

		activeCageButton = false

		if isElement(priceRenderTarget) then
			dxDrawMaterialLine3D(2328.0776367188, 502.21578979492, 3.2701209576925, 2328.0776367188, 502.21578979492, 1.5634542910258, priceRenderTarget, 1.8333333333333, tocolor(255, 255, 255), 2327.3956384748, 501.48443598507, 3.2701209576925)
		end

		if contactElement then
			local contactModel = getElementModel(contactElement)

			if contactModel == 453 or contactModel == 454 then
				if not isPedInVehicle(localPlayer) then
					local playerX, playerY, playerZ = getElementPosition(localPlayer)
					local cursorX, cursorY = getCursorPosition()

					if not cursorX then
						cursorX = -1000
						cursorY = -1000
					else
						cursorX = cursorX * screenX
						cursorY = cursorY * screenY
					end

					local lastCrateIndex = 0

					if crabCratesOnShip[contactElement] then
						lastCrateIndex = #crabCratesOnShip[contactElement]
					end

					if lastCrateIndex > 0 then
						local crateElement = crabCratesOnShip[contactElement][lastCrateIndex]
						local crateX, crateY, crateZ = getElementPosition(crateElement)

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, crateX, crateY, crateZ) <= 2.5 then
							local guiPosX, guiPosY, guiDistance = getScreenFromWorldPosition(crateX, crateY, crateZ + 0.45)

							if guiPosX and guiPosY then
								local numOfBaits = 0
								local visibleText = "Add le a teli ketreceket,\nmielőtt újat dobsz ki!"
								local totalWeight = shipWeights[contactElement] or 0

								if totalWeight <= 0 then
									local currentBait = shipDatas[contactElement].currentBait

									if currentBait then
										numOfBaits = tonumber(currentBait[lastCrateIndex]) or 0
									end

									visibleText = "Csali: " .. numOfBaits .. "/4 db"
								end

								if guiDistance < 3.6 then
									guiDistance = 3.6
								end

								dxDrawText(visibleText, guiPosX - respc(272 / guiDistance), 0, guiPosX + respc(272 / guiDistance), guiPosY - respc(144 / guiDistance), tocolor(255, 255, 255), 3.6 / guiDistance, Roboto, "center", "bottom")

								-- ** Gombok
								local buttonSize = respc(256 / guiDistance)
								local primaryPosX = guiPosX - respc(272 / guiDistance)
								local secondaryPosX = guiPosX + respc(16 / guiDistance)
								local buttonPosY = guiPosY - respc(128 / guiDistance)

								-- Kidobás
								local cageDropAlpha = 150
								if totalWeight > 0 then
									cageDropAlpha = 75
								else
									if cursorX >= primaryPosX and cursorX <= primaryPosX + buttonSize then
										if cursorY >= buttonPosY and cursorY <= buttonPosY + buttonSize then
											activeCageButton = {contactElement, "drop"}
											cageDropAlpha = 255
										end
									end
								end
								dxDrawRectangle(primaryPosX, buttonPosY, buttonSize, buttonSize, tocolor(0, 0, 0, 150))
								dxDrawImage(primaryPosX, buttonPosY, buttonSize, buttonSize, "files/cage_down.png", 0, 0, 0, tocolor(61, 122, 188, cageDropAlpha))

								-- Csali
								local cageBaitAlpha = 150
								if totalWeight > 0 then
									cageBaitAlpha = 75
								else
									if cursorX >= secondaryPosX and cursorX <= secondaryPosX + buttonSize then
										if cursorY >= buttonPosY and cursorY <= buttonPosY + buttonSize then
											if numOfBaits < 4 then
												activeCageButton = {contactElement, "bait"}
												cageBaitAlpha = 255
											end
										end
									end
								end
								dxDrawRectangle(secondaryPosX, buttonPosY, buttonSize, buttonSize, tocolor(0, 0, 0, 150))
								dxDrawImage(secondaryPosX, buttonPosY, buttonSize, buttonSize, "files/cage_fish.png", 0, 0, 0, tocolor(61, 122, 188, cageBaitAlpha))
							end
						end
					end

					for objectElement, shipId in pairs(crabCratesInWater) do
						if shipId == fishingShips[contactElement] then
							if not isElement(objectElement) then
								crabCratesInWater[objectElement] = nil
							else
								local crateX, crateY, crateZ = getElementPosition(objectElement)
								local maximumDistance = 2.3

								if getElementModel(contactElement) == 454 then
									maximumDistance = 5
								end

								if getDistanceBetweenPoints3D(playerX, playerY, playerZ, crateX, crateY, crateZ) <= maximumDistance then
									local guiPosX, guiPosY, guiDistance = getScreenFromWorldPosition(crateX, crateY, crateZ + 0.45)

									if guiPosX and guiPosY then
										local guiSize = respc(256 / guiDistance)

										guiPosX = guiPosX - guiSize / 2
										guiPosY = guiPosY - guiSize / 2

										local cageUpAlpha = 150

										if cursorX >= guiPosX and cursorX <= guiPosX + guiSize then
											if cursorY >= guiPosY and cursorY <= guiPosY + guiSize then
												activeCageButton = {contactElement, "getin", objectElement}
												cageUpAlpha = 255
											end
										end

										dxDrawRectangle(guiPosX, guiPosY, guiSize, guiSize, tocolor(0, 0, 0, 150))
										dxDrawImage(guiPosX, guiPosY, guiSize, guiSize, "files/cage_up.png", 0, 0, 0, tocolor(61, 122, 188, cageUpAlpha))
									end
								end
							end
						end
					end

					if contactModel == 454 then
						local leftX, leftY, leftZ = getPositionFromElementOffset(contactElement, -3.5, -2.75, 1.25)
						local rightX, rightY, rightZ = getPositionFromElementOffset(contactElement, 3.5, -2.75, 1.25)

						local rightDoorDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, rightX, rightY, rightZ)
						local leftDoorDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, leftX, leftY, leftZ)

						if rightDoorDistance <= 0.65 or leftDoorDistance <= 0.65 then
							dxDrawRectangle(screenX / 2 - respc(150), screenY - respc(128), respc(300), respc(40), tocolor(0, 0, 0, 100))

							if not isVehicleLocked(contactElement) then
								dxDrawText("Belépéshez: #3d7abc/enter", 0, screenY - respc(128), screenX, screenY - respc(88), tocolor(255, 255, 255), 1, Roboto, "center", "center", false, false, false, true)
							else
								dxDrawText("Az ajtó #d75959zárva #ffffffvan.", 0, screenY - respc(128), screenX, screenY - respc(88), tocolor(255, 255, 255), 1, Roboto, "center", "center", false, false, false, true)
							end
						end
					end
				end
			elseif contactModel == 9494 then
				if getElementInterior(localPlayer) == 123 then
					local shipElement = getElementData(localPlayer, "inTugBoat")
					local isLocked = false

					if isElement(shipElement) then
						isLocked = isVehicleLocked(shipElement)
					end

					local playerX, playerY, playerZ = getElementPosition(localPlayer)
					local rightDoorDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, -746.1103515625, 393.744140625, 9999.421875)
					local leftDoorDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, -746.1103515625, 387.744140625, 9999.421875)

					if rightDoorDistance <= 0.65 or leftDoorDistance <= 0.65 then
						dxDrawRectangle(screenX / 2 - respc(150), screenY - respc(128), respc(300), respc(40), tocolor(0, 0, 0, 100))

						if not isLocked then
							dxDrawText("Kilépéshez: #3d7abc/enter", 0, screenY - respc(128), screenX, screenY - respc(88), tocolor(255, 255, 255), 1, Roboto, "center", "center", false, false, false, true)
						else
							dxDrawText("Az ajtó #d75959zárva #ffffffvan.", 0, screenY - respc(128), screenX, screenY - respc(88), tocolor(255, 255, 255), 1, Roboto, "center", "center", false, false, false, true)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if button == "left" then
			if state == "up" then
				if activeCageButton then
					if getTickCount() - lastClickTick <= 1000 then
						exports.see_hud:showInfobox("e", "Ilyen gyorsan nem kéne!")
						return
					end

					local shipElement = activeCageButton[1]
					local streamedPlayers = getElementsByType("player", getRootElement(), true)

					if isElement(shipElement) then
						local totalWeight = shipWeights[shipElement] or 0

						if activeCageButton[2] == "bait" then
							if totalWeight <= 0 then
								triggerServerEvent("baitTheShip", localPlayer, shipElement, streamedPlayers)
							end
						elseif activeCageButton[2] == "drop" then
							if totalWeight <= 0 then
								triggerServerEvent("dropCage", localPlayer, shipElement, streamedPlayers)
							end
						elseif activeCageButton[2] == "getin" then
							triggerServerEvent("getInCage", localPlayer, shipElement, activeCageButton[3], streamedPlayers)
						end
					end

					lastClickTick = getTickCount()
				end
			end
		end
	end
)

addEvent("playCrabSound", true)
addEventHandler("playCrabSound", getRootElement(),
	function (filePath, x, y, z)
		local soundEffect = playSound3D(filePath, x, y, z)
		if isElement(soundEffect) then
			setSoundMaxDistance(soundEffect, 35)
		end
	end
)

function clickCrabMenu(button, state)
	if button == "left" then
		if state == "up" then
			if activeButton == "close" then
				removeEventHandler("onClientRender", getRootElement(), renderCrabMenu)
				removeEventHandler("onClientClick", getRootElement(), clickCrabMenu)
				setElementFrozen(getPedOccupiedVehicle(localPlayer), false)
				lastClickTick = 0
				return
			end

			if activeButton then
				if getTickCount() - lastClickTick <= 500 then
					exports.see_hud:showInfobox("e", "Ilyen gyorsan nem kéne!")
					return
				end

				local currentVehicle = getPedOccupiedVehicle(localPlayer)
				local streamedPlayers = getElementsByType("player", getRootElement(), true)

				if activeButton == "plus" or activeButton == "minus" then
					triggerServerEvent("buyCrabCage", localPlayer, currentVehicle, activeButton, streamedPlayers)
				elseif activeButton == "sellcrab" then
					triggerServerEvent("sellCrabCage", localPlayer, currentVehicle, streamedPlayers)
				end

				lastClickTick = getTickCount()
			end
		end
	end
end

function renderCrabMenu()
	local currentVehicle = getPedOccupiedVehicle(localPlayer)

	if not currentVehicle then
		removeEventHandler("onClientRender", getRootElement(), renderCrabMenu)
		removeEventHandler("onClientClick", getRootElement(), clickCrabMenu)
		return
	end

	local cursorX, cursorY = getCursorPosition()

	if cursorX then
		cursorX = cursorX * screenX
		cursorY = cursorY * screenY
	else
		cursorX = 0
		cursorY = 0
	end

	activeButton = false

	-- ** Háttér
	dxDrawRectangle(menuPosX, menuPosY, menuWidth, menuHeight, tocolor(0, 0, 0, 160))

	-- ** Keret
	dxDrawRectangle(menuPosX - 2, menuPosY - 2, menuWidth + 4, 2, tocolor(0, 0, 0, 200)) -- felső
	dxDrawRectangle(menuPosX - 2, menuPosY + menuHeight, menuWidth + 4, 2, tocolor(0, 0, 0, 200)) -- alsó
	dxDrawRectangle(menuPosX - 2, menuPosY, 2, menuHeight, tocolor(0, 0, 0, 200)) -- bal
	dxDrawRectangle(menuPosX + menuWidth, menuPosY, 2, menuHeight, tocolor(0, 0, 0, 200)) -- jobb

	-- ** Bezárás
	local closeAlpha = 200

	if cursorX >= menuPosX + menuWidth - respc(40) and cursorX <= menuPosX + menuWidth then
		if cursorY >= menuPosY and cursorY <= menuPosY + respc(40) then
			closeAlpha = 255
			activeButton = "close"
		end
	end

	dxDrawRectangle(menuPosX + menuWidth - respc(40), menuPosY, respc(40), respc(40), tocolor(0, 0, 0, 100))
	dxDrawText("X", menuPosX + menuWidth - respc(40), menuPosY, menuPosX + menuWidth, menuPosY + respc(40), tocolor(215, 89, 89, closeAlpha), 1, Roboto, "center", "center")

	-- ** Szöveg
	if myShipCrabWeight > 0 then
		dxDrawText("Hajó tartalma: #598ed7" .. math.floor(myShipCrabWeight * 10) / 10 .. " kg#ffffff rák.\nEgységár: #3d7abc" .. math.floor(crabPrice * 10) / 10 .. " $/kg\n#ffffffÉrték: #3d7abc" .. math.floor(crabPrice * myShipCrabWeight + myShipCagesPrice) .. " $", menuPosX, menuPosY + respc(10), menuPosX + menuWidth, 0, tocolor(255, 255, 255), 0.8, Roboto, "center", "top", false, false, false, true)
	else
		dxDrawText("Ketrecek:\n(#3d7abc" .. cagePrice .. "$#ffffff/ketrec)", menuPosX, menuPosY + respc(10), menuPosX + menuWidth, 0, tocolor(255, 255, 255), 0.8, Roboto, "center", "top", false, false, false, true)
		dxDrawText(myShipCagesCount, menuPosX, menuPosY + menuHeight - respc(50), menuPosX + menuWidth, menuPosY + menuHeight, tocolor(255, 255, 255), 1, Roboto, "center", "center")
	end

	-- ** Gombok
	if myShipCrabWeight > 0 then
		local buttonPosX = menuPosX + menuWidth / 2 - respc(120) / 2
		local buttonAlpha = 100

		if cursorX >= buttonPosX and cursorX <= buttonPosX + respc(120) then
			if cursorY >= menuPosY + menuHeight - respc(42) and cursorY <= menuPosY + menuHeight - respc(10) then
				buttonAlpha = 200
				activeButton = "sellcrab"
			end
		end

		dxDrawRectangle(buttonPosX, menuPosY + menuHeight - respc(42), respc(120), respc(32), tocolor(61, 122, 188, buttonAlpha))
		dxDrawText("Eladás", buttonPosX, menuPosY + menuHeight - respc(42), buttonPosX + respc(120), menuPosY + menuHeight - respc(10), tocolor(0, 0, 0), 1, Roboto, "center", "center")
	else
		if myShipCagesCount > 0 then
			local buttonAlpha = 100

			if cursorX >= menuPosX + respc(40) and cursorX <= menuPosX + respc(40) + respc(32) then
				if cursorY >= menuPosY + menuHeight - respc(42) and cursorY <= menuPosY + menuHeight - respc(10) then
					buttonAlpha = 200
					activeButton = "minus"
				end
			end

			dxDrawRectangle(menuPosX + respc(40), menuPosY + menuHeight - respc(42), respc(32), respc(32), tocolor(61, 122, 188, buttonAlpha))
			dxDrawText("-", menuPosX + respc(40), menuPosY + menuHeight - respc(42), menuPosX + respc(40) + respc(32), menuPosY + menuHeight - respc(10), tocolor(0, 0, 0), 1, Roboto, "center", "center")
		end

		local shipModel = getElementModel(currentVehicle)
		local maximumSlot = 18

		if shipModel == 454 then
			maximumSlot = 84
		end

		if myShipCagesCount < maximumSlot then
			local buttonAlpha = 100

			if cursorX >= menuPosX + menuWidth - respc(72) and cursorX <= menuPosX + menuWidth - respc(72) + respc(32) then
				if cursorY >= menuPosY + menuHeight - respc(42) and cursorY <= menuPosY + menuHeight - respc(10) then
					buttonAlpha = 200
					activeButton = "plus"
				end
			end

			dxDrawRectangle(menuPosX + menuWidth - respc(72), menuPosY + menuHeight - respc(42), respc(32), respc(32), tocolor(61, 122, 188, buttonAlpha))
			dxDrawText("+", menuPosX + menuWidth - respc(72), menuPosY + menuHeight - respc(42), menuPosX + menuWidth - respc(72) + respc(32), menuPosY + menuHeight - respc(10), tocolor(0, 0, 0), 1, Roboto, "center", "center")
		end
	end
end

function processCrabCrates(vehicle, numOfCage)
	local shipModel = getElementModel(vehicle)

	if not crabCratesOnShip[vehicle] then
		crabCratesOnShip[vehicle] = {}
	end

	if not crabObjectsOnShip[vehicle] then
		crabObjectsOnShip[vehicle] = {}
	end

	if not baitObjects[vehicle] then
		baitObjects[vehicle] = {}
	end

	local currentBaits = shipDatas[vehicle].currentBait or {}

	if currentBaits then
		for cageIndex in pairs(baitObjects[vehicle]) do
			if not currentBaits[cageIndex] or currentBaits[cageIndex] <= 0 then
				for k, v in pairs(baitObjects[vehicle][cageIndex]) do
					if isElement(v) then
						destroyElement(v)
					end
				end

				baitObjects[vehicle][cageIndex] = nil
			end
		end

		for cageIndex, baitCount in pairs(currentBaits) do
			if not baitObjects[vehicle][cageIndex] then
				baitObjects[vehicle][cageIndex] = {}
			end

			if baitCount - #baitObjects[vehicle][cageIndex] > 0 then
				local cageX, cageY, cageZ = countPoses(cageIndex, shipModel)

				for baitIndex = 1, math.abs(baitCount - #baitObjects[vehicle][cageIndex]) do
					local objectElement = createObject(replacementModels.bait, 0, 0, 0)

					if isElement(objectElement) then
						local baitCount = #baitObjects[vehicle][cageIndex] + 1

						setElementCollisionsEnabled(objectElement, false)
						attachElements(objectElement, vehicle, cageX - 0.32 + (baitCount - 1) * 0.15, cageY, cageZ - 0.09, 0, 0, 90 + math.random(10) - 5)

						table.insert(baitObjects[vehicle][cageIndex], objectElement)
					end
				end
			end
		end
	end

	local shipWeight = shipWeights[vehicle] or 0
	local crabWeights = shipDatas[vehicle].crabWeights or {}
	local totalWeight = 0

	for k in pairs(crabWeights) do
		local thisWeight = tonumber(crabWeights[k]) or 0

		if thisWeight > 0 then
			totalWeight = totalWeight + thisWeight
		end
	end

	if vehicle == getPedOccupiedVehicle(localPlayer) then
		myShipCrabWeight = totalWeight
		myShipCagesCount = numOfCage
	end

	if shipWeight > 0 and totalWeight <= 0 then
		for cageIndex = 1, #crabCratesOnShip[vehicle] do
			local cageContent = crabObjectsOnShip[vehicle][cageIndex]

			if cageContent then
				for crabIndex = 1, #cageContent do
					if isElement(cageContent[crabIndex]) then
						destroyElement(cageContent[crabIndex])
					end
				end
			end
		end
	end

	shipWeights[vehicle] = totalWeight

	local cratesList = crabCratesOnShip[vehicle]
	local cratesCount = #cratesList

	if cratesCount ~= numOfCage then
		if numOfCage - cratesCount < 0 then
			for cageIndex = 1, math.abs(numOfCage - cratesCount) do
				if isElement(cratesList[cratesCount]) then
					destroyElement(cratesList[cratesCount])
				end

				cratesList[cratesCount] = nil
				cratesCount = #cratesList

				local crabsList = crabObjectsOnShip[vehicle][cratesCount]

				if crabsList then
					for crabIndex = 1, #crabsList do
						if isElement(crabsList[crabIndex]) then
							destroyElement(crabsList[crabIndex])
						end
					end
				end

				crabObjectsOnShip[vehicle][cratesCount] = nil
			end
		elseif numOfCage - cratesCount > 0 then
			for i = 1, math.abs(numOfCage - cratesCount) do
				local cageIndex = cratesCount + 1
				local cageX, cageY, cageZ = countPoses(cageIndex, shipModel)

				cratesList[cageIndex] = createObject(replacementModels.cage, 0, 0, 0)

				if isElement(cratesList[cageIndex]) then
					attachElements(cratesList[cageIndex], vehicle, cageX, cageY, cageZ, 0, 0, 90)
				end

				if crabWeights[cageIndex] then
					if crabWeights[cageIndex] > 0 then
						local numOfCrabs = math.floor(crabWeights[cageIndex] / 25) + 1

						if numOfCrabs > 4 then
							numOfCrabs = 4
						end

						if not crabObjectsOnShip[vehicle][cageIndex] then
							crabObjectsOnShip[vehicle][cageIndex] = {}
						end

						for crabIndex = 1, numOfCrabs do
							local objectElement = createObject(replacementModels.crab, 0, 0, 0)

							if isElement(objectElement) then
								setElementCollisionsEnabled(objectElement, false)

								setObjectScale(objectElement, 0.9)
								attachElements(objectElement, vehicle, cageX, cageY, cageZ + (crabIndex - 1) * 0.08, 0, 0, 90 + math.random(10) - 5)

								crabObjectsOnShip[vehicle][cageIndex][crabIndex] = objectElement
							end
						end
					end
				end

				cratesCount = #cratesList
			end

			local velX, velY, velZ = getElementVelocity(vehicle)
			setElementVelocity(vehicle, velX, velY, velZ + 0.01)

			if isElementFrozen(vehicle) then
				setElementFrozen(vehicle, false)
				setTimer(setElementFrozen, 100, 1, vehicle, true)
			end
		end
	end
end

function countPoses(cageIndex, shipModel)
	if shipModel == 454 then
		local x = 0
		local y = -15.35
		local z = 1.6
		local remainder = (cageIndex - 1) % 8

		if remainder == 0 then
			x = -1.2
		elseif remainder == 2 then
			x = 1.2
		end

		if remainder > 2 then
			y = y + 1.25
			z = 1.4

			if remainder == 3 then
				x = -2.4
			elseif remainder == 4 then
				x = -1.2
			elseif remainder == 6 then
				x = 1.2
			elseif remainder == 7 then
				x = 2.4
			end
		end

		if cageIndex > 8 then
			z = z + 0.525
		end

		if cageIndex > 16 then
			z = z + 0.525
		end

		if cageIndex > 24 then
			cageIndex = cageIndex - 24
			x, y, z = 0, -13.1, 1.25

			local multiplier = 1

			if cageIndex > 40 then
				cageIndex = cageIndex - 40
				y = y + 1.85
				z = z - 0.3
				multiplier = 1.15
			elseif cageIndex > 20 then
				cageIndex = cageIndex - 20
				y = y + 0.925
				z = z - 0.2
				multiplier = 1.05
			end

			local remainder = cageIndex % 5

			if remainder == 1 then
				x = -2.6 * multiplier
			elseif remainder == 2 then
				x = -1.3 * multiplier
			elseif remainder == 4 then
				x = 1.3 * multiplier
			elseif remainder == 0 then
				x = 2.6 * multiplier
			end

			if cageIndex > 5 and cageIndex <= 20 then
				z = z + 0.525 * math.floor((cageIndex - 1) / 5)
			end
		end

		return x, y, z
	else
		local level = math.ceil(cageIndex / 2) - 1
		local x = -0.6
		local y = -3.5
		local z = 0.45

		if cageIndex % 2 == 0 then
			x = math.abs(x)
		end

		if level >= 6 then
			y = y + (level - 6) * 0.9
			z = z + 1.05
		elseif level >= 3 then
			y = y + (level - 3) * 0.9
			z = z + 0.525
		else
			y = y + level * 0.9
		end

		return x, y, z
	end
end

function createShipInterior(shipId)
	local objectPositions = {
		{9494, -749.90002, 390.79999, 10000, 0, 0, 0},
		{3095, -746.5, 391, 10001.3, 0, 0, 0},
		{3095, -746.5, 394.5, 10001.3, 270, 0, 0},
		{3095, -746.5, 386.60001, 10001.3, 270, 0, 0},
		{2421, -748.20001, 394.39999, 10000, 0, 0, 0},
		{16662, -743, 391.10001, 9997.9502, 296.751, 269.504, 358.945, 0.30000001},
		{2206, -744.90002, 389.89999, 9998.2998, 0, 0, 90},
		{2190, -745.19, 390.25601, 9999.2002, 0, 0, 92},
		{16782, -744.79999, 390.10001, 9999.5996, 0, 354.25, 26, 0.12},
		{1778, -744.09998, 394.20001, 9998.4004, 0, 0, 44},
		{1667, -744.90002, 391.39999, 9999.3203, 0, 0, 0},
		{2027, -748.90002, 393.60001, 9999, 0, 0, 2.25},
		{2854, -744.90002, 390.89999, 9999.2305, 0, 0, 100},
		{2596, -748.23999, 387.285, 10000.40039, 0, 0, 210.25},
		{1544, -745, 391.5, 9999.2002, 0, 0, 0},
		{1764, -752.5, 387.89999, 9998.2998, 0, 0, 90},
		{16101, -748.29999, 387.29999, 9989.5, 0, 0, 0},
		{2147, -751.59998, 393.89999, 9998.4004, 0, 0, 16},
		{2847, -743.5, 390, 9998.4199, 0, 0, 90, 2},
		{2328, -754.59998, 389.5, 9998.4004, 0, 0, 270},
		{2558, -752.40002, 389.79999, 9998.5996, 0, 0, 90, 2},
		{2670, -748.70001, 392.89999, 9998.5, 0, 0, 0},
		{2993, -747.5, 394.39999, 10000.7, 90, 0, 270},
		{2673, -752.5, 392.89999, 9998.5, 0, 0, 50},
		{2671, -750, 393.64999, 9998.4551, 0, 0, 0, 0.5},
		{2843, -755.29999, 391.89999, 9998.4004, 0, 0, 0},
		{2993, -746.90002, 387.5, 9998.4502, 355, 350, 150},
		{1771, -755, 388.39999, 9998.7002, 0, 0, 90},
		{1771, -755, 388.39999, 9999.7998, 0, 0, 90},
		{1428, -755.90002, 389.10001, 9998.4004, 5.25, 0, 180.75},
		{2993, -746.5, 387.60001, 9998.4502, 354.996, 349.997, 111.996},
		{1771, -755, 393.39999, 9998.7002, 0, 0, 90},
		{1771, -755, 393.39999, 9999.7998, 0, 0, 90},
		{1428, -754.09998, 392.70001, 9998.4004, 5.246, 0, 0.997},
		{2844, -755, 389, 9998.4004, 0, 0, 0},
		{2328, -754.70001, 392.10001, 9998.4004, 0, 0, 270},
		{2238, -753.5, 389.29999, 9999.3496, 0, 0, 0, 0.5},
		{1369, -743.79999, 388.10001, 9999, 0, 0, 235.5},
		{2268, -750.09998, 393.89999, 10000.2, 0, 0, 0},
		{2518, -749.09998, 387.70001, 9998.5, 0, 0, 180},
		{1714, -743.59998, 391.20001, 9998.4004, 0, 0, 300},
		{2286, -752.90002, 388.89999, 10000.3, 0, 0, 90},
		{2277, -749.5, 393.89999, 10000, 0, 0, 0},
		{2281, -749.29999, 387.5, 10000.4, 0, 0, 180, 0.5},
		{2278, -750.09998, 387.70001, 10000.2, 0, 0, 180},
		{2851, -748.90002, 393.20001, 9999.2002, 0, 0, 0},
		{3044, -745.09998, 391.79999, 9999.2402, 320, 0, 0},
		{1510, -745, 391.70001, 9999.25, 0, 0, 0}
	}

	for i = 1, #objectPositions do
		local objectData = objectPositions[i]
		local objectElement = createObject(objectData[1], objectData[2], objectData[3], objectData[4])

		if isElement(objectElement) then
			setElementRotation(objectElement, objectData[5] or 0, objectData[6] or 0, objectData[7] or 0)
			setElementDoubleSided(objectElement, true)
			setElementInterior(objectElement, 123)
			setElementDimension(objectElement, shipId)
			setObjectScale(objectElement, objectData[8] or 1)
			table.insert(shipInteriorObjects, objectElement)
		end
	end

	engineSetAsynchronousLoading(true, true)

	local coronaPositions = {
		{-748.017578125, 390.8, 10000.721875, 0.25, 252, 245, 194, 155},
		{-754.9, 390.8, 10000.721875, 0.25, 252, 245, 194, 155}
	}

	for i = 1, #coronaPositions do
		local coronaData = coronaPositions[i]
		local coronaElement = exports.custom_coronas:createCorona(unpack(coronaData))

		if isElement(coronaElement) then
			setElementInterior(coronaElement, 123)
			setElementDimension(coronaElement, shipId)
			table.insert(shipInteriorCoronas, coronaElement)
		end
	end

	if getElementData(localPlayer, "inTugBoat") then
		setTimer(setElementFrozen, 1500, 1, localPlayer, false)
	end
end

function destroyShipInterior()
	for i = 1, #shipInteriorObjects do
		if isElement(shipInteriorObjects[i]) then
			destroyElement(shipInteriorObjects[i])
		end
	end

	for i = 1, #shipInteriorCoronas do
		if shipInteriorCoronas[i] then
			exports.custom_coronas:destroyCorona(shipInteriorCoronas[i])
		end
	end

	shipInteriorObjects = {}
	shipInteriorCoronas = {}
end

function enterTheShip(shipId, doorId)
	if tonumber(shipId) then
		if shipId == 0 then
			local spawnX, spawnY, spawnZ = 1049.07421875, 1027.5341796875, 11
			local shipElement = getElementData(localPlayer, "inTugBoat")

			if isElement(shipElement) then
				if isVehicleLocked(shipElement) then
					outputChatBox("#d75959[StrongMTA]: #ffffffBe van zárva a hajó.", 255, 255, 255, true)
					return
				end

				if doorId == 1 then
					spawnX, spawnY, spawnZ = getPositionFromElementOffset(shipElement, 3.5, -2.75, 1.25)
				else
					spawnX, spawnY, spawnZ = getPositionFromElementOffset(shipElement, -3.5, -2.75, 1.25)
				end
			end

			setElementData(localPlayer, "inTugBoat", false)
			destroyShipInterior()
			setElementPosition(localPlayer, spawnX, spawnY, spawnZ)
		else
			destroyShipInterior()
			createShipInterior(shipId)

			if doorId == 1 then
				setElementPosition(localPlayer, -746.1103515625, 393.744140625, 9999.421875)
			else
				setElementPosition(localPlayer, -746.1103515625, 387.744140625, 9999.421875)
			end
		end

		triggerServerEvent("syncShipDims", localPlayer, shipId)
	end
end

addCommandHandler("enter",
	function ()
		if getElementInterior(localPlayer) == 123 then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)

			if getDistanceBetweenPoints3D(playerX, playerY, playerZ, -746.1103515625, 393.744140625, 9999.421875) <= 0.65 then
				enterTheShip(0, 1)
			end

			if getDistanceBetweenPoints3D(playerX, playerY, playerZ, -746.1103515625, 387.744140625, 9999.421875) <= 0.65 then
				enterTheShip(0, 2)
			end
		else
			local contactElement = getPedContactElement(localPlayer)

			if contactElement then
				if getElementModel(contactElement) == 454 then
					if not isPedInVehicle(localPlayer) then
						local playerX, playerY, playerZ = getElementPosition(localPlayer)

						if isVehicleLocked(contactElement) then
							outputChatBox("#d75959[StrongMTA]: #ffffffBe van zárva a hajó.", 255, 255, 255, true)
							return
						end

						local leftX, leftY, leftZ = getPositionFromElementOffset(contactElement, -3.5, -2.75, 1.25)
						local rightX, rightY, rightZ = getPositionFromElementOffset(contactElement, 3.5, -2.75, 1.25)

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, rightX, rightY, rightZ) <= 0.65 then
							enterTheShip(getElementData(contactElement, "vehicle.dbID"), 1)
							setElementData(localPlayer, "inTugBoat", contactElement)
							return
						end

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, leftX, leftY, leftZ) <= 0.65 then
							enterTheShip(getElementData(contactElement, "vehicle.dbID"), 2)
							setElementData(localPlayer, "inTugBoat", contactElement)
							return
						end
					end
				end
			end
		end
	end
)
