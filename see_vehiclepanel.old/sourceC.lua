local theOldCar = false

addCommandHandler("oldcar",
	function ()
		outputChatBox("#3d7abc[StrongMTA - Oldcar]: #ffffffElőző járműved: #ff9600" .. (theOldCar or "-"), 0, 0, 0, true)
	end)

local engineStartTimer = false
local preEngineStart = false
local lastEngineStart = 0

bindKey("j", "both",
	function (key, state)
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if pedveh then
			if getVehicleOccupant(pedveh) == localPlayer then
				if getVehicleType(pedveh) ~= "BMX" then
					if state == "down" then
						if not getVehicleEngineState(pedveh) then
							preEngineStart = true
							playSound("files/key.mp3")
						else
							triggerServerEvent("toggleEngine", localPlayer, pedveh, false)
						end
					elseif state == "up" then
						preEngineStart = false
					end
				end
			end
		end
	end)

bindKey("space", "both",
	function (key, state)
		if preEngineStart then
			local pedveh = getPedOccupiedVehicle(localPlayer)

			if pedveh then
				if getVehicleOccupant(pedveh) == localPlayer then
					if getVehicleType(pedveh) ~= "BMX" then
						if state == "down" then
							if not isTimer(engineStartTimer) then
								if getTickCount() - lastEngineStart >= 1500 then
									triggerServerEvent("syncVehicleSound", pedveh, "files/starter.mp3", getElementsByType("player", root, true))

									engineStartTimer = setTimer(
										function()
											triggerServerEvent("toggleEngine", localPlayer, pedveh, true)
											lastEngineStart = getTickCount()
										end,
									1000, 1)
								end
							end
						elseif state == "up" then
							preEngineStart = false
						end
					end
				end
			end
		end
	end)

addEvent("syncVehicleSound", true)
addEventHandler("syncVehicleSound", getRootElement(),
	function (typ, path)
		if isElement(source) then
			if typ == "3d" then
				local x, y, z = getElementPosition(source)
				local soundEffect = playSound3D(path, x, y, z)

				if isElement(soundEffect) then
					setElementInterior(soundEffect, getElementInterior(source))
					setElementDimension(soundEffect, getElementDimension(source))
					attachElements(soundEffect, source)
				end
			else
				playSound(path)
			end
		end
	end)

addEvent("onVehicleLockEffect", true)
addEventHandler("onVehicleLockEffect", getRootElement(),
	function ()
		if isElement(source) then
			processLockEffect(source)
		end
	end)

function processLockEffect(vehicle)
	if isElement(vehicle) then
		if getVehicleOverrideLights(vehicle) == 0 or getVehicleOverrideLights(vehicle) == 1 then
			setVehicleOverrideLights(vehicle, 2)
		else
			setVehicleOverrideLights(vehicle, 1)
		end
		
		setTimer(
			function()
				if getVehicleOverrideLights(vehicle) == 0 or getVehicleOverrideLights(vehicle) == 1 then
					setVehicleOverrideLights(vehicle, 2)
				else
					setVehicleOverrideLights(vehicle, 1)
				end
			end,
		548.57142857143 / 3, 3)
	end
end

local lastLockTick = 0

bindKey("k", "down",
	function ()
		if getTickCount() - lastLockTick > 500 then
			local x, y, z = getElementPosition(localPlayer)
			local pedveh = getPedOccupiedVehicle(localPlayer)

			if not isElement(pedveh) then
				local lastdist = math.huge

				for k, v in pairs(getElementsByType("vehicle", getRootElement(), true)) do
					local tx, ty, tz = getElementPosition(v)
					local dist = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

					if dist <= 5 and dist < lastdist then
						lastdist = dist
						pedveh = v
					end
				end
			end

			if isElement(pedveh) then
				triggerServerEvent("toggleLock", localPlayer, pedveh, getElementsByType("player", getRootElement(), true))
			end

			lastLockTick = getTickCount()
		end
	end)

local lastLightTick = 0

bindKey("l", "down",
	function ()
		if isPedInVehicle(localPlayer) then
			if getTickCount() - lastLightTick > 500 then
				local pedveh = getPedOccupiedVehicle(localPlayer)

				if getVehicleType(pedveh) ~= "BMX" and getVehicleOccupant(pedveh) == localPlayer then
					if not getElementData(pedveh, "emergencyIndicator") and not getElementData(pedveh, "leftIndicator") and not getElementData(pedveh, "rightIndicator") then
						lastLightTick = getTickCount()
						triggerServerEvent("toggleLights", localPlayer, pedveh)
					end
				end
			end
		end
	end)

