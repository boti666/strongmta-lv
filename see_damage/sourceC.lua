local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = 1

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local lastVehicleDamage = 0
local lastSplatterTick = 0

local splatterStart = false
local greenSplatter = false
local splatters = {}
local splatterSizes = {
	[1] = {1024, 666},
	[2] = {1024, 751},
	[3] = {1024, 515},
	[4] = {1024, 510}
}

local vignetteShader = false
local damageEffect = false
local screenSource = dxCreateScreenSource(screenX, screenY)

local attackStartTick = false
local attackerPosX = 0
local attackerPosY = 0

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedres)
		if getResourceName(startedres) == "see_hud" then
			responsiveMultipler = exports.see_hud:getResponsiveMultipler()
		else
			if source == getResourceRootElement() then
				local see_hud = getResourceFromName("see_hud")

				if see_hud then
					if getResourceState(see_hud) == "running" then
						responsiveMultipler = exports.see_hud:getResponsiveMultipler()
					end
				end

				vignetteShader = dxCreateShader("files/vignette.fx")
			end
		end
	end)

addEventHandler("onClientHUDRender", getRootElement(),
	function ()
		local currentHealth = getElementHealth(localPlayer)

		if currentHealth < 25 then
			local progress = interpolateBetween(1, 0, 0, 0, 0, 0, currentHealth / 25, "Linear")

			dxUpdateScreenSource(screenSource)

			dxSetShaderValue(vignetteShader, "ScreenSource", screenSource)
			dxSetShaderValue(vignetteShader, "radius", 13)
			dxSetShaderValue(vignetteShader, "rdarkness", 0.5 * progress)
			dxSetShaderValue(vignetteShader, "gdarkness", 1 * progress)
			dxSetShaderValue(vignetteShader, "bdarkness", 1 * progress)

			dxDrawImage(0, 0, screenX, screenY, vignetteShader)
		else
			if #splatters >= 1 or damageEffect then
				local progress = 0.5

				if splatterStart then
					progress = interpolateBetween(0, 0, 0, 0.5, 0, 0, (getTickCount() - splatterStart) / 200, "Linear")
				elseif damageEffect then
					progress = interpolateBetween(0.5, 0, 0, 0, 0, 0, (getTickCount() - damageEffect) / 200, "Linear")

					if progress <= 0 then
						damageEffect = false
					end
				end

				dxUpdateScreenSource(screenSource)

				dxSetShaderValue(vignetteShader, "ScreenSource", screenSource)
				dxSetShaderValue(vignetteShader, "radius", 13)

				if greenSplatter then
					dxSetShaderValue(vignetteShader, "rdarkness", 1 * progress)
					dxSetShaderValue(vignetteShader, "gdarkness", 0.25 * progress)
					dxSetShaderValue(vignetteShader, "bdarkness", 1 * progress)
				else
					dxSetShaderValue(vignetteShader, "rdarkness", 0.5 * progress)
					dxSetShaderValue(vignetteShader, "gdarkness", 1 * progress)
					dxSetShaderValue(vignetteShader, "bdarkness", 1 * progress)
				end

				dxDrawImage(0, 0, screenX, screenY, vignetteShader)
			end
		end

		if #splatters >= 1 then
			if not splatterStart then
				splatterStart = getTickCount()
			end

			for k = 1, #splatters do
				local v = splatters[k]

				if v then
					local progress = 0

					if getTickCount() >= v[2] then
						local elapsedTime = getTickCount() - v[2]

						progress = elapsedTime / 1000

						if progress >= 1 then
							splatters[k] = nil

							if #splatters < 1 then
								splatterStart = false
								damageEffect = getTickCount()
							end
						end
					end

					if v then
						local alpha = interpolateBetween(
							255, 0, 0,
							0, 0, 0,
							progress, "Linear")

						dxDrawImage(v[3], v[4], v[5], v[6], "files/splatters/" .. v[1] .. ".png", 0, 0, 0, tocolor(255, 255, 255, alpha))
					end
				end
			end
		end

		if attackStartTick then
			local elapsedTime = getTickCount() - attackStartTick

			if elapsedTime <= 4500 then
				local alpha = 255

				if elapsedTime > 3500 then
					alpha = interpolateBetween(
						255, 0, 0,
						0, 0, 0,
						(elapsedTime - 3500) / 1000, "Linear")
				end

				local playerPosX, playerPosY = getElementPosition(localPlayer)
				local angle = -math.deg(math.atan2(attackerPosX - playerPosX, attackerPosY - playerPosY))

				if angle < 0 then
					angle = angle + 360
				end

				local cameraX, cameraY, _, lookAtX, lookAtY = getCameraMatrix()
				local angle2 = -math.deg(math.atan2(lookAtX - cameraX, lookAtY - cameraY))

				if angle2 < 0 then
					angle2 = angle2 + 360
				end

				local imageangle = -(angle - angle2)
				local theta = math.rad(imageangle)
				local x = (182 + 64) * math.sin(theta) - (0.5 * 256 * math.cos(theta))
				local y = (182 + 64) * math.cos(theta) + (0.5 * 256 * math.sin(theta))

				dxDrawImage(screenX / 2 + x, screenY / 2 - y, 256, 64, "files/arrow.png", imageangle, -128, -32, tocolor(255, 255, 255, alpha), true)
			else
				attackStartTick = false
			end
		end
	end, true, "high+999999999")

