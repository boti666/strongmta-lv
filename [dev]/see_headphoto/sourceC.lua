local screenWidth, screenHeight = guiGetScreenSize()

local commandName = "headphoto"
local photoMode = false

local photoSizeX = 128
local photoSizeY = 128

local photoPosX = screenWidth / 2 - photoSizeX / 2
local photoPosY = screenHeight / 2 - photoSizeY / 2

local previewElement = false
local renderTarget = false
local shaderElement = false
local fontElement = false

local currentModelId = 1
local simpleCapture = false

local removeBackground = true
local backgroundColor = {255, 255, 255}

local captureThread = false
local threadTimer = false
local threadInterval = 1000

local lastPosition = false
local lastInterior = 0
local lastDimension = 0

local availableModels = getValidPedModels()

function isValidModel(modelId)
	for i = 1, #availableModels do
		if availableModels[i] == modelId then
			return true
		end
	end
	return false
end

function rotateAround(angle, offsetX, offsetY, baseX, baseY)
	angle = math.rad(angle)

	offsetX = offsetX or 0
	offsetY = offsetY or 0

	baseX = baseX or 0
	baseY = baseY or 0

	return baseX + offsetX * math.cos(angle) - offsetY * math.sin(angle),
			 baseY + offsetX * math.sin(angle) + offsetY * math.cos(angle)
end

local basePosition = {1045.3537597656, 1014.3500976563, 1000}
local cameraPosition = {}
do
	cameraPosition[1], cameraPosition[2] = rotateAround(0, 3, 0, basePosition[1], basePosition[2])
	cameraPosition[3] = basePosition[3] + 0.5
	cameraPosition[4], cameraPosition[5], cameraPosition[6] = basePosition[1], basePosition[2], basePosition[3] + 0.5
end

