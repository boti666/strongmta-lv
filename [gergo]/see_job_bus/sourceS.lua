local activeJobs = {}
local maleSkins = exports.see_binco:getSkinsByType("Férfi")
local femaleSkins = exports.see_binco:getSkinsByType("Női")

addEventHandler("onVehicleEnter", getRootElement(),
	function (thePlayer, seat)
		if seat == 0 then
			if getElementModel(source) == 431 then
				local playerJob = getElementData(thePlayer, "char.Job") or 0
				local jobVehicle = getElementData(thePlayer, "jobVehicle")

				if (playerJob == 5 or playerJob == 6) and jobVehicle then
					if jobVehicle == source then
						if not activeJobs[thePlayer] then
							setElementData(source, "busPassengers", {})

							activeJobs[thePlayer] = {
								busVeh = source,
								nextWp = 0,
								lastWpCheck = 0,
								lineType = playerJob == 5 and "normal" or "country",
								lineColor = playerJob == 5 and {50, 179, 239} or {215, 89, 89},
								peds = {},
								colshape = false
							}

							nextPoint(thePlayer)
						end
					end
				end
			end
		end
	end
)

function nextPoint(playerElement)
	if isElement(playerElement) then
		local currentVehicle = getPedOccupiedVehicle(playerElement)
		local jobVehicle = getElementData(playerElement, "jobVehicle")

		if not currentVehicle or not jobVehicle then
			return false
		end

		if currentVehicle ~= jobVehicle then
			exports.see_hud:showInfobox(playerElement, "e", "Nem ez a munkajárműved!")
			return
		end

		local activeJob = activeJobs[playerElement]

		if not activeJob then
			return
		end

		if getTickCount() - activeJob.lastWpCheck <= 2000 then
			return
		end

		if isElement(activeJob.colshape) then
			destroyElement(activeJob.colshape)
		end

		activeJob.lastWpCheck = getTickCount()
		activeJob.nextWp = activeJob.nextWp + 1

		if activeJob.nextWp > #markerPoints[activeJob.lineType] then
			activeJob.nextWp = 1
		end

		local markerPoint = markerPoints[activeJob.lineType][activeJob.nextWp]

		if markerPoint then
			activeJob.colshape = createColSphere(markerPoint[1], markerPoint[2], markerPoint[3], 3)
		end

		local passengers = #activeJob.peds
		local totalPrize = 10000 * passengers

		activeJob.peds = {}

		for i = 1, math.random(1, 5) do
			if math.random(2) == 2 then
				activeJob.peds[i] = maleSkins[math.random(1, #maleSkins)][1]
			else
				activeJob.peds[i] = femaleSkins[math.random(1, #femaleSkins)][1]
			end
		end

		activeJobs[playerElement] = activeJob

		if passengers > 0 then
			exports.see_core:giveMoney(playerElement, totalPrize)
			outputChatBox("[StrongMTA - Buszsofőr]: #ffffffÖsszesen felszállt #598ed7" .. passengers .. " db#ffffff utas, és kerestél #3d7abc" .. totalPrize .. "$#ffffff-t ezen a megállóhelyen.", playerElement, activeJob.lineColor[1], activeJob.lineColor[2], activeJob.lineColor[3], true)
		end

		triggerClientEvent(playerElement, "nextBusStop", playerElement, activeJob.lineType, activeJob.nextWp, activeJob.peds)
	end
end

function findRandomFreeSeat(vehicleElement)
	if isElement(vehicleElement) then
		local busPassengers = getElementData(vehicleElement, "busPassengers") or {}
		local occupiedSeats = 0

		for k in pairs(busPassengers) do
			if busPassengers[k] then
				if pedPositions[k] then
					occupiedSeats = occupiedSeats + 1
				end
			end
		end

		if #pedPositions - occupiedSeats > 0 then
			local freeSeat = false

			while not freeSeat do
				local seat = math.random(1, #pedPositions)

				if not busPassengers[seat] then
					freeSeat = seat
					break
				end
			end

			return freeSeat
		else
			return false
		end
	else
		return false
	end
end

addEventHandler("onColShapeHit", getResourceRootElement(),
	function (hitElement, sameDimension)
		if isElement(source) and sameDimension then
			if getElementType(hitElement) == "player" then
				local currentVehicle = getPedOccupiedVehicle(hitElement)
				local jobVehicle = getElementData(hitElement, "jobVehicle")

				if currentVehicle and getElementModel(currentVehicle) == 431 and jobVehicle then
					if currentVehicle == jobVehicle then
						if hitElement == getVehicleController(currentVehicle) then
							local activeJob = activeJobs[hitElement]

							if activeJob then
								if getVehicleSpeed(currentVehicle) <= 20 then
									local passengersTable = getElementData(currentVehicle, "busPassengers") or {}
									local passengersCount = #activeJob.peds + 1
									local waitingDuration = passengersCount * 2500

									setElementVelocity(currentVehicle, 0, 0, 0)

									for k in pairs(passengersTable) do
										if math.random(10) < 5 then
											passengersTable[k] = nil
										end
									end

									setElementData(currentVehicle, "busPassengers", passengersTable)

									setTimer(
										function (sourcePlayer, sourceVehicle)
											if activeJobs[sourcePlayer] then
												if isElement(sourceVehicle) then
													local passengersLeft = select(2, getTimerDetails(sourceTimer))

													passengersLeft = passengersLeft - 1

													if passengersLeft / #activeJobs[sourcePlayer].peds == 0 then
														if isElement(sourcePlayer) then
															nextPoint(sourcePlayer)
														end
													else
														local passengersTable = getElementData(sourceVehicle, "busPassengers") or {}
														local freeSeat = findRandomFreeSeat(sourceVehicle)

														if freeSeat then
															passengersTable[freeSeat] = activeJobs[sourcePlayer].peds[passengersLeft]
															setElementData(sourceVehicle, "busPassengers", passengersTable)
														end
													end
												end
											end
										end,
									waitingDuration / passengersCount, passengersCount, hitElement, currentVehicle)

									triggerClientEvent(hitElement, "createBusProgressbar", hitElement, waitingDuration)
								else
									exports.see_hud:showInfobox(hitElement, "e", "Ilyen gyorsan nem tudsz utasokat felvenni. Lassíts le, és próbáld újra!")
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			if getElementModel(source) == 431 then
				removeElementData(source, "busPassengers")
			end
		end
	end
)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if activeJobs[source] then
			if isElement(activeJobs[source].colshape) then
				destroyElement(activeJobs[source].colshape)
			end

			activeJobs[source] = nil
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "char.Job" or dataName == "jobVehicle" then
			local playerJob = getElementData(source, "char.Job")
			local jobVehicle = getElementData(source, "jobVehicle")

			if (playerJob ~= 5 and playerJob ~= 6) or not jobVehicle then
				if activeJobs[source] then
					if isElement(activeJobs[source].colshape) then
						destroyElement(activeJobs[source].colshape)
					end

					activeJobs[source] = nil
				end
			end
		end
	end
)

function getVehicleSpeed(vehicle)
	if isElement(vehicle) then
		local vx, vy, vz = getElementVelocity(vehicle)
		return math.sqrt(vx*vx + vy*vy + vz*vz) * 187.5
	end
end

function RGBToHex(r, g, b)
	return string.format("#%.2X%.2X%.2X", r, g, b)
end