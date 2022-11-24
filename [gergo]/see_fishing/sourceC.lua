local screenX, screenY = guiGetScreenSize()

local Roboto = dxCreateFont("files/fonts/Roboto.ttf", 12, false, "antialiased")

local rodThrowed = false
local throwPosition = {}
setElementData(localPlayer, "endingFishing", true)

local fishingRodObjects = {}
local playerFloaters = {}
local playerFloaterStopped = {}

local catchTickTimer = false
local catchSound = false

local balanceMinigame = {}
local minigameInProgress = false
local minigameTick = false
local minigameState = false
local minigameStage = 0

local minigameBarWidth = 25
local minigameBarHeight = 250
local minigameBarPosX = screenX - minigameBarWidth - 20
local minigameBarPosY = (screenY / 2) - (minigameBarHeight / 2)

local headNotifications = {}
local playerCatchSounds = {}

local weightedItems = {
	[1] = {
		[247] = 25,
		[359] = 150,
		[359] = 150,
		[226] = 200,
		[250] = 200,
		[251] = 200,
		[252] = 200,
		[255] = 200,
		[261] = 200,
		[221] = 200,
		[351] = 200,
		[352] = 200,
		[353] = 250,
		[354] = 200,
		[222] = 350,
		[223] = 350,
		[224] = 350,
		[225] = 350,
		[256] = 350,
		[246] = 350,
		[217] = 400,
		[218] = 400,
		[219] = 400,
		[220] = 400,
		[249] = 400,
		[257] = 400,
		[258] = 400,
		[227] = 500,
		[228] = 500,
		[229] = 500,
		[230] = 500,
		[231] = 500,
		[248] = 500
	},
	[2] = {
		[224] = 300,
		[225] = 300,
		[356] = 300,
		[357] = 300,
		[217] = 450,
		[218] = 450,
		[219] = 450,
		[220] = 450,
		[249] = 450,
		[257] = 450,
		[258] = 450,
		[227] = 500,
		[228] = 500,
		[229] = 500,
		[230] = 500,
		[231] = 500,
		[248] = 500
	},
	[3] = {
		[224] = 200,
		[225] = 200,
		[217] = 475,
		[218] = 475,
		[219] = 475,
		[220] = 475,
		[249] = 475,
		[257] = 475,
		[258] = 475,
		[227] = 525,
		[228] = 525,
		[229] = 525,
		[230] = 525,
		[231] = 525,
		[248] = 525
	},
	[4] = {
		[217] = 475,
		[218] = 475,
		[219] = 475,
		[220] = 475,
		[249] = 475,
		[257] = 475,
		[258] = 475,
		[358] = 475,
		[227] = 520,
		[228] = 520,
		[229] = 520,
		[230] = 520
	},
	[5] = {
		[363] = 155,
		[351] = 225,
		[352] = 225,
		[353] = 250,
		[354] = 225,
		[222] = 350,
		[223] = 350,
		[224] = 350,
		[225] = 350,
		[256] = 350,
		[246] = 350,
		[217] = 400,
		[218] = 400,
		[219] = 400,
		[220] = 400,
		[249] = 400,
		[257] = 400,
		[258] = 400,
		[227] = 520,
		[228] = 520,
		[229] = 520,
		[230] = 520
	}
}

function chooseRandomItem(inputTable)
	local totalWeight = 0

	for k, v in pairs(inputTable) do
		totalWeight = totalWeight + v
	end

	local randomWeight = math.random(totalWeight)
	local currentWeight = 0

	for k, v in pairs(inputTable) do
		currentWeight = currentWeight + v

		if randomWeight <= currentWeight then
			return k
		end
	end

	return false
end

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if minigameInProgress or balanceMinigame.preStart then
			if string.find(key, "mouse") then
				cancelEvent()
			end
		end
	end,