addEvent("addBloodToScreenByCarDamage", true)
addEventHandler("addBloodToScreenByCarDamage", getRootElement(),
	function (affected)
		local loss = affected[localPlayer] or 5

		if loss > 2 and getTickCount() - lastSplatterTick >= 1000 then
			lastSplatterTick = getTickCount()
			greenSplatter = false

			for i = 1, #splatters + 1 do
				if not splatters[i] then
					local id = math.random(1, 4)
					local sx = respc(splatterSizes[id][1])
					local sy = respc(splatterSizes[id][2])
					local x = math.random(-(sx / 2), screenX - sx + sx / 2)
					local y = math.random(-(sy / 2), screenY - sy + sy / 2)

					splatters[i] = {tostring(id), getTickCount() + math.abs(loss) * math.random(400, 600), x, y, sx, sy}

					break
				end
			end
		end
	end)

addEvent("addGreenSplatter", true)
addEventHandler("addGreenSplatter", getRootElement(),
	function (amount)
		if amount > 2 and getTickCount() - lastSplatterTick >= 1000 then
			lastSplatterTick = getTickCount()
			greenSplatter = true

			for i = 1, #splatters + math.random(1, 3) do
				if not splatters[i] then
					local id = math.random(1, 4)
					local sx = respc(splatterSizes[id][1])
					local sy = respc(splatterSizes[id][2])
					local x = math.random(-(sx / 2), screenX - sx + sx / 2)
					local y = math.random(-(sy / 2), screenY - sy + sy / 2)

					splatters[i] = {"g" .. tostring(id), getTickCount() + math.abs(amount) * math.random(400, 600), x, y, sx, sy}

					break
				end
			end
		end
	end)

addEventHandler("onClientPlayerDamage", localPlayer,
	function (attacker, weapon, bodypart, loss)
		if getElementData(source, "invulnerable") then
			cancelEvent()
			return
		end

		if getTickCount() - lastSplatterTick >= 1000 then
			lastSplatterTick = getTickCount()
			greenSplatter = false

			for i = 1, #splatters + 1 do
				if not splatters[i] then
					local id = math.random(1, 4)
					local sx = respc(splatterSizes[id][1])
					local sy = respc(splatterSizes[id][2])
					local x = math.random(-(sx / 2), screenX - sx + sx / 2)
					local y = math.random(-(sy / 2), screenY - sy + sy / 2)

					splatters[i] = {tostring(id), getTickCount() + math.abs(loss) * math.random(400, 600), x, y, sx, sy}

					break
				end
			end
		end

		if isElement(attacker) then
			if getElementType(attacker) == "player" then
				if weapon and weapon > 9 then
					attackerPosX, attackerPosY = getElementPosition(attacker)
					attackStartTick = getTickCount()
				end

				if getElementData(attacker, "tazerState") then
					if weapon == 24 then
						triggerServerEvent("€z€'i'×z'÷s*Äkl*k*", attacker, source)
						cancelEvent()
					end
				elseif bodypart == 9 then
					triggerServerEvent("processHeadShot", localPlayer, attacker, weapon)
					cancelEvent()
				end
			elseif getElementType(attacker) == "ped" then
				local hitDamage = getElementData(attacker, "hitDamage")

				if hitDamage then
					setElementHealth(localPlayer, getElementHealth(localPlayer) - hitDamage)
					cancelEvent()
				end
			end
		end
	end)

