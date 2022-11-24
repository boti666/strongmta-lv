local innerColShape = createColSphere(186.26443481445, 2501.3564453125, 16.484375, 350)
local inColShape = false

local lineTexture = dxCreateTexture("files/white.png", "dxt1")
local tireTexture = dxCreateTexture("files/tire.png")

local dragRace = false
local joinTime = false
local raceData = false
local isRaceStarted = false

local renderTarget = dxCreateRenderTarget(512, 288)
local shaderElement = dxCreateShader("files/texturechanger.fx")
local boardFont = dxCreateFont("files/ocr.ttf", 40, false, "antialiased")

local coronaMarkers = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if isElement(renderTarget) then
			if isElement(shaderElement) then
				dxSetShaderValue(shaderElement, "gTexture", renderTarget)
				engineApplyShaderToWorldTexture(shaderElement, "cj_airp_s_2")
			end
		end

		if isInsideColShape(innerColShape, getElementPosition(localPlayer)) then
			inColShape = true
		end

		renderTheScoreBoard()
	end
)

function deleteMarkers(state)
	if coronaMarkers[1] then
		exports.custom_coronas:destroyCorona(coronaMarkers[1])
		coronaMarkers[1] = false
	end

	if coronaMarkers[2] then
		exports.custom_coronas:destroyCorona(coronaMarkers[2])
		coronaMarkers[2] = false
	end

	if coronaMarkers[3] then
		exports.custom_coronas:destroyCorona(coronaMarkers[3])
		coronaMarkers[3] = false
	end

	if coronaMarkers[4] then
		exports.custom_coronas:destroyCorona(coronaMarkers[4])
		coronaMarkers[4] = false
	end

	if coronaMarkers[5] then
		exports.custom_coronas:destroyCorona(coronaMarkers[5])
		coronaMarkers[5] = false
	end

	if coronaMarkers[6] then
		exports.custom_coronas:destroyCorona(coronaMarkers[6])
		coronaMarkers[6] = false
	end

	if coronaMarkers[7] then
		exports.custom_coronas:destroyCorona(coronaMarkers[7])
		coronaMarkers[7] = false
	end

	if coronaMarkers[8] then
		exports.custom_coronas:destroyCorona(coronaMarkers[8])
		coronaMarkers[8] = false
	end

	if coronaMarkers[9] and state ~= "onstart" then
		exports.custom_coronas:destroyCorona(coronaMarkers[9])
		coronaMarkers[9] = false
	end

	if coronaMarkers[10] and state ~= "onstart" then
		exports.custom_coronas:destroyCorona(coronaMarkers[10])
		coronaMarkers[10] = false
	end
end

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		deleteMarkers()
	end
)

addEventHandler("onClientColShapeHit", innerColShape,
	function (theElement, matchingDimension)
		if theElement == localPlayer then
			if matchingDimension then
				inColShape = true
				renderTheScoreBoard()
			end
		end
	end
)

