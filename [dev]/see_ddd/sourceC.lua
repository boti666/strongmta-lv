local screenWidth, screenHeight = guiGetScreenSize()

function getValidVehicleModels ( )
	local validVehicles = { }
	local invalidModels = {
		[435]=true, [449]=true, [450]=true, [537]=true,
		[538]=true, [569]=true, [570]=true, [584]=true,
		[590]=true, [591]=true, [606]=true, [607]=true, 
		[608]=true
	}
	for i=400, 609 do
		if ( not invalidModels[i] ) then
			table.insert ( validVehicles, i )
		end
	end
	return validVehicles
end

local availableModels = getValidVehicleModels ( )

local commandName = "objphoto"
local photoMode = false

local photoSizeX = 900
local photoSizeY = 600

local photoPosX = screenWidth / 2 - photoSizeX / 2
local photoPosY = screenHeight / 2 - photoSizeY / 2

local previewElement = false
local renderTarget = false
local fontElement = false

local currentModelId = 1

local removeBackground = true
local backgroundColor = {255, 255, 255}

local captureThread = false
local threadTimer = false
local threadInterval = 1000

local lastPosition = false
local lastInterior = 0
local lastDimension = 0

local basePosition = {1000, 1000, 1000}
local baseOffsetZ = 0

local cameraPosition = false
local cameraRotation = 180
local cameraHeight = 20
local cameraZoom = 15
local cameraMoveSpeed = 2
local cameraRotateSpeed = 3

function orbitCamera()
	local yaw = math.rad(cameraRotation)
	local pitch = math.rad(cameraHeight)

	cameraPosition[4] = math.cos(yaw) * math.cos(pitch)
	cameraPosition[5] = math.sin(yaw) * math.cos(pitch)
	cameraPosition[6] = math.sin(pitch)

	cameraPosition[4] = cameraPosition[1] + cameraPosition[4] * cameraZoom
	cameraPosition[5] = cameraPosition[2] + cameraPosition[5] * cameraZoom
	cameraPosition[6] = cameraPosition[3] + cameraPosition[6] * cameraZoom
end

addCommandHandler(commandName,
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") < 9 then
			return
		end

		photoMode = not photoMode

		if photoMode then
			lastPosition = {getElementPosition(localPlayer)}
			lastInterior = getElementInterior(localPlayer)
			lastDimension = getElementDimension(localPlayer)
			cameraPosition = {1000, 1000, 1000}

			orbitCamera()
			setCloudsEnabled(false)
			setRainLevel(0)
			setHeatHaze(0)
			setElementInterior(localPlayer, 1)
			setElementDimension(localPlayer, 65535)

			currentModelId = 1
			cameraRotation = 180
			cameraHeight = 20
			cameraZoom = 15
			baseOffsetZ = 0

			renderTarget = dxCreateScreenSource(screenWidth, screenHeight)
			previewElement = createVehicle(availableModels[1], basePosition[1], basePosition[2], basePosition[3], 0)
			fontElement = dxCreateFont(":see_hud/files/fonts/Roboto.ttf", 14, false, "antialiased")

			setElementFrozen(previewElement, true)
			setElementCollisionsEnabled(previewElement, false)
			setElementStreamable(previewElement, false)
			setElementDoubleSided(previewElement, true)
			setElementInterior(previewElement, 1)
			setElementDimension(previewElement, 65535)

			addEventHandler("onClientRender", getRootElement(), onRender)
			addEventHandler("onClientPreRender", getRootElement(), onPreRender)
			addEventHandler("onClientKey", getRootElement(), onKeyHandler)
		else
			if isTimer(threadTimer) then
				killTimer(threadTimer)
			end

			threadTimer = nil
			captureThread = nil

			removeEventHandler("onClientRender", getRootElement(), onRender)
			removeEventHandler("onClientPreRender", getRootElement(), onPreRender)
			removeEventHandler("onClientKey", getRootElement(), onKeyHandler)

			destroyElement(previewElement)
			destroyElement(renderTarget)
			destroyElement(fontElement)

			setCameraTarget(localPlayer)
			setElementInterior(localPlayer, lastInterior)
			setElementDimension(localPlayer, lastDimension)
			setElementPosition(localPlayer, unpack(lastPosition))

			resetSunColor()
			resetSkyGradient()
			triggerServerEvent("requestWeather", localPlayer)
		end
	end
)

function onKeyHandler(key, press)
	if press and not guiGetInputEnabled() then
		if key == "enter" then
			cancelEvent()

			if not captureThread then
				threadProcess(threadInterval, 1)
			end
		elseif key == "backspace" then
			executeCommandHandler(commandName)
		elseif key == "arrow_r" then
			if currentModelId < #availableModels then
				currentModelId = currentModelId + 1
				setElementModel(previewElement, availableModels[currentModelId])
			end
		elseif key == "arrow_l" then
			if currentModelId > 1 then
				currentModelId = currentModelId - 1
				setElementModel(previewElement, availableModels[currentModelId])
			end
		elseif key == "mouse_wheel_down" then

			if getKeyState("mouse1") then
				cameraZoom = cameraZoom + 2
			elseif getKeyState("mouse2") then
				cameraZoom = cameraZoom + 0.5
			else
				cameraZoom = cameraZoom + 1
			end

			if cameraZoom > 75 then
				cameraZoom = 75
			end

			orbitCamera()
		elseif key == "mouse_wheel_up" then
			if getKeyState("mouse1") then
				cameraZoom = cameraZoom - 2
			elseif getKeyState("mouse2") then
				cameraZoom = cameraZoom - 0.5
			else
				cameraZoom = cameraZoom - 1
			end

			if cameraZoom < 1 then
				cameraZoom = 1
			end

			orbitCamera()
		end
	end