true, "high+99999")

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absoluteX, absoluteY)
		if button == "left" then
			if state == "up" then
				if getElementData(localPlayer, "fishingRodInHand") then
					if not isElementInWater(localPlayer) then
						if not isPedInVehicle(localPlayer) then
							if not rodThrowed then
								if not playerFloaters[localPlayer] then
									local worldPosX, worldPosY, worldPosZ = getWorldFromScreenPosition(absoluteX, absoluteY, 100)

									if worldPosX and worldPosY and worldPosZ then
										local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
										local cameraPosX, cameraPosY, cameraPosZ = getCameraMatrix()
										local waterHit, waterPosX, waterPosY, waterPosZ = testLineAgainstWater(cameraPosX, cameraPosY, cameraPosZ, worldPosX, worldPosY, worldPosZ)

										if waterHit then
											if isLineOfSightClear(cameraPosX, cameraPosY, cameraPosZ, waterPosX, waterPosY, waterPosZ, true, false, false, true, false) then
												local distanceBetweenPoints = getDistanceBetweenPoints3D(waterPosX, waterPosY, waterPosZ, playerPosX, playerPosY, playerPosZ)

												if distanceBetweenPoints > 5 and distanceBetweenPoints < 20 then
													triggerServerEvent("throwInRod", localPlayer, waterPosX, waterPosY, waterPosZ)
													rodThrowed = true
												elseif distanceBetweenPoints <= 5 then
													exports.see_hud:showInfobox("e", "Ilyen közelre nem tudod eldobni!")
												else
													exports.see_hud:showInfobox("e", "Ilyen messzire nem tudod eldobni!")
												end
											end
										else
											exports.see_hud:showInfobox("e", "Itt nem tudod használni!")
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

function moveFloaterTimer(player, state)
	if not playerFloaterStopped[player] or not state then
		if isElement(playerFloaters[player]) then
			local floaterX, floaterY, floaterZ = getElementPosition(playerFloaters[player])

			if state then
				moveObject(playerFloaters[player], 2000, floaterX, floaterY, floaterZ - 0.5, 0, 0, 0, "InElastic", 0.3, 0.5)
			else
				moveObject(playerFloaters[player], 2000, floaterX, floaterY, floaterZ + 0.5, 0, 0, 0, "InElastic", 0.3, 0.5)
			end

			if not playerFloaterStopped[player] then
				setTimer(moveFloaterTimer, 2000, 1, player, not state)
			else
				setTimer(moveFloater2Timer, 2000, 1, player, true)
			end
		end
	else
		moveFloater2Timer(player, true)
	end
end

function moveFloater2Timer(player, state)
	if isElement(playerFloaters[player]) then
		local floaterX, floaterY, floaterZ = getElementPosition(playerFloaters[player])

		if state then
			moveObject(playerFloaters[player], 500, floaterX + math.random(0.5, 1), floaterY + math.random(0.5, 1), floaterZ - 0.15, 0, 0, 0, "Linear")
		else
			moveObject(playerFloaters[player], 500, floaterX - math.random(0.5, 1), floaterY - math.random(0.5, 1), floaterZ + 0.15, 0, 0, 0, "Linear")
		end

		setTimer(moveFloater2Timer, 500, 1, player, not state)
	end
end

addEvent("moveDownFloater", true)
addEventHandler("moveDownFloater", getRootElement(),
	function ()
		if isElement(source) then
			moveFloaterTimer(source, true)
			headNotifications[source] = {
				startTick = getTickCount(),
				state = "showing",
				itemId = false
			}
		end
	end
)

addEvent("floaterMoveStopped", true)
addEventHandler("floaterMoveStopped", getRootElement(),
	function ()
		playerFloaterStopped[source] = true
	end
)

function catchTick()
	if rodThrowed then
		if not minigameTick and not balanceMinigame.preStart then
			if math.random(5) == 2 then
				triggerServerEvent("setFishingAnim", localPlayer, getElementsByType("player", getRootElement(), true))

				if isTimer(minigameStartTimer) then
					killTimer(minigameStartTimer)
				end

				minigameInProgress = true
				minigameStartTimer = setTimer(
					function ()
						bindKey("space", "down", stopMinigame)

						minigameTick = getTickCount()
						minigameState = false
						minigameStage = 0

						if isElement(catchSound) then
							destroyElement(catchSound)
						end

						catchSound = playSound("files/sounds/catch.mp3", true)
						triggerServerEvent("Łä>&ä&đ€}Đ", localPlayer, getElementsByType("player", getRootElement(), true))
					end,
				math.random(3000, 5000), 1)

				exports.see_hud:showInfobox("i", "Készülj, mert kapásod van!")
			end
		end
	end
end

function getPositionFromElementOffset(m, x, y, z)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
          x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
          x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

addEvent("Łä>&ä&đ€}Đ", true)
addEventHandler("Łä>&ä&đ€}Đ", getRootElement(),
	function ()
		if source ~= localPlayer then
			local playerX, playerY, playerZ = getElementPosition(source)

			if isElement(playerCatchSounds[source]) then
				destroyElement(playerCatchSounds[source])
			end

			playerCatchSounds[source] = playSound3D("files/kapas.mp3", playerX, playerY, playerZ, false)
			setSoundMaxDistance(playerCatchSounds[source], 13)
		end
	end
)

