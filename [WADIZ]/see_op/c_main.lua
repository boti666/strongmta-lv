-- 
-- c_main.lua
--

objectPreview = {}
objectPreview_mt = { __index = objectPreview }

local isMRTShaderSupported = nil
local glRenderTarget = nil
local colorFilter = {66 / 255, 66 / 255, 48 / 255, 255 / 255, 166 / 255, 129 / 255, 60 / 255, 255 / 255}

refOPTable = {}

local scx, scy = guiGetScreenSize ()
local fov = ({getCameraMatrix()})[8]

function objectPreview:create(element,rotX,rotY,rotZ,projPosX,projPosY,projSizeX,projSizeY,isRelative,postGui,isSRT,isAtt)
	local posX,posY,posZ = getCameraMatrix()
	if isRelative == false then
		projPosX, projPosY, projSizeX, projSizeY = projPosX / scx, projPosY / scy, projSizeX / scx, projSizeY / scy
	end
	local elementType = getElementType(element)
	outputDebugString('objPrev: Identified element as: '..tostring(elementType))
	if elementType =="ped" or elementType =="player" then 
		elementType = "ped"
	end

    local new = {
		element = element,
		elementType = elementType,
		alpha = 255,
		elementRadius = 0,
		elementPosition = {posX, posY, posZ},
		elementRotation = {rotX, rotY, rotZ},
		elementRotationOffsets = {0, 0, 0},
		elementPositionOffsets = {0, 0, 0},
		zDistanceSpread = 0,
		projection = {projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative},
		shader = {},
		isSecondRT = isSRT,
		isUpdate = false,
		attached = isAtt,
		visible = true,
		renID = findEmptyEntry(refOPTable) 
	}

	setElementAlpha(new.element, 254)
	setElementStreamable(new.element, false)
	setElementFrozen(new.element, true)
	setElementCollisionsEnabled (new.element, false)
	
	if elementType =="vehicle" then
		new.zDistanceSpread = -3.9
		for i=0,5 do
			setVehicleDoorState ( new.element, i, 0 )
		end
	elseif elementType =="ped" then
		new.zDistanceSpread = -1.0
	else
		new.zDistanceSpread = 3.0		
	end
	
	new.elementRadius = math.max(returnMaxValue({getElementBoundingBox(new.element)}), 1)	

	local tempRadius = getElementRadius(new.element)
	if tempRadius > new.elementRadius then new.elementRadius = tempRadius end

	if new.isSecondRT then
		if not isMRTShaderSupported then
			outputDebugString('objPrev: Can not create a preview. MRT in shaders not supported')
			return false
		end
		outputDebugString('objPrev: Creating fx_pre_'..elementType..'.fx')
		new.shader[1] = dxCreateShader("fx/fx_pre_"..elementType..".fx", 0, 0, false, "all")
		if not glRenderTarget then
			glRenderTarget = dxCreateRenderTarget( scx, scy, true )
		end
	else
		outputDebugString('objPrev: Creating fx_pre_'..elementType..'_noMRT.fx')
		new.shader[1] = dxCreateShader("fx/fx_pre_"..elementType.."_noMRT.fx", 0, 0, false, "all")	
	end
	if not new.shader[1] then 
		return false 
	end

	if isMRTShaderSupported and glRenderTarget and new.isSecondRT then
		dxSetShaderValue (new.shader[1], "secondRT", glRenderTarget)
	end
	
	dxSetShaderValue(new.shader[1], "sColorFilter1", 0, 0, 0, 0)
	dxSetShaderValue(new.shader[1], "sColorFilter2", 0, 0, 0, 0)
	dxSetShaderValue(new.shader[1], "sAlphaMult", 0)
	dxSetShaderValue(new.shader[1], "sFov", math.rad(fov))
	dxSetShaderValue(new.shader[1], "sAspect", (scy / scx))
	engineApplyShaderToWorldTexture (new.shader[1], "*", new.element)
	
	refOPTable[new.renID] = {}
	refOPTable[new.renID].enabled = true
	refOPTable[new.renID].isSecondRT = isSRT
	refOPTable[new.renID].instance = new

	new.onPreRender = function()
		new:update()
	end
	addEventHandler( "onClientPreRender", root, new.onPreRender, true, "low-5" )
    setmetatable(new, objectPreview_mt)
	outputDebugString('objPrev: Created ID: '..new.renID..' for: '..tostring(elementType)) 
	return new
end

