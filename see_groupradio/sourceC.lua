function playRadioSound()
	playSoundFrontEnd(47)
	setTimer(playSoundFrontEnd, 700, 1, 48)
	setTimer(playSoundFrontEnd, 800, 1, 48)
end
addEvent("playRadioSound", true)
addEventHandler("playRadioSound", getRootElement(), playRadioSound)

addCommandHandler("ar",
	function (commandName, ...)
		if not (...) then
			outputChatBox("#3d7abc[StrongMTA - Chat]: #ffffff/" .. commandName .. " [szöveg]", 255, 255, 255, true)
		else
			if not isPedInVehicle(localPlayer) then
				outputChatBox("#d75959[StrongMTA]: #ffffffNem ülsz járműben.", 255, 255, 255, true)
				return
			end

			local message = utf8.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")
			local currVeh = getPedOccupiedVehicle(localPlayer)
			local vehType = getVehicleType(currVeh)

			if vehType == "Plane" or vehType == "Helicopter" then
				local affected = {}

				for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
					local vehType = getVehicleType(v)
					
					if vehType == "Plane" or vehType == "Helicopter" then
						table.insert(affected, v)
					end
				end
				
				triggerServerEvent("onAirRadio", localPlayer, affected, getElementsByType("player", getRootElement(), true), message)
			else
				outputChatBox("#d75959[StrongMTA]: #ffffffEbben a járműben nincs légi rádió.", 255, 255, 255, true)
			end
		end
	end)

addCommandHandler("hr",
	function (commandName, ...)
		if not (...) then
			outputChatBox("#3d7abc[StrongMTA - Chat]: #ffffff/" .. commandName .. " [szöveg]", 255, 255, 255, true)
		else
			if not isPedInVehicle(localPlayer) then
				outputChatBox("#d75959[StrongMTA]: #ffffffNem ülsz járműben.", 255, 255, 255, true)
				return
			end

			local message = utf8.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")
			local currVeh = getPedOccupiedVehicle(localPlayer)
			local model = getElementModel(currVeh)

			if model == 472 or model == 595 or model == 484 or model == 430 or model == 453 or model == 454 then
				local affected = {}

				for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
					local model = getElementModel(v)
					
					if model == 472 or model == 595 or model == 484 or model == 430 or model == 453 or model == 454 then
						table.insert(affected, v)
					end
				end
				
				triggerServerEvent("onShipRadio", localPlayer, affected, getElementsByType("player", getRootElement(), true), message)
			else
				outputChatBox("#d75959[StrongMTA]: #ffffffEbben a járműben nincs hajó rádió.", 255, 255, 255, true)
			end
		end
	end)

addEvent("onAirRadio", true)
addEventHandler("onAirRadio", getRootElement(),
	function (message, vehicles)
		if isElement(source) then
			local currVeh = getPedOccupiedVehicle(source)
			local model = getElementModel(currVeh)
			local vehType = exports.wm_vehiclenames:getCustomVehicleName(model)
			local visibleName = getElementData(source, "visibleName"):gsub("_", " ")

			local plateText = getVehiclePlateText(currVeh)
			local plateTextTable = split(plateText, "-")
			local plateSection = {}

			for i = 1, #plateTextTable do
				if utf8.len(plateTextTable[i]) > 0 then
					table.insert(plateSection, plateTextTable[i])
				end
			end

			plateText = table.concat(plateSection, "-")

			local px, py, pz = getElementPosition(localPlayer)

			for i = 1, #vehicles do
				local veh = vehicles[i]
				local vx, vy, vz = getElementPosition(veh)
				local dist = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
				
				if getPedOccupiedVehicle(localPlayer) == veh then
					local scale = 1 - dist / 1000
					local r, g, b = 89, 142, 215

					if model == 497 or model == 488 or model == 425 or model == 548 or model == 520 then
						r, g, b = 215, 89, 89
					end

					outputChatBox("[Légi Rádió] " .. visibleName .. " (" .. vehType .. "-" .. plateText .. "): " .. message, r * scale, g * scale, b * scale)
					playRadioSound()
				elseif dist < 6 then
					local color = interpolateBetween(255, 0, 0, 50, 0, 0, dist / 6, "Linear")
					outputChatBox("[Légi Rádió] " .. visibleName .. " (" .. vehType .. "-" .. plateText .. "): " .. message, color, color, color)
				end
			end
		end
	end)

addEvent("onShipRadio", true)
addEventHandler("onShipRadio", getRootElement(),
	function (message, vehicles)
		if isElement(source) then
			local currVeh = getPedOccupiedVehicle(source)
			local vehType = exports.wm_vehiclenames:getCustomVehicleName(getElementModel(currVeh))
			local visibleName = getElementData(source, "visibleName"):gsub("_", " ")

			local plateText = getVehiclePlateText(currVeh)
			local plateTextTable = split(plateText, "-")
			local plateSection = {}

			for i = 1, #plateTextTable do
				if utf8.len(plateTextTable[i]) > 0 then
					table.insert(plateSection, plateTextTable[i])
				end
			end

			plateText = table.concat(plateSection, "-")

			local px, py, pz = getElementPosition(localPlayer)

			for i = 1, #vehicles do
				local veh = vehicles[i]
				local vx, vy, vz = getElementPosition(veh)
				local dist = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
				
				if getPedOccupiedVehicle(localPlayer) == veh then
					local scale = 1 - dist / 1000
					outputChatBox("[Hajó Rádió] " .. visibleName .. " (" .. vehType .. "-" .. plateText .. "): " .. message, 89 * scale, 142 * scale, 215 * scale)
					playRadioSound()
				elseif dist < 6 then
					local color = interpolateBetween(255, 0, 0, 50, 0, 0, dist / 6, "Linear")
					outputChatBox("[Hajó Rádió] " .. visibleName .. " (" .. vehType .. "-" .. plateText .. "): " .. message, color, color, color)
				end
			end
		end
	end)

addEvent("localRadioMessage", true)
addEventHandler("localRadioMessage", getRootElement(),
	function (message)
		if message then
			local affected = {}
			local currVeh = getPedOccupiedVehicle(localPlayer)

			if currVeh then
				if getElementData(currVeh, "vehicle.windowState") then
					for k, v in pairs(getVehicleOccupants(currVeh)) do
						if v ~= localPlayer then
							table.insert(affected, {v, "#FFFFFF"})
						end
					end
				end
			else
				local px, py, pz = getElementPosition(localPlayer)

				for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
					if v ~= localPlayer then
						local tx, ty, tz = getElementPosition(v)
						local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

						if dist <= 12 then
							table.insert(affected, {v, string.format("#%.2X%.2X%.2X", interpolateBetween(255, 255, 255, 50, 50, 50, dist / 12, "Linear"))})
						end
					end
				end
			end
			
			if #affected > 0 then
				triggerServerEvent("localRadioMessage", localPlayer, message, affected)
			end
		end
	end
)