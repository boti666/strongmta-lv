local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = 1

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local shopEntrancePosition = {-421.1318359375, 1163.7470703125, 1.7}
local shopColShape = createColSphere(shopEntrancePosition[1], shopEntrancePosition[2], shopEntrancePosition[3], 0.75)
local shopMarker = false

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedres)
		if getResourceName(startedres) == "see_hud" then
			responsiveMultipler = exports.see_hud:getResponsiveMultipler()
		elseif getResourceName(startedres) == "see_interiors" then
			if isElement(shopMarker) then
				destroyElement(shopMarker)
			end

			shopMarker = exports.see_interiors:createCoolMarker(shopEntrancePosition[1], shopEntrancePosition[2], shopEntrancePosition[3], "business_active")
		else
			if source == getResourceRootElement() then
				local see_hud = getResourceFromName("see_hud")

				if see_hud then
					if getResourceState(see_hud) == "running" then
						responsiveMultipler = exports.see_hud:getResponsiveMultipler()
					end
				end

				local see_interiors = getResourceFromName("see_interiors")

				if see_interiors then
					if getResourceState(see_interiors) == "running" then
						if isElement(shopMarker) then
							destroyElement(shopMarker)
						end

						shopMarker = exports.see_interiors:createCoolMarker(shopEntrancePosition[1], shopEntrancePosition[2], shopEntrancePosition[3], "business_active")
					end
				end
			end
		end
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if isElement(shopMarker) then
			destroyElement(shopMarker)
		end
	end)

local inColShape = false

addEventHandler("onClientColShapeHit", shopColShape,
	function (hitElement, matchingDimension)
		if hitElement == localPlayer then
			if matchingDimension then
				inColShape = true
				exports.see_hud:showInteriorBox("Hajószalon", "Nyomj [E] gombot a kereskedés megtekintéséhez.", false, "carshop")
			end
		end
	end)

addEventHandler("onClientColShapeLeave", shopColShape,
	function (hitElement, matchingDimension)
		if hitElement == localPlayer then
			if inColShape then
				inColShape = false
				exports.see_hud:endInteriorBox()
			end
		end
	end)

local inTheShop = false
local pressTick = 0

bindKey("e", "up",
	function ()
		if inColShape and not inTheShop then
			if getTickCount() >= pressTick + 5000 then
				pressTick = getTickCount()

				fadeCamera(false, 2)
				setTimer(enterShop, 2000, 1)

				inTheShop = true
				exports.see_hud:endInteriorBox()
				setElementFrozen(localPlayer, true)
			else
				outputChatBox("#d75959[StrongMTA]:#ffffff Csak 5 másodpercenként használhatod a bejáratot.", 255, 255, 255, true)
			end
		end
	end)

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

local availableColors = {
	{0, 0, 0},
	{106, 107, 109},
	{255, 255, 255},
	{111, 2, 5},
	{200, 18, 25},
	{7, 158, 79},
	{4, 80, 156},
	{110, 161, 179},
	{231, 116, 27}
}

local previewVehicle = false

local RobotoFont = false
local mesmerizeFont = false

local bcgMusic = false

local currentMoney = ""
local currentPP = ""

local selectedVehicle = 1
local selectedColor = {unpack(availableColors[1])}

local vehicleName = ""
local vehicleManufacturer = ""
local vehiclePrice = 0
local vehiclePremium = 0
local vehicleLimit = 0
local carModelCount = 0

local cinematicCamera = true
local freeLookCamera = false
local freeLook = {
	zoomInterpolation = false,
	zoom = 1,
	z = 3,
	r = 0,
	faceR = 0,
	faceZ = 0
}
local cameraInterpolation = false
local cameraStage = 1

local exitingProcessStarted = false

local promptActive = false
local promptWidth = 600
local promptHeight = 200
local promptPosX = screenX / 2 - promptWidth / 2
local promptPosY = screenY / 2 - promptHeight / 2

local buttons = {}
local activeButton = false

