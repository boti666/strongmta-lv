if fileExists("sourceC.lua") then 
	fileDelete("sourceC.lua")
end

if fileExists("sourceG.lua") then 
	fileDelete("sourceG.lua")
end


addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setCameraShakeLevel(0)
	end 
)


local screenX, screenY = guiGetScreenSize()

local validSkins = {}
local invalidSkins = {
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[8] = true,
	[42] = true,
	[65] = true,
	[74] = true,
	[86] = true,
	[119] = true,
	[149] = true,
	[208] = true,
	[273] = true,
	[289] = true
}

for i = 1, 312 do
	if not invalidSkins[i] then
		table.insert(validSkins, i)
	end
end

local deathTypes = {
	[19] = "robbanás",
	[37] = "égés",
	[49] = "autóbaleset",
	[50] = "autóbaleset",
	[51] = "robbanás",
	[52] = "elütötték",
	[53] = "fulladás",
	[54] = "esés",
	[55] = "unknown",
	[56] = "verekedés",
	[57] = "fegyver",
	[59] = "tank",
	[63] = "robbanás",
	[0] = "verekedés"
}

local weaponNames = {
	Rammed = "autóbaleset",
	shovel = "Csákány",
	["colt 45"] = "Glock 17",
	silenced = "Hangtompítós Colt-45",
	rifle = "Vadász puska",
	sniper = "Remington 700",
	mp5 = "P90"
}

local screenSource = false
local deathSound = false
local deathShader = false

local preDeathStart = false
local preDeathTimer = false
local preDeathEnd = false

local deathFadeEffect = false
local deathStart = false
local deathEnd = false

local aetherObjects = {}
local aetherColshape = false

local visionStartTime = 0
local visionDuration = math.random(500, 750)
local visionIntenseStart = 5
local visionIntenseEnd = math.random(3, 15)
local visionColorStart = 10
local visionColorEnd = math.random(5, 20)

local ghostPeds = {}
local ghostMoving = false

local Roboto = false

local pickupObject = false
local pickupColshape = false
local pickupRotationStart = false
local pickupSpawnBack = false

local animControls = false
local endAnimTimer = false
local inAnimTime = false
local lastAnimSecond = -1
local lastInjureAnimSync = 0

local destroyElementEx = destroyElement
function destroyElement(element)
	if isElement(element) then
		destroyElementEx(element)
	end
