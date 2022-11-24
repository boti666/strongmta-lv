local screenX, screenY = guiGetScreenSize()

local activeSyncedStation = false
local activeStation = false
local activePump = false
local enteredToInterior = false

local fuelTankSize = {}
local vehFuelLeft = {}
local vehFuelStart = {}
local vehAddFuel = {}

local availableFonts = {
	Roboto = false,
	ThermalPrinter = false,
	Lunabar = false,
	Counter = false
}

local priceTable = {
	renderTarget = false,
	shaderElement = false
}

local counterSizeXY = 200
local circleTexture = false

local requestPistolTick = 0
local pistolTaken = false
local pistolInHand = false
local pistolLastData = false
local pistolHitNum = 0
local pickupAnim = false

local activeVehicle = false
local selectedVehicle = false

local fillTimer = false
local counterSpeed = 1
local lastPressTick = 0
local canisterInHand = false
local fuelingProcess = {}

local receiptWidth = 300
local receiptHeight = 423
local receiptPosX = screenX / 2 - receiptWidth / 2
local receiptPosY = screenY / 2 - receiptHeight / 2
local signStart = false
local showReciept = false
local playerName = false

local buttons = {}
local activeButton = false

local lastX, lastY = 0, 0

addCommandHandler("rect1",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			lastX, lastY = getElementPosition(localPlayer)
		end
	end)

addCommandHandler("rect2",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local pointX, pointY = getElementPosition(localPlayer)
			local minX = math.min(lastX, pointX)
			local minY = math.min(lastY, pointY)
			local maxX = math.max(lastX, pointX)
			local maxY = math.max(lastY, pointY)

			outputChatBox(minX .. ", " .. minY .. ", " .. maxX - minX .. ", " .. maxY - minY)
		end
	end)

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedres)
		if getResourceName(startedres) == "see_vehiclepanel" then
			fuelTankSize = exports.see_vehiclepanel:getTheFuelTankTable()
		elseif source == getResourceRootElement() then
			local see_vehiclepanel = getResourceFromName("see_vehiclepanel")

			if see_vehiclepanel and getResourceState(see_vehiclepanel) == "running" then
				fuelTankSize = exports.see_vehiclepanel:getTheFuelTankTable()
			end

			for k, v in ipairs(availableStations) do
				v.pedDetails.element = createPed(v.pedDetails.skin, v.pedDetails.position[1], v.pedDetails.position[2], v.pedDetails.position[3], v.pedDetails.rotation)

				if isElement(v.pedDetails.element) then
					setElementFrozen(v.pedDetails.element, true)
					setElementInterior(v.pedDetails.element, v.pedDetails.interior)
					setElementDimension(v.pedDetails.element, v.pedDetails.dimension)

					setElementData(v.pedDetails.element, "stationId", k, false)
					setElementData(v.pedDetails.element, "visibleName", v.pedDetails.name, false)
					setElementData(v.pedDetails.element, "pedNameType", "Benzinkút", false)
					setElementData(v.pedDetails.element, "invulnerable", true, false)
				end

				if k == 6 then
					v.outerColShape.element = createColPolygon(unpack(v.outerColShape.details))
					v.innerColShape.element = createColPolygon(unpack(v.innerColShape.details))
				elseif k == 7 or k == 8 then
					v.outerColShape.element = createColPolygon(unpack(v.outerColShape.details))
					v.innerColShape.element = createColRectangle(unpack(v.innerColShape.details))
				else
					v.outerColShape.element = createColRectangle(unpack(v.outerColShape.details))
					v.innerColShape.element = createColRectangle(unpack(v.innerColShape.details))
				end

				if isElement(v.outerColShape.element) then
					setElementData(v.outerColShape.element, "outerStationId", k, false)
				end

				if isElement(v.innerColShape.element) then
					setElementData(v.innerColShape.element, "innerStationId", k, false)
				end

				for k2, v2 in ipairs(v.fuelPositions) do
					v2.pistolObject = createObject(unpack(v2.pistolDetails))
					v2.pistolColShape = createColSphere(unpack(v2.colShapePoses))

					if isElement(v2.pistolColShape) then
						setElementData(v2.pistolColShape, "stationId", k, false)
						setElementData(v2.pistolColShape, "positionId", k2, false)
					end

					v2.currentAmount = 0
					v2.currentFuelAmount = 0
				end
			end

			circleTexture = dxCreateTexture("files/images/circle.png")
			canisterInHand = getElementData(localPlayer, "canisterInHand")

			if getElementData(localPlayer, "loggedIn") then
				initFuelSystem()
			end

			setElementData(localPlayer, "fuelStation", false)
			setElementData(localPlayer, "pistolHolder", false)
		end
	end)

function initFuelSystem()
	for k, v in ipairs(availableStations) do
		v.fuelPrice = getElementData(resourceRoot, "fuelPrices")[k]

		for k2, v2 in ipairs(v.fuelPositions) do
			if k and k2 then
				v2.currentAmount = getElementData(resourceRoot, "fuelStation_" .. k .. "_" .. k2) or 0

				if v2.currentAmount == 0 then
					if isElement(v2.effectElement) then
						destroyElement(v2.effectElement)
						v2.effectElement = nil
					end

					if isElement(v2.soundElement) then
						destroyElement(v2.soundElement)
						v2.soundElement = nil
					end
				end
			end
		end
	end

	for k, v in ipairs(getElementsByType("player")) do
		local pistolHolder = getElementData(v, "pistolHolder")

		if pistolHolder then
			local stationId = pistolHolder[1]
			local positionId = pistolHolder[2]

			if availableStations[stationId] then
				local fuelPos = availableStations[stationId].fuelPositions[positionId]

				if fuelPos then
					fuelPos.pistolHolder = v

					if fuelPos.pistolObject then
						exports.see_boneattach:attachElementToBone(fuelPos.pistolObject, v, 12, 0.05, 0.05, 0.05, 180, 0, 0)

						if v == localPlayer then
							exports.see_controls:toggleControl({"fire", "enter_exit", "enter_passenger", "aim_weapon"}, false)
							pistolInHand = pistolHolder
							pistolTaken = false
							pistolHitNum = 0
						end
					end
				end
			end
		end
	end

	local playerX, playerY, playerZ = getElementPosition(localPlayer)

	for k, v in pairs(getElementsByType("colshape", resourceRoot, true)) do
		if isInsideColShape(v, playerX, playerY, playerZ) and getElementData(v, "syncStationId") then
			triggerEvent("onClientColShapeHit", v, localPlayer)
			break
		end
	end