addEventHandler("onClientPlayerVehicleEnter", getRootElement(),
	function (vehicle, seat)
		setVehicleDoorOpenRatio(vehicle, 2, 0, 0)
		setVehicleDoorOpenRatio(vehicle, 3, 0, 0)
		setVehicleDoorOpenRatio(vehicle, 4, 0, 0)
		setVehicleDoorOpenRatio(vehicle, 5, 0, 0)

		if getVehicleOverrideLights(vehicle) == 0 then
			setVehicleOverrideLights(vehicle, 1)
			setElementData(vehicle, "vehicle.lights", 0)
		end

		if source == localPlayer then
			if isElement(vehicle) then
				local vehicleType = getVehicleType(vehicle)

				theOldCar = getElementData(vehicle, "vehicle.dbID")

				if vehicleType == "BMX" then
					setVehicleEngineState(vehicle, true)
				end

				if (getElementData(vehicle, "vehicle.engine") or 0) ~= 1 then
					if seat == 0 and vehicleType ~= "BMX" then
						outputChatBox("#dc143c[StrongMTA]: #acd373A jármű elindításához fordítsd el a gyújtáskapcsolót és indítsd a motort!", 80, 168, 227, true)
						outputChatBox("#dc143c[StrongMTA]: #acd373(( Tartsd lenyomva a #ffffff'J'#acd373 betűt, mellé pedig szintén tartsd lenyomva a #ffffff'Space'#acd373-t, amíg a motor be nem indul. ))", 80, 168, 227, true)
					end
				end
			end
		end
	end)

addEventHandler("onClientVehicleStartEnter", getRootElement(),
	function (player, seat, door)
		if player == localPlayer then
			if getVehicleType(source) == "Bike" or getVehicleType(source) == "BMX" or getVehicleType(source) == "Boat" then
				if isVehicleLocked(source) then
					cancelEvent()

					local playerX, playerY, playerZ = getElementPosition(localPlayer)
					local vehicleX, vehicleY, vehicleZ = getElementPosition(source)

					if getDistanceBetweenPoints3D(playerX, playerY, playerZ, vehicleX, vehicleY, vehicleZ) <= 5 then
						exports.see_hud:showInfobox("error", "Ez a jármű be van zárva!")
					end
				end
			end
		end
	end)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			setVehicleDoorOpenRatio(source, 2, 0, 0)
			setVehicleDoorOpenRatio(source, 3, 0, 0)
			setVehicleDoorOpenRatio(source, 4, 0, 0)
			setVehicleDoorOpenRatio(source, 5, 0, 0)
			
			for i = 0, 6 do
				setVehiclePanelState(source, i, getVehiclePanelState(source, i))
			end

			if getElementData(source, "vehicle.dbID") then
				if getElementData(source, "vehicle.engine") == 1 then
					setVehicleEngineState(source, true)
				else
					setVehicleEngineState(source, false)
				end
				
				if getElementData(source, "vehicle.lights") == 1 then
					setVehicleOverrideLights(source, 2)
				else
					setVehicleOverrideLights(source, 1)
				end
				
				if getElementData(source, "vehicle.locked") == 1 then
					setVehicleLocked(source, true)
				else
					setVehicleLocked(source, false)
				end
			end
		end
	end)

local screenX, screenY = guiGetScreenSize()

local brakePanelState = false

local brakePanelWidth = 10
local brakePanelHeight = 250

local brakePanelPosX = screenX - brakePanelWidth - 12
local brakePanelPosY = screenY / 2 - brakePanelHeight / 2

