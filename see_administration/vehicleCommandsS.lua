addEvent("logAdminPaintjob", true)
addEventHandler("logAdminPaintjob", getRootElement(),
	function (vehicleId, commandName, paintjobId)
		if vehicleId and commandName and paintjobId then
			exports.see_logs:logCommand(client, commandName, {vehicleId, paintjobId})
		end
	end)

addCommandHandler("unflip",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")

						local rx, ry, rz = getElementRotation(theVehicle)

						if rx > 90 and rx < 270 then
							setElementRotation(theVehicle, 0, 0, rz + 180)
						else
							setElementRotation(theVehicle, 0, 0, rz)
						end

						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffvisszaforgatta a járműved.", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen visszaforgattad a kiválasztott játékos járművét. #32b3ef(" .. targetName .. ")", 61, 122, 188)

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId})
							setElementData(sourcePlayer, "acc.unflip", (getElementData(sourcePlayer, "acc.unflip") or 0)+1)
							dbExec(connection, "UPDATE accounts SET statUnflip = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.unflip"), getElementData(sourcePlayer, "char.accID"))
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("oilveh",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")

						setElementData(theVehicle, "lastOilChange", 0)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen kicserélted a kiválasztott jármű olaját.", 61, 122, 188)

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId})
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("setvehoil",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			value = tonumber(value) or 515

			if not (targetPlayer and value and value >= 0 and value <= 10000) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Olajcsere (0 km - 10 000 km)]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")
						local lastOilChange = getElementData(theVehicle, "lastOilChange") or 0

						setElementData(theVehicle, "lastOilChange", -value)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen megváltoztattad a kiválasztott jármű következő olajcseréjének idejét.", 61, 122, 188)

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId, lastOilChange, -value})
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("fuelveh",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")

						local fuelTankSize = exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(getElementModel(theVehicle))
						local currentFuelLevel = getElementData(theVehicle, "vehicle.fuel")

						setElementData(theVehicle, "vehicle.fuel", fuelTankSize)

						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegtankolta a járműved.", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen megtankoltad a kiválasztott járművét.", 61, 122, 188)

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId})
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("setvehfuel",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			value = tonumber(value)

			if not (targetPlayer and value and value >= 0 and value <= 100) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Üzemanyagszint (0-100)]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")

						local fuelTankSize = exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(getElementModel(theVehicle))
						local currentFuelLevel = getElementData(theVehicle, "vehicle.fuel")
						local newFuelLevel = reMap(value, 0, 100, 0, fuelTankSize)

						if newFuelLevel > fuelTankSize then
							newFuelLevel = fuelTankSize
						end

						setElementData(theVehicle, "vehicle.fuel", newFuelLevel)

						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta a járműved üzemanyagszintjét. #32b3ef(" .. value .. "%)", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen megváltoztattad a kiválasztott jármű üzemanyagszintjét.", 61, 122, 188)

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId, currentFuelLevel, newFuelLevel})
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("setvehhp",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			value = tonumber(value)

			if not (targetPlayer and value and value >= 0 and value <= 100) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Életerő (0-100)]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")
						local currHealth = getElementHealth(theVehicle)
						local newHealth = reMap(value, 0, 100, 0, 1000)

						if newHealth < 320 then
							newHealth = 320
						end

						setElementHealth(theVehicle, newHealth)

						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta a járműved életerejét. #32b3ef(" .. value .. "%)", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen megváltoztattad a kiválasztott jármű életerejét.", 61, 122, 188)

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId, currHealth, newHealth})
							setElementData(sourcePlayer, "acc.vehiclehp", (getElementData(sourcePlayer, "acc.vehiclehp") or 0)+1)
							dbExec(connection, "UPDATE accounts SET statVehicleHP = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.vehiclehp"), getElementData(sourcePlayer, "char.accID"))
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("rtc",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", 255, 150, 0)
			else
				local targetVehicle = false

				for k, v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v, "vehicle.dbID") == vehicleId then
						targetVehicle = v
						break
					end
				end

				if isElement(targetVehicle) then
					respawnVehicle(targetVehicle)

					local parkedData = getElementData(targetVehicle, "vehicle.parkPosition")

					if parkedData then
						setElementInterior(targetVehicle, parkedData[7])
						setElementDimension(targetVehicle, parkedData[8])
					end

					setElementData(targetVehicle, "vehicle.engine", 0)
					setVehicleEngineState(targetVehicle, false)

					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen helyreállítottad a kiválasztott járművet.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {vehicleId})
					setElementData(sourcePlayer, "acc.rtc", (getElementData(sourcePlayer, "acc.rtc") or 0)+1)
					dbExec(connection, "UPDATE accounts SET statRTC = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.rtc"), getElementData(sourcePlayer, "char.accID"))
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott jármű nem található.", 215, 89, 89)
				end
			end
		end
	end 
)

