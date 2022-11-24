local screenX, screenY = guiGetScreenSize()

local minigameState = false
local minigameData = {}

function stopMinigame()
	if minigameData then
		if minigameState == "ghero" then
			if isTimer(minigameData.spawnNextArrowTimer) then
				killTimer(minigameData.spawnNextArrowTimer)
				minigameData.spawnNextArrowTimer = nil
			end

			if isElement(minigameData.renderTarget) then
				destroyElement(minigameData.renderTarget)
				minigameData.renderTarget = nil
			end

			if isElement(minigameData.RobotoFont) then
				destroyElement(minigameData.RobotoFont)
				minigameData.RobotoFont = nil
			end
		end
	end

	minigameState = false
	minigameData = {}
end

function endMinigame(...)
	local args = {...}

	if minigameState == "ghero" then
		if args[1] >= 0.75 then
			if minigameData.successEvent then
				triggerEvent(minigameData.successEvent, localPlayer)
			end
		else
			if minigameData.failEvent then
				triggerEvent(minigameData.failEvent, localPlayer)
			end
		end
	end

	stopMinigame()
end

function startMinigame(gameType, successEvent, failEvent, ...)
	stopMinigame()

	local args = {...}
	minigameData = {}

	if gameType == "ghero" then
		minigameData.arrows = {}
		minigameData.spawnedArrows = 0

		minigameData.renderTarget = dxCreateRenderTarget(622, 90, true)
		minigameData.RobotoFont = dxCreateFont("files/Roboto.ttf", 24, false, "antialiased")

		minigameData.speed = args[1] or 0.15
		minigameData.endSpeed = (args[2] or 0.2) - minigameData.speed
		minigameData.density = args[3] or 120
		minigameData.maxArrowsNum = args[4] or 100

		minigameData.interpolateSpeedSet = false
		minigameData.currentArrow = false
		minigameData.arrowInKey = false
		minigameData.failCount = 0
		minigameData.successCount = 0
		minigameData.lastRing = false
		minigameData.onScreenNum = 0

		minigameData.spawnNextArrowTimer = setTimer(spawnNextArrow, 2000, 1)
	end

	if successEvent then
		minigameData.successEvent = successEvent
	end

	if failEvent then
		minigameData.failEvent = failEvent
	end

	minigameState = gameType
end

function spawnNextArrow()
	if minigameState == "ghero" then
		minigameData.spawnedArrows = minigameData.spawnedArrows + 1

		table.insert(minigameData.arrows, {90 * math.random(0, 3), 0, false})

		local stopInterpolate = minigameData.speed + minigameData.endSpeed / minigameData.maxArrowsNum
		local duration = minigameData.density / stopInterpolate

		minigameData.interpolateSpeedSet = {getTickCount(), minigameData.speed, stopInterpolate, duration}

		if minigameData.spawnedArrows < minigameData.maxArrowsNum then
			minigameData.spawnNextArrowTimer = setTimer(spawnNextArrow, duration + 50, 1)
		end
	end
end

