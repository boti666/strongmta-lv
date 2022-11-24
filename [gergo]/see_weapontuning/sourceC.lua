local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local availablePaintjobs = {
	[30] = {
		[1] = dxCreateTexture("files/ak/camo.png", "dxt1"),
		[2] = dxCreateTexture("files/ak/camo2.png", "dxt1"),
		[3] = dxCreateTexture("files/ak/camo3.png", "dxt1"),
		[4] = dxCreateTexture("files/ak/gold.png", "dxt1"),
		[5] = dxCreateTexture("files/ak/gold2.png", "dxt1"),
		[6] = dxCreateTexture("files/ak/silver.png", "dxt1"),
		[7] = dxCreateTexture("files/ak/kitty.png", "dxt1"),
		[8] = dxCreateTexture("files/ak/summerak.png", "dxt1"),
		[9] = dxCreateTexture("files/ak/fadeak.png", "dxt1"),

	},
	[34] = {
		[1] = dxCreateTexture("files/sniper/camo.png", "dxt1"),
		[2] = dxCreateTexture("files/sniper/camo2.png", "dxt1"),
	},
	[23] = {
		[1] = dxCreateTexture("files/silenced/camo.png", "dxt1"),
		[2] = dxCreateTexture("files/silenced/neon.png", "dxt1"),

	},
	[24] = {
		[1] = dxCreateTexture("files/deagle/camo.png", "dxt1"),
		[2] = dxCreateTexture("files/deagle/gold.png", "dxt1"),
	},
	[29] = {
		[1] = dxCreateTexture("files/p90/1.png", "dxt1"),
		[2] = dxCreateTexture("files/p90/2.png", "dxt1"),
		[3] = dxCreateTexture("files/p90/3.png", "dxt1"),
		[4] = dxCreateTexture("files/p90/4.png", "dxt1"),
		[5] = dxCreateTexture("files/p90/5.png", "dxt1"),
		[6] = dxCreateTexture("files/p90/6.png", "dxt1"),
		[7] = dxCreateTexture("files/p90/7.png", "dxt1"),
		[8] = dxCreateTexture("files/p90/8.png", "dxt1"),
		[9] = dxCreateTexture("files/p90/9.png", "dxt1"),
	},
	[4] = {
		[1] = dxCreateTexture("files/knife/knife1.png", "dxt1"),
		[2] = dxCreateTexture("files/knife/knife2.png", "dxt1"),
		[3] = dxCreateTexture("files/knife/knife3.png", "dxt1"),
		[4] = dxCreateTexture("files/knife/summerknife.png", "dxt1"),
	},
	[28] = {
		[1] = dxCreateTexture("files/uzi/uzi1.png", "dxt1"),
		[2] = dxCreateTexture("files/uzi/uzi2.png", "dxt1"),
		[3] = dxCreateTexture("files/uzi/uzi3.png", "dxt1"),
		[4] = dxCreateTexture("files/uzi/uzi4.png", "dxt1"),
	},
	[25] = {
		[1] = dxCreateTexture("files/shotgun/1.png", "dxt1"),
		[2] = dxCreateTexture("files/shotgun/2.png", "dxt1"),
		[3] = dxCreateTexture("files/shotgun/3.png", "dxt1"),
		[4] = dxCreateTexture("files/shotgun/4.png", "dxt1"),
	},
}

local weaponTextureNames = {
	[30] = "ak",
	[34] = "tekstura",
	[23] = "1911",
	[24] = "deagle",
	[29] = "p90TEX",
	[4] = "kabar",
	[28] = "9MM_C",
	[25] = "m870t",
}

local playerWeaponShaders = {}
local sideWeaponObjects = {}
local sideWeaponShaders = {}

local previewWidth = respc(700)
local previewHeight = respc(500)

local previewPosX = screenX / 2 - previewWidth / 2
local previewPosY = screenY / 2 - previewHeight / 2

local previewName = false
local previewTarget = false
local previewScreen = false
local previewScreenSize = respc(1000)
local previewZoomSection = respc(250)
local previewZoom = 1

local previewInteriorObject = false
local previewWeaponObject = false
local previewWeaponShader = false

local myLastInterior = false
local myLastFrozenState = false