end

function onPreRender(deltaTime)
	if isElement(previewElement) then
		local deltaX = false
		local deltaY = false

		if getKeyState("w") then
			deltaX = 0 - deltaTime / 1000
		elseif getKeyState("s") then
			deltaX = 0 + deltaTime / 1000
		end

		if getKeyState("a") then
			deltaY = 0 - deltaTime / 1000
		elseif getKeyState("d") then
			deltaY = 0 + deltaTime / 1000
		end

		local movementSpeed = cameraMoveSpeed
		local rotationSpeed = cameraRotateSpeed

		if getKeyState("mouse1") then
			movementSpeed = cameraMoveSpeed * 3
			rotationSpeed = cameraRotateSpeed * 3
		elseif getKeyState("mouse2") then
			movementSpeed = cameraMoveSpeed / 3
			rotationSpeed = cameraRotateSpeed / 3
		end

		if deltaX or deltaY then
			deltaX = deltaX or 0
			deltaY = deltaY or 0

			if getKeyState("lshift") then
				cameraRotation = cameraRotation + deltaY * cameraZoom * rotationSpeed
				cameraHeight = cameraHeight + deltaX * -cameraZoom * rotationSpeed

				if cameraHeight >= 89.9 then
					cameraHeight = 89.9
				elseif cameraHeight <= 0 then
					cameraHeight = 0
				end
			else
				local rotationTheta = math.rad(cameraRotation)

				cameraPosition[1] = cameraPosition[1] + deltaX * movementSpeed * math.cos(rotationTheta) - deltaY * movementSpeed * math.sin(rotationTheta)
				cameraPosition[2] = cameraPosition[2] + deltaX * movementSpeed * math.sin(rotationTheta) + deltaY * movementSpeed * math.cos(rotationTheta)
			end

			orbitCamera()
		end

		if getKeyState("arrow_u") then
			baseOffsetZ = baseOffsetZ + movementSpeed * deltaTime / 1000
			setElementPosition(previewElement, basePosition[1], basePosition[2], basePosition[3] + baseOffsetZ)
		elseif getKeyState("arrow_d") then
			baseOffsetZ = baseOffsetZ - movementSpeed * deltaTime / 1000
			setElementPosition(previewElement, basePosition[1], basePosition[2], basePosition[3] + baseOffsetZ)
		end
	end
end

function onRender()
	if isElement(previewElement) then
		if cameraPosition then
			setCameraMatrix(cameraPosition[4], cameraPosition[5], cameraPosition[6], cameraPosition[1], cameraPosition[2], cameraPosition[3])
		end

		setTime(12, 0)
		setWeather(0)

		setSkyGradient(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[1], backgroundColor[2], backgroundColor[3])
		setSunColor(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[1], backgroundColor[2], backgroundColor[3])

		dxDrawRectangle(0, 0, photoPosX, screenHeight, tocolor(0, 0, 0, 200)) -- left
		dxDrawRectangle(photoPosX + photoSizeX, 0, screenWidth - photoPosX, screenHeight, tocolor(0, 0, 0, 200)) -- right

		dxDrawRectangle(photoPosX, 0, photoSizeX, photoPosY, tocolor(0, 0, 0, 200)) -- top
		dxDrawRectangle(photoPosX, photoPosY + photoSizeY, photoSizeX, screenHeight - photoPosY, tocolor(0, 0, 0, 200)) -- bottom

		if not captureThread then
			dxDrawText("A fotózás megkezdéséhez nyomd le az ENTER-t.", 0, screenHeight - 80, screenWidth, 200, tocolor(124, 197, 118), 1, fontElement, "center", "top")
		else
			dxDrawText("Fotózás folyamatban...", 0, screenHeight - 80, screenWidth, 200, tocolor(215, 89, 89), 1, fontElement, "center", "top")
		end
	end
end

function threadProcess(timeInterval, retryAmount)
	captureThread = coroutine.create(captureTheScreen)

	coroutine.resume(captureThread)

	threadTimer = setTimer(
		function()
			local status = coroutine.status(captureThread)

			if status == "suspended" then
				for i = 1, retryAmount do
					coroutine.resume(captureThread)
				end
			elseif status == "dead" then
				killTimer(threadTimer)
				captureThread = nil
				exports.see_accounts:showInfo("s", "A kép generálása befejeződött.")
			end
		end,
	timeInterval, 0)
end

function captureTheScreen()
	dxUpdateScreenSource(renderTarget)

	local modelId = availableModels[currentModelId]
	local texturPixels = dxGetTexturePixels(renderTarget, photoPosX, photoPosY, photoSizeX, photoSizeY)

	if removeBackground then
		for x = 0, photoSizeX do
			for y = 0, photoSizeY do
				local r, g, b = dxGetPixelColor(texturPixels, x, y)

				if r and g and b and r == 255 and g == 255 and b == 255 then
					dxSetPixelColor(texturPixels, x, y, 0, 0, 0, 0)
				end
			end
		end
	end

	if fileExists("renders/" .. modelId .. ".png") then
		fileDelete("renders/" .. modelId .. ".png")
	end

	local imageFile = fileCreate("renders/" .. modelId .. ".png")

	if imageFile then
		fileWrite(imageFile, dxConvertPixels(texturPixels, "png"))
		fileFlush(imageFile)
		fileClose(imageFile)
	end

	coroutine.yield()
end
