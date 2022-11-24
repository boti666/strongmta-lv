local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local sirenVehicles = {
	[596] = true, -- Police LS
	[597] = true, -- Police SF
	[598] = true, -- Police LV
	[599] = true, -- Police Ranger
	[490] = true, -- FBI Rancher
	[416] = true, -- Ambulance
	[407] = true, -- Fire Truck
}

local sirenGui = true
local sirenGuiWidth = respc(248.5)
local sirenGuiHeight = respc(69.5)
local sirenGuiPosX = screenX / 2 - sirenGuiWidth / 2
local sirenGuiPosY = screenY - sirenGuiHeight * 2
local sirenVeh = false

local isPanelMoving = false
local moveDiffX = false
local moveDiffY = false

local Roboto = false
local activeButton = false

local sirenSound = 0
local switchClickTick = 0
local soundClickTick = 0
local hornClickTick = 0

addCommandHandler("togsirengui",
	function ()
		sirenGui = not sirenGui
		activeButton = false
	end)

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (player, seat)
		if player == localPlayer then
			if seat == 0 or seat == 1 then
				sirenVeh = false

				if sirenVehicles[getElementModel(source)] or getElementData(source, "civilSiren") then
					sirenSound = getElementData(source, "sirenSound") or 0
					outputChatBox("#598ed7[StrongMTA - Rendőrség]:#FFFFFF A szirénakezelő panel eltüntetéséhez/előhozásához használd a /togsirengui parancsot.", 255, 255, 255, true)
					sirenVeh = true
				end
			end
		end
	end)