addEvent("throwInRod", true)
addEventHandler("throwInRod", getRootElement(),
	function (waterPosX, waterPosY, waterPosZ)
		if isElement(source) then
			local rodObjectElement = getElementData(source, "attachedObject")

			if isElement(rodObjectElement) then
				local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(source)
				local rodEndPosX, rodEndPosY, rodEndPosZ = getPositionFromElementOffset(getElementMatrix(rodObjectElement), 0.02, 0, 1.95)

				fishingRodObjects[source] = rodObjectElement
				playerFloaters[source] = createObject(3917, rodEndPosX, rodEndPosY, rodEndPosZ)
				playerFloaterStopped[source] = false
				throwPosition = {waterPosX, waterPosY, waterPosZ}

				moveObject(playerFloaters[source], 300, waterPosX, waterPosY, waterPosZ)
				playSound3D("files/sounds/throw.mp3", sourcePosX, sourcePosY, sourcePosZ)

				if source == localPlayer then
					bindKey("mouse2", "down", getOutRod)

					if isTimer(catchTickTimer) then
						killTimer(catchTickTimer)
					end

					catchTickTimer = setTimer(catchTick, 10000, 0)
				end
			end
		end
	end
)

function getOutRod()
	unbindKey("mouse2", "down", getOutRod)
	triggerServerEvent("endFishing", localPlayer, false)
end

addEvent("endFishing", true)
addEventHandler("endFishing", getRootElement(),
	function (itemId)
		if source == localPlayer then
			balanceMinigame = {}
			minigameInProgress = false
			minigameTick = false

			if isTimer(minigameStartTimer) then
				killTimer(minigameStartTimer)
			end

			if isTimer(catchTickTimer) then
				killTimer(catchTickTimer)
			end

			if isElement(catchSound) then
				destroyElement(catchSound)
			end

			unbindKey("mouse2", "down", getOutRod)
			rodThrowed = false
		end

		if playerFloaters[source] then
			local rodObjectElement = getElementData(source, "attachedObject")

			if isElement(rodObjectElement) then
				local rodEndPosX, rodEndPosY, rodEndPosZ = getPositionFromElementOffset(getElementMatrix(rodObjectElement), 0.02, 0, 1.95)

				if isElement(playerFloaters[source]) then
					moveObject(playerFloaters[source], 300, rodEndPosX, rodEndPosY, rodEndPosZ)
					setTimer(
						function (sourcePlayer)
							if playerFloaters[sourcePlayer] then
								if isElement(playerFloaters[sourcePlayer]) then
									destroyElement(playerFloaters[sourcePlayer])
								end

								playerFloaters[sourcePlayer] = nil
							end
						end,
					300, 1, source)
				end
			else
				destroyElement(playerFloaters[source])
				playerFloaters[source] = nil
			end
		end

		if isElement(source) then
			local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(source)
			playSound3D("files/sounds/success.mp3", sourcePosX, sourcePosY, sourcePosZ)
		end

		playerFloaterStopped[source] = nil
		fishingRodObjects[source] = nil

		if itemId then
			headNotifications[source] = {
				startTick = getTickCount(),
				state = "showing",
				itemId = itemId
			}
		end

		if playerCatchSounds[source] then
			if isElement(playerCatchSounds[source]) then
				destroyElement(playerCatchSounds[source])
			end

			playerCatchSounds[source] = nil
		end
	end
)

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if playerFloaters[source] then
			if isElement(playerFloaters[source]) then
				destroyElement(playerFloaters[source])
			end

			playerFloaters[source] = nil
		end

		playerFloaterStopped[source] = nil
		fishingRodObjects[source] = nil
		headNotifications[source] = nil

		if playerCatchSounds[source] then
			if isElement(playerCatchSounds[source]) then
				destroyElement(playerCatchSounds[source])
			end

			playerCatchSounds[source] = nil
		end
	end
)

