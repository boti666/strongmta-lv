local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = 1

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local shopEntrancePosition = {1671.4169921875, 1814.3505859375, 10.8203125}
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
				exports.see_hud:showInteriorBox("Autószalon", "Nyomj [E] gombot a kereskedés megtekintéséhez.", false, "carshop")
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

local availableVehicles = {}
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

local showroomObject = false
local previewVehicle = false
local driverPed = false
local occupantPed = false

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
	z = 0,
	r = 0,
	faceR = 0,
	faceZ = 0
}
local firstPersonCamera = false
local cameraInterpolation = false
local cameraStage = 1

local exitingProcessStarted = false
local components = {"bonnet_dummy", "boot_dummy", "door_lf_dummy", "door_rf_dummy", "door_lr_dummy", "door_rr_dummy"}

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

	if isElement(showroomObject) then
		destroyElement(showroomObject)
	end

	if isElement(previewVehicle) then
		destroyElement(previewVehicle)
	end

	if isElement(driverPed) then
		destroyElement(driverPed)
	end
	
	if isElement(occupantPed) then
		destroyElement(occupantPed)
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

	showroomObject = nil
	previewVehicle = nil
	driverPed = nil
	occupantPed = nil
	RobotoFont = nil
	mesmerizeFont = nil
	bcgMusic = nil
	exitingProcessStarted = false

	setElementDimension(localPlayer, 0)
	setElementPosition(localPlayer, shopEntrancePosition[1], shopEntrancePosition[2], shopEntrancePosition[3])
	setElementRotation(localPlayer, 0, 0, 90)
	setElementFrozen(localPlayer, false)
	setCameraTarget(localPlayer)

	fadeCamera(true, 1)
	showCursor(false)
	
	exports.see_hud:showHUD()
end