local brakeProgress = 1
local brakeLastProgress = false

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if isPedInVehicle(localPlayer) then
			if getPedOccupiedVehicleSeat(localPlayer) == 0 then
				local pedveh = getPedOccupiedVehicle(localPlayer)
				local informateAbout = false
				if not getElementData(pedveh, "cannotMove") then 

					if getElementData(pedveh, "vehicle.handBrake") then
						informateAbout = "Amíg be van húzva a kézifék, nem indulhatsz el."
					end

					if informateAbout and not isMTAWindowActive() and not isCursorShowing() then
						local pedtask = getPedSimplestTask(localPlayer)

						if pedtask == "TASK_SIMPLE_CAR_GET_OUT" or pedtask == "TASK_SIMPLE_CAR_CLOSE_DOOR_FROM_OUTSIDE" then
							return
						end

						local boundkeys = {}

						for k, v in pairs(getBoundKeys("accelerate")) do
							if k == key then
								table.insert(boundkeys, k)
							end
						end

						for k, v in pairs(getBoundKeys("brake_reverse")) do
							if k == key then
								table.insert(boundkeys, k)
							end
						end

						for i = 1, #boundkeys do
							if boundkeys[i] == key then
								cancelEvent()

								if press then
									if (getElementData(pedveh, "vehicle.engine") or 0) == 1 then
										exports.see_hud:showInfobox("w", informateAbout)
									end
								end

								break
							end
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientCursorMove", getRootElement(),
	function (relX, relY, absX, absY)
		if brakePanelState then
			if not isMTAWindowActive() and getKeyState("lalt") then
				local pedveh = getPedOccupiedVehicle(localPlayer)
				local state = getElementData(pedveh, "vehicle.handBrake")
				
				brakeProgress = brakeProgress - (0.5 - relY) * 5

				if brakeProgress < 0 then
					brakeProgress = 0
				elseif brakeProgress > 2 then
					brakeProgress = 2
				end

				if brakeProgress < 0.5 then
					if state then
						if getVehicleType(pedveh) == "Automobile" then
							setPedControlState(localPlayer, "handbrake", false)
							triggerServerEvent("toggleHandBrake", pedveh, false, true)
						else
							triggerServerEvent("toggleHandBrake", pedveh, false)
						end
					end
				elseif brakeProgress > 1.5 then
					if not state then
						if getVehicleType(pedveh) == "Automobile" then
							setPedControlState(localPlayer, "handbrake", true)
							triggerServerEvent("toggleHandBrake", pedveh, true, true)
						else
							triggerServerEvent("toggleHandBrake", pedveh, true)
						end
					end
				end

				setCursorPosition(screenX / 2, screenY / 2)
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "vehicle.handBrake" then
			local pedveh = getPedOccupiedVehicle(localPlayer)

			if pedveh == source then
				if getElementData(source, "vehicle.handBrake") then
					playSound("files/handbrakeon.mp3")
				else
					playSound("files/handbrakeoff.mp3")
				end
			end
		end
	end)

local lastGear = 0
local gearIFP = engineLoadIFP("files/gear.ifp", "gear_shift")
local gearVals = {}
local nextKerregesTime = 0

function remFromTable()
	gearVals[source] = nil