addCommandHandler(commandName,
	function (commandName, modelId)
		if getElementData(localPlayer, "acc.adminLevel") < 9 then
			return
		end

		photoMode = not photoMode

		if photoMode then
			modelId = tonumber(modelId)

			if modelId then
				if not isValidModel(modelId) then
					exports.see_accounts:showInfo("e", "A kiválasztott model ID érvénytelen!")
					return
				end
			end

			lastPosition = {getElementPosition(localPlayer)}
			lastInterior = getElementInterior(localPlayer)
			lastDimension = getElementDimension(localPlayer)

			setCloudsEnabled(false)
			setRainLevel(0)
			setHeatHaze(0)
			setElementInterior(localPlayer, 1)
			setElementDimension(localPlayer, 65535)

			simpleCapture = modelId
			currentModelId = 1

			renderTarget = dxCreateScreenSource(screenWidth, screenHeight)
			previewElement = createPed(modelId and modelId or availableModels[1], basePosition[1], basePosition[2], basePosition[3], 0)
			shaderElement = dxCreateShader("shader.hlsl", 0, 0, false, "all")
			fontElement = dxCreateFont(":see_hud/files/fonts/Roboto.ttf", 14, false, "antialiased")

			setElementCollisionsEnabled(previewElement, false)
			setElementStreamable(previewElement, false)
			setElementInterior(previewElement, 1)
			setElementDimension(previewElement, 65535)
			engineApplyShaderToWorldTexture(shaderElement, "*", previewElement)

			addEventHandler("onClientRender", getRootElement(), onRender)
			addEventHandler("onClientKey", getRootElement(), onKeyHandler)
		else
			if isTimer(threadTimer) then
				killTimer(threadTimer)
			end

			threadTimer = nil
			captureThread = nil

			removeEventHandler("onClientRender", getRootElement(), onRender)
			removeEventHandler("onClientKey", getRootElement(), onKeyHandler)

			destroyElement(previewElement)
			destroyElement(renderTarget)
			destroyElement(shaderElement)
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
		end
	end
end

function onRender()
	if isElement(previewElement) then
		setElementPosition(previewElement, basePosition[1], basePosition[2], basePosition[3])
		setElementRotation(previewElement, 0, 0, 90)

		setTime(6, 0)
		setWeather(0)

		setSkyGradient(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[1], backgroundColor[2], backgroundColor[3])
		setSunColor(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[1], backgroundColor[2], backgroundColor[3])

		setCameraMatrix(unpack(cameraPosition))

		local leftX, leftY, leftZ = getPedBonePosition(previewElement, 7)
		local rightX, rightY, rightZ = getPedBonePosition(previewElement, 6)

		if leftZ and rightZ then
			local minX, maxX = math.min(leftX, rightX), math.max(leftX, rightX)
			local minY, maxY = math.min(leftY, rightY), math.max(leftY, rightY)
			local minZ, maxZ = math.min(leftZ, rightZ), math.max(leftZ, rightZ)

			local faceX = minX + (maxX - minX) / 2
			local faceY = minY + (maxY - minY) / 2
			local faceZ = minZ + (maxZ - minZ) / 2

			local screenX, screenY = getScreenFromWorldPosition(faceX, faceY, faceZ)

			if screenX and screenY then
				screenX = screenX - photoSizeX / 2
				screenY = screenY - photoSizeY / 2

				dxDrawRectangle(0, 0, screenX, screenHeight, tocolor(0, 0, 0, 200)) -- left
				dxDrawRectangle(screenX + photoSizeX, 0, screenWidth - screenX, screenHeight, tocolor(0, 0, 0, 200)) -- right

				dxDrawRectangle(screenX, 0, photoSizeX, screenY, tocolor(0, 0, 0, 200)) -- top
				dxDrawRectangle(screenX, screenY + photoSizeY, photoSizeX, screenHeight - screenY, tocolor(0, 0, 0, 200)) -- bottom

				photoPosX = screenX
				photoPosY = screenY
			end
		end

		if not captureThread then
			dxDrawText("A fotózás megkezdéséhez nyomd le az ENTER-t.", 0, screenHeight - 100, screenWidth, 0, tocolor(61, 122, 188), 1, fontElement, "center", "top")
		else
			local remainingTimeText = ""

			if not simpleCapture then
				local seconds = math.floor((#availableModels - currentModelId) * threadInterval / 1000)

				if seconds < 0 then
					seconds = 0
				end

				remainingTimeText = " (kb. " .. string.format("%d perc és %d másodperc", seconds / 60 % 60, seconds % 60) .. ")"
			end

			dxDrawText("Fotózás folyamatban..." .. remainingTimeText, 0, screenHeight - 100, screenWidth, 0, tocolor(215, 89, 89), 1, fontElement, "center", "top")
		end
	end
end

function threadProcess(timeInterval, retryAmount)
	captureThread = coroutine.create(launchScreenCapture)

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
				exports.see_accounts:showInfo("s", "A képek generálása befejeződött.")
			end
		end,
	timeInterval, 0)
end

function launchScreenCapture()
	--print("launchScreenCapture")
	if simpleCapture then
		--print("simpleCapture")
		captureTheScreen(simpleCapture)
	else
		for i = 1, #availableModels + 1 do
			if availableModels[i] then
				--print(#availableModels + 1)
				setElementModel(previewElement, availableModels[i])
			end

			if availableModels[i - 1] then
				captureTheScreen(availableModels[i - 1])
				--print("screened - 1")
			else
				--print("screened i")
				captureTheScreen(availableModels[i])
			end

			currentModelId = currentModelId + 1
			--print(currentModelId + 1)
		end
	end
end

function captureTheScreen()
	dxUpdateScreenSource(renderTarget)

	local modelId = currentModelId
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

	if fileExists(":see_headphoto/renders/" .. modelId .. ".png") then
		--fileDelete("renders/" .. modelId .. ".png")
	end

	local imageFile = fileCreate(currentModelId)
	fileCreate("asd.txt")

	--if imageFile then
		fileWrite(imageFile, "racks")
		fileFlush(imageFile)
		fileClose(imageFile)
	--end

	coroutine.yield()
end