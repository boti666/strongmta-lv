addCommandHandler("nearbyvehicles",
	function (commandName)
		if getElementData(localPlayer, "loggedIn") then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local vehiclesTable = getElementsByType("vehicle", getRootElement(), true)
			local nearbyList = {}

			for i = 1, #vehiclesTable do
				local vehicleElement = vehiclesTable[i]

				if isElement(vehicleElement) then
					local vehicleId = getElementData(vehicleElement, "vehicle.dbID") or 0

					if vehicleId then
						local targetX, targetY, targetZ = getElementPosition(vehicleElement)

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 15 then
							table.insert(nearbyList, {getElementModel(vehicleElement), getVehicleName(vehicleElement), vehicleId, getVehiclePlateText(vehicleElement)})
						end
					end
				end
			end

			if #nearbyList > 0 then
				outputChatBox("#3d7abc[StrongMTA]: #ffffffKözeledben lévő járművek (15 yard):", 255, 255, 255, true)

				for i, v in ipairs(nearbyList) do
					outputChatBox("    * #3d7abcTípus: #ffffff" .. v[1] .. " (" .. v[2] .. ") | #3d7abcAzonosító: #ffffff" .. (v[3] == 0 and "Nincs (ideiglenes)" or v[3]) .. " | #3d7abcRendszám: #ffffff" .. (v[4] or "Nincs"), 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[StrongMTA]: #ffffffNincs egyetlen jármű sem a közeledben.", 255, 255, 255, true)
			end
		end
	end)

addCommandHandler("nearbygroupvehicles",
	function (commandName)
		if exports.see_groups:isPlayerHavePermission(localPlayer, "impoundTowFinal") or getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local vehiclesTable = getElementsByType("vehicle", getRootElement(), true)
			local nearbyList = {}

			for i = 1, #vehiclesTable do
				local vehicleElement = vehiclesTable[i]

				if isElement(vehicleElement) then
					local vehicleId = getElementData(vehicleElement, "vehicle.dbID") or 0
					local groupId = getElementData(vehicleElement, "vehicle.group") or 0

					if vehicleId and groupId > 0 then
						local targetX, targetY, targetZ = getElementPosition(vehicleElement)

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 15 then
							table.insert(nearbyList, {getElementModel(vehicleElement), getVehicleName(vehicleElement), vehicleId, getVehiclePlateText(vehicleElement), groupId})
						end
					end
				end
			end

			if #nearbyList > 0 then
				outputChatBox("#3d7abc[StrongMTA]: #ffffffKözeledben lévő frakciójárművek (15 yard):", 255, 255, 255, true)

				for i, v in ipairs(nearbyList) do
					outputChatBox("    * #3d7abcTípus: #ffffff" .. v[1] .. " (" .. v[2] .. ") | #3d7abcAzonosító: #ffffff" .. (v[3] == 0 and "Nincs (ideiglenes)" or v[3]) .. " | #3d7abcRendszám: #ffffff" .. (v[4] or "Nincs") .. " | " .. v[5], 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[StrongMTA]: #ffffffNincs egyetlen frakciójármű sem a közeledben.", 255, 255, 255, true)
			end
		end
	end)