end

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if source == getResourceRootElement() then
			if dataName == "fuelPrices" then
				local fuelPrices = getElementData(source, "fuelPrices") or {}

				for k, v in pairs(fuelPrices) do
					availableStations[k].fuelPrice = v
				end

				generatePriceTable()
			elseif string.find(dataName, "fuelStation_") then
				local selected = split(dataName:gsub("fuelStation_", ""), "_")
				local stationId = tonumber(selected[1])
				local pumpId = tonumber(selected[2])

				if availableStations[stationId] then
					local fuelPos = availableStations[stationId].fuelPositions[pumpId]

					if fuelPos then
						fuelPos.currentAmount = getElementData(source, dataName) or 0

						if fuelPos.currentAmount == 0 then
							if isElement(fuelPos.effectElement) then
								destroyElement(fuelPos.effectElement)
								fuelPos.effectElement = nil
							end

							if isElement(fuelPos.soundElement) then
								destroyElement(fuelPos.soundElement)
								fuelPos.soundElement = nil
							end
						end
					end
				end
			end
		elseif dataName == "pistolHolder" then
			local pistolHolder = getElementData(source, "pistolHolder")

			if pistolHolder then
				local stationId = pistolHolder[1]
				local positionId = pistolHolder[2]

				if availableStations[stationId] then
					local fuelPos = availableStations[stationId].fuelPositions[positionId]

					if fuelPos then
						fuelPos.pistolHolder = source

						if fuelPos.pistolObject then
							exports.see_boneattach:attachElementToBone(fuelPos.pistolObject, source, 12, 0.05, 0.05, 0.05, 180, 0, 0)

							if source == localPlayer then
								exports.see_controls:toggleControl({"fire", "enter_exit", "enter_passenger", "aim_weapon"}, false)
								pistolInHand = pistolHolder
								pistolTaken = false
								pistolHitNum = 0
							end
						end
					end
				end
			elseif oldValue then
				local stationId = oldValue[1]
				local positionId = oldValue[2]

				if availableStations[stationId] then
					local fuelPos = availableStations[stationId].fuelPositions[positionId]

					if fuelPos then
						fuelPos.pistolHolder = {}

						if isElement(fuelPos.effectElement) then
							destroyElement(fuelPos.effectElement)
						end

						if isElement(fuelPos.soundElement) then
							destroyElement(fuelPos.soundElement)
						end

						fuelPos.effectElement = nil
						fuelPos.soundElement = nil

						if fuelPos.pistolObject then
							exports.see_boneattach:detachElementFromBone(fuelPos.pistolObject)

							setElementPosition(fuelPos.pistolObject, fuelPos.pistolDetails[2], fuelPos.pistolDetails[3], fuelPos.pistolDetails[4])
							setElementRotation(fuelPos.pistolObject, fuelPos.pistolDetails[5], fuelPos.pistolDetails[6], fuelPos.pistolDetails[7])

							if source == localPlayer then
								exports.see_controls:toggleControl({"fire", "enter_exit", "enter_passenger", "aim_weapon"}, true)
								pistolLastData = pistolInHand
								pistolInHand = false
							end
						end
					end
				end
			end

			if pistolHolder or oldValue then
				playSound3D("files/sounds/fuelpickupesoff.mp3", getElementPosition(source))
			end
		elseif dataName == "canisterInHand" then
			if source == localPlayer then
				canisterInHand = getElementData(source, "canisterInHand")
			end
		elseif dataName == "loggedIn" then
			if source == localPlayer then
				initFuelSystem()
			end
		end
	end)

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (sourceElement)
		if sourceElement == localPlayer then
			local syncStationId = getElementData(source, "syncStationId")

			if syncStationId then
				activeSyncedStation = syncStationId

				for k, v in ipairs(availableStations[syncStationId].fuelPositions) do
					v.renderTargetUpdated = false

					if not v.renderTarget then
						v.renderTarget = dxCreateRenderTarget(counterSizeXY, counterSizeXY, true)
					end
				end

				for k, v in pairs(availableFonts) do
					if isElement(availableFonts[k]) then
						destroyElement(availableFonts[k])
					end

					availableFonts[k] = nil
				end

				availableFonts.Roboto = dxCreateFont("files/fonts/Roboto.ttf", 13, false, "antialiased")
				availableFonts.Counter = dxCreateFont("files/fonts/counter.ttf", 25 * (counterSizeXY / 400), false, "antialiased")

				if isElement(priceTable.renderTarget) then
					destroyElement(priceTable.renderTarget)
				end

				if isElement(priceTable.shaderElement) then
					destroyElement(priceTable.shaderElement)
				end

				priceTable.renderTarget = dxCreateRenderTarget(256, 256, true)
				priceTable.shaderElement = dxCreateShader("files/shaders/texturechanger.fx")

				if priceTable.shaderElement and generatePriceTable() then
					dxSetShaderValue(priceTable.shaderElement, "gTexture", priceTable.renderTarget)
					engineApplyShaderToWorldTexture(priceTable.shaderElement, "ws_xenon_3")
				end
			end

			local outerStationId = getElementData(source, "outerStationId")

			if outerStationId then
				activeStation = outerStationId
			end

			local stationId = getElementData(source, "stationId")
			local positionId = getElementData(source, "positionId")

			if not activePump and stationId and positionId then
				activePump = {stationId, positionId}
			end
		end
	end)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (sourceElement)
		if sourceElement == localPlayer then
			local syncStationId = getElementData(source, "syncStationId")

			if syncStationId and activeSyncedStation then
				activeSyncedStation = false

				for k, v in ipairs(availableStations[syncStationId].fuelPositions) do
					if isElement(v.renderTarget) then
						destroyElement(v.renderTarget)
					end

					v.fillingStarted = nil
					v.renderTarget = nil
				end

				for k, v in pairs(availableFonts) do
					if isElement(availableFonts[k]) then
						destroyElement(availableFonts[k])
					end

					availableFonts[k] = nil
				end

				for k, v in pairs(priceTable) do
					if isElement(priceTable[k]) then
						destroyElement(priceTable[k])
					end
					
					priceTable[k] = nil
				end
			end

			if getElementData(source, "outerStationId") then
				setTimer(
					function()
						local dimension = getElementDimension(localPlayer)
						local interior = getElementInterior(localPlayer)

						if dimension >= 1 and dimension <= 8 and interior == 16 then
							enteredToInterior = true
							return
						end

						local fuelStation = getElementData(localPlayer, "fuelStation")

						activeStation = false

						if fuelStation then
							setElementData(resourceRoot, "fuelStation_" .. fuelStation[1] .. "_" .. fuelStation[2], 0)
							setElementData(localPlayer, "fuelStation", false)
							setElementData(localPlayer, "pistolHolder", false)
						end
					end,
				1000, 1)
			end

			activePump = false
		end
	end)