local Roboto = false
local isRotatingWeapon = false

function previewWeapon(itemId)
	Roboto = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")

	previewZoom = 1
	previewName = exports.see_items:getItemName(itemId)
	previewTarget = dxCreateScreenSource(screenX, screenY)
	previewScreen = dxCreateScreenSource(previewScreenSize, previewScreenSize)

	dxUpdateScreenSource(previewTarget)

	myLastInterior = getElementInterior(localPlayer)
	myLastFrozenState = isElementFrozen(localPlayer)

	local pedX, pedY, pedZ = getElementPosition(localPlayer)
	local pedDimension = getElementDimension(localPlayer)

	setElementInterior(localPlayer, 255)
	setCameraMatrix(pedX + 1, pedY + 0.93, pedZ + 10 + 0.45, pedX - 1, pedY - 0.93, pedZ + 10 - 0.45, 0, 70)

	previewInteriorObject = createObject(18088, pedX - 1, pedY - 0.93, pedZ + 10 - 0.45)
	previewWeaponObject = createObject(itemWeaponModel[itemId], pedX - 1, pedY - 0.93, pedZ + 10 - 0.45)
	previewWeaponShader = dxCreateShader("files/texturechanger.fx", 0, 0, false, "object")

	local weaponId = itemWeaponId[itemId]
	local paintjobId = exports.see_items:getWeaponSkin(itemId)

	dxSetShaderValue(previewWeaponShader, "gTexture", availablePaintjobs[weaponId][paintjobId])
	engineApplyShaderToWorldTexture(previewWeaponShader, weaponTextureNames[weaponId], previewWeaponObject)

	setElementCollisionsEnabled(previewInteriorObject, false)
	setElementCollisionsEnabled(previewWeaponObject, false)

	setElementInterior(previewInteriorObject, 255)
	setElementInterior(previewWeaponObject, 255)

	setElementDimension(previewInteriorObject, pedDimension)
	setElementDimension(previewWeaponObject, pedDimension)

	isRotatingWeapon = false
	showCursor(true)
	setElementFrozen(localPlayer, true)

	addEventHandler("onClientHUDRender", getRootElement(), renderPreviewBCG, true, "high+99999")
	addEventHandler("onClientRender", getRootElement(), renderPreview, true, "low")
	addEventHandler("onClientRestore", getRootElement(), restoreThePreview)
	addEventHandler("onClientKey", getRootElement(), previewKey)
end

function restoreThePreview()
	setCameraTarget(localPlayer)

	removeEventHandler("onClientHUDRender", getRootElement(), renderPreviewBCG)
	removeEventHandler("onClientRender", getRootElement(), renderPreview)
	removeEventHandler("onClientRestore", getRootElement(), restoreThePreview)
	removeEventHandler("onClientKey", getRootElement(), previewKey)

	if isElement(previewScreen) then
		destroyElement(previewScreen)
	end

	if isElement(previewTarget) then
		destroyElement(previewTarget)
	end

	if isElement(previewInteriorObject) then
		destroyElement(previewInteriorObject)
	end

	if isElement(previewWeaponObject) then
		destroyElement(previewWeaponObject)
	end

	if isElement(previewWeaponShader) then
		destroyElement(previewWeaponShader)
	end

	if isElement(Roboto) then
		destroyElement(Roboto)
	end

	previewScreen = nil
	previewTarget = nil
	previewInteriorObject = nil
	previewWeaponObject = nil
	previewWeaponShader = nil
	Roboto = nil

	showCursor(false)
	setCursorAlpha(255)

	setElementInterior(localPlayer, myLastInterior)
	setElementFrozen(localPlayer, myLastFrozenState)
end

function previewKey(key, press)
	if key == "escape" or key == "backspace" then
		cancelEvent()

		if not press then
			restoreThePreview()
		end
	end

	if press then
		if key == "mouse_wheel_down" then
			if previewZoom > 1 then
				previewZoom = previewZoom - 0.1
			end
		elseif key == "mouse_wheel_up" then
			if previewZoom < 1.75 then
				previewZoom = previewZoom + 0.1
			end
		end
	end
end

function renderPreviewBCG()
	dxDrawImage(0, 0, screenX, screenY, previewTarget)
