local connection = false
local vehiclesTable = {}
local queueTable = {}
local queueTimer = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getRootElement(),
	function (startedRes)
		if getResourceName(startedRes) == "see_items" then
			for k, v in pairs(vehiclesTable) do
				if isElement(k) then
					exports.see_items:loadItems(k)
				end
			end
		elseif startedRes == getThisResource() then
			connection = exports.see_database:getConnection()

			dbQuery(loadGroupVehicles, connection, "SELECT * FROM vehicles WHERE groupId > 0")
		end
	end)

local blockedParkPositions = {}

addCommandHandler("park",
	function (sourcePlayer)
		local pedveh = getPedOccupiedVehicle(sourcePlayer)

		if isElement(pedveh) then
			local ownerId = getElementData(pedveh, "vehicle.owner")

			if ownerId then
				local groupId = getElementData(pedveh, "vehicle.group") or 0

				if ownerId == getElementData(sourcePlayer, "char.ID") or groupId > 0 and exports.see_groups:isPlayerInGroup(sourcePlayer, groupId) then
					triggerClientEvent(sourcePlayer, "handleParkingProcess", sourcePlayer, pedveh, blockedParkPositions)
				else
					exports.see_hud:showInfobox(sourcePlayer, "e", "Ezt a járművet nem tudod leparkolni!")
				end
			else
				exports.see_hud:showInfobox(sourcePlayer, "e", "Ezt a járművet nem tudod leparkolni!")
			end
		else
			exports.see_hud:showInfobox(sourcePlayer, "e", "Nem ülsz járműben!")
		end
	end)

addEvent("finishParkingProcess", true)
addEventHandler("finishParkingProcess", getRootElement(),
	function (vehicle)
		if isElement(vehicle) then
			local datas = {}
			local x, y, z = getElementPosition(vehicle)
			local rx, ry, rz = getElementRotation(vehicle)

			datas.park_position = x .. "," .. y .. "," .. z
			datas.park_rotation = rx .. "," .. ry .. "," .. rz
			datas.park_interior = getElementInterior(vehicle)
			datas.park_dimension = getElementDimension(vehicle)

			setVehicleRespawnPosition(vehicle, x, y, z, rx, ry, rz)
			setElementData(vehicle, "vehicle.parkPosition", {
				x, y, z,
				rx, ry, rz,
				datas.park_interior, datas.park_dimension
			}, false)

			exports.see_database:dbUpdate("vehicles", datas, {vehicleId = getElementData(vehicle, "vehicle.dbID")})

			if isElement(source) then
				exports.see_hud:showInfobox(source, "s", "Sikeresen leparkoltad a járművedet.")
			end
		end
	end)

addEvent("updateNitroLevel", true)
addEventHandler("updateNitroLevel", getRootElement(),
	function (vehicle, vehicleId, nitroLevel)
		if isElement(vehicle) then
			setElementData(vehicle, "vehicle.nitroLevel", nitroLevel)

			if vehicleId then
				dbExec(connection, "UPDATE vehicles SET tuningNitroLevel = ? WHERE vehicleId = ?", nitroLevel, vehicleId)
			end
		end
	end)

addEvent("updateVehicle", true)
addEventHandler("updateVehicle", getRootElement(),
	function (vehicle, vehicleId, saveProcess, fuel, distance, oil)
		if isElement(vehicle) then
			fuel = tonumber(fuel)
			distance = tonumber(distance)
			oil = tonumber(oil)

			setElementData(vehicle, "vehicle.fuel", fuel)
			setElementData(vehicle, "vehicle.distance", distance)
			--setElementData(vehicle, "lastOilChange", oil)

			if saveProcess or getElementData(vehicle, "vehicle.group") ~= 0 then
				exports.see_database:saveVehicle(vehicle)
			end
		end
	end)

addEvent("ä}€[[€ÄŁ", true)
addEventHandler("ä}€[[€ÄŁ", getRootElement(),
	function (vehicle)
		if isElement(vehicle) then
			setElementData(vehicle, "vehicle.fuel", 0)
			setElementData(vehicle, "vehicle.engine", 0)
			setVehicleEngineState(vehicle, false)
		end
	end)

addEvent("setVehicleHealthSync", true)
addEventHandler("setVehicleHealthSync", getRootElement(),
	function (vehicle, health)
		if isElement(vehicle) then
			setVehicleDamageProof(vehicle, false)
			setElementHealth(vehicle, health)
		end
	end)