addEventHandler("onClientVehicleDamage", getRootElement(),
	function (attacker, weapon, loss, dmgPosX, dmgPosY, dmgPosZ, tireId)
		if (not weapon or weapon == 0) and attacker == localPlayer and not tireId then
			if not getElementData(localPlayer, "invulnerable") then
				triggerServerEvent("damageCarPunch", localPlayer)
			end
		end

		if not weapon and source == getPedOccupiedVehicle(localPlayer) then
			if getTickCount() - lastVehicleDamage >= 2000 then
				local vehicleModel = getElementModel(source)
				local damageMultipler = damageMultiplers[vehicleModel] or 1
				local affected = {}
				local count = 0

				for k, v in pairs(getVehicleOccupants(source)) do
					if (getElementData(v, "adminDuty") or 0) == 0 then
						if getElementData(v, "player.seatBelt") then
							affected[v] = math.floor(loss * 0.3) * 0.5 * damageMultipler
						else
							affected[v] = math.floor(loss * 0.3) * damageMultipler
						end

						if affected[v] == 0 then
							affected[v] = nil
						else
							count = count + 1
						end
					end
				end

				if count > 0 then
					triggerServerEvent("vehicleDamage", localPlayer, affected)
				end

				lastVehicleDamage = getTickCount()
			end
		end
	end, true, "high+99999")

addEventHandler("onClientPedDamage", getRootElement(),
	function ()
		if getElementData(source, "invulnerable") then
			cancelEvent()
		end
	end)

addEventHandler("onClientPlayerStealthKill", getRootElement(),
	function (targetPlayer)
		cancelEvent()
	end)

local seatBeltLastUse = 0
local seatBeltTimer = false

addCommandHandler("öv",
	function ()
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if isElement(pedveh) then
			if (getVehicleType(pedveh) or "N/A") == "Automobile" and not beltlessModels[getElementModel(pedveh)] then
				if getTickCount() - seatBeltLastUse >= 1000 then
					setElementData(localPlayer, "player.seatBelt", not getElementData(localPlayer, "player.seatBelt"))

					if not getElementData(localPlayer, "player.seatBelt") then
						exports.see_chat:localActionC(localPlayer, "kicsatolja a biztonsági övét.")
						playSound(":see_vehiclepanel/files/beltout.mp3", false)
					else
						exports.see_chat:localActionC(localPlayer, "becsatolja a biztonsági övét.")
						playSound(":see_vehiclepanel/files/beltin.mp3", false)
					end

					seatBeltLastUse = getTickCount()
				else
					exports.see_hud:showInfobox("e", "Csak másodpercenként csatolhatod ki/be az öved.")
				end
			end
		end
	end)
bindKey("F5", "down", "öv")

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "player.seatBelt"then
			local myveh = getPedOccupiedVehicle(localPlayer)
			local pedveh = getPedOccupiedVehicle(source)

			if isElement(myveh) and isElement(pedveh) and myveh == pedveh then
				if source ~= localPlayer then
					if getElementData(source, "player.seatBelt") then
						playSound(":see_vehiclepanel/files/beltin.mp3", false)
					else
						playSound(":see_vehiclepanel/files/beltout.mp3", false)
					end
				end

				checkSeatBelt(myveh)
			end
		end
	end)

addEventHandler("onClientVehicleStartEnter", getRootElement(),
	function (player)
		if player == localPlayer then
			setElementData(localPlayer, "player.seatBelt", false)
		end
	end)

addEventHandler("onClientPlayerVehicleEnter", getRootElement(),
	function (vehicle, seat)
		if vehicle == getPedOccupiedVehicle(localPlayer) or source == localPlayer then
			checkSeatBelt(vehicle)
		end
	end)

addEventHandler("onClientPlayerVehicleExit", getRootElement(),
	function (vehicle, seat)
		if vehicle == getPedOccupiedVehicle(localPlayer) or source == localPlayer then
			checkSeatBelt(vehicle)
		end
	end)

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		local pedveh = getPedOccupiedVehicle(source)

		if pedveh == getPedOccupiedVehicle(localPlayer) then
			setTimer(checkSeatBelt, 1000, 1, pedveh)
		end
	end)

