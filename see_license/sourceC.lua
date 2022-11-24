local screenX, screenY = guiGetScreenSize()

local availableAnswers = {}
local questionId = 0
local questionText = false
local correctAnswerId = false

function shuffleTable(array)
	for i = #array, 2, -1 do
		local j = math.random(i)
		array[i], array[j] = array[j], array[i]
	end
	
	return array
end

local quizMarker = false
local quizState = false
local quizStage = false

local correctAnswers = 0
local quizPercent = 0

local activeButton = false
local Roboto = false

local drivingTest = {
	markerElement = false,
	markerId = 1
}
local testVehicle = false
local pedTalkTimer = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		quizMarker = createMarker(-2032.3994140625, -116.8515625, 1034.171875, "cylinder", 2, 50, 179, 239, 160)
		
		if isElement(quizMarker) then
			setElementInterior(quizMarker, 3)
			setElementDimension(quizMarker, 34)
		end
	end)

addEventHandler("onClientMarkerHit", getResourceRootElement(),
	function (hitPlayer, matchingDimension)
		if hitPlayer == localPlayer and matchingDimension then
			if source == quizMarker then
				if not quizState then
					local carlicense = getElementData(localPlayer, "license.car") or 0

					createFonts()

					if carlicense then
						if carlicense == 0 then
							questionId = 0
							quizState = true
							quizStage = "startQuiz"
							correctAnswers = 0
							quizPercent = 0
						elseif carlicense == 1 then
							quizState = true
							quizStage = "drivingTest"
						end
					end
				end
			elseif source == drivingTest.startMarker then
				destroyElement(drivingTest.startMarker)
				triggerServerEvent("createLicenseVehicle", localPlayer)
			elseif source == drivingTest.markerElement then
				local pedveh = getPedOccupiedVehicle(localPlayer)

				if pedveh and pedveh == testVehicle then
					destroyElement(drivingTest.markerElement)

					if isElement(drivingTest.blipElement) then
						destroyElement(drivingTest.blipElement)
					end

					drivingTest.markerId = drivingTest.markerId + 1

					if drivingTest.markerId <= #waypoints then
						drivingTest.markerElement = createMarker(waypoints[drivingTest.markerId][1], waypoints[drivingTest.markerId][2], waypoints[drivingTest.markerId][3] - 1, "cylinder", 4, 215, 89, 89, 160)
						
						if isElement(drivingTest.markerElement) then
							drivingTest.blipElement = createBlip(waypoints[drivingTest.markerId][1], waypoints[drivingTest.markerId][2], waypoints[drivingTest.markerId][3], 0, 2, 215, 89, 89, 255, 0, 99999)
						end
					else
						if getElementHealth(pedveh) < 600 then
							exports.see_accounts:showInfo("e", "Megbuktál a vizsgán, mivel a járműved túlságosan sérült!")
						else
							exports.see_accounts:showInfo("s", "Gratulálok, sikeresen letetted az autóvezetői vizsgát!")
							
							setElementData(localPlayer, "license.car", 0)
							triggerServerEvent("giveDocument", localPlayer, 208)
						end

						triggerServerEvent("destroyLicenseVehicle", localPlayer)
						testVehicle = false

						if isTimer(pedTalkTimer) then
							killTimer(pedTalkTimer)
						end
						pedTalkTimer = nil
					end
				end
			end
		end
	end)