addEvent("destroyVehicle", true)
addEventHandler("destroyVehicle", getRootElement(),
	function (theVeh, vehicleId, code)
		if code ~= "updatVeh" then 
			return iprint(source)
		end
		if theVeh and vehicleId then
			--iprint(source)
			dbExec(connection, "DELETE FROM vehicles WHERE vehicleId = ?", vehicleId)
			destroyElement(theVeh)

			if isElement(source) then
				exports.see_hud:showInfobox(source, "i", "Sikeresen bezúzattad a járművet!")
			end
		end
	end)

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		if vehiclesTable[source] then
			vehiclesTable[source] = nil
		end
	end)

addEventHandler("onVehicleExplode", getRootElement(),
	function ()
		if vehiclesTable[source] then
			setTimer(resetVehicle, 5000, 1, source)
		end
	end)

function resetVehicle(vehicle)
	if isElement(vehicle) then
		fixVehicle(vehicle)
		respawnVehicle(vehicle)
		setVehicleDamageProof(vehicle, false)
		setElementData(vehicle, "vehicle.engine", 0)

		local parkedData = getElementData(vehicle, "vehicle.parkPosition")

		if parkedData then
			setElementInterior(vehicle, parkedData[7])
			setElementDimension(vehicle, parkedData[8])
		end
	end
end

addEventHandler("onVehicleDamage", getRootElement(),
	function (loss)
		local health = getElementHealth(source)

		if health - loss <= 319 then
			setElementHealth(source, 320)
			setVehicleDamageProof(source, true)
			setVehicleEngineState(source, false)
			setElementData(source, "vehicle.engine", 0)

			local theDriver = getVehicleController(source)

			if isElement(theDriver) then
				exports.see_hud:showInfobox(theDriver, "e", "Lerobbant a járműved!")
			end
		else
			setVehicleDamageProof(source, false)
		end
	end)


addEventHandler("onElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "loggedIn" then
			if getElementData(source, dataName) then
				loadPlayerVehicles(source)
			end
		end
	end)

addEvent("loadPlayerVehicles", true)
addEventHandler("loadPlayerVehicles", getRootElement(),
	function ()
		if isElement(source) then
			loadPlayerVehicles(source)
		end
	end)

function loadPlayerVehicles(player)
	if isElement(player) then
		local characterId = tonumber(getElementData(player, "char.ID"))

		if characterId then
			return dbQuery(
				function (qh)
					local result = dbPoll(qh, 0)

					if result then
						for i = 1, #result do
							table.insert(queueTable, result[i])
						end

						if not isTimer(queueTimer) then
							queueTimer = setTimer(loadNextVehicle, 200, 1)
							--print(queueTimer)
							--print(inspect(loadNextVehicle))
						end
					end
				end,
			connection, "SELECT * FROM vehicles WHERE groupId = 0 AND impounded = 0 AND ownerId = ?", characterId)
		end

		return false
	end

	return false
end

function enableCollide(vehicle)
	if isElement(vehicle) then
		removeElementData(vehicle, "noCollide")
		setElementAlpha(vehicle, 255)
	end
end

function loadNextVehicle()
	local id = queueTable[1]

	if id then
		local veh = loadVehicle(queueTable[1].vehicleId, queueTable[1], true)

		if isElement(veh) then
			setTimer(enableCollide, 20000, 1, veh)
		end

		table.remove(queueTable, 1)

		if isTimer(queueTimer) then
			killTimer(queueTimer)
		end

		queueTimer = setTimer(loadNextVehicle, 200, 1)
	end
end

function loadGroupVehicles(qh)
	local result = dbPoll(qh, 0)

	if result then
		for i = 1, #result do
			local row = result[i]
			loadVehicle(row.vehicleId, row)
		end
	end
end