addEventHandler("onClientVehicleExit", getRootElement(),
	function (player, seat)
		if player == localPlayer then
			sirenVeh = false
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY)
		if sirenGui and activeButton then
			if button == "left" then
				if state == "down" then
					if activeButton == "moveSirenGui" then
						isPanelMoving = "sirenGui"
						moveDiffX = absX - sirenGuiPosX
						moveDiffY = absY - sirenGuiPosY
					else
						if activeButton == "switchTheSiren" or string.find(activeButton, "sirenSound:") or activeButton == "sirenHorn" then
							triggerSirenFunctions(activeButton)
						end
					end
				else
					isPanelMoving = false
					moveDiffX = false
					moveDiffY = false
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if isPedInVehicle(localPlayer) then
			local strongVEH = getPedOccupiedVehicle(localPlayer)
			if isElement(strongVEH) then
				if sirenGui and sirenVeh or getElementData(strongVEH, "civilSiren") then
					if getPedOccupiedVehicleSeat(localPlayer) == 0 or getPedOccupiedVehicleSeat(localPlayer) == 1 then
						local currVeh = getPedOccupiedVehicle(localPlayer)
						local model = getElementModel(currVeh)

						if sirenVehicles[model] or getElementData(strongVEH,"sirens->State") or getElementData(strongVEH, "civilSiren") then
							local relX, relY = getCursorPosition()
							local absX, absY = -1, -1

							if relX then
								absX = relX * screenX
								absY = relY * screenY
							end

							if not isElement(Roboto) then
								Roboto = dxCreateFont("files/fonts/Roboto.ttf", respc(15), false, "antialiased")
							end

							local x, y = sirenGuiPosX, sirenGuiPosY
							local sx, sy = sirenGuiWidth, sirenGuiHeight
							local buttons = {}

							if isPanelMoving == "sirenGui" then
								sirenGuiPosX = absX - moveDiffX
								sirenGuiPosY = absY - moveDiffY
							end

							-- ** Keret
							dxDrawRectangle(x, y, sx, 2, tocolor(0, 0, 0, 200))
							dxDrawRectangle(x, y + sy - 2, sx, 2, tocolor(0, 0, 0, 200))
							dxDrawRectangle(x, y + 2, 2, sy - 4, tocolor(0, 0, 0, 200))
							dxDrawRectangle(x + sx - 2, y + 2, 2, sy - 4, tocolor(0, 0, 0, 200))

							-- ** Háttér
							dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))

							-- ** Cím
							dxDrawRectangle(x, y, sx, respc(25), tocolor(0, 0, 0, 200))
							dxDrawText("#3d7abcStrong#FFFFFFMTA - #598ed7Sziréna", x + respc(5), y, x + sx, y + respc(25), tocolor(255, 255, 255), 0.75, Roboto, "left", "center", false, false, false, true)
							
							buttons["moveSirenGui"] = {x, y, sx, respc(25)}

							-- ** Content
							local buttonAlpha = 175
							if activeButton == "switchTheSiren" then
								buttonAlpha = 255
							end

							local sirenParams = getVehicleSirenParams(currVeh)

							if getVehicleSirensOn(currVeh) and sirenParams.SirenType ~= 1 then
								dxDrawImage(x + 2 + respc(7.5), y + respc(30), respc(32), respc(32), "files/images/siren.png", 0, 0, 0, tocolor(89, 142, 215, buttonAlpha))
							else
								dxDrawImage(x + 2 + respc(7.5), y + respc(30), respc(32), respc(32), "files/images/siren.png", 0, 0, 0, tocolor(215, 89, 89, buttonAlpha))
							end
							buttons["switchTheSiren"] = {x + 2 + respc(7.5), y + respc(30), respc(32), respc(32)}

							-- Hang off
							local buttonAlpha = 175
							if activeButton == "sirenSound:0" then
								buttonAlpha = 255
							end

							if sirenSound == 0 then
								dxDrawImage(x + 2 + respc(15) + respc(32), y + respc(30), respc(32), respc(32), "files/images/soundoff.png", 0, 0, 0, tocolor(89, 142, 215, buttonAlpha))
							else
								dxDrawImage(x + 2 + respc(15) + respc(32), y + respc(30), respc(32), respc(32), "files/images/soundoff.png", 0, 0, 0, tocolor(215, 89, 89, buttonAlpha))
							end
							buttons["sirenSound:0"] = {x + 2 + respc(15) + respc(32), y + respc(30), respc(32), respc(32)}

							-- Hang 1
							local buttonAlpha = 175
							if activeButton == "sirenSound:1" then
								buttonAlpha = 255
							end

							if sirenSound == 1 then
								dxDrawImage(x + 2 + respc(22.5) + respc(64), y + respc(30), respc(32), respc(32), "files/images/sound.png", 0, 0, 0, tocolor(89, 142, 215, buttonAlpha))
							else
								dxDrawImage(x + 2 + respc(22.5) + respc(64), y + respc(30), respc(32), respc(32), "files/images/sound.png", 0, 0, 0, tocolor(215, 89, 89, buttonAlpha))
							end
							buttons["sirenSound:1"] = {x + 2 + respc(22.5) + respc(64), y + respc(30), respc(32), respc(32)}

							-- Hang 2
							local buttonAlpha = 175
							if activeButton == "sirenSound:2" then
								buttonAlpha = 255
							end

							if sirenSound == 2 then
								dxDrawImage(x + 2 + respc(30) + respc(96), y + respc(30), respc(32), respc(32), "files/images/sound.png", 0, 0, 0, tocolor(89, 142, 215, buttonAlpha))
							else
								dxDrawImage(x + 2 + respc(30) + respc(96), y + respc(30), respc(32), respc(32), "files/images/sound.png", 0, 0, 0, tocolor(215, 89, 89, buttonAlpha))
							end
							buttons["sirenSound:2"] = {x + 2 + respc(30) + respc(96), y + respc(30), respc(32), respc(32)}

							-- Hang 3
							local buttonAlpha = 175
							if activeButton == "sirenSound:3" then
								buttonAlpha = 255
							end

							if sirenSound == 3 then
								dxDrawImage(x + 2 + respc(37.5) + respc(128), y + respc(30), respc(32), respc(32), "files/images/sound.png", 0, 0, 0, tocolor(89, 142, 215, buttonAlpha))
							else
								dxDrawImage(x + 2 + respc(37.5) + respc(128), y + respc(30), respc(32), respc(32), "files/images/sound.png", 0, 0, 0, tocolor(215, 89, 89, buttonAlpha))
							end
							buttons["sirenSound:3"] = {x + 2 + respc(37.5) + respc(128), y + respc(30), respc(32), respc(32)}

							-- Légkürt
							local buttonAlpha = 175
							if activeButton == "sirenHorn" then
								buttonAlpha = 255
							end

							if getTickCount() - hornClickTick <= 550 then
								dxDrawImage(x + 2 + respc(45) + respc(160), y + respc(30), respc(32), respc(32), "files/images/horn.png", 0, 0, 0, tocolor(89, 142, 215, buttonAlpha))
							else
								dxDrawImage(x + 2 + respc(45) + respc(160), y + respc(30), respc(32), respc(32), "files/images/horn.png", 0, 0, 0, tocolor(215, 89, 89, buttonAlpha))
							end
							buttons["sirenHorn"] = {x + 2 + respc(45) + respc(160), y + respc(30), respc(32), respc(32)}

							-- ** Gombok
							activeButton = false

							if relX and relY then
								for k, v in pairs(buttons) do
									if absX >= v[1] and absY >= v[2] and absX <= v[1] + v[3] and absY <= v[2] + v[4] then
										activeButton = k
										break
									end
								end
							end
						end
					end
				end
			end
		end
	end)

