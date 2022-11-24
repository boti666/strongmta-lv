addCommandHandler("gate",
	function ()
		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		local playerInterior = getElementInterior(localPlayer)
		local playerDimension = getElementDimension(localPlayer)

		local lastDistance = 999999
		local nearbyGateID = false

		for k, v in pairs(availableGates) do
			if playerInterior == v[13] and playerDimension == v[14] then
				local currentDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, v[7], v[8], v[9])

				if lastDistance >= currentDistance then
					lastDistance = currentDistance
					nearbyGateID = k
				end
			end
		end

		if nearbyGateID then
			if lastDistance <= 8 then
				triggerServerEvent("toggleGate", localPlayer, nearbyGateID)
			end
		end
	end
)

addCommandHandler("nearbygates",
	function (commandName, maxDistance)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local nearbyList = {}
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)

			maxDistance = tonumber(maxDistance) or 15

			for k, v in pairs(availableGates) do
				if playerInterior == v[13] and playerDimension == v[14] then
					local currentDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, v[7], v[8], v[9])

					if currentDistance <= maxDistance then
						table.insert(nearbyList, {k, v[15], currentDistance})
					end
				end
			end

			if #nearbyList > 0 then
				outputChatBox("#3d7abc[Gate]: #ffffffKözeledben lévő kapuk (" .. maxDistance .. " yard):", 255, 255, 255, true)
				
				for k, v in ipairs(nearbyList) do
					outputChatBox("    * #3d7abcAzonosító: #ffffff" .. v[1] .. " | #3d7abcModel: #ffffff" .. v[2] .. " | #3d7abcTávolság: #ffffff" .. math.floor(v[3] * 1000) / 1000, 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[Gate]: #ffffffNincs egyetlen kapu sem a közeledben.", 255, 255, 255, true)
			end
		end
	end
)