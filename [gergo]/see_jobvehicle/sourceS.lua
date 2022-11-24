local CARRIER_DEFAULT_POSITION = {-0.35643125092904, -3.7341625987995, 0.012808443771302, 10.887329101563}
local YANKEE_VARIANTS = {
	[1] = {239, 174, 24}, -- Burger Shot
	[2] = {255, 255, 255}, -- Globe Oil
	[3] = {255, 255, 255}, -- Xoomer
	[4] = {2, 163, 112}, -- 24/7 Supermarket
	[5] = {255, 255, 255}, -- Rockshore
	[6] = {236, 225, 115}, -- Cluckin Bell
}

local jobVehicles = {}
local destroyTimer = {}

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("player")) do
			removeElementData(v, "jobVehicle")
		end
	end)

addEventHandler("onPlayerVehicleEnter", getRootElement(),
	function (vehicle)
		local vehicleId = getElementData(vehicle, "jobVehicleID")
		
		if vehicleId then
			local spawnerName = getElementData(vehicle, "jobSpawnerName")
			local myName = getElementData(source, "visibleName")

			if spawnerName == myName then
				if isTimer(destroyTimer[vehicle]) then
					killTimer(destroyTimer[vehicle])
				end

				destroyTimer[vehicle] = nil

				exports.see_hud:showInfobox(source, "i", "Beszálltál a munkajárművedbe.")
			end
		end
	end)

addEventHandler("onPlayerVehicleExit", getRootElement(),
	function (vehicle, seat, jacker, forcedByScript)
		if not forcedByScript then
			local vehicleId = getElementData(vehicle, "jobVehicleID")
			
			if vehicleId then
				local spawnerName = getElementData(vehicle, "jobSpawnerName")
				local myName = getElementData(source, "visibleName")

				if spawnerName == myName then
					if isTimer(destroyTimer[vehicle]) then
						killTimer(destroyTimer[vehicle])
					end

					destroyTimer[vehicle] = setTimer(
						function (thePlayer, veh)
							if isElement(thePlayer) then
								removeElementData(thePlayer, "jobVehicle")
							end

							jobVehicles[thePlayer] = nil

							if isElement(veh) then
								destroyElement(veh)
							end

							destroyTimer[veh] = nil
						end,
					1000 * 60 * 15, 1, source, vehicle)

					exports.see_hud:showInfobox(source, "i", "Kiszálltál a munkajárművedből. Ha nem szállsz vissza, a jármű 15 percen belül törlődik!")
				end
			end
		end
	end)

addEvent("deleteJobVehicle", true)
addEventHandler("deleteJobVehicle", getRootElement(),
	function ()
		if source then
			for k, v in pairs(jobVehicles) do
				if v == source then
					if isElement(k) then
						removeElementData(k, "jobVehicle")
					end

					if isTimer(destroyTimer[v]) then
						killTimer(destroyTimer[v])
					end

					destroyTimer[v] = nil

					if isElement(v) then
						destroyElement(v)
					end

					jobVehicles[k] = nil

					break
				end
			end
		end
	end)

