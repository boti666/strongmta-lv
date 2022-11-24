local dutyPositions = {}
local standingMarker = false

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedResource)
		if startedResource == getThisResource() or getResourceName(startedResource) == "see_interiors" then
			for k, v in pairs(availableGroups) do
				if not dutyPositions[k] then
					dutyPositions[k] = {}
				end

				for i, v2 in ipairs(v.duty.positions) do
					local colShapeElement = createColSphere(v2[1], v2[2], v2[3], 0.75)

					if isElement(colShapeElement) then
						setElementInterior(colShapeElement, v2[4])
						setElementDimension(colShapeElement, v2[5])
						setElementData(colShapeElement, "groupId", k)

						local markerElement = exports.see_interiors:createCoolMarker(v2[1], v2[2], v2[3], "duty")

						if isElement(markerElement) then
							setElementInterior(markerElement, v2[4])
							setElementDimension(markerElement, v2[5])
						end

						dutyPositions[k][i] = {}
						dutyPositions[k][i].colShape = colShapeElement
						dutyPositions[k][i].pickup = markerElement
					end
				end
			end
		end
	end
)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(availableGroups) do
			for i, v2 in ipairs(v.duty.positions) do
				if isElement(dutyPositions[k][i].pickup) then
					destroyElement(dutyPositions[k][i].pickup)
				end
			end
		end
	end
)

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (hitElement, dimensionMatch)
		if hitElement == localPlayer and dimensionMatch then
			local groupId = getElementData(source, "groupId")

			if groupId then
				standingMarker = groupId
				exports.see_hud:showInteriorBox("Szolgálat", "Nyomj [E] gombot a szolgálat felvételéhez/leadásához", false, "duty")
			end
		end
	end
)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (leftElement, dimensionMatch)
		if leftElement == localPlayer and dimensionMatch then
			standingMarker = false
			exports.see_hud:endInteriorBox()
		end
	end
)

local lastDutyTime = 0

bindKey("e", "down",
	function ()
		if standingMarker then
			if isPlayerInGroup(localPlayer, standingMarker) then
				local elapsedTime = getTickCount() - lastDutyTime

				if elapsedTime >= 20000 then
					lastDutyTime = getTickCount()
					triggerServerEvent("requestDuty", localPlayer, standingMarker)
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffVárj " .. 20 - math.ceil(elapsedTime / 1000) .. " másodpercet a következő dutyzásig.", 255, 255, 255, true)
				end
			end
		end
	end
)

addCommandHandler("grouplist",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			outputChatBox("#3d7abc[StrongMTA]:#ffffff A csoportok megtekintéséhez nyisd meg a konzolt. (F8)", 255, 255, 255, true)
			
			local groupList = {}
			
			for k, v in pairs(availableGroups) do
				table.insert(groupList, {k, v})
			end
			
			table.sort(groupList,
				function (a, b)
					return a[1] < b[1]
				end
			)
			
			for i, v in ipairs(groupList) do
				outputConsole("    * (" .. v[1] .. "): " .. v[2].name .. " [" .. groupTypes[v[2].type] .. "]")
			end
		end
	end
)