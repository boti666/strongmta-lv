local screenSizeX, screenSizeY = guiGetScreenSize()

local previews = {}
local renderTarget = false

local getLastTick = getTickCount()
local lastCamVelocity = {0, 0, 0}
local currentCamPos = {0, 0, 0}
local lastCamPos = {0, 0, 0}

function setDistanceSpread(element, zSpread)
	if not isElement(element) then
		return false
	end

	for k = 1, #previews do
		local v = previews[k]

		if v and v.element == element then
			v.zDistanceSpread = zSpread
			break
		end
	end

	return true
end

function setPositionOffsets(element, offsX, offsY, offsZ)
	if not isElement(element) then
		return false
	end

	for k = 1, #previews do
		local v = previews[k]

		if v and v.element == element then
			v.elementPositionOffsets = {offsX, offsY, offsZ}
			break
		end
	end

	return true
end

function setRotationOffsets(element, offsX, offsY, offsZ)
	if not isElement(element) then
		return false
	end

	for k = 1, #previews do
		local v = previews[k]

		if v and v.element == element then
			v.elementRotationOffsets = {offsX, offsY, offsZ}
			break
		end
	end

	return true
end

function setRotation(element, rotX, rotY, rotZ)
	if not isElement(element) then
		return false
	end

	for k = 1, #previews do
		local v = previews[k]

		if v and v.element == element then
			v.elementRotation = {rotX, rotY, rotZ}
			break
		end
	end

	return true
end

function setProjection(element, projPosX, projPosY, projSizeX, projSizeY)
	if not isElement(element) then
		return false
	end

	projPosX, projSizeX = projPosX / screenSizeX, projSizeX / screenSizeX
	projPosY, projSizeY = projPosY / screenSizeY, projSizeY / screenSizeY

	for k = 1, #previews do
		local v = previews[k]

		if v and v.element == element then
			v.projection = {projPosX, projPosY, projSizeX, projSizeY}
			break
		end
	end

	return true
end

function capturePreview(element, fileName)
	if fileName then
		if isElement(element) then
			if isElement(renderTarget) then
				local details = false

				for k = 1, #previews do
					local v = previews[k]

					if v and v.element == element then
						details = v
						break
					end
				end

				if details then
					if fileExists(fileName) then
						fileDelete(fileName)
					end

					local imageFile = fileCreate(fileName)

					if imageFile then
						local projPosX, projPosY, projSizeX, projSizeY = unpack(details.projection)
						local projPosX, projSizeX = projPosX * screenSizeX, projSizeX * screenSizeX
						local projPosY, projSizeY = projPosY * screenSizeY, projSizeY * screenSizeY

						local texturePixels = dxGetTexturePixels(renderTarget, projPosX, projPosY, projSizeX, projSizeY)
						texturePixels = dxConvertPixels(texturePixels, "png")

						fileWrite(imageFile, texturePixels)
						fileFlush(imageFile)
						fileClose(imageFile)

						return true
					end
				end
			end
		end
	end

	return false
end

function drawPreview(element, alpha, projPosX, projPosY, projSizeX, projSizeY)
	if isElement(element) then
		if isElement(renderTarget) then
			for k = 1, #previews do
				local v = previews[k]

				if v and v.element == element then
					if not alpha then
						alpha = getElementAlpha(element)

						if alpha < 0 then
							alpha = 0
						elseif alpha > 255 then
							alpha = 255
						end
					end

					if not projPosX then
						local projPosX, projPosY, projSizeX, projSizeY = unpack(v.projection)
						local projPosX, projSizeX = projPosX * screenSizeX, projSizeX * screenSizeX
						local projPosY, projSizeY = projPosY * screenSizeY, projSizeY * screenSizeY

						return dxDrawImageSection(projPosX, projPosY, projSizeX, projSizeY, projPosX, projPosY, projSizeX, projSizeY, renderTarget, 0, 0, 0, tocolor(255, 255, 255, alpha))
					else
						return dxDrawImageSection(projPosX, projPosY, projSizeX, projSizeY, projPosX, projPosY, projSizeX, projSizeY, renderTarget, 0, 0, 0, tocolor(255, 255, 255, alpha))
					end
				end
			end
		end
	end

	return false
end