function exitShop()
	inTheShop = false

	removeEventHandler("onClientRender", getRootElement(), renderTheShowroom)
	removeEventHandler("onClientKey", getRootElement(), handleShowroomKeys)
	removeEventHandler("onClientElementDataChange", getRootElement(), handleDataChanges)
	removeEventHandler("onClientClick", getRootElement(), handlePromptClick)

	if isElement(previewVehicle) then
		destroyElement(previewVehicle)
	end

	if isElement(RobotoFont) then
		destroyElement(RobotoFont)
	end

	if isElement(mesmerizeFont) then
		destroyElement(mesmerizeFont)
	end
	
	if isElement(bcgMusic) then
		destroyElement(bcgMusic)
	end

	previewVehicle = nil
	RobotoFont = nil
	mesmerizeFont = nil
	bcgMusic = nil
	exitingProcessStarted = false

	setElementDimension(localPlayer, 0)
	setElementPosition(localPlayer, -417.1845703125, 1163.822265625, 2.3863942623138)
	setElementRotation(localPlayer, 0, 0, 270)
	setElementFrozen(localPlayer, false)
	setCameraTarget(localPlayer)

	fadeCamera(true, 1)
	showCursor(false)
	
	exports.see_hud:showHUD()

	triggerEvent("waterDimensionChange", localPlayer)
end

