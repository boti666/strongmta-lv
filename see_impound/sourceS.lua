local connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end
)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("vehicle")) do
			removeElementData(v, "cableHolder")
			removeElementData(v, "cableAttachment")
			removeElementData(v, "carAnimation")
			removeElementData(v, "carPlacedOnTruck")
		end
	end
)

addEvent("playPackerRampAnim", true)
addEventHandler("playPackerRampAnim", getRootElement(),
	function (towTruck)
		if towTruck then
			local rx, ry, rz = getElementRotation(towTruck)

			setElementRotation(source, 0, 0, rz - 90, "default", true)
			setElementFrozen(source, true)
			setPedAnimation(source, "police", "CopTraf_Left", -1, true, false, false)

			setTimer(
				function (thePlayer)
					if isElement(thePlayer) then
						setPedAnimation(thePlayer, false)
						setElementFrozen(thePlayer, false)
					end
				end,
			SLIDE_ANIMATION_TIME + ROTATE_ANIMATION_TIME, 1, source)
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldVal)
		if dataName == "packerState" then
			local dataVal = getElementData(source, "packerState") or "up"

			if dataVal ~= "up" then
				setElementFrozen(source, true)
			else
				setElementFrozen(source, false)
			end
		end

		if dataName == "carPlacedOnTruck" then
			local dataVal = getElementData(source, "carPlacedOnTruck")

			if oldVal and not dataVal then
				detachElements(source, oldVal[1])
			end

			if dataVal then
				attachElements(source, dataVal[1], dataVal[2], dataVal[3], dataVal[4], dataVal[5], dataVal[6], dataVal[7])
			end
		end

		if dataName == "carAnimation" then
			local dataVal = getElementData(source, "carAnimation")

			if oldVal and not dataVal then
				setElementCollisionsEnabled(source, true)
			end

			if dataVal then
				setElementCollisionsEnabled(source, false)
			end
		end

		if dataName == "cableHolder" then
			local dataVal = getElementData(source, "cableHolder")

			if isElement(dataVal) and getElementType(dataVal) == "player" then
				setElementSyncer(source, dataVal)
			else
				setElementSyncer(source, true)
			end
		end
	end
)

addEvent("openUnImpoundPanel", true)
addEventHandler("openUnImpoundPanel", getRootElement(),
	function ()
		if isElement(source) then
			dbQuery(
				function (qh, thePlayer)
					if isElement(thePlayer) then
						local result = dbPoll(qh, 0)

						triggerClientEvent(thePlayer, "openUnImpoundPanel", thePlayer, result or {})
					end
				end,
			{source}, connection, "SELECT vehicleId, modelId FROM vehicles WHERE impounded = 1 AND ownerId = ?", getElementData(source, "char.ID"))
		end
	end
)

local unImpoundPrice = 50000

local unImpoundPositions = {
	[1] = {2406.501953125, 2529.1779785156, 10.8203125},
	[2] = {2412.501953125, 2529.0368652344, 10.8203125},
	[3] = {2422.501953125, 2529.326171875, 10.8203125},
	[4] = {2433.501953125, 2529.6169433594, 10.8203125},
	[5] = {2438.501953125, 2529.6169433594, 10.8203125},
	[6] = {2444.501953125, 2529.6169433594, 10.8203125},
	[7] = {2449.501953125, 2529.6169433594, 10.8203125},
	[8] = {2454.501953125, 2529.6169433594, 10.8203125},
	[9] = {2460.501953125, 2529.6169433594, 10.8203125},
	[10] = {2471.501953125, 2529.6169433594, 10.8203125},
	[11] = {2476.501953125, 2529.6169433594, 10.8203125}

}

