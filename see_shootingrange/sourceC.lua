local screenX, screenY = guiGetScreenSize()

local targetObjects = {}
local targetInterpolations = {}
local targetPositions = {
	{1583, 803.90002, 1658, 4.1, 0, 0, 180, 270, 0, 180},
	{1583, 798, 1651.9, 4.1, 0, 0, 179.995, 270, 0, 180},
	{1583, 796.79999, 1646.2, 4.1, 0, 0, 179.995, 270, 0, 180},
	{1583, 800, 1646.2, 4.1, 0, 0, 179.995, 270, 0, 180},
	{1583, 801.5, 1651.8, 4.1, 0, 0, 179.995, 270, 0, 180},
	{1584, 804.90002, 1646.2, 4.1, 0, 0, 179.995, 270, 0, 180},
	{1584, 804, 1651.9, 4.1, 0, 0, 179.995, 270, 0, 180},
	{1584, 799.09998, 1657.8, 4.1, 0, 0, 179.995, 270, 0, 180},
	{1584, 801.29999, 1657.9, 4.1, 0, 0, 179.995, 270, 0, 180}
}

local mapObjects = {}
local mapObjectPositions = {
	{9339, 801.40002, 1658.5, 4.3, 0, 0, 90},
	{9339, 800, 1647.2998, 4.3, 0, 0, 90},
	{9339, 800, 1653, 4.3, 0, 0, 90}
}

local exitPosition = {803.5791015625, 1674.248046875, 5.28125, 0, 0, 0, 0, 0}
local trainingPosition = {800.20001, 1669, 5.3, 0, 0, 180}

local allowedWeapons = {22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 34, 32, 33}
local weaponStats = {
	[22] = {69, "Glock 17"},
	[23] = {70, "Hangtompítós Colt 45"},
	[24] = {71, "Desert Eagle"},
	[25] = {72, "Sörétes puska"},
	[26] = {73, "Rövid csövű sörétes puska"},
	[27] = {74, "SPAZ-12 taktikai sörétes puska"},
	[28] = {75, "Micro Uzi & Tec-9"},
	[29] = {76, "FN P90"},
	[30] = {77, "AK47"},
	[31] = {78, "M4"},
	[32] = 28,
	[33] = 34,
	[34] = {79, "Vadász- és Mesterlövész puska"}
}

local panelState = false
local panelFont = false
local itemFont = false
local pointFont = false
local timeFont = false

local panelWidth = 600
local panelHeight = 380
local panelMargin = 3

local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

local selectedItem = -1
local activeButton = false

local weaponTraining = false
local currentTargetObject = false
local currentPoints = 0
local targetHit = false

local endRoundTimer = false
local randomizeTimer = false

function createFonts()
	destroyFonts()

	panelFont = dxCreateFont("files/Roboto.ttf", 12, false, "antialiased")
	itemFont = dxCreateFont("files/Roboto.ttf", 11, false, "antialiased")
end

function destroyFonts()
	if isElement(itemFont) then
		destroyElement(itemFont)
	end

	if isElement(panelFont) then
		destroyElement(panelFont)
	end
end

function createPointFonts()
	destroyPointFonts()

	timeFont = dxCreateFont("files/Roboto.ttf", 12, false, "antialiased")
	pointFont = dxCreateFont("files/Roboto.ttf", 20, false, "antialiased")
end

function destroyPointFonts()
	if isElement(timeFont) then
		destroyElement(timeFont)
	end

	if isElement(pointFont) then
		destroyElement(pointFont)
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function (resourceElement)
		local pedElement = createPed(1, 812.189453125, 1673.419921875, 5.28125, 100)

		if isElement(pedElement) then
			setElementInterior(pedElement, 0)
			setElementDimension(pedElement, 0)
			setElementFrozen(pedElement, true)

			setElementData(pedElement, "invulnerable", true)
			setElementData(pedElement, "visibleName", "Benjamin", false)
			setElementData(pedElement, "weaponSkillNPC", true, false)
		end

		for i, v in ipairs(targetPositions) do
			local objectElement = createObject(v[1], v[2], v[3], v[4], v[8], v[9], v[10])

			targetObjects[i] = objectElement

			if isElement(objectElement) then
				setElementData(objectElement, "targetId", i, false)
			end
		end

		for i, v in ipairs(mapObjectPositions) do
			mapObjects[i] = createObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
		end
	end
)

