local customDoors = {}
local moonbeams = {}
local hotrings = {}

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "vehicle.tuning.DoorType" then
			local dataVal = getElementData(source, dataName)

			customDoors[source] = nil

			if isElementStreamedIn(source) then
				customDoors[source] = dataVal
			end
		end
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
			local doorType = getElementData(v, "vehicle.tuning.DoorType")

			if doorType then
				customDoors[v] = doorType
			end

			if getElementModel(v) == 418 then
				moonbeams[v] = true
			end

			if getElementModel(v) == 503 then
				--hotrings[v] = true
			end
		end
	end)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			local doorType = getElementData(source, "vehicle.tuning.DoorType")

			if doorType then
				customDoors[source] = doorType
			end

			if getElementModel(source) == 418 then
				moonbeams[source] = true
			end

			if getElementModel(source) == 503 then
				--hotrings[source] = true
			end
		end
	end)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if customDoors[source] then
			customDoors[source] = nil
		end

		if moonbeams[source] then
			moonbeams[source] = nil
		end

		if hotrings[source] then
			hotrings[source] = nil
		end
	end)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if customDoors[source] then
			customDoors[source] = nil
		end

		if moonbeams[source] then
			moonbeams[source] = nil
		end

		if hotrings[source] then
			hotrings[source] = nil
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function (timeSlice)
		for veh, doortype in pairs(customDoors) do
			if isElement(veh) then
				if doortype == "scissor" then
					for i = 2, 3 do
						local ratio = getVehicleDoorOpenRatio(veh, i)
						local rx, ry, rz = -72 * ratio, -10 * ratio, -10 * ratio
						local doorname = "door_lf_dummy"

						if i == 3 then
							ry = -ry
							rz = -rz
							doorname = "door_rf_dummy"
						end

						setVehicleComponentRotation(veh, doorname, rx, ry, rz)
					end
				end
			end
		end

		for veh in pairs(moonbeams) do -- GMC Savana
			if isElement(veh) then
				if getElementModel(veh) ~= 418 then
					resetVehicleComponentPosition(veh, "door_lr_dummy")
					resetVehicleComponentPosition(veh, "door_rr_dummy")
					moonbeams[veh] = nil
				end

				for i = 4, 5 do
					local ratio = getVehicleDoorOpenRatio(veh, i)
					local rx, ry, rz = -1.0231127738953, 0.50695592164993, 0.43886932730675
					local doorname = "door_lr_dummy"

					if i == 5 then
						rx, ry, rz = 1.0229268074036, 0.50707358121872, 0.43913355469704
						doorname = "door_rr_dummy"
					end

					setVehicleComponentRotation(veh, doorname, 0, 0, 0)
					setVehicleComponentPosition(veh, doorname, rx * (1 + 0.1 * ratio), ry * (1 - 2 * ratio), rz)
				end
			end
		end

		for veh in pairs(hotrings) do -- Ford Capi RS Cosworth '74
			if isElement(veh) then
				if getElementModel(veh) ~= 503 then
					--setVehicleComponentRotation(veh, "door_lf_dummy")
					--setVehicleComponentRotation(veh, "door_rf_dummy")
					--hotrings[veh] = nil
				end

				for i = 2, 3 do
					local ratio = getVehicleDoorOpenRatio(veh, i)

					if i == 2 then
						setVehicleComponentRotation(veh, "door_lf_dummy", -79.2 * ratio, 24 * ratio, -57.6 * ratio)
					else
						setVehicleComponentRotation(veh, "door_rf_dummy", -79.2 * ratio, -24 * ratio, 57.6 * ratio)
					end
				end
			end
		end
	end)