end
addEventHandler("onClientElementStreamIn", getRootElement(), remFromTable)
addEventHandler("onClientElementStreamOut", getRootElement(), remFromTable)
addEventHandler("onClientElementDestroy", getRootElement(), remFromTable)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if pedveh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local vehtype = getVehicleType(pedveh)
			local pedtask = getPedSimplestTask(localPlayer)

			if getKeyState("lalt") and pedtask == "TASK_SIMPLE_CAR_DRIVE" and isControlEnabled("accelerate") then
				local vx, vy, vz = getElementVelocity(pedveh)
				local actualspeed = math.sqrt(vx * vx + vy * vy + vz * vz) * 180

				if (vehtype ~= "Automobile" and actualspeed <= 5) or vehtype == "Automobile" then
					brakePanelState = true
					showCursor(true)
					setCursorAlpha(0)
				end
			else
				brakePanelState = false
				showCursor(false)
				setCursorAlpha(255)
				brakeLastProgress = false
			end

			if brakePanelState then
				local sizeForZone = brakePanelHeight / 3

				dxDrawRectangle(brakePanelPosX, brakePanelPosY, brakePanelWidth, brakePanelHeight, tocolor(0, 0, 0, 200))

				dxDrawRectangle(brakePanelPosX + 2, brakePanelPosY + 2, brakePanelWidth - 4, sizeForZone - 4, tocolor(61, 122, 188))

				dxDrawRectangle(brakePanelPosX + 2, brakePanelPosY + 2 + brakePanelHeight - sizeForZone, brakePanelWidth - 4, sizeForZone - 4, tocolor(215, 89, 89))

				dxDrawRectangle(brakePanelPosX + 2, brakePanelPosY + 2 + sizeForZone * brakeProgress, brakePanelWidth - 4, sizeForZone - 4, tocolor(255, 255, 255, 160))
			end

			if vehtype == "Automobile" then
				local state = getElementData(pedveh, "vehicle.handBrake")

				if state then
					local vx, vy, vz = getElementVelocity(pedveh)
					local actualspeed = math.sqrt(vx * vx + vy * vy + vz * vz) * 180

					if actualspeed <= 1 then
						setElementAngularVelocity(pedveh, 0, 0, 0)
						setElementFrozen(pedveh, true)
					else
						setPedControlState(localPlayer, "handbrake", true)
					end
				end

				if not brakeLastProgress then
					if state then
						brakeLastProgress = 2
						brakeProgress = 2
					else
						brakeLastProgress = 0
						brakeProgress = 0
					end
				end

				local currGear = getVehicleCurrentGear(pedveh)
				local x, y, z = getElementPosition(pedveh)
				local health = getElementHealth(pedveh)
				
				if health <= 600 then
					if getTickCount() > nextKerregesTime then
						local vx, vy, vz = getElementVelocity(pedveh)
						local actualspeed = math.sqrt(vx * vx + vy * vy + vz * vz) * 180

						if actualspeed >= 15 then
							nextKerregesTime = getTickCount() + math.random(40000, 60000)
							triggerServerEvent("playTurboSound", localPlayer, pedveh, -math.random(2, 3), getElementsWithinRange(x, y, z, 100, "player"))
						end
					end
				end

				if currGear > lastGear then
					lastGear = currGear

					local turboLevel = getElementData(pedveh, "vehicle.tuning.Turbo") or 0

					if turboLevel >= 4 then
						triggerServerEvent("playTurboSound", localPlayer, pedveh, turboLevel, getElementsWithinRange(x, y, z, 100, "player"))
					end

					if health <= 600 then
						if math.random(10) <= 7 then
							triggerServerEvent("playTurboSound", localPlayer, pedveh, -1, getElementsWithinRange(x, y, z, 100, "player"))
						end
					end
				elseif currGear < lastGear then
					lastGear = currGear

					if health <= 600 then
						if math.random(10) <= 7 then
							triggerServerEvent("playTurboSound", localPlayer, pedveh, -1, getElementsWithinRange(x, y, z, 100, "player"))
						end
					end
				end
			end
		end

		local x, y, z = getElementPosition(localPlayer)
		local vehicles = getElementsWithinRange(x, y, z, 100, "vehicle")

		for i = 1, #vehicles do
			local veh = vehicles[i]

			if isElement(veh) then
				if getVehicleType(veh) == "Automobile" then
					local currGear = getVehicleCurrentGear(veh)

					if currGear and gearVals[veh] ~= currGear then
						gearVals[veh] = currGear

						local driver = getVehicleController(veh)

						if isElement(driver) then
							local currAnim = getPedAnimation(driver)

							if not currAnim then
								setPedAnimation(driver, "gear_shift", "CAR_tune_radio", -1, false, false, true, false)
							end
						end
					end
				end
			end
		end
	end)

addEvent("playTurboSound", true)
addEventHandler("playTurboSound", getRootElement(),
	function (turboLevel)
		if isElement(source) then
			local x, y, z = getElementPosition(source)
			local soundEffect = false

			if turboLevel == 4 then
				soundEffect = playSound3D("files/turbo.mp3", x, y, z)
			elseif turboLevel == -1 then
				soundEffect = playSound3D("files/kerreges.mp3", x, y, z)
			elseif turboLevel == -2 then
				soundEffect = playSound3D("files/ekszij1.mp3", x, y, z)
			elseif turboLevel == -3 then
				soundEffect = playSound3D("files/ekszij2.mp3", x, y, z)
			else
				soundEffect = playSound3D("files/charger.mp3", x, y, z)
			end

			if isElement(soundEffect) then
				if turboLevel == 4 then
					setSoundVolume(soundEffect, 0.3)
				end

				setElementDimension(soundEffect, getElementDimension(source))
				setElementInterior(soundEffect, getElementInterior(source))
				attachElements(soundEffect, source)
			end
		end
	end)

function getPlayerToVehicleRelatedPosition()
	local lookAtVehicle = getPedTarget(localPlayer)

	if lookAtVehicle and getElementType(lookAtVehicle) == "vehicle" then   
		local vehPosX, vehPosY, vehPosZ = getElementPosition(lookAtVehicle)
		local vehRotX, vehRotY, vehRotZ = getElementRotation(lookAtVehicle)
		local pedPosX, pedPosY, pedPosZ = getElementPosition(localPlayer)
		local angle = math.deg(math.atan2(pedPosX - vehPosX, pedPosY - vehPosY)) + 180 + vehRotZ
		
		if angle < 0 then
			angle = angle + 360
		elseif angle > 360 then
			angle = angle - 360
		end
		
		return math.floor(angle) + 0.5
	else
		return false
	end
end

