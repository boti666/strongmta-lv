local localConnection = false
local connectionReady = false

local dragRace = false
local topTimes = {}

local raceEntryMarker = createMarker(412.0769, 2502.5837, 14, "cylinder", 3, 255, 255, 255, 200)
local raceEntryColShape = createColSphere(412.0769, 2502.5837, 16, 1.75)

local singlePlayerTimer = false
local countDownTimer = false
local newRaceTimer = false

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		localConnection = exports.see_database:getConnection()

		if localConnection then
			dbQuery(
				function (queryHandle)
					local result = dbPoll(queryHandle, 0)

					if result then
						topTimes = {}

						for i = 1, #result do
							topTimes[i] = result[i]
						end

						refreshToplist()
					end

					connectionReady = true
				end,
			localConnection, "SELECT * FROM toplist")
		end
	end
)

function refreshToplist()
	local raceToplist = {}

	for i = 1, displayTopCount do
		if topTimes[i] then
			raceToplist[i] = topTimes[i]
		end
	end

	table.sort(raceToplist,
		function (a, b)
			return a.elapsed_time < b.elapsed_time
		end
	)

	setElementData(resourceRoot, "dragRaceToplist", raceToplist)
end

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		if connectionReady then
			dbExec(localConnection, "DELETE FROM toplist")

			if #topTimes > 0 then
				for i, v in ipairs(topTimes) do
					dbExec(localConnection, "INSERT INTO toplist (character_id, character_name, car_name, elapsed_time, speed, date_recorded) VALUES (?,?,?,?,?,?)", v.character_id, v.character_name, v.car_name, v.elapsed_time, v.speed, v.date_recorded)
				end
			end
		end

		removeElementData(resourceRoot, "dragRace")
		removeElementData(resourceRoot, "dragRaceToplist")
	end
)

addEvent("dragRaceDone", true)
addEventHandler("dragRaceDone", getRootElement(),
	function (elapsedTime, racerDetails, maximumSpeed)
		if elapsedTime then
			-- Ha nem DNF
			if tonumber(elapsedTime) then
				-- A jelenlegi "saját legjobb" record megkeresése
				local characterId = getElementData(racerDetails[4], "char.ID")
				local currentBest = false

				for i = 1, #topTimes do
					if characterId == topTimes[i].character_id then
						currentBest = topTimes[i]
						break
					end
				end

				-- Ha nincs még record, beszúrunk neki egy újat
				local realTime = getRealTime()
				local dateTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)
				local timeMs = elapsedTime * 1000

				if not currentBest then
					table.insert(topTimes, {
						character_id = characterId,
						character_name = racerDetails[3],
						car_name = racerDetails[2],
						elapsed_time = timeMs,
						speed = maximumSpeed,
						date_recorded = dateTime
					})
					currentBest = topTimes[#topTimes]
				end

				-- Összehasonlítjuk a jelenlegi saját legjobb rekordot a mostani értékekkel, ha jobb, frissítjük a táblában
				local isNewBest = false

				if timeMs == currentBest.elapsed_time then
					if dateTime < currentBest.date_recorded then
						isNewBest = true
					end
				elseif timeMs < currentBest.elapsed_time then
					isNewBest = true
				end

				if isNewBest then
					currentBest.character_name = racerDetails[3]
					currentBest.car_name = racerDetails[2]
					currentBest.elapsed_time = timeMs
					currentBest.speed = maximumSpeed
					currentBest.date_recorded = dateTime

					local seconds = math.floor(timeMs / 1000)
					local milliseconds = math.floor((timeMs / 1000 - seconds) * 1000)

					for j = 3, utf8.len(milliseconds) + 1, -1 do
						milliseconds = "0" .. milliseconds
					end

					outputChatBox("#3d7abc[StrongMTA - Drag]: #FFFFFFÚj egyéni rekord!", source, 255, 255, 255, true)
					outputChatBox("#3d7abc[StrongMTA - Drag]: #FFFFFFIdő: #ff9900" .. seconds .. "." .. milliseconds .. "s#FFFFFF, Sebesség: #ff9900" .. maximumSpeed .. " km/h", source, 255, 255, 255, true)
				end

				refreshToplist()
			end

			-- versenyzők ellenőrzése, ha mindenki célba ért, verseny leállítása
			if dragRace then
				local finishedCounter = 0

				for i = 1, #dragRace[2] do
					local v = dragRace[2][i]

					if v then
						if racerDetails[4] == v[4] then
							v[5] = "done"
						end

						if v[5] == "done" then -- ha a játékos befejezte a versenyt
							finishedCounter = finishedCounter + 1
						else
							if not isElement(v[4]) then -- ha a játékos közben kilépett
								finishedCounter = finishedCounter + 1
							end
						end
					end
				end

				if finishedCounter >= #dragRace[2] then
					if isTimer(newRaceTimer) then
						killTimer(newRaceTimer)
					end

					newRaceTimer = setTimer(
						function ()
							setElementData(resourceRoot, "dragRace", false)
							dragRace = false
						end,
					5000, 1)
				end
			end
		end
	end
)