function loadVehicle(vehicleId, datas, noCollide)
	vehicleId = tonumber(vehicleId)

	if findVehElement(vehicleId) then
		return --print("veh already load")
	end

	if vehicleId and datas and type(datas) == "table" then
		local position = split(datas.last_position, ",")
		local rotation = split(datas.last_rotation, ",")

		if not isElement(vehiclesTable[vehicleId]) then
			local vehicleElement = createVehicle(datas.modelId, position[1], position[2], position[3], rotation[1], rotation[2], rotation[3])

			if not vehicleElement then
				return false
			else
				if noCollide then
					setElementData(vehicleElement, "noCollide", true)
					setElementAlpha(vehicleElement, 150)
				end

				local r1, g1, b1 = hexToRgb(datas.color1)
				local r2, g2, b2 = hexToRgb(datas.color2)
				local r3, g3, b3 = hexToRgb(datas.color3)
				local r4, g4, b4 = hexToRgb(datas.color4)

				setVehicleColor(vehicleElement, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4)

				local r, g, b = hexToRgb(datas.headLightColor)

				setVehicleHeadLightColor(vehicleElement, r, g, b)

				if not datas.plateText or utfLen(datas.plateText) == 0 then
					datas.plateText = encodeDatabaseId(vehicleId)
					dbExec(connection, "UPDATE vehicles SET plateText = ? WHERE vehicleId = ?", datas.plateText, vehicleId)
				end

				setVehiclePlateText(vehicleElement, datas.plateText)

				position = split(datas.park_position, ",")
				rotation = split(datas.park_rotation, ",")

				setVehicleRespawnPosition(vehicleElement, position[1], position[2], position[3], rotation[1], rotation[2], rotation[3])
				setElementData(vehicleElement, "vehicle.parkPosition", {position[1], position[2], position[3], rotation[1], rotation[2], rotation[3], datas.park_interior, datas.park_dimension}, false)

				setElementInterior(vehicleElement, datas.last_interior)
				setElementDimension(vehicleElement, datas.last_dimension)

				setVehicleFuelTankExplodable(vehicleElement, false)
				setElementHealth(vehicleElement, datas.health)

				setElementData(vehicleElement, "vehicle.dbID", vehicleId)
				setElementData(vehicleElement, "vehicle.owner", datas.ownerId)
				setElementData(vehicleElement, "vehicle.protect", datas.protected)
				setElementData(vehicleElement, "vehicle.group", datas.groupId)

				setElementData(vehicleElement, "vehicle.engine", datas.engine)
				setElementData(vehicleElement, "vehicle.locked", datas.locked)
				setElementData(vehicleElement, "vehicle.lights", datas.lights)
				setElementData(vehicleElement, "vehicle.handBrake", datas.handBrake == 1)

				setVehicleEngineState(vehicleElement, datas.engine == 1)
				setVehicleLocked(vehicleElement, datas.locked == 1)
				setVehicleOverrideLights(vehicleElement, datas.lights == 1 and 2 or 1)
				setElementFrozen(vehicleElement, datas.handBrake == 1)

				local maxFuel = exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(datas.modelId)
				local currentFuel = datas.fuel or maxFuel

				if currentFuel > maxFuel then
					currentFuel = maxFuel
				end

				setElementData(vehicleElement, "vehicle.fuel", currentFuel)
				setElementData(vehicleElement, "vehicle.maxFuel", maxFuel)
				setElementData(vehicleElement, "vehicle.distance", datas.distance)
				setElementData(vehicleElement, "vehicle.windowState", true)

				if datas.panelStates then
					for panel, state in ipairs(split(datas.panelStates, "/")) do
						setElementData(vehicleElement, "panelState:" .. panel-1, tonumber(state) or 0)
						setVehiclePanelState(vehicleElement, panel-1 , tonumber(state) or 0)
					end
				end

				if datas.doorStates then
					for door, state in ipairs(split(datas.doorStates, "/")) do
						setVehicleDoorState(vehicleElement, door-1 , tonumber(state) or 0)
					end
				end

				if datas.wheelStates then
					setVehicleWheelStates(vehicleElement, unpack(split(datas.wheelStates, "/")))
				end

				if datas.variant == 0 then
					setVehicleVariant(vehicleElement, 255, 255)
				else
					setVehicleVariant(vehicleElement, datas.variant - 1, 255)
					setElementData(vehicleElement, "vehicle.variant", datas.variant)
				end

				setElementData(vehicleElement, "vehicle.tuning.Engine", datas.tuningEngine)
				setElementData(vehicleElement, "vehicle.tuning.Turbo", datas.tuningTurbo)
				setElementData(vehicleElement, "vehicle.tuning.ECU", datas.tuningECU)
				setElementData(vehicleElement, "vehicle.tuning.Transmission", datas.tuningTransmission)
				setElementData(vehicleElement, "vehicle.tuning.Suspension", datas.tuningSuspension)
				setElementData(vehicleElement, "vehicle.tuning.Brakes", datas.tuningBrakes)
				setElementData(vehicleElement, "vehicle.tuning.Tires", datas.tuningTires)
				setElementData(vehicleElement, "vehicle.nitroLevel", datas.tuningNitroLevel)
				setElementData(vehicleElement, "vehicle.tuning.WeightReduction", datas.tuningWeightReduction)
				if tonumber(datas.backFire) and tonumber(datas.backFire) > 0 then
					setElementData(vehicleElement, "vehicle.backfire", tonumber(datas.backFire))
				else
					setElementData(vehicleElement, "vehicle.backfire", 0)
				end

				if datas.vehicleSpecialMod and datas.vehicleSpecialMod ~= 0 then
					setElementData(vehicleElement, "vehicleSpecialMod", tostring(datas.vehicleSpecialMod))
				end

				if datas.tuningOptical and #datas.tuningOptical > 0 then
					local currUpgradesTable = split(datas.tuningOptical, ",") or {}

					setElementData(vehicleElement, "vehicle.tuning.Optical", datas.tuningOptical)

					for k, upgrade in pairs(currUpgradesTable) do
						addVehicleUpgrade(vehicleElement, upgrade)
					end
				end

				setElementData(vehicleElement, "tuning.neon", datas.tuningNeon)
				setElementData(vehicleElement, "tuning.neon.state", 0)

				if datas.tuningAirRide ~= 0 then
					setElementData(vehicleElement, "vehicle.tuning.AirRide", datas.tuningAirRide)

					local memory1 = tonumber(gettok(datas.airRideMemory, 1, ","))
					local memory2 = tonumber(gettok(datas.airRideMemory, 2, ","))

					if memory1 ~= 8 then
						setElementData(vehicleElement, "airRideMemory1", memory1)
					end

					if memory2 ~= 8 then
						setElementData(vehicleElement, "airRideMemory2", memory2)
					end
				end

				if datas.tuningSpinners and #datas.tuningSpinners > 0 then
					setElementData(vehicleElement, "tuningSpinners", {unpack(split(datas.tuningSpinners, ","))})
				else
					setElementData(vehicleElement, "tuningSpinners", false)
				end

				if datas.tuningDoorType and #datas.tuningDoorType > 0 then
					setElementData(vehicleElement, "vehicle.tuning.DoorType", datas.tuningDoorType)
				end

				setElementData(vehicleElement, "vehicle.tuning.Paintjob", datas.tuningPaintjob)
				setElementData(vehicleElement, "vehicle.Tuning.Platina", datas.tuningPlatina)
				setElementData(vehicleElement, "vehicle.tuning.WheelPaintjob", datas.tuningWheelPaintjob)
				setElementData(vehicleElement, "vehicle.tuning.HeadLight", datas.tuningHeadLight)

				if datas.speedoColor then
					local colors = split(datas.speedoColor, ";")

					if validHexColor(colors[1]:gsub("#", "")) then
						local r, g, b = hexToRgb(colors[1])

						if r ~= 255 and g ~= 255 and b ~= 255 then
							setElementData(vehicleElement, "vehicle.speedoColor", {r, g, b})
						end
					end

					if validHexColor(colors[2]:gsub("#", "")) then
						local r, g, b = hexToRgb(colors[2])

						if r ~= 255 and g ~= 255 and b ~= 255 then
							setElementData(vehicleElement, "vehicle.speedoColor2", {r, g, b})
						end
					end
				end

				if datas.handlingFlags ~= 0 then
					setElementData(vehicleElement, "vehicle.handlingFlags", datas.handlingFlags)
				end

				if datas.modelFlags ~= 0 then
					setElementData(vehicleElement, "vehicle.modelFlags", datas.modelFlags)
				end

				if datas.tuningDriveType and #datas.tuningDriveType > 0 then
					setElementData(vehicleElement, "vehicle.tuning.DriveType", datas.tuningDriveType)
					setElementData(vehicleElement, "activeDriveType", datas.activeDriveType)
				end

				if datas.tuningSteeringLock ~= 0 then
					setElementData(vehicleElement, "vehicle.tuning.SteeringLock", datas.tuningSteeringLock)
				end

				if datas.traffipaxRadar ~= 0 then
					setElementData(vehicleElement, "traffipaxRadarInVehicle", datas.traffipaxRadar)
				end

				if datas.gpsNavigation ~= 0 then
					setElementData(vehicleElement, "vehicle.GPS", datas.gpsNavigation)
				end

				if datas.customHorn ~= 0 then
					setElementData(vehicleElement, "customHorn", datas.customHorn)
				end

				exports.see_tuning:makeTuning(vehicleElement)
				exports.see_items:loadItems(vehicleElement)

				vehiclesTable[vehicleElement] = true

				return vehicleElement
			end
		end

		return false
	end

	return false