addEventHandler("onClientPreRender", getRootElement(),
    function ()
        for playerElement, objectElement in pairs(fishingRodObjects) do
            if isElement(playerElement) then
                if isElement(objectElement) then
                    if not isElement(playerFloaters[playerElement]) or isPedInVehicle(playerElement) then
                        if playerElement == localPlayer then
                            unbindKey("mouse2", "down", getOutRod)
                            triggerServerEvent("endFishing", localPlayer, false)
                            fishingRodObjects[playerElement] = nil
                        end
                    elseif isElementStreamedIn(objectElement) then
                        if playerElement == localPlayer then
                            local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)

                            if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, throwPosition[1], throwPosition[2], throwPosition[3]) >= 20 then
                                exports.see_hud:showInfobox("e", "Nem kéne ilyen messzire menni!")


                                setElementData(localPlayer, "endingFishing", true)

                                unbindKey("mouse2", "down", getOutRod)
                                triggerServerEvent("endFishing", localPlayer, false)

                                fishingRodObjects[playerElement] = nil
                            end
                        end

                        local rodMatrix = getElementMatrix(objectElement)
                        local lineStartX, lineStartY, lineStartZ = getPositionFromElementOffset(rodMatrix, 0.02, 0, 0.1)
                        local lineEndX, lineEndY, lineEndZ = getPositionFromElementOffset(rodMatrix, 0.02, 0, 2.075)
                        local floaterPosX, floaterPosY, floaterPosZ = getElementPosition(playerFloaters[playerElement])

                        dxDrawLine3D(lineStartX, lineStartY, lineStartZ, lineEndX, lineEndY, lineEndZ, tocolor(100, 100, 100, 100), 0.5)
                        dxDrawLine3D(lineEndX, lineEndY, lineEndZ, floaterPosX, floaterPosY, floaterPosZ, tocolor(100, 100, 100, 100), 0.5)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local cameraPosX, cameraPosY, cameraPosZ = getCameraMatrix()
		local currentTick = getTickCount()

		for k, v in pairs(headNotifications) do
			if isElement(k) then
				if isElementStreamedIn(k) then
					local bonePosX, bonePosY, bonePosZ = getPedBonePosition(k, 8)

					if bonePosX and bonePosY and bonePosZ then
						local distanceBetweenPoints = getDistanceBetweenPoints3D(cameraPosX, cameraPosY, cameraPosZ, bonePosX, bonePosY, bonePosZ)

						if distanceBetweenPoints <= 15 then
							local screenPosX, screenPosY = getScreenFromWorldPosition(bonePosX, bonePosY, bonePosZ)

							if screenPosX and screenPosY then
								local scaleMultipler = interpolateBetween(1, 0, 0, 0.15, 0, 0, distanceBetweenPoints / 15, "OutQuad")

								local imageWidth = 128
								local imageHeight = 128
								local imageAlpha = 0

								if v.itemId then
									imageWidth = 64
									imageHeight = 64
								end

								imageWidth = imageWidth * scaleMultipler
								imageHeight = imageHeight * scaleMultipler

								screenPosX = screenPosX - imageWidth / 2
								screenPosY = screenPosY - imageHeight / 2

								if currentTick >= v.startTick then
									local elapsedTime = currentTick - v.startTick

									if v.state == "showing" then
										local progress = interpolateBetween(0, 0, 0, 1, 0, 0, elapsedTime / 1000, "OutQuad")

										screenPosY = screenPosY - imageHeight * 1.5 * progress
										imageAlpha = 200 * progress

										if elapsedTime >= 1000 then
											v.state = "rendering"
											v.startTick = currentTick
										end
									elseif v.state == "rendering" then
										screenPosY = screenPosY - imageHeight * 1.5
										imageAlpha = 200

										if elapsedTime >= 7000 then
											v.state = "hiding"
											v.startTick = currentTick
										end
									elseif v.state == "hiding" then
										local progress = interpolateBetween(1, 0, 0, 0, 0, 0, elapsedTime / 1000, "OutQuad")

										screenPosY = screenPosY - imageHeight * 1.5 * progress
										imageAlpha = 200 * progress

										if elapsedTime >= 1000 then
											headNotifications[k] = nil
										end
									end
								end

								if v.itemId then
									dxDrawImage(screenPosX, screenPosY, imageWidth, imageHeight, ":see_items/files/items/" .. v.itemId - 1 .. ".png", 0, 0, 0, tocolor(255, 255, 255, imageAlpha))
								else
									dxDrawImage(screenPosX, screenPosY, imageWidth, imageHeight, "files/images/notification.png", 0, 0, 0, tocolor(0, 0, 0, imageAlpha))
								end
							end
						end
					end
				end
			else
				headNotifications[k] = nil
			end
		end

		if minigameTick then
			local progress = (currentTick - minigameTick) / 750

			if minigameState then
				progress = 1 - progress
			end

			if progress >= 1 then
				minigameTick = currentTick
				minigameState = not minigameState
				minigameStage = minigameStage + 1
			end

			if progress <= 0 then
				minigameTick = currentTick
				minigameState = not minigameState
				minigameStage = minigameStage + 1
			end

			if minigameStage >= 15 then
				stopMinigame()
			end

			local colorR, colorG, colorB = interpolateBetween(61, 122, 188, 215, 89, 89, math.abs(progress - 0.5) * 2, "Linear")
			local barHeight = (minigameBarHeight - 4) * progress

			dxDrawRectangle(minigameBarPosX, minigameBarPosY, minigameBarWidth, minigameBarHeight, tocolor(0, 0, 0, 150))
			dxDrawRectangle(minigameBarPosX + 2, minigameBarPosY + 2, minigameBarWidth - 4, minigameBarHeight - 4, tocolor(0, 0, 0, 200))
			dxDrawRectangle(minigameBarPosX + 2, minigameBarPosY + 2 + minigameBarHeight - 4 - barHeight, minigameBarWidth - 4, barHeight, tocolor(colorR, colorG, colorB))
		end

		if minigameInProgress then
			dxDrawText("Állítsd meg a jobb oldali, mozgó csíkot a #3d7abckék#ffffff mezőben, a #3d7abcSPACE#ffffff gomb megnyomásával!", 0, screenY - 200, screenX, screenY, tocolor(255, 255, 255), 1, Roboto, "center", "top", false, false, false, true)
		elseif balanceMinigame.preStart then
			dxDrawText("Tartsd a felső #3d7abckék#ffffff nyílt középen, a #598ed7balra#ffffff és #598ed7jobbra nyíl#ffffff gombok nyomogatásával!", 0, screenY - 200, screenX, screenY, tocolor(255, 255, 255), 1, Roboto, "center", "top", false, false, false, true)
		end
	end
)