end

function renderPreview()
	dxUpdateScreenSource(previewScreen)

	dxDrawText(previewName, previewPosX + 1, previewPosY - respc(40) + 1, previewPosX + previewWidth + 1, previewPosY + 1, tocolor(0, 0, 0), 1, Roboto, "center", "center")
	dxDrawText(previewName, previewPosX, previewPosY - respc(40), previewPosX + previewWidth, previewPosY, tocolor(255, 255, 255), 1, Roboto, "center", "center")

	dxDrawRectangle(previewPosX - 5, previewPosY - 5, previewWidth + 10, previewHeight + 10, tocolor(0, 0, 0, 150))
	dxDrawImageSection(previewPosX, previewPosY, previewWidth, previewHeight, previewZoomSection * (previewZoom - 1), previewZoomSection * (previewZoom - 1), previewScreenSize - previewZoomSection * (previewZoom - 1) * 2, previewScreenSize - previewZoomSection * (previewZoom - 1) * 2, previewScreen)

	dxDrawText("Forgatás: egér | Kilépés: ESC / Backspace | Nagyítás: görgő", previewPosX + 1, previewPosY + previewHeight + 1, previewPosX + previewWidth + 1, previewPosY + previewHeight + respc(40) + 1, tocolor(0, 0, 0), 0.75, Roboto, "center", "center")
	dxDrawText("Forgatás: egér | Kilépés: ESC / Backspace | Nagyítás: görgő", previewPosX, previewPosY + previewHeight, previewPosX + previewWidth, previewPosY + previewHeight + respc(40), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")

	local cursorX, cursorY = getCursorPosition()

	if cursorX then
		if isRotatingWeapon then
			local rotX, rotY, rotZ = getElementRotation(previewWeaponObject)

			setElementRotation(previewWeaponObject, rotX, rotY, (rotZ - (0.5 - cursorX) * 75) % 360)
			setCursorPosition(screenX / 2, screenY / 2)

			if not getKeyState("mouse1") then
				isRotatingWeapon = false
				setCursorAlpha(255)
			end
		else
			cursorX = cursorX * screenX
			cursorY = cursorY * screenY

			if cursorX >= previewPosX and cursorX <= previewPosX + previewWidth and cursorY >= previewPosY and cursorY <= previewPosY + previewHeight then
				if getKeyState("mouse1") then
					isRotatingWeapon = true
					setCursorAlpha(0)
					setCursorPosition(screenX / 2, screenY / 2)
				end
			end
		end
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("player")) do
			if getElementData(v, "loggedIn") then
				local currentWeaponPaintjob = getElementData(v, "currentWeaponPaintjob")

				if currentWeaponPaintjob then
					local paintjobId = currentWeaponPaintjob[1]
					local weaponId = currentWeaponPaintjob[2]

					if paintjobId then
						if paintjobId > 0 then
							playerWeaponShaders[v] = dxCreateShader("files/texturechanger.fx", 0, 0, false, "ped")

							if isElement(playerWeaponShaders[v]) then
								dxSetShaderValue(playerWeaponShaders[v], "gTexture", availablePaintjobs[weaponId][paintjobId])
								engineApplyShaderToWorldTexture(playerWeaponShaders[v], weaponTextureNames[weaponId], v)
							end
						end
					end
				end

				if getElementData(v, "playerSideWeapons") then
					if isElementStreamedIn(v) then
						processSideWeapons(v)
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "currentWeaponPaintjob" then
			local newValue = getElementData(source, "currentWeaponPaintjob")

			if isElement(playerWeaponShaders[source]) then
				destroyElement(playerWeaponShaders[source])
			end

			if newValue then
				local paintjobId = newValue[1]
				local weaponId = newValue[2]

				if paintjobId then
					if paintjobId > 0 then
						playerWeaponShaders[source] = dxCreateShader("files/texturechanger.fx", 0, 0, false, "ped")

						if isElement(playerWeaponShaders[source]) then
							dxSetShaderValue(playerWeaponShaders[source], "gTexture", availablePaintjobs[weaponId][paintjobId])
							engineApplyShaderToWorldTexture(playerWeaponShaders[source], weaponTextureNames[weaponId], source)
						end
					end
				end
			end
		elseif dataName == "adminDuty" then
			if isElementStreamedIn(source) then
				processSideWeapons(source)
			end
		elseif dataName == "playerSideWeapons" then
			if isElementStreamedIn(source) then
				processSideWeapons(source)
			end
		elseif dataName == "player.groups" then
			if isElementStreamedIn(source) then
				processSideWeapons(source)
			end
		end
	end
)

