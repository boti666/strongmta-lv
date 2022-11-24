local copterRotorStates = {}
local vehiclePanelStates = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("vehicle", getRootElement(), true)) do
			vehiclePanelStates[v] = {}

			for i = 0, 6 do
				vehiclePanelStates[v][i] = getElementData(v, "panelState:" .. i)
				setVehiclePanelState(v, i, vehiclePanelStates[v][i] or 0)
			end

			if getVehicleType(v) == "Helicopter" then
				copterRotorStates[v] = getElementData(v, "vehicle.engine")
			end
		end
	end
)

addEventHandler("onClientVehicleDamage", getRootElement(),
	function (attackerElement, weaponId, damageTaken, damagePosX, damagePosY, damagePosZ, tireId)
		if isElement(attackerElement) then
			if getElementData(attackerElement, "tazerState") then
				cancelEvent()
				return
			end
		end

		if attackerElement == localPlayer then
			if not vehiclePanelStates[source] then
				vehiclePanelStates[source] = {}
			end

			for i = 0, 6 do
				local state = getVehiclePanelState(source, i)

				if vehiclePanelStates[source][i] ~= state then
					vehiclePanelStates[source][i] = state
					setElementData(source, "panelState:" .. i, state)
				end
			end
		elseif not attackerElement then
			if getPedOccupiedVehicle(localPlayer) == source then
				if getPedOccupiedVehicleSeat(localPlayer) == 0 then
					if not vehiclePanelStates[source] then
						vehiclePanelStates[source] = {}
					end

					for i = 0, 6 do
						local state = getVehiclePanelState(source, i)

						if vehiclePanelStates[source][i] ~= state then
							vehiclePanelStates[source][i] = state
							setElementData(source, "panelState:" .. i, state)
						end
					end
				end
			end
		end

		if tireId then
			if source == getPedOccupiedVehicle(localPlayer) then
				if getPedOccupiedVehicleSeat(localPlayer) == 0 then
					triggerServerEvent("onTireFlatten", source, tireId)
				end
			end
		end
	end
)

addEventHandler("onClientVehicleEnter", getRootElement(),
	function ()
		if getVehicleType(source) ~= "BMX" then
			setVehicleEngineState(source, true)

			if not getElementData(source, "vehicle.engine") then
				setVehicleEngineState(source, false)
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "vehicle.engine" then
			if getVehicleType(source) == "Helicopter" then
				if isElementStreamedIn(source) then
					copterRotorStates[source] = getElementData(source, "vehicle.engine")
				end
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		local elementType = getElementType(source)

		if elementType == "vehicle" then
			vehiclePanelStates[source] = {}

			for i = 0, 6 do
				vehiclePanelStates[source][i] = getElementData(source, "panelState:" .. i)
				setVehiclePanelState(source, i, vehiclePanelStates[source][i] or 0)
			end

			if getVehicleType(source) == "Helicopter" then
				copterRotorStates[source] = getElementData(source, "vehicle.engine")
			end
		elseif elementType == "ped" or elementType == "player" then
			local activeAnimation = getElementData(source, "activeAnimation")

			if activeAnimation then
				setPedAnimation(source, unpack(activeAnimation))
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			vehiclePanelStates[source] = nil

			if getVehicleType(source) == "Helicopter" then
				copterRotorStates[source] = nil
			end
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function()
		if getElementType(source) == "vehicle" then
			vehiclePanelStates[source] = nil

			if getVehicleType(source) == "Helicopter" then
				copterRotorStates[source] = nil
			end
		end
	end
)

addEventHandler("onClientPreRender", getRootElement(),
	function (timeStep)
		for helicopter, rotorState in pairs(copterRotorStates) do
			if isElement(helicopter) then
				if rotorState == 0 then
					local speed = getHelicopterRotorSpeed(helicopter)

					if speed > 0 then
						local new_speed = speed - 0.075 * timeStep / 1000

						if new_speed < 0 then
							new_speed = 0
						end

						setHelicopterRotorSpeed(helicopter, new_speed)
					else
						setHelicopterRotorSpeed(helicopter, 0)
					end
				else
					if not getVehicleController(helicopter) then
						setHelicopterRotorSpeed(helicopter, 0.1)
					end
				end
			else
				copterRotorStates[helicopter] = nil
			end
		end
	end
)

addCommandHandler("fixcam",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			setCameraTarget(localPlayer)
		end
	end
)