addEventHandler("onClientElementStreamIn", localPlayer,
	function ()
		if activeStation and not enteredToInterior then
			local dimension = getElementDimension(localPlayer)
			local interior = getElementInterior(localPlayer)

			if dimension >= 1 and dimension <= 8 and interior == 16 then
				return
			end

			local fuelStation = getElementData(localPlayer, "fuelStation")
			
			if fuelStation then
				setElementData(resourceRoot, "fuelStation_" .. fuelStation[1] .. "_" .. fuelStation[2], 0)
				setElementData(localPlayer, "fuelStation", false)
				setElementData(localPlayer, "pistolHolder", false)
			end
		end
	end)

addEventHandler("onClientPlayerWasted", localPlayer,
	function()
		if source == localPlayer then
			if pickupAnim or selectedVehicle then
				setElementFrozen(localPlayer, false)
				exports.see_controls:toggleControl({"all"}, true)
			end

			if pistolInHand then
				triggerServerEvent("resetPumpPistol", localPlayer)
				triggerServerEvent("doFuelingProcess", localPlayer, false, pistolInHand[1], pistolInHand[2], selectedVehicle, false, true)
			end

			enteredToInterior = false
			selectedVehicle = false
			pistolTaken = false
			pickupAnim = false

			if isTimer(fillTimer) then
				killTimer(fillTimer)
			end

			fillTimer = nil
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if activeStation then
			if activePump and key == "e" and press then
				local pistolHolder = getElementData(localPlayer, "pistolHolder")

				if pistolHolder then
					local stationId = pistolHolder[1]
					local positionId = pistolHolder[2]

					if stationId ~= activePump[1] or positionId ~= activePump[2] then
						exports.see_hud:showInfobox("e", "Ezt a kutat jelenleg nem használhatod!")
						return
					end

					if availableStations[stationId].fuelPositions[positionId].fillingStarted then
						return
					end
				end

				if getTickCount() - lastPressTick >= 1000 then
					triggerServerEvent("requestPumpPistol", localPlayer, activePump[1], activePump[2])
					lastPressTick = getTickCount()
				end
			end

			if key == "mouse1" and pistolInHand and not activePump then
				if not press or getTickCount() - lastPressTick >= 1000 then
					if not press and not pistolInHand then
						return
					end

					cancelEvent()

					if press and activeVehicle then
						if getElementData(activeVehicle, "vehicle.engine") == 1 then
							exports.see_hud:showInfobox("e", "A jármű motorja jár!")
							return
						end

						vehFuelLeft[activeVehicle] = getElementData(activeVehicle, "vehicle.fuel") or 0

						if not vehAddFuel[activeVehicle] then
							vehAddFuel[activeVehicle] = 0
						end

						if vehFuelLeft[activeVehicle] + vehAddFuel[activeVehicle] >= (fuelTankSize[getElementModel(activeVehicle)] or 50) then
							exports.see_hud:showInfobox("e", "A jármű tankja tele van!")
							return
						end
					end

					if press then
						if activeVehicle then
							triggerServerEvent("startFuelingProcess", localPlayer, activeStation)

							fillTimer = setTimer(
								function()
									triggerServerEvent("doFuelingProcess", localPlayer, activeStation, pistolInHand[1], pistolInHand[2], activeVehicle)
								end,
							2400, 1)
						else
							triggerServerEvent("doFuelingProcess", localPlayer, press, pistolInHand[1], pistolInHand[2], activeVehicle)
						end
					else
						if isTimer(fillTimer) then
							killTimer(fillTimer)
						end

						triggerServerEvent("doFuelingProcess", localPlayer, press, pistolInHand[1], pistolInHand[2], selectedVehicle)
					end

					lastPressTick = getTickCount()
				else
					cancelEvent()
					exports.see_hud:showInfobox("e", "Ilyen gyorsan nem kéne nyomkodni!")
				end
			end
		end

		if key == "mouse1" and not pistolInHand and canisterInHand then
			cancelEvent()

			if press and not isPedInVehicle(localPlayer) then
				local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
				local playerRotX, playerRotY, playerRotZ = getElementRotation(localPlayer)
				local vehiclesTable = getElementsByType("vehicle", getRootElement(), true)

				for k, v in ipairs(vehiclesTable) do
					local fillX, fillY, fillZ = getElementPosition(v)
					local vehRotX, vehRotY, vehRotZ = getElementRotation(v)
					local vehicleModel = getElementModel(v)
					local fuelSide = fuelSides[vehicleModel] or "bh"

					if centerFilling[vehicleModel] then
					elseif fuelSide then
						if fuelSide == "hk" then
							fillX, fillY, fillZ = getPositionFromElementOffset(getElementMatrix(v), 0, -getElementRadius(v), 0)
						else
							fillX, fillY, fillZ = getVehicleComponentPosition(v, wheelSide[fuelSide], "world")
							fillX, fillY = rotateAround(vehRotZ, 0.5, 0, fillX, fillY)
						end
					end

					if fillX and fillY and fillZ then
						local velX, velY, velZ = getElementVelocity(v)
						local actualspeed = math.floor(math.sqrt(velX*velX + velY*velY + velZ*velZ) * 187.5)

						if actualspeed < 2 and math.abs(fillZ - playerPosZ) <= 2.5 then
							local dist = getDistanceBetweenPoints2D(playerPosX, playerPosY, fillX, fillY)

							if dist <= 5 then
								local angle = playerRotZ - vehRotZ

								if angle < 0 then
									angle = angle + 360
								elseif angle > 360 then
									angle = angle - 360
								end

								local nearestVehicle = false

								if dist <= 0.75 then
									if fuelSide == "hk" then
										if angle <= 45 or angle >= 315 then
											nearestVehicle = v
										end
									elseif angle >= 45 and angle <= 135 then
										nearestVehicle = v
									end
								end

								if nearestVehicle then
									if getElementData(nearestVehicle, "vehicle.engine") == 1 then
										exports.see_hud:showInfobox("e", "A jármű motorja jár!")
										return
									end

									triggerServerEvent("useCanister", localPlayer, nearestVehicle)
									canisterInHand = false
								end

								break
							end
						end
					end
				end
			end
		end
	end)