function objectPreview:getID()
	return self.renID
end

function objectPreview:setAlpha(alphaValue)
	self.alpha = alphaValue
	self.isUpdate = false
	return setElementAlpha(self.element, self.alpha) 
end

function objectPreview:destroy()
	if self.onPreRender then
		removeEventHandler( "onClientPreRender", root, self.onPreRender)
		self.onPreRender = nil
	end
	self.onPreRender = nil
	local renID = self.renID
	refOPTable[renID].enabled = false
	refOPTable[renID].isSecondRT = false
	refOPTable[renID].instance = nil
	if self.shader then
		for i, v in ipairs(self.shader) do
			engineRemoveShaderFromWorldTexture(v, "*", self.element)
			destroyElement(v)
			v = nil
		end
		self.shader = nil
	end
	outputDebugString('objPrev: Destroyed ID: '..renID) 
	self.element = nil
end

function objectPreview:createTextureReplace(texElement, texName)
	local elementNr = nil
	if self.isSecondRT then
		if not isMRTShaderSupported then
			outputDebugString('objPrev: Can not create a preview. MRT in shaders not supported')
			return false
		end
		outputDebugString('objPrev: Creating fx_pre_'..self.elementType..'_replace.fx')
		elementNr = #self.shader + 1
		self.shader[elementNr] = dxCreateShader("fx/fx_pre_"..self.elementType.."_replace.fx", 0, 0, false, "all")
		if not glRenderTarget then
			glRenderTarget = dxCreateRenderTarget( scx, scy, true )
		end
	else
		outputDebugString('objPrev: Creating fx_pre_'..self.elementType..'_replace_noMRT.fx')
		self.shader[elementNr] = dxCreateShader("fx/fx_pre_"..self.elementType.."_replace_noMRT.fx", 0, 0, false, "all")	
	end
	if not self.shader[elementNr] then 
		return false 
	end
	if isMRTShaderSupported and glRenderTarget and self.isSecondRT then
		dxSetShaderValue (self.shader[elementNr], "secondRT", glRenderTarget)
	end
	
	dxSetShaderValue(self.shader[elementNr], "sColorFilter1", 0, 0, 0, 0)
	dxSetShaderValue(self.shader[elementNr], "sColorFilter2", 0, 0, 0, 0)
	dxSetShaderValue(self.shader[elementNr], "sAlphaMult", 0)
	dxSetShaderValue(self.shader[elementNr], "sFov", math.rad(fov))
	dxSetShaderValue(self.shader[elementNr], "sAspect", (scy / scx))
	dxSetShaderValue(self.shader[elementNr], "sTexture0", texElement)	

	engineApplyShaderToWorldTexture (self.shader[elementNr], texName, self.element)	
	return elementNr
end

function objectPreview:destroyTextureReplace(elementNr)
	local renID = self.renID
	if not refOPTable[renID].enabled then return false end 
	if self.shader then
		if self.shader[elementNr] then
			engineRemoveShaderFromWorldTexture(self.shader[elementNr], "*", self.element)
			destroyElement(self.shader[elementNr])
			self.shader[elementNr] = nil
			outputDebugString('objPrev: Removed texture replace for ID: '..renID)
			return true
		end
	end
	return false
end

function objectPreview:setTextureReplaceTexture(elementNr, textureElement)
	local renID = self.renID
	if not refOPTable[renID].enabled then return false end 
	if self.shader then
		if self.shader[elementNr] then
			dxSetShaderValue(self.shader[elementNr], "sTexture0", texElement)
			return true
		end
	end
	return false
end