addEventHandler("onClientMarkerLeave", getResourceRootElement(),
	function (leftPlayer, matchingDimension)
		if leftPlayer == localPlayer then
			if source == quizMarker then
				if quizState then
					quizState = false
					destroyFonts()
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if testVehicle then
			checkSpeed()
		elseif quizState then
			local sx, sy = 430, 340
			local x = screenX / 2 - sx / 2
			local y = screenY / 2 - sy / 2
			local buttons = {}

			-- ** Háttér
			dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 160))

			-- ** Keret
			dxDrawRectangle(x - 3, y - 3, sx + (3 * 2), 3, tocolor(0, 0, 0, 200)) -- felső
			dxDrawRectangle(x - 3, y + sy, sx + (3 * 2), 3, tocolor(0, 0, 0, 200)) -- alsó
			dxDrawRectangle(x - 3, y, 3, sy, tocolor(0, 0, 0, 200)) -- bal
			dxDrawRectangle(x + sx, y, 3, sy, tocolor(0, 0, 0, 200)) -- jobb

			if quizStage == "startQuiz" then
				dxDrawText("Kedves vizsgázni vágyó tanuló!\n\nA sikeres autóvezetői engedély megszerzéséhez #d75959két\nvizsgát #ffffffis teljesíteni kell.\n #3d7abc- Elméleti vizsga\n#ffffff(Vizsgadíj: #32b3ef120$#ffffff)\n - #3d7abcGyakorlati vizsga\n#ffffff(Vizsgadíj: #32b3ef240$#ffffff)\n\nAz elméleti vizsgán #d7595910 kérdést #fffffffog kapni,\namiből legalább #3d7abc8-ra helyesen #ffffffkell válaszoljon.\n\nAmennyiben készen áll az elméleti vizsgára,\nnyomjon a #32b3ef\"Kezdés\" #ffffffgombra.\n#3d7abcSok sikert!", x, y, x + sx, y + sy - 40, tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)
			
				-- Mégsem
				local buttonWidth = (sx - 30) / 2
				local buttonHeight = 35

				buttons["decline"] = {x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight}
				if activeButton == "decline" then
					dxDrawRectangle(x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(215, 89, 89, 200))
				else
					dxDrawRectangle(x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(215, 89, 89, 150))
				end
				dxDrawText("Mégsem", x + 10, y + sy - 10 - buttonHeight, x + 10 + buttonWidth, y + sy - 10, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")

				-- Kezdés
				buttons["accept"] = {x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight}
				if activeButton == "accept" then
					dxDrawRectangle(x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(61, 122, 188, 150))
				end
				dxDrawText("Kezdés", x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, x + sx - 10, y + sy - 10, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")
			elseif quizStage == "quiz" then
				local buttonWidth = sx - 20
				local buttonHeight = 35

				dxDrawText(questionText, x + 10, y, x + sx - 20, y + sy - buttonHeight * 4 - 10 * 4, tocolor(255, 255, 255), 1, Roboto, "center", "center", false, true)

				for i = 1, 4 do
					local buttY = y + sy - (buttonHeight + 10) * i

					buttons["quiz" .. i] = {x + 10, buttY, buttonWidth, buttonHeight}
					if activeButton == "quiz" .. i then
						dxDrawRectangle(x + 10, buttY, buttonWidth, buttonHeight, tocolor(50, 179, 239, 200))
					else
						dxDrawRectangle(x + 10, buttY, buttonWidth, buttonHeight, tocolor(0, 50, 100, 150))
					end
					dxDrawText(availableAnswers[i], x + 10, buttY, x + 10 + buttonWidth, buttY + buttonHeight, tocolor(255, 255, 255), 0.7, Roboto, "center", "center")
				end
			elseif quizStage == "quizEnd" then
				if quizPercent < 10 then
					dxDrawText("Sajnos elrontottad a tesztet!\nMinimum 80%-ot kell elérned legközelebb\nEredményed: #d75959" .. quizPercent .. "%#ffffff\nAz újra gombra kattintva újra kezdheted a\ntesztet.\n\nEnnek díja további 120$.", x + 10, y + 15, x + sx - 20, y + sy - 30, tocolor(255, 255, 255), 1, Roboto, "center", "center", false, true, false, true)
				else
					dxDrawText("Sikeresen kitöltötted a tesztet!\nEredményed: #3d7abc" .. quizPercent .. "%#ffffff\nA tovább gombra kattintva elkezdheted a\ngyakorlati vizsgát.", x + 10, y + 15, x + sx - 20, y + sy - 30, tocolor(255, 255, 255), 1, Roboto, "center", "center", false, true, false, true)
				end

				local buttonWidth = (sx - 30) / 2
				local buttonHeight = 35

				buttons["cancel"] = {x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight}
				if activeButton == "cancel" then
					dxDrawRectangle(x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(215, 89, 89, 200))
				else
					dxDrawRectangle(x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(215, 89, 89, 150))
				end
				dxDrawText("Megszakítás", x + 10, y + sy - 10 - buttonHeight, x + 10 + buttonWidth, y + sy - 10, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")

				-- Kezdés
				buttons["ok"] = {x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight}
				if activeButton == "ok" then
					dxDrawRectangle(x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(61, 122, 188, 150))
				end
				if quizPercent < 10 then
					dxDrawText("Újra (120$)", x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, x + sx - 10, y + sy - 10, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")
				else
					dxDrawText("Tovább", x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, x + sx - 10, y + sy - 10, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")
				end
			elseif quizStage == "drivingTest" then
				dxDrawText("#3d7abcKedves vizsgázó!\n\n\n#ffffffMivel már rendelkezel egy #32b3efsikeres\nKRESZ vizsgával #ffffffezért a #3d7abc\"Kezdés\"\n#ffffffgombra kattintva azonnal elkezdheted\na #3d7abcgyakorlati vizsgát,\n#ffffffmelynek díja #d75959240$.", x + 10, y + 15, x + sx - 20, y + sy - 30, tocolor(255, 255, 255), 1, Roboto, "center", "center", false, true, false, true)
				
				local buttonWidth = (sx - 30) / 2
				local buttonHeight = 35

				buttons["cancel"] = {x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight}
				if activeButton == "cancel" then
					dxDrawRectangle(x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(215, 89, 89, 200))
				else
					dxDrawRectangle(x + 10, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(215, 89, 89, 150))
				end
				dxDrawText("Kilépés", x + 10, y + sy - 10 - buttonHeight, x + 10 + buttonWidth, y + sy - 10, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")

				-- Kezdés
				buttons["ok"] = {x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight}
				if activeButton == "ok" then
					dxDrawRectangle(x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, buttonWidth, buttonHeight, tocolor(61, 122, 188, 150))
				end
				dxDrawText("Kezdés", x + sx - 10 - buttonWidth, y + sy - 10 - buttonHeight, x + sx - 10, y + sy - 10, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")
			end

			local cx, cy = getCursorPosition()

			if tonumber(cx) then
				cx = cx * screenX
				cy = cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			else
				activeButton = false
			end
		end
	end)

local checkProcess = false

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if quizState then
			if not checkProcess then
				if button == "left" then
					if state == "up" then
						if activeButton then
							if quizStage == "startQuiz" then
								if activeButton == "accept" then
									triggerServerEvent("checkQuizTest", localPlayer)
									checkProcess = true
								elseif activeButton == "decline" then
									quizState = false
									destroyFonts()
								end
							elseif quizStage == "quiz" then
								if string.find(activeButton, "quiz") then
									local selected = string.gsub(activeButton, "quiz", "")
									local answerId = tonumber(selected)

									if correctAnswerId == availableAnswers[answerId] then
										correctAnswers = correctAnswers + 1
									end

									if questionId < #quizTable then
										pickQuizQuestion()
									else
										quizPercent = math.floor(correctAnswers / #quizTable * 100)
										
										if quizPercent >= 10 then
											exports.see_accounts:showInfo("s", "Sikeresen teljesítetted az elméleti tesztet. Most következzen a gyakorlati rész.")
											setElementData(localPlayer, "license.car", 1)
										else
											exports.see_accounts:showInfo("e", "Elrontottad a tesztet! Minimum 80%-ot kellet volna elérned!")
										end

										quizStage = "quizEnd"
									end
								end
							elseif quizStage == "quizEnd" then
								if activeButton == "ok" then
									if quizPercent < 10 then
										questionId = 0
										quizState = true
										correctAnswers = 0
										quizPercent = 0
										quizTable = shuffleTable(quizTable)
										pickQuizQuestion()
										quizStage = "quiz"
									else
										if getElementData(localPlayer, "license.car") == 1 then
											triggerServerEvent("checkDrivingTest", localPlayer)
											checkProcess = true
										end
									end
								elseif activeButton == "cancel" then
									quizState = false
									destroyFonts()
								end
							elseif quizStage == "drivingTest" then
								if activeButton == "ok" then
									if getElementData(localPlayer, "license.car") == 1 then
										triggerServerEvent("checkDrivingTest", localPlayer)
										checkProcess = true
									end
								elseif activeButton == "cancel" then
									quizState = false
									destroyFonts()
								end
							end
						end
					end
				end
			end
		end
	end)

addEvent("checkQuizTest", true)
addEventHandler("checkQuizTest", getRootElement(),
	function (result)
		if result == "Y" then
			quizTable = shuffleTable(quizTable)
			pickQuizQuestion()
			quizStage = "quiz"
		end

		checkProcess = false
	end)

addEvent("checkDrivingTest", true)
addEventHandler("checkDrivingTest", getRootElement(),
	function (result)
		if result == "Y" then
			quizState = false
			destroyFonts()
			startDrivingTest()
		end

		checkProcess = false
	end)

addEvent("startDrivingTest", true)
addEventHandler("startDrivingTest", getRootElement(),
	function (vehicleElement)
		if isTimer(pedTalkTimer) then
			killTimer(pedTalkTimer)
		end

		testVehicle = vehicleElement

		outputChatBox("#3d7abc* Oktató: #ffffffHa készen állsz, akkor indulhatunk!", 255, 255, 255, true)
		outputChatBox("#3d7abc* Oktató: #ffffffDe azért a kéziféket ne felejtsük el kiengedni!", 255, 255, 255, true)
		outputChatBox("#3d7abc(( ALT lenyomva, és az egeret előretolni a zöld mezőbe ))", 255, 255, 255, true)

		pedTalkTimer = setTimer(
			function ()
				if testVehicle then
					local pedveh = getPedOccupiedVehicle(localPlayer)

					if isElement(pedveh) and testVehicle == pedveh then
						outputChatBox("#3d7abc* Oktató: #ffffff" .. instructions[math.random(1, #instructions)], 255, 255, 255, true)
					end
				end
			end,
		30000, 0)

		drivingTest.overSpeed = 0
		drivingTest.noSeatbelt = 0
		drivingTest.markerElement = createMarker(waypoints[1][1], waypoints[1][2], waypoints[1][3] - 1, "cylinder", 4, 215, 89, 89, 160)
		drivingTest.markerId = 1

		if isElement(drivingTest.markerElement) then
			drivingTest.blipElement = createBlip(waypoints[1][1], waypoints[1][2], waypoints[1][3], 0, 2, 255, 0, 0, 255, 0, 99999)
		end
	end)

addEvent("destroyLicenseVehicle", true)
addEventHandler("destroyLicenseVehicle", getRootElement(),
	function ()
		testVehicle = false

		if isElement(drivingTest.markerElement) then
			destroyElement(drivingTest.markerElement)
		end

		if isElement(drivingTest.blipElement) then
			destroyElement(drivingTest.blipElement)
		end

		if isTimer(pedTalkTimer) then
			killTimer(pedTalkTimer)
		end
		pedTalkTimer = nil

		exports.see_accounts:showInfo("e", "Megbuktál a vizsgán!")
	end)

local seatBeltState = false

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "player.seatBelt" then
			seatBeltState = getElementData(localPlayer, "player.seatBelt")
		end
	end)

function startDrivingTest()
	if not isElement(drivingTest.startMarker) then
		drivingTest.startMarker = createMarker(876.6298828125, 2023.869140625, 9.8203125, "cylinder", 3, 50, 179, 239, 160)

		if isElement(drivingTest.startMarker) then
			outputChatBox("#3d7abc[StrongMTA]: #ffffffA vizsga megkezdéséhez menj bele az épület előtt található #32b3efmarkerbe#ffffff.", 255, 255, 255, true)
		end
	end
end

function checkSpeed()
	local pedveh = getPedOccupiedVehicle(localPlayer)

	if isElement(pedveh) then
		if pedveh == testVehicle then
			local velx, vely, velz = getElementVelocity(pedveh)
			local actualspeed = math.sqrt(velx*velx + vely*vely + velz*velz) * 187.5

			if actualspeed > 70 then
				if not isTimer(speedTimer) then
					speedTimer = setTimer(
						function ()
							local pedveh = getPedOccupiedVehicle(localPlayer)

							if isElement(pedveh) then
								if pedveh == testVehicle then
									local velx, vely, velz = getElementVelocity(pedveh)
									local actualspeed = math.sqrt(velx*velx + vely*vely + velz*velz) * 187.5

									if actualspeed > 70 then
										if drivingTest.overSpeed + 1 == 3 then
											if isElement(drivingTest.markerElement) then
												destroyElement(drivingTest.markerElement)
											end

											if isElement(drivingTest.blipElement) then
												destroyElement(drivingTest.blipElement)
											end

											if isTimer(pedTalkTimer) then
												killTimer(pedTalkTimer)
											end

											testVehicle = false
											triggerServerEvent("destroyLicenseVehicle", localPlayer)

											exports.see_accounts:showInfo("e", "Megbuktál, mert túl sokszor lépted át a megengedett sebességhatárt!")
										else
											exports.see_accounts:showInfo("e", "Túl gyorsan hajtasz (70km/h)! Ha így folytatod, akkor meg fogsz bukni!")
										end

										drivingTest.overSpeed = drivingTest.overSpeed + 1
									end
								end
							end
						end,
					5000, 1)

					outputChatBox("#3d7abc* Oktató: #ffffffHaver azt akarod, hogy megbuktassalak? LASSÍTS! Tartsd be a sebességet.", 255, 255, 255, true)
				end
			end
		end
	end

	if isElement(pedveh) then
		if pedveh == testVehicle then
			if not seatBeltState then
				if not isTimer(noSeatbeltTimer) then
					noSeatbeltTimer = setTimer(
						function ()
							local pedveh = getPedOccupiedVehicle(localPlayer)

							if isElement(pedveh) then
								if pedveh == testVehicle then
									if not drivingTest then
										if drivingTest.noSeatbelt + 1 == 4 then
											if isElement(drivingTest.markerElement) then
												destroyElement(drivingTest.markerElement)
											end

											if isElement(drivingTest.blipElement) then
												destroyElement(drivingTest.blipElement)
											end

											if isTimer(pedTalkTimer) then
												killTimer(pedTalkTimer)
											end

											testVehicle = false
											triggerServerEvent("destroyLicenseVehicle", localPlayer)

											exports.see_accounts:showInfo("e", "Megbuktál, mert nem volt bekötve az öved!")
										else
											exports.see_accounts:showInfo("e", "Nincs bekötve az öved! Ha így folytatod, akkor meg fogsz bukni!")
										end

										drivingTest.noSeatbelt = drivingTest.noSeatbelt + 1
									end
								end
							end
						end,
					15000, 1)

					outputChatBox("#3d7abc* Oktató: #ffffffHaver azt akarod, hogy megbuktassalak? Kösd be az övedet! ((F5))", 255, 255, 255, true)
				end
			end
		end
	end
end

function pickQuizQuestion()
	questionId = questionId + 1
	questionText = quizTable[questionId][1]
	correctAnswerId = quizTable[questionId][quizTable[questionId][6] + 1]
	availableAnswers = {}

	--outputDebugString("válasz: " .. correctAnswerId)

	local answerIds = shuffleTable({1, 2, 3, 4})

	for i = 1, 4 do
		availableAnswers[i] = quizTable[questionId][1 + answerIds[i]]
	end
end

function createFonts()
	destroyFonts()
	Roboto = dxCreateFont("files/Roboto.ttf", 14, false, "antialiased")
end

function destroyFonts()
	if isElement(Roboto) then
		destroyElement(Roboto)
	end
	Roboto = nil
end