addEvent("startFuelingProcess", true)
addEventHandler("startFuelingProcess", getRootElement(),
	function ()
		if isElement(source) then
			if source == localPlayer then
				setElementFrozen(localPlayer, true)
				exports.see_controls:toggleControl({"all"}, false)

				fuelingProcess.startTime = getTickCount()
				fuelingProcess.endTime = fuelingProcess.startTime + 2400
				fuelingProcess.text = "Tankolás megkezdése..."

				pickupAnim = true
			end

			setPedAnimation(source, "CASINO", "cards_win")
			playSound3D("files/sounds/fuelstart.mp3", getElementPosition(source))
		end
	end)

addEvent("doFuelingProcess", true)
addEventHandler("doFuelingProcess", getRootElement(),
	function (startFill, stationId, positionId, vehicleElement, endFill)
		if isElement(source) and stationId and positionId then
			local playerPosX, playerPosY, playerPosZ = getElementPosition(source)

			if endFill then
				playSound3D("files/sounds/tankfull.mp3", playerPosX, playerPosY, playerPosZ)
			end

			local fuelPos = availableStations[stationId].fuelPositions[positionId]

			if fuelPos then
				if isElement(fuelPos.effectElement) then
					destroyElement(fuelPos.effectElement)
				end

				if isElement(fuelPos.soundElement) then
					destroyElement(fuelPos.soundElement)
				end

				fuelPos.effectElement = nil
				fuelPos.soundElement = nil

				if startFill then
					setPedAnimation(source, "SWORD", "sword_IDLE")

					if source == localPlayer then
						pickupAnim = false
					end

					if not vehicleElement then
						local pistolPosX, pistolPosY, pistolPosZ = getElementPosition(fuelPos.pistolObject)
						local pistolRotX, pistolRotY, pistolRotZ = getElementRotation(fuelPos.pistolObject)

						local angle = math.rad(pistolRotZ + 90)
						local rotatedX = -math.sin(angle) * 0.3
						local rotatedY = math.cos(angle) * 0.3

						fuelPos.effectElement = createEffect("petrolcan", pistolPosX + rotatedX, pistolPosY + rotatedY, pistolPosZ, 120, 0, -pistolRotZ - 90)

	        			setEffectDensity(fuelPos.effectElement, 2)
					end

					local pumpId = positionId

					if pumpId % 2 == 0 then
						pumpId = pumpId - 1
					end

					local pumpPosX, pumpPosY, pumpPosZ = getElementPosition(availableStations[stationId].fuelPositions[pumpId].element)

					fuelPos.soundElement = playSound3D("files/sounds/fuelfill.mp3", pumpPosX, pumpPosY, pumpPosZ, true)

					setSoundVolume(fuelPos.soundElement, 0.2)

					if source == localPlayer then
						selectedVehicle = vehicleElement
					end
				else
					if vehicleElement then
						setPedAnimation(source, "CASINO", "cards_win")
						playSound3D("files/sounds/fuelover.mp3", playerPosX, playerPosY, playerPosZ)

						setTimer(
							function(sourceElement)
								setPedAnimation(sourceElement)

								if sourceElement == localPlayer then
									pickupAnim = false
									selectedVehicle = false
									setElementFrozen(localPlayer, false)
									exports.see_controls:toggleControl({"all"}, true)
								end
							end,
						2400, 1, source)

						if source == localPlayer then
							fuelingProcess.startTime = getTickCount()
							fuelingProcess.endTime = fuelingProcess.startTime + 2400
							fuelingProcess.text = "Tankolás befejezése..."
						end
					else
						setPedAnimation(source)

						if source == localPlayer then
							pickupAnim = false
							setElementFrozen(localPlayer, false)
							exports.see_controls:toggleControl({"all"}, true)
						end
					end

					if isElement(fuelPos.effectElement) then
						destroyElement(fuelPos.effectElement)
					end

					if isElement(fuelPos.soundElement) then
						destroyElement(fuelPos.soundElement)
					end

					fuelPos.effectElement = nil
					fuelPos.soundElement = nil
				end

				fuelPos.fillingStarted = startFill

				if fuelPos.fillingStarted then
					fuelPos.fillingStarted = getTickCount()
					fuelPos.litersStarted = fuelPos.currentAmount

					for k, v in pairs(vehAddFuel) do
						vehFuelStart[k] = v
					end
				elseif source == localPlayer then
					setElementData(resourceRoot, "fuelStation_" .. stationId .. "_" .. positionId, fuelPos.currentAmount)
				end
			end
		end
	end)

addEvent("resetFuelStation", true)
addEventHandler("resetFuelStation", getRootElement(),
	function (stationId, positionId)
		if stationId and positionId then
			local fuelPos = availableStations[stationId].fuelPositions[positionId]

			if fuelPos then
				if isElement(fuelPos.effectElement) then
					destroyElement(fuelPos.effectElement)
				end

				if isElement(fuelPos.soundElement) then
					destroyElement(fuelPos.soundElement)
				end

				fuelPos.effectElement = nil
				fuelPos.soundElement = nil
				fuelPos.fillingStarted = nil
				fuelPos.litersStarted = nil
			end
		end
	end)