end

function createPermVehicle(data)
	if data and type(data) == "table" then
		local modelId = tonumber(data.modelId)
		local groupId = tonumber(data.groupId) or 0
		local CustomID = data.CustomID or 0

		local sourcePlayer = false
		local targetPlayer = false

		if isElement(data.sourcePlayer) then
			sourcePlayer = data.sourcePlayer
		end

		if isElement(data.targetPlayer) then
			targetPlayer = data.targetPlayer
		end

		if not isElement(targetPlayer) then
			return false
		end

		local x, y, z = getElementPosition(targetPlayer)
		local rx, ry, rz = getElementRotation(targetPlayer)
		local interior = getElementInterior(targetPlayer)
		local dimension = getElementDimension(targetPlayer)

		if data.posX then
			x, y, z = data.posX, data.posY, data.posZ
			rx, ry, rz = data.rotX or 0, data.rotY or 0, data.rotZ or 0
			interior = data.interior or 0
			dimension = data.dimension or 0
		end

		local datas = {}

		datas.last_position = x .. "," .. y .. "," .. z
		datas.last_rotation = rx .. "," .. ry .. "," .. rz
		datas.last_interior = interior
		datas.last_dimension = dimension

		datas.park_position = datas.last_position
		datas.park_rotation = datas.last_rotation
		datas.park_interior = datas.last_interior
		datas.park_dimension = datas.last_dimension

		datas.ownerId = tonumber(getElementData(targetPlayer, "char.ID")) or 0
		datas.modelId = modelId
		datas.groupId = groupId

		datas.vehicleSpecialMod = CustomID

		datas.color1 = data.color1 or "7F7F7F"
		datas.color2 = data.color2 or "FFFFFF"

		if modelId == 453 or modelId == 454 then
			datas.customHorn = 8
		end

		if exports.see_database:dbInsert("vehicles", datas) then
			return dbQuery(
				function (qh)
					local result = dbPoll(qh, 0)[1]

					if result then
						if isElement(targetPlayer) then
							local vehicleElement = loadVehicle(result.vehicleId, result)

							if isElement(vehicleElement) then
								warpPedIntoVehicle(targetPlayer, vehicleElement)
								setCameraTarget(targetPlayer, targetPlayer)

								setElementData(vehicleElement, "noCollide", true)
								setElementAlpha(vehicleElement, 150)

								setTimer(
									function ()
										if isElement(vehicleElement) then
											removeElementData(vehicleElement, "noCollide")
											setElementAlpha(vehicleElement, 255)
										end
									end,
								15000, 1)
							end

							exports.see_items:giveItem(targetPlayer, 1, 1, false, result.vehicleId)
						end

						if isElement(sourcePlayer) then
							outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen létrehoztál egy járművet. #32b3ef(" .. result.vehicleId .. ")", sourcePlayer, 0, 0, 0, true)
						end
					end
				end,
			connection, "SELECT * FROM vehicles WHERE vehicleId = LAST_INSERT_ID()")
		end
	end

	return false