function seatBeltSound()
	local pedveh = getPedOccupiedVehicle(localPlayer)

	if pedveh then
		if getVehicleEngineState(pedveh) then
			playSound(":see_vehiclepanel/files/belt.mp3", false)
		end
	else
		if isTimer(seatBeltTimer) then
			killTimer(seatBeltTimer)
		end

		if getElementData(localPlayer, "player.seatBelt") then
			setElementData(localPlayer, "player.seatBelt", false)
		end
	end
end

function checkSeatBelt(vehicle)
	if isElement(vehicle) then
		if beepingModels[getElementModel(vehicle)] then
			local playSound = false

			for k, v in pairs(getVehicleOccupants(vehicle)) do
				if getElementType(v) == "player" and not getElementData(v, "player.seatBelt") then
					playSound = true
					break
				end
			end

			if not playSound then
				if isTimer(seatBeltTimer) then
					killTimer(seatBeltTimer)
				end
			elseif not isTimer(seatBeltTimer) then
				seatBeltTimer = setTimer(seatBeltSound, 1500, 0)
			end
		elseif isTimer(seatBeltTimer) then
			killTimer(seatBeltTimer)
		end
	end
end

local bulletLocation = {
	[3] = "törzsben",
	[4] = "medencében",
	[5] = "bal kézben",
	[6] = "jobb kézben",
	[7] = "bal lábban",
	[8] = "jobb lábban",
	[9] = "fejben"
}

local surfaceLocation = {
	[3] = "törzsön",
	[4] = "medencén",
	[5] = "bal kézen",
	[6] = "jobb kézen",
	[7] = "bal lábon",
	[8] = "jobb lábon",
	[9] = "fejen"
}

local bulletOperation = {
	[3] = "törzséből",
	[4] = "medencéjéből",
	[5] = "bal kezéből",
	[6] = "jobb kezéből",
	[7] = "bal lábából",
	[8] = "jobb lábából",
	[9] = "fejéből"
}

local stitchOperation = {
	[3] = "törzsén",
	[4] = "medencéjén",
	[5] = "bal kezén",
	[6] = "jobb kezén",
	[7] = "bal lábán",
	[8] = "jobb lábán",
	[9] = "fején"
}

local panelPosX = 0
local panelPosY = 0
local panelFont = false

local buttons = {}
local activeButton = false

local examinedPed = false
local injureLeftFoot = false
local injureRightFoot = false
local injureLeftArm = false
local injureRightArm = false
local bulletDamages = false

local canOperate = false
local canStitch = false

function examineMyself()
	if not examinedPed then
		examinedPed = localPlayer

		panelPosX = screenX / 2
		panelPosY = screenY / 2
		panelFont = dxCreateFont("files/Roboto.ttf", respc(13), false, "antialiased")

		showCursor(true)

		bulletDamages = getElementData(examinedPed, "bulletDamages") or {}

		canOperate = exports.see_items:playerHasItem(364)
		canStitch = exports.see_items:playerHasItem(371)

		if not exports.see_groups:isPlayerInGroup(localPlayer, 2) then
			canOperate = false
			canStitch = false
		end
	end
end
addCommandHandler("examinemyself", examineMyself)
addCommandHandler("sérüléseim", examineMyself)
addCommandHandler("seruleseim", examineMyself)

