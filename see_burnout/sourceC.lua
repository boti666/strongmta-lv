local tiresHeatLevels = {}
local handleBurnout = false

local currentVehicle = false
local vehicleDriveType = "rwd"

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (enterPlayer, seatIndex)
		if enterPlayer == localPlayer then
			if seatIndex == 0 then
				currentVehicle = source
				vehicleDriveType = getVehicleHandling(source).driveType

				if not handleBurnout then
					handleBurnout = true
					addEventHandler("onClientPreRender", getRootElement(), burnoutRender)
				end
			end
		end
	end
)

addEventHandler("onClientVehicleExit", getRootElement(),
	function (exitPlayer, seatIndex)
		if exitPlayer == localPlayer then
			if seatIndex == 0 then
				currentVehicle = false

				if handleBurnout then
					handleBurnout = false
					removeEventHandler("onClientPreRender", getRootElement(), burnoutRender)
				end
			end
		end
	end
)

addEventHandler("onClientPlayerSpawn", localPlayer,
	function ()
		currentVehicle = false

		if handleBurnout then
			handleBurnout = false
			removeEventHandler("onClientPreRender", getRootElement(), burnoutRender)
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if source == currentVehicle then
			currentVehicle = false

			if handleBurnout then
				handleBurnout = false
				removeEventHandler("onClientPreRender", getRootElement(), burnoutRender)
			end
		end
	end
)

function burnoutRender(deltaTime)
	if currentVehicle then
		if getVehicleEngineState(currentVehicle) then
			if not isPedInVehicle(localPlayer) then
				currentVehicle = false
				removeEventHandler("onClientPreRender", getRootElement(), burnoutRender)
				handleBurnout = false
			end

			local accelerate = false
			local brake_reverse = false
			local handbrake = false

			for k in pairs(getBoundKeys("accelerate")) do
				if getKeyState(k) then
					accelerate = true
				end
			end

			if vehicleDriveType == "awd" or vehicleDriveType == "rwd" then
				for k in pairs(getBoundKeys("brake_reverse")) do
					if getKeyState(k) then
						brake_reverse = true
					end
				end
			end

			if vehicleDriveType == "awd" or vehicleDriveType == "fwd" then
				for k in pairs(getBoundKeys("handbrake")) do
					if getKeyState(k) then
						handbrake = true
					end
				end
			end

			if not tiresHeatLevels[currentVehicle] then
				tiresHeatLevels[currentVehicle] = {0, 0, 0, 0}
			end

			if getVehicleSpeed(currentVehicle) < 20 then
				local handbrakeState = brake_reverse and handbrake

				-- Rear
				if accelerate and brake_reverse and not handbrakeState then
					tiresHeatLevels[currentVehicle][1] = tiresHeatLevels[currentVehicle][1] + deltaTime / math.random(100, 2250) * 1000
					tiresHeatLevels[currentVehicle][2] = tiresHeatLevels[currentVehicle][2] + deltaTime / math.random(100, 2250) * 1000

					if tiresHeatLevels[currentVehicle][1] / 10000 * 100 > 100 then
						tiresHeatLevels[currentVehicle][1] = 0
						triggerServerEvent("damageWheels", currentVehicle, 2)
						exports.see_hud:showInfobox("e", "Túlmelegedett a gumid, és kidurrant!")
					end

					if tiresHeatLevels[currentVehicle][2] / 10000 * 100 > 100 then
						tiresHeatLevels[currentVehicle][2] = 0
						triggerServerEvent("damageWheels", currentVehicle, 4)
						exports.see_hud:showInfobox("e", "Túlmelegedett a gumid, és kidurrant!")
					end
				else
					if tiresHeatLevels[currentVehicle][1] > 0 then
						tiresHeatLevels[currentVehicle][1] = tiresHeatLevels[currentVehicle][1] - deltaTime / math.random(100, 1000) * 1000
					end

					if tiresHeatLevels[currentVehicle][2] > 0 then
						tiresHeatLevels[currentVehicle][2] = tiresHeatLevels[currentVehicle][2] - deltaTime / math.random(100, 1000) * 1000
					end
				end

				-- Front
				if accelerate and handbrake and not handbrakeState then
					tiresHeatLevels[currentVehicle][3] = tiresHeatLevels[currentVehicle][3] + deltaTime / math.random(100, 2250) * 1000
					tiresHeatLevels[currentVehicle][4] = tiresHeatLevels[currentVehicle][4] + deltaTime / math.random(100, 2250) * 1000

					if tiresHeatLevels[currentVehicle][3] / 10000 * 100 > 100 then
						tiresHeatLevels[currentVehicle][3] = 0
						triggerServerEvent("damageWheels", currentVehicle, 1)
						exports.see_hud:showInfobox("e", "Túlmelegedett a gumid, és kidurrant!")
					end

					if tiresHeatLevels[currentVehicle][4] / 10000 * 100 > 100 then
						tiresHeatLevels[currentVehicle][4] = 0
						triggerServerEvent("damageWheels", currentVehicle, 3)
						exports.see_hud:showInfobox("e", "Túlmelegedett a gumid, és kidurrant!")
					end
				else
					if tiresHeatLevels[currentVehicle][3] > 0 then
						tiresHeatLevels[currentVehicle][3] = tiresHeatLevels[currentVehicle][3] - deltaTime / math.random(100, 1000) * 1000
					end

					if tiresHeatLevels[currentVehicle][4] > 0 then
						tiresHeatLevels[currentVehicle][4] = tiresHeatLevels[currentVehicle][4] - deltaTime / math.random(100, 1000) * 1000
					end
				end
			end
		end
	end
end

function getVehicleSpeed(vehicle)
	if isElement(vehicle) then
		local vx, vy, vz = getElementVelocity(vehicle)
		return (vx*vx + vy*vy + vz*vz) ^ 0.5 * 187.5
	end
	return 9999
end