function objectPreview:update()
	-- Check if element exists
    if not isElement(self.element) then 
		return false
	end
	-- Calculate position and size of the projector	
	local projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative = unpack(self.projection)
	projSizeX, projSizeY = projSizeX / 2, projSizeY / 2
	projPosX, projPosY = projPosX + projSizeX - 0.5, -(projPosY + projSizeY - 0.5)
	projPosX, projPosY = 2 * projPosX, 2 * projPosY
	
	-- Calculate position and rotation of the element		
	local cameraMatrix = getElementMatrix(getCamera())
	local rotationMatrix = createElementMatrix({0,0,0}, self.elementRotation)
	local positionMatrix = createElementMatrix(self.elementRotationOffsets, {0,0,0})
	local transformMatrix = matrixMultiply(positionMatrix, rotationMatrix)
		
	local multipliedMatrix = matrixMultiply(transformMatrix, cameraMatrix)
	local distTemp = self.zDistanceSpread

	local posTemp = self.elementPositionOffsets
	local posX, posY, posZ = getPositionFromMatrixOffset(cameraMatrix, {posTemp[1], 1.6 * self.elementRadius + distTemp + posTemp[2], posTemp[3]})
	local rotX, rotY, rotZ = getEulerAnglesFromMatrix(multipliedMatrix)

	local velX, velY, velZ = getCamVelocity()
	local vecLen = math.sqrt(math.pow(velX, 2) + math.pow(velY, 2) + math.pow(velZ, 2))
	local camCom = {cameraMatrix[2][1] * vecLen, cameraMatrix[2][2] * vecLen, cameraMatrix[2][3] * vecLen}
	velX, velY, velZ =	(velX + camCom[1]), (velY + camCom[2]), (velZ + camCom[3])
	if not self.attached then
		setElementPosition(self.element, posX + velX, posY + velY, posZ + velZ, false)				
		setElementRotation(self.element, rotX, rotY, rotZ, "ZXY")
	end
	
	-- Set shader values
	if self.shader then
		for i, v in ipairs(self.shader) do
			if isElement(v) then
				if self.visible then
					dxSetShaderValue(v, "sAlphaMult", 1)		
				else
					dxSetShaderValue(v, "sAlphaMult", 0)		
				end
				dxSetShaderValue(v, "sCameraPosition", cameraMatrix[4])
				dxSetShaderValue(v, "sCameraForward", cameraMatrix[2])
				dxSetShaderValue(v, "sCameraUp", cameraMatrix[3])
				dxSetShaderValue(v, "sElementOffset", 0, -distTemp, 0)
				dxSetShaderValue(v, "sWorldOffset", -velX, -velY, -velZ)
				dxSetShaderValue(v, "sMoveObject2D", projPosX, projPosY)
				dxSetShaderValue(v, "sScaleObject2D", 2 * math.min(projSizeX, projSizeY), 2 * math.min(projSizeX, projSizeY))
				dxSetShaderValue(v, "sRealScale2D", 2 * projSizeX, 2 * projSizeY)
				dxSetShaderValue(v, "sProjZMult", 2)
				dxSetShaderValue(v, "sColorFilter1", colorFilter[1],colorFilter[2],colorFilter[3],colorFilter[4])
				dxSetShaderValue(v, "sColorFilter2", colorFilter[5],colorFilter[6],colorFilter[7],colorFilter[8])
			end
		end
		self.isUpdate = true
	end
end

local getLastTick = getTickCount() local lastCamVelocity  = {0, 0, 0}
local currentCamPos = {0, 0, 0} local lastCamPos = {0, 0, 0}

function getCamVelocity()
	if getTickCount() - getLastTick  < 100 then 
		return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3] 
	end
	local currentCamPos = {getElementPosition(getCamera())}
	lastCamVelocity = {currentCamPos[1] - lastCamPos[1], currentCamPos[2] - lastCamPos[2], currentCamPos[3] - lastCamPos[3]}
	lastCamPos = {currentCamPos[1], currentCamPos[2], currentCamPos[3]}
	return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3]
end


function objectPreview:saveToFile(filePath)
	if not isMRTShaderSupported or not self.isSecondRT or not isElement(self.element) then
			outputDebugString('objPrev : saveRTToFile fail (non MRT object or MRT not supported) !')
		return false 
	end
	if glRenderTarget then
		local projPosX, projPosY, projSizeX, projSizeY, postGui, isRelaftive = unpack(self.projection)
		projPosX, projPosY, projSizeX, projSizeY = toint(projPosX * scx), toint(projPosY * scy), toint(projSizeX * scx), toint(projSizeY * scy)
		local rtPixels = dxGetTexturePixels ( glRenderTarget, projPosX, projPosY, projSizeX, projSizeY)
		if not rtPixels then
			outputDebugString('objPrev : saveRTToFile fail (could not get texture pixels) !')
			return false 
		end
		rtPixels = dxConvertPixels(rtPixels, 'png')
		isValid = rtPixels and true
		local file = fileCreate(filePath)
		isValid = fileWrite(file, rtPixels) and isValid
		isValid = fileClose(file) and isValid
		if not isValid then
			outputDebugString('objPrev : saveRTToFile fail (could not save pixels to file) !')
			return false
		end
		outputDebugString('objPrev : saveRTToFile to: '..filePath)
		return isValid
	else
		outputDebugString('objPrev : saveRTToFile fail (render target error) !')
		return false	
	end
	return false