local lastTryToHelpUp = 0

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absoluteX, absoluteY, _, _, _, clickedElement)
		if not examinedPed and clickedElement then
			if button == "right" and state == "up" then
				if clickedElement ~= localPlayer then
					local elementType = getElementType(clickedElement)

					if elementType == "player" or (elementType == "ped" and getElementData(clickedElement, "deathPed")) then
						if not isPedHeadless(clickedElement) then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local targetX, targetY, targetZ = getElementPosition(clickedElement)

							if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) > 5 then
								return
							end

							examinedPed = clickedElement
							panelPosX = absoluteX - 180
							panelPosY = absoluteY

							injureLeftFoot = getElementData(examinedPed, "char.injureLeftFoot")
							injureRightFoot = getElementData(examinedPed, "char.injureRightFoot")
							injureLeftArm = getElementData(examinedPed, "char.injureLeftArm")
							injureRightArm = getElementData(examinedPed, "char.injureRightArm")

							panelFont = dxCreateFont("files/Roboto.ttf", respc(13), false, "antialiased")

							showCursor(true)
						end
					end
				end
			end
		end

		if activeButton then
			if button == "left" and state == "up" then
				if activeButton == "exit" then
					closeExamine()
				end

				if activeButton == "examineBody" then
					if getElementType(examinedPed) == "player" then
						bulletDamages = getElementData(examinedPed, "bulletDamages") or {}
					else
						bulletDamages = getElementData(examinedPed, "deathPed") or {}

						if bulletDamages then
							bulletDamages = bulletDamages[5] or {}
						end
					end

					canOperate = exports.see_items:playerHasItem(364)
					canStitch = exports.see_items:playerHasItem(371)

					if not exports.see_groups:isPlayerInGroup(localPlayer, 2) then
						canOperate = false
						canStitch = false
					end
				end

				if activeButton and string.find(activeButton, "getoutbullet") then
					if canOperate then
						local selected = gettok(activeButton, 2, ":")
						local dmgtype = tonumber(gettok(selected, 1, ";"))
						local bodypart = tonumber(gettok(selected, 2, ";"))
						local visibleName = getElementData(examinedPed, "visibleName"):gsub("_", " ")

						iprint(examinedPed, selected)

						triggerServerEvent("getOutBullet", examinedPed, selected)

						if dmgtype >= 25 and dmgtype <= 27 then
							exports.see_chat:localActionC(localPlayer, "kiveszi a söréteket " .. visibleName .. " " .. bulletOperation[bodypart] .. ".")
						else
							exports.see_chat:localActionC(localPlayer, "kivesz egy golyót " .. visibleName .. " " .. bulletOperation[bodypart] .. ".")
						end

						closeExamine()
					end
				end

				if activeButton and string.find(activeButton, "stitch") then
					if canStitch then
						local selected = gettok(activeButton, 2, ":")
						local bodypart = tonumber(gettok(selected, 2, ";"))
						local visibleName = getElementData(examinedPed, "visibleName"):gsub("_", " ")

						triggerServerEvent("stitchPlayerCut", examinedPed, selected)

						exports.see_chat:localActionC(localPlayer, "összevarr egy sebet " .. visibleName .. " " .. stitchOperation[bodypart] .. ".")

						closeExamine()
					end
				end

				if activeButton == "helpUp" then
					if getTickCount() - lastTryToHelpUp >= 1000 then
						lastTryToHelpUp = getTickCount()

						local injureLeftFoot = getElementData(examinedPed, "char.injureLeftFoot")
						local injureRightFoot = getElementData(examinedPed, "char.injureRightFoot")
						local injureLeftArm = getElementData(examinedPed, "char.injureLeftArm")
						local injureRightArm = getElementData(examinedPed, "char.injureRightArm")
						local damages = {}
						local damageCount = 0

						if getElementType(examinedPed) == "player" then
							damages = getElementData(examinedPed, "bulletDamages") or {}
						else
							damages = getElementData(examinedPed, "deathPed") or {}

							if damages then
								damages = damages[5] or {}
							end
						end

						for k, v in pairs(damages) do
							damageCount = damageCount + 1
						end

						if injureLeftFoot or injureRightFoot or injureLeftArm or injureRightArm or damageCount > 0 or getElementHealth(examinedPed) <= 20 then
							for data, amount in pairs(damages) do
								local typ = gettok(data, 1, ";")

								if typ == "stitch-cut" then
								elseif typ == "stitch-hole" then
								elseif typ == "punch" then
								elseif typ == "hole" then
									outputChatBox("#d75959[SeeMTA]: #ffffffAddig nem gyógyíthatod meg, amíg vágás van a testén!", 255, 255, 255, true)
									exports.see_hud:showInfobox("e", "Addig nem gyógyíthatod meg, amíg vágás van a testén!")
									return
								elseif typ == "cut" then
									outputChatBox("#d75959[SeeMTA]: #ffffffAddig nem gyógyíthatod meg, amíg vágás van a testén!", 255, 255, 255, true)
									exports.see_hud:showInfobox("e", "Addig nem gyógyíthatod meg, amíg vágás van a testén!")
									return
								else
									local weapon = tonumber(typ)

									if weapon >= 25 and weapon <= 27 then
										outputChatBox("#d75959[SeeMTA]: #ffffffAddig nem gyógyíthatod meg, amíg sörétek vannak a testében!", 255, 255, 255, true)
										exports.see_hud:showInfobox("e", "Addig nem gyógyíthatod meg, amíg sörétek vannak a testében!")
										return
									else
										outputChatBox("#d75959[SeeMTA]: #ffffffAddig nem gyógyíthatod meg, amíg golyó van a testében!", 255, 255, 255, true)
										exports.see_hud:showInfobox("e", "Addig nem gyógyíthatod meg, amíg golyó van a testében!")
										return
									end
								end
							end

							triggerServerEvent("takeMedicBag", localPlayer, examinedPed)
							closeExamine()
						else
							outputChatBox("#d75959[SeeMTA]: #ffffffA kiválasztott játékos nincs megsérülve!", 255, 255, 255, true)
							exports.see_hud:showInfobox("e", "A kiválasztott játékos nincs megsérülve!")
						end
					end
				end
			end
		end
	end)