function createMapObjects(dimension)
	if dimension then
		for k, v in pairs(mapObjects) do
			if isElement(v) then
				setElementDimension(v, dimension)
			end
		end
	end
end

function createTargets(dimension)
	if dimension then
		for k, v in pairs(targetObjects) do
			if isElement(v) then
				setElementDimension(v, dimension)
				setElementRotation(v, targetPositions[k][8], targetPositions[k][9], targetPositions[k][10])
			end
		end
	end
end

function resetTargets(targetElement)
	for k, v in pairs(targetObjects) do
		if isElement(v) then
			setElementRotation(v, targetPositions[k][8], targetPositions[k][9], targetPositions[k][10])

			if targetElement == v then
				if targetHit ~= targetElement then
					targetInterpolations[k] = {targetPositions[k][8], targetPositions[k][8] + 90, getTickCount()}
				end
			end
		end
	end

	targetHit = false
	currentTargetObject = false
end

function randomizeTargets()
	local targetId = math.random(1, #targetObjects)

	if targetId then
		local objectElement = targetObjects[targetId]

		if objectElement then
			if not targetHit then
				if currentPoints >= 2 then
					currentPoints = currentPoints - 2
				end
			end

			resetTargets(currentTargetObject)
			currentTargetObject = objectElement

			if isElement(currentTargetObject) then
				targetInterpolations[targetId] = {targetPositions[targetId][8] + 90, targetPositions[targetId][8], getTickCount()}
			end
		end
	end
end

function endRound(suspended)
	if weaponTraining then
		if not suspended then
			if currentPoints >= 25 then
				local weaponStat = weaponStats[weaponTraining]

				if type(weaponStat) == "number" then
					weaponStat = weaponStats[weaponStat]
				end

				if weaponStat then
					local skillLevel = getPedStat(localPlayer, weaponStat[1])

					if skillLevel then
						skillLevel = skillLevel + math.floor(currentPoints / 25) * 10

						playSound("files/sounds/roundcomplete.mp3")
						outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen teljesítetted a feladatod. +" .. math.floor(currentPoints / 25) * 10 .. " fegyver tapasztalat a jutalmad.", 255, 255, 255, true)

						if skillLevel then
							if skillLevel > 1000 then
								skillLevel = 1000
							end

							triggerServerEvent("setWeaponStat", localPlayer, weaponStat[1], skillLevel)
						end
					end
				end
			else
				outputChatBox("#d75959[StrongMTA]: #ffffffSajnos nem sikerült teljesíteni a feladatot. Próbáld meg mégegyszer.", 255, 255, 255, true)
				playSound("files/sounds/roundfailed.mp3")
			end
		else
			outputChatBox("#d75959[StrongMTA]: #ffffffKiléptél, ezért a pontok nem kerültek jóváírásra.", 255, 255, 255, true)
			playSound("files/sounds/roundfailed.mp3")
		end

		if isTimer(endRoundTimer) then
			killTimer(endRoundTimer)
		end

		if isTimer(randomizeTimer) then
			killTimer(randomizeTimer)
		end

		endRoundTimer = nil
		randomizeTimer = nil
		weaponTraining = false

		triggerServerEvent("warpPlayerTraining", localPlayer, exitPosition[7], exitPosition[8])
		setElementPosition(localPlayer, exitPosition[1], exitPosition[2], exitPosition[3])
		setElementRotation(localPlayer, exitPosition[4], exitPosition[5], exitPosition[6])
		setElementFrozen(localPlayer, false)

		resetTargets()
		destroyPointFonts()

		exports.see_hud:showHUD()
	end
end

addEventHandler("onClientObjectDamage", getResourceRootElement(),
	function (lossAmount, attackerElement)
		if isElement(attackerElement) then
			if attackerElement == localPlayer then
				local targetId = getElementData(source, "targetId")

				if targetId then
					local weaponId = getPedWeapon(attackerElement)

					if weaponId and weaponTraining then
						if weaponTraining == weaponId then
							if currentTargetObject then
								if currentTargetObject == source then
									if not targetHit then
										targetInterpolations[targetId] = {targetPositions[targetId][8], targetPositions[targetId][8] + 90, getTickCount()}
										targetHit = currentTargetObject
										currentPoints = currentPoints + 1
										playSound("files/sounds/tablehit.mp3")
									end
								end
							end
						else
							currentPoints = 0
						end
					end
				else
					if currentPoints >= 2 then
						if not targetHit then
							currentPoints = currentPoints - 2
							playSound("files/sounds/tablefailed.mp3")
							targetHit = true
						end
					end
				end
			end
		end

		cancelEvent()
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
		if state == "up" then
			if button == "right" then
				if not panelState then
					if isElement(clickedElement) then
						if getElementType(clickedElement) == "ped" then
							if getElementData(clickedElement, "weaponSkillNPC") then
								local playerX, playerY, playerZ = getElementPosition(localPlayer)
								local targetX, targetY, targetZ = getElementPosition(clickedElement)

								if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 3 then
									if not exports.see_weaponskill:isPanelOpen() then
										createFonts()
										showCursor(true)
										panelState = true
										playSound("files/sounds/skillopen.mp3")
									end
								end
							end
						end
					end
				end
			else
				if button == "left" then
					if panelState then
						if activeButton then
							if string.find(activeButton, "skill_") then
								local rowId = tonumber(gettok(activeButton, 2, "_"))

								if selectedItem ~= rowId then
									selectedItem = rowId
									playSound("files/sounds/skillselect.mp3")
								end
							elseif activeButton == "start" then
								if selectedItem ~= -1 then
									local weaponId = allowedWeapons[selectedItem]
									if weaponId then
										local weaponStat = weaponStats[weaponId]
										if type(weaponStat) == "number" then
											weaponStat = weaponStats[weaponStat]
										end
										if weaponStat then
											local trainingDimension = getElementData(localPlayer, "playerID") + 60000
											if trainingDimension then
												if getPedWeapon(localPlayer) == weaponId then
													triggerServerEvent("startWeaponTraining", localPlayer, weaponId, trainingDimension)
												else
													outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott fegyvernek a kezedben kell lennie.", 255, 255, 255, true)
												end
											end
										end
									end
								end
							elseif activeButton == "exit" then
								panelState = false

								showCursor(false)
								destroyFonts()

								playSound("files/sounds/skillclose.mp3")
							elseif activeButton == "downgrade" then
								panelState = false

								showCursor(false)
								destroyFonts()

								exports.see_weaponskill:togglePanel(true)
							end
						end
					else
						if weaponTraining then
							if activeButton == "exit" then
								endRound(true)
							end
						end
					end
				end
			end
		end
	end
)

addEvent("startWeaponTraining", true)
addEventHandler("startWeaponTraining", getRootElement(),
	function (weaponId, dimension)
		weaponTraining = weaponId

		setElementPosition(localPlayer, trainingPosition[1], trainingPosition[2], trainingPosition[3])
		setElementRotation(localPlayer, trainingPosition[4], trainingPosition[5], trainingPosition[6])
		setElementFrozen(localPlayer, true)

		createTargets(dimension)
		createMapObjects(dimension)

		if isTimer(endRoundTimer) then
			killTimer(endRoundTimer)
		end

		if isTimer(randomizeTimer) then
			killTimer(randomizeTimer)
		end

		endRoundTimer = setTimer(endRound, 180000, 1)
		randomizeTimer = setTimer(randomizeTargets, getAvailableTime(), 0)

		currentPoints = 0
		targetHit = false
		panelState = false

		showCursor(false)

		destroyFonts()
		createPointFonts()

		exports.see_hud:hideHUD()

		playSound("files/sounds/skillstart.mp3")
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if isTimer(endRoundTimer) then
			local buttons = {}

			-- ** Hátralévő idő
			local timeLeft = getTimerDetails(endRoundTimer)

			if timeLeft then
				local minutes, seconds = calculateTime(math.ceil(timeLeft / 1000))

				dxDrawText("#FFFFFFIdő:\n#4aabd0" .. minutes .. " #FFFFFFperc és #4aabd0" .. seconds .. " #FFFFFFmásodperc.", 0, screenY - 110, screenX, screenY - 80, tocolor(255, 255, 255), 1, timeFont, "center", "top", false, false, false, true)
			end

			-- ** Pontok
			if currentPoints < 25 then
				dxDrawText("Találatok: #d75959" .. currentPoints .. "\n#ffffffPontok: #d75959" .. math.floor(currentPoints / 25) * 10, 0, 0, screenX, screenY, tocolor(255, 255, 255), 1, pointFont, "center", "top", false, false, false, true)
			else
				dxDrawText("Találatok: #3d7abc" .. currentPoints .. "\n#ffffffPontok: #3d7abc" .. math.floor(currentPoints / 25) * 10, 0, 0, screenX, screenY, tocolor(255, 255, 255), 1, pointFont, "center", "top", false, false, false, true)
			end

			-- ** Kilépés
			buttons.exit = {screenX - 100, screenY - 60, 80, 40}

			if activeButton == "exit" then
				dxDrawRectangle(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], tocolor(215, 89, 89, 240))
			else
				dxDrawRectangle(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], tocolor(215, 89, 89, 180))
			end
			dxDrawText("Kilépés", buttons.exit[1], buttons.exit[2], buttons.exit[1] + buttons.exit[3], buttons.exit[2] + buttons.exit[4], tocolor(0, 0, 0), 1, timeFont, "center", "center")

			-- ** Button handler
			activeButton = false

			if isCursorShowing() then
				local relX, relY = getCursorPosition()
				local absX, absY = relX * screenX, relY * screenY

				for k, v in pairs(buttons) do
					if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			end

			-- ** Table animation
			for i = 1, #targetPositions do
				local v = targetInterpolations[i]

				if v then
					local objectElement = targetObjects[i]

					if isElement(objectElement) then
						local elapsedTime = getTickCount() - v[3]
						local progress = elapsedTime / 500

						local currentRotX, currentRotY, currentRotZ = getElementRotation(objectElement)
						local newRotX = interpolateBetween(v[2], 0, 0, v[1], 0, 0, progress, "Linear")

						setElementRotation(objectElement, newRotX, currentRotY, currentRotZ)

						if progress >= 1 then
							targetInterpolations[i] = nil
						end
					end
				end
			end
		end

		if panelState then
			-- ** Háttér
			dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 140))
			dxDrawImage(panelPosX, panelPosY, panelWidth, panelHeight, ":see_hud/files/images/vin.png")

			-- ** Keret
			dxDrawRectangle(panelPosX - panelMargin, panelPosY - panelMargin, panelWidth + panelMargin * 2, panelMargin, tocolor(0, 0, 0, 200)) -- felső
			dxDrawRectangle(panelPosX - panelMargin, panelPosY + panelHeight, panelWidth + panelMargin * 2, panelMargin, tocolor(0, 0, 0, 200)) -- alsó
			dxDrawRectangle(panelPosX - panelMargin, panelPosY, panelMargin, panelHeight, tocolor(0, 0, 0, 200)) -- bal
			dxDrawRectangle(panelPosX + panelWidth, panelPosY, panelMargin, panelHeight, tocolor(0, 0, 0, 200)) -- jobb

			-- ** Cím
			dxDrawText("#3d7abcStrongMTA #ffffff- Lőtér", panelPosX + 5, panelPosY - 25, 0, 0, tocolor(255, 255, 255), 1, panelFont, "left", "top", false, false, true, true, true)

			-- ** Content
			local buttons = {}

			dxDrawImage(panelPosX + 320, panelPosY + 10, 272, 272, "files/logo.png")
			dxDrawText("Elérhető fegyverek:", panelPosX + 15, panelPosY + 10, 0, 0, tocolor(61, 122, 188), 1, panelFont, "left", "top", false, false, true, false, true)
			dxDrawRectangle(panelPosX + 10, panelPosY + 40, 300, panelHeight - 50, tocolor(0, 0, 0, 140))

			for i = 1, #allowedWeapons - 2 do
				local rowY = panelPosY + 40 + (i - 1) * 30

				if selectedItem ~= i then
					if activeButton == "skill_" .. i then
						dxDrawRectangle(panelPosX + 10, rowY, 300, 30, tocolor(50, 179, 239, 140))
					else
						if i % 2 == 0 then
							dxDrawRectangle(panelPosX + 10, rowY, 300, 30, tocolor(255, 255, 255, 20))
						end
					end

					buttons["skill_" .. i] = {panelPosX + 10, rowY, 300, 30}
				else
					dxDrawRectangle(panelPosX + 10, rowY, 300, 30, tocolor(50, 179, 239, 180))
				end

				local weaponId = allowedWeapons[i]
				local weaponStat = weaponStats[weaponId]

				if weaponStat then
					if type(weaponStat) == "number" then
						weaponStat = weaponStats[weaponStat]
					end

					if weaponStat then
						dxDrawText(weaponStat[2], panelPosX + 15, rowY + 1, 0, rowY + 30, tocolor(255, 255, 255), 1, itemFont, "left", "center", false, false, true, false, true)
						dxDrawText("[#4aabd0" .. getPedStat(localPlayer, weaponStat[1]) .. "#ffffff/#3d7abc1000#ffffff]", panelPosX + 140, rowY + 1, panelPosX + 305, rowY + 30, tocolor(255, 255, 255), 1, itemFont, "right", "center", false, false, true, true, true)
					end
				end
			end

			-- ** Indítás
			buttons.start = {panelPosX + 320, panelPosY + panelHeight - 75, panelWidth - 330, 30}

			if activeButton == "start" then
				dxDrawRectangle(buttons.start[1], buttons.start[2], buttons.start[3], buttons.start[4], tocolor(61, 122, 188, 180))
			else
				dxDrawRectangle(buttons.start[1], buttons.start[2], buttons.start[3], buttons.start[4], tocolor(61, 122, 188, 140))
			end
			dxDrawText("Indítás", buttons.start[1], buttons.start[2], buttons.start[1] + buttons.start[3], buttons.start[2] + buttons.start[4], tocolor(255, 255, 255), 1, panelFont, "center", "center", false, false, true, false, true)

			-- ** Kilépés
			buttons.exit = {panelPosX + 320, panelPosY + panelHeight - 40, panelWidth - 330, 30}

			if activeButton == "exit" then
				dxDrawRectangle(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], tocolor(215, 89, 89, 180))
			else
				dxDrawRectangle(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], tocolor(215, 89, 89, 140))
			end
			dxDrawText("Kilépés", buttons.exit[1], buttons.exit[2], buttons.exit[1] + buttons.exit[3], buttons.exit[2] + buttons.exit[4], tocolor(255, 255, 255), 1, panelFont, "center", "center", false, false, true, false, true)

			-- ** Fegyverskill csökkentés
			buttons.downgrade = {panelPosX + panelWidth - 200, panelPosY - 40, 200, 30}

			if activeButton == "downgrade" then
				dxDrawRectangle(buttons.downgrade[1], buttons.downgrade[2], buttons.downgrade[3], buttons.downgrade[4], tocolor(61, 122, 188, 200))
			else
				dxDrawRectangle(buttons.downgrade[1], buttons.downgrade[2], buttons.downgrade[3], buttons.downgrade[4], tocolor(61, 122, 188, 150))
			end
			dxDrawText("Fegyverskillek csökkentése", buttons.downgrade[1], buttons.downgrade[2], buttons.downgrade[1] + buttons.downgrade[3], buttons.downgrade[2] + buttons.downgrade[4], tocolor(0, 0, 0), 0.75, panelFont, "center", "center")

			-- ** Button handler
			activeButton = false

			if isCursorShowing() then
				local relX, relY = getCursorPosition()
				local absX, absY = relX * screenX, relY * screenY

				for k, v in pairs(buttons) do
					if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			end
		end
	end
)

