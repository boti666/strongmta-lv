local invoiceList = {}
local elevatorList = {}
local availableElevators = {
	-- Roosevelt
	{1090.6206054688, 1331.8839111328, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.15, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.15 * 2, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.15 * 3, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.15 * 4, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.15 * 5, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.15 * 6, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.25 * 7, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.25 * 8, 10.831257820129, 270},
	{1090.6206054688, 1331.8839111328 - 11.25 * 9, 10.831257820129, 270},

	-- jesse
	{-759.22381591797, 2753.2221679688, 45.839061737061, 90},
	{-759.22381591797, 2753.2221679688 + 15.00, 45.839061737061, 90},

	-- graves
	{2032.3868408203, 2038.0698242188, 10.831257820129, 180},
	{2059.4541015625, 2038.4008789062, 10.831257820129, 180},
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		for i, v in ipairs(availableElevators) do
			addElevatorPoint(v[1], v[2], v[3], v[4])
		end

		changePriceMargin()
		setTimer(changePriceMargin, 1000 * 60 * 60, 0)
	end
)

function changePriceMargin()
	setElementData(resourceRoot, "priceMargin:15", math.random(10, 150))
	setElementData(resourceRoot, "priceMargin:39", math.random(10, 150))
	setElementData(resourceRoot, "priceMargin:19", math.random(10, 150))
end

addEvent("sendInvoice", true)
addEventHandler("sendInvoice", getRootElement(),
	function (selectedPlayer, partsList, sourceVehicle, groupId)
		if isElement(source) and client and client == source then
			if isElement(selectedPlayer) then
				invoiceList[sourceVehicle] = {selectedPlayer, partsList, groupId, source}

				triggerClientEvent(selectedPlayer, "sendInvoice", selectedPlayer, source, partsList, sourceVehicle)
			end
		end
	end
)

function fixVehicleParts(sourceVehicle, selectedParts)
	if isElement(sourceVehicle) then
		for i = 1, #selectedParts do
			local part = selectedParts[i]

			if part then
				local id = gettok(part[3], 2, ":")

				if id then
					id = tonumber(id)
				end

				if string.find(part[3], "panel") then
					setVehiclePanelState(sourceVehicle, id, 0)
					removeElementData(sourceVehicle, "panelState:" .. i)
				elseif string.find(part[3], "door") then
					setVehicleDoorState(sourceVehicle, id, 0)
				elseif string.find(part[3], "light") then
					setVehicleLightState(sourceVehicle, id, 0)
				elseif part[3] == "engine" then
					setElementHealth(sourceVehicle, 1000)
				elseif string.find(part[3], "wheel") then
					local states = {getVehicleWheelStates(sourceVehicle)}

					for j = 1, 4 do
						if j == id then
							states[j] = 0
							break
						end
					end

					setVehicleWheelStates(sourceVehicle, unpack(states))
				elseif part[3] == "oilchange" then
					setElementData(sourceVehicle, "lastOilChange", 0)
					triggerClientEvent("oilChangeEffect", resourceRoot, sourceVehicle)
				end
			end
		end

		return true
	else
		return false
	end
end