function makePreview(element, projPosX, projPosY, projSizeX, projSizeY)
	if not isElement(element) then
		return false
	end

	local posX, posY, posZ = getCameraMatrix()

	projPosX, projSizeX = projPosX / screenSizeX, projSizeX / screenSizeX
	projPosY, projSizeY = projPosY / screenSizeY, projSizeY / screenSizeY

	local elementType = getElementType(element)

	if elementType == "ped" or elementType == "player" then
		elementType = "ped"
	end

	if elementType ~= "ped" and elementType ~= "vehicle" and elementType ~= "object" then
		outputDebugString("makePreview @ elementType - only ped, vehicle and object is allowed.", 1)
		return false
	end

	setElementAlpha(element, 254)
	setElementStreamable(element, false)
	setElementFrozen(element, true)
	setElementCollisionsEnabled(element, false)

	local preview = {}
	preview.element = element
	preview.elementType = elementType
	preview.elementRadius = math.max(returnMaxValue({getElementBoundingBox(preview.element)}), 1)
	preview.elementPosition = {posX, posY, posZ}
	preview.elementRotation = {0, 0, 0}
	preview.elementPositionOffsets = {0, 0, 0}
	preview.elementRotationOffsets = {0, 0, 0}
	preview.zDistanceSpread = 0
	preview.projection = {projPosX, projPosY, projSizeX, projSizeY}
	preview.shader = dxCreateShader(elementType .. ".fx", 0, 0, false, "all")

	if elementType == "vehicle" then
		preview.zDistanceSpread = -3.9

		for i = 0, 5 do
			setVehicleDoorState(preview.element, i, 0)
		end
	elseif elementType == "ped" then
		preview.zDistanceSpread = -1.0
	else
		preview.zDistanceSpread = 3.0
	end

	local tempRadius = getElementRadius(preview.element)

	if tempRadius > preview.elementRadius then
		preview.elementRadius = tempRadius
	end

	if not renderTarget then
		renderTarget = dxCreateRenderTarget(screenSizeX, screenSizeY, true)
	end

	local cameraFOV = ({getCameraMatrix()})[8]

	dxSetShaderValue(preview.shader, "secondRT", renderTarget)
	dxSetShaderValue(preview.shader, "sFov", math.rad(cameraFOV))
	dxSetShaderValue(preview.shader, "sAspect", screenSizeY / screenSizeX)
	dxSetShaderValue(preview.shader, "sProjZMult", 2)
	engineApplyShaderToWorldTexture(preview.shader, "*", preview.element)

	table.insert(previews, preview)

	if not preRender then
		addEventHandler("onClientPreRender", root, onPreRender, true, "low-5")
		preRender = true
	end

	return true
end

function setPreviewFOV(element, FOV)
	if isElement(element) then
		if isElement(renderTarget) then
			local details = false

			for k = 1, #previews do
				local v = previews[k]

				if v and v.element == element then
					dxSetShaderValue(v.shader, "sFov", math.rad(FOV))
					return true
				end
			end
		end
	end

	return false
end

function destroyPreview(element)
	if not isElement(element) then
		return false
	end

	local temp = {}

	for k = 1, #previews do
		local v = previews[k]

		if v then
			if v.element ~= element then
				table.insert(temp, v)
			else
				if isElement(v.shader) then
					destroyElement(v.shader)
				end

				v.shader = nil

				setElementPosition(v.element, 0, 0, 0)
			end
		end
	end

	previews = temp

	if #temp > 0 then
		if not preRender then
			addEventHandler("onClientPreRender", root, onPreRender, true, "low-5")
			preRender = true
		end
	else
		if preRender then
			removeEventHandler("onClientPreRender", root, onPreRender)
			preRender = false
		end

		if isElement(renderTarget) then
			destroyElement(renderTarget)
		end
		renderTarget = nil
	end
end