function stopMinigame()
	if minigameTick then
		local minigameProgress = (getTickCount() - minigameTick) / 750

		unbindKey("space", "down", stopMinigame)

		minigameTick = false
		minigameInProgress = false

		if isElement(catchSound) then
			destroyElement(catchSound)
		end

		if math.abs(minigameProgress - 0.5) * 2 <= 0.25 then
			triggerServerEvent("floaterMoveStopped", localPlayer, getElementsByType("player", getRootElement(), true))

			exports.see_hud:showInfobox("s", "Siker! Kezdd el a hal kifárasztását!")
			outputChatBox("#3d7abc[StrongMTA - Horgászat]: #FFFFFFSiker! Kezdd el a hal kifárasztását!", 255, 255, 255, true)

			balanceMinigame.preStart = true
			minigameStartTimer = setTimer(
				function ()
					setBalanceState(true)

					if isElement(catchSound) then
						destroyElement(catchSound)
					end

					catchSound = playSound("files/sounds/catch.mp3", true)
					triggerServerEvent("Łä>&ä&đ€}Đ", localPlayer, getElementsByType("player", getRootElement(), true))
				end,
			math.random(3000, 5000), 1)
		else
			triggerServerEvent("endFishing", localPlayer, false)

			exports.see_hud:showInfobox("e", "Sajnos a hal leakadt a horogról!")
			outputChatBox("#3d7abc[StrongMTA - Horgászat]: #FFFFFFSajnos a hal #d75959leakadt#ffffff a horogról!", 255, 255, 255, true)
		end
	end
end

function setBalanceState(state)
	if balanceMinigame.state ~= state then
		balanceMinigame.state = state

		if state then
			balanceMinigame.startTime = getTickCount()
			balanceMinigame.endTime = balanceMinigame.startTime + 15000
			balanceMinigame.direction = false
			balanceMinigame.keyType = false
			balanceMinigame.rotation = math.random(0, 1) == 0 and -10 or 10
			balanceMinigame.acceleration = math.random(0, 1) == 0 and -0.2 or 0.2
			balanceMinigame.accelerationMultipler = 0.5

			toggleControl("left", false)
			toggleControl("right", false)

			bindKey("a", "both", minigameMoveHandler)
			bindKey("arrow_l", "both", minigameMoveHandler)

			bindKey("d", "both", minigameMoveHandler)
			bindKey("arrow_r", "both", minigameMoveHandler)

			addEventHandler("onClientRender", getRootElement(), renderBalanceMinigame)
			addEventHandler("onClientPreRender", getRootElement(), balanceMovementRender)
		else
			removeEventHandler("onClientRender", getRootElement(), renderBalanceMinigame)
			removeEventHandler("onClientPreRender", getRootElement(), balanceMovementRender)

			toggleControl("left", true)
			toggleControl("right", true)

			unbindKey("a", "both", minigameMoveHandler)
			unbindKey("arrow_l", "both", minigameMoveHandler)

			unbindKey("d", "both", minigameMoveHandler)
			unbindKey("arrow_r", "both", minigameMoveHandler)
		end
	end