function getDoor(vehicle)
	if vehicle then
		-- 0 (hood), 1 (trunk), 2 (front left), 3 (front right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 or getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 1
		end
			
		if getPlayerToVehicleRelatedPosition() >= 65 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 295 then
			return 3
		end
	elseif vehicle then
		-- 0 (hood), 2 (front left), 3 (front right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 65 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 295 then
			return 3
		end
	elseif vehicle then
		-- 0 (hood), 1 (trunk), 2 (front left), 3 (front right), 4 (rear left), 5 (rear right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 or getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 1
		end
			
		if getPlayerToVehicleRelatedPosition() >= 91 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 270 then
			return 3
		end
			
		if getPlayerToVehicleRelatedPosition() >= 60 and getPlayerToVehicleRelatedPosition() <= 90 then
			return 4
		end
			
		if getPlayerToVehicleRelatedPosition() >= 271 and getPlayerToVehicleRelatedPosition() <= 300 then
			return 5
		end
	elseif vehicle then
		-- 0 (hood), 2 (front left), 3 (front right), 4 (rear left at back), 5 (rear right at back)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 91 and getPlayerToVehicleRelatedPosition() <= 130 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 230 and getPlayerToVehicleRelatedPosition() <= 270 then
			return 3
		end
			
		if getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 4
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 then
			return 5
		end
	elseif vehicle then
		-- 0 (hood), 2 (front left), 3 (front right)
		if getPlayerToVehicleRelatedPosition() >= 160 and getPlayerToVehicleRelatedPosition() <= 200 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 120 and getPlayerToVehicleRelatedPosition() <= 155 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 205 and getPlayerToVehicleRelatedPosition() <= 230 then
			return 3
		end
	elseif vehicle then
		-- 2 (front left), 3 (front right)       
		if getPlayerToVehicleRelatedPosition() >= 120 and getPlayerToVehicleRelatedPosition() <= 155 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 205 and getPlayerToVehicleRelatedPosition() <= 230 then
			return 3
		end
	elseif vehicle then
		-- 0 (hood), 1 (trunk), 2 (front left), 3 (front right), 4 (rear left), 5 (rear right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 or getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 1
		end
			
		if getPlayerToVehicleRelatedPosition() >= 91 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 270 then
			return 3
		end
			
		if getPlayerToVehicleRelatedPosition() >= 60 and getPlayerToVehicleRelatedPosition() <= 90 then
			return 4
		end
			
		if getPlayerToVehicleRelatedPosition() >= 271 and getPlayerToVehicleRelatedPosition() <= 300 then
			return 5
		end
	end

	return nil
end

bindKey("mouse2", "down",
	function ()
		if getPedWeapon(localPlayer) == 0 then
			if not isCursorShowing() then
				if not getPedOccupiedVehicle(localPlayer) then
					local lookAtVehicle = getPedTarget(localPlayer)

					if isElement(lookAtVehicle) then
						if getElementType(lookAtVehicle) == "vehicle" then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local targetX, targetY, targetZ = getElementPosition(lookAtVehicle)

							if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 5 then
								if (getElementData(lookAtVehicle, "vehicle.locked") or 0) == 0 then
									local door = getDoor(lookAtVehicle)

									if door then
										local doorname = ""

										if door == 0 then
											doorname = "motorháztető"
										elseif door == 1 then
											doorname = "csomagtartó"
										elseif door == 2 then
											doorname = "bal első ajtó"
										elseif door == 3 then
											doorname = "jobb első ajtó"
										elseif door == 4 then
											doorname = "bal hátsó ajtó"
										elseif door == 5 then
											doorname = "jobb hátsó ajtó"
										end

										triggerServerEvent("doVehicleDoorInteract", localPlayer, lookAtVehicle, door, doorname)
									end
								else
									outputChatBox("#d75959[StrongMTA]: #FFFFFFA jármű be van zárva!", 255, 255, 255, true)
								end
							end
						end
					end
				end
			end
		end
	end)

addEvent("playDoorEffect", true)
addEventHandler("playDoorEffect", getRootElement(),
	function (vehicle, typ)
		if isElement(vehicle) and typ then
			local soundPath = false

			if typ == "open" then
				soundPath = exports.see_vehiclepanel:getDoorOpenSound(getElementModel(vehicle))
			elseif typ == "close" then
				soundPath = exports.see_vehiclepanel:getDoorCloseSound(getElementModel(vehicle))
			end

			if soundPath then
				local x, y, z = getElementPosition(vehicle)
				local int = getElementInterior(vehicle)
				local dim = getElementDimension(vehicle)
				local sound = playSound3D(soundPath, x, y, z)

				if isElement(sound) then
					setElementInterior(sound, int)
					setElementDimension(sound, dim)
					attachElements(sound, vehicle)
				end
			end
		end
	end)