function onPreRender()
	if #previews == 0 then
		preRender = false

		removeEventHandler("onClientPreRender", root, onPreRender)

		if isElement(renderTarget) then
			destroyElement(renderTarget)
		end

		renderTarget = nil

		return
	end

	if isElement(renderTarget) then
		dxSetRenderTarget(renderTarget, true)
		dxSetRenderTarget()
	end

	local cameraMatrix = getElementMatrix(getCamera())
	local velX, velY, velZ = getCamVelocity()
	local vecLen = math.sqrt(velX * velX + velY * velY + velZ * velZ)
	local cameraCom = {cameraMatrix[2][1] * vecLen, cameraMatrix[2][2] * vecLen, cameraMatrix[2][3] * vecLen}

	velX = velX + cameraCom[1]
	velY = velY + cameraCom[2]
	velZ = velZ + cameraCom[3]

	for k = 1, #previews do
		local v = previews[k]

		if v and isElement(v.element) and v.shader then
			local projPosX, projPosY, projSizeX, projSizeY = unpack(v.projection)

			projSizeX = projSizeX / 2
			projSizeY = projSizeY / 2

			projPosX = projPosX + projSizeX - 0.5
			projPosY = -(projPosY + projSizeY - 0.5)

			projPosX = projPosX * 2
			projPosY = projPosY * 2

			local positionMatrix = createElementMatrix(v.elementRotationOffsets, {0, 0, 0})
			local rotationMatrix = createElementMatrix({0, 0, 0}, v.elementRotation)
			local transformMatrix = matrixMultiply(positionMatrix, rotationMatrix)
			local multipliedMatrix = matrixMultiply(transformMatrix, cameraMatrix)

			local posX, posY, posZ = getPositionFromMatrixOffset(cameraMatrix, v.elementPositionOffsets[1], 1.5 * v.elementRadius + v.zDistanceSpread + v.elementPositionOffsets[2], v.elementPositionOffsets[3])
			local rotX, rotY, rotZ = getEulerAnglesFromMatrix(multipliedMatrix)

			setElementPosition(v.element, posX + velX, posY + velY, posZ + velZ, false)
			setElementRotation(v.element, rotX, rotY, rotZ, "ZXY")

			dxSetShaderValue(v.shader, "sCameraPosition", cameraMatrix[4])

		end
	end
end

function matrixMultiply(mat1, mat2)
	local matrixOut = {}

	for i = 1, #mat1 do
		matrixOut[i] = {}

		for j = 1, #mat2[1] do
			local num = mat1[i][1] * mat2[1][j]

			for n = 2, #mat1[1] do
				num = num + mat1[i][n] * mat2[n][j]
			end

			matrixOut[i][j] = num
		end
	end

	return matrixOut
end

function createElementMatrix(pos, rot)
	local rx, ry, rz = math.rad(rot[1]), math.rad(rot[2]), math.rad(rot[3])
	return {
		{math.cos(rz) * math.cos(ry) - math.sin(rz) * math.sin(rx) * math.sin(ry), math.cos(ry) * math.sin(rz) + math.cos(rz) * math.sin(rx) * math.sin(ry), -math.cos(rx) * math.sin(ry), 0},
		{-math.cos(rx) * math.sin(rz), math.cos(rz) * math.cos(rx), math.sin(rx), 0},
		{math.cos(rz) * math.sin(ry) + math.cos(ry) * math.sin(rz) * math.sin(rx), math.sin(rz) * math.sin(ry) - math.cos(rz) * math.cos(ry) * math.sin(rx), math.cos(rx) * math.cos(ry), 0},
		{pos[1], pos[2], pos[3], 1}
	}
end

function getEulerAnglesFromMatrix(mat)
	local nz1, nz2, nz3

	nz3 = math.sqrt(mat[2][1] * mat[2][1] + mat[2][2] * mat[2][2])
	nz1 = -mat[2][1] * mat[2][3] / nz3
	nz2 = -mat[2][2] * mat[2][3] / nz3

	local vx = nz1 * mat[1][1] + nz2 * mat[1][2] + nz3 * mat[1][3]
	local vz = nz1 * mat[3][1] + nz2 * mat[3][2] + nz3 * mat[3][3]

	return math.deg(math.asin(mat[2][3])), -math.deg(math.atan2(vx, vz)), -math.deg(math.atan2(mat[2][1], mat[2][2]))
end

function getPositionFromMatrixOffset(matrix, x, y, z)
	return x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1],
		x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2],
		x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
end

function getCamVelocity()
	if getTickCount() - getLastTick < 100 then
		return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3]
	end

	local currentCamPos = {getElementPosition(getCamera())}
	lastCamVelocity = {currentCamPos[1] - lastCamPos[1], currentCamPos[2] - lastCamPos[2], currentCamPos[3] - lastCamPos[3]}
	lastCamPos = {currentCamPos[1], currentCamPos[2], currentCamPos[3]}

	return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3]
end

function returnMaxValue(inTable)
	local itemCount = #inTable
	local outTable = {}

	for i,v in pairs(inTable) do
		outTable[i] = math.abs(v)
	end

	local hasChanged

	repeat
		hasChanged = false
		itemCount = itemCount - 1

		for i = 1, itemCount do
			if outTable[i] > outTable[i + 1] then
				outTable[i], outTable[i + 1] = outTable[i + 1], outTable[i]
				hasChanged = true
			end
		end
	until hasChanged == false

	return outTable[#outTable]
end