addEvent("&ÄäÄí{@ÄÍ&ŁÄ", true)
addEventHandler("&ÄäÄí{@ÄÍ&ŁÄ", getRootElement(),
	function (modelId, colorCode)
		if isElement(source) and client and client == source then
			local playerPosX, playerPosY, playerPosZ = getElementPosition(source)
			local playerRotX, playerRotY, playerRotZ = getElementRotation(source)

			modelId = tonumber(modelId)

			if not modelId then
				exports.see_hud:showInfobox(source, "i", "Sikeresen leadtad a munkajárműved.")

				if isElement(jobVehicles[source]) then
					destroyElement(jobVehicles[source])
				end

				jobVehicles[source] = nil
			elseif isElement(jobVehicles[source]) then
				exports.see_hud:showInfobox(source, "e", "Már van egy munkajárműved!")
			else
				local characterJob = getElementData(source, "char.Job") or 0

				if characterJob > 0 then
					local vehicleElement = createVehicle(modelId, playerPosX, playerPosY, playerPosZ, playerRotX, playerRotY, playerRotZ)

					if isElement(vehicleElement) then
						local vehicleId = 0

						for k, v in pairs(getElementsByType("vehicle")) do
							if getElementData(v, "jobVehicleID") then
								vehicleId = vehicleId + 1
							end
						end

						vehicleId = vehicleId + 1

						if vehicleId then
							triggerClientEvent("ghostJobCar", source, vehicleElement)

							exports.see_tuning:applyHandling(vehicleElement)

							setElementData(vehicleElement, "vehicle.engine", 0)
							setElementData(vehicleElement, "vehicle.lights", 0)
							setElementData(vehicleElement, "vehicle.locked", 0)
							setElementData(vehicleElement, "vehicle.windowState", true)
							setElementData(vehicleElement, "vehicle.fuel", exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(modelId))
							setElementData(vehicleElement, "vehicle.GPS", 1)
							setElementData(vehicleElement, "vehicle.jobID", characterJob)

							setVehicleEngineState(vehicleElement, false)
							setVehicleOverrideLights(vehicleElement, 1)
							setVehicleLocked(vehicleElement, false)
							setVehicleFuelTankExplodable(vehicleElement, false)
							setVehiclePlateText(vehicleElement, "JOB-" .. vehicleId)

							if modelId == 456 then
								local variant = math.random(1, #YANKEE_VARIANTS)
								local color = YANKEE_VARIANTS[variant]

								setVehicleVariant(vehicleElement, variant - 1, 255)
								setVehicleColor(vehicleElement, color[1], color[2], color[3], color[1], color[2], color[3])

								setElementData(vehicleElement, "carrierPlacedInTruck", {unpack(CARRIER_DEFAULT_POSITION)})
								setElementData(vehicleElement, "yankeeState", "close")
							else
								local r, g, b = hexToRgb(colorCode)

								if r and g and b then
									setVehicleColor(vehicleElement, r, g, b, r, g, b)
								else
									setVehicleColor(vehicleElement, 255, 255, 255, 255, 255, 255)
								end
							end

							setElementData(vehicleElement, "jobVehicleID", vehicleId)
							setElementData(vehicleElement, "jobSpawner", getElementData(source, "playerID"))
							setElementData(vehicleElement, "jobSpawnerName", getElementData(source, "visibleName"))
							
							setElementData(source, "jobVehicle", vehicleElement)
							outputChatBox("#dc143c[StrongMTA]: #ffffffSikeresen lehívtál egy munkajárművet. Amennyiben le szeretnéd adni, hozd ide.", source, 0, 0, 0, true)

							setTimer(warpPedIntoVehicle, 3000, 1, source, vehicleElement)
							jobVehicles[source] = vehicleElement
						end
					end
				end
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if jobVehicles[source] then
			local veh = jobVehicles[source]

			if isTimer(destroyTimer[veh]) then
				killTimer(destroyTimer[veh])
			end

			destroyTimer[veh] = nil

			if isElement(jobVehicles[source]) then
				destroyElement(jobVehicles[source])
			end

			jobVehicles[source] = nil
		end
	end)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "char.Job" then
			local dataValue = getElementData(source, dataName) or 0

			if dataValue == 0 then
				if jobVehicles[source] then
					local veh = jobVehicles[source]

					if isElement(source) then
						removeElementData(source, "jobVehicle")
					end

					if isTimer(destroyTimer[veh]) then
						killTimer(destroyTimer[veh])
					end

					destroyTimer[veh] = nil

					if isElement(jobVehicles[source]) then
						destroyElement(jobVehicles[source])
					end

					jobVehicles[source] = nil
				end
			end
		end
	end
)

function hexToRgb(color)
	if color and string.len(color) > 0 then
		color = color:gsub("#", "")
		return tonumber("0x" .. color:sub(1, 2)), tonumber("0x" .. color:sub(3, 4)), tonumber("0x" .. color:sub(5, 6))
	else
		return 255, 255, 255
	end
end