local activePedStationId = stationId

addEvent("ä>[€ÄŁ", true)
addEventHandler("ä>[€ÄŁ", getRootElement(),
	function (success)
		if source == localPlayer then
			if not success then
				exports.see_hud:showInfobox("e", "Nincs elég pénzed!")
			else
				for vehicleElement, tankedAmount in pairs(vehAddFuel) do
					if tonumber(tankedAmount) then
						local model = getElementModel(vehicleElement)
						local currentAmount = getElementData(vehicleElement, "vehicle.fuel") or 0

						currentAmount = currentAmount + tankedAmount

						if currentAmount >= (fuelTankSize[model] or 50) then
							currentAmount = fuelTankSize[model] or 50
						end

						setElementData(vehicleElement, "vehicle.fuel", math.floor(currentAmount * 10) / 10)
					end
				end

				enteredToInterior = false

				exports.see_hud:showInfobox("s", "Sikeres fizetés! A tankolt üzemanyag a kocsidba került.")
			end
		end

		vehAddFuel = {}
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
		if showReciept then
			if state == "down" then
				if activeButton then
					if activeButton == "exit" then
						showReciept = false
						showCursor(false)
						
						for k, v in pairs(availableFonts) do
							if isElement(availableFonts[k]) then
								destroyElement(availableFonts[k])
							end

							availableFonts[k] = nil
						end

						availableFonts = {}
					elseif activeButton == "ä>[€ÄŁ" then
						if not signStart then
							signStart = getTickCount()
							playSound("files/sounds/sign.mp3")
						end
					end
				end
			end
		elseif clickedElement then
			if isElement(clickedElement) then
				if getElementType(clickedElement) == "ped" then
					if not showReciept then
						local stationId = getElementData(clickedElement, "stationId")

						if stationId then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)

							if pistolLastData and getDistanceBetweenPoints3D(playerX, playerY, playerZ, worldX, worldY, worldZ) <= 2 then
								local stationId = pistolLastData[1]
								local positionId = pistolLastData[2]

								if availableStations[stationId].fuelPositions[positionId].currentAmount > 0 then
									availableFonts.Roboto = dxCreateFont("files/fonts/Roboto.ttf", 13, false, "antialiased")
									availableFonts.ThermalPrinter = dxCreateFont("files/fonts/ThermalPrinter.ttf", 18, false, "antialiased")
									availableFonts.Lunabar = dxCreateFont("files/fonts/lunabar.ttf", 38, false, "antialiased")

									playerName = getElementData(localPlayer, "visibleName"):gsub("_", " ")
									signStart = false
									activePedStationId = stationId
									showReciept = true

									showCursor(true)
									
									exports.see_hud:showInfobox("i", "A számla kifizetéséhez kattints az aláírásra!")
								end
							end
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if showReciept and activePedStationId then
			local stationId, positionId = pistolLastData[1], pistolLastData[2]
			local pump = availableStations[stationId].fuelPositions[positionId]
			local fuelPrice = availableStations[stationId].fuelPrice

			buttons = {}

			-- ** Háttér
			dxDrawImage(receiptPosX, receiptPosY, receiptWidth, receiptHeight, availableStations[activePedStationId].receiptPath)
			
			-- Bezárás
			if activeButton == "exit" then
				dxDrawText("X", receiptPosX, receiptPosY, receiptPosX + 24, receiptPosY + 24, tocolor(0, 0, 0), 1, availableFonts.Roboto, "center", "center")
			else
				dxDrawText("X", receiptPosX, receiptPosY, receiptPosX + 24, receiptPosY + 24, tocolor(0, 0, 0), 0.75, availableFonts.Roboto, "center", "center")
			end

			buttons["exit"] = {receiptPosX, receiptPosY, 24, 24}
			
			-- Adatok
			dxDrawText(math.ceil(pump.currentAmount * fuelPrice) .. " $", receiptPosX, receiptPosY + 135, receiptPosX + 280, receiptPosY + 147, tocolor(0, 0, 0), 0.5, availableFonts.ThermalPrinter, "right", "center")
			
			dxDrawText(pump.currentAmount .. " L " .. fuelPrice .. " $/L", receiptPosX + 30, receiptPosY + 147, receiptPosX + 280, receiptPosY + 159, tocolor(0, 0, 0), 0.45, availableFonts.ThermalPrinter, "left", "center")
			
			dxDrawText("00001\n" .. math.ceil(pump.currentAmount * fuelPrice) .. " $\n" .. math.ceil(pump.currentAmount * fuelPrice) .. " $", receiptPosX, receiptPosY + 235, receiptPosX + 280, receiptPosY + 275, tocolor(0, 0, 0), 0.5, availableFonts.ThermalPrinter, "right", "center")
			
			-- Fizetés
			if signStart then
				local playerNameWidth = dxGetTextWidth(playerName, 0.5, availableFonts.Lunabar)

				local elapsedTime = getTickCount() - signStart
				local progress = elapsedTime / 3579
				local signState = interpolateBetween(
					0, 0, 0,
					playerNameWidth, 0, 0,
					progress, "Linear")

				dxDrawText(playerName, receiptPosX + 210 - playerNameWidth / 2, receiptPosY + 375, receiptPosX + 210 - playerNameWidth / 2 + signState, receiptPosY + 395, tocolor(20, 100, 200), 0.5, availableFonts.Lunabar, "left", "center", true, false, false, false, true)
				
				if progress > 1.25 then
					showReciept = false
					showCursor(false)
					
					triggerServerEvent("ä>[€ÄŁ", localPlayer, stationId, positionId, math.ceil(pump.currentAmount * fuelPrice))
					
					for k, v in pairs(availableFonts) do
						if isElement(availableFonts[k]) then
							destroyElement(availableFonts[k])
						end

						availableFonts[k] = nil
					end

					availableFonts = {}
				end
			else
				buttons["ä>[€ÄŁ"] = {receiptPosX + receiptWidth - 160, receiptPosY + 365, 140, 30}
			end

			-- Gombok
			local cursorX, cursorY = getCursorPosition()

			if tonumber(cursorX) and tonumber(cursorY) then
				cursorX = cursorX * screenX
				cursorY = cursorY * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			else
				activeButton = false
			end
		end

		if not activeSyncedStation then
			return
		end

		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
		local playerRotX, playerRotY, playerRotZ = getElementRotation(localPlayer)
		local fuelPositions = availableStations[activeSyncedStation].fuelPositions

		for k = 1, #fuelPositions do
			local v = fuelPositions[k]
			local canSeePump = false
			local pumpId = k

			if pumpId % 2 == 0 then
				pumpId = pumpId - 1
			end

			if fuelPositions[pumpId].element and isElementOnScreen(fuelPositions[pumpId].element) then
				canSeePump = true
			end

			if v.pistolObject and v.lineStart then
				local pistolX, pistolY, pistolZ = getElementPosition(v.pistolObject)
				dxDrawLine3D(v.lineStart[1], v.lineStart[2], v.lineStart[3], pistolX, pistolY, pistolZ, tocolor(5, 5, 5), 1.25)
			end

			if v.renderTarget and canSeePump then
				local fuelPrice = availableStations[activeSyncedStation].fuelPrice

				-- ha a jelenlegi mennyiség nagyobb mint 0 és jelenleg használja valaki a kutat
				if v.currentAmount > 0 and v.fillingStarted then
					dxSetRenderTarget(v.renderTarget, true)

					dxDrawText(math.ceil(math.floor(v.currentAmount * 10) / 10 * fuelPrice) .. " $", 0, 0, counterSizeXY, counterSizeXY / 4, tocolor(37, 40, 12), 1, availableFonts.Counter, "right", "center")
					dxDrawText(math.floor(v.currentAmount * 10) / 10 .. " L", 0, counterSizeXY / 4 - 2.5, counterSizeXY, counterSizeXY / 2 - 2.5, tocolor(37, 40, 12), 1, availableFonts.Counter, "right", "center")
					
					if v.drawPosition[7] then
						dxDrawText(utf8.gsub(fuelPrice, "%.", ",") .. " $/L", counterSizeXY / 4, counterSizeXY / 2 - 5, counterSizeXY - 5, counterSizeXY / 4 * 3 - 5, tocolor(37, 40, 12), 1, availableFonts.Counter, "left", "center")
					else
						dxDrawText(utf8.gsub(fuelPrice, "%.", ",") .. " $/L", 0, counterSizeXY / 2 - 5, counterSizeXY - 5, counterSizeXY / 4 * 3 - 5, tocolor(37, 40, 12), 1, availableFonts.Counter, "right", "center")
					end

					dxSetRenderTarget()

					v.renderTargetUpdated = false
				-- ha nincs használatban a kút vagy 0 az értéke akkor csak 1x frissítse
				elseif not v.renderTargetUpdated then
					v.renderTargetUpdated = true

					dxSetRenderTarget(v.renderTarget, true)

					dxDrawText(math.ceil(math.floor(v.currentAmount * 10) / 10 * fuelPrice) .. " $", 0, 0, counterSizeXY, counterSizeXY / 4, tocolor(37, 40, 12), 1, availableFonts.Counter, "right", "center")
					dxDrawText(math.floor(v.currentAmount * 10) / 10 .. " L", 0, counterSizeXY / 4 - 2.5, counterSizeXY, counterSizeXY / 2 - 2.5, tocolor(37, 40, 12), 1, availableFonts.Counter, "right", "center")
					
					if v.drawPosition[7] then
						dxDrawText(utf8.gsub(fuelPrice, "%.", ",") .. " $/L", counterSizeXY / 4, counterSizeXY / 2 - 5, counterSizeXY - 5, counterSizeXY / 4 * 3 - 5, tocolor(37, 40, 12), 1, availableFonts.Counter, "left", "center")
					else
						dxDrawText(utf8.gsub(fuelPrice, "%.", ",") .. " $/L", 0, counterSizeXY / 2 - 5, counterSizeXY - 5, counterSizeXY / 4 * 3 - 5, tocolor(37, 40, 12), 1, availableFonts.Counter, "right", "center")
					end

					dxSetRenderTarget()
				end

				if v.drawPosition then
					dxDrawMaterialLine3D(v.drawPosition[1], v.drawPosition[2], v.drawPosition[3] + 0.5, v.drawPosition[1], v.drawPosition[2], v.drawPosition[3], v.renderTarget, 0.5, -1, v.drawPosition[1] + v.drawPosition[4], v.drawPosition[2] + v.drawPosition[5], v.drawPosition[3] + v.drawPosition[6])
				end
			end

			if v.effectElement then
				for i = 1, #v.lineStart do
					if isElement(v.pistolObject) and isElement(v.pistolHolder) then
						local pistolPosX, pistolPosY, pistolPosZ = getElementPosition(v.pistolObject)
						local pistolRotX, pistolRotY, pistolRotZ = getElementRotation(v.pistolObject)

						local angle = math.rad(pistolRotZ + 90)
						local rotatedX = -math.sin(angle) * 0.3
						local rotatedY = math.cos(angle) * 0.3

						setElementPosition(v.effectElement, pistolPosX + rotatedX, pistolPosY + rotatedY, pistolPosZ + 0.07)
						setElementRotation(v.effectElement, 120, 0, -pistolRotZ - 90)
					end
				end
			end

			if v.fillingStarted then
				local fuelPrice = availableStations[activeSyncedStation].fuelPrice
				local elapsedTime = getTickCount() - v.fillingStarted
				local fuelAmount = counterSpeed / 1000 * elapsedTime

				v.currentAmount = v.litersStarted + fuelAmount

				if pistolInHand and selectedVehicle and pistolInHand[1] == activeSyncedStation and pistolInHand[2] == k then
					vehAddFuel[selectedVehicle] = (vehFuelStart[selectedVehicle] or 0) + math.floor(fuelAmount * 10) / 10

					if not vehFuelLeft[selectedVehicle] then
						vehFuelLeft[selectedVehicle] = getElementData(selectedVehicle, "vehicle.fuel") or 0
					end

					if vehFuelLeft[selectedVehicle] + vehAddFuel[selectedVehicle] >= (fuelTankSize[getElementModel(selectedVehicle)] or 50) then
						v.fillingStarted = false

						triggerServerEvent("doFuelingProcess", localPlayer, false, pistolInHand[1], pistolInHand[2], selectedVehicle, true)

						setElementData(resourceRoot, "fuelStation_" .. pistolInHand[1] .. "_" .. pistolInHand[2], v.currentAmount)

						exports.see_hud:showInfobox("i", "Teletankoltad a járművet.")
					end
				end
			end
		end

		if fuelingProcess then
			local now = getTickCount()

			if fuelingProcess.endTime and now <= fuelingProcess.endTime then
				local elapsedTime = now - fuelingProcess.startTime
				local duration = fuelingProcess.endTime - fuelingProcess.startTime
				local progress = elapsedTime / duration

				local sx, sy = 400, 30
				local x = screenX / 2 - sx / 2
				local y = screenY - 100 - sy

				dxDrawRectangle(x - 2, y - 2, sx + 4, sy + 4, tocolor(0, 0, 0, 155))
				dxDrawRectangle(x, y, sx, sy, tocolor(61, 122, 188, 150))
				dxDrawRectangle(x, y, sx * progress, sy, tocolor(61, 122, 188))

				dxDrawText(fuelingProcess.text, x, y, x + sx, y + sy, tocolor(0, 0, 0), 1, availableFonts.Roboto, "center", "center")
			end
		end

		local nearestVehicle = false
		
		activeVehicle = false

		if (pistolInHand or canisterInHand) and not isPedInVehicle(localPlayer) then
			local vehiclesTable = false

			if canisterInHand then
				vehiclesTable = getElementsByType("vehicle", getRootElement(), true)
			else
				vehiclesTable = getElementsWithinColShape(availableStations[activeSyncedStation].innerColShape.element, "vehicle")
			end

			for k, v in ipairs(vehiclesTable) do
				local fillX, fillY, fillZ = getElementPosition(v)
				local vehRotX, vehRotY, vehRotZ = getElementRotation(v)
				local vehicleModel = getElementModel(v)
				local fuelSide = fuelSides[vehicleModel] or "bh"

				if centerFilling[vehicleModel] then
				elseif fuelSide then
					if fuelSide == "hk" then
						fillX, fillY, fillZ = getPositionFromElementOffset(getElementMatrix(v), 0, -getElementRadius(v), 0)
					else
						fillX, fillY, fillZ = getVehicleComponentPosition(v, wheelSide[fuelSide], "world")
						fillX, fillY = rotateAround(vehRotZ, 0.5, 0, fillX, fillY)
					end
				end

				if fillX and fillY and fillZ then
					local velX, velY, velZ = getElementVelocity(v)
					local actualspeed = math.floor(math.sqrt(velX*velX + velY*velY + velZ*velZ) * 187.5)

					if actualspeed < 2 and math.abs(fillZ - playerPosZ) <= 2.5 then
						local dist = getDistanceBetweenPoints2D(playerPosX, playerPosY, fillX, fillY)

						if dist <= 5 then
							local angle = playerRotZ - vehRotZ

							if angle < 0 then
								angle = angle + 360
							elseif angle > 360 then
								angle = angle - 360
							end

							if dist <= 0.75 then
								if fuelSide == "hk" then
									if angle <= 45 or angle >= 315 then
										nearestVehicle = v
									end
								elseif angle >= 45 and angle <= 135 then
									nearestVehicle = v
								end
							end

							local activeColor = tocolor(255, 255, 255, 200)

							fillZ = getGroundPosition(fillX, fillY, fillZ) + 0.05
							
							if nearestVehicle then
								activeColor = tocolor(61, 122, 188, 200)
							end

							if pickupAnim or selectedVehicle and selectedVehicle == nearestVehicle then
								activeColor = tocolor(0, 170, 255, 200)
							end

							dxDrawMaterialLine3D(fillX - 0.5, fillY, fillZ, fillX + 0.5, fillY, fillZ, circleTexture, 1, activeColor, fillX, fillY, fillZ + 0.25)

							local onScreenX, onScreenY = getScreenFromWorldPosition(fillX, fillY, fillZ + 1)

							if onScreenX and onScreenY then
								dxDrawImage(onScreenX - 64, onScreenY - 64, 128, 128, "files/images/fuel.png", 0, 0, 0, activeColor)
							end
						end
					end
				end
			end
		end

		activeVehicle = nearestVehicle

		if selectedVehicle and not nearestVehicle then
			if isTimer(fillTimer) then
				killTimer(fillTimer)
			end

			triggerServerEvent("resetPumpPistol", localPlayer)

			lastPressTick = getTickCount()
			vehAddFuel = {}
			selectedVehicle = false
			setPedAnimation(source)
		end

		if pistolInHand and not pistolTaken then
			local stationId = pistolInHand[1]
			local positionId = pistolInHand[2]
			local fuelPos = availableStations[stationId].fuelPositions[positionId]

			if fuelPos then
				if isPedInVehicle(localPlayer) then
					triggerServerEvent("resetPumpPistol", localPlayer)
					exports.see_hud:showInfobox("w", "Itt nem tud átmenni a cső!")
					pistolTaken = true
					pistolHitNum = 0
					setPedAnimation(source)
					return
				end

				if pickupAnim or selectedVehicle then
					return
				end

				local pistolPosX, pistolPosY, pistolPosZ = getElementPosition(fuelPos.pistolObject)
				local lineStartX, lineStartY, lineStartZ = fuelPos.lineStart[1], fuelPos.lineStart[2], fuelPos.lineStart[3]
				local angle = math.deg(math.atan2(lineStartY - pistolPosY, lineStartX - pistolPosX)) + 180 + (fuelPos.lineStart[4] or 0)

				if angle > 360 then
					angle = angle - 360
				end

				if fuelPos.checkRotation(angle) then
					triggerServerEvent("resetPumpPistol", localPlayer)
					exports.see_hud:showInfobox("w", "Itt nem tud átmenni a cső!")
					pistolTaken = true
					pistolHitNum = 0
					setPedAnimation(source)
					return
				end

				if getDistanceBetweenPoints3D(lineStartX, lineStartY, lineStartZ, playerPosX, playerPosY, playerPosZ) >= 4.5 then
					triggerServerEvent("resetPumpPistol", localPlayer)
					exports.see_hud:showInfobox("w", "Túl messzire mentél a csővel!")
					pistolTaken = true
					pistolHitNum = 0
					setPedAnimation(source)
					return
				end

				local _, _, _, _, hitElement = processLineOfSight(pistolPosX, pistolPosY, pistolPosZ, lineStartX, lineStartY, lineStartZ, true, true, false, true, true, false, false, false, availableStations[stationId].fuelPositions[positionId].pistolObject)
				local _, _, _, _, hitElement2 = processLineOfSight(pistolPosX, pistolPosY, pistolPosZ, lineStartX, lineStartY, lineStartZ, true, true, false, true, true, false, false, false, localPlayer)

				if isElement(hitElement) and isElement(hitElement2) then
					local elementModel = getElementModel(hitElement)
					local elementModel2 = getElementModel(hitElement2)

					if elementModel ~= 3465 and elementModel ~= 330 and elementModel2 ~= 3465 and elementModel2 ~= 330 then
						pistolHitNum = pistolHitNum + 1

						if pistolHitNum >= 5 then
							triggerServerEvent("resetPumpPistol", localPlayer)
							exports.see_hud:showInfobox("w", "Itt nem tud átmenni a cső!")
							pistolTaken = true
							pistolHitNum = 0
							setPedAnimation(source)
							return
						end
					else
						pistolHitNum = 0
					end
				else
					pistolHitNum = 0
				end
			end
		end

		if activePump then
			local x = screenX / 2 - 250
			local y = screenY - 122

			dxDrawRectangle(x, y, 500, 50, tocolor(0, 0, 0, 150))
			dxDrawRectangle(x, y + 50, 500, 2, tocolor(61, 122, 188))

			if pistolInHand then
				dxDrawText("Használd az #3d7abc[E] #ffffffbetűt a pisztoly visszarakásához.", x, y, x + 500, y + 50, tocolor(255, 255, 255), 1, availableFonts.Roboto, "center", "center", false, false, false, true)
			else
				dxDrawText("Használd az #3d7abc[E] #ffffffbetűt a pisztoly kivételéhez.", x, y, x + 500, y + 50, tocolor(255, 255, 255), 1, availableFonts.Roboto, "center", "center", false, false, false, true)
			end
		end
	end)