--local mathUnPositions = math.random(#unImpoundPositions)

function getRandomValue(selectedTable) 
	return selectedTable[math.random(#selectedTable)] 
end 

addEvent("€}Í<€}Đ@ÄÍ&ŁÄ", true)
addEventHandler("€}Í<€}Đ@ÄÍ&ŁÄ", getRootElement(),
	function (vehicleId)
		if isElement(source) then
			if vehicleId then
				if exports.see_core:takeMoneyEx(source, unImpoundPrice, "€}Í<€}Đ@ÄÍ&ŁÄ") then
					dbExec(connection, "UPDATE vehicles SET impounded = 0 WHERE vehicleId = ?", vehicleId)
					dbQuery(
						function (qh, thePlayer)
							if isElement(thePlayer) then
								local result = dbPoll(qh, 0)
								local selectedTable = getRandomValue(unImpoundPositions)
								local posX = selectedTable[1]
								local posY = selectedTable[2]
								local posZ = selectedTable[3]
								--print(inspect(posX .. " " .. posY .. " " .. posZ))


								if result then
									local veh = exports.see_vehicles:loadVehicle(vehicleId, result[1], true)
									local rotationX, rotationY, rotationZ = getElementRotation(veh)
									setElementPosition(veh, posX, posY, posZ)
									setElementRotation(veh, rotationX, rotationY, rotationZ + 100)
									setTimer(
										function ()
											if isElement(veh) then
												removeElementData(veh, "noCollide")
												setElementAlpha(veh, 255)
											end
										end,
									20000, 1)

									triggerClientEvent(thePlayer, "gpsLocalizeCar", veh)

									local currentBalance = exports.see_groups:getGroupBalance(33)

									if currentBalance then
										exports.see_groups:setGroupBalance(33, currentBalance + 10000)
									end

									exports.see_hud:showInfobox(thePlayer, "i", "Sikeresen kiváltottad a járművedet! Megjelöltük a térképen. Azonosító: " .. vehicleId)
								end
							end
						end,
					{source}, connection, "SELECT * FROM vehicles WHERE vehicleId = ? LIMIT 1", vehicleId)
				else
					exports.see_hud:showInfobox(source, "e", "Nincs elég pénzed a jármű kiváltásához! (" .. unImpoundPrice .. "$)")
				end
			end
		end
	end
)

addCommandHandler("lefoglal",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 2 then
			local theVeh = getPedOccupiedVehicle(sourcePlayer)

			if isElement(theVeh) then
				local groupId = getElementData(theVeh, "vehicle.group") or 0

				if groupId == 0 then
					local jobVehID = getElementData(theVeh, "jobVehicleID") or 0

					if jobVehID == 0 then
						if not getElementData(theVeh, "cableAttachment") then
							removePedFromVehicle(sourcePlayer)
							impoundTheVehicle(theVeh)
							outputChatBox("#3d7abc[StrongMTA - Lefoglalás]: #ffffffSikeresen lefoglaltad a járművet.", sourcePlayer, 255, 255, 255, true)
							
							local currentBalance = exports.see_groups:getGroupBalance(33)

							if currentBalance then
								exports.see_groups:setGroupBalance(33, currentBalance + 150000)
							end
						else
							outputChatBox("#d75959[StrongMTA - Lefoglalás]: #ffffffAz autót éppen lefoglalják.", sourcePlayer, 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[StrongMTA - Lefoglalás]: #ffffffMunkajárműveket nem foglalhatsz le.", sourcePlayer, 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[StrongMTA - Lefoglalás]: #ffffffFrakciójárműveket nem foglalhatsz le.", sourcePlayer, 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[StrongMTA - Lefoglalás]: #ffffffNem ülsz járműben.", sourcePlayer, 255, 255, 255, true)
			end
		end
	end
)

function informatePlayer(thePlayer)
	if isElement(thePlayer) then
		outputChatBox("[formatting]#3d7abc[Parkolás felügyelet]: #ffffffÜdvözöljük! Tájékoztatjuk, hogy járművét szervezetünk lefoglalta és elszállította [b]#d75959nem megfelelő parkolás[/b] #ffffffmiatt.", thePlayer, 255, 255, 255, true)
		outputChatBox("[formatting]#3d7abc[Parkolás felügyelet]: #ffffffAmennyiben ki szeretné váltani járművét, úgy fáradjon el Las Venturas-i telephelyünkre. ((Piros 'P' ikon a térképen)). Kiváltási díj: " .. unImpoundPrice .. "$", thePlayer, 255, 255, 255, true)	
	end
end

function impoundTheVehicle(theVeh)
	if isElement(theVeh) then
		local ownerId = getElementData(theVeh, "vehicle.owner") or 0

		dbExec(connection, "UPDATE vehicles SET impounded = 1 WHERE vehicleId = ?", getElementData(theVeh, "vehicle.dbID"))
		destroyElement(theVeh)

		if ownerId > 0 then
			for k, v in pairs(getElementsByType("player")) do
				if ownerId == getElementData(v, "char.ID") then
					informatePlayer(v)
					break
				end
			end
		end
	end
end
addEvent("Í}€}Đ@ÄÍ&ŁÄ", true)
addEventHandler("Í}€}Đ@ÄÍ&ŁÄ", getRootElement(), impoundTheVehicle)