function closeExamine()
	showCursor(false)

	examinedPed = false
	activeButton = false
	bulletDamages = false

	if isElement(panelFont) then
		destroyElement(panelFont)
	end

	panelFont = nil
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		if examinedPed then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local targetX, targetY, targetZ = getElementPosition(examinedPed)

			if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) > 5 then
				closeExamine()
				return
			end

			buttons = {}

			if bulletDamages then
				local damages = {}

				for data, amount in pairs(bulletDamages) do
					local typ = gettok(data, 1, ";")
					local part = tonumber(gettok(data, 2, ";"))

					if typ == "stitch-cut" then
						table.insert(damages, {"Összevart vágás a " .. surfaceLocation[part]})
					elseif typ == "stitch-hole" then
						table.insert(damages, {"Összevart golyó helye a " .. surfaceLocation[part]})
					elseif typ == "punch" then
						table.insert(damages, {"Ütések a " .. surfaceLocation[part]})
					elseif typ == "hole" then
						table.insert(damages, {amount .. " golyó helye a " .. surfaceLocation[part], false, data})
					elseif typ == "cut" then
						table.insert(damages, {amount .. " vágás a " .. surfaceLocation[part], false, data})
					else
						local weapon = tonumber(typ)

						if weapon >= 25 and weapon <= 27 then
							table.insert(damages, {"Sörétek a " .. bulletLocation[part], data, false})
						else
							table.insert(damages, {amount .. " golyó a " .. bulletLocation[part], data, false})
						end
					end
				end

				if #damages == 0 then
					damages[1] = {"Nem található sérülés."}
				end

				local onesize = 30
				local panelHeight = 60 + onesize * #damages

				dxDrawRectangle(panelPosX, panelPosY, 300, panelHeight, tocolor(0, 0, 0, 150))

				local startY = panelPosY + 10

				for i = 1, #damages do
					local dmg = damages[i]
					local y = startY + onesize * (i - 1)

					dxDrawText(dmg[1], panelPosX + 10, y, 0, y + onesize, tocolor(255, 255, 255), 1, panelFont, "left", "center")

					if dmg[2] and canOperate then
						buttons["getoutbullet:" .. dmg[2]] = {panelPosX + 300 - 110, y + onesize / 2 - 10, 100, 20}

						if activeButton == "getoutbullet:" .. dmg[2] then
							dxDrawRectangle(panelPosX + 300 - 110, y + onesize / 2 - 10, 100, 20, tocolor(61, 122, 188, 200))
						else
							dxDrawRectangle(panelPosX + 300 - 110, y + onesize / 2 - 10, 100, 20, tocolor(61, 122, 188, 140))
						end

						dxDrawText("Kivétel", panelPosX + 300 - 110, y, panelPosX + 300 - 10, y + onesize, tocolor(0, 0, 0), 0.75, panelFont, "center", "center")
					elseif dmg[3] and canStitch then
						buttons["stitch:" .. dmg[3]] = {panelPosX + 300 - 110, y + onesize / 2 - 10, 100, 20}

						if activeButton == "stitch:" .. dmg[3] then
							dxDrawRectangle(panelPosX + 300 - 110, y + onesize / 2 - 10, 100, 20, tocolor(61, 122, 188, 200))
						else
							dxDrawRectangle(panelPosX + 300 - 110, y + onesize / 2 - 10, 100, 20, tocolor(61, 122, 188, 140))
						end

						dxDrawText("Összevarrás", panelPosX + 300 - 110, y, panelPosX + 300 - 10, y + onesize, tocolor(0, 0, 0), 0.75, panelFont, "center", "center")
					end
				end

				startY = panelPosY + onesize * #damages + 20

				buttons["exit"] = {panelPosX + 10, startY, 280, onesize}

				if activeButton == "exit" then
					dxDrawRectangle(panelPosX + 10, startY, 280, onesize, tocolor(215, 89, 89, 200))
				else
					dxDrawRectangle(panelPosX + 10, startY, 280, onesize, tocolor(215, 89, 89, 150))
				end

				dxDrawText("Kilépés", panelPosX, startY, panelPosX + 300, startY + onesize, tocolor(0, 0, 0), 1, panelFont, "center", "center")
			elseif examinedPed then
				local addY = 0

				if injureLeftFoot or injureRightFoot or injureLeftArm or injureRightArm or getElementHealth(examinedPed) <= 20 then
					dxDrawRectangle(panelPosX, panelPosY, 180, 150, tocolor(0, 0, 0, 150))

					if activeButton == "helpUp" then
						dxDrawRectangle(panelPosX + 10, panelPosY + 10, 160, 30, tocolor(61, 122, 188, 250))
					else
						dxDrawRectangle(panelPosX + 10, panelPosY + 10, 160, 30, tocolor(61, 122, 188, 200))
					end

					if getElementHealth(examinedPed) <= 20 then
						dxDrawText("Felsegítés", panelPosX + 10, panelPosY + 10, panelPosX + 10 + 160, panelPosY + 10 + 30, tocolor(0, 0, 0), 1, panelFont, "center", "center")
					elseif injureLeftFoot or injureRightFoot or injureLeftArm or injureRightArm or getElementHealth(examinedPed) <= 20 then
						dxDrawText("Gyógyítás", panelPosX + 10, panelPosY + 10, panelPosX + 10 + 160, panelPosY + 10 + 30, tocolor(0, 0, 0), 1, panelFont, "center", "center")
					end

					addY = addY + 50

					buttons["helpUp"] = {panelPosX + 10, panelPosY + 10, 160, 30}
				else
					dxDrawRectangle(panelPosX, panelPosY, 180, 100, tocolor(0, 0, 0, 150))
				end

				if activeButton == "examineBody" then
					dxDrawRectangle(panelPosX + 10, panelPosY + addY + 10, 160, 30, tocolor(61, 122, 188, 250))
				else
					dxDrawRectangle(panelPosX + 10, panelPosY + addY + 10, 160, 30, tocolor(61, 122, 188, 200))
				end

				dxDrawText("Vizsgálat", panelPosX + 10, panelPosY + addY + 10, panelPosX + 10 + 160, panelPosY + addY + 10 + 30, tocolor(0, 0, 0), 1, panelFont, "center", "center")

				buttons["examineBody"] = {panelPosX + 10, panelPosY + addY + 10, 160, 30}

				addY = addY + 50

				if activeButton == "exit" then
					dxDrawRectangle(panelPosX + 10, panelPosY + addY + 10, 160, 30, tocolor(215, 89, 89, 250))
				else
					dxDrawRectangle(panelPosX + 10, panelPosY + addY + 10, 160, 30, tocolor(215, 89, 89, 200))
				end

				dxDrawText("Kilépés", panelPosX + 10, panelPosY + addY + 10, panelPosX + 10 + 160, panelPosY + addY + 10 + 30, tocolor(0, 0, 0), 1, panelFont, "center", "center")

				buttons["exit"] = {panelPosX + 10, panelPosY + addY + 10, 160, 30}
			else
				dxDrawRectangle(panelPosX, panelPosY, 180, 100, tocolor(0, 0, 0, 150))

				buttons["examineBody"] = {panelPosX + 10, panelPosY + 10, 160, 30}

				if activeButton == "examineBody" then
					dxDrawRectangle(panelPosX + 10, panelPosY + 10, 160, 30, tocolor(61, 122, 188, 200))
				else
					dxDrawRectangle(panelPosX + 10, panelPosY + 10, 160, 30, tocolor(61, 122, 188, 150))
				end

				dxDrawText("Vizsgálat", panelPosX + 10, panelPosY + 10, panelPosX + 10 + 160, panelPosY + 10 + 30, tocolor(0, 0, 0), 1, panelFont, "center", "center")

				buttons["exit"] = {panelPosX + 10, panelPosY + 60, 160, 30}

				if activeButton == "exit" then
					dxDrawRectangle(panelPosX + 10, panelPosY + 60, 160, 30, tocolor(215, 89, 89, 200))
				else
					dxDrawRectangle(panelPosX + 10, panelPosY + 60, 160, 30, tocolor(215, 89, 89, 150))
				end

				dxDrawText("Kilépés", panelPosX + 10, panelPosY + 60, panelPosX + 10 + 160, panelPosY + 60 + 30, tocolor(0, 0, 0), 1, panelFont, "center", "center")
			end

			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx = cx * screenX
				cy = cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
						activeButton = k
					end
				end
			else
				activeButton = false
			end
		end
	end)

