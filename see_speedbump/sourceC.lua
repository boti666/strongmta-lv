local streamedSpeedBumps = {}
local collisionsEnabled = true

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("object", getRootElement(), true)) do
			if getElementModel(v) == 10117 then
				streamedSpeedBumps[v] = true
				setElementCollisionsEnabled(v, collisionsEnabled)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementModel(source) == 10117 then
			streamedSpeedBumps[source] = true
			setElementCollisionsEnabled(source, collisionsEnabled)
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementModel(source) == 10117 then
			streamedSpeedBumps[source] = nil
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local currentVeh = getPedOccupiedVehicle(localPlayer)

		if isElement(currentVeh) then
			local enableCollisions = true

			if Vector3(getElementVelocity(currentVeh)).length * 180 < 40 then
				enableCollisions = false
			end

			if collisionsEnabled ~= enableCollisions then
				for k, v in pairs(streamedSpeedBumps) do
					if isElement(k) then
						setElementCollisionsEnabled(k, enableCollisions)
					end
				end

				collisionsEnabled = enableCollisions
			end
		end
	end
)