addEventHandler("onClientElementModelChange", getRootElement(),
	function ()
		if getElementType(source) == "player" then
			if getElementData(source, "playerSideWeapons") then
				processSideWeapons(source)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "player" then
			if getElementData(source, "playerSideWeapons") then
				processSideWeapons(source)
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if sideWeaponObjects[source] then
			for i = 1, #sideWeaponObjects[source] do
				if isElement(sideWeaponObjects[source][i]) then
					destroyElement(sideWeaponObjects[source][i])
				end
			end

			sideWeaponObjects[source] = nil
		end

		if sideWeaponShaders[source] then
			for i = 1, #sideWeaponShaders[source] do
				if isElement(sideWeaponShaders[source][i]) then
					destroyElement(sideWeaponShaders[source][i])
				end
			end

			sideWeaponShaders[source] = nil
		end
	end
)

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if sideWeaponObjects[source] then
			for i = 1, #sideWeaponObjects[source] do
				if isElement(sideWeaponObjects[source][i]) then
					destroyElement(sideWeaponObjects[source][i])
				end
			end

			sideWeaponObjects[source] = nil
		end

		if sideWeaponShaders[source] then
			for i = 1, #sideWeaponShaders[source] do
				if isElement(sideWeaponShaders[source][i]) then
					destroyElement(sideWeaponShaders[source][i])
				end
			end

			sideWeaponShaders[source] = nil
		end
	end
)

function attachToBoneEX(sizeName, sideId, objectElement, pedElement, boneId, posX, posY, posZ, rotX, rotY, rotZ)
	local skinId = getElementModel(pedElement)
	local multiplier = (positionMultipliers[skinId] or 1) * 2.55

	if sizeName == "small" then
		if primaryMultipliers[skinId] then
			multiplier = primaryMultipliers[skinId] * 2.55
		end

		if sideId == 2 then
			if secondaryMultipliers[skinId] then
				multiplier = secondaryMultipliers[skinId] * 2.55
			end
		end

		if skinRotationOffsets[skinId] then
			rotX = rotX + skinRotationOffsets[skinId][1]
			rotY = rotY + skinRotationOffsets[skinId][2]
			rotZ = rotZ + skinRotationOffsets[skinId][3]
		end

		if skinPositionOffsets[skinId] then
			posX = posX + skinPositionOffsets[skinId][1]
			posY = posY + skinPositionOffsets[skinId][2]
			posZ = posZ + skinPositionOffsets[skinId][3]
		end
	end

	exports.see_boneattach:attachElementToBone(objectElement, pedElement, boneId, posX * multiplier, posY * multiplier, posZ * multiplier, rotX, rotY, rotZ)
end