end

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "isPlayerDeath" then
			if not getElementData(localPlayer, "isPlayerDeath") and (preDeathStart or preDeathEnd or deathStart) then
				setCameraTarget(localPlayer)

				preDeathStart = false
				preDeathEnd = false
				deathStart = false

				for i = 1, 5 do
					if ghostPeds[i] then
						destroyElement(ghostPeds[i])
						ghostPeds[i] = false
					end
				end

				deathFadeEffect = false

				if isTimer(preDeathTimer) then
					killTimer(preDeathTimer)
				end
				preDeathTimer = nil

				if pickupSpawnBack then
					triggerServerEvent("pickupSpawnBack", localPlayer)
				end

				destroyElement(screenSource)
				screenSource = nil

				destroyElement(deathShader)
				deathShader = nil

				destroyElement(deathSound)
				deathSound = nil

				destroyElement(aetherColshape)
				aetherColshape = nil

				for k, v in ipairs(aetherObjects) do
					destroyElement(aetherObjects[k])
					aetherObjects[k] = nil
				end
				aetherObjects = {}

				destroyElement(Roboto)
				Roboto = nil

				setGameSpeed(1)
				resetSkyGradient()

				if not pickupSpawnBack then
					print("showHUD")
					exports.see_hud:showHUD()
				end
			end
		elseif dataName == "loggedIn" then
			if getElementData(localPlayer, "loggedIn") and getElementData(localPlayer, "isPlayerDeath") then
				screenSource = dxCreateScreenSource(screenX, screenY)

				exports.see_hud:hideHUD()

				if getElementData(localPlayer, "cuffed") then
					exports.see_controls:toggleControl({"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, true)
				end

				setElementData(localPlayer, "isPlayerDeath", true)
				setElementData(localPlayer, "cuffed", false)
				setElementData(localPlayer, "tazed", false)
				setElementData(localPlayer, "player.seatBelt", false)

				aetherColshape = createColRectangle(minX, minY, maxX - minX, maxY - minY)

				for k, v in pairs(objectPositions) do
					local obj = createObject(4020, v[1], v[2], v[3])

					setElementDimension(obj, playerId)
					setElementInterior(obj, 111)
					setElementAlpha(obj, 0)

					table.insert(aetherObjects, obj)
				end

				deathFadeEffect = {getTickCount(), 0, 255}

				preDeathTimer = setTimer(
					function ()
						deathFadeEffect = {getTickCount(), 255, 0}

						setCameraTarget(localPlayer)
						triggerServerEvent("spawnPlayerInAether", localPlayer)

						destroyElement(deathShader)

						deathSound = playSound("files/death.mp3")
						Roboto = dxCreateFont("files/Roboto.ttf", 24, false, "antialiased")
						deathShader = dxCreateShader("files/urmaeffekt.fx")

						dxSetShaderValue(deathShader, "UVSize", screenX, screenY)
						dxSetShaderValue(deathShader, "screenSource", screenSource)
						dxSetShaderValue(deathShader, "BlurIntense", 5)
						dxSetShaderValue(deathShader, "ColorDivider", 10)

						setSkyGradient(255, 255, 255, 255, 255, 255)

						preDeathStart = false
						preDeathTimer = setTimer(
							function ()
								setGameSpeed(0.5)
								deathStart = getTickCount()
								pickupRotationStart = getTickCount()
							end,
						3000, 1)
					end,
				5000, 1)
			end
		end
	end)

addEventHandler("onClientPlayerSpawn", localPlayer,
	function ()
		setElementData(localPlayer, "customDeath", false)
	end)

addEventHandler("onClientPlayerWasted", localPlayer,
	function (killer, weapon, bodypart)
		local characterJail = getElementData(localPlayer, "char.jail") or 0
		local adminJail = getElementData(localPlayer, "acc.adminJail") or 0

		if characterJail + adminJail > 0 then
			triggerServerEvent("reSpawnInJail", localPlayer)
			return
		end

		local deathText = "ismeretlen"
		local customText = getElementData(source, "customDeath")

		setElementData(localPlayer, "startedAnim", false)

		if customText then
			deathText = customText
		elseif tonumber(weapon) then
			deathText = deathTypes[weapon]

			if not deathText then
				local weaponName = getWeaponNameFromID(weapon)

				if weaponNames[weaponName] then
					weaponName = weaponNames[weaponName]

					if weaponName == "autóbaleset" then
						deathText = "autóbaleset"
					else
						deathText = "fegyver: '" .. weaponName .. "'"
					end
				else
					deathText = "fegyver: '" .. weaponName .. "'"
				end

				if bodypart == 9 then
					deathText = deathText .. " (fejlövés)"
				end
			elseif deathText == "unknown" then
				deathText = "ismeretlen"
			end
		end

		setElementData(source, "deathReason", deathText)

		local x, y, z = getElementPosition(localPlayer)

		if y < 375 then -- Las Venturasban van-e
			setElementData(localPlayer, "deathInCountry", true)
		else
			setElementData(localPlayer, "deathInCountry", false)
		end

		screenSource = dxCreateScreenSource(screenX, screenY)
		deathSound = playSound("files/deathup.mp3")
		preDeathStart = getTickCount()
		deathShader = dxCreateShader("files/shader.fx")

		dxSetShaderValue(deathShader, "screenSource", screenSource)

		exports.see_hud:hideHUD()

		if getElementData(localPlayer, "cuffed") then
			exports.see_controls:toggleControl({"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, true)
		end

		setElementData(localPlayer, "isPlayerDeath", true)
		setElementData(localPlayer, "cuffed", false)
		setElementData(localPlayer, "tazed", false)
		setElementData(localPlayer, "player.seatBelt", false)

		local playerId = getElementData(localPlayer, "playerID")

		destroyElement(pickupObject)
		destroyElement(pickupColshape)

		if not isPedHeadless(localPlayer) then
			local pos = pickupPositions[math.random(1, #pickupPositions)]

			pickupObject = createObject(1254, pos[1], pos[2], pos[3] + 0.25)
			pickupColshape = createColSphere(pos[1], pos[2], pos[3] + 0.25, 0.5)

			setElementCollisionsEnabled(pickupObject, false)
			setElementDimension(pickupObject, playerId)
			setElementInterior(pickupObject, 111)

			setElementDimension(pickupColshape, playerId)
			setElementInterior(pickupColshape, 111)
		end

		pickupSpawnBack = false

		preDeathTimer = setTimer(
			function ()
				aetherColshape = createColRectangle(minX, minY, maxX - minX, maxY - minY)

				for k, v in pairs(objectPositions) do
					local obj = createObject(4020, v[1], v[2], v[3])
					setElementDimension(obj, playerId)
					table.insert(aetherObjects, obj)
				end

				deathFadeEffect = {getTickCount(), 0, 255}
				deathEnd = false

				preDeathTimer = setTimer(
					function ()
						deathFadeEffect = {getTickCount(), 255, 0}

						triggerServerEvent("spawnPlayerInAether", localPlayer)

						destroyElement(deathShader)
						destroyElement(deathSound)

						deathSound = playSound("files/death.mp3")
						Roboto = dxCreateFont("files/Roboto.ttf", 24, false, "antialiased")
						deathShader = dxCreateShader("files/urmaeffekt.fx")

						dxSetShaderValue(deathShader, "UVSize", screenX, screenY)
						dxSetShaderValue(deathShader, "screenSource", screenSource)
						dxSetShaderValue(deathShader, "BlurIntense", 5)
						dxSetShaderValue(deathShader, "ColorDivider", 10)

						setSkyGradient(255, 255, 255, 255, 255, 255)

						setCameraTarget(localPlayer)
						preDeathStart = false
						setGameSpeed(0.5)
						deathStart = getTickCount()
						pickupRotationStart = getTickCount()
					end,
				5000, 1)
			end,
		34000, 1)
	end)

function dxDrawBorderText(text, x, y, sx, sy, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	dxDrawText(text, x - 1, y - 1, sx - 1, sy - 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x - 1, y + 1, sx - 1, sy + 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x + 1, y - 1, sx + 1, sy - 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x + 1, y + 1, sx + 1, sy + 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x, y, sx, sy, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end

function rotateAround(angle, x, y, x2, y2)
	local theta = math.rad(angle)
	local rotatedX = x * math.cos(theta) - y * math.sin(theta) + (x2 or 0)
	local rotatedY = x * math.sin(theta) + y * math.cos(theta) + (y2 or 0)
	return rotatedX, rotatedY
end

function createGhostBehind(id)
	local skinId = validSkins[math.random(1, #validSkins)]

	local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
	local playerRotX, playerRotY, playerRotZ = getElementRotation(localPlayer)

	local rotatedX, rotatedY = rotateAround(playerRotZ + (id or 0) * 25, math.random(1, 3), math.random(3, 6))
	local pedElement = createPed(skinId, playerPosX - rotatedX, playerPosY - rotatedY, playerPosZ)

	setElementDimension(pedElement, getElementDimension(localPlayer))
	setElementInterior(pedElement, getElementInterior(localPlayer))
	setElementAlpha(pedElement, 175)

	ghostPeds[id] = pedElement

	for i = 1, #ghostPeds do
		if ghostPeds[i] then
			setElementCollidableWith(pedElement, ghostPeds[i], false)
		end
	end
end

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if inAnimTime then
			setElementData(localPlayer, "inAnimTime", getTickCount() - inAnimTime)
		else
			setElementData(localPlayer, "inAnimTime", 0)
		end
	end)

function endAnim()
	triggerServerEvent("killPlayerAnimTimer", localPlayer)
	endAnimTimer = false
	setElementData(localPlayer, "startedAnim", false)
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		local now = getTickCount()
		local currentHealth = getElementHealth(localPlayer)

		if currentHealth > 0 and currentHealth <= 20 then
			local block, anim = getPedAnimation(localPlayer)

			if block then
				block = string.lower(block)
			end

			if anim then
				anim = string.lower(anim)
			end

			if isPedInVehicle(localPlayer) then
				if block ~= "ped" or anim ~= "car_dead_lhs" then
					local elapsedTime = now - lastInjureAnimSync

					if elapsedTime > 500 then
						setPedAnimation(localPlayer, "ped", "car_dead_lhs", -1, false, false, false)
						triggerServerEvent("bringBackInjureAnim", localPlayer)
						lastInjureAnimSync = now
					end
				end
			elseif block ~= "sweet" or anim ~= "sweet_injuredloop" then
				local elapsedTime = now - lastInjureAnimSync

				if elapsedTime > 500 then
					setPedAnimation(localPlayer, "sweet", "sweet_injuredloop", -1, false, false, false)
					triggerServerEvent("bringBackInjureAnim", localPlayer)
					lastInjureAnimSync = now
				end
			end

			if not isElement(Roboto) then
				Roboto = dxCreateFont("files/Roboto.ttf", 24, false, "antialiased")
			end

			if not animControls then
				animControls = true

				setElementData(localPlayer, "startedAnim", true)
				setElementFrozen(localPlayer, true)
				exports.see_controls:toggleControl({"all"}, false)
				--setCameraShakeLevel(50)

				local lastAnimTime = getElementData(localPlayer, "inAnimTime") or 0

				inAnimTime = now - lastAnimTime
				lastAnimSecond = -1

				if isTimer(endAnimTimer) then
					killTimer(endAnimTimer)
				end

				endAnimTimer = setTimer(endAnim, 1000 * 60 * 10, 1)
			end

			if endAnimTimer then
				local timeLeft = getTimerDetails(endAnimTimer)

				if timeLeft then
					timeLeft = timeLeft / 1000
				else
					timeLeft = 0
				end

				local minute = timeLeft / 60 % 60
				local second = timeLeft % 60

				minute = math.floor(minute)
				second = math.floor(second)

				if lastAnimSecond ~= second then
					lastAnimSecond = second
					setElementData(localPlayer, "inAnimTime", getTickCount() - inAnimTime)
				end

				if minute < 5 then
					dxDrawBorderText(string.format("%02d:%02d", minute, second), 0, screenY - screenY / 5, screenX, screenY, tocolor(215, 89, 89), 1, Roboto, "center", "center")
				else
					dxDrawBorderText(string.format("%02d:%02d", minute, second), 0, screenY - screenY / 5, screenX, screenY, tocolor(255, 255, 255), 1, Roboto, "center", "center")
				end
			end
		elseif animControls then
			animControls = false
			inAnimTime = false

			triggerServerEvent("bringBackInjureAnim", localPlayer, true)
			setElementFrozen(localPlayer, false)
			exports.see_controls:toggleControl({"all"}, true)
			--setCameraShakeLevel(0)

			if isTimer(endAnimTimer) then
				killTimer(endAnimTimer)
			end
			endAnimTimer = false

			destroyElement(Roboto)
			Roboto = nil

			setElementData(localPlayer, "startedAnim", false)
			setElementData(localPlayer, "inAnimTime", 0)
		end

		if preDeathStart then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local elapsedTime = now - preDeathStart
			local progress = elapsedTime / 40000
			local z = 0

			if playerZ >= 10000 or getElementInterior(localPlayer) ~= 0 then
				z = interpolateBetween(
					1.5, 0, 0,
					3.5, 0, 0,
					progress, "Linear")
			else
				z = interpolateBetween(
					5, 0, 0,
					60, 0, 0,
					progress, "Linear")
			end

			setCameraMatrix(playerX, playerY, playerZ + z, playerX, playerY, playerZ)
			dxUpdateScreenSource(screenSource)
			dxDrawImage(0, 0, screenX, screenY, deathShader)
		elseif preDeathEnd then
			local x, y, z = getElementPosition(localPlayer)
			local z2 = interpolateBetween(60, 0, 0, 0, 0, 0, (now - preDeathEnd) / 10000, "Linear")

			setCameraMatrix(x, y, z + z2, x, y, z)
			dxUpdateScreenSource(screenSource)
			dxDrawImage(0, 0, screenX, screenY, deathShader)
		elseif deathStart then
			local elapsedTime = now - deathStart

			dxUpdateScreenSource(screenSource)
			dxDrawImage(0, 0, screenX, screenY, deathShader)

			if elapsedTime >= 5000 and elapsedTime <= 20000 or elapsedTime >= 23000 and elapsedTime <= 28000 or elapsedTime >= 43000 and elapsedTime <= 65000 or elapsedTime >= 119000 and elapsedTime <= 128000 or elapsedTime >= 225000 and elapsedTime <= 235000 or elapsedTime >= 321000 and elapsedTime <= 334000 or elapsedTime >= 358000 and elapsedTime <= 370000 or elapsedTime >= 479000 and elapsedTime <= 487000 or elapsedTime >= 720000 and elapsedTime <= 728000 or elapsedTime >= 872000 and elapsedTime <= 907000 then
				for i = 1, 5 do
					local pedElement = ghostPeds[i]

					if pedElement then
						local playerX, playerY = getElementPosition(localPlayer)
						local targetX, targetY = getElementPosition(pedElement)
						local dist = getDistanceBetweenPoints2D(playerX, playerY, targetX, targetY)

						if dist <= 1 then
							destroyElement(pedElement)
							ghostPeds[i] = nil
						elseif i == 1 then
							if dist >= 7.5 then
								setPedCameraRotation(pedElement, -(math.deg(math.atan2(targetY - playerY, targetX - playerX)) + 180) + 90)

								if not ghostMoving then
									ghostMoving = true
									setPedControlState(pedElement, "forwards", true)
								end
							else
								setElementRotation(pedElement, 0, 0, math.deg(math.atan2(targetY - playerY, targetX - playerX)) + 180 - 90)

								if ghostMoving then
									ghostMoving = false
									setPedControlState(pedElement, "forwards", false)
								end
							end
						elseif ghostMoving then
							setPedCameraRotation(pedElement, -(math.deg(math.atan2(targetY - playerY, targetX - playerX)) + 180) + 90)
							setPedControlState(pedElement, "forwards", true)
						else
							setElementRotation(pedElement, 0, 0, math.deg(math.atan2(targetY - playerY, targetX - playerX)) + 180 - 90)
							setPedControlState(pedElement, "forwards", false)
						end
					else
						createGhostBehind(i)
					end
				end

				local progress = (now - visionStartTime) / visionDuration

				if progress > 1 then
					visionStartTime = getTickCount()
					visionDuration = math.random(500, 750)

					visionIntenseStart = visionIntenseEnd
					visionIntenseEnd = math.random(3, 15)

					visionColorStart = visionColorEnd
					visionColorEnd = math.random(5, 20)
				end

				local intense, divider = interpolateBetween(
					visionIntenseStart, visionColorStart, 0,
					visionIntenseEnd, visionColorEnd, 0,
					progress, "Linear")

				dxSetShaderValue(deathShader, "BlurIntense", intense)
				dxSetShaderValue(deathShader, "ColorDivider", divider)
			else
				dxSetShaderValue(deathShader, "BlurIntense", 5)
				dxSetShaderValue(deathShader, "ColorDivider", 10)

				for i = 1, 5 do
					if ghostPeds[i] then
						destroyElement(ghostPeds[i])
						ghostPeds[i] = false
					end
				end
			end

			if pickupRotationStart and pickupObject then
				local progress = (now - pickupRotationStart) / 3000

				local rot = interpolateBetween(
					0, 0, 0,
					360, 0, 0,
					progress, "Linear")

				if progress > 1 then
					pickupRotationStart = getTickCount()
				end

				setElementRotation(pickupObject, 0, 0, rot)
			end

			local timeLeft = (60000 - elapsedTime) / 1000
			local minute = timeLeft / 60 % 60
			local second = timeLeft % 60

			minute = math.floor(minute)
			second = math.floor(second)

			if minute <= 0 and second <= 0 and not deathEnd then
				deathEnd = true
				deathFadeEffect = {getTickCount(), 0, 255}

				setElementFrozen(localPlayer, true)

				if isTimer(preDeathTimer) then
					killTimer(preDeathTimer)
				end

				preDeathTimer = setTimer(
					function ()
						setGameSpeed(1)
						resetSkyGradient()

						setElementData(localPlayer, "isPlayerDeath", false)
						triggerServerEvent("spawnToHospital", localPlayer)

						destroyElement(screenSource)
						destroyElement(deathShader)

						screenSource = dxCreateScreenSource(screenX, screenY)
						deathShader = dxCreateShader("files/shader.fx")
						dxSetShaderValue(deathShader, "screenSource", screenSource)

						deathFadeEffect = {getTickCount(), 255, 0}
						preDeathEnd = getTickCount()

						ghostMoving = false

						for i = 1, 5 do
							if ghostPeds[i] then
								destroyElement(ghostPeds[i])
							end

							ghostPeds[i] = nil
						end

						preDeathTimer = setTimer(
							function ()
								preDeathEnd = false

								setCameraTarget(localPlayer)
								setElementFrozen(localPlayer, false)
								exports.see_hud:showHUD()

								destroyElement(screenSource)
								destroyElement(pickupObject)
								destroyElement(pickupColshape)

								screenSource = nil
								pickupObject = nil
								pickupColshape = nil
							end,
						10000, 1)
					end,
				5000, 1)
			end

			if not deathEnd then
				if minute < 5 then
					dxDrawBorderText(string.format("%02d:%02d", minute, second), 0, 0, screenX - 50, screenY - 50, tocolor(215, 89, 89), 1, Roboto, "right", "bottom")
				else
					dxDrawBorderText(string.format("%02d:%02d", minute, second), 0, 0, screenX - 50, screenY - 50, tocolor(255, 255, 255), 1, Roboto, "right", "bottom")
				end
			end
		end

		if deathFadeEffect then
			local progress = (now - deathFadeEffect[1]) / 5000

			local alpha = interpolateBetween(
				deathFadeEffect[2], 0, 0,
				deathFadeEffect[3], 0, 0,
				progress, "Linear")

			if deathFadeEffect[2] <= 0 and progress > 1 then
				deathFadeEffect = false
			end

			dxDrawRectangle(0, 0, screenX, screenY, tocolor(255, 255, 255, alpha))
		end
	end)

addEventHandler("onClientColShapeLeave", getRootElement(),
	function (hitElement)
		if aetherColshape and source == aetherColshape and hitElement == localPlayer then
			if deathStart and not deathEnd then
				local playerX, playerY, playerZ = getElementPosition(localPlayer)
				setElementPosition(localPlayer, math.random(minX, maxX), math.random(minY, maxY), playerZ, false)
			end
		end
	end)

addEventHandler("onClientColShapeHit", getRootElement(),
	function (hitElement)
		if hitElement == localPlayer and source and pickupColshape then
			if source == pickupColshape then
				destroyElement(source)

				pickupSpawnBack = true
				setElementFrozen(localPlayer, true)
				deathFadeEffect = {getTickCount(), 0, 255}

				if isTimer(preDeathTimer) then
					killTimer(preDeathTimer)
				end

				preDeathTimer = setTimer(
					function ()
						setGameSpeed(1)
						resetSkyGradient()

						setElementData(localPlayer, "isPlayerDeath", false)

						destroyElement(screenSource)
						destroyElement(deathShader)

						screenSource = dxCreateScreenSource(screenX, screenY)
						deathShader = dxCreateShader("files/shader.fx")
						dxSetShaderValue(deathShader, "screenSource", screenSource)

						deathFadeEffect = {getTickCount(), 255, 0}
						preDeathEnd = getTickCount()

						ghostMoving = false

						for i = 1, 5 do
							if ghostPeds[i] then
								destroyElement(ghostPeds[i])
							end

							ghostPeds[i] = nil
						end

						preDeathTimer = setTimer(
							function ()
								preDeathEnd = false

								setCameraTarget(localPlayer)
								setElementFrozen(localPlayer, false)
								triggerServerEvent("pickupSpawnBack", localPlayer)
								exports.see_hud:showHUD()

								destroyElement(screenSource)
								destroyElement(pickupObject)
								destroyElement(pickupColshape)

								screenSource = nil
								pickupObject = nil
								pickupColshape = nil
							end,
						10000, 1)
					end,
				5000, 1)
			end
		end
	end)