function enterShop()
	availableVehicles = {}

	for i = 1, #vehiclesTable do
		local veh = vehiclesTable[i]

		if exports.see_vehiclenames:getCustomVehicleName(veh.model) ~= getVehicleNameFromModel(veh.model) then
			table.insert(availableVehicles, veh)
		end
	end
	
	table.sort(availableVehicles,
		function (a, b)
			return utf8.lower(exports.see_vehiclenames:getCustomVehicleName(b.model)) > utf8.lower(exports.see_vehiclenames:getCustomVehicleName(a.model))
		end
	)
	
	local gtaVehicles = {}
	
	for i = 1, #vehiclesTable do
		local veh = vehiclesTable[i]

		if exports.see_vehiclenames:getCustomVehicleName(veh.model) == getVehicleNameFromModel(veh.model) then
			table.insert(gtaVehicles, veh)
		end
	end
	
	table.sort(gtaVehicles,
		function (a, b)
			return utf8.lower(getVehicleNameFromModel(b.model)) > utf8.lower(getVehicleNameFromModel(a.model))
		end
	)
	
	for i = 1, #gtaVehicles do
		table.insert(availableVehicles, gtaVehicles[i])
	end

	local playerId = getElementData(localPlayer, "playerID")

	currentMoney = formatNumber(getElementData(localPlayer, "char.Money"))
	currentPP = formatNumber(getElementData(localPlayer, "acc.premiumPoints"))

	showroomObject = createObject(9950, 2140.1001, 3775.5, 1010.1)
	setElementDimension(showroomObject, playerId)

	local veh = availableVehicles[selectedVehicle]
	local color = availableColors[math.random(1, #availableColors)]

	previewVehicle = createVehicle(veh.model, 2628.609375, 2309.5710449219, 10.671875)
	setVehicleColor(previewVehicle, color[1], color[2], color[3])
	setElementDimension(previewVehicle, playerId)
	selectedColor = {unpack(color)}

	exports.see_tuning:applyHandling(previewVehicle)

	vehicleName = exports.see_vehiclenames:getCustomVehicleName(veh.model)
	vehicleManufacturer = utf8.lower(exports.see_vehiclenames:getCustomVehicleManufacturer(veh.model)):gsub(" ", "-")
	
	vehiclePrice = veh.price
	vehiclePremium = veh.premium
	vehicleLimit = veh.limit

	fuelType = getVehicleHandling(previewVehicle)["engineType"]
	driveType = getVehicleHandling(previewVehicle)["driveType"]
	tankCapacity = exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(veh.model)
	bootCapacity = exports.see_items:getWeightLimit("vehicle", previewVehicle)

	if fuelType == "petrol" then
		fuelType = "Benzin"
	elseif fuelType == "diesel" then
		fuelType = "Dízel"
	else
		fuelType = "Elektromos"
	end

	if driveType == "fwd" then
		driveType = "Elsőkerék"
	elseif driveType == "rwd" then
		driveType = "Hátsókerék"
	else
		driveType = "Összkerék"
	end

	fuelType = "#3d7abc" .. fuelType
	driveType = "#3d7abc" .. driveType
	tankCapacity = "#3d7abc" .. tankCapacity .. " l"
	bootCapacity = "#3d7abc" .. bootCapacity .. " kg"

	triggerServerEvent("countCarsByModel", localPlayer, veh.model)

	driverPed = createPed(0, 2628.609375, 2309.5710449219, 10.671875)
	setElementCollisionsEnabled(driverPed, false)
	warpPedIntoVehicle(driverPed, previewVehicle, 0)
	setElementAlpha(driverPed, 0)
	setElementDimension(driverPed, playerId)
	
	occupantPed = createPed(0, 2628.609375, 2309.5710449219, 10.6718751)
	setElementCollisionsEnabled(occupantPed, false)
	warpPedIntoVehicle(occupantPed, previewVehicle, 1)
	setElementAlpha(occupantPed, 0)
	setElementDimension(occupantPed, playerId)

	cinematicCamera = true
	freeLookCamera = false
	firstPersonCamera = false

	cameraInterpolation = getTickCount()
	cameraStage = 1

	fadeCamera(true, 1)
	setElementDimension(localPlayer, playerId)
	setElementPosition(localPlayer, 1686.8603515625, 1833.818359375, 14.814833641052)
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
		if firstPersonCamera then
			local boneX, boneY, boneZ = getPedBonePosition(firstPersonCamera, 8)

			if getKeyState("d") then
				if freeLook.faceR > -90 then
					freeLook.faceR = freeLook.faceR - 0.75
				end
			elseif getKeyState("a") then
				if freeLook.faceR < 90 then
					freeLook.faceR = freeLook.faceR + 0.75
				end
			end

			if getKeyState("w") then
				if freeLook.faceZ <= 0.5 then
					freeLook.faceZ = freeLook.faceZ + 0.01
				end
			elseif getKeyState("s") then
				if freeLook.faceZ >= -1 then
					freeLook.faceZ = freeLook.faceZ - 0.01
				end
			end

			local rotatedX, rotatedY = rotateAround(freeLook.faceR, 0, 1)

			setCameraMatrix(boneX, boneY, boneZ, boneX + rotatedX, boneY + rotatedY, boneZ + freeLook.faceZ)

			dxDrawText("A #d75959visszalépéshez #ffffffnyomd meg az #3d7abc[E] #ffffffgombot.", 0, screenY - respc(120), screenX, 0, tocolor(255, 255, 255), 1, RobotoFont, "center", "top", false, false, true, true, true)
		else
			-- Navigáció segédlet
			local fontHeight = dxGetFontHeight(1, RobotoFont) * 1.5

			local w1 = dxGetTextWidth("Cinematic kamera", 1, RobotoFont) + fontHeight
			local w2 = dxGetTextWidth("Kamera mozgatás", 1, RobotoFont) + fontHeight * 4
			local w3 = dxGetTextWidth("Interakció", 1, RobotoFont) + fontHeight

			local lineWidth = w1 + w2 + w3 + respc(10) * 4
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

			linePosX = linePosX + w2 + respc(10)

			dxDrawImage(linePosX + respc(5), linePosY + (lineHeight - fontHeight) / 2, fontHeight, fontHeight, "files/images/keys/e.png")
			dxDrawText("Interakció", linePosX + fontHeight + respc(10), linePosY, 0, linePosY + lineHeight, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

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

			local rotatedX, rotatedY = rotateAround(90 + freeLook.r, 5 / freeLook.zoom, 5 / freeLook.zoom)

			setCameraMatrix(vehX + rotatedX, vehY + rotatedY, vehZ + freeLook.z, vehX, vehY, vehZ)

			-- Interakció
			for i = 1, #components do
				local componentName = components[i]
				local componentX, componentY, componentZ = getVehicleComponentPosition(previewVehicle, componentName, "world")

				if componentX then
					local onScreenX, onScreenY = getScreenFromWorldPosition(componentX, componentY, componentZ + 0.15)

					if onScreenX and onScreenY then
						if onScreenX >= screenX / 2 - resp(23) and onScreenY >= screenY / 2 - resp(23) and onScreenX <= screenX / 2 - resp(23) + 48 and onScreenY <= screenY / 2 - resp(23) + 48 then
							dxDrawImage(onScreenX - resp(128) / 2, onScreenY - resp(128) / 2, resp(128), resp(128), "files/images/hover.png")
						else
							dxDrawImage(onScreenX - resp(128) / 2, onScreenY - resp(128) / 2, resp(128), resp(128), "files/images/circle.png")
						end
					end

					if componentName == "door_lf_dummy" or componentName == "door_rf_dummy" then
						local openratio = 0

						if componentName == "door_lf_dummy" then
							openratio = getVehicleDoorOpenRatio(previewVehicle, 2)
						else
							openratio = getVehicleDoorOpenRatio(previewVehicle, 3)
						end

						local onScreenX, onScreenY = getScreenFromWorldPosition(componentX, componentY - 0.5, componentZ + 0.15)

						if onScreenX and onScreenY and openratio == 1 then
							if onScreenX >= screenX / 2 - resp(23) and onScreenY >= screenY / 2 - resp(23) and onScreenX <= screenX / 2 - resp(23) + 48 and onScreenY <= screenY / 2 - resp(23) + 48 then
								dxDrawImage(onScreenX - resp(128) / 2, onScreenY - resp(128) / 2, resp(128), resp(128), "files/images/hover.png")
							else
								dxDrawImage(onScreenX - resp(128) / 2, onScreenY - resp(128) / 2, resp(128), resp(128), "files/images/circle.png")
							end
						end
					end
				end
			end

			dxDrawImage(screenX / 2 - resp(128) / 2, screenY / 2 - resp(128) / 2, resp(128), resp(128), "files/images/arc.png")
		end

		return
	end

	dxDrawText("<", respc(125), screenY - respc(300), screenX - respc(125), screenY, tocolor(255, 255, 255), 1, mesmerizeFont, "left", "center")
	dxDrawText(">", respc(125), screenY - respc(300), screenX - respc(125), screenY, tocolor(255, 255, 255), 1, mesmerizeFont, "right", "center")

	dxDrawText(vehicleName, 0 + 1, screenY - respc(300) + 1, screenX + 1, screenY + 1, tocolor(0, 0, 0), 1, mesmerizeFont, "center", "center")
	dxDrawText(vehicleName, 0, screenY - respc(300), screenX, screenY, tocolor(255, 255, 255), 1, mesmerizeFont, "center", "center")

	-- Fejléc
	local mesmerizeHeight = dxGetFontHeight(1, mesmerizeFont) * 1.75

	dxDrawRectangle(0, 0, screenX, respc(150), tocolor(0, 0, 0, 200))
	dxDrawText("AUTÓSZALON", respc(50) + mesmerizeHeight, 0, screenX, respc(150), tocolor(255, 255, 255), 1, mesmerizeFont, "left", "center")
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

	--dxDrawText("#d8d8d8Active Dashboard: " .. _UPVALUE14_ .. "\n" .. "#d8d8d8Paintjob: " .. _UPVALUE15_ .. "\n" .. "#d8d8d8Egyedi lámpa: " .. _UPVALUE16_ .. "\n" .. "#d8d8d8SuperCharger: " .. _UPVALUE17_, screenX - respc(150) * 2.5 - respc(25), 0, screenX - respc(25), respc(150), tocolor(255, 255, 255), 1, RobotoFont, "left", "center", false, false, false, true)
	dxDrawText("#d8d8d8Üzemanyag típus: " .. fuelType .. "\n" .. "#d8d8d8Tank méret: " .. tankCapacity .. "\n" .. "#d8d8d8Meghajtás: " .. driveType .. "\n" .. "#d8d8d8Csomagtartó méret: " .. bootCapacity, screenX - respc(150) * 2.5 - respc(25), 0, screenX - respc(25), respc(150), tocolor(255, 255, 255), 1, RobotoFont, "left", "center", false, false, false, true)

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

			local rotatedX, rotatedY = rotateAround(90 + rot, 5, 5)

			setCameraMatrix(vehX + rotatedX, vehY + rotatedY, vehZ + 0.55, vehX, vehY, vehZ)
		elseif cameraStage == 2 then
			local componentX, componentY, componentZ = getVehicleComponentPosition(previewVehicle, "boot_dummy", "world")
			
			if not componentX then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
				return
			end
			
			if elapsedTime >= 6500 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 7500 and cinematicCamera then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
			end
			
			local pos = interpolateBetween(
				1.5, 0, 0,
				-2, 0, 0,
				elapsedTime / 7500, "Linear")
			
			setCameraMatrix(componentX, componentY + pos + 4, componentZ + 1.25, componentX, -componentY + pos + 4, 0)
		elseif cameraStage == 3 then
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
			
			setCameraMatrix(vehX, vehY + pos, vehZ + 4, vehX, vehY + pos, vehZ, 90)
		elseif cameraStage == 4 then
			if elapsedTime >= 9000 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 10000 and cinematicCamera then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
			end
			
			local rot, pos = interpolateBetween(
				0, 0, 0,
				20, 1.2, 0,
				elapsedTime / 10000, "Linear")

			local rotatedX, rotatedY = rotateAround(90 + rot, -5 + pos, -5 + pos)
			
			setCameraMatrix(vehX + rotatedX, vehY + rotatedY, vehZ + 0.55, vehX, vehY, vehZ)
		elseif cameraStage == 5 then
			if elapsedTime >= 9000 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 10000 and cinematicCamera then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
			end
			
			local pos = interpolateBetween(
				-3, 0, 0,
				1, 0, 0,
				elapsedTime / 10000, "Linear")
			
			setCameraMatrix(vehX + 2.5, vehY + 2.5 + pos, vehZ + 0.55, -vehX + 2.5, -vehY + 2.5, vehZ)
		elseif cameraStage == 6 then
			local componentX, componentY, componentZ
			
			if getVehicleComponentPosition(previewVehicle, "bump_front_dummy", "world") then
				componentX, componentY, componentZ = getVehicleComponentPosition(previewVehicle, "bump_front_dummy", "world")
			elseif getVehicleComponentPosition(previewVehicle, "bump_front_ok", "world") then
				componentX, componentY, componentZ = getVehicleComponentPosition(previewVehicle, "bump_front_ok", "world")
			end
			
			if not (componentX and componentY and componentZ) then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
				return
			end
			
			if elapsedTime >= 6500 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 7500 and cinematicCamera then
				cameraStage = cameraStage + 1
				cameraInterpolation = now
			end
			
			local rot = interpolateBetween(
				0, 0, 0,
				20, 0, 0,
				elapsedTime / 7500, "Linear")

			local rotatedX, rotatedY = rotateAround(90 + rot, 2, 1)

			setCameraMatrix(componentX + rotatedX, componentY + rotatedY, componentZ + 0.55, componentX, componentY, componentZ)
		elseif cameraStage == 7 then
			local componentX, componentY, componentZ = getVehicleComponentPosition(previewVehicle, "bump_rear_dummy", "world")
			
			if not (componentX and componentY and componentZ) then
				cameraStage = 1
				cameraInterpolation = now
				return
			end
			
			if elapsedTime >= 6500 and cinematicCamera then
				fadeCamera(false, 1)
				setTimer(fadeCamera, 1000, 1, true, 1)
			end
			
			if elapsedTime >= 7500 and cinematicCamera then
				cameraStage = 1
				cameraInterpolation = now
			end
			
			local rot = interpolateBetween(
				0, 0, 0,
				20, 0, 0,
				elapsedTime / 7500, "Linear")

			local rotatedX, rotatedY = rotateAround(90 + rot, -2, -1)

			setCameraMatrix(componentX + rotatedX, componentY + rotatedY, componentZ + 0.55, componentX, componentY, componentZ)
		end
	end
end

addEvent("exitShop", true)
addEventHandler("exitShop", getRootElement(),
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
							triggerServerEvent("{€>Ä&Ä}&ä", localPlayer, availableVehicles[selectedVehicle], "money", selectedColor[1], selectedColor[2], selectedColor[3])
						end
					elseif activeButton == "buyCarPremium" then
						if selectedVehicle then
							triggerServerEvent("{€>Ä&Ä}&ä", localPlayer, availableVehicles[selectedVehicle], "pp", selectedColor[1], selectedColor[2], selectedColor[3])
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

		if key == "e" then
			if press then
				if freeLookCamera and not promptActive then
					if getTickCount() - lastInteraction >= 1000 then
						if not firstPersonCamera then
							for i = 1, #components do
								local componentName = components[i]
								local componentX, componentY, componentZ = getVehicleComponentPosition(previewVehicle, componentName, "world")

								if componentX then
									local onScreenX, onScreenY = getScreenFromWorldPosition(componentX, componentY, componentZ + 0.15)

									if onScreenX and onScreenY then
										if onScreenX >= screenX / 2 - 24 and onScreenY >= screenY / 2 - 24 and onScreenX <= screenX / 2 - 24 + 48 and onScreenY <= screenY / 2 - 24 + 48 then
											if getVehicleDoorOpenRatio(previewVehicle, i - 1) > 0 then
												setVehicleDoorOpenRatio(previewVehicle, i - 1, 0, 250)
												setTimer(playSound, 250, 1, exports.see_vehiclepanel:getDoorCloseSound(getElementModel(previewVehicle)))
											else
												setVehicleDoorOpenRatio(previewVehicle, i - 1, 1, 500)
												playSound(exports.see_vehiclepanel:getDoorOpenSound(getElementModel(previewVehicle)))
											end
										end
									end

									if componentName == "door_lf_dummy" or componentName == "door_rf_dummy" then
										local openratio = 0

										if componentName == "door_lf_dummy" then
											openratio = getVehicleDoorOpenRatio(previewVehicle, 2)
										else
											openratio = getVehicleDoorOpenRatio(previewVehicle, 3)
										end

										local onScreenX, onScreenY = getScreenFromWorldPosition(componentX, componentY - 0.5, componentZ + 0.15)

										if onScreenX and onScreenY and openratio == 1 then
											if onScreenX >= screenX / 2 - 24 and onScreenY >= screenY / 2 - 24 and onScreenX <= screenX / 2 - 24 + 48 and onScreenY <= screenY / 2 - 24 + 48 then
												lastInteraction = getTickCount()

												fadeCamera(false, 1)
												setTimer(fadeCamera, 1000, 1, true, 1)
												setTimer(playSound, 750, 1, "files/sounds/sitin.mp3")

												setTimer(
													function ()
														if componentName == "door_lf_dummy" then
															firstPersonCamera = driverPed
														else
															firstPersonCamera = occupantPed
														end
													end,
												1000, 1)
											end
										end
									end
								end
							end
						else
							lastInteraction = getTickCount()

							fadeCamera(false, 1)
							setTimer(fadeCamera, 1000, 1, true, 1)
							setTimer(playSound, 750, 1, "files/sounds/sitin.mp3")

							setTimer(
								function ()
									firstPersonCamera = false
								end,
							1000, 1)
						end
					end
				end
			end
		end

		if key == "q" then
			if press then
				if not promptActive then
					if firstPersonCamera then
						exports.see_accounts:showInfo("e", "Előbb lépj ki a belsőnézetből! (E)")
						return
					end

					freeLookCamera = not freeLookCamera

					if freeLookCamera then
						fadeCamera(true, 0)
					else
						cameraInterpolation = getTickCount()
						cameraStage = 1
					end

					for i = 0, 5 do
						setVehicleDoorOpenRatio(previewVehicle, i, 0, 0)
					end

					freeLook.zoomInterpolation = getTickCount()
					freeLook.zoom = 1

					playSound("files/sounds/cammove.mp3")
				end
			end
		end

		if key == "l" then
			if press then
				if not promptActive then
					if getVehicleOverrideLights(previewVehicle) == 2 then
						setVehicleOverrideLights(previewVehicle, 1)
						playSound(":see_vehiclepanel/files/headlightoff.mp3")
					else
						setVehicleOverrideLights(previewVehicle, 2)
						playSound(":see_vehiclepanel/files/headlighton.mp3")
					end
				end
			end
		end

		if key == "arrow_r" or key == "arrow_l" then
			if press then
				if not freeLookCamera and not promptActive and getTickCount() - lastNavigate >= 200 then
					if key == "arrow_r" then
						selectedVehicle = selectedVehicle + 1
						
						if selectedVehicle > #availableVehicles then
							selectedVehicle = 1
						end
					else
						selectedVehicle = selectedVehicle - 1
						
						if selectedVehicle < 1 then
							selectedVehicle = #availableVehicles
						end
					end
					
					fadeCamera(false, 1)
					setTimer(fadeCamera, 100, 1, true, 1)

					setTimer(
						function()
							cameraInterpolation = getTickCount()
							cameraStage = 1

							local veh = availableVehicles[selectedVehicle]
							local color = availableColors[math.random(1, #availableColors)]

							setElementModel(previewVehicle, veh.model)
							setElementPosition(previewVehicle, 2628.609375, 2309.5710449219, 10.671875)
							setElementRotation(previewVehicle, 0, 0, 0)

							setVehicleColor(previewVehicle, color[1], color[2], color[3])
							selectedColor = {unpack(color)}

							exports.see_tuning:applyHandling(previewVehicle)

							vehicleName = exports.see_vehiclenames:getCustomVehicleName(veh.model)
							vehicleManufacturer = utf8.lower(exports.see_vehiclenames:getCustomVehicleManufacturer(veh.model)):gsub(" ", "-")
							
							vehiclePrice = veh.price
							vehiclePremium = veh.premium
							vehicleLimit = veh.limit

							fuelType = getVehicleHandling(previewVehicle)["engineType"]
							driveType = getVehicleHandling(previewVehicle)["driveType"]
							tankCapacity = exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(veh.model)
							bootCapacity = exports.see_items:getWeightLimit("vehicle", previewVehicle)

							if fuelType == "petrol" then
								fuelType = "Benzin"
							elseif fuelType == "diesel" then
								fuelType = "Dízel"
							else
								fuelType = "Elektromos"
							end

							if driveType == "fwd" then
								driveType = "Elsőkerék"
							elseif driveType == "rwd" then
								driveType = "Hátsókerék"
							else
								driveType = "Összkerék"
							end

							fuelType = "#3d7abc" .. fuelType
							driveType = "#3d7abc" .. driveType
							tankCapacity = "#3d7abc" .. tankCapacity .. " liter"
							bootCapacity = "#3d7abc" .. bootCapacity .. " kg"

							triggerServerEvent("countCarsByModel", localPlayer, veh.model)
						end,
					100, 1)
					
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