function enterShop()
	local playerId = getElementData(localPlayer, "playerID")

	currentMoney = formatNumber(getElementData(localPlayer, "char.Money"))
	currentPP = formatNumber(getElementData(localPlayer, "acc.premiumPoints"))

	local veh = vehiclesTable[selectedVehicle]
	local color = availableColors[math.random(1, #availableColors)]

	previewVehicle = createVehicle(veh.model, -491.9775390625, 1158.240234375, -0.55000001192093)
	setElementRotation(previewVehicle, 0, 0, 180)
	setVehicleColor(previewVehicle, color[1], color[2], color[3])
	setElementDimension(previewVehicle, playerId)
	selectedColor = {unpack(color)}

	vehicleName = exports.see_vehiclenames:getCustomVehicleName(veh.model)
	vehicleManufacturer = utf8.lower(exports.see_vehiclenames:getCustomVehicleManufacturer(veh.model)):gsub(" ", "-")
	
	vehiclePrice = veh.price
	vehiclePremium = veh.premium
	vehicleLimit = veh.limit

	triggerServerEvent("countCarsByModel", localPlayer, veh.model)

	cinematicCamera = true
	freeLookCamera = false

	cameraInterpolation = getTickCount()
	cameraStage = 1

	fadeCamera(true, 1)
	setElementDimension(localPlayer, playerId)
	setElementPosition(localPlayer, -400.2138671875, 1172.93359375, 6.6141986846924)
	setElementFrozen(localPlayer, true)
	setElementRotation(localPlayer, 0, 0, 0)
	
	mesmerizeFont = dxCreateFont("files/fonts/mesmerize.ttf", resp(30), false, "antialiased")
	RobotoFont = dxCreateFont("files/fonts/Roboto.ttf", resp(12), false, "antialiased")

	bcgMusic = playSound("files/sounds/showroom.mp3", true)

	exports.see_hud:hideHUD()
	showCursor(true)
	
	addEventHandler("onClientRender", getRootElement(), renderTheShowroom)
	addEventHandler("onClientKey", getRootElement(), handleShowroomKeys)
	addEventHandler("onClientElementDataChange", getRootElement(), handleDataChanges)
	addEventHandler("onClientClick", getRootElement(), handlePromptClick)

	triggerEvent("waterDimensionChange", localPlayer)
end

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

function renderTheShowroom()
	local now = getTickCount()
	local vehX, vehY, vehZ = getElementPosition(previewVehicle)

	setVehicleEngineState(previewVehicle, false)

	buttons = {}

	if freeLookCamera then
		-- Navigáció segédlet
		local fontHeight = dxGetFontHeight(1, RobotoFont) * 1.5

		local w1 = dxGetTextWidth("Cinematic kamera", 1, RobotoFont) + fontHeight
		local w2 = dxGetTextWidth("Kamera mozgatás", 1, RobotoFont) + fontHeight * 4

		local lineWidth = w1 + w2 + respc(10) * 3
		local lineHeight = respc(48)
		
		local linePosX = screenX - lineWidth
		local linePosY = screenY - respc(100)

		dxDrawRectangle(linePosX, linePosY, lineWidth, lineHeight, tocolor(0, 0, 0, 200))

		dxDrawImage(linePosX + respc(5), linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/q.png")
		dxDrawText("Cinematic kamera", linePosX + fontHeight + respc(10), linePosY, 0, linePosY + lineHeight, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

		linePosX = linePosX + w1 + respc(10)

		dxDrawImage(linePosX + respc(5), linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/w.png")
		dxDrawImage(linePosX + respc(5) + fontHeight, linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/a.png")
		dxDrawImage(linePosX + respc(5) + fontHeight * 2, linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/s.png")
		dxDrawImage(linePosX + respc(5) + fontHeight * 3, linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/d.png")
		dxDrawText("Kamera mozgatás", linePosX + fontHeight * 4 + respc(10), linePosY, 0, linePosY + lineHeight, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

		-- Kamera
		if getKeyState("w") then
			if freeLook.z <= 6 then
				freeLook.z = freeLook.z + 0.05
			end
		elseif getKeyState("s") then
			if freeLook.z >= 0 then
				freeLook.z = freeLook.z - 0.05
			end
		end

		if getKeyState("a") then
			freeLook.r = freeLook.r - 0.55
		elseif getKeyState("d") then
			freeLook.r = freeLook.r + 0.55
		end

		if freeLook.zoomInterpolation then
			local elapsedTime = now - freeLook.zoomInterpolation
			local progress = elapsedTime / 500

			if progress >= 1 then
				freeLook.zoomInterpolation = false
			end

			freeLook.zoom = interpolateBetween(0.75, 0, 0, 1, 0, 0, progress, "Linear")
		end

		local rotatedX, rotatedY = rotateAround(90 + freeLook.r, 7.5 / freeLook.zoom, 7.5 / freeLook.zoom)

		setCameraMatrix(vehX + rotatedX, vehY + rotatedY, vehZ + freeLook.z, vehX, vehY, vehZ)

		return
	end

	dxDrawText("<", respc(125), screenY - respc(300), screenX - respc(125), screenY, tocolor(255, 255, 255), 1, mesmerizeFont, "left", "center")
	dxDrawText(">", respc(125), screenY - respc(300), screenX - respc(125), screenY, tocolor(255, 255, 255), 1, mesmerizeFont, "right", "center")

	dxDrawText(vehicleName, 0 + 1, screenY - respc(300) + 1, screenX + 1, screenY + 1, tocolor(0, 0, 0), 1, mesmerizeFont, "center", "center")
	dxDrawText(vehicleName, 0, screenY - respc(300), screenX, screenY, tocolor(255, 255, 255), 1, mesmerizeFont, "center", "center")

	-- Fejléc
	local mesmerizeHeight = dxGetFontHeight(1, mesmerizeFont) * 1.75

	dxDrawRectangle(0, 0, screenX, respc(150), tocolor(0, 0, 0, 200))
	dxDrawText("HAJÓSZALON", respc(50) + mesmerizeHeight, 0, screenX, respc(150), tocolor(255, 255, 255), 1, mesmerizeFont, "left", "center")
	dxDrawImage(respc(25), respc(150) / 2 - mesmerizeHeight / 2, mesmerizeHeight, mesmerizeHeight, "files/images/logos/" .. vehicleManufacturer .. ".png")
	
	-- Színek
	dxDrawRectangle(screenX - #availableColors * respc(48), respc(150), respc(48) * #availableColors, respc(48), tocolor(0, 0, 0, 225))
	
	for i = 1, #availableColors do
		local x = screenX - (#availableColors + 1) * respc(48) + i * respc(48) + respc(8)
		local y = respc(150) + respc(8)

		local sx = respc(48) - respc(16)
		local sy = respc(48) - respc(16)

		if activeButton == "selectcolor:" .. i then
			dxDrawRectangle(x, y, sx, sy, tocolor(availableColors[i][1], availableColors[i][2], availableColors[i][3], 200))
		else
			dxDrawRectangle(x, y, sx, sy, tocolor(availableColors[i][1], availableColors[i][2], availableColors[i][3], 255))
		end
		
		buttons["selectcolor:" .. i] = {x, y, sx, sy}
	end

	-- Adatok
	dxDrawText("#d8d8d8Készpénz:\n#ffffff" .. currentMoney .. " $\n\n#d8d8d8Prémium egyenleg:\n#ffffff" .. currentPP .. " PP", screenX - respc(150) - respc(25), 0, screenX - respc(25), respc(150), tocolor(255, 255, 255), 1, RobotoFont, "left", "center", false, false, false, true)

	-- Lábléc
	dxDrawRectangle(0, screenY - respc(100), screenX, respc(100), tocolor(0, 0, 0, 200))
			
	if vehicleLimit == -1 then
		dxDrawText("Ár: " .. formatNumber(vehiclePrice) .. " $ vagy " .. formatNumber(vehiclePremium) .. " prémium pont", respc(10), screenY - respc(100), screenX, screenY - respc(100) + respc(50), tocolor(255, 255, 255), 1, RobotoFont, "left", "center", false, false, false, true)
	else
		dxDrawText("Ár: " .. formatNumber(vehiclePrice) .. " $ vagy " .. formatNumber(vehiclePremium) .. " prémium pont\nLimit: " .. carModelCount .. "/" .. vehicleLimit, respc(10), screenY - respc(100), screenX - respc(25), screenY - respc(100) + respc(50), tocolor(255, 255, 255), 1, RobotoFont, "left", "center", false, false, false, true)
	end

	-- Navigációs segédlet
	local fontHeight = dxGetFontHeight(1, RobotoFont) * 1.5

	local w1 = dxGetTextWidth("Vásárlás", 1, RobotoFont) + fontHeight * 2
	local w2 = dxGetTextWidth("Szabad kamera", 1, RobotoFont) + fontHeight
	local w3 = dxGetTextWidth("Navigáció", 1, RobotoFont) + fontHeight * 2
	local w4 = dxGetTextWidth("Kilépés", 1, RobotoFont) + fontHeight * 2

	local lineWidth = w1 + w2 + w3 + w4 + respc(10) * 7
	local lineHeight = respc(48)
	
	local linePosX = screenX - lineWidth
	local linePosY = screenY - respc(100)

	dxDrawRectangle(linePosX, linePosY, lineWidth, lineHeight, tocolor(0, 0, 0, 200))

	dxDrawImage(linePosX + respc(5), linePosY + (lineHeight - fontHeight) / 2, fontHeight * 4, fontHeight, "files/images/keys/enter.png")
	dxDrawText("Vásárlás", linePosX + fontHeight * 2 + respc(10), linePosY, 0, linePosY + lineHeight, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

	linePosX = linePosX + w1 + respc(10)

	dxDrawImage(linePosX + respc(5), linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/q.png")
	dxDrawText("Szabad kamera", linePosX + fontHeight + respc(10), linePosY, 0, linePosY + lineHeight, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

	linePosX = linePosX + w2 + respc(10)

	dxDrawImage(linePosX + respc(5), linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/left.png")
	dxDrawImage(linePosX + respc(5) + fontHeight, linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/right.png")
	dxDrawText("Navigáció", linePosX + fontHeight * 2 + respc(10), linePosY, 0, linePosY + lineHeight, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

	linePosX = linePosX + w3 + respc(10)

	dxDrawImage(linePosX + respc(5), linePosY + (lineHeight - fontHeight) / 2, fontHeight * 4, fontHeight, "files/images/keys/bcksp.png")
	dxDrawText("Kilépés", linePosX + fontHeight * 3, linePosY, 0, linePosY + lineHeight, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

	-- Megerősítő ablak
	if promptActive then
		local cx, cy = getCursorPosition()

		dxDrawRectangle(promptPosX, promptPosY, promptWidth, promptHeight, tocolor(0, 0, 0, 150))
		
		dxDrawText("#3d7abcStrongMTA - #FF9600Jármű vásárlás", promptPosX, promptPosY - 20, promptPosX, promptPosY, tocolor(255, 255, 255), 1, RobotoFont, "left", "center", false, false, false, true)
		
		dxDrawText("#FFFFFFBiztosan megszeretnéd vásárolni a kiválasztott járművet?", promptPosX, promptPosY + 30, promptPosX + promptWidth, 0, tocolor(255, 255, 255), 1, RobotoFont, "center", "top", false, false, false, true)
		
		-- Fizetés készpénzzel
		buttons["buyCarMoney"] = {promptPosX + 30, promptPosY + 80, promptWidth / 2 - 60, 40}

		if activeButton == "buyCarMoney" then
			dxDrawRectangle(promptPosX + 30, promptPosY + 80, promptWidth / 2 - 60, 40, tocolor(61, 122, 188, 240))
		else
			dxDrawRectangle(promptPosX + 30, promptPosY + 80, promptWidth / 2 - 60, 40, tocolor(61, 122, 188, 150))
		end

		dxDrawText("Vásárlás [Dollár]", promptPosX + 30, promptPosY + 80, promptPosX + 30 + promptWidth / 2 - 60, promptPosY + 80 + 40, tocolor(255, 255, 255), 1, RobotoFont, "center", "center")
		
		-- Fizetés pépével
		buttons["buyCarPremium"] = {promptPosX + promptWidth / 2 + 30, promptPosY + 80, promptWidth / 2 - 60, 40}
		
		if activeButton == "buyCarPremium" then
			dxDrawRectangle(promptPosX + promptWidth / 2 + 30, promptPosY + 80, promptWidth / 2 - 60, 40, tocolor(50, 179, 239, 240))
		else
			dxDrawRectangle(promptPosX + promptWidth / 2 + 30, promptPosY + 80, promptWidth / 2 - 60, 40, tocolor(50, 179, 239, 150))
		end

		dxDrawText("Vásárlás [Prémium Pont]", promptPosX + promptWidth / 2 + 30, promptPosY + 80, promptPosX + promptWidth / 2 + 30 + promptWidth / 2 - 60, promptPosY + 80 + 40, tocolor(255, 255, 255), 1, RobotoFont, "center", "center")
		
		-- Bezárás
		buttons["cancelPrompt"] = {promptPosX + 30, promptPosY + 140, promptWidth - 60, 40}

		if activeButton == "cancelPrompt" then
			dxDrawRectangle(promptPosX + 30, promptPosY + 140, promptWidth - 60, 40, tocolor(215, 89, 89, 240))
		else
			dxDrawRectangle(promptPosX + 30, promptPosY + 140, promptWidth - 60, 40, tocolor(215, 89, 89, 150))
		end

		dxDrawText("Mégsem", promptPosX + 30, promptPosY + 140, promptPosX + 30 + promptWidth - 60, promptPosY + 140 + 40, tocolor(255, 255, 255), 1, RobotoFont, "center", "center", false, false, false, true)
	end

	-- ** Egér
	local cx, cy = getCursorPosition()

	if tonumber(cx) and tonumber(cy) then
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

	-- Kamera
	if cameraInterpolation and now >= cameraInterpolation then
		local elapsedTime = now - cameraInterpolation

		if cameraStage == 1 then
			if elapsedTime >= 4000 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 5000 and cinematicCamera then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
			end
			
			local rot = interpolateBetween(
				10, 0, 0,
				20, 0, 0,
				elapsedTime / 5000, "OutQuad")

			local rotatedX, rotatedY = rotateAround(90 + rot, 7.5, 7.5)

			setCameraMatrix(vehX + rotatedX, vehY + rotatedY, vehZ + 3, vehX, vehY, vehZ)
		elseif cameraStage == 2 then
			if elapsedTime >= 9000 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 10000 and cinematicCamera then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
			end
			
			local pos = interpolateBetween(
				1, 0, 0,
				-3, 0, 0,
				elapsedTime / 10000, "Linear")
			
			setCameraMatrix(vehX, vehY + pos, vehZ + 12, vehX, vehY + pos, vehZ, 90)
		elseif cameraStage == 3 then
			if elapsedTime >= 9000 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 10000 and cinematicCamera then
				cameraStage = 1
				cameraInterpolation = now
			end
			
			local rot, pos = interpolateBetween(
				0, 0, 0,
				20, 1.2, 0,
				elapsedTime / 10000, "Linear")

			local rotatedX, rotatedY = rotateAround(90 + rot, -10 + pos, -10 + pos)
			
			setCameraMatrix(vehX + rotatedX, vehY + rotatedY, vehZ + 1.65, vehX, vehY, vehZ + 0.2)
		end
	end
end

addEvent("exitBoatShop", true)
addEventHandler("exitBoatShop", getRootElement(),
	function ()
		fadeCamera(false, 2)
		setTimer(exitShop, 2000, 1)
		exitingProcessStarted = true
		cinematicCamera = false
		promptActive = false
	end)

function handlePromptClick(button, state, cx, cy)
	if button == "left" then
		if state == "up" then
			if activeButton then
				if string.find(activeButton, "selectcolor:") then
					local selected = tonumber(gettok(activeButton, 2, ":"))

					setVehicleColor(previewVehicle, availableColors[selected][1], availableColors[selected][2], availableColors[selected][3])

					selectedColor = {unpack(availableColors[selected])}
				end

				if promptActive then
					if activeButton == "buyCarMoney" then
						if selectedVehicle then
							triggerServerEvent("buyTheCurrentBoat", localPlayer, vehiclesTable[selectedVehicle], "money", selectedColor[1], selectedColor[2], selectedColor[3])
						end
					elseif activeButton == "buyCarPremium" then
						if selectedVehicle then
							triggerServerEvent("buyTheCurrentBoat", localPlayer, vehiclesTable[selectedVehicle], "pp", selectedColor[1], selectedColor[2], selectedColor[3])
						end
					elseif activeButton == "cancelPrompt" then
						promptActive = false
					end
				end
			end
		end
	end
end

local lastNavigate = 0
local lastInteraction = 0

function handleShowroomKeys(key, press)
	if inTheShop and not exitingProcessStarted then
		if key == "backspace" then
			if press then
				if not freeLookCamera and not promptActive then
					fadeCamera(false, 2)
					setTimer(exitShop, 2000, 1)
					exitingProcessStarted = true
					cinematicCamera = false
					promptActive = false
				end
			end
		end

		if key == "enter" then
			if press then
				if not freeLookCamera and not promptActive then
					promptActive = true
				end
			end
		end

		if key == "q" then
			if press then
				if not promptActive then
					freeLookCamera = not freeLookCamera

					if freeLookCamera then
						fadeCamera(true, 0)
					else
						cameraInterpolation = getTickCount()
						cameraStage = 1
					end

					freeLook.zoomInterpolation = getTickCount()
					freeLook.zoom = 1

					playSound("files/sounds/cammove.mp3")
				end
			end
		end

		if key == "arrow_r" or key == "arrow_l" then
			if press then
				if not freeLookCamera and not promptActive and getTickCount() - lastNavigate >= 2000 then
					if key == "arrow_r" then
						selectedVehicle = selectedVehicle + 1
						
						if selectedVehicle > #vehiclesTable then
							selectedVehicle = 1
						end
					else
						selectedVehicle = selectedVehicle - 1
						
						if selectedVehicle < 1 then
							selectedVehicle = #vehiclesTable
						end
					end
					
					fadeCamera(false, 1)
					setTimer(fadeCamera, 1000, 1, true, 1)

					setTimer(
						function()
							cameraInterpolation = getTickCount()
							cameraStage = 1

							local veh = vehiclesTable[selectedVehicle]
							local color = availableColors[math.random(1, #availableColors)]

							setElementModel(previewVehicle, veh.model)
							setVehicleColor(previewVehicle, color[1], color[2], color[3])
							selectedColor = {unpack(color)}

							vehicleName = exports.see_vehiclenames:getCustomVehicleName(veh.model)
							vehicleManufacturer = utf8.lower(exports.see_vehiclenames:getCustomVehicleManufacturer(veh.model)):gsub(" ", "-")
							
							vehiclePrice = veh.price
							vehiclePremium = veh.premium
							vehicleLimit = veh.limit

							triggerServerEvent("countCarsByModel", localPlayer, veh.model)
						end,
					1000, 1)
					
					lastNavigate = getTickCount()
				end
			end
		end

		if freeLookCamera and press and not freeLook.zoomInterpolation and not promptActive then
			if key == "mouse_wheel_up" then
				if freeLook.zoom <= 2 then
					freeLook.zoom = freeLook.zoom + 0.1
				end
			elseif key == "mouse_wheel_down" then
				if freeLook.zoom >= 1 then
					freeLook.zoom = freeLook.zoom - 0.1
				end
			end
		end

		if key ~= "esc" then
			cancelEvent()
		end
	end
end

function handleDataChanges(dataName, oldValue)
	if source == localPlayer then
		if dataName == "char.Money" then
			currentMoney = formatNumber(getElementData(localPlayer, "char.Money"))
		elseif dataName == "acc.premiumPoints" then
			currentPP = formatNumber(getElementData(localPlayer, "acc.premiumPoints"))
		end
	end
end

addEvent("countCarsByModel", true)
addEventHandler("countCarsByModel", getRootElement(),
	function (count)
		carModelCount = count
	end)