function triggerSirenFunctions(state)
	local currVeh = getPedOccupiedVehicle(localPlayer)
	
	if state == "switchTheSiren" then
		if getTickCount() - switchClickTick >= 1000 then
			switchClickTick = getTickCount()

			triggerServerEvent("switchTheSiren", currVeh)

			exports.see_chat:localActionC(localPlayer, "megnyomott egy gombot a műszerfalon.")
		else
			exports.see_hud:showInfobox("e", "Ilyen gyorsan nem kéne kapcsolgatni!")
		end
	elseif string.find(state, "sirenSound:") then
		if getTickCount() - soundClickTick >= 250 then
			soundClickTick = getTickCount()

			setElementData(currVeh, "sirenSound", tonumber(gettok(state, 2, ":")))
			iprint("sirenSound: " .. tonumber(gettok(state, 2, ":")))

			exports.see_chat:localActionC(localPlayer, "megnyomott egy gombot a műszerfalon.")
		else
			exports.see_hud:showInfobox("e", "Ilyen gyorsan nem kéne kapcsolgatni!")
		end
	elseif state == "sirenHorn" then
		if getTickCount() - hornClickTick >= 350 then
			setElementData(currVeh, "sirenHorn", not getElementData(currVeh, "sirenHorn"))
			hornClickTick = getTickCount()
		else
			exports.see_hud:showInfobox("e", "Ilyen gyorsan nem kéne nyomogatni!")
		end
	end
end

addCommandHandler("sirenpanel",
	function (commandName, sirenId)
		sirenId = tonumber(sirenId)

		if not sirenId or sirenId < 1 or sirenId > 6 then
			outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [1-6]", 255, 255, 255, true)
			return
		end

		if getPedOccupiedVehicleSeat(localPlayer) == 0 or getPedOccupiedVehicleSeat(localPlayer) == 1 then
			if sirenVeh then
				if sirenId == 1 then
					triggerSirenFunctions("switchTheSiren")
				elseif sirenId == 2 then
					triggerSirenFunctions("sirenSound:0")
				elseif sirenId == 3 then
					triggerSirenFunctions("sirenSound:1")
				elseif sirenId == 4 then
					triggerSirenFunctions("sirenSound:2")
				elseif sirenId == 5 then
					triggerSirenFunctions("sirenSound:3")
				elseif sirenId == 6 then
					triggerSirenFunctions("sirenHorn")
				end
			end
		end
	end)

local sirenSounds = {}
local headLightData = {}
local strobeTimer = {}

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if sirenSounds[source] then
			if isElement(sirenSounds[source]) then
				destroyElement(sirenSounds[source])
			end

			sirenSounds[source] = nil
		end

		if strobeTimer[source] then
			if isTimer(strobeTimer[source]) then
				killTimer(strobeTimer[source])
			end

			strobeTimer[source] = nil
		end

		headLightData[source] = nil
	end)