end

function findVehElement(dbID)
	local findVeh = false

	for k, v in ipairs(getElementsByType("vehicle")) do

		if getElementData(v, "vehicle.dbID") == dbID then
			findVeh = v
			break
		end
	end

	return findVeh
end

addCommandHandler("makeveh",
	function (sourcePlayer, commandName, modelId, targetPlayer, groupId, color1, color2)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			groupId = tonumber(groupId) or 0
			color1 = color1 or "7F7F7F"
			color2 = color2 or "FFFFFF"

			if not (modelId and targetPlayer and groupId and (color1 and validHexColor(color1)) and (color2 and validHexColor(color2))) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Model Név / ID] [Játékos Név / ID] [Frakció ID < 0 = nincs >] [ < Szín 1 | Szín 2 > ]", sourcePlayer, 0, 0, 0, true)
				outputChatBox("#3d7abc[Használat]: #ffffffA színeket HEX formátumban kell megadni, például: 7CC576", sourcePlayer, 0, 0, 0, true)
			else
				if tonumber(modelId) then
					modelId = tonumber(modelId)
					CustomIdData = 0

					if modelId < 400 or modelId > 611 then
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott jármű model érvénytelen! (400-611)", sourcePlayer, 0, 0, 0, true)
						return
					end
				elseif type(modelId) == "string" and exports.see_infinity:getVehicleCustomName(modelId) then
					CustomIdData = modelId
					modelId = exports.see_infinity:GetVehicleDefaultID(modelId)
				else
					modelId = getVehicleModelFromName(string.lower(modelId))
					CustomIdData = 0
					if not modelId then
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott jármű model érvénytelen!", sourcePlayer, 0, 0, 0, true)
						return
					end
				end

				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local groupData = false

					if groupId > 0 then
						local availableGroups = exports.see_groups:getGroups()

						if not availableGroups[groupId] then
							outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott frakció nem létezik!", sourcePlayer, 0, 0, 0, true)
							return
						end

						groupData = availableGroups[groupId]
					end

					if groupData then
						if not exports.see_groups:isPlayerInGroup(targetPlayer, groupId) then
							outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem tagja a kiválasztott frakciónak!", sourcePlayer, 0, 0, 0, true)
							return
						end
					end

					createPermVehicle({
						modelId = modelId,
						groupId = groupId,
						color1 = color1,
						color2 = color2,
						targetPlayer = targetPlayer,
						sourcePlayer = sourcePlayer,
						CustomID = CustomIdData
					})

					exports.see_logs:logCommand(sourcePlayer, commandName, {modelId, ownerId, groupId})
				end
			end
		end
	end, false, false)

