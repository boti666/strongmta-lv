local connection = false
local reportPrice = 800000

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		--local pedElement = createPed(37, 356.29742431641, 165.8410949707, 1008.3762207031, 270)
		local pedElement = createPed(37, 355.81918334961, 166.08586120605, 1029.7864990234, 270)

		if isElement(pedElement) then
			setElementInterior(pedElement, 3)
			setElementDimension(pedElement, 13)
			setElementFrozen(pedElement, true)
			setElementData(pedElement, "invulnerable", true)
			setElementData(pedElement, "visibleName", "Ingatlanos Dezső")
			setElementData(pedElement, "ped.type", "interiorReport", false)
			setPedWalkingStyle(pedElement, 120)
		end

		local currentTime = getRealTime()
		local nextInteriorReport = {currentTime.year + 1900, currentTime.month + 1 + 1, 12}

		if nextInteriorReport then
			setElementData(resourceRoot, "nextInteriorReport", nextInteriorReport)
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName)
		if isElement(source) then
			if dataName == "loggedIn" then
				local interiorsResource = getResourceFromName("see_interiors")

				if interiorsResource then
					if getResourceState(interiorsResource) == "running" then
						local nextInteriorReport = getElementData(resourceRoot, "nextInteriorReport")

						if nextInteriorReport then

							local interiorsTable = exports.see_interiors:requestInteriors(source)

							if interiorsTable then
								local notReportedInteriors = {}
								local notReportedCounter = 0

								local dbQuery = dbQuery(connection, "SELECT * FROM interiors WHERE ownerId = ?", getElementData(source, "char.ID"))
								local dbResult = dbPoll(dbQuery, -1)
								dbResult = dbResult[1]

								if string.len(dbResult.lastReport) > 0 then
									--iprint(dbResult.lastReport)
									--print("ide futok wowow")
									local dateSplit = split(dbResult.lastReport, ".")

									iprint(dateSplit[1] ~= nextInteriorReport[1] or dateSplit[2] ~= nextInteriorReport[2])

									if dateSplit[1] ~= nextInteriorReport[1] or dateSplit[2] ~= nextInteriorReport[2] and dateSplit[3] < nextInteriorReport[3] then
										notReportedInteriors[dbResult.interiorId] = true
										notReportedCounter = notReportedCounter + 1
									end
								end


								if notReportedCounter > 0 then
									setElementData(source, "notReportedInteriors", notReportedInteriors)
								else
									setElementData(source, "notReportedInteriors", false)
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onPlayerClick", getRootElement(),
	function (button, state, clickedElement)
		if button == "right" and state == "up" then
			if clickedElement then
				if getElementData(source, "talking") then 
					return exports.see_hud:showInfobox(source, "e", "Már beszélsz Dezsővel!")
				end
				local pedType = getElementData(clickedElement, "ped.type")

				if pedType and pedType == "interiorReport" then
					local playerX, playerY, playerZ = getElementPosition(source)
					local targetX, targetY, targetZ = getElementPosition(clickedElement)

					if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 3 then
						local nextInteriorReport = getElementData(resourceRoot, "nextInteriorReport")
						local notReportedInteriors = getElementData(source, "notReportedInteriors")

						if nextInteriorReport and notReportedInteriors then
							local interiorCount = 0
							local interiorsList = {}

							for k, v in pairs(notReportedInteriors) do
								interiorCount = interiorCount + 1
								table.insert(interiorsList, k)
							end

							setElementData(source, "talking", true)

							if interiorCount > 0 then
								local currentMoney = getElementData(source, "char.Money") or 0

								currentMoney = currentMoney - reportPrice

								if currentMoney > 0 then
									local currentTime = getRealTime()
									local reportTime = string.format("%04d.%02d.%02d.", currentTime.year + 1900, currentTime.month + 1, currentTime.monthday)

									setElementData(source, "char.Money", currentMoney)
									setElementData(source, "notReportedInteriors", false)

									npcTalk(source, clickedElement, 1, true)
									triggerClientEvent(source, "npcTalk", source, clickedElement, 1, true, reportPrice)

									dbExec(connection, "UPDATE interiors SET lastReport = ? WHERE ownerId = ?", reportTime, getElementData(source, "char.ID"))
								else
									npcTalk(source, clickedElement, 1, false)
									triggerClientEvent(source, "npcTalk", source, clickedElement, 1, false, reportPrice)
								end
							else
								exports.see_hud:showInfobox(source, "e", "Minden ingatlanod be van jelentve!")
							end
						else
							exports.see_hud:showInfobox(source, "e", "Minden ingatlanod be van jelentve!")
						end
					end
				end
			end
		end
	end
)

function npcTalk(sourcePlayer, sourcePed, stage, state)
	if state == "deleting" then
		setPedAnimation(sourcePlayer, false)
		setPedAnimation(sourcePed, false)

		if stage == 1 then
			setPedAnimation(sourcePed, "GANGS", "prtial_gngtlkA", -1, true, false, false)
			setTimer(npcTalk, 8000, 1, sourcePed, stage + 1, state)
		end
	else
		setPedAnimation(sourcePlayer, false)
		setPedAnimation(sourcePed, false)

		if stage == 1 then
			setPedAnimation(sourcePed, "GANGS", "prtial_gngtlkA", -1, true, false, false)
		elseif stage == 2 then
			setPedAnimation(sourcePlayer, "GANGS", "prtial_gngtlkA", -1, true, false, false)
		elseif stage == 3 then
			setPedAnimation(sourcePed, "GANGS", "prtial_gngtlkA", -1, true, false, false)
		elseif stage == 4 then
			setPedAnimation(sourcePlayer, "GANGS", "prtial_gngtlkA", -1, true, false, false)
		elseif stage == 5 then
			setPedAnimation(sourcePed, "GANGS", "prtial_gngtlkA", 6000, true, false, false)
		end

		if stage < 5 then
			setTimer(npcTalk, 6000, 1, sourcePlayer, sourcePed, stage + 1, state)
			setElementData(source, "talking", false)
		end
	end
end