addEventHandler("onClientColShapeLeave", innerColShape,
	function (theElement, matchingDimension)
		if theElement == localPlayer then
			inColShape = false
			deleteMarkers()
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if inColShape then
			dxDrawMaterialLine3D(391, 2509.0622558594, 15.525, 391, 2496.1975097656, 15.525, lineTexture, 0.2, tocolor(255, 255, 255), 391, 2502.6298828125, 16.525)
			dxDrawMaterialLine3D(-8.6, 2509.0622558594, 15.525, -8.6, 2496.1975097656, 15.525, lineTexture, 0.2, tocolor(255, 255, 255), -8.6, 2502.6298828125, 16.525)

			dxDrawMaterialLine3D(387.2, 2505.8, 15.525, 404.075, 2505.8, 15.525, tireTexture, 3, tocolor(255, 255, 255, 100), 395.6375, 2505.8, 16.525)
			dxDrawMaterialLine3D(386.90313720703, 2505.6953125, 15.525, 404.075, 2505.6953125, 15.525, tireTexture, 2.55, tocolor(255, 255, 255, 125), 395.48906860351497, 2505.6953125, 16.525)
			dxDrawMaterialLine3D(386.50313720703, 2499.25, 15.525, 404.075, 2499.25, 15.525, tireTexture, 3, tocolor(255, 255, 255, 100), 395.28906860351503, 2499.25, 16.525)
			dxDrawMaterialLine3D(386.90313720703, 2499.4953125, 15.525, 404.075, 2499.4953125, 15.525, tireTexture, 2.55, tocolor(255, 255, 255, 125), 395.48906860351497, 2499.4953125, 16.525)

			dxDrawMaterialLine3D(-60, 2505.8, 15.525, -8.9, 2505.8, 15.525, tireTexture, 3, tocolor(255, 255, 255, 100), 16.6, 2505.8, 16.525)
			dxDrawMaterialLine3D(-60, 2505.6953125, 15.525, -9, 2505.6953125, 15.525, tireTexture, 2.55, tocolor(255, 255, 255, 125), 16.5, 2505.6953125, 16.525)
			dxDrawMaterialLine3D(-60, 2499.25, 15.525, -9.2, 2499.25, 15.525, tireTexture, 3, tocolor(255, 255, 255, 100), 16.2, 2499.25, 16.525)
			dxDrawMaterialLine3D(-60, 2499.4953125, 15.525, -9, 2499.4953125, 15.525, tireTexture, 2.55, tocolor(255, 255, 255, 125), 16.5, 2499.4953125, 16.525)

			if raceData then
				if raceData[1] then
					raceData[4] = (getTickCount() - raceData[1]) / 1000
				end

				local numOfFinishedPlayers = 0

				for i = 1, #dragRace[2] do
					if raceData[i + 1] then
						local vehicle = dragRace[2][i][1]

						if isElement(vehicle) then
							local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
							local velocityX, velocityY, velocityZ = getElementVelocity(vehicle)
							local vehicleSpeed = math.floor(math.sqrt(velocityX * velocityX + velocityY * velocityY) * 187.5)

							-- Megtett táv
							if 394 - vehicleX > raceData[i + 1] then
								raceData[i + 1] = 394 - vehicleX
							end

							-- Legnagyobb elért sebesség
							if vehicleSpeed > raceData[i + 4] then
								raceData[i + 4] = vehicleSpeed
							end

							-- Cél
							if raceData[i + 1] >= 400 then
								raceData[i + 1] = false
								raceData[i + 6] = raceData[4]

								if getVehicleOccupant(vehicle, 0) == localPlayer then
									triggerServerEvent("dragRaceDone", localPlayer, raceData[4], dragRace[2][i], raceData[i + 4])
								end
							end

							-- Diszkvalifikáció
							local didNotFinish = false

							if 404 - vehicleX < 0 then -- ha visszatolatott a rajttól
								didNotFinish = true
							end

							if not raceData[1] and raceData[i + 4] > 0 then -- ha még nem indult el a verseny, és gázt adtunk
								didNotFinish = true
							end

							if didNotFinish then
								raceData[i + 1] = false

								if getVehicleOccupant(vehicle, 0) == localPlayer then
									triggerServerEvent("dragRaceDone", localPlayer, "dnf", dragRace[2][i])
								end

								if i == 1 then
									coronaMarkers[9] = exports.custom_coronas:createCorona(380.55, 2502.775, 18.9, 0.25, 255, 0, 0, 255)

									if coronaMarkers[4] then
										exports.custom_coronas:destroyCorona(coronaMarkers[4])
										coronaMarkers[4] = false
									end

									if coronaMarkers[6] then
										exports.custom_coronas:destroyCorona(coronaMarkers[6])
										coronaMarkers[6] = false
									end

									if coronaMarkers[8] then
										exports.custom_coronas:destroyCorona(coronaMarkers[8])
										coronaMarkers[8] = false
									end
								else
									coronaMarkers[10] = exports.custom_coronas:createCorona(380.55, 2502.125, 18.9, 0.25, 255, 0, 0, 255)

									if coronaMarkers[3] then
										exports.custom_coronas:destroyCorona(coronaMarkers[3])
										coronaMarkers[3] = false
									end

									if coronaMarkers[5] then
										exports.custom_coronas:destroyCorona(coronaMarkers[5])
										coronaMarkers[5] = false
									end

									if coronaMarkers[7] then
										exports.custom_coronas:destroyCorona(coronaMarkers[7])
										coronaMarkers[7] = false
									end
								end
							end
						end
					else
						numOfFinishedPlayers = numOfFinishedPlayers + 1
					end

					if numOfFinishedPlayers >= #dragRace[2] then
						raceData[1] = false
						raceData[4] = false
					end
				end

				if isRaceStarted then
					renderTheScoreBoard("rendering")
				end
			end

			if joinTime then
				renderTheScoreBoard("rendering")
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getResourceRootElement(),
	function (dataName)
		if dataName == "dragRace" or dataName == "dragRaceToplist" then
			if inColShape then
				renderTheScoreBoard()
			end
		end
	end
)