addEventHandler("onClientRestore", getRootElement(),
	function ()
		if activeSyncedStation then
			local fuelPositions = availableStations[activeSyncedStation].fuelPositions

			for k = 1, #fuelPositions do
				local v = fuelPositions[k]

				if v then
					v.renderTargetUpdated = false
				end
			end
		end
	end)

function generatePriceTable()
	if activeSyncedStation and isElement(priceTable.renderTarget) then
		local fuelPrice = availableStations[activeSyncedStation].fuelPrice

		if not fuelPrice then
			fuelPrice = getElementData(resourceRoot, "fuelPrices")[activeSyncedStation]
			availableStations[activeSyncedStation].fuelPrice = fuelPrics
		end

		local tempFont = dxCreateFont("files/fonts/counter2.ttf", 35, false, "antialiased")

		dxSetRenderTarget(priceTable.renderTarget)

		dxDrawImage(0, 0, 256, 256, "files/images/arak_uv.png")
		dxDrawText("8", 226, 92, 245, 122, tocolor(0, 0, 0, 150), 0.5, tempFont, "center", "center")
		dxDrawText("8", 226, 147, 245, 176, tocolor(0, 0, 0, 150), 0.5, tempFont, "center", "center")
		dxDrawText("8", 226, 202, 245, 231, tocolor(0, 0, 0, 150), 0.5, tempFont, "center", "center")
		dxDrawText("$", 226, 92, 245, 122, tocolor(255, 240, 10, 225), 0.5, tempFont, "center", "center")
		dxDrawText("$", 226, 147, 245, 176, tocolor(255, 240, 10, 225), 0.5, tempFont, "center", "center")
		dxDrawText("$", 226, 202, 245, 231, tocolor(255, 240, 10, 225), 0.5, tempFont, "center", "center")
		
		for i = 0, 2 do
			dxDrawText("8", 123 + 34 * i, 92, 151 + 34 * i, 135, tocolor(0, 0, 0, 150), 1, tempFont, "right", "center")
			
			if utf8.len(fuelPrice) >= 3 - i then
				dxDrawText(utf8.sub(fuelPrice, -1 * (3 - i), -1 * (3 - i)), 123 + 34 * i, 92, 151 + 34 * i, 135, tocolor(255, 240, 10, 225), 1, tempFont, "right", "center")
			end
		end

		for i = 0, 2 do
			dxDrawText("8", 123 + 34 * i, 147, 151 + 34 * i, 191, tocolor(0, 0, 0, 150), 1, tempFont, "right", "center")
			dxDrawText("-", 123 + 34 * i, 147, 151 + 34 * i, 191, tocolor(255, 240, 10, 225), 1, tempFont, "right", "center")
		end

		for i = 0, 2 do
			dxDrawText("8", 123 + 34 * i, 202, 151 + 34 * i, 246, tocolor(0, 0, 0, 150), 1, tempFont, "right", "center")
			dxDrawText("-", 123 + 34 * i, 202, 151 + 34 * i, 246, tocolor(255, 240, 10, 225), 1, tempFont, "right", "center")
		end

		dxSetRenderTarget()

		if isElement(tempFont) then
			destroyElement(tempFont)
		end

		return true
	end

	return false
end
addEventHandler("onClientRestore", getRootElement(), generatePriceTable)

function getPositionFromElementOffset(matrix, offsetX, offsetY, offsetZ)
	local positionX = offsetX * matrix[1][1] + offsetY * matrix[2][1] + offsetZ * matrix[3][1] + matrix[4][1]
	local positionY = offsetX * matrix[1][2] + offsetY * matrix[2][2] + offsetZ * matrix[3][2] + matrix[4][2]
	local positionZ = offsetX * matrix[1][3] + offsetY * matrix[2][3] + offsetZ * matrix[3][3] + matrix[4][3]

	return positionX, positionY, positionZ
end