addEventHandler("onClientKey", getRootElement(),
	function (key, state)
		if minigameData then
			if minigameState == "ghero" then
				cancelEvent()

				if state then
					local currentArrow = minigameData.currentArrow

					if currentArrow and not minigameData.arrows[currentArrow][3] then
						if key == "arrow_u" or key == "arrow_d" or key == "arrow_l" or key == "arrow_r" then
							if currentArrow == minigameData.arrowInKey then
								local arrowRot = minigameData.arrows[currentArrow][1]

								if arrowRot == 0 and key == "arrow_d" then
									minigameData.arrows[currentArrow][3] = "success"
									minigameData.lastRing = "success"
									minigameData.successCount = minigameData.successCount + 1
									playSound("files/ghero/correct.mp3")
								elseif arrowRot == 90 and key == "arrow_l" then
									minigameData.arrows[currentArrow][3] = "success"
									minigameData.lastRing = "success"
									minigameData.successCount = minigameData.successCount + 1
									playSound("files/ghero/correct.mp3")
								elseif arrowRot == 180 and key == "arrow_u" then
									minigameData.arrows[currentArrow][3] = "success"
									minigameData.lastRing = "success"
									minigameData.successCount = minigameData.successCount + 1
									playSound("files/ghero/correct.mp3")
								elseif arrowRot == 270 and key == "arrow_r" then
									minigameData.arrows[currentArrow][3] = "success"
									minigameData.lastRing = "success"
									minigameData.successCount = minigameData.successCount + 1
									playSound("files/ghero/correct.mp3")
								else
									minigameData.arrows[currentArrow][3] = "fail"
									minigameData.failCount = minigameData.failCount + 1
									minigameData.lastRing = "fail"
									playSound("files/ghero/wrong.mp3")
								end
							else
								minigameData.arrows[currentArrow][3] = "fail"
								minigameData.failCount = minigameData.failCount + 1
								minigameData.lastRing = "fail"
								playSound("files/ghero/wrong.mp3")
							end
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function (deltaTime)
		if not minigameData then
			return
		end

		if minigameState == "ghero" then
			minigameData.onScreenNum = 0
			minigameData.arrowInKey = false
			minigameData.currentArrow = false
			minigameData.lastCurrent = minigameData.currentArrow

			if minigameData.interpolateSpeedSet then
				local progress = (getTickCount() - minigameData.interpolateSpeedSet[1]) / minigameData.interpolateSpeedSet[4]

				minigameData.speed = interpolateBetween(
					minigameData.interpolateSpeedSet[2], 0, 0,
					minigameData.interpolateSpeedSet[3], 0, 0,
					progress, "Linear")
			end
			
			dxSetRenderTarget(minigameData.renderTarget, true)

			for i = 1, #minigameData.arrows do
				local arrow = minigameData.arrows[i]

				if arrow then
					minigameData.onScreenNum = minigameData.onScreenNum + 1

					local progress = arrow[2] + minigameData.speed * deltaTime / 1000

					if progress >= 1 then
						progress = 1
					end

					arrow[2] = progress

					local alpha = 1 - math.abs(0.5 - progress) * 2
					local r, g, b = 255, 255, 255

					if arrow[3] then
						if arrow[3] == "fail" then
							r, g, b = 215, 89, 89
						elseif arrow[3] == "success" then
							r, g, b = 61, 122, 188
						end
					end

					if not minigameData.currentArrow and progress <= 0.575 then
						minigameData.currentArrow = i
					end

					if progress >= 0.475 and progress <= 0.525 then
						minigameData.arrowInKey = i
					end

					dxDrawImage(-90 + 712 * progress, 0, 90, 90, "files/ghero/arrow.png", arrow[1], 0, 0, tocolor(r, g, b, 55 * alpha + 200))

					if progress > 0.525 then
						if minigameData.lastCurrent == i then
							minigameData.lastRing = false
						end

						if not arrow[3] then
							arrow[3] = "fail"
							minigameData.failCount = minigameData.failCount + 1
							minigameData.lastRing = "fail"
							playSound("files/ghero/wrong.mp3")
						end
					end

					if progress >= 1 then
						minigameData.arrows[i] = false
					end
				end
			end

			dxSetRenderTarget()
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if not minigameData then
			return
		end

		if minigameState == "ghero" then
			local presskey = false

			if getKeyState("arrow_u") or getKeyState("arrow_d") or getKeyState("arrow_l") or getKeyState("arrow_r") then
				presskey = true
			end

			local r, g, b = 255, 255, 255

			if minigameData.lastRing then
				if minigameData.lastRing == "success" then
					r, g, b = 61, 122, 188
				else
					r, g, b = 215, 89, 89
				end
			end

			local x = math.floor(screenX / 2 - 311)
			local y = math.floor(screenY - 90 - 80)
			local alpha = 1

			if minigameData.fadeOut then
				alpha = interpolateBetween(
					1, 0, 0,
					0, 0, 0,
					(getTickCount() - minigameData.fadeOut) / 1000, "Linear")
			end

			dxDrawImage(x, y, 622, 90, "files/ghero/black.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))
			dxDrawImage(x, y, 622, 90, "files/ghero/ring3.png", 0, 0, 0, tocolor(r, g, b, 40 * alpha))
			dxDrawImage(x, y, 622, 90, minigameData.renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))
			
			if presskey then
				dxDrawImage(x, y, 622, 90, "files/ghero/ring2.png", 0, 0, 0, tocolor(r, g, b, 220 * alpha))
			else
				dxDrawImage(x, y, 622, 90, "files/ghero/ring1.png", 0, 0, 0, tocolor(r, g, b, 220 * alpha))
			end

			if minigameData.onScreenNum <= 0 and minigameData.successCount + minigameData.failCount > 1 then
				if not minigameData.fadeOut then
					minigameData.fadeOut = getTickCount()
				end

				if alpha <= 0 then
					endMinigame(minigameData.successCount / (minigameData.successCount + minigameData.failCount))
				end
			end
		end
	end)