addEventHandler("onColShapeHit", raceEntryColShape,
	function (hitElement, matchingDimension)
		if matchingDimension then
			if isElement(hitElement) then
				if getElementType(hitElement) == "player" then
					local pedVehicle = getPedOccupiedVehicle(hitElement)

					if pedVehicle then
						if getVehicleController(pedVehicle) == hitElement then
							if not dragRace or not dragRace[1] then
								local alreadyJoined = false

								if dragRace then
									for i = 1, #dragRace[2] do
										local v = dragRace[2][i]

										if v then
											if hitElement == v[4] then
												alreadyJoined = true
												break
											end
										end
									end
								end

								if not alreadyJoined then
									addPlayerToRace(hitElement)
								end
							end
						end
					end
				end
			end
		end
	end
)

function addPlayerToRace(player)
	if isElement(player) and client and client == player then
		local vehicle = getPedOccupiedVehicle(player)

		if isElement(vehicle) then
			if not dragRace then
				dragRace = {}
				dragRace[1] = false -- visszaszámláló
				dragRace[2] = {} -- versenyzők
			end

			local selectedLane = false

			if not dragRace[2][1] then
				selectedLane = 1
			elseif not dragRace[2][2] then
				selectedLane = 2
			end

			if selectedLane then
				local vehicleName = exports.see_vehiclenames:getCustomVehicleName(getElementModel(vehicle))
				local characterName = getElementData(player, "char.Name"):gsub("_", " ")

				setElementFrozen(vehicle, true)
				setElementRotation(vehicle, 0, 0, 90)
				exports.see_controls:toggleControl(player, {"accelerate", "brake_reverse"}, false)
				setCameraTarget(player, player)

				if selectedLane == 1 then
					setElementPosition(vehicle, 394, 2505.6602, 16.5)
				elseif selectedLane == 2 then
					setElementPosition(vehicle, 394, 2499.4851, 16.5)
				end

				local vehicleCounter = 0

				dragRace[2][selectedLane] = {vehicle, vehicleName, characterName, player}

				for i = 1, 2 do
					if dragRace[2][i] then
						if isElement(dragRace[2][i][1]) then
							vehicleCounter = vehicleCounter + 1
						end
					end
				end

				if isTimer(singlePlayerTimer) then
					killTimer(singlePlayerTimer)
				end

				if isTimer(countDownTimer) then
					killTimer(countDownTimer)
				end

				if vehicleCounter == 1 then
					singlePlayerTimer = setTimer(
						function ()
							countDownTimer = setTimer(countDownRecursive, 1000, 1, 3)
						end,
					raceWaitingTime * 1000, 1)
				elseif vehicleCounter == 2 then
					countDownTimer = setTimer(countDownRecursive, 1000, 1, 3)
				end

				setElementData(resourceRoot, "dragRace", dragRace)
			end
		end
	end
end

function countDownRecursive(count)
	if dragRace then
		if not dragRace[1] then
			for i = 1, #dragRace[2] do
				local v = dragRace[2][i]

				if v then
					if isElement(v[1]) then
						setElementFrozen(v[1], false)
					end

					if isElement(v[4]) then
						exports.see_controls:toggleControl(v[4], {"accelerate", "brake_reverse"}, true)
					end
				end
			end
		end

		dragRace[1] = count
		setElementData(resourceRoot, "dragRace", dragRace)

		if count - 1 >= 0 then
			if isTimer(countDownTimer) then
				killTimer(countDownTimer)
			end

			countDownTimer = setTimer(countDownRecursive, 1000, 1, count - 1)
		end
	else
		if isTimer(singlePlayerTimer) then
			killTimer(singlePlayerTimer)
		end

		if isTimer(countDownTimer) then
			killTimer(countDownTimer)
		end
	end
end