addCommandHandler("msegit",
	function ()
		local onlinemedic = false
		local players = getElementsByType("player")

		for i = 1, #players do
			local player = players[i]

			if player and exports.see_groups:isPlayerInGroup(player, 2) then
				onlinemedic = true
				break
			end
		end

		if onlinemedic then
			exports.see_accounts:showInfo("e", "Van fent mentős!")
			return
		end

		if not getElementData(localPlayer, "isPlayerDeath") and getElementHealth(localPlayer) > 0 and getElementHealth(localPlayer) <= 20 then
			exports.see_minigames:startMinigame("ghero", "helpUpMyself", "failedToHelpUpMyself", 0.15, 0.2, 120, 100)
			setElementData(localPlayer, "triedToHelpUp", true)
		end
	end)

addEvent("failedToHelpUpMyself", true)
addEventHandler("failedToHelpUpMyself", localPlayer,
	function ()
		outputChatBox("#d75959[SeeMTA]: #ffffffNem sikerült meggyógyítanod magadat.", 255, 255, 255, true)
		exports.see_hud:showInfobox("e", "Nem sikerült meggyógyítanod magadat.")
	end)

addEvent("helpUpMyself", true)
addEventHandler("helpUpMyself", localPlayer,
	function ()
		triggerServerEvent("helpUpPerson", localPlayer)
		outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen meggyógyítottad magadat.", 255, 255, 255, true)
		exports.see_hud:showInfobox("s", "Sikeresen meggyógyítottad magadat.")
		setElementData(localPlayer, "triedToHelpUp", true)
	end)