function processStrobe(vehicle, state)
	if isElement(vehicle) then
		local model = getElementModel(vehicle)

		if state then
			setVehicleLightState(vehicle, 0, 1)
			setVehicleLightState(vehicle, 3, 1)
			setVehicleLightState(vehicle, 1, 0)
			setVehicleLightState(vehicle, 2, 0)

			if model == 443 or model == 525 then
				setVehicleHeadLightColor(vehicle, 255, 175, 25)
			else
				setVehicleHeadLightColor(vehicle, 10, 50, 255)
			end
		else
			setVehicleLightState(vehicle, 0, 0)
			setVehicleLightState(vehicle, 3, 0)
			setVehicleLightState(vehicle, 1, 1)
			setVehicleLightState(vehicle, 2, 1)

			if model == 443 or model == 525 then
				setVehicleHeadLightColor(vehicle, 255, 175, 25)
			else
				setVehicleHeadLightColor(vehicle, 255, 60, 60)
			end
		end

		strobeTimer[vehicle] = setTimer(processStrobe, 150, 1, vehicle, not state)
	else
		strobeTimer[vehicle] = nil
	end
end

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if key == "p" and press then
			local currVeh = getPedOccupiedVehicle(localPlayer)

			if currVeh and getVehicleController(currVeh) == localPlayer then
				local model = getElementModel(currVeh)

				if sirenVehicles[model] or model == 433 or model == 427 or model == 528 or model == 544 or model == 601 or model == 443 or model == 525 then
					if not isMTAWindowActive() then
						--if not getElementData(currVeh, "emergencyIndicator") and not getElementData(currVeh, "rightIndicator") and not getElementData(currVeh, "leftIndicator") then
							setElementData(currVeh, "emergencyStrobeLight", not getElementData(currVeh, "emergencyStrobeLight"))
						--end
					end
				end
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "emergencyStrobeLight" then
			if getElementData(source, "emergencyStrobeLight") then
				if not headLightData[source] then
					headLightData[source] = {}

					for i = 0, 3 do
						headLightData[source][i] = getVehicleLightState(source, i)
					end

					headLightData[source].color = {getVehicleHeadLightColor(source)}
					headLightData[source].override = getVehicleOverrideLights(source)

					setVehicleOverrideLights(source, 2)

					strobeTimer[source] = setTimer(processStrobe, 300, 1, source, true)
				end
			else
				if isTimer(strobeTimer[source]) then
					killTimer(strobeTimer[source])
				end

				if headLightData[source] then
					for i = 0, 3 do
						setVehicleLightState(source, i, headLightData[source][i])
					end

					setVehicleHeadLightColor(source, unpack(headLightData[source].color))
					setVehicleOverrideLights(source, headLightData[source].override)

					headLightData[source] = nil
				end
			end
		end

		if dataName == "sirenSound" or dataName == "sirenHorn" then
			local dataValue = getElementData(source, dataName)
			local currVeh = getPedOccupiedVehicle(localPlayer)

			if dataName == "sirenSound" then
				if source == currVeh then
					sirenSound = dataValue
				end

				if isElement(sirenSounds[source]) then
					destroyElement(sirenSounds[source])
				end

				if dataValue >= 2 then
					local x, y, z = getElementPosition(source)
					local model = getElementModel(source)
					local sirenType = dataValue

					if model == 407 then
						sirenType = sirenType .. "_fire"
					end

					if model == 416 and tonumber(sirenType) == 3 then
						sirenSounds[source] = playSound3D("files/sounds/ambulance.mp3", x, y, z, true)
					else
						sirenSounds[source] = playSound3D("files/sounds/siren" .. sirenType .. ".mp3", x, y, z, true)
					end

					attachElements(sirenSounds[source], source)
					setSoundMaxDistance(sirenSounds[source], 140)
				end
			end

			if dataName == "sirenHorn" then
				local x, y, z = getElementPosition(source)
				local soundElement = playSound3D("files/sounds/sirenhorn.mp3", x, y, z)

				attachElements(soundElement, source)
				setSoundMaxDistance(soundElement, 140)
				
				if source == currVeh then
					hornClickTick = getTickCount()
				end
			end
		end
	end)