end

function minigameMoveHandler(button, state)
	if state == "down" then
		if not balanceMinigame.direction then
			local rand = math.random(9, 10) / 10

			balanceMinigame.keyType = button

			if button == "a" or button == "arrow_l" then
				balanceMinigame.direction = -0.2 * balanceMinigame.accelerationMultipler * rand
			elseif button == "d" or button == "arrow_r" then
				balanceMinigame.direction = 0.2 * balanceMinigame.accelerationMultipler * rand
			end

			balanceMinigame.accelerationMultipler = balanceMinigame.accelerationMultipler + 0.1
		end
	elseif state == "up" then
		if balanceMinigame.direction then
			if balanceMinigame.keyType == button then
				balanceMinigame.direction = nil
				balanceMinigame.keyType = nil
			end
		end
	end
end

function balanceMovementRender(deltaTime)
	if balanceMinigame.state then
		if getTickCount() - balanceMinigame.startTime > 1000 then
			if math.abs(balanceMinigame.rotation) < 50 then
				if balanceMinigame.direction then
					balanceMinigame.acceleration = balanceMinigame.acceleration + balanceMinigame.direction * 0.5
				end

				balanceMinigame.acceleration = balanceMinigame.acceleration + balanceMinigame.rotation / 780
				balanceMinigame.rotation = balanceMinigame.rotation + balanceMinigame.acceleration * deltaTime / 100

				if balanceMinigame.rotation == 0 then
					balanceMinigame.rotation = math.random(0, 1) == 0 and -1 or 1
				end
			else
				balanceMinigameFail()
			end
		end
	end
end

function renderBalanceMinigame()
	if balanceMinigame.state then
		local progress = (getTickCount() - balanceMinigame.startTime) / (balanceMinigame.endTime - balanceMinigame.startTime)

		if progress > 1 then
			progress = 1
			balanceMinigameSuccess()
		end

		local theX = screenX / 2
		local theY = screenY / 2

		dxDrawImage(theX - 256, 294, 512, 512, "files/images/arch.png")
		dxDrawImage(theX - 256, 294, 512, 512, "files/images/pointer.png", balanceMinigame.rotation)

		dxDrawRectangle(theX - 150 - 3, 485 - 3, 300 + 6, 25 + 6, tocolor(0, 0, 0, 150))
		dxDrawRectangle(theX - 150, 485, 300, 25, tocolor(61, 122, 188, 50))
		dxDrawRectangle(theX - 150, 485, 300 * progress, 25, tocolor(61, 122, 188))
	end
end

function balanceMinigameFail()
	setBalanceState(false)

	if math.random(10) < 5 then
		triggerServerEvent("failTheRod", localPlayer)
		outputChatBox("#3d7abc[StrongMTA - Horgászat]: #FFFFFFA horgászbotodon #d75959elszakadt#ffffff a damil!", 255, 255, 255, true)
	else
		outputChatBox("#3d7abc[StrongMTA - Horgászat]: #FFFFFFA hal #d75959meglógott#ffffff!", 255, 255, 255, true)
	end

	triggerServerEvent("endFishing", localPlayer, false)

	exports.see_hud:showInfobox("e", "Sajnos nem sikerült kifognod a halat.")
	outputChatBox("#3d7abc[StrongMTA - Horgászat]: #FFFFFFSajnos nem sikerült kifognod a halat.", 255, 255, 255, true)
end

function balanceMinigameSuccess()
	setBalanceState(false)

	local itemId = chooseRandomItem(weightedItems[math.random(1, #weightedItems)])

	if itemId then
		triggerServerEvent("endFishing", localPlayer, itemId, exports.see_items:getItemName(itemId))
	else
		triggerServerEvent("endFishing", localPlayer, false)
	end
end