addEventHandler("onClientRestore", getRootElement(),
	function (didClearRenderTargets)
		if didClearRenderTargets then
			if inColShape then
				renderTheScoreBoard()
			end
		end
	end
)

function renderTheScoreBoard(state)
	dxSetRenderTarget(renderTarget)

	if state ~= "rendering" then
		dragRace = getElementData(resourceRoot, "dragRace")
	end

	dxDrawRectangle(0, 0, 512, 288, tocolor(0, 0, 0))
	dxDrawImage(0, 0, 512, 288, "files/screen.png", 0, 0, 0, tocolor(255, 255, 255, 150))

	if dragRace then
		if dragRace[1] then
			if dragRace[1] > 0 then
				dxDrawText(dragRace[1], 0, 0, 512, 64, tocolor(255, 200, 0), 1, boardFont, "center", "center", false, false, false, true)

				joinTime = false

				if not raceData then
					raceData = {false, 0, 0, 0, 0, 0}
				end

				deleteMarkers("onstart")

				if dragRace[1] == 3 then
					coronaMarkers[2] = exports.custom_coronas:createCorona(380.55, 2502.45, 20.9, 0.25, 255, 127, 0, 255)
				elseif dragRace[1] == 2 then
					if raceData[3] then
						coronaMarkers[3] = exports.custom_coronas:createCorona(380.55, 2502.125, 20.4, 0.25, 255, 127, 0, 255)
					end

					if raceData[2] then
						coronaMarkers[4] = exports.custom_coronas:createCorona(380.55, 2502.775, 20.4, 0.25, 255, 127, 0, 255)
					end
				elseif dragRace[1] == 1 then
					if raceData[3] then
						coronaMarkers[5] = exports.custom_coronas:createCorona(380.55, 2502.125, 19.9, 0.25, 255, 127, 0, 255)
					end

					if raceData[2] then
						coronaMarkers[6] = exports.custom_coronas:createCorona(380.55, 2502.775, 19.9, 0.25, 255, 127, 0, 255)
					end
				end

				setSoundMaxDistance(playSound3D("files/lamp.mp3", 380, 2502, 20), 100)
			else
				if not isRaceStarted then
					deleteMarkers("onstart")

					if raceData[3] then
						coronaMarkers[7] = exports.custom_coronas:createCorona(380.55, 2502.125, 19.4, 0.25, 0, 255, 0, 255)
					end

					if raceData[2] then
						coronaMarkers[8] = exports.custom_coronas:createCorona(380.55, 2502.775, 19.4, 0.25, 0, 255, 0, 255)
					end

					isRaceStarted = true
					raceData[1] = getTickCount()

					setSoundMaxDistance(playSound3D("files/start.mp3", 380, 2502, 20), 100)
				end

				if raceData[4] then
					local seconds = math.floor(raceData[4])
					local milliseconds = math.floor((raceData[4] - seconds) * 1000)

					for j = 3, utf8.len(milliseconds) + 1, -1 do
						milliseconds = "0" .. milliseconds
					end

					dxDrawText(seconds .. "." .. milliseconds .. " s", 0, 0, 512, 64, tocolor(255, 200, 0), 0.75, boardFont, "center", "center", false, false, false, true)
				else
					dxDrawText("Vége", 0, 0, 512, 64, tocolor(255, 200, 0), 0.75, boardFont, "center", "center", false, false, false, true)
				end
			end
		else
			if not joinTime then
				joinTime = getTickCount()
				deleteMarkers()
				coronaMarkers[1] = exports.custom_coronas:createCorona(380.55, 2502.45, 18.3, 0.25, 255, 127, 0, 255)
			end

			local elapsedTime = getTickCount() - joinTime
			local remainingTime = raceWaitingTime - math.floor(elapsedTime / 1000)

			if remainingTime < 0 then
				remainingTime = 0
			end

			local minutes = math.floor(remainingTime / 60)
			local seconds = remainingTime - minutes * 60

			for i = 2, utf8.len(seconds) + 1, -1 do
				seconds = "0" .. seconds
			end

			dxDrawText("Várakozás a második versenyzőre...\n" .. minutes .. ":" .. seconds, 0, 0, 512, 64, tocolor(255, 200, 0), 0.3, boardFont, "center", "center", false, false, false, true)
		end

		dxDrawLine(0, 64, 512, 64, tocolor(255, 200, 0), 2)
		dxDrawLine(256, 64, 256, 288, tocolor(255, 200, 0), 2)

		-- verseny alatt
		if not raceData or raceData[2] then
			local distance = "000"
			local speed = "000"

			if raceData then
				distance = math.floor(raceData[2])
				speed = math.floor(raceData[5])

				for i = 3, utf8.len(distance) + 1, -1 do
					distance = "0" .. distance
				end

				for i = 3, utf8.len(speed) + 1, -1 do
					speed = "0" .. speed
				end
			end

			dxDrawText(distance .. " m", 256, 64, 512, 128, tocolor(255, 200, 0), 1, boardFont, "center", "center", false, false, false, true)
			dxDrawText(speed .. " km/h", 256, 128, 512, 192, tocolor(255, 200, 0), 0.5, boardFont, "center", "center", false, false, false, true)
		-- verseny vége
		elseif raceData[7] then
			local seconds = math.floor(raceData[7])
			local milliseconds = math.floor((raceData[7] - seconds) * 1000)

			for j = 3, utf8.len(milliseconds) + 1, -1 do
				milliseconds = "0" .. milliseconds
			end

			local speed = "000"

			if raceData then
				speed = math.floor(raceData[5])

				for i = 3, utf8.len(speed) + 1, -1 do
					speed = "0" .. speed
				end
			end

			dxDrawText(seconds .. "." .. milliseconds .. " s\n" .. speed .. " km/h", 256, 104, 512, 128, tocolor(255, 200, 0), 0.7, boardFont, "center", "center", false, false, false, true)
		else
			dxDrawText("Start\nfailed", 256, 104, 512, 128, tocolor(255, 200, 0), 0.8, boardFont, "center", "center", false, false, false, true)
		end

		dxDrawText(dragRace[2][1][2], 256, 224, 512, 256, tocolor(255, 200, 0), 0.35, boardFont, "center", "center", false, false, false, true)
		dxDrawText(dragRace[2][1][3], 256, 256, 512, 288, tocolor(255, 200, 0), 0.2, boardFont, "center", "center", false, false, false, true)

		if raceData then
			-- verseny alatt
			if raceData[3] then
				local distance = math.floor(raceData[3])
				local speed = math.floor(raceData[6])

				for i = 3, utf8.len(distance) + 1, -1 do
					distance = "0" .. distance
				end

				for i = 3, utf8.len(speed) + 1, -1 do
					speed = "0" .. speed
				end

				dxDrawText(distance .. " m", 0, 64, 256, 128, tocolor(255, 200, 0), 1, boardFont, "center", "center", false, false, false, true)
				dxDrawText(speed .. " km/h", 0, 128, 256, 192, tocolor(255, 200, 0), 0.5, boardFont, "center", "center", false, false, false, true)
			-- verseny vége
			elseif raceData[8] then
				local seconds = math.floor(raceData[8])
				local milliseconds = math.floor((raceData[8] - seconds) * 1000)

				for j = 3, utf8.len(milliseconds) + 1, -1 do
					milliseconds = "0" .. milliseconds
				end

				local speed = "000"

				if raceData then
					speed = math.floor(raceData[6])

					for i = 3, utf8.len(speed) + 1, -1 do
						speed = "0" .. speed
					end
				end

				dxDrawText(seconds .. "." .. milliseconds .. " s\n" .. speed .. " km/h", 0, 104, 256, 128, tocolor(255, 200, 0), 0.7, boardFont, "center", "center", false, false, false, true)
			else
				dxDrawText("Start\nfailed", 0, 104, 256, 128, tocolor(255, 200, 0), 0.8, boardFont, "center", "center", false, false, false, true)
			end

			if dragRace[2][2] then
				dxDrawText(dragRace[2][2][2], 0, 224, 256, 256, tocolor(255, 200, 0), 0.35, boardFont, "center", "center", false, false, false, true)
				dxDrawText(dragRace[2][2][3], 0, 256, 256, 288, tocolor(255, 200, 0), 0.2, boardFont, "center", "center", false, false, false, true)
			end
		elseif dragRace[1] then
			dxDrawText("000 m", 0, 64, 256, 128, tocolor(255, 200, 0), 1, boardFont, "center", "center", false, false, false, true)
			dxDrawText("000 km/h", 0, 128, 256, 192, tocolor(255, 200, 0), 0.5, boardFont, "center", "center", false, false, false, true)

			if dragRace[2][2] then
				dxDrawText(dragRace[2][2][2], 0, 224, 256, 256, tocolor(255, 200, 0), 0.35, boardFont, "center", "center", false, false, false, true)
				dxDrawText(dragRace[2][2][3], 0, 256, 256, 288, tocolor(255, 200, 0), 0.2, boardFont, "center", "center", false, false, false, true)
			end
		end
	else
		dxDrawText("Top", 0, 0, 512, 60, tocolor(255, 200, 0), 0.6, boardFont, "center", "center", false, false, false, true)
		dxDrawLine(0, 60, 512, 60, tocolor(255, 200, 0), 2)

		local topList = getElementData(resourceRoot, "dragRaceToplist") or {}
		local oneSize = (288 - 64) / displayTopCount

		for i = 1, displayTopCount do
			local v = topList[i]
			local y = 64 + oneSize * (i - 1)

			if v then
				local seconds = math.floor(v.elapsed_time / 1000)
				local milliseconds = math.floor((v.elapsed_time / 1000 - seconds) * 1000)

				for j = 3, utf8.len(milliseconds) + 1, -1 do
					milliseconds = "0" .. milliseconds
				end

				dxDrawText(i .. ". " .. utf8.sub(v.character_name, 1, 14), 5, y, 0, y + oneSize, tocolor(255, 200, 0), 0.25, boardFont, "left", "center", false, false, false, true)
				dxDrawText(utf8.sub(v.car_name, 1, 14), 200, y, 0, y + oneSize, tocolor(255, 200, 0), 0.25, boardFont, "left", "center", false, false, false, true)

				dxDrawText(seconds .. "." .. milliseconds .. "s", 345, y, 0, y + oneSize, tocolor(255, 200, 0), 0.25, boardFont, "left", "center", false, false, false, true)
				dxDrawText(v.speed .. "km/h", 425, y, 0, y + oneSize, tocolor(255, 200, 0), 0.25, boardFont, "left", "center", false, false, false, true)
			end
		end

		joinTime = false
		raceData = false
		isRaceStarted = false
		deleteMarkers()
	end

	dxSetRenderTarget()
end