function processSideWeapons(pedElement)
	local visibleObjects = {}

	if sideWeaponShaders[pedElement] then
		if #sideWeaponShaders[pedElement] > 0 then
			for i = 1, #sideWeaponShaders[pedElement] do
				if isElement(sideWeaponShaders[pedElement][i]) then
					destroyElement(sideWeaponShaders[pedElement][i])
				end
			end
		end
	end

	sideWeaponShaders[pedElement] = {}

	if isElementStreamedIn(pedElement) then
		if getElementData(pedElement, "adminDuty") ~= 1 then
			local playerSideWeapons = getElementData(pedElement, "playerSideWeapons") or {}
			local sideWeaponCount = 0
			local backWeaponCount = 0
			local isIllegal = exports.see_groups:isPlayerHavePermission(pedElement, "hideWeapons")

			for i = 1, #playerSideWeapons do
				local weaponData = playerSideWeapons[i]
				local itemId = weaponData[1]
				local modelId = itemWeaponModel[itemId]
				local hideTheWeapon = false

				if isIllegal and modelId then
					local statId = false

					if modelId == 352 or modelId == 372 then -- TEC-9, UZI
						statId = 75
					elseif modelId == 348 then -- Deagle
						statId = 71
					end

					if statId then
						if getPedStat(pedElement, statId) >= 990 then
							hideTheWeapon = true
						end
					end
				end

				if not hideTheWeapon then
					if weaponData[2] == "inuse" then
						if backWeapons[itemId] then
							backWeaponCount = backWeaponCount + 1

							if backWeaponCount > #backOffsets then
								backWeaponCount = 1
							end
						else
							sideWeaponCount = sideWeaponCount + 1

							if sideWeaponCount > #sideOffsets then
								sideWeaponCount = 1
							end
						end
					elseif weaponData[2] then
						if modelId then
							local pedX, pedY, pedZ = getElementPosition(pedElement)
							local objectElement = createObject(modelId, pedX, pedY, pedZ)

							setElementDimension(objectElement, getElementDimension(pedElement))
							setElementInterior(objectElement, getElementInterior(pedElement))
							setElementCollisionsEnabled(objectElement, false)

							local itemOffset = itemOffsets[itemId]

							if backWeapons[itemId] then
								backWeaponCount = backWeaponCount + 1

								if backWeaponCount > #backOffsets then
									backWeaponCount = 1
								end

								local mainOffset = backOffsets[backWeaponCount]
								local extraOffset = false

								if itemOffset then
									extraOffset = itemOffset[backWeaponCount]
								end

								if extraOffset then
									attachToBoneEX("big", backWeaponCount, objectElement, pedElement, 3, mainOffset[1] + extraOffset[1], mainOffset[2] + extraOffset[2], mainOffset[3] + extraOffset[3], mainOffset[4] + extraOffset[4], mainOffset[5] + extraOffset[5], mainOffset[6] + extraOffset[6])
								else
									attachToBoneEX("big", backWeaponCount, objectElement, pedElement, 3, unpack(mainOffset))
								end
							elseif itemOffset then
								sideWeaponCount = sideWeaponCount + 1

								if sideWeaponCount > #sideOffsets then
									sideWeaponCount = 1
								end

								local mainOffset = sideOffsets[sideWeaponCount]
								local extraOffset = itemOffset[sideWeaponCount]

								attachToBoneEX("small", sideWeaponCount, objectElement, pedElement, 4, mainOffset[1] + extraOffset[1], mainOffset[2] + extraOffset[2], mainOffset[3] + extraOffset[3], mainOffset[4] + extraOffset[4], mainOffset[5] + extraOffset[5], mainOffset[6] + extraOffset[6])
							else
								sideWeaponCount = sideWeaponCount + 1

								if sideWeaponCount > #sideOffsets then
									sideWeaponCount = 1
								end

								attachToBoneEX("small", sideWeaponCount, objectElement, pedElement, 4, unpack(sideOffsets[sideWeaponCount]))
							end

							local paintjobId = tonumber(weaponData[3])

							if paintjobId then
								if paintjobId > 0 then
									local weaponId = itemWeaponId[itemId]

									if weaponId then
										if weaponTextureNames[weaponId] then
											if availablePaintjobs[weaponId][paintjobId] then
												local shaderIndex = #sideWeaponShaders[pedElement] + 1

												sideWeaponShaders[pedElement][shaderIndex] = dxCreateShader("files/texturechanger.fx", 0, 0, false, "object")

												if isElement(sideWeaponShaders[pedElement][shaderIndex]) then
													dxSetShaderValue(sideWeaponShaders[pedElement][shaderIndex], "gTexture", availablePaintjobs[weaponId][paintjobId])
													engineApplyShaderToWorldTexture(sideWeaponShaders[pedElement][shaderIndex], weaponTextureNames[weaponId], objectElement)
												end
											end
										end
									end
								end
							end

							table.insert(visibleObjects, objectElement)
						end
					end
				end
			end
		end
	end

	if sideWeaponObjects[pedElement] then
		for i = 1, #sideWeaponObjects[pedElement] do
			if isElement(sideWeaponObjects[pedElement][i]) then
				destroyElement(sideWeaponObjects[pedElement][i])
			end
		end
	end

	if visibleObjects then
		sideWeaponObjects[pedElement] = visibleObjects
	end
end