local helpUpPerson = false

addEvent("takeMedicBag", true)
addEventHandler("takeMedicBag", localPlayer,
	function (player)
		if isElement(player) then
			helpUpPerson = player
			exports.see_chat:localActionC(localPlayer, "elkezdte felsegíteni " .. getElementData(player, "visibleName"):gsub("_", " ") .. "-t.")

			if exports.see_groups:isPlayerInGroup(localPlayer, 2) then
				exports.see_minigames:startMinigame("ghero", "helpUpPerson", "failedToHelpUp", 0.15, 0.2, 105, 40)
			else
				exports.see_minigames:startMinigame("ghero", "helpUpPerson", "failedToHelpUp", 0.15, 0.2, 120, 100)
			end
		end
	end)

addEvent("failedToHelpUp", true)
addEventHandler("failedToHelpUp", localPlayer,
	function ()
		if isElement(helpUpPerson) then
			outputChatBox("#d75959[SeeMTA]: #ffffffNem sikerült felsegíteni " .. getElementData(helpUpPerson, "visibleName"):gsub("_", " ") .. "-t, ezért meghalt.", 255, 255, 255, true)
			exports.see_hud:showInfobox("e", "Nem sikerült felsegíteni, ezért meghalt.")
			triggerServerEvent("killPlayerBadHelpup", helpUpPerson)
		end
	end)

addEvent("helpUpPerson", true)
addEventHandler("helpUpPerson", localPlayer,
	function ()
		if isElement(helpUpPerson) then
			triggerServerEvent("helpUpPerson", helpUpPerson)
			outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen meggyógyítottad " .. getElementData(helpUpPerson, "visibleName"):gsub("_", " ") .. "-t.", 255, 255, 255, true)
			exports.see_hud:showInfobox("s", "Sikeresen meggyógyítottad.")
		end
	end)