end

function objectPreview:drawRenderTarget()
	if not isMRTShaderSupported or not self.isSecondRT then return false end
	if glRenderTarget and self.visible and not self.attached then
		local projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative = unpack(self.projection)
		projPosX, projPosY, projSizeX, projSizeY = projPosX * scx, projPosY * scy, projSizeX * scx, projSizeY * scy
		return dxDrawImageSection(projPosX, projPosY, projSizeX, projSizeY, projPosX, projPosY, projSizeX, projSizeY, glRenderTarget, 
			0, 0, 0, tocolor(255, 255, 255, 255), postGui )
	end
	return false
end

function objectPreview:setProjection(projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative)
	if self.projection then
		if isRelative == false then
			projPosX, projPosY, projSizeX, projSizeY = projPosX / scx, projPosY / scy, projSizeX / scx, projSizeY / scy
		end
		self.isUpdate = false
		self.projection = {projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative}
	end
end

function objectPreview:setPostGui(postGui)
	if not self.isSecondRT then return false end
	if self.projection then
		self.isUpdate = false
		self.projection[5] = postGui
	end
end

function objectPreview:setRotation(rotX, rotY, rotZ)
	if self.elementRotation then
		self.isUpdate = false
		self.elementRotation = {rotX, rotY, rotZ}
	end
end

function objectPreview:setRotationOffsets(offsX, offsY, offsZ)
	if self.elementRotationOffsets then
		self.isUpdate = false
		self.elementRotationOffsets = {offsX, offsY, offsZ}
	end
end

function objectPreview:setDistanceSpread(zSpread)
	if self.zDistanceSpread then
		self.isUpdate = false
		self.zDistanceSpread = zSpread
	end
end

function objectPreview:setPositionOffsets(offsX, offsY, offsZ)
	if self.elementPositionOffsets then
		self.isUpdate = false
		self.elementPositionOffsets = {offsX, offsY, offsZ}
	end
end

function objectPreview:setVisible(isVis)
	self.isUpdate = false
	self.visible = isVis
	return true
end

function objectPreview:setAttached(isAtt)
	self.isUpdate = false
	self.attached = isAtt
	return true
end

function objectPreview:isVisible()
	return self.visible
end

function getRTarget()
	if not isMRTShaderSupported then return false end
	if glRenderTarget then
		return glRenderTarget
	else
		outputDebugString('objPrev : getRenderTarget fail (no render target) !')
		return false
	end
end	

function setCFilter(inputVal)
	if not isMRTShaderSupported then return false end
		colorFilter = {inputVal[1] / 255,inputVal[2] / 255,inputVal[3] / 255,inputVal[4] / 255,
			inputVal[5] / 255,inputVal[6] / 255,inputVal[7] / 255,inputVal[8] / 255}
end

-- onClientPreRender
addEventHandler( "onClientPreRender", root, function()
	if not isMRTShaderSupported or (#refOPTable == 0) then 
		return 
	end
	if glRenderTarget then
		dxSetRenderTarget( glRenderTarget, true )
		dxSetRenderTarget()
	end
end, true, "low-5" )

-- onClientHUDRender
addEventHandler( "onClientHUDRender", root, function()
	isMRTUsed = false
	if not isMRTShaderSupported or (#refOPTable == 0) then 
		return 
	end
	for index, this in ipairs( refOPTable ) do
		-- Draw secondary render target
		if refOPTable[index] then
			if refOPTable[index].isSecondRT then
					isMRTUsed = true
				end
			if refOPTable[index].enabled then
				local instance = this.instance
				if instance then
					instance:drawRenderTarget()
				end
			end
		end
    end
	if (isMRTUsed == false) and glRenderTarget then
		destroyElement( glRenderTarget )
		glRenderTarget = nil
		outputDebugString('objPrev : no MRT objects visible - destroyed RT')
	end
end, true, "low-10" )

-- OnClientResourceStart
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	if not isMTAUpToDate("07331") then 
		outputChatBox('Object preview: Update your MTA 1.5 client. Download at nightly.mtasa.com',255,0,0) 
		return 
	end
	isMRTShaderSupported = vCardNumRenderTargets() > 1
	if not isMRTShaderSupported then 
		outputChatBox('Object preview: Multiple RT in shader not supported',255,0,0) 
		return 
	end
end)