addCommandHandler("delveh",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", sourcePlayer, 0, 0, 0, true)
			else
				local vehicleElement = false

				for k, v in pairs(getElementsByType("vehicle")) do
					if vehicleId == getElementData(v, "vehicle.dbID") then
						vehicleElement = v
						break
					end
				end

				if isElement(vehicleElement) then
					vehiclesTable[vehicleElement] = nil

					dbExec(connection, "DELETE FROM vehicles WHERE vehicleId = ?", vehicleId)
					dbExec(connection, "DELETE FROM items WHERE ownerType = 'vehicle' AND ownerId = ?", vehicleId)

					destroyElement(vehicleElement)

					outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen kitörölted a kiválasztott járművet. #32b3ef(" .. vehicleId .. ")", sourcePlayer, 0, 0, 0, true)

					exports.see_logs:logCommand(sourcePlayer, commandName, {vehicleId})
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott jármű nem található!", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end)

addCommandHandler("getvehid",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					if isElement(pedveh) then
						local vehicleId = getElementData(pedveh, "vehicle.dbID")

						if vehicleId then
							outputChatBox("#3d7abc[StrongMTA]: #ffffffA kiválasztott jármű azonosítója #3d7abc" .. vehicleId .. ".", sourcePlayer, 0, 0, 0, true)
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott jármű egy ideiglenes jármű.", sourcePlayer, 0, 0, 0, true)
						end
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", sourcePlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end)

addCommandHandler("getvehowner",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", sourcePlayer, 0, 0, 0, true)
			else
				dbQuery(
					function (qh)
						local result, rows = dbPoll(qh, 0)

						if result and rows > 0 then
							local row = result[1]
							outputChatBox("#3d7abc[StrongMTA]: #ffffffA kiválasztott jármű tulajdonosa: #3d7abc" .. row.name .. " #ffffff(Karakter ID: #32b3ef" .. row.characterId .. " #ffffff| #32b3efAccountID: " .. row.accountId .. "#ffffff)", sourcePlayer, 0, 0, 0, true)
						else
							outputChatBox("#3d7abc[StrongMTA]: #ffffffA kiválasztott járműnek nem létezik, nincs tulajdonosa vagy egy frakció jármű.", sourcePlayer, 0, 0, 0, true)
						end
					end,
				connection, "SELECT characters.name, characters.characterId, characters.accountId FROM characters LEFT JOIN vehicles ON vehicles.ownerId = characters.characterId WHERE vehicles.vehicleId = ? LIMIT 1", vehicleId)
			end
		end
	end)

addCommandHandler("setvehcustom", 
	function(sourcePlayer, commandName, targetPlayer, vehID)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			if not (targetPlayer and vehID) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [custom veh id]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					if isElement(pedveh) then
						local vehicleId = getElementData(pedveh, "vehicle.dbID")

						if vehicleId then
							local characterId = getElementData(sourcePlayer, "char.ID") or 0

							setElementData(pedveh, "vehicleSpecialMod", vehID)

							outputChatBox("#3d7abc[StrongMTA]: #ffffffA jármű sikeresen egyedi model lett.", sourcePlayer, 0, 0, 0, true)
							dbExec(connection, "UPDATE vehicles SET vehicleSpecialMod = ? WHERE vehicleId = ?", vehID, vehicleId)
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffIdeiglenes járművet nem alakíthatsz egyedi járművé.", sourcePlayer, 0, 0, 0, true)
						end
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", sourcePlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end
)

addCommandHandler("setvehgroup",
	function (sourcePlayer, commandName, targetPlayer, groupId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			groupId = tonumber(groupId)

			if not (targetPlayer and groupId) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Csoport ID (0 = kivétel)]", sourcePlayer, 0, 0, 0, true)
				outputChatBox("#3d7abc[Használat]: #ffffffA csoportból való kivétel esetén, a jármű a kiválasztott játékos tulajdonába kerül.", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					if isElement(pedveh) then
						local vehicleId = getElementData(pedveh, "vehicle.dbID")

						if vehicleId then
							if groupId == 0 then
								local characterId = getElementData(sourcePlayer, "char.ID") or 0

								setElementData(pedveh, "vehicle.group", 0)
								setElementData(pedveh, "vehicle.owner", characterId)

								outputChatBox("#3d7abc[StrongMTA]: #ffffffA jármű sikeresen eltávolítva a kiválasztott csoportból.", sourcePlayer, 0, 0, 0, true)
								dbExec(connection, "UPDATE vehicles SET ownerId = ?, groupId = ? WHERE vehicleId = ?", characterId, 0, vehicleId)
								--print(characterId .. " 0 " .. vehicleId .. "")
							else
								local group = exports.see_groups:getGroupData(groupId)

								if group then
									setElementData(pedveh, "vehicle.group", groupId)
									setElementData(pedveh, "vehicle.owner", 0)

									outputChatBox("#3d7abc[StrongMTA]: #ffffffA jármű sikeresen hozzáadva a kiválasztott csoporthoz. #32b3ef(" .. group.name .. ")", sourcePlayer, 0, 0, 0, true)
									dbExec(connection, "UPDATE vehicles SET ownerId = ?, groupId = ? WHERE vehicleId = ?", 0, groupId, vehicleId)
								else
									outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott csoport nem létezik.", sourcePlayer, 0, 0, 0, true)
								end
							end
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffIdeiglenes járművet nem alakíthatsz csoport járművé.", sourcePlayer, 0, 0, 0, true)
						end
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", sourcePlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end)

addCommandHandler("getvehgroup",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			if not targetPlayer then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					if isElement(pedveh) then
						local vehicleId = getElementData(pedveh, "vehicle.dbID")

						if vehicleId then
							local groupId = getElementData(pedveh, "vehicle.group") or 0
							local group = exports.see_groups:getGroupData(groupId)

							if group then
								outputChatBox("#3d7abc[StrongMTA]: #ffffffA kiválasztott jármű csoportja #3d7abc" .. group.name .. ".", sourcePlayer, 0, 0, 0, true)
							else
								outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott jármű nem tartozik csoporthoz.", sourcePlayer, 0, 0, 0, true)
							end
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott jármű egy ideiglenes jármű.", sourcePlayer, 0, 0, 0, true)
						end
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", sourcePlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end)

function hexToRgb(color)
	if color and string.len(color) > 0 then
		color = color:gsub("#", "")
		return tonumber("0x" .. color:sub(1, 2)), tonumber("0x" .. color:sub(3, 4)), tonumber("0x" .. color:sub(5, 6))
	else
		return 255, 255, 255
	end
end

function validHexColor(color)
	return color:match("^%x%x%x%x%x%x$")
end


local checkPlayer = {}
local checkPlayerRemove = {}

addCommandHandler("protect",
	function(sourcePlayer, commandName, isCancel)
		if getElementData(sourcePlayer, "loggedIn") then
			if isElement(sourcePlayer) then
				if getPedOccupiedVehicle(sourcePlayer) then
					local playerVehicle = getPedOccupiedVehicle(sourcePlayer)

					if isCancel then
						if checkPlayer[sourcePlayer] and isCancel == "cancel" then
							outputChatBox("#d75959[StrongMTA]: #ffffffSikeresen elutasítottad!", sourcePlayer, 0, 0, 0, true)
							checkPlayer[sourcePlayer] = nil
						elseif not checkPlayer[sourcePlayer] and isCancel == "remove" and not checkPlayerRemove[sourcePlayer] and getElementData(playerVehicle, "vehicle.protect") == 1 then
							if getElementData(playerVehicle, "vehicle.protect") == 1 then
								outputChatBox("#d75959[StrongMTA]: #ffffffA protect törléséhez írd be mégegyszer! (/protect remove)", sourcePlayer, 0, 0, 0, true)
								checkPlayerRemove[sourcePlayer] = true
							end
						elseif checkPlayerRemove[sourcePlayer] then
							if getElementData(playerVehicle, "vehicle.owner") == getElementData(sourcePlayer, "char.ID") then
								setElementData(playerVehicle, "vehicle.protect", 0)
								outputChatBox("#d75959[StrongMTA]: #ffffffSikeresen törölted a protectet!", sourcePlayer, 0, 0, 0, true)
								checkPlayerRemove[sourcePlayer] = nil
								dbExec(connection, "UPDATE vehicles SET protected = ? WHERE vehicleId = ?", getElementData(playerVehicle, "vehicle.protect"), getElementData(playerVehicle, "vehicle.dbID"))
							else
								outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott autó nem a te tulajdonodban van!", sourcePlayer, 0, 0, 0, true)
								checkPlayerRemove[sourcePlayer] = nil
							end
						end
						return
					end

					if isElement(playerVehicle) then
						if not getElementData(playerVehicle, "vehicle.protect") then
							setElementData(playerVehicle, "vehicle.protect", 0)
						end
						if getElementData(playerVehicle, "vehicle.protect") == 1 then
							outputChatBox("#d75959[StrongMTA]: #ffffffEz az autó már le van védve! #d75959(Törléshez: /protect remove)", sourcePlayer, 0, 0, 0, true)
						else
							if checkPlayer[sourcePlayer] then
								if (getElementData(sourcePlayer, "acc.premiumPoints") - 20000) > 0 then
									checkPlayer[sourcePlayer] = nil
									setElementData(playerVehicle, "vehicle.protect", 1)
									setElementData(sourcePlayer, "acc.premiumPoints", getElementData(sourcePlayer, "acc.premiumPoints") - 20000)
									outputChatBox("#d75959[StrongMTA]: #ffffffSikeresen megvásároltad!", sourcePlayer, 0, 0, 0, true)
									dbExec(connection, "UPDATE vehicles SET protected = ? WHERE vehicleId = ?", getElementData(playerVehicle, "vehicle.protect"), getElementData(playerVehicle, "vehicle.dbID"))
								else
									outputChatBox("#d75959[StrongMTA]: #ffffffNincs elegendő prémiumpontod!", sourcePlayer, 0, 0, 0, true)
								end
							else
								checkPlayer[sourcePlayer] = true
								outputChatBox("#d75959[StrongMTA]: #ffffffA protect #3d7abc20.000 PP#ffffff-be kerül. Biztosan rászeretnéd rakni?", sourcePlayer, 0, 0, 0, true)
								outputChatBox("#d75959[StrongMTA]: #ffffffElfogadás: #3d7abc/protect #ffffff| Elutasítás: #3d7abc/protect cancel", sourcePlayer, 0, 0, 0, true)
							end
						end
					end
				else
					exports.see_accounts:showInfo(sourcePlayer, "e", "Nem ülsz kocsiban!")
				end
			end	
		end
	end
)