function getAvailableTime()
	if weaponTraining then
		local weaponStat = weaponStats[weaponTraining]

		if type(weaponStat) == "number" then
			weaponStat = weaponStats[weaponStat]
		end

		if weaponStat then
			local skillLevel = getPedStat(localPlayer, weaponStat[1])

			if skillLevel then
				if skillLevel >= 0 and skillLevel <= 100 then
					return 5000
				elseif skillLevel > 100 and skillLevel <= 200 then
					return 4000
				elseif skillLevel > 200 and skillLevel <= 300 then
					return 3000
				elseif skillLevel > 300 and skillLevel <= 400 then
					return 2000
				elseif skillLevel > 400 and skillLevel <= 500 then
					return 1500
				elseif skillLevel > 500 and skillLevel <= 600 then
					return 1400
				elseif skillLevel > 600 and skillLevel <= 700 then
					return 1300
				elseif skillLevel > 700 and skillLevel <= 800 then
					return 1200
				elseif skillLevel > 800 and skillLevel <= 900 then
					return 1100
				elseif skillLevel > 900 and skillLevel <= 1000 then
					return 1000
				end
			end
		end
	end

	return 1000
end

function calculateTime(seconds)
	seconds = tonumber(seconds)

	if seconds == 0 then
		return 0, 0
	else
		local min = string.format("%02.f", math.floor(seconds / 60))
		local sec = string.format("%02.f", math.floor(seconds - min * 60))

		return min, sec
	end
end