addCommandHandler("rtc2",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", 255, 150, 0)
			else
				local targetVehicle = false

				for k, v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v, "vehicle.dbID") == vehicleId then
						targetVehicle = v
						break
					end
				end

				if isElement(targetVehicle) then
					respawnVehicle(targetVehicle)
					--setElementDimension(targetVehicle, 800)

					local parkedData = getElementData(targetVehicle, "vehicle.parkPosition")

					if parkedData then
						setElementInterior(targetVehicle, parkedData[7])
						--setElementDimension(targetVehicle, parkedData[8])
						setElementDimension(targetVehicle, 800)
					end

					setElementData(targetVehicle, "vehicle.engine", 0)
					setVehicleEngineState(targetVehicle, false)

					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen áthelyezted a kiválasztott járművet.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {vehicleId})
					setElementData(sourcePlayer, "acc.rtc2", (getElementData(sourcePlayer, "acc.rtc2") or 0)+1)
					dbExec(connection, "UPDATE accounts SET statRTC2 = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.rtc2"), getElementData(sourcePlayer, "char.accID"))
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott jármű nem található.", 215, 89, 89)
				end
			end
		end
	end 
)

addCommandHandler("gotoveh",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", 255, 150, 0)
			else
				local targetVehicle = false

				for k, v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v, "vehicle.dbID") == vehicleId then
						targetVehicle = v
						break
					end
				end

				if isElement(targetVehicle) then
					local x, y, z = getElementPosition(targetVehicle)
					local rx, ry, rz = getVehicleRotation(targetVehicle)

					x = x + math.cos(math.rad(rz)) * 2
					y = y + math.sin(math.rad(rz)) * 2

					setElementPosition(sourcePlayer, x, y, z)
					setPedRotation(sourcePlayer, rz)
					setElementInterior(sourcePlayer, getElementInterior(targetVehicle))
					setElementDimension(sourcePlayer, getElementDimension(targetVehicle))

					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffElteleportáltál a kiválasztott járműhöz.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {vehicleId})
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott jármű nem található.", 215, 89, 89)
				end
			end
		end
	end)

addCommandHandler("getveh",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", 255, 150, 0)
			else
				local targetVehicle = false

				for k, v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v, "vehicle.dbID") == vehicleId then
						targetVehicle = v
						break
					end
				end

				if isElement(targetVehicle) then
					local x, y, z = getElementPosition(sourcePlayer)
					local rotation = getPedRotation(sourcePlayer)

					x = x + math.cos(math.rad(rotation)) * 2
					y = y + math.sin(math.rad(rotation)) * 2

					if getElementHealth(targetVehicle) == 0 then
						spawnVehicle(targetVehicle, x, y, z, 0, 0, rotation)
					else
						setElementPosition(targetVehicle, x, y, z)
						setVehicleRotation(targetVehicle, 0, 0, rotation)
					end
					
					setElementInterior(targetVehicle, getElementInterior(sourcePlayer))
					setElementDimension(targetVehicle, getElementDimension(sourcePlayer))

					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffMagadhoz teleportáltad a kiválasztott járművet.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {vehicleId})
					setElementData(sourcePlayer, "acc.getveh", (getElementData(sourcePlayer, "acc.getveh") or 0)+1)
					dbExec(connection, "UPDATE accounts SET statGetveh = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.getveh"), getElementData(sourcePlayer, "char.accID"))
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott jármű nem található.", 215, 89, 89)
				end
			end
		end
	end)