addEvent("invoiceReaction", true)
addEventHandler("invoiceReaction", getRootElement(),
	function (reacionType, sourceVehicle)
		if isElement(source) and client and client == source then
			if isElement(sourceVehicle) then
				local invoiceData = invoiceList[sourceVehicle]

				if invoiceData then
					local partsCount = #invoiceData[2]
					local repairDuration = 0

					if reacionType == "accept" then
						local currentMoney = getElementData(source, "char.Money") or 0
						local totalPrice = 0
						local partsPrice = 0
						local difficulty = 0



						for i = 1, partsCount do
							local part = invoiceData[2][i]

							if part then
								totalPrice = totalPrice + part[2]
								partsPrice = partsPrice + part[5]
								difficulty = difficulty + part[4]
							end
						end

						totalPrice = math.floor(totalPrice)
						partsPrice = math.floor(partsPrice)

						repairDuration = 2000 * difficulty
						currentMoney = currentMoney - totalPrice

						if currentMoney >= 0 then
							if fixVehicleParts(sourceVehicle, invoiceData[2]) then
								setElementData(source, "char.Money", currentMoney)

								if invoiceData[3] and invoiceData[3] > 0 then
									local currentBalance = exports.see_groups:getGroupBalance(invoiceData[3]) or 0
									
									if currentBalance then
										exports.see_groups:setGroupBalance(invoiceData[3], currentBalance + 25000 * partsCount)
									end
								end

								-- Infó
								local visibleName = getElementData(invoiceData[4], "visibleName"):gsub("_", " ")
								local vehicleName = exports.see_vehiclenames:getCustomVehicleName(getElementModel(sourceVehicle))
								local playersList = getElementsByType("player")

								for i = 1, #playersList do
									local playerElement = playersList[i]

									if exports.see_groups:isPlayerHavePermission(playerElement, "repair") then
										outputChatBox("#3d7abc[StrongMTA - Szerelő]: #ffffff" .. visibleName .. " megjavított egy #598ed7" .. vehicleName .. "#ffffff-t.", playerElement, 255, 255, 255, true)
										outputChatBox("#3d7abc[StrongMTA - Szerelő]: #ffffffÁr: #3d7abc" .. totalPrice .. " $ #ffffffAlkatrész ár: #d75959" .. partsPrice .. " $ #ffffffProfit: #3d7abc" .. 25000 * partsCount .. " $", playerElement, 255, 255, 255, true)
									end
								end

								-- Anim @ Sound
								setPedAnimation(invoiceData[4], "BOMBER", "BOM_Plant_Loop", -1, true, false, false)
								setElementData(source, "forcedanimation", 1)
								--setElementFrozen(source, true)
								triggerClientEvent("repairVehicleSound", invoiceData[4], true)

								setTimer(
									function (sourcePlayer)
										if isElement(sourcePlayer) then
											triggerClientEvent("repairVehicleSound", sourcePlayer, false)
											setPedAnimation(sourcePlayer, false)
											setElementData(sourcePlayer, "forcedanimation", 0)
										end
									end,
								repairDuration, 1, invoiceData[4])
							end
						else
							exports.see_hud:showInfobox(source, "e", "Nincs nálad elég pénz!")
							reacionType = "nomoney"
						end
					end

					triggerClientEvent(invoiceData[4], "invoiceReaction", invoiceData[4], reacionType, repairDuration)

					invoiceList[sourceVehicle] = nil
				end
			end
		end
	end
)

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		if invoiceList[source] then
			triggerClientEvent(invoiceList[source][1], "interruptReaction", invoiceList[source][1])
			iprint(invoiceList[source][1])
		end
	end
)

addCommandHandler("makelift",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			local x, y, z = getElementPosition(sourcePlayer)
			local rot = getPedRotation(sourcePlayer)
			addElevatorPoint(x, y, z, rot)
		end
	end
)

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

function addElevatorPoint(posX, posY, posZ, rotation)
	posZ = posZ - 1

	local baseObject = createObject(4830, posX, posY, posZ, 0, 0, rotation + 180) --4830 --13049

	if isElement(baseObject) then
		local armsObject = createObject(4991, posX, posY, posZ, 0, 0, rotation + 180) --4991  --12931
		setElementCollisionsEnabled(armsObject, false)

		local baseColShape = createColSphere(posX, posY, posZ, 2)
		attachElements(baseColShape, armsObject, 0, 0, 1)

		local rotatedX, rotatedY = rotateAround(rotation, -2.5, 0)
		local buttonColShape = createColSphere(posX + rotatedX, posY + rotatedY, posZ + 1, 0.75)

		table.insert(elevatorList, {baseObject, armsObject, buttonColShape, baseColShape, 0, posZ, false})
	end
end

addCommandHandler("lift",
	function (sourcePlayer, commandName, newLevel)
		if exports.see_groups:isPlayerHavePermission(sourcePlayer, "repair") then
			local nearbyElevator = false

			for i = 1, #elevatorList do
				if isElementWithinColShape(sourcePlayer, elevatorList[i][3]) then
					nearbyElevator = i
					break
				end
			end

			if nearbyElevator then
				newLevel = tonumber(newLevel)

				if not newLevel or newLevel < 0 or newLevel > 2 then
					outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Szint (0-2)]", sourcePlayer, 255, 255, 255, true)
				else
					if not elevatorList[nearbyElevator][7] then
						if newLevel ~= elevatorList[nearbyElevator][5] then
							local playersTable = getElementsWithinColShape(elevatorList[nearbyElevator][4], "player")
							local canSetLevel = true

							for i = 1, #playersTable do
								local playerElement = playersTable[i]

								if isElement(playerElement) then
									canSetLevel = false
									break
								end
							end

							if canSetLevel then
								local liftArmX, liftArmY, liftArmZ = getElementPosition(elevatorList[nearbyElevator][2])

								if elevatorList[nearbyElevator][5] == 0 and newLevel > 0 then
									local vehiclesTable = getElementsWithinColShape(elevatorList[nearbyElevator][4], "vehicle")
									local vehicleFound = false
									local multipleFound = false

									for i = 1, #vehiclesTable do
										local vehicleElement = vehiclesTable[i]

										if isElement(vehicleElement) then
											if vehicleFound then
												multipleFound = true
												break
											else
												vehicleFound = vehicleElement
											end
										end
									end

									if multipleFound then
										outputChatBox("#3d7abc[StrongMTA - Szerelő]: #ffffffEgyszerre csak egy járművet bír el a lift!", sourcePlayer, 255, 255, 255, true)
										return
									end

									if isElement(vehicleFound) then
										attachRotationAdjusted(vehicleFound, elevatorList[nearbyElevator][2])
									end
								end

								moveObject(elevatorList[nearbyElevator][2], 5000, liftArmX, liftArmY, elevatorList[nearbyElevator][6] + newLevel)

								triggerClientEvent("elevatorSound", resourceRoot, elevatorList[nearbyElevator][1], true)

								setTimer(
									function (elevatorId)
										if elevatorList[elevatorId] then
											local attachedElements = getAttachedElements(elevatorList[elevatorId][2])
											local attachedVehicle = false

											for i = 1, #attachedElements do
												local attachedElement = attachedElements[i]

												if getElementType(attachedElement) == "vehicle" then
													attachedVehicle = attachedElement
													break
												end
											end

											if isElement(attachedVehicle) then
												if elevatorList[elevatorId][5] == 0 then
													detachElements(attachedVehicle)
													removeElementData(attachedVehicle, "elevatorLevel")
												else
													setElementData(attachedVehicle, "elevatorLevel", elevatorList[elevatorId][5])
												end
											end

											elevatorList[elevatorId][7] = false

											stopObject(elevatorList[elevatorId][2])

											triggerClientEvent("elevatorSound", resourceRoot, elevatorList[elevatorId][1], false)
										end
									end,
								5000, 1, nearbyElevator)

								elevatorList[nearbyElevator][5] = newLevel
								elevatorList[nearbyElevator][7] = true
							else
								outputChatBox("#3d7abc[StrongMTA - Szerelő]: #ffffffValaki éppen alatta áll!", sourcePlayer, 255, 255, 255, true)
							end
						end
					end
				end
			else
				outputChatBox("#3d7abc[StrongMTA - Szerelő]: #ffffffNem vagy lift közelében!", sourcePlayer, 255, 255, 255, true)
			end
		end
	end
)

function attachRotationAdjusted(sourceElement, targetElement)
	local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(sourceElement)
	local sourceRotX, sourceRotY, sourceRotZ = getElementRotation(sourceElement)

	local targetPosX, targetPosY, targetPosZ = getElementPosition(targetElement)
	local targetRotX, targetRotY, targetRotZ = getElementRotation(targetElement)

	local offsetPosX = sourcePosX - targetPosX
	local offsetPosY = sourcePosY - targetPosY
	local offsetPosZ = sourcePosZ - targetPosZ

	local offsetRotX = sourceRotX - targetRotX
	local offsetRotY = sourceRotY - targetRotY
	local offsetRotZ = sourceRotZ - targetRotZ

	offsetPosX, offsetPosY, offsetPosZ = applyInverseRotation(offsetPosX, offsetPosY, offsetPosZ, targetRotX, targetRotY, targetRotZ)

	attachElements(sourceElement, targetElement, offsetPosX, offsetPosY, offsetPosZ, offsetRotX, offsetRotY, offsetRotZ)
end

function applyInverseRotation(posX, posY, posZ, rotX, rotY, rotZ)
	rotX = math.rad(rotX)
	rotY = math.rad(rotY)
	rotZ = math.rad(rotZ)

	local tempY = posY
	posY =  math.cos(rotX) * tempY + math.sin(rotX) * posZ
	posZ = -math.sin(rotX) * tempY + math.cos(rotX) * posZ

	local tempX = posX
	posX =  math.cos(rotY) * tempX - math.sin(rotY) * posZ
	posZ =  math.sin(rotY) * tempX + math.cos(rotY) * posZ

	tempX = posX
	posX =  math.cos(rotZ) * tempX + math.sin(rotZ) * posY
	posY = -math.sin(rotZ) * tempX + math.cos(rotZ) * posY

	return posX, posY, posZ
end