addCommandHandler("blowveh",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						local adminRank = getPlayerAdminTitle(sourcePlayer)
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")

						blowVehicle(theVehicle)

						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #fffffffelrobbantotta a járműved.", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen felrobbantottad #32b3ef" .. targetName .. " #ffffffjárművét.", 61, 122, 188)
						showAdminLog(adminRank .. " " .. adminName .. " felrobbantotta #32b3ef" .. targetName .. " #ffffffjárművét.")

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId})
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("fixveh",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						local adminRank = getPlayerAdminTitle(sourcePlayer)
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")

						fixVehicle(theVehicle)
						setVehicleDamageProof(theVehicle, false)

						for i = 0, 6 do
							removeElementData(theVehicle, "panelState:" .. i)
						end

						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegjavította a járműved.", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen megjavítottad #32b3ef" .. targetName .. " #ffffffjárművét.", 61, 122, 188)
						showAdminLog(adminRank .. " " .. adminName .. " megjavította #32b3ef" .. targetName .. " #ffffffjárművét.")

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId})
							setElementData(sourcePlayer, "acc.fix", (getElementData(sourcePlayer, "acc.fix") or 0)+1)
							dbExec(connection, "UPDATE accounts SET statFix = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.fix"), getElementData(sourcePlayer, "char.accID"))
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("fixvehbody",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						local vehicleId = getElementData(theVehicle, "vehicle.dbID")
						local currhealth = getElementHealth(theVehicle)
					
						fixVehicle(theVehicle)
						setElementHealth(theVehicle, currhealth)

						for i = 0, 6 do
							removeElementData(theVehicle, "panelState:" .. i)
						end

						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegjavította a járműved külsejét.", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen megjavítottad #32b3ef" .. targetName .. " #ffffffjárművének külsejét.", 61, 122, 188)

						if tonumber(vehicleId) then
							exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, vehicleId})
						end
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nem ül járműben.", 215, 89, 89)
					end
				end
			end
		end
	end)

addCommandHandler("gotojobcar",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", 255, 150, 0)
			else
				local targetVehicle = false

				for k, v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v, "jobVehicleID") == vehicleId then
						targetVehicle = v
						break
					end
				end

				if isElement(targetVehicle) then
					local x, y, z = getElementPosition(targetVehicle)
					local rx, ry, rz = getVehicleRotation(targetVehicle)

					x = x + math.cos(math.rad(rz)) * 2
					y = y + math.sin(math.rad(rz)) * 2

					setElementPosition(sourcePlayer, x, y, z)
					setPedRotation(sourcePlayer, rz)
					setElementInterior(sourcePlayer, getElementInterior(targetVehicle))
					setElementDimension(sourcePlayer, getElementDimension(targetVehicle))

					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffElteleportáltál a kiválasztott munkajárműhöz.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {vehicleId})
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott munkajármű nem található.", 215, 89, 89)
				end
			end
		end
	end)

addCommandHandler("getjobcar",
	function (sourcePlayer, commandName, vehicleId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			vehicleId = tonumber(vehicleId)

			if not vehicleId then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Jármű ID]", 255, 150, 0)
			else
				local targetVehicle = false

				for k, v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v, "jobVehicleID") == vehicleId then
						targetVehicle = v
						break
					end
				end

				if isElement(targetVehicle) then
					local x, y, z = getElementPosition(sourcePlayer)
					local rotation = getPedRotation(sourcePlayer)

					x = x + math.cos(math.rad(rotation)) * 2
					y = y + math.sin(math.rad(rotation)) * 2

					if getElementHealth(targetVehicle) == 0 then
						spawnVehicle(targetVehicle, x, y, z, 0, 0, rotation)
					else
						setElementPosition(targetVehicle, x, y, z)
						setVehicleRotation(targetVehicle, 0, 0, rotation)
					end
					
					setElementInterior(targetVehicle, getElementInterior(sourcePlayer))
					setElementDimension(targetVehicle, getElementDimension(sourcePlayer))

					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffMagadhoz teleportáltad a kiválasztott munkajárművet.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {vehicleId})
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott munkajármű nem található.", 215, 89, 89